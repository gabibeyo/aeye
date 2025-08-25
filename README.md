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
git clone https://github.com/yourusername/aeye.git
cd aeye

# Make the script executable
chmod +x claude-monitor-enhanced.sh

# Run with default settings (last 24 hours)
./claude-monitor-enhanced.sh

# Run with custom time filter
./claude-monitor-enhanced.sh "3 days ago"

# Live monitoring only (no historical data)
./claude-monitor-enhanced.sh live
```

## 📋 Requirements

- **macOS** (Linux support coming soon)
- **jq** - JSON processor (`brew install jq`)
- **Claude Desktop** - The tool monitors Claude Desktop application logs

## 🔧 Usage Examples

```bash
# Monitor all historical data
./claude-monitor-enhanced.sh all

# Monitor from specific date
./claude-monitor-enhanced.sh "2025-01-01"

# Monitor last week
./claude-monitor-enhanced.sh "1 week ago"

# Live monitoring only
./claude-monitor-enhanced.sh live
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
│   └── claude-monitor-enhanced.sh
├── docs/                   # Documentation
├── tests/                  # Test suite
├── scripts/               # Installation and utility scripts
├── config/                # Configuration files
└── examples/              # Usage examples
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Issues & Support

Found a bug or have a feature request? Please [open an issue](https://github.com/yourusername/aeye/issues).

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
