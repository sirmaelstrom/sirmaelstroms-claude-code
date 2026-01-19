#!/usr/bin/env bash
# test-session-tracker-operations.sh

set -euo pipefail

# Create test session file matching SessionStart hook structure
SESSION_FILE="/tmp/test-session-$$.json"
cat > "$SESSION_FILE" <<'EOF'
{
  "session_id": "1234567890",
  "project": "test-project",
  "start_time": "2026-01-18T10:00:00",
  "operations": {
    "read": 0,
    "write": 0,
    "edit": 0,
    "bash": 0,
    "grep": 0,
    "glob": 0,
    "task": 0,
    "other": 0
  },
  "agents": [],
  "files_modified": []
}
EOF

# Source the track_operation function
SESSION_FILE="$SESSION_FILE" bash -c '
source .claude/hooks/session-tracker.sh
track_operation read
track_operation read
track_operation write
'

# Verify operations are counters
READ_COUNT=$(python3 -c "import json; print(json.load(open('$SESSION_FILE'))['operations']['read'])")
WRITE_COUNT=$(python3 -c "import json; print(json.load(open('$SESSION_FILE'))['operations']['write'])")

if [ "$READ_COUNT" = "2" ] && [ "$WRITE_COUNT" = "1" ]; then
    echo "✓ PASS: Operations tracked as counters"
else
    echo "❌ FAIL: Operations not tracked correctly (read=$READ_COUNT, write=$WRITE_COUNT)"
    rm "$SESSION_FILE"
    exit 1
fi

# Cleanup
rm "$SESSION_FILE"

echo "Session tracker operations test passed!"
