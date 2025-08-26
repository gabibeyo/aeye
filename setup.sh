#!/bin/bash

# Aeye - Claude Activity Monitor Setup Script
# One-liner installation: curl -fsSL https://raw.githubusercontent.com/gabibeyo/aeye/main/setup.sh | bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Global variables
AEYE_DIR="$HOME/.aeye"
AEYE_REPO="https://github.com/gabibeyo/aeye.git"
AEYE_RAW_BASE="https://raw.githubusercontent.com/gabibeyo/aeye/main"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/aeye"

# Function to print with color and emoji
log() {
    local color=$1
    local emoji=$2
    local message=$3
    echo -e "${color}${emoji} ${message}${NC}"
}

# Function to print header
print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                       👁️  Aeye Setup - Claude Activity Monitor                      ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        log "$RED" "❌" "Unsupported operating system: $OSTYPE"
        log "$YELLOW" "💡" "Aeye currently supports macOS and Linux only"
        exit 1
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies on macOS
install_macos_deps() {
    log "$BLUE" "🍎" "Installing dependencies for macOS..."
    
    # Check if Homebrew is installed
    if ! command_exists brew; then
        log "$YELLOW" "🍺" "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
    
    # Install required packages
    local packages=("jq" "yq" "git" "curl")
    for package in "${packages[@]}"; do
        if ! command_exists "$package"; then
            log "$YELLOW" "📦" "Installing $package..."
            brew install "$package"
        else
            log "$GREEN" "✅" "$package is already installed"
        fi
    done
}

# Function to install dependencies on Linux
install_linux_deps() {
    log "$BLUE" "🐧" "Installing dependencies for Linux..."
    
    # Detect Linux distribution
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        log "$BLUE" "📦" "Detected Debian/Ubuntu system"
        sudo apt-get update
        
        local packages=("jq" "git" "curl")
        for package in "${packages[@]}"; do
            if ! command_exists "$package"; then
                log "$YELLOW" "📦" "Installing $package..."
                sudo apt-get install -y "$package"
            else
                log "$GREEN" "✅" "$package is already installed"
            fi
        done
        
        # Install yq (special case)
        if ! command_exists yq; then
            log "$YELLOW" "📦" "Installing yq..."
            wget -qO /tmp/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            chmod +x /tmp/yq
            sudo mv /tmp/yq /usr/local/bin/yq
        else
            log "$GREEN" "✅" "yq is already installed"
        fi
        
    elif [[ -f /etc/redhat-release ]]; then
        # RHEL/CentOS/Fedora
        log "$BLUE" "📦" "Detected Red Hat/CentOS/Fedora system"
        
        local packages=("jq" "git" "curl")
        for package in "${packages[@]}"; do
            if ! command_exists "$package"; then
                log "$YELLOW" "📦" "Installing $package..."
                if command_exists dnf; then
                    sudo dnf install -y "$package"
                else
                    sudo yum install -y "$package"
                fi
            else
                log "$GREEN" "✅" "$package is already installed"
            fi
        done
        
        # Install yq (special case)
        if ! command_exists yq; then
            log "$YELLOW" "📦" "Installing yq..."
            wget -qO /tmp/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            chmod +x /tmp/yq
            sudo mv /tmp/yq /usr/local/bin/yq
        else
            log "$GREEN" "✅" "yq is already installed"
        fi
        
    elif [[ -f /etc/arch-release ]]; then
        # Arch Linux
        log "$BLUE" "📦" "Detected Arch Linux system"
        
        local packages=("jq" "yq" "git" "curl")
        for package in "${packages[@]}"; do
            if ! command_exists "$package"; then
                log "$YELLOW" "📦" "Installing $package..."
                sudo pacman -S --noconfirm "$package"
            else
                log "$GREEN" "✅" "$package is already installed"
            fi
        done
        
    else
        log "$YELLOW" "⚠️" "Unknown Linux distribution. Please install jq, yq, git, and curl manually."
        log "$CYAN" "💡" "Then run this script again."
        exit 1
    fi
}

# Function to install dependencies
install_dependencies() {
    local os=$(detect_os)
    
    log "$BLUE" "🔧" "Installing dependencies for $os..."
    
    case $os in
        "macos")
            install_macos_deps
            ;;
        "linux")
            install_linux_deps
            ;;
        *)
            log "$RED" "❌" "Unsupported OS: $os"
            exit 1
            ;;
    esac
    
    log "$GREEN" "✅" "All dependencies installed successfully"
}

# Function to verify dependencies
verify_dependencies() {
    log "$BLUE" "🔍" "Verifying dependencies..."
    
    local deps=("jq" "yq" "git" "curl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if command_exists "$dep"; then
            log "$GREEN" "✅" "$dep is available"
        else
            log "$RED" "❌" "$dep is not available"
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log "$RED" "💀" "Missing dependencies: ${missing[*]}"
        log "$YELLOW" "💡" "Please install missing dependencies and run setup again"
        exit 1
    fi
    
    log "$GREEN" "🎉" "All dependencies verified"
}

# Function to create directories
create_directories() {
    log "$BLUE" "📁" "Creating directories..."
    
    mkdir -p "$AEYE_DIR"
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"
    
    log "$GREEN" "✅" "Directories created"
}

# Function to download Aeye files
download_aeye() {
    log "$BLUE" "⬇️" "Downloading Aeye files..."
    
    # Download main script
    log "$YELLOW" "📄" "Downloading claude-monitor.sh..."
    curl -fsSL "$AEYE_RAW_BASE/src/claude-monitor.sh" -o "$AEYE_DIR/claude-monitor.sh"
    chmod +x "$AEYE_DIR/claude-monitor.sh"
    
    # Download configuration file
    log "$YELLOW" "⚙️" "Downloading configuration file..."
    curl -fsSL "$AEYE_RAW_BASE/config/monitor.yaml" -o "$CONFIG_DIR/monitor.yaml"
    
    # Download documentation
    log "$YELLOW" "📚" "Downloading documentation..."
    curl -fsSL "$AEYE_RAW_BASE/README.md" -o "$AEYE_DIR/README.md"
    curl -fsSL "$AEYE_RAW_BASE/USAGE.md" -o "$AEYE_DIR/USAGE.md"
    
    log "$GREEN" "✅" "Aeye files downloaded successfully"
}

# Function to create wrapper script
create_wrapper() {
    log "$BLUE" "🔗" "Creating aeye command..."
    
    cat > "$INSTALL_DIR/aeye" << 'EOF'
#!/bin/bash
# Aeye wrapper script

AEYE_CONFIG="$HOME/.config/aeye/monitor.yaml"
AEYE_SCRIPT="$HOME/.aeye/claude-monitor.sh"

# Check if config exists
if [[ ! -f "$AEYE_CONFIG" ]]; then
    echo "❌ Configuration file not found: $AEYE_CONFIG"
    echo "💡 Run 'aeye setup' to reconfigure"
    exit 1
fi

# Check if script exists
if [[ ! -f "$AEYE_SCRIPT" ]]; then
    echo "❌ Aeye script not found: $AEYE_SCRIPT"
    echo "💡 Run 'aeye setup' to reinstall"
    exit 1
fi

# Special commands
case "$1" in
    "setup")
        echo "🔧 Re-running Aeye setup..."
        curl -fsSL https://raw.githubusercontent.com/gabibeyo/aeye/main/setup.sh | bash
        exit 0
        ;;
    "config")
        echo "📝 Opening configuration file..."
        ${EDITOR:-nano} "$AEYE_CONFIG"
        exit 0
        ;;
    "help"|"--help"|"-h")
        echo "👁️  Aeye - Claude Activity Monitor"
        echo ""
        echo "Usage:"
        echo "  aeye [time_filter]     - Start monitoring (default: last 24 hours)"
        echo "  aeye live              - Live monitoring only"
        echo "  aeye all               - Show all historical data"
        echo "  aeye setup             - Re-run setup"
        echo "  aeye config            - Edit configuration"
        echo "  aeye help              - Show this help"
        echo ""
        echo "Examples:"
        echo "  aeye                   - Monitor last 24 hours + live"
        echo "  aeye '3 days ago'      - Monitor last 3 days + live"
        echo "  aeye '2025-01-01'      - Monitor since specific date"
        echo "  aeye live              - Live monitoring only"
        echo ""
        exit 0
        ;;
esac

# Run the main script with config
exec "$AEYE_SCRIPT" --config "$AEYE_CONFIG" "$@"
EOF

    chmod +x "$INSTALL_DIR/aeye"
    log "$GREEN" "✅" "aeye command created"
}

# Function to setup PATH
setup_path() {
    log "$BLUE" "🛤️" "Setting up PATH..."
    
    # Detect shell
    local shell_name=$(basename "$SHELL")
    local shell_config=""
    
    case $shell_name in
        "bash")
            shell_config="$HOME/.bashrc"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                shell_config="$HOME/.bash_profile"
            fi
            ;;
        "zsh")
            shell_config="$HOME/.zshrc"
            ;;
        "fish")
            shell_config="$HOME/.config/fish/config.fish"
            ;;
        *)
            log "$YELLOW" "⚠️" "Unknown shell: $shell_name"
            shell_config="$HOME/.profile"
            ;;
    esac
    
    # Add to PATH if not already there
    local path_line='export PATH="$HOME/.local/bin:$PATH"'
    
    if [[ -f "$shell_config" ]] && grep -q "\.local/bin" "$shell_config"; then
        log "$GREEN" "✅" "PATH already configured in $shell_config"
    else
        echo "" >> "$shell_config"
        echo "# Added by Aeye installer" >> "$shell_config"
        echo "$path_line" >> "$shell_config"
        log "$GREEN" "✅" "Added $INSTALL_DIR to PATH in $shell_config"
        log "$YELLOW" "💡" "Restart your terminal or run: source $shell_config"
    fi
}

# Function to configure Aeye
configure_aeye() {
    log "$BLUE" "⚙️" "Configuring Aeye..."
    
    # Detect Claude installation paths
    local claude_projects="$HOME/.claude/projects"
    local claude_config="$HOME/.claude.json"
    local mcp_cache="$HOME/Library/Caches/claude-cli-nodejs"
    
    # Linux alternative paths
    if [[ ! -d "$mcp_cache" ]]; then
        local alt_cache="$HOME/.cache/claude-cli-nodejs"
        if [[ -d "$alt_cache" ]]; then
            mcp_cache="$alt_cache"
        fi
    fi
    
    # Update configuration file with detected paths
    local config_file="$CONFIG_DIR/monitor.yaml"
    
    # Use yq to update paths if different from defaults
    if [[ -d "$claude_projects" ]]; then
        log "$GREEN" "✅" "Found Claude projects directory: $claude_projects"
    else
        log "$YELLOW" "⚠️" "Claude projects directory not found: $claude_projects"
        log "$CYAN" "💡" "Make sure Claude Desktop is installed and has been run at least once"
    fi
    
    if [[ -f "$claude_config" ]]; then
        log "$GREEN" "✅" "Found Claude config file: $claude_config"
    else
        log "$YELLOW" "⚠️" "Claude config file not found: $claude_config"
    fi
    
    if [[ -d "$mcp_cache" ]]; then
        log "$GREEN" "✅" "Found MCP cache directory: $mcp_cache"
        # Update config to use detected MCP cache path
        yq eval ".paths.mcp_cache_dir = \"$mcp_cache\"" -i "$config_file"
    else
        log "$YELLOW" "⚠️" "MCP cache directory not found: $mcp_cache"
    fi
    
    log "$GREEN" "✅" "Configuration updated"
}

# Function to test installation
test_installation() {
    log "$BLUE" "🧪" "Testing installation..."
    
    # Test dependencies
    if ! command_exists yq; then
        log "$RED" "❌" "yq not found in PATH"
        return 1
    fi
    
    # Test config file
    if [[ ! -f "$CONFIG_DIR/monitor.yaml" ]]; then
        log "$RED" "❌" "Configuration file not found"
        return 1
    fi
    
    # Test if config is valid YAML
    if ! yq eval '.' "$CONFIG_DIR/monitor.yaml" >/dev/null 2>&1; then
        log "$RED" "❌" "Configuration file is not valid YAML"
        return 1
    fi
    
    # Test if wrapper script exists and is executable
    if [[ ! -x "$INSTALL_DIR/aeye" ]]; then
        log "$RED" "❌" "aeye command not found or not executable"
        return 1
    fi
    
    log "$GREEN" "✅" "Installation test passed"
    return 0
}

# Function to print success message
print_success() {
    echo ""
    log "$GREEN" "🎉" "Aeye installation completed successfully!"
    echo ""
    log "$CYAN" "🚀" "Quick Start:"
    log "$WHITE" "   " "aeye                 # Monitor last 24 hours + live"
    log "$WHITE" "   " "aeye live            # Live monitoring only"
    log "$WHITE" "   " "aeye '3 days ago'    # Monitor last 3 days"
    log "$WHITE" "   " "aeye help            # Show help"
    echo ""
    log "$BLUE" "📚" "Documentation:"
    log "$WHITE" "   " "cat ~/.aeye/README.md    # Full documentation"
    log "$WHITE" "   " "cat ~/.aeye/USAGE.md     # Usage examples"
    echo ""
    log "$YELLOW" "💡" "Configuration:"
    log "$WHITE" "   " "aeye config          # Edit configuration"
    log "$WHITE" "   " "nano ~/.config/aeye/monitor.yaml"
    echo ""
    
    # Check if PATH needs to be updated
    if ! command_exists aeye; then
        log "$YELLOW" "⚠️" "Restart your terminal or run:"
        log "$WHITE" "   " "source ~/.$(basename $SHELL)rc"
        log "$WHITE" "   " "# or for zsh: source ~/.zshrc"
    fi
    
    echo ""
    log "$PURPLE" "👁️" "Happy monitoring with Aeye!"
    echo ""
}

# Function to handle errors
handle_error() {
    local exit_code=$?
    echo ""
    log "$RED" "💥" "Installation failed with exit code: $exit_code"
    log "$YELLOW" "💡" "Please check the error messages above and try again"
    log "$CYAN" "🆘" "For help, visit: https://github.com/gabibeyo/aeye/issues"
    echo ""
    exit $exit_code
}

# Main installation function
main() {
    # Set up error handling
    trap handle_error ERR
    
    print_header
    
    log "$BLUE" "🔍" "Detected OS: $(detect_os)"
    
    # Step 1: Install dependencies
    install_dependencies
    
    # Step 2: Verify dependencies
    verify_dependencies
    
    # Step 3: Create directories
    create_directories
    
    # Step 4: Download Aeye files
    download_aeye
    
    # Step 5: Create wrapper script
    create_wrapper
    
    # Step 6: Setup PATH
    setup_path
    
    # Step 7: Configure Aeye
    configure_aeye
    
    # Step 8: Test installation
    if ! test_installation; then
        log "$RED" "❌" "Installation test failed"
        exit 1
    fi
    
    # Step 9: Print success message
    print_success
}

# Run main function
main "$@"
