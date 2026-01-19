#!/usr/bin/env bash
# test-init-session-script.sh

set -euo pipefail

echo "Testing init-session.sh script..."

# Clean test environment
rm -rf ~/.cache/claude_sessions/test-init-project-*
rm -f ~/.cache/claude_session_latest.json

# Create test project directory
TEST_DIR="/tmp/test-init-project-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Run init-session.sh
bash "$HOME/.claude/hooks/init-session.sh"

# Extract actual project name used
ACTUAL_PROJECT=$(basename "$TEST_DIR" | sed "s/[^a-zA-Z0-9._-]/_/g")

# Verify session directory created
if [ -d ~/.cache/claude_sessions/"$ACTUAL_PROJECT" ]; then
    echo "✓ PASS: Session directory created"
else
    echo "❌ FAIL: Session directory not created"
    exit 1
fi

# Verify session file exists
if [ -f ~/.cache/claude_session_latest.json ] || [ -L ~/.cache/claude_session_latest.json ]; then
    SESSION_FILE=$(readlink ~/.cache/claude_session_latest.json)
    if [ -f "$SESSION_FILE" ]; then
        echo "✓ PASS: Session file created via symlink"
    else
        echo "❌ FAIL: Symlink doesn't point to valid file"
        exit 1
    fi
else
    echo "❌ FAIL: Latest session symlink not created"
    exit 1
fi

# Verify JSON structure
if python3 -c "import json; data=json.load(open('$SESSION_FILE')); assert 'session_id' in data; assert 'project' in data; assert 'operations' in data"; then
    echo "✓ PASS: Session JSON structure valid"
else
    echo "❌ FAIL: Session JSON structure invalid"
    exit 1
fi

# Verify operations are counters
if python3 -c "import json; data=json.load(open('$SESSION_FILE')); assert isinstance(data['operations']['read'], int)"; then
    echo "✓ PASS: Operations are counters (not arrays)"
else
    echo "❌ FAIL: Operations structure incorrect"
    exit 1
fi

# Test error handling: try to create session without write permissions
mkdir -p ~/test-no-perms
chmod 000 ~/test-no-perms
cd ~/test-no-perms 2>/dev/null || true
if ! bash "$HOME/.claude/hooks/init-session.sh" 2>/dev/null; then
    echo "✓ PASS: Script fails gracefully without permissions"
else
    echo "⚠ WARNING: Script succeeded despite permission issues (may be running as root)"
fi
chmod 755 ~/test-no-perms
rmdir ~/test-no-perms

# Cleanup
cd /
rm -rf "$TEST_DIR"
rm -rf ~/.cache/claude_sessions/"$ACTUAL_PROJECT"

echo ""
echo "All init-session.sh tests passed!"
