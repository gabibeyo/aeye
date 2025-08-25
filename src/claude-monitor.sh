#!/bin/bash

# Enhanced Claude Activity Monitor - Shows prompts, tool usage, todos, and detailed conversations
# This script monitors Claude's comprehensive activity including conversation logs
# FIXED VERSION - with bulletproof signal handling

# Global variables for process tracking
declare -a BACKGROUND_PIDS=()

# Configuration variables (loaded from YAML - required)
CLAUDE_PROJECTS_DIR=""
CLAUDE_CONFIG_FILE=""
MCP_CACHE_DIR=""
CLAUDE_JSON_CHECK_INTERVAL=""
NEW_CONVERSATIONS_CHECK_INTERVAL=""
STATS_UPDATE_INTERVAL=""
MAIN_HEALTH_CHECK_INTERVAL=""
HEALTH_LOG_INTERVAL_MINUTES=""
SHUTDOWN_TIMEOUT=""
ENABLE_DATA_OBFUSCATION=""
DEFAULT_HISTORY_FILTER=""

# Color variables (loaded from YAML)
RED=""
GREEN=""
YELLOW=""
BLUE=""
PURPLE=""
CYAN=""
WHITE=""
GRAY=""
BOLD=""
NC=""

# Function to load YAML configuration
load_config() {
    local config_file="$1"
    
    if [[ -f "$config_file" ]]; then
        log_event "$CYAN" "⚙️" "Config" "Loading YAML configuration from: $config_file"
        
        # Parse YAML using yq (required)
        if command -v yq &> /dev/null; then
            # Load configuration values from YAML (all required)
            CLAUDE_PROJECTS_DIR=$(yq eval '.paths.claude_projects_dir' "$config_file")
            CLAUDE_CONFIG_FILE=$(yq eval '.paths.claude_config_file' "$config_file")
            MCP_CACHE_DIR=$(yq eval '.paths.mcp_cache_dir' "$config_file")
            CLAUDE_JSON_CHECK_INTERVAL=$(yq eval '.timing.claude_json_check_interval' "$config_file")
            NEW_CONVERSATIONS_CHECK_INTERVAL=$(yq eval '.timing.new_conversations_check_interval' "$config_file")
            STATS_UPDATE_INTERVAL=$(yq eval '.timing.stats_update_interval' "$config_file")
            MAIN_HEALTH_CHECK_INTERVAL=$(yq eval '.timing.main_health_check_interval' "$config_file")
            HEALTH_LOG_INTERVAL_MINUTES=$(yq eval '.timing.health_log_interval_minutes' "$config_file")
            SHUTDOWN_TIMEOUT=$(yq eval '.timing.shutdown_timeout' "$config_file")
            ENABLE_DATA_OBFUSCATION=$(yq eval '.security.enable_data_obfuscation' "$config_file")
            DEFAULT_HISTORY_FILTER=$(yq eval '.display.default_history_filter' "$config_file")
            
            # Load color configuration
            RED=$(yq eval '.colors.red' "$config_file")
            GREEN=$(yq eval '.colors.green' "$config_file")
            YELLOW=$(yq eval '.colors.yellow' "$config_file")
            BLUE=$(yq eval '.colors.blue' "$config_file")
            PURPLE=$(yq eval '.colors.purple' "$config_file")
            CYAN=$(yq eval '.colors.cyan' "$config_file")
            WHITE=$(yq eval '.colors.white' "$config_file")
            GRAY=$(yq eval '.colors.gray' "$config_file")
            BOLD=$(yq eval '.colors.bold' "$config_file")
            NC=$(yq eval '.colors.nc' "$config_file")
            
            # Expand environment variables in paths
            CLAUDE_PROJECTS_DIR=$(eval echo "$CLAUDE_PROJECTS_DIR")
            CLAUDE_CONFIG_FILE=$(eval echo "$CLAUDE_CONFIG_FILE")
            MCP_CACHE_DIR=$(eval echo "$MCP_CACHE_DIR")
            
            log_event "$GREEN" "✅" "Config" "YAML configuration loaded successfully"
        else
            echo -e "${RED}❌ Error: yq not found! Install with: brew install yq${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ Error: Configuration file not found: $config_file${NC}"
        exit 1
    fi
}

# Colors loaded from YAML configuration above

# Function to print with timestamp and color
log_event() {
    local color=$1
    local icon=$2
    local source=$3
    local message=$4
    local timestamp=$(date '+%H:%M:%S')
    # Obfuscate sensitive data in message
    local clean_message="$message"
    
    # Obfuscate API keys (sk-*, ghp_*, etc.)
    clean_message=$(echo "$clean_message" | sed -E 's/(sk-[a-zA-Z0-9_-]+)/sk-***REDACTED***/g')
    clean_message=$(echo "$clean_message" | sed -E 's/(ghp_[a-zA-Z0-9_-]+)/ghp_***REDACTED***/g')
    clean_message=$(echo "$clean_message" | sed -E 's/(sk-ant-[a-zA-Z0-9_-]+)/sk-ant-***REDACTED***/g')
    
    # Obfuscate AWS keys
    clean_message=$(echo "$clean_message" | sed -E 's/(AKIA[A-Z0-9]+)/AKIA***REDACTED***/g')
    clean_message=$(echo "$clean_message" | sed -E 's/([A-Za-z0-9/+=]{40})/***REDACTED_SECRET***/g')
    
    # Obfuscate usernames in paths
    clean_message=$(echo "$clean_message" | sed -E 's/\/Users\/[^\/]+/\/Users\/***USER***/g')
    clean_message=$(echo "$clean_message" | sed -E 's/gabrielbeyo/***USER***/g')
    
    # Obfuscate passwords
    clean_message=$(echo "$clean_message" | sed -E 's/(pass[word]*[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1***REDACTED***/gi')
    
    # Obfuscate email addresses
    clean_message=$(echo "$clean_message" | sed -E 's/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/***EMAIL***@***DOMAIN***/g')
    
    # Obfuscate IP addresses
    clean_message=$(echo "$clean_message" | sed -E 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/***IP_ADDRESS***/g')
    
    printf "${GRAY}[%s]${NC} %s ${color}%s${NC} %s\n" "$timestamp" "$icon" "$source" "$clean_message"
}

# Function to truncate long text (disabled - show full text)
truncate_text() {
    local text="$1"
    local max_length=${2:-100}
    # Always return full text without truncation
    echo "$text"
}

# Function to extract and format JSON field
extract_json_field() {
    local json="$1"
    local field="$2"
    echo "$json" | jq -r ".$field // empty" 2>/dev/null
}

# Function to extract and display todos
extract_todos() {
    local json="$1"
    local session_short="$2"
    
    # Check if this is a TodoWrite tool use
    local tool_name=$(echo "$json" | jq -r '.message.content[]? | select(.type == "tool_use") | .name' 2>/dev/null)
    if [[ "$tool_name" == "TodoWrite" ]]; then
        # Extract the todos array
        local todos=$(echo "$json" | jq -r '.message.content[]? | select(.type == "tool_use" and .name == "TodoWrite") | .input.todos' 2>/dev/null)
        if [[ -n "$todos" && "$todos" != "null" ]]; then
            # Parse each todo item
            echo "$todos" | jq -r '.[] | "  \(.status | ascii_upcase) [\(.priority)] \(.content)"' 2>/dev/null | while read -r todo_line; do
                if [[ -n "$todo_line" ]]; then
                    # Color code by status
                    local status=$(echo "$todo_line" | grep -oE '(PENDING|IN_PROGRESS|COMPLETED)')
                    local todo_color="$GRAY"
                    local todo_icon="⚪"
                    
                    case "$status" in
                        "PENDING")
                            todo_color="$YELLOW"
                            todo_icon="⏳"
                            ;;
                        "IN_PROGRESS")
                            todo_color="$BLUE" 
                            todo_icon="🔄"
                            ;;
                        "COMPLETED")
                            todo_color="$GREEN"
                            todo_icon="✅"
                            ;;
                    esac
                    
                    log_event "$todo_color" "$todo_icon" "Todo:$session_short" "$todo_line"
                fi
            done
        fi
    fi
}

# Function to print header
print_header() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                      🤖 Enhanced Claude Activity Monitor                      ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GRAY}Started at: $(date) | Press Ctrl+C to stop${NC}"
    echo -e "${YELLOW}Monitoring: Conversations, Tool Usage, MCP Servers, Configurations${NC}"
    echo -e "${GRAY}Usage: $0 [history_filter] - e.g., '3 days ago', '2025-08-01', 'all', 'live'${NC}"
    echo ""
}

# Function to process conversation line
process_conversation_line() {
    local line="$1"
    local filename="$2"
    local session_short="$3"
    
    if [[ -n "$line" && "$line" == *"{"* ]]; then
        # Try to parse the JSON line
        if echo "$line" | jq . >/dev/null 2>&1; then
            local msg_type=$(extract_json_field "$line" "type")
            local role=$(extract_json_field "$line" "message.role")
            local model=$(extract_json_field "$line" "message.model")
            local content=$(extract_json_field "$line" "message.content")
            local timestamp=$(extract_json_field "$line" "timestamp")
            
            case "$msg_type" in
                "user")
                    # Extract user prompt
                    local user_content=$(echo "$line" | jq -r '.message.content // empty' 2>/dev/null)
                    if [[ -n "$user_content" ]]; then
                        log_event "$GREEN" "💬" "User:$session_short" "\"$user_content\""
                    fi
                    ;;
                "assistant")
                    # Check if it's a tool use or regular response
                    local tool_uses=$(echo "$line" | jq -r '.message.content[]? | select(.type == "tool_use") | .name' 2>/dev/null)
                    local text_content=$(echo "$line" | jq -r '.message.content[]? | select(.type == "text") | .text' 2>/dev/null)
                    
                    if [[ -n "$tool_uses" ]]; then
                        for tool in $tool_uses; do
                            local tool_input=$(echo "$line" | jq -r ".message.content[]? | select(.type == \"tool_use\" and .name == \"$tool\") | .input" 2>/dev/null)
                            log_event "$BLUE" "🔧" "Tool:$session_short" "$tool $tool_input"
                        done
                    elif [[ -n "$text_content" ]]; then
                        log_event "$PURPLE" "🤖" "Claude:$session_short" "\"$text_content\""
                    fi
                    
                    # Check for usage statistics
                    local input_tokens=$(extract_json_field "$line" "message.usage.input_tokens")
                    local output_tokens=$(extract_json_field "$line" "message.usage.output_tokens")
                    if [[ -n "$input_tokens" && -n "$output_tokens" ]]; then
                        log_event "$CYAN" "📊" "Usage:$session_short" "In: $input_tokens tokens, Out: $output_tokens tokens, Model: $model"
                    fi
                    ;;
                "summary")
                    local summary=$(extract_json_field "$line" "summary")
                    if [[ -n "$summary" ]]; then
                        log_event "$YELLOW" "📄" "Summary:$session_short" "$summary"
                    fi
                    ;;
            esac
            
            # Check for tool results
            local tool_result=$(extract_json_field "$line" "toolUseResult")
            if [[ -n "$tool_result" && "$tool_result" != "null" ]]; then
                local tool_type=$(echo "$tool_result" | jq -r 'type' 2>/dev/null)
                if [[ "$tool_type" == "object" ]]; then
                    local file_path=$(echo "$tool_result" | jq -r '.filePath // empty' 2>/dev/null)
                    if [[ -n "$file_path" ]]; then
                        log_event "$GREEN" "📁" "File:$session_short" "Modified: $(basename "$file_path")"
                    fi
                fi
            fi
            
            # Look for todo-related activities
            if echo "$line" | grep -qi "todo\|task\|TodoWrite"; then
                log_event "$YELLOW" "✅" "Todo:$session_short" "Todo activity detected"
            fi
        fi
    fi
}

# Function to show historical conversation data first, then monitor new events
monitor_conversation_logs() {
    local claude_projects="$CLAUDE_PROJECTS_DIR"
    local history_filter="${1:-$DEFAULT_HISTORY_FILTER}"
    
    if [[ -d "$claude_projects" ]]; then
        if [[ "$history_filter" == "live" ]]; then
            log_event "$GRAY" "🔴" "Live" "Live monitoring only - no historical data"
        else
            log_event "$GRAY" "📚" "History" "Loading conversation history from: $history_filter"
            
            # First, show historical data from files (chronologically ordered)
            if [[ -n "$history_filter" && "$history_filter" != "all" ]]; then
                find "$claude_projects" -name "*.jsonl" -type f -newermt "$history_filter"
            else
                find "$claude_projects" -name "*.jsonl" -type f
            fi | while read -r logfile; do
                local session_id=$(basename "$(dirname "$logfile")")
                local filename=$(basename "$logfile" .jsonl)
                local session_short=$(echo "$filename" | cut -c1-8)
                
                # Read the file and process each line with timestamps for sorting
                while IFS= read -r line; do
                    if [[ -n "$line" && "$line" == *"{"* ]]; then
                        local timestamp=$(echo "$line" | jq -r '.timestamp // empty' 2>/dev/null)
                        echo "$timestamp|$logfile|$line"
                    fi
                done < "$logfile"
            done | sort -t'|' -k1,1 | while IFS='|' read -r timestamp logfile line; do
                local filename=$(basename "$logfile" .jsonl)
                local session_short=$(echo "$filename" | cut -c1-8)
                process_conversation_line "$line" "$filename" "$session_short"
            done
            
            log_event "$GREEN" "🔄" "Monitor" "History loaded. Now monitoring for new events..."
        fi
        
        # Then monitor for new events in real-time
        # Start monitoring existing files
        find "$claude_projects" -name "*.jsonl" -type f | while read -r logfile; do
            local session_id=$(basename "$(dirname "$logfile")")
            local filename=$(basename "$logfile" .jsonl)
            local session_short=$(echo "$filename" | cut -c1-8)
            
            # Monitor this conversation log for new lines - BULLETPROOF PATTERN
            (
                # Set up signal handling in subshell
                trap 'exit 0' SIGTERM SIGINT
                tail -f "$logfile" 2>/dev/null | while read -r line; do
                    process_conversation_line "$line" "$filename" "$session_short"
                done
            ) &
            
            # CRITICAL: Track the PID
            local pid=$!
            BACKGROUND_PIDS+=($pid)
            log_event "$BLUE" "📂" "Monitor" "Watching: $session_short (PID: $pid)"
        done
        
        # Also start monitoring for new conversation files
        monitor_new_conversation_files
    fi
}

# Function to monitor MCP logs (enhanced from original)
monitor_mcp_logs() {
    local cache_dir="$MCP_CACHE_DIR"
    
    if [[ -d "$cache_dir" ]]; then
        find "$cache_dir" -name "*.txt" -path "*/mcp-logs-*" | while read -r logfile; do
            local server_name=$(echo "$logfile" | sed -E 's/.*mcp-logs-([^\/]+).*/\1/')
            
            (
                # Set up signal handling in subshell
                trap 'exit 0' SIGTERM SIGINT
                tail -f "$logfile" 2>/dev/null | while read -r line; do
                    if [[ -n "$line" && "$line" == *"{"* ]]; then
                        if echo "$line" | jq . >/dev/null 2>&1; then
                            local debug_msg=$(extract_json_field "$line" "debug")
                            local error_msg=$(extract_json_field "$line" "error")
                            local session_id=$(extract_json_field "$line" "sessionId")
                            local session_short=$(echo "$session_id" | cut -c1-8)
                            
                            if [[ -n "$debug_msg" ]]; then
                                if [[ "$debug_msg" == *"connection"* ]]; then
                                    log_event "$GREEN" "🔌" "MCP:$server_name" "$debug_msg"
                                elif [[ "$debug_msg" == *"tool"* ]]; then
                                    log_event "$BLUE" "🛠️" "MCP:$server_name" "$debug_msg"
                                else
                                    log_event "$CYAN" "🔧" "MCP:$server_name" "$debug_msg"
                                fi
                            elif [[ -n "$error_msg" ]]; then
                                log_event "$RED" "❌" "MCP:$server_name" "$error_msg"
                            fi
                        fi
                    fi
                done
            ) &
            
            # CRITICAL: Track the PID
            local pid=$!
            BACKGROUND_PIDS+=($pid)
            log_event "$CYAN" "🔧" "MCP" "Monitoring MCP server: $server_name (PID: $pid)"
        done
    fi
}

# Function to monitor .claude.json changes (enhanced)
monitor_claude_json() {
    local claude_json="$CLAUDE_CONFIG_FILE"
    
    if [[ -f "$claude_json" ]]; then
        (
            # Set up signal handling in subshell
            trap 'exit 0' SIGTERM SIGINT
            
            local last_startups=$(jq -r '.numStartups // 0' "$claude_json" 2>/dev/null)
            local last_queue=$(jq -r '.promptQueueUseCount // 0' "$claude_json" 2>/dev/null)
            local last_memory=$(jq -r '.memoryUsageCount // 0' "$claude_json" 2>/dev/null)
            
            while true; do
                sleep $CLAUDE_JSON_CHECK_INTERVAL
                if [[ -f "$claude_json" ]]; then
                    local current_startups=$(jq -r '.numStartups // 0' "$claude_json" 2>/dev/null)
                    local current_queue=$(jq -r '.promptQueueUseCount // 0' "$claude_json" 2>/dev/null)
                    local current_memory=$(jq -r '.memoryUsageCount // 0' "$claude_json" 2>/dev/null)
                    
                    if [[ "$current_startups" != "$last_startups" ]]; then
                        log_event "$CYAN" "🚀" "Claude" "Session startup #$current_startups"
                        last_startups=$current_startups
                    fi
                    
                    if [[ "$current_queue" != "$last_queue" ]]; then
                        log_event "$PURPLE" "📝" "Claude" "Prompt queue usage: $current_queue"
                        last_queue=$current_queue
                    fi
                    
                    if [[ "$current_memory" != "$last_memory" ]]; then
                        log_event "$YELLOW" "🧠" "Claude" "Memory usage count: $current_memory"
                        last_memory=$current_memory
                    fi
                fi
            done
        ) &
        
        # CRITICAL: Track the PID
        local pid=$!
        BACKGROUND_PIDS+=($pid)
        log_event "$YELLOW" "⚙️" "Config" "Monitoring claude.json (PID: $pid)"
    fi
}

# Function to monitor for new conversation files and start tailing them
monitor_new_conversation_files() {
    (
        # Set up signal handling in subshell
        trap 'exit 0' SIGTERM SIGINT
        
        local projects_dir="$CLAUDE_PROJECTS_DIR"
        local monitored_files="/tmp/claude_monitored_files_$$"
        
        # Create a list of currently monitored files
        find "$projects_dir" -name "*.jsonl" -type f 2>/dev/null > "$monitored_files"
        
        while true; do
            sleep $NEW_CONVERSATIONS_CHECK_INTERVAL
            
            # Find all current conversation files
            find "$projects_dir" -name "*.jsonl" -type f 2>/dev/null | while read -r logfile; do
                # Check if this file is already being monitored
                if ! grep -q "^$logfile$" "$monitored_files" 2>/dev/null; then
                    local filename=$(basename "$logfile" .jsonl)
                    local session_short=$(echo "$filename" | cut -c1-8)
                    
                    log_event "$GREEN" "🆕" "Session" "New conversation detected: $session_short - starting monitor"
                    
                    # Add to monitored files list
                    echo "$logfile" >> "$monitored_files"
                    
                    # Start monitoring this new file
                    (
                        # Set up signal handling in subshell
                        trap 'exit 0' SIGTERM SIGINT
                        tail -f "$logfile" 2>/dev/null | while read -r line; do
                            process_conversation_line "$line" "$filename" "$session_short"
                        done
                    ) &
                    
                    # Track this PID too
                    local new_pid=$!
                    BACKGROUND_PIDS+=($new_pid)
                fi
            done
        done
    ) &
    
    # CRITICAL: Track the PID
    local pid=$!
    BACKGROUND_PIDS+=($pid)
    log_event "$GREEN" "👀" "New" "Monitoring for new conversations (PID: $pid)"
}

# Function to monitor new conversation files (legacy - for session creation notification)
monitor_new_conversations() {
    local projects_dir="$HOME/.claude/projects"
    
    if [[ -d "$projects_dir" ]]; then
        while true; do
            find "$projects_dir" -name "*.jsonl" -newermt "10 seconds ago" 2>/dev/null | while read -r newfile; do
                local session_id=$(basename "$newfile" .jsonl)
                local session_short=$(echo "$session_id" | cut -c1-8)
                log_event "$GREEN" "🆕" "Session" "New conversation started: $session_short"
            done
            # Use shorter sleep intervals to be more responsive to signals
            for i in {1..100}; do
                sleep 0.1
            done
        done &
    fi
}

# Function to show enhanced statistics
show_enhanced_stats() {
    (
        # Set up signal handling in subshell
        trap 'exit 0' SIGTERM SIGINT
        
        while true; do
            sleep $STATS_UPDATE_INTERVAL
            
            local conversation_count=0
            local mcp_logs_count=0
            local active_projects=0
            
            if [[ -d "$CLAUDE_PROJECTS_DIR" ]]; then
                conversation_count=$(find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" | wc -l)
            fi
            
            if [[ -d "$MCP_CACHE_DIR" ]]; then
                mcp_logs_count=$(find "$MCP_CACHE_DIR" -name "*.txt" -path "*/mcp-logs-*" | wc -l)
            fi
            
            if [[ -f "$CLAUDE_CONFIG_FILE" ]]; then
                active_projects=$(jq -r '.projects | length // 0' "$CLAUDE_CONFIG_FILE" 2>/dev/null)
            fi
            
            local current_sessions=$(find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -newermt "1 hour ago" 2>/dev/null | wc -l)
            
            log_event "$WHITE" "📈" "Stats" "Conversations: $conversation_count, MCP logs: $mcp_logs_count, Projects: $active_projects, Recent: $current_sessions"
        done
    ) &
    
    # CRITICAL: Track the PID
    local pid=$!
    BACKGROUND_PIDS+=($pid)
    log_event "$WHITE" "📊" "Stats" "Statistics monitor started (PID: $pid)"
}

# Function to cleanup background processes - BULLETPROOF VERSION
cleanup() {
    echo -e "\n${YELLOW}🛑 Stopping Enhanced Claude Activity Monitor...${NC}"
    
    # Kill each tracked process individually
    for pid in "${BACKGROUND_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            log_event "$YELLOW" "🛑" "Cleanup" "Stopping PID: $pid"
            kill -TERM "$pid" 2>/dev/null
        fi
    done
    
    # Give processes time to exit gracefully
    sleep $SHUTDOWN_TIMEOUT
    
    # Force kill any remaining processes
    for pid in "${BACKGROUND_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            log_event "$RED" "💀" "Cleanup" "Force killing PID: $pid"
            kill -KILL "$pid" 2>/dev/null
        fi
    done
    
    # Kill any remaining tail processes that might be orphaned
    pkill -f "tail -f.*claude" 2>/dev/null || true
    pkill -f "tail -f.*mcp-logs" 2>/dev/null || true
    pkill -f "claude-monitor-enhanced" 2>/dev/null || true
    
    # Clean up temporary files
    rm -f "/tmp/claude_monitored_files_$$" 2>/dev/null
    
    echo -e "${GREEN}✅ All monitors stopped${NC}"
    exit 0
}

# Main function
main() {
    # Configuration is REQUIRED - no defaults
    local config_file=""
    
    # Check for configuration file argument or use default YAML
    if [[ "$1" == "--config" && -n "$2" ]]; then
        config_file="$2"
        shift 2
    elif [[ -f "$(dirname "${BASH_SOURCE[0]}")/../config/monitor.yaml" ]]; then
        config_file="$(dirname "${BASH_SOURCE[0]}")/../config/monitor.yaml"
    else
        echo -e "${RED}❌ Error: Configuration file required!${NC}"
        echo -e "${YELLOW}Usage: $0 --config path/to/config.yaml [history_filter]${NC}"
        echo -e "${YELLOW}   or: Place config/monitor.yaml in the config directory${NC}"
        echo -e "${CYAN}📖 See README.md for configuration examples${NC}"
        exit 1
    fi
    
    # Load configuration (required)
    load_config "$config_file"
    
    # Validate configuration was loaded properly
    if [[ -z "$CLAUDE_PROJECTS_DIR" ]] || [[ -z "$CLAUDE_CONFIG_FILE" ]] || [[ -z "$RED" ]] || [[ -z "$NC" ]]; then
        echo -e "\033[0;31m❌ Error: Configuration incomplete or invalid!\033[0m"
        echo -e "\033[1;33mCheck that your YAML config has all required fields including colors\033[0m"
        exit 1
    fi
    
    # Check dependencies (both required)
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}❌ Error: jq is required but not installed. Install with: brew install jq${NC}"
        exit 1
    fi
    
    if ! command -v yq &> /dev/null; then
        echo -e "${RED}❌ Error: yq is required for YAML configuration. Install with: brew install yq${NC}"
        exit 1
    fi
    
    # BULLETPROOF signal handling - ONLY these signals, NO EXIT
    trap cleanup SIGINT SIGTERM
    
    # Print header
    print_header
    
    # Kill any existing monitor processes first
    log_event "$YELLOW" "🧹" "Cleanup" "Killing any existing Claude monitor processes..."
    pkill -f "claude-monitor" 2>/dev/null
    pkill -f "tail -f.*claude" 2>/dev/null
    pkill -f "tail -f.*mcp-logs" 2>/dev/null
    sleep 2
    
    # Start monitoring different aspects
    log_event "$GREEN" "🚀" "Monitor" "Starting Enhanced Claude Activity Monitor..."
    log_event "$CYAN" "📁" "Monitor" "Monitoring conversation logs in ~/.claude/projects/"
    log_event "$BLUE" "🔧" "Monitor" "Monitoring MCP server logs"
    log_event "$YELLOW" "⚙️" "Monitor" "Monitoring configuration changes"
    
    # Start all monitoring functions in background  
    monitor_conversation_logs "${1:-$DEFAULT_HISTORY_FILTER}"
    monitor_mcp_logs
    monitor_claude_json
    show_enhanced_stats
    
    log_event "$GREEN" "✅" "Monitor" "All monitors active. You should see prompts, responses, tool usage, todos..."
    echo -e "${GRAY}💡 Tip: Start a new Claude session or use tools to see activity${NC}"
    echo ""
    
    # Keep the script running and responsive to signals
    while true; do
        sleep $MAIN_HEALTH_CHECK_INTERVAL
        
        # Check process health
        local alive_count=0
        for pid in "${BACKGROUND_PIDS[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                alive_count=$((alive_count + 1))
            fi
        done
        
        # Log health check every 2 minutes
        local seconds=$(date +%S)
        seconds=${seconds#0}  # Remove leading zero
        if (( seconds == 0 )); then
            local minutes=$(date +%M)
            minutes=${minutes#0}
            if (( minutes % HEALTH_LOG_INTERVAL_MINUTES == 0 )); then
                log_event "$CYAN" "💓" "Health" "$alive_count/${#BACKGROUND_PIDS[@]} processes running"
            fi
        fi
    done
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi