# Installation Guide

This guide provides detailed instructions for installing Aeye on different platforms.

## Prerequisites

### macOS (Current Support)
- macOS 10.15 or later
- Homebrew package manager
- Claude Desktop application installed

### Dependencies
- **jq** - JSON processor for parsing log files
- **yq** - YAML processor for configuration files (required)
- **bash** - Version 4.0 or later

## Installation Methods

### Method 1: Quick Install (Recommended)

```bash
# Download and run the install script
curl -fsSL https://raw.githubusercontent.com/gabibeyo/aeye/main/scripts/install.sh | bash
```

### Method 2: Manual Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/gabibeyo/aeye.git
   cd aeye
   ```

2. **Install dependencies**
   ```bash
   # macOS with Homebrew
   brew install jq yq
   
   # Verify installation
   jq --version
   yq --version
   ```

3. **Make script executable**
   ```bash
   chmod +x src/claude-monitor.sh
   ```

4. **Add to PATH (optional)**
   ```bash
   # Add to your shell profile (.bashrc, .zshrc, etc.)
   export PATH="$PATH:/path/to/aeye/src"
   
   # Or create a symlink
   ln -s /path/to/aeye/src/claude-monitor.sh /usr/local/bin/aeye
   ```

### Method 3: Homebrew (Coming Soon)

```bash
# This will be available once the formula is published
brew tap gabibeyo/aeye
brew install aeye
```

## Verification

Test your installation:

```bash
# Run the help command
./src/claude-monitor.sh --help

# Run a quick test
./src/claude-monitor.sh live
```

You should see the monitoring interface start up with colorful output.

## Configuration

### Default Locations
Aeye monitors these default locations:
- **Conversation logs**: `~/.claude/projects/`
- **MCP logs**: `~/Library/Caches/claude-cli-nodejs/`
- **Configuration**: `~/.claude.json`

### Configuration

Aeye uses YAML configuration files. The default configuration is in `config/monitor.yaml`.

To create a custom configuration:

```bash
# Copy the default config
cp config/monitor.yaml ~/.aeye-config.yaml

# Edit your custom configuration
vim ~/.aeye-config.yaml

# Use your custom config
./src/claude-monitor.sh --config ~/.aeye-config.yaml
```

See the [Configuration Example](README.md#configuration-example) for available options.

## Troubleshooting

### Common Issues

**1. "jq: command not found" or "yq: command not found"**
```bash
# Install required dependencies
brew install jq yq
```

**2. "Permission denied"**
```bash
# Make the script executable
chmod +x src/claude-monitor.sh
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
bash -x src/claude-monitor.sh
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
2. Search [existing issues](https://github.com/gabibeyo/aeye/issues)
3. Create a [new issue](https://github.com/gabibeyo/aeye/issues/new) with:
   - Your operating system and version
   - Command you ran
   - Complete error message
   - Output of `jq --version` and `yq --version`
