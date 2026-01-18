#!/bin/bash
# Session state tracking for Discord notifications

SESSION_FILE="/tmp/claude_session_$$.json"

# Initialize session
init_session() {
    cat > "$SESSION_FILE" <<EOF
{
  "start_time": $(date +%s),
  "project": "$(basename "$(pwd)")",
  "operations": {
    "read": 0,
    "edit": 0,
    "write": 0,
    "bash": 0
  },
  "agents": [],
  "tests": null,
  "builds": null,
  "commits": []
}
EOF
}

# Track operation
track_operation() {
    local op_type="$1"

    if [ ! -f "$SESSION_FILE" ]; then
        init_session
    fi

    # Increment operation counter
    python3 -c "
import json, sys
with open('$SESSION_FILE', 'r') as f:
    data = json.load(f)
data['operations']['$op_type'] = data['operations'].get('$op_type', 0) + 1
with open('$SESSION_FILE', 'w') as f:
    json.dump(data, f)
"
}

# Track agent usage
track_agent() {
    local agent_name="$1"

    if [ ! -f "$SESSION_FILE" ]; then
        init_session
    fi

    python3 -c "
import json
with open('$SESSION_FILE', 'r') as f:
    data = json.load(f)
if '$agent_name' not in data['agents']:
    data['agents'].append('$agent_name')
with open('$SESSION_FILE', 'w') as f:
    json.dump(data, f)
"
}

# Export functions
export -f init_session track_operation track_agent
