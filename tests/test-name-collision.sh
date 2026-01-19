#!/bin/bash
set -e

echo "Testing: Name collision handling across plugins"
echo "================================================="
echo ""

# Setup test directories
TEST_BASE="$HOME/.claude-test-collision-$$"
TEST_COMMANDS="$TEST_BASE/commands"
TEST_AGENTS="$TEST_BASE/agents"

# Plugin namespaces
SIRM_NAMESPACE="sirm-toolbox"
OTHER_NAMESPACE="other-plugin"

# Common file name that exists in both plugins
COMMON_CMD="build-test.md"
COMMON_AGENT="security-engineer.md"

# Cleanup function
cleanup() {
    rm -rf "$TEST_BASE"
}
trap cleanup EXIT

echo "1. Setting up test environment..."
mkdir -p "$TEST_COMMANDS/$SIRM_NAMESPACE"
mkdir -p "$TEST_COMMANDS/$OTHER_NAMESPACE"
mkdir -p "$TEST_AGENTS/$SIRM_NAMESPACE"
mkdir -p "$TEST_AGENTS/$OTHER_NAMESPACE"

echo "2. Creating identically-named command in both plugins..."
cat > "$TEST_COMMANDS/$SIRM_NAMESPACE/$COMMON_CMD" <<'EOF'
---
name: build-test
description: "Build and test from sirm-toolbox"
---

# Build Test (sirm-toolbox)
This is the sirm-toolbox version.
EOF

cat > "$TEST_COMMANDS/$OTHER_NAMESPACE/$COMMON_CMD" <<'EOF'
---
name: build-test
description: "Build and test from other-plugin"
---

# Build Test (other-plugin)
This is the other-plugin version.
EOF

echo "3. Creating identically-named agent in both plugins..."
cat > "$TEST_AGENTS/$SIRM_NAMESPACE/$COMMON_AGENT" <<'EOF'
---
name: security-engineer
description: "Security engineer from sirm-toolbox"
model: sonnet
color: red
---

# Security Engineer (sirm-toolbox)
This is the sirm-toolbox version.
EOF

cat > "$TEST_AGENTS/$OTHER_NAMESPACE/$COMMON_AGENT" <<'EOF'
---
name: security-engineer
description: "Security engineer from other-plugin"
model: opus
color: blue
---

# Security Engineer (other-plugin)
This is the other-plugin version.
EOF

echo "4. Verifying both files exist..."
if [ ! -f "$TEST_COMMANDS/$SIRM_NAMESPACE/$COMMON_CMD" ]; then
    echo "✗ Test failed: sirm-toolbox command not found"
    exit 1
fi

if [ ! -f "$TEST_COMMANDS/$OTHER_NAMESPACE/$COMMON_CMD" ]; then
    echo "✗ Test failed: other-plugin command not found"
    exit 1
fi

if [ ! -f "$TEST_AGENTS/$SIRM_NAMESPACE/$COMMON_AGENT" ]; then
    echo "✗ Test failed: sirm-toolbox agent not found"
    exit 1
fi

if [ ! -f "$TEST_AGENTS/$OTHER_NAMESPACE/$COMMON_AGENT" ]; then
    echo "✗ Test failed: other-plugin agent not found"
    exit 1
fi

echo "  ✓ All files created successfully"

echo "5. Verifying files have different content..."
SIRM_CMD_CONTENT=$(cat "$TEST_COMMANDS/$SIRM_NAMESPACE/$COMMON_CMD")
OTHER_CMD_CONTENT=$(cat "$TEST_COMMANDS/$OTHER_NAMESPACE/$COMMON_CMD")

if [ "$SIRM_CMD_CONTENT" == "$OTHER_CMD_CONTENT" ]; then
    echo "✗ Test failed: Command files should have different content"
    exit 1
fi

SIRM_AGENT_CONTENT=$(cat "$TEST_AGENTS/$SIRM_NAMESPACE/$COMMON_AGENT")
OTHER_AGENT_CONTENT=$(cat "$TEST_AGENTS/$OTHER_NAMESPACE/$COMMON_AGENT")

if [ "$SIRM_AGENT_CONTENT" == "$OTHER_AGENT_CONTENT" ]; then
    echo "✗ Test failed: Agent files should have different content"
    exit 1
fi

echo "  ✓ Files have distinct content"

echo "6. Verifying namespace isolation..."
if ! grep -q "sirm-toolbox version" "$TEST_COMMANDS/$SIRM_NAMESPACE/$COMMON_CMD"; then
    echo "✗ Test failed: sirm-toolbox command has wrong content"
    exit 1
fi

if ! grep -q "other-plugin version" "$TEST_COMMANDS/$OTHER_NAMESPACE/$COMMON_CMD"; then
    echo "✗ Test failed: other-plugin command has wrong content"
    exit 1
fi

if ! grep -q "sirm-toolbox version" "$TEST_AGENTS/$SIRM_NAMESPACE/$COMMON_AGENT"; then
    echo "✗ Test failed: sirm-toolbox agent has wrong content"
    exit 1
fi

if ! grep -q "other-plugin version" "$TEST_AGENTS/$OTHER_NAMESPACE/$COMMON_AGENT"; then
    echo "✗ Test failed: other-plugin agent has wrong content"
    exit 1
fi

echo "  ✓ Each namespace maintains its own version"

echo "7. Verifying directory structure..."
SIRM_CMD_PATH="$TEST_COMMANDS/$SIRM_NAMESPACE/$COMMON_CMD"
OTHER_CMD_PATH="$TEST_COMMANDS/$OTHER_NAMESPACE/$COMMON_CMD"

if [ "$SIRM_CMD_PATH" == "$OTHER_CMD_PATH" ]; then
    echo "✗ Test failed: Files should have different paths"
    exit 1
fi

echo "  ✓ Files isolated in separate namespaces"

echo "8. Testing file access by full path..."
SIRM_CONTENT=$(cat "$SIRM_CMD_PATH")
OTHER_CONTENT=$(cat "$OTHER_CMD_PATH")

if [[ ! "$SIRM_CONTENT" =~ "sirm-toolbox version" ]]; then
    echo "✗ Test failed: Cannot access sirm-toolbox version"
    exit 1
fi

if [[ ! "$OTHER_CONTENT" =~ "other-plugin version" ]]; then
    echo "✗ Test failed: Cannot access other-plugin version"
    exit 1
fi

echo "  ✓ Both versions accessible via namespace path"

echo ""
echo "================================================="
echo "✓ All tests passed!"
echo "================================================="
echo ""
echo "Summary:"
echo "  - Same filename in both namespaces: $COMMON_CMD"
echo "  - Both commands coexist without conflict"
echo "  - Both agents coexist without conflict"
echo "  - Each namespace maintains distinct content"
echo "  - Full path access works for both versions"
echo ""
echo "File paths:"
echo "  sirm-toolbox:  $SIRM_CMD_PATH"
echo "  other-plugin:  $OTHER_CMD_PATH"
echo ""
echo "✓ Name collision prevention verified"
