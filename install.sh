#!/bin/bash
set -e

echo "Installing sirmaelstroms-claude-code..."

# Get absolute path to repo
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure we're in a git repo
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Error: Must run from git repository root"
    exit 1
fi

# Check if already installed
if [ -L ~/.claude/commands ] || [ -L ~/.claude/agents ]; then
    echo "Existing installation detected."
    read -p "Remove and reinstall? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f ~/.claude/commands ~/.claude/agents
        echo "Removed existing symlinks"
    else
        echo "Installation cancelled"
        exit 0
    fi
fi

# Create .claude directory if needed
mkdir -p ~/.claude

# Symlink commands and agents
echo "Creating symlinks..."
ln -sf "$REPO_DIR/.claude/commands" ~/.claude/commands
ln -sf "$REPO_DIR/.claude/agents" ~/.claude/agents

# Copy hooks (scripts need to be executable and may be customized)
echo "Installing hooks..."
mkdir -p ~/.claude/hooks
cp -r "$REPO_DIR/.claude/hooks/"* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# Copy plugin metadata
echo "Installing plugin metadata..."
mkdir -p ~/.claude-plugin
cp "$REPO_DIR/.claude-plugin/plugin.json" ~/.claude-plugin/
cp "$REPO_DIR/.claude-plugin/marketplace.json" ~/.claude-plugin/ 2>/dev/null || true

echo ""
echo "✓ Installation complete!"
echo ""
echo "Installed:"
echo "  Commands: ~/.claude/commands -> $REPO_DIR/.claude/commands"
echo "  Agents: ~/.claude/agents -> $REPO_DIR/.claude/agents"
echo "  Hooks: ~/.claude/hooks/ (copied)"
echo ""
echo "See QUICKSTART.md for next steps"

