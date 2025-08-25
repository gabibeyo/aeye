# 👁️ Aeye - Claude Activity Monitor

A sophisticated real-time monitoring tool for Claude AI interactions, providing comprehensive insights into conversations, tool usage, MCP server activity, and system metrics.

## 🌟 Features

- **Real-time Conversation Monitoring** - Track user prompts, Claude responses, and tool usage live
- **MCP Server Integration** - Monitor Model Context Protocol server logs and connections
- **Enhanced Privacy** - Automatic obfuscation of sensitive data (API keys, passwords, emails, IPs)
- **Todo Tracking** - Visual tracking of todo lists and task management
- **Historical Analysis** - Review past conversations with flexible time filtering
- **Multi-session Support** - Monitor multiple Claude sessions simultaneously
- **Rich Terminal UI** - Color-coded output with emojis for easy visual parsing
- **Statistics Dashboard** - Real-time metrics on usage patterns and activity

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/gabibeyo/aeye.git
cd aeye

# Make the script executable
chmod +x claude-monitor.sh

# Run with default settings (last 24 hours)
./claude-monitor.sh

# Run with custom time filter
./claude-monitor.sh "3 days ago"

# Live monitoring only (no historical data)
./claude-monitor.sh live
```

## 📋 Requirements

- **macOS** (Linux support coming soon)
- **jq** - JSON processor (`brew install jq`)
- **yq** - YAML processor (required for configuration: `brew install yq`)
- **Claude Desktop** - The tool monitors Claude Desktop application logs

## ⚙️ Configuration

Aeye uses YAML configuration files for all settings. Configuration files are automatically detected:

1. `--config path/to/config.yaml` (command line argument)
2. `config/monitor.yaml` (auto-detected default)

### Configuration Example

The `config/monitor.yaml` file contains all settings:

```yaml
# Path configurations
paths:
  claude_projects_dir: "$HOME/.claude/projects"
  claude_config_file: "$HOME/.claude.json"
  mcp_cache_dir: "$HOME/Library/Caches/claude-cli-nodejs"

# Timing settings (seconds)
timing:
  claude_json_check_interval: 3
  new_conversations_check_interval: 5
  stats_update_interval: 60
  main_health_check_interval: 5

# Security settings
security:
  enable_data_obfuscation: true
  obfuscate:
    api_keys: true
    passwords: true
    emails: true
    ip_addresses: true

# Monitoring components
monitoring:
  conversation_logs: true
  mcp_servers: true
  config_changes: true
  statistics: true
```

## 🔧 Usage Examples

```bash
# Basic usage with default config
./src/claude-monitor.sh

# Use custom configuration file
./src/claude-monitor.sh --config path/to/custom.yaml

# Monitor with time filter
./src/claude-monitor.sh "2 hours ago"

# Live monitoring only
./src/claude-monitor.sh live

# Monitor all historical data
./src/claude-monitor.sh all
```

## 📊 Sample Output

```
[15:09:10] 🚀 Monitor Starting Enhanced Claude Activity Monitor...
[15:09:15] 💬 User:a1b2c3d4 "How do I implement error handling in Python?"
[15:09:16] 🔧 Tool:a1b2c3d4 search_code {"query": "error handling python"}
[15:09:18] 🤖 Claude:a1b2c3d4 "Here are several effective approaches for error handling..."
[15:09:19] 📊 Usage:a1b2c3d4 In: 150 tokens, Out: 420 tokens, Model: claude-3-5-sonnet
[15:09:20] ✅ Todo:a1b2c3d4 COMPLETED [HIGH] Implement try-catch blocks
```

## 🛡️ Privacy & Security

Aeye automatically obfuscates sensitive information:
- API keys (sk-*, ghp-*, sk-ant-*)
- AWS credentials
- Passwords and secrets
- Email addresses
- IP addresses
- User paths and names

## 📁 Project Structure

```
aeye/
├── src/                    # Source code
│   └── claude-monitor.sh   # Main monitoring script
├── config/                 # Configuration files
│   └── monitor.yaml        # YAML configuration
├── scripts/               # Installation and utility scripts
├── tests/                 # Test suite
├── examples/              # Usage examples
├── INSTALLATION.md        # Installation guide
├── USAGE.md              # Usage documentation
└── CONTRIBUTING.md       # Contributing guidelines
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Issues & Support

Found a bug or have a feature request? Please [open an issue](https://github.com/gabibeyo/aeye/issues).

## 🔮 Roadmap

- [ ] Linux and Windows support
- [ ] Web dashboard interface
- [ ] Plugin system for extensibility
- [ ] Export functionality (JSON, CSV, PDF)
- [ ] Real-time notifications
- [ ] Performance analytics
- [ ] Configuration management UI

---

**Made with ❤️ for the Claude community**
