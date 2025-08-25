# Installation Guide

This guide provides detailed instructions for installing Aeye on different platforms.

## Prerequisites

### macOS (Current Support)
- macOS 10.15 or later
- Homebrew package manager
- Claude Desktop application installed

### Dependencies
- **jq** - JSON processor for parsing log files
- **bash** - Version 4.0 or later

## Installation Methods

### Method 1: Quick Install (Recommended)

```bash
# Download and run the install script
curl -fsSL https://raw.githubusercontent.com/yourusername/aeye/main/scripts/install.sh | bash
```

### Method 2: Manual Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/aeye.git
   cd aeye
   ```

2. **Install dependencies**
   ```bash
   # macOS with Homebrew
   brew install jq
   
   # Verify installation
   jq --version
   ```

3. **Make script executable**
   ```bash
   chmod +x src/claude-monitor-enhanced.sh
   ```

4. **Add to PATH (optional)**
   ```bash
   # Add to your shell profile (.bashrc, .zshrc, etc.)
   export PATH="$PATH:/path/to/aeye/src"
   
   # Or create a symlink
   ln -s /path/to/aeye/src/claude-monitor-enhanced.sh /usr/local/bin/aeye
   ```

### Method 3: Homebrew (Coming Soon)

```bash
# This will be available once the formula is published
brew tap yourusername/aeye
brew install aeye
```

## Verification

Test your installation:

```bash
# Run the help command
./src/claude-monitor-enhanced.sh --help

# Run a quick test
./src/claude-monitor-enhanced.sh live
```

You should see the monitoring interface start up with colorful output.

## Configuration

### Default Locations
Aeye monitors these default locations:
- **Conversation logs**: `~/.claude/projects/`
- **MCP logs**: `~/Library/Caches/claude-cli-nodejs/`
- **Configuration**: `~/.claude.json`

### Custom Configuration
Create a configuration file at `~/.aeye/config.yaml`:

```yaml
# Example configuration (coming in v2.0)
paths:
  claude_projects: "~/.claude/projects"
  mcp_logs: "~/Library/Caches/claude-cli-nodejs"
  
monitoring:
  default_history: "24 hours ago"
  refresh_interval: 1
  
privacy:
  obfuscate_emails: true
  obfuscate_paths: true
  obfuscate_keys: true
```

## Troubleshooting

### Common Issues

**1. "jq: command not found"**
```bash
# Install jq
brew install jq
```

**2. "Permission denied"**
```bash
# Make the script executable
chmod +x src/claude-monitor-enhanced.sh
```

**3. "No conversation logs found"**
- Ensure Claude Desktop is installed and has been used
- Check that logs exist: `ls ~/.claude/projects/`

**4. "Background processes not cleaning up"**
```bash
# Kill any stuck processes
pkill -f "claude-monitor"
```

### Debug Mode

Run with debug output:
```bash
# Enable bash debugging
bash -x src/claude-monitor-enhanced.sh
```

## Platform-Specific Notes

### macOS
- Tested on macOS 12+ (Monterey and later)
- Requires Xcode Command Line Tools for some dependencies

### Linux (Experimental)
- Ubuntu 20.04+ or equivalent
- Install jq: `sudo apt-get install jq`
- May require path adjustments for Claude installation

### Windows
- Not currently supported
- WSL2 with Ubuntu may work but is untested

## Uninstallation

To remove Aeye:

```bash
# Remove the repository
rm -rf /path/to/aeye

# Remove symlinks (if created)
rm /usr/local/bin/aeye

# Remove configuration (optional)
rm -rf ~/.aeye
```

## Getting Help

If you encounter issues:

1. Check the [Troubleshooting section](#troubleshooting)
2. Search [existing issues](https://github.com/yourusername/aeye/issues)
3. Create a [new issue](https://github.com/yourusername/aeye/issues/new) with:
   - Your operating system and version
   - Command you ran
   - Complete error message
   - Output of `jq --version`
