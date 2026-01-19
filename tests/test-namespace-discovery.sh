#!/bin/bash
set -e

echo "Testing: Namespace discovery for commands and agents"
echo "======================================================="
echo ""

# Setup
TEST_NAMESPACE="test-plugin-$$"
TEST_DIR="$HOME/.claude/commands/$TEST_NAMESPACE"
AGENT_DIR="$HOME/.claude/agents/$TEST_NAMESPACE"
TEMP_FILE=$(mktemp)

# Cleanup function
cleanup() {
    rm -rf "$TEST_DIR" "$AGENT_DIR" "$TEMP_FILE"
}
trap cleanup EXIT

echo "1. Creating test namespace directories..."
mkdir -p "$TEST_DIR"
mkdir -p "$AGENT_DIR"

echo "2. Creating test command file..."
cat > "$TEST_DIR/test-command.md" <<'EOF'
---
name: test-command
description: "Test command for namespace discovery"
---

# Test Command

This is a test command to verify namespace discovery works correctly.
EOF

echo "3. Creating test agent file..."
cat > "$AGENT_DIR/test-agent.md" <<'EOF'
---
name: test-agent
description: "Test agent for namespace discovery"
model: sonnet
color: blue
---

# Test Agent

This is a test agent to verify namespace discovery works correctly.
EOF

echo "4. Verifying files were created..."
if [ ! -f "$TEST_DIR/test-command.md" ]; then
    echo "✗ Test failed: Command file not created"
    exit 1
fi

if [ ! -f "$AGENT_DIR/test-agent.md" ]; then
    echo "✗ Test failed: Agent file not created"
    exit 1
fi

echo "✓ Files created successfully"

echo ""
echo "5. Checking file structure..."
ls -la "$TEST_DIR/" | tee "$TEMP_FILE"
if ! grep -q "test-command.md" "$TEMP_FILE"; then
    echo "✗ Test failed: Command file not found in listing"
    exit 1
fi

ls -la "$AGENT_DIR/" | tee "$TEMP_FILE"
if ! grep -q "test-agent.md" "$TEMP_FILE"; then
    echo "✗ Test failed: Agent file not found in listing"
    exit 1
fi

echo "✓ File structure correct"

echo ""
echo "======================================================="
echo "MANUAL VERIFICATION REQUIRED:"
echo "======================================================="
echo ""
echo "The test files have been created at:"
echo "  Command: $TEST_DIR/test-command.md"
echo "  Agent: $AGENT_DIR/test-agent.md"
echo ""
echo "To complete this test, verify in a Claude Code session:"
echo "  1. Type '/test-command' and verify Claude recognizes it"
echo "  2. Type 'use the test-agent' and verify Claude activates it"
echo "  3. If namespace prefix required, try:"
echo "     - /$TEST_NAMESPACE:test-command"
echo "     - use $TEST_NAMESPACE:test-agent"
echo ""
echo "Files will be automatically cleaned up when you press Enter."
read -p "Press Enter to cleanup test files..."

echo ""
echo "✓ Automated portion of test passed"
echo "✓ Manual verification steps documented above"
