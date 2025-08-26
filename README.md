# 👁️ Aeye - Claude Activity Monitor

A sophisticated real-time monitoring tool for Claude AI interactions, providing comprehensive insights into conversations, tool usage, MCP server activity, and system metrics.

## 📖 Table of Contents

- [🌟 Features](#🌟-features)
- [🚀 Quick Start](#🚀-quick-start)
- [📋 Requirements](#📋-requirements)
- [📦 Installation Details](#📦-installation-details)
- [⚙️ Configuration](#⚙️-configuration)
- [🔧 Usage Examples](#🔧-usage-examples)
- [✅ Verification](#✅-verification)
- [📊 Sample Output](#📊-sample-output)
- [🔧 Troubleshooting](#🔧-troubleshooting)
- [🗑️ Uninstallation](#🗑️-uninstallation)
- [🏗️ Architecture](#🏗️-architecture)
- [🛡️ Privacy & Security](#🛡️-privacy--security)
- [📁 Project Structure](#📁-project-structure)
- [🎯 Next Steps](#🎯-next-steps)
- [🤝 Contributing](#🤝-contributing)
- [🆘 Getting Help](#🆘-getting-help)
- [🔮 Roadmap](#🔮-roadmap)

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

### One-liner Installation (Recommended)

```bash
# Install Aeye with automatic dependency installation
curl -fsSL https://raw.githubusercontent.com/gabibeyo/aeye/main/setup.sh | bash

# Start monitoring (after installation)
aeye

# Or start live monitoring only
aeye live
```

### Quick Download & Run (No Installation)

For testing or one-time use without installing:

```bash
# Download script and config to current directory
curl -fsSL https://raw.githubusercontent.com/gabibeyo/aeye/main/src/claude-monitor.sh -o claude-monitor.sh
curl -fsSL https://raw.githubusercontent.com/gabibeyo/aeye/main/config/monitor.yaml -o monitor.yaml

# Make executable and run directly
chmod +x claude-monitor.sh
./claude-monitor.sh --config monitor.yaml

# With time filters
./claude-monitor.sh --config monitor.yaml "3 days ago"
./claude-monitor.sh --config monitor.yaml live
```

**Requirements:** You still need `jq` and `yq` installed:
```bash
# macOS
brew install jq yq

# Ubuntu/Debian  
sudo apt-get install jq
wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && chmod +x /usr/local/bin/yq
```

### Manual Installation (Full Repository)

```bash
# Clone the repository
git clone https://github.com/gabibeyo/aeye.git
cd aeye

# Install dependencies
brew install jq yq  # macOS
# or
sudo apt-get install jq && wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64  # Linux

# Make the script executable
chmod +x src/claude-monitor.sh

# Run with configuration file (REQUIRED)
./src/claude-monitor.sh --config config/monitor.yaml

# Run with custom time filter
./src/claude-monitor.sh --config config/monitor.yaml "3 days ago"

# Live monitoring only (no historical data)
./src/claude-monitor.sh --config config/monitor.yaml live
```

## 📋 Requirements

- **macOS or Linux** - Full support for both operating systems
- **jq** - JSON processor (auto-installed by setup script)
- **yq** - YAML processor (auto-installed by setup script) 
- **git** - Version control (auto-installed by setup script)
- **curl** - HTTP client (auto-installed by setup script)
- **Claude Desktop** - The tool monitors Claude Desktop application logs

### Supported Operating Systems

#### macOS
- ✅ **Full Support** - Auto-installs via Homebrew
- Requires: macOS 10.14+ (Mojave or later)
- Dependencies installed: `jq`, `yq`, `git`, `curl`
- Homebrew is automatically installed if not present

#### Linux
- ✅ **Full Support** - Auto-installs via system package manager
- Supported distributions:
  - **Ubuntu/Debian** (uses `apt`)
  - **RHEL/CentOS/Fedora** (uses `dnf`/`yum`)
  - **Arch Linux** (uses `pacman`)
- Dependencies installed: `jq`, `yq`, `git`, `curl`

#### Windows
- ❌ **Not yet supported** - Coming soon!
- WSL2 with Ubuntu should work (untested)

### Auto-Installation

The setup script automatically installs all required dependencies:

- **macOS**: Uses Homebrew (installs Homebrew if not present)
- **Linux**: Uses system package manager (apt, dnf/yum, pacman)

No manual dependency installation required when using the one-liner setup!

## 📦 Installation Details

### What Gets Installed

The setup script installs Aeye in these locations:

```
~/.aeye/                    # Main installation directory
├── claude-monitor.sh       # Main monitoring script
├── README.md              # Documentation
└── USAGE.md               # Usage examples

~/.config/aeye/            # Configuration directory
└── monitor.yaml           # Main configuration file

~/.local/bin/              # Executable directory
└── aeye                   # Command wrapper script
```

### Automatic Dependency Installation

**macOS:**
- Installs Homebrew if not present
- Runs: `brew install jq yq git curl`

**Ubuntu/Debian:**
- Updates package list
- Runs: `apt-get install jq git curl`
- Downloads latest `yq` binary from GitHub

**RHEL/CentOS/Fedora:**
- Uses `dnf` or `yum` for packages
- Downloads latest `yq` binary from GitHub

**Arch Linux:**
- Runs: `pacman -S jq yq git curl`

### PATH Configuration

The setup script automatically adds `~/.local/bin` to your PATH by modifying:
- `~/.bashrc` (bash)
- `~/.zshrc` (zsh) 
- `~/.config/fish/config.fish` (fish)
- `~/.profile` (fallback)

### Manual Installation Options

#### Full Manual Installation

If you prefer to install manually or the automatic installer doesn't work:

**1. Install Dependencies**

**macOS:**
```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install jq yq git curl
```

**Ubuntu/Debian:**
```bash
# Update package list
sudo apt-get update

# Install dependencies
sudo apt-get install jq git curl

# Install yq
wget -qO /tmp/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod +x /tmp/yq
sudo mv /tmp/yq /usr/local/bin/yq
```

**RHEL/CentOS/Fedora:**
```bash
# Install dependencies
sudo dnf install jq git curl  # or: sudo yum install jq git curl

# Install yq
wget -qO /tmp/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod +x /tmp/yq
sudo mv /tmp/yq /usr/local/bin/yq
```

**2. Download and Install Aeye**

```bash
# Create directories
mkdir -p ~/.aeye ~/.config/aeye ~/.local/bin

# Download main script
curl -fsSL https://raw.githubusercontent.com/gabibeyo/aeye/main/src/claude-monitor.sh -o ~/.aeye/claude-monitor.sh
chmod +x ~/.aeye/claude-monitor.sh

# Download configuration
curl -fsSL https://raw.githubusercontent.com/gabibeyo/aeye/main/config/monitor.yaml -o ~/.config/aeye/monitor.yaml

# Create wrapper script
cat > ~/.local/bin/aeye << 'EOF'
#!/bin/bash
AEYE_CONFIG="$HOME/.config/aeye/monitor.yaml"
AEYE_SCRIPT="$HOME/.aeye/claude-monitor.sh"
exec "$AEYE_SCRIPT" --config "$AEYE_CONFIG" "$@"
EOF
chmod +x ~/.local/bin/aeye

# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
source ~/.bashrc  # or ~/.zshrc
```

## ⚙️ Configuration

Aeye uses YAML configuration files for all settings. Configuration handling differs by installation method:

### Setup Script Installation
- **Config Location**: `~/.config/aeye/monitor.yaml` (automatically created)
- **Usage**: `aeye` (config detected automatically)
- **Edit Config**: `aeye config` (opens in your default editor)

### Quick Download
- **Config Location**: `monitor.yaml` (downloaded to current directory)
- **Usage**: `./claude-monitor.sh --config monitor.yaml`
- **Edit Config**: Use any text editor: `nano monitor.yaml`

### Manual Installation  
- **Config Location**: `config/monitor.yaml` (in repository)
- **Usage**: `./src/claude-monitor.sh --config config/monitor.yaml`
- **Custom Config**: `./src/claude-monitor.sh --config path/to/custom.yaml`

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

### After One-liner Installation

```bash
# Basic usage with default config (last 24 hours)
aeye

# Monitor with time filter
aeye "2 hours ago"

# Live monitoring only
aeye live

# Monitor all historical data
aeye all

# Edit configuration
aeye config

# Show help
aeye help

# Re-run setup
aeye setup
```

### Quick Download Usage

```bash
# After downloading to current directory
./claude-monitor.sh --config monitor.yaml

# With time filters
./claude-monitor.sh --config monitor.yaml "2 hours ago"
./claude-monitor.sh --config monitor.yaml live
./claude-monitor.sh --config monitor.yaml all
```

### Manual Installation Usage

```bash
# Basic usage with required config file
./src/claude-monitor.sh --config config/monitor.yaml

# Use custom configuration file
./src/claude-monitor.sh --config path/to/custom.yaml

# Monitor with time filter (config always required)
./src/claude-monitor.sh --config config/monitor.yaml "2 hours ago"

# Live monitoring only
./src/claude-monitor.sh --config config/monitor.yaml live

# Monitor all historical data
./src/claude-monitor.sh --config config/monitor.yaml all
```

## ✅ Verification

Test your installation:

```bash
# Check that aeye command is available
which aeye

# Show help
aeye help

# Test configuration
aeye config

# Run a quick test (live monitoring)
aeye live
```

You should see the monitoring interface start up with colorful output.

## 📊 Sample Output

```
[15:09:10] 🚀 Monitor Starting Enhanced Claude Activity Monitor...
[15:09:15] 💬 User:a1b2c3d4 "How do I implement error handling in Python?"
[15:09:16] 🔧 Tool:a1b2c3d4 search_code {"query": "error handling python"}
[15:09:18] 🤖 Claude:a1b2c3d4 "Here are several effective approaches for error handling..."
[15:09:19] 📊 Usage:a1b2c3d4 In: 150 tokens, Out: 420 tokens, Model: claude-3-5-sonnet
[15:09:20] ✅ Todo:a1b2c3d4 COMPLETED [HIGH] Implement try-catch blocks
```

## 🔧 Troubleshooting

### Common Issues

**1. "aeye: command not found"**
```bash
# Restart terminal or reload shell config
source ~/.bashrc  # or ~/.zshrc

# Check if PATH is set correctly
echo $PATH | grep -o ~/.local/bin
```

**2. "yq: command not found"**
```bash
# Manually install yq
wget -qO /tmp/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod +x /tmp/yq
sudo mv /tmp/yq /usr/local/bin/yq
```

**3. "Configuration file not found"**
```bash
# Re-download configuration
curl -fsSL https://raw.githubusercontent.com/gabibeyo/aeye/main/config/monitor.yaml -o ~/.config/aeye/monitor.yaml
```

**4. "No conversation logs found"**
- Ensure Claude Desktop is installed and has been used
- Check that logs exist: `ls ~/.claude/projects/`

**5. Permission errors**
```bash
# Fix permissions
chmod +x ~/.aeye/claude-monitor.sh
chmod +x ~/.local/bin/aeye
```

### Debug Mode

Run with debug output:
```bash
# Enable debug mode
bash -x ~/.aeye/claude-monitor.sh --config ~/.config/aeye/monitor.yaml
```

### Re-run Setup

If something goes wrong, you can re-run the setup:
```bash
# Re-run the installer
aeye setup

# Or run directly
curl -fsSL https://raw.githubusercontent.com/gabibeyo/aeye/main/setup.sh | bash
```

## 🗑️ Uninstallation

To remove Aeye completely:

```bash
# Remove installation directories
rm -rf ~/.aeye ~/.config/aeye

# Remove command
rm ~/.local/bin/aeye

# Remove PATH entry (optional)
# Edit your shell config file and remove the PATH line
```

## 🏗️ Architecture

Aeye uses a clean separation of concerns with two main components:

### Core Monitoring Script
- **Location**: `~/.aeye/claude-monitor.sh` (via setup) or `src/claude-monitor.sh` (manual)
- **Purpose**: Pure monitoring functionality with comprehensive log parsing
- **Requirements**: Always needs `--config` parameter with YAML configuration file
- **Features**: Signal handling, process management, real-time monitoring

### Wrapper Script (Setup Installation Only)
- **Location**: `~/.local/bin/aeye` (created by setup.sh)
- **Purpose**: User-friendly interface and convenience commands
- **Features**:
  - Automatic config file detection (`~/.config/aeye/monitor.yaml`)
  - Built-in commands: `aeye config`, `aeye setup`, `aeye help`
  - Simplified usage: `aeye` instead of complex paths
  - Error handling and helpful messages

### Installation Methods Comparison

| Method | Command | Config Management | Wrapper | Use Case |
|--------|---------|-------------------|---------|----------|
| **Setup Script** | `aeye` | Automatic | ✅ Yes | Regular use, easy commands |
| **Quick Download** | `./claude-monitor.sh --config monitor.yaml` | Manual | ❌ No | Testing, one-time use |
| **Manual Install** | `./src/claude-monitor.sh --config config/monitor.yaml` | Manual | ❌ No | Development, customization |

## 🛡️ Privacy & Security

Aeye can automatically obfuscate sensitive information when `enable_data_obfuscation: true` in the configuration:
- API keys (sk-*, ghp-*, sk-ant-*)
- AWS credentials
- Passwords and secrets
- Email addresses
- IP addresses
- User paths and names

### Disabling Data Obfuscation

To see raw, unobfuscated data (useful for debugging), set in your configuration:

```yaml
security:
  enable_data_obfuscation: false
```

**Note:** When disabled, sensitive data like API keys and passwords will be displayed in plain text. Use with caution.

## 📁 Project Structure

```
aeye/
├── src/                    # Source code
│   └── claude-monitor.sh   # Main monitoring script
├── config/                 # Configuration files
│   └── monitor.yaml        # YAML configuration
├── setup.sh               # One-liner installation script
├── README.md              # Complete project documentation
├── USAGE.md               # Usage documentation
├── CONTRIBUTING.md        # Contributing guidelines
├── CHANGELOG.md           # Version history
└── LICENSE                # MIT license
```

## 🎯 Next Steps

After installation:

1. **Start monitoring**: `aeye`
2. **Customize configuration**: `aeye config`
3. **Try different filters**: `aeye "3 days ago"`
4. **Live monitoring**: `aeye live`
5. **Read the documentation**: `cat ~/.aeye/README.md`

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Getting Help

If you encounter issues:

1. Check the [Troubleshooting section](#🔧-troubleshooting)
2. Run `aeye help` for usage information
3. Search [existing issues](https://github.com/gabibeyo/aeye/issues)
4. Create a [new issue](https://github.com/gabibeyo/aeye/issues/new) with:
   - Your operating system and version
   - Command you ran
   - Complete error message
   - Output of `jq --version` and `yq --version`

## 🔮 Roadmap

- [x] Linux support (✅ Completed)
- [x] One-liner installation script (✅ Completed)
- [ ] Windows support
- [ ] Web dashboard interface
- [ ] Plugin system for extensibility
- [ ] Export functionality (JSON, CSV, PDF)
- [ ] Real-time notifications
- [ ] Performance analytics
- [ ] Configuration management UI

---

**Made with ❤️ for the Claude community**
