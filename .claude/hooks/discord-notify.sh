#!/bin/bash

# Session state file
SESSION_FILE="/tmp/claude_session_$$.json"

# Read session state if available
if [ -f "$SESSION_FILE" ]; then
    SESSION_DATA=$(cat "$SESSION_FILE")
    START_TIME=$(echo "$SESSION_DATA" | python3 -c "import json, sys; print(json.load(sys.stdin).get('start_time', 0))")
    OPERATIONS=$(echo "$SESSION_DATA" | python3 -c "import json, sys; ops=json.load(sys.stdin)['operations']; print(f\"{ops['edit']} edits, {ops['read']} reads\")")
    AGENTS=$(echo "$SESSION_DATA" | python3 -c "import json, sys; print(', '.join(json.load(sys.stdin).get('agents', [])))")

    # Calculate duration
    if [ "$START_TIME" -gt 0 ]; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        DURATION_STR="$((DURATION / 60))m $((DURATION % 60))s"
    else
        DURATION_STR="Unknown"
    fi
else
    OPERATIONS="No data"
    AGENTS="None"
    DURATION_STR="Unknown"
fi

# Get project context
PROJECT=$(basename "$(pwd)")
FILES_CHANGED=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
LAST_COMMIT=$(git log -1 --oneline 2>/dev/null | cut -c 1-50)

# Determine color based on state
if [ "$FILES_CHANGED" -eq 0 ]; then
    COLOR=5763719  # Green - no changes
else
    COLOR=16776960  # Yellow - changes pending
fi

# Build embed
WEBHOOK_URL="${DISCORD_WEBHOOK_URL}"

curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "embeds": [{
    "title": "🤖 Claude Code Session Complete",
    "description": "Project: **$PROJECT**",
    "color": $COLOR,
    "fields": [
      {"name": "⏱️ Duration", "value": "$DURATION_STR", "inline": true},
      {"name": "🔧 Operations", "value": "$OPERATIONS", "inline": true},
      {"name": "📁 Files Modified", "value": "$FILES_CHANGED file(s)", "inline": true},
      {"name": "🤖 Agents", "value": "${AGENTS:-None}", "inline": false},
      {"name": "📝 Last Commit", "value": "${LAST_COMMIT:-No commits}", "inline": false}
    ],
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "footer": {"text": "Ready for next task"}
  }]
}
EOF

# Clean up session file
rm -f "$SESSION_FILE"
