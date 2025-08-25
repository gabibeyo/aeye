# Usage Guide

This guide covers all the features and usage patterns of Aeye.

## Basic Usage

### Starting the Monitor

```bash
# Default monitoring (last 24 hours + live)
./src/claude-monitor-enhanced.sh

# Live monitoring only (no historical data)
./src/claude-monitor-enhanced.sh live

# Monitor all historical data
./src/claude-monitor-enhanced.sh all
```

### Time Filters

Aeye supports flexible time filtering for historical data:

```bash
# Relative time
./src/claude-monitor-enhanced.sh "3 days ago"
./src/claude-monitor-enhanced.sh "1 week ago"
./src/claude-monitor-enhanced.sh "2 hours ago"

# Specific dates
./src/claude-monitor-enhanced.sh "2025-01-01"
./src/claude-monitor-enhanced.sh "2025-01-15 14:30"

# Date ranges (coming soon)
./src/claude-monitor-enhanced.sh "last week"
./src/claude-monitor-enhanced.sh "this month"
```

## Understanding the Output

### Event Types

Aeye displays different types of events with color-coded indicators:

| Icon | Color | Type | Description |
|------|-------|------|-------------|
| 💬 | Green | User | User prompts and messages |
| 🤖 | Purple | Claude | Claude's responses |
| 🔧 | Blue | Tool | Tool usage and function calls |
| ✅ | Yellow/Green | Todo | Todo list activities |
| 📊 | Cyan | Usage | Token usage and model info |
| 🔌 | Green | MCP | MCP server connections |
| 🛠️ | Blue | MCP | MCP tool operations |
| ❌ | Red | Error | Error messages |
| 📁 | Green | File | File operations |
| 🚀 | Green | System | System events |

### Session Identifiers

Each event includes a session identifier (e.g., `a1b2c3d4`) that helps track which Claude session the activity belongs to.

### Timestamps

All events include precise timestamps in `HH:MM:SS` format for accurate tracking.

## Advanced Features

### Privacy Protection

Aeye automatically obfuscates sensitive information:

- **API Keys**: `sk-***REDACTED***`, `ghp-***REDACTED***`
- **AWS Credentials**: `AKIA***REDACTED***`
- **Passwords**: `password: ***REDACTED***`
- **Emails**: `***EMAIL***@***DOMAIN***`
- **IP Addresses**: `***IP_ADDRESS***`
- **User Paths**: `/Users/***USER***/documents`

### Real-time Monitoring

The tool monitors multiple aspects simultaneously:

1. **Conversation Logs** - New messages and responses
2. **MCP Servers** - Server connections and tool usage
3. **Configuration Changes** - Claude settings updates
4. **Statistics** - Usage metrics and session counts

### Multi-session Support

Aeye can monitor multiple Claude sessions running simultaneously, with each session having its own identifier.

## Keyboard Shortcuts

- **Ctrl+C** - Stop monitoring and exit cleanly
- **Ctrl+Z** - Suspend (use `fg` to resume)

## Examples

### Example 1: Development Workflow Monitoring

```bash
# Start monitoring for a coding session
./src/claude-monitor-enhanced.sh live
```

Sample output:
```
[14:23:15] 💬 User:a1b2c3d4 "Help me debug this Python function"
[14:23:16] 🔧 Tool:a1b2c3d4 read_file {"file": "main.py"}
[14:23:17] 🔧 Tool:a1b2c3d4 search_code {"pattern": "def.*error"}
[14:23:18] 🤖 Claude:a1b2c3d4 "I found the issue in line 23..."
[14:23:19] 📊 Usage:a1b2c3d4 In: 234 tokens, Out: 567 tokens, Model: claude-3-5-sonnet
```

### Example 2: Historical Analysis

```bash
# Review yesterday's activities
./src/claude-monitor-enhanced.sh "1 day ago"
```

### Example 3: Todo Tracking

When Claude uses todo management tools:
```
[15:30:45] ✅ Todo:b2c3d4e5 PENDING [HIGH] Implement error handling
[15:31:02] ✅ Todo:b2c3d4e5 IN_PROGRESS [MEDIUM] Write unit tests
[15:32:18] ✅ Todo:b2c3d4e5 COMPLETED [HIGH] Implement error handling
```

## Performance Tips

### For Large Log Files

If you have extensive conversation history:

```bash
# Use live mode to avoid loading large histories
./src/claude-monitor-enhanced.sh live

# Or limit to recent data
./src/claude-monitor-enhanced.sh "12 hours ago"
```

### Memory Usage

The tool is designed to be lightweight, but for very active sessions:

- Historical data is processed efficiently in chronological order
- Real-time monitoring uses minimal memory
- Background processes are properly cleaned up on exit

## Filtering and Search

### Current Capabilities

- Time-based filtering for historical data
- Automatic session grouping
- Real-time event streaming

### Coming Soon

- Event type filtering (`--only-tools`, `--only-conversations`)
- Keyword search (`--search "error handling"`)
- Export to files (`--export json`)
- Session-specific filtering (`--session a1b2c3d4`)

## Troubleshooting

### No Output Appearing

1. **Check Claude is running**: Ensure Claude Desktop is active
2. **Verify log locations**: `ls ~/.claude/projects/`
3. **Test with live mode**: `./src/claude-monitor-enhanced.sh live`

### Performance Issues

1. **Large history**: Use time filters to limit data
2. **Multiple sessions**: Each session spawns monitoring processes
3. **Clean exit**: Always use Ctrl+C to properly clean up

### Missing Events

1. **Delayed logs**: Some events may appear with slight delays
2. **File permissions**: Ensure read access to Claude directories
3. **jq dependency**: Verify `jq --version` works

## Best Practices

1. **Start with live mode** when first testing
2. **Use time filters** for large conversation histories
3. **Clean exit** with Ctrl+C to avoid orphaned processes
4. **Regular cleanup** if you encounter stuck processes
5. **Check dependencies** if output seems incomplete

## Integration

### With Development Tools

```bash
# Monitor while coding
./src/claude-monitor-enhanced.sh live &
# Continue your development work
```

### With Scripts

```bash
#!/bin/bash
# Start monitoring before running your workflow
./src/claude-monitor-enhanced.sh live &
MONITOR_PID=$!

# Your workflow here
# ...

# Clean up
kill $MONITOR_PID
```

## Getting Help

For additional help:

- Check the [Installation Guide](INSTALLATION.md)
- Review [common issues](https://github.com/yourusername/aeye/issues)
- Join the [community discussions](https://github.com/yourusername/aeye/discussions)
