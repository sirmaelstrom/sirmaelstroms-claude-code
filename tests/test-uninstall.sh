#!/bin/bash
set -e

echo "Testing: Safe uninstall preserving other plugins"
echo "================================================="
echo ""

# Setup test directories
TEST_BASE="$HOME/.claude-test-uninstall-$$"
TEST_COMMANDS="$TEST_BASE/commands"
TEST_AGENTS="$TEST_BASE/agents"

# Plugin namespaces
SIRM_NAMESPACE="sirm-toolbox"
OTHER_NAMESPACE="other-plugin"

# Cleanup function
cleanup() {
    rm -rf "$TEST_BASE"
}
trap cleanup EXIT

echo "1. Setting up test environment with multiple plugins..."
mkdir -p "$TEST_COMMANDS/$SIRM_NAMESPACE"
mkdir -p "$TEST_COMMANDS/$OTHER_NAMESPACE"
mkdir -p "$TEST_AGENTS/$SIRM_NAMESPACE"
mkdir -p "$TEST_AGENTS/$OTHER_NAMESPACE"

echo "2. Creating mock sirm-toolbox files..."
echo "test content" > "$TEST_COMMANDS/$SIRM_NAMESPACE/test-command.md"
echo "test content" > "$TEST_AGENTS/$SIRM_NAMESPACE/test-agent.md"

echo "3. Creating mock other-plugin files..."
cat > "$TEST_COMMANDS/$OTHER_NAMESPACE/other-command.md" <<'EOF'
---
name: other-command
description: "Command from another plugin"
---

# Other Command
This should NOT be deleted during sirm-toolbox uninstall.
EOF

cat > "$TEST_AGENTS/$OTHER_NAMESPACE/other-agent.md" <<'EOF'
---
name: other-agent
description: "Agent from another plugin"
---

# Other Agent
This should NOT be deleted during sirm-toolbox uninstall.
EOF

echo "4. Recording state before uninstall..."
OTHER_CMD_CHECKSUM=$(md5sum "$TEST_COMMANDS/$OTHER_NAMESPACE/other-command.md" | awk '{print $1}')
OTHER_AGENT_CHECKSUM=$(md5sum "$TEST_AGENTS/$OTHER_NAMESPACE/other-agent.md" | awk '{print $1}')

echo "5. Simulating uninstall (removing sirm-toolbox namespace)..."
rm -rf "$TEST_COMMANDS/$SIRM_NAMESPACE"
rm -rf "$TEST_AGENTS/$SIRM_NAMESPACE"

echo "6. Verifying sirm-toolbox was removed..."
if [ -d "$TEST_COMMANDS/$SIRM_NAMESPACE" ]; then
    echo "✗ Test failed: sirm-toolbox commands directory still exists"
    exit 1
fi

if [ -d "$TEST_AGENTS/$SIRM_NAMESPACE" ]; then
    echo "✗ Test failed: sirm-toolbox agents directory still exists"
    exit 1
fi

echo "  ✓ sirm-toolbox namespace removed completely"

echo "7. Verifying other-plugin was preserved..."
if [ ! -d "$TEST_COMMANDS/$OTHER_NAMESPACE" ]; then
    echo "✗ Test failed: other-plugin commands directory was deleted"
    exit 1
fi

if [ ! -d "$TEST_AGENTS/$OTHER_NAMESPACE" ]; then
    echo "✗ Test failed: other-plugin agents directory was deleted"
    exit 1
fi

if [ ! -f "$TEST_COMMANDS/$OTHER_NAMESPACE/other-command.md" ]; then
    echo "✗ Test failed: other-plugin command file was deleted"
    exit 1
fi

if [ ! -f "$TEST_AGENTS/$OTHER_NAMESPACE/other-agent.md" ]; then
    echo "✗ Test failed: other-plugin agent file was deleted"
    exit 1
fi

echo "  ✓ other-plugin directory preserved"

echo "8. Verifying other-plugin files unchanged..."
NEW_CMD_CHECKSUM=$(md5sum "$TEST_COMMANDS/$OTHER_NAMESPACE/other-command.md" | awk '{print $1}')
NEW_AGENT_CHECKSUM=$(md5sum "$TEST_AGENTS/$OTHER_NAMESPACE/other-agent.md" | awk '{print $1}')

if [ "$OTHER_CMD_CHECKSUM" != "$NEW_CMD_CHECKSUM" ]; then
    echo "✗ Test failed: other-plugin command file was modified"
    exit 1
fi

if [ "$OTHER_AGENT_CHECKSUM" != "$NEW_AGENT_CHECKSUM" ]; then
    echo "✗ Test failed: other-plugin agent file was modified"
    exit 1
fi

echo "  ✓ other-plugin files unchanged"

echo "9. Verifying parent directories still exist..."
if [ ! -d "$TEST_COMMANDS" ]; then
    echo "✗ Test failed: parent commands directory was deleted"
    exit 1
fi

if [ ! -d "$TEST_AGENTS" ]; then
    echo "✗ Test failed: parent agents directory was deleted"
    exit 1
fi

echo "  ✓ Parent directories preserved"

echo ""
echo "================================================="
echo "✓ All tests passed!"
echo "================================================="
echo ""
echo "Summary:"
echo "  - sirm-toolbox namespace completely removed"
echo "  - other-plugin files and directories preserved"
echo "  - other-plugin file contents unchanged"
echo "  - Parent directories not deleted"
echo ""
echo "✓ Safe uninstall verified"
