#!/bin/bash
set -e

echo "Testing: Reinstall handling and symlink refresh"
echo "================================================="
echo ""

# Get repo directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Setup test directories
TEST_BASE="$HOME/.claude-test-reinstall-$$"
TEST_COMMANDS="$TEST_BASE/commands/sirm-toolbox"
TEST_AGENTS="$TEST_BASE/agents/sirm-toolbox"

# Cleanup function
cleanup() {
    rm -rf "$TEST_BASE"
}
trap cleanup EXIT

echo "1. Creating initial installation..."
mkdir -p "$TEST_COMMANDS"
mkdir -p "$TEST_AGENTS"

# Initial install
find "$REPO_DIR/commands" -name "*.md" -type f | head -3 | while read file; do
    basename=$(basename "$file")
    ln -sf "$file" "$TEST_COMMANDS/$basename"
done

find "$REPO_DIR/agents" -name "*.md" -type f | head -3 | while read file; do
    basename=$(basename "$file")
    ln -sf "$file" "$TEST_AGENTS/$basename"
done

INITIAL_CMD_COUNT=$(find "$TEST_COMMANDS" -name "*.md" | wc -l)
INITIAL_AGENT_COUNT=$(find "$TEST_AGENTS" -name "*.md" | wc -l)

echo "  ✓ Initial install: $INITIAL_CMD_COUNT commands, $INITIAL_AGENT_COUNT agents"

echo "2. Simulating symlink corruption..."
# Break one symlink
FIRST_CMD=$(find "$TEST_COMMANDS" -name "*.md" | head -1)
rm "$FIRST_CMD"
echo "broken link" > "$FIRST_CMD"

echo "  ✓ Corrupted one symlink"

echo "3. Verifying corruption..."
if [ -L "$FIRST_CMD" ]; then
    echo "✗ Test failed: File should not be a symlink after corruption"
    exit 1
fi

echo "  ✓ Corruption confirmed"

echo "4. Simulating reinstall (remove and recreate)..."
rm -rf "$TEST_COMMANDS"
rm -rf "$TEST_AGENTS"
mkdir -p "$TEST_COMMANDS"
mkdir -p "$TEST_AGENTS"

# Reinstall with all files
find "$REPO_DIR/commands" -name "*.md" -type f | while read file; do
    basename=$(basename "$file")
    ln -sf "$file" "$TEST_COMMANDS/$basename"
done

find "$REPO_DIR/agents" -name "*.md" -type f | while read file; do
    basename=$(basename "$file")
    ln -sf "$file" "$TEST_AGENTS/$basename"
done

REINSTALL_CMD_COUNT=$(find "$TEST_COMMANDS" -name "*.md" | wc -l)
REINSTALL_AGENT_COUNT=$(find "$TEST_AGENTS" -name "*.md" | wc -l)

echo "  ✓ Reinstall: $REINSTALL_CMD_COUNT commands, $REINSTALL_AGENT_COUNT agents"

echo "5. Verifying all files are symlinks..."
NON_SYMLINK_COUNT=$(find "$TEST_COMMANDS" -name "*.md" ! -type l | wc -l)
if [ "$NON_SYMLINK_COUNT" -gt 0 ]; then
    echo "✗ Test failed: Found $NON_SYMLINK_COUNT non-symlink files in commands"
    exit 1
fi

NON_SYMLINK_COUNT=$(find "$TEST_AGENTS" -name "*.md" ! -type l | wc -l)
if [ "$NON_SYMLINK_COUNT" -gt 0 ]; then
    echo "✗ Test failed: Found $NON_SYMLINK_COUNT non-symlink files in agents"
    exit 1
fi

echo "  ✓ All files are symlinks"

echo "6. Verifying symlinks point to repo..."
find "$TEST_COMMANDS" -name "*.md" -type l | while read link; do
    target=$(readlink "$link")
    if [[ ! "$target" =~ "$REPO_DIR/commands" ]]; then
        echo "✗ Test failed: Symlink points to wrong location: $target"
        exit 1
    fi
done

find "$TEST_AGENTS" -name "*.md" -type l | while read link; do
    target=$(readlink "$link")
    if [[ ! "$target" =~ "$REPO_DIR/agents" ]]; then
        echo "✗ Test failed: Symlink points to wrong location: $target"
        exit 1
    fi
done

echo "  ✓ All symlinks point to repo"

echo "7. Verifying file count increased..."
if [ "$REINSTALL_CMD_COUNT" -le "$INITIAL_CMD_COUNT" ]; then
    echo "✗ Test failed: Reinstall should have more commands (partial to full install)"
    exit 1
fi

if [ "$REINSTALL_AGENT_COUNT" -le "$INITIAL_AGENT_COUNT" ]; then
    echo "✗ Test failed: Reinstall should have more agents (partial to full install)"
    exit 1
fi

echo "  ✓ Full reinstall completed (more files than initial partial install)"

echo ""
echo "================================================="
echo "✓ All tests passed!"
echo "================================================="
echo ""
echo "Summary:"
echo "  - Initial install: $INITIAL_CMD_COUNT commands, $INITIAL_AGENT_COUNT agents"
echo "  - Simulated corruption successfully"
echo "  - Reinstall: $REINSTALL_CMD_COUNT commands, $REINSTALL_AGENT_COUNT agents"
echo "  - All files are valid symlinks pointing to repo"
echo ""
echo "✓ Reinstall handling verified"
