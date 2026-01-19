#!/bin/bash
set -e

echo "Testing: Safe installation with multiple plugins"
echo "================================================="
echo ""

# Get repo directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Setup test directories
TEST_BASE="$HOME/.claude-test-$$"
TEST_COMMANDS="$TEST_BASE/commands"
TEST_AGENTS="$TEST_BASE/agents"

# Create mock other plugin
OTHER_PLUGIN="other-plugin"
OTHER_COMMAND_FILE="$TEST_COMMANDS/$OTHER_PLUGIN/other-command.md"
OTHER_AGENT_FILE="$TEST_AGENTS/$OTHER_PLUGIN/other-agent.md"

# Cleanup function
cleanup() {
    rm -rf "$TEST_BASE"
}
trap cleanup EXIT

echo "1. Setting up mock ~/.claude directory..."
mkdir -p "$TEST_COMMANDS/$OTHER_PLUGIN"
mkdir -p "$TEST_AGENTS/$OTHER_PLUGIN"

echo "2. Creating mock other-plugin files..."
cat > "$OTHER_COMMAND_FILE" <<'EOF'
---
name: other-command
description: "Command from another plugin"
---

# Other Command

This should not be touched by sirm-toolbox installer.
EOF

cat > "$OTHER_AGENT_FILE" <<'EOF'
---
name: other-agent
description: "Agent from another plugin"
model: sonnet
color: red
---

# Other Agent

This should not be touched by sirm-toolbox installer.
EOF

echo "3. Recording checksums of other-plugin files..."
OTHER_CMD_CHECKSUM=$(md5sum "$OTHER_COMMAND_FILE" | awk '{print $1}')
OTHER_AGENT_CHECKSUM=$(md5sum "$OTHER_AGENT_FILE" | awk '{print $1}')

echo "4. Simulating sirm-toolbox installation..."
# Create sirm-toolbox namespace
SIRM_COMMANDS="$TEST_COMMANDS/sirm-toolbox"
SIRM_AGENTS="$TEST_AGENTS/sirm-toolbox"

mkdir -p "$SIRM_COMMANDS"
mkdir -p "$SIRM_AGENTS"

# Symlink our files (simulating installer)
find "$REPO_DIR/commands" -name "*.md" -type f | while read file; do
    basename=$(basename "$file")
    ln -sf "$file" "$SIRM_COMMANDS/$basename"
done

find "$REPO_DIR/agents" -name "*.md" -type f | while read file; do
    basename=$(basename "$file")
    ln -sf "$file" "$SIRM_AGENTS/$basename"
done

echo "5. Verifying sirm-toolbox files were created..."
if [ ! -d "$SIRM_COMMANDS" ]; then
    echo "✗ Test failed: sirm-toolbox commands directory not created"
    exit 1
fi

if [ ! -d "$SIRM_AGENTS" ]; then
    echo "✗ Test failed: sirm-toolbox agents directory not created"
    exit 1
fi

SIRM_CMD_COUNT=$(find "$SIRM_COMMANDS" -name "*.md" | wc -l)
SIRM_AGENT_COUNT=$(find "$SIRM_AGENTS" -name "*.md" | wc -l)

echo "  ✓ Created $SIRM_CMD_COUNT command symlinks"
echo "  ✓ Created $SIRM_AGENT_COUNT agent symlinks"

echo "6. Verifying other-plugin files were NOT modified..."
if [ ! -f "$OTHER_COMMAND_FILE" ]; then
    echo "✗ Test failed: other-plugin command file was deleted"
    exit 1
fi

if [ ! -f "$OTHER_AGENT_FILE" ]; then
    echo "✗ Test failed: other-plugin agent file was deleted"
    exit 1
fi

NEW_CMD_CHECKSUM=$(md5sum "$OTHER_COMMAND_FILE" | awk '{print $1}')
NEW_AGENT_CHECKSUM=$(md5sum "$OTHER_AGENT_FILE" | awk '{print $1}')

if [ "$OTHER_CMD_CHECKSUM" != "$NEW_CMD_CHECKSUM" ]; then
    echo "✗ Test failed: other-plugin command file was modified"
    exit 1
fi

if [ "$OTHER_AGENT_CHECKSUM" != "$NEW_AGENT_CHECKSUM" ]; then
    echo "✗ Test failed: other-plugin agent file was modified"
    exit 1
fi

echo "  ✓ other-plugin files unchanged"

echo "7. Verifying directory structure..."
if [ ! -d "$TEST_COMMANDS/$OTHER_PLUGIN" ]; then
    echo "✗ Test failed: other-plugin directory was removed"
    exit 1
fi

if [ ! -d "$TEST_AGENTS/$OTHER_PLUGIN" ]; then
    echo "✗ Test failed: other-plugin agent directory was removed"
    exit 1
fi

echo "  ✓ Directory structure intact"

echo ""
echo "================================================="
echo "✓ All tests passed!"
echo "================================================="
echo ""
echo "Summary:"
echo "  - sirm-toolbox namespace created successfully"
echo "  - $SIRM_CMD_COUNT commands and $SIRM_AGENT_COUNT agents symlinked"
echo "  - other-plugin files completely untouched"
echo "  - Directory structure preserved"
echo ""
echo "✓ Safe installation verified"
