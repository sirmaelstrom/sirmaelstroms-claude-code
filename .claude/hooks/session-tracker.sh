#!/bin/bash
# Session state tracking functions
#
# NOTE: These functions are currently UNUSED because Claude Code does not provide
# per-tool hooks (no PostToolUse event). They are ready for future use when/if
# Claude Code adds support for per-tool hook events.
#
# Current status (v1.1.0):
# - Session initialization works (via SessionStart hook)
# - Operation/agent tracking awaits PostToolUse hook support

# Ensure cache directory exists
mkdir -p "$HOME/.cache"

SESSION_FILE="${SESSION_FILE:-$HOME/.cache/claude_session_latest.json}"

# Track operation
track_operation() {
    local op_type="$1"

    # Increment operation counter
    # Pass via environment to avoid Python injection
    OP_TYPE="$op_type" SESSION_FILE="$SESSION_FILE" python3 <<'EOF'
import json
import os

session_file = os.environ.get('SESSION_FILE', '')
op_type = os.environ.get('OP_TYPE', 'unknown')

# Validate operation type (allowlist)
valid_ops = ['read', 'write', 'edit', 'bash', 'grep', 'glob', 'task']
if op_type not in valid_ops:
    op_type = 'other'

# Read, update, write
try:
    with open(session_file, 'r') as f:
        data = json.load(f)

    data['operations'][op_type] = data['operations'].get(op_type, 0) + 1

    with open(session_file, 'w') as f:
        json.dump(data, f)
except Exception:
    pass  # Silently fail if session file is inaccessible
EOF
}

# Track agent usage
track_agent() {
    local agent_name="$1"

    # Pass via environment to avoid Python injection
    AGENT_NAME="$agent_name" SESSION_FILE="$SESSION_FILE" python3 <<'EOF'
import json
import os
import re

session_file = os.environ.get('SESSION_FILE', '')
agent_name = os.environ.get('AGENT_NAME', 'unknown')

# Validate agent name (alphanumeric, hyphens, underscores only)
if not re.match(r'^[a-zA-Z0-9_-]+$', agent_name):
    agent_name = 'unknown'

# Read, update, write
try:
    with open(session_file, 'r') as f:
        data = json.load(f)

    if agent_name not in data['agents']:
        data['agents'].append(agent_name)

    with open(session_file, 'w') as f:
        json.dump(data, f)
except Exception:
    pass  # Silently fail if session file is inaccessible
EOF
}

# Export functions
export -f track_operation track_agent
