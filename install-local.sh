#!/bin/bash
# Local installation script for sirmaelstroms-claude-code
# Creates symlinks from ~/.claude/ to the plugin directory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing sirmaelstroms-claude-code locally..."

# Create symlinks for commands and agents
ln -sf "$SCRIPT_DIR/commands" "$CLAUDE_DIR/commands" || true
ln -sf "$SCRIPT_DIR/agents" "$CLAUDE_DIR/agents" || true

# Copy hooks (don't symlink to avoid breaking existing hooks)
if [ -d "$SCRIPT_DIR/.claude/hooks" ]; then
    mkdir -p "$CLAUDE_DIR/hooks"
    cp -r "$SCRIPT_DIR/.claude/hooks/"* "$CLAUDE_DIR/hooks/" || true
fi

echo "✓ Installation complete"
echo ""
echo "Commands installed:"
ls -1 "$SCRIPT_DIR/commands"/*/*.md | wc -l
echo ""
echo "Agents installed:"
ls -1 "$SCRIPT_DIR/agents"/*/*.md | wc -l
echo ""
echo "Hooks installed in: $CLAUDE_DIR/hooks/"
