#!/bin/bash
# Installation script for Sirm Claude Toolbox
# Usage: ./install.sh

set -e

echo "Installing Sirm Claude Toolbox..."

# Create directories
mkdir -p ~/.claude/commands ~/.claude/agents ~/.claude/hooks ~/.claude/scripts ~/.claude-plugin

# Copy commands and agents
echo "Copying commands and agents..."
cp -r commands/* ~/.claude/commands/
cp -r agents/* ~/.claude/agents/

# Copy hook scripts
echo "Copying hook scripts..."
cp .claude-plugin/hooks/format-code.sh ~/.claude/hooks/
cp .claude-plugin/hooks/discord-embed.sh ~/.claude/hooks/
cp .claude-plugin/hooks/discord-notify.sh ~/.claude/scripts/
chmod +x ~/.claude/hooks/*.sh ~/.claude/scripts/discord-notify.sh

# Copy plugin metadata
echo "Copying plugin metadata..."
cp .claude-plugin/plugin.json ~/.claude-plugin/
cp .claude-plugin/README.md ~/.claude-plugin/
cp .claude-plugin/COMMANDS.md ~/.claude-plugin/
cp .claude-plugin/AGENTS.md ~/.claude-plugin/

echo ""
echo "✓ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Add permissions to ~/.claude/settings.json (see README.md for details)"
echo "2. Optional: Set DISCORD_WEBHOOK_URL environment variable for notifications"
echo "3. Test with a slash command like /build-test or /code-explain"
echo ""
echo "Available commands:"
echo "  /commit-push-pr    - Full git workflow"
echo "  /build-test        - Build and test .NET projects"
echo "  /new-project       - Scaffold new .NET project"
echo "  /add-package       - Add NuGet packages"
echo "  /code-explain      - Explain code structure"
echo "  /docs-generate     - Generate documentation"
echo "  /lint              - Run linters"
echo "  /code-optimize     - Optimize performance"
echo "  /code-cleanup      - Clean up code"
echo ""
echo "For more information, see:"
echo "  README.md          - Full documentation"
echo "  COMMANDS.md        - Command reference"
echo "  AGENTS.md          - Agent reference"
echo ""
