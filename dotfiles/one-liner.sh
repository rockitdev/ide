#!/bin/bash

# One-liner installer for dotfiles
# This file provides different installation methods

# Method 1: Interactive installation (recommended)
echo "Interactive installation (you'll be prompted for options):"
echo 'curl -fsSL https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash'
echo

# Method 2: Silent installation with defaults
echo "Silent installation with all defaults:"
echo 'curl -fsSL https://raw.githubusercontent.com/rockitdev/ide/main/install.sh | bash -s -- --silent'
echo

# Method 3: Custom GitHub username
echo "Installation with custom GitHub username:"
echo 'GITHUB_USERNAME="your-github" curl -fsSL https://raw.githubusercontent.com/your-github/your-repo/main/install.sh | bash'
echo

# Method 4: Download and run locally (for inspection)
echo "Download first, inspect, then run:"
echo 'wget https://raw.githubusercontent.com/rockitdev/ide/main/install.sh'
echo 'cat install.sh  # Review the script'
echo 'bash install.sh'
echo

# Method 5: Clone and install (traditional)
echo "Traditional clone and install:"
echo 'git clone https://github.com/rockitdev/ide.git ~/ide && ~/ide/install.sh'