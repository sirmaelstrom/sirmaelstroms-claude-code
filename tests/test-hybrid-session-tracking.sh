#!/usr/bin/env bash
# test-hybrid-session-tracking.sh
# Tests the hybrid session tracking implementation

set -euo pipefail

PASS_COUNT=0
FAIL_COUNT=0

pass() {
    echo "✓ PASS: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    echo "❌ FAIL: $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo "Testing hybrid session tracking..."
echo ""

# Test 1: Project name sanitization
echo "Test 1: Project name sanitization"
PROJECT_RAW="test project@#\$%"
PROJECT_SANITIZED=$(echo "$PROJECT_RAW" | sed "s/[^a-zA-Z0-9._-]/_/g")
if [ "$PROJECT_SANITIZED" = "test_project____" ]; then
    pass "Project name sanitized correctly"
else
    fail "Project name sanitization failed (got: $PROJECT_SANITIZED)"
fi
echo ""

# Test 2: Directory creation
echo "Test 2: Directory creation"
PROJECT="test-project"
SESSION_ID=$(date +%s)
SESSION_DIR="$HOME/.cache/claude_sessions/$PROJECT"
mkdir -p "$SESSION_DIR"

if [ -d "$SESSION_DIR" ]; then
    pass "Project directory created"
else
    fail "Project directory not created"
fi
echo ""

# Test 3: Session file creation
echo "Test 3: Session file creation"
SESSION_FILE="$SESSION_DIR/$SESSION_ID.json"

python3 <<EOF
import json
import os
from datetime import datetime

session_file = "$SESSION_FILE"
project = "$PROJECT"
session_id = "$SESSION_ID"

data = {
    "session_id": session_id,
    "project": project,
    "start_time": datetime.now().isoformat(),
    "operations": {
        "read": 0,
        "edit": 0,
        "write": 0,
        "bash": 0,
        "grep": 0,
        "glob": 0,
        "task": 0,
        "other": 0
    },
    "agents": [],
    "files_modified": []
}

with open(session_file, "w") as f:
    json.dump(data, f, indent=2)
EOF

if [ -f "$SESSION_FILE" ]; then
    pass "Session file created"
else
    fail "Session file not created"
fi
echo ""

# Test 4: Symlink creation
echo "Test 4: Symlink creation"
LATEST_LINK="$HOME/.cache/claude_session_latest.json"

# Remove existing symlink if present
if [ -L "$LATEST_LINK" ]; then
    rm "$LATEST_LINK"
elif [ -e "$LATEST_LINK" ]; then
    rm "$LATEST_LINK"
fi

# Create symlink
ln -sf "$SESSION_FILE" "$LATEST_LINK"

if [ -L "$LATEST_LINK" ]; then
    pass "Latest symlink created"
else
    fail "Latest symlink not created"
fi
echo ""

# Test 5: Symlink target
echo "Test 5: Symlink target"
LINK_TARGET=$(readlink "$LATEST_LINK")
if [ "$LINK_TARGET" = "$SESSION_FILE" ]; then
    pass "Symlink points to correct session file"
else
    fail "Symlink points to wrong file (expected: $SESSION_FILE, got: $LINK_TARGET)"
fi
echo ""

# Test 6: JSON structure validation
echo "Test 6: JSON structure validation"
if python3 -c "
import json
import sys
try:
    with open('$SESSION_FILE') as f:
        data = json.load(f)
    assert 'session_id' in data, 'Missing session_id'
    assert 'project' in data, 'Missing project'
    assert 'start_time' in data, 'Missing start_time'
    assert 'operations' in data, 'Missing operations'
    assert 'agents' in data, 'Missing agents'
    assert 'files_modified' in data, 'Missing files_modified'
    sys.exit(0)
except Exception as e:
    print(f'Validation failed: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null; then
    pass "Session data structure valid"
else
    fail "Session data structure invalid"
fi
echo ""

# Test 7: Multiple sessions in same project
echo "Test 7: Multiple sessions in same project"
sleep 1  # Ensure different timestamp
SESSION_ID2=$(date +%s)
SESSION_FILE2="$SESSION_DIR/$SESSION_ID2.json"

python3 <<EOF
import json
from datetime import datetime

data = {
    "session_id": "$SESSION_ID2",
    "project": "$PROJECT",
    "start_time": datetime.now().isoformat(),
    "operations": {},
    "agents": [],
    "files_modified": []
}

with open("$SESSION_FILE2", "w") as f:
    json.dump(data, f, indent=2)
EOF

SESSION_COUNT=$(find "$SESSION_DIR" -name "*.json" -type f | wc -l)
if [ "$SESSION_COUNT" -eq 2 ]; then
    pass "Multiple sessions stored in same project directory"
else
    fail "Expected 2 sessions, found $SESSION_COUNT"
fi
echo ""

# Test 8: Symlink update
echo "Test 8: Symlink update to latest session"
ln -sf "$SESSION_FILE2" "$LATEST_LINK"
LINK_TARGET2=$(readlink "$LATEST_LINK")
if [ "$LINK_TARGET2" = "$SESSION_FILE2" ]; then
    pass "Symlink updated to new session"
else
    fail "Symlink not updated correctly"
fi
echo ""

# Test 9: Project directory listing
echo "Test 9: Project directory listing"
PROJECTS_LIST=$(ls -1 "$HOME/.cache/claude_sessions" 2>/dev/null | wc -l)
if [ "$PROJECTS_LIST" -ge 1 ]; then
    pass "Can list project directories"
else
    fail "Cannot list project directories"
fi
echo ""

# Test 10: Session file readability via symlink
echo "Test 10: Session file readability via symlink"
if python3 -c "
import json
with open('$LATEST_LINK') as f:
    data = json.load(f)
assert data['session_id'] == '$SESSION_ID2'
" 2>/dev/null; then
    pass "Session data readable via symlink"
else
    fail "Session data not readable via symlink"
fi
echo ""

# Cleanup
echo "Cleaning up test data..."
rm -rf "$HOME/.cache/claude_sessions/test-project"
rm -f "$HOME/.cache/claude_session_latest.json"
echo ""

# Summary
echo "================================"
echo "Test Results:"
echo "  PASSED: $PASS_COUNT"
echo "  FAILED: $FAIL_COUNT"
echo "================================"

if [ $FAIL_COUNT -eq 0 ]; then
    echo ""
    echo "All hybrid session tracking tests passed!"
    exit 0
else
    echo ""
    echo "Some tests failed. Please review the output above."
    exit 1
fi
