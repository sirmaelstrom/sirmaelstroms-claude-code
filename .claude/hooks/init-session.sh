#!/usr/bin/env bash
# init-session.sh
# Initialize session tracking with hybrid design (per-project + session IDs)

set -euo pipefail

# Capture project and session ID
PROJECT=$(basename "$(pwd)" | sed "s/[^a-zA-Z0-9._-]/_/g")

# Validate project name isn't empty or special
if [ -z "$PROJECT" ] || [ "$PROJECT" = "." ] || [ "$PROJECT" = ".." ]; then
    PROJECT="unknown-project-$(date +%s)"
fi

SESSION_ID=$(date +%s)
SESSION_DIR="$HOME/.cache/claude_sessions/$PROJECT"
mkdir -p "$SESSION_DIR"
SESSION_FILE="$SESSION_DIR/$SESSION_ID.json"

# Export for Python
export PROJECT SESSION_ID SESSION_FILE

# Initialize session JSON with Python
python3 <<'EOF'
import json
import os
from datetime import datetime

session_file = os.environ["SESSION_FILE"]
project = os.environ["PROJECT"]
session_id = os.environ["SESSION_ID"]

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

# Create symlink to latest
latest = os.path.expanduser("~/.cache/claude_session_latest.json")

# Atomic symlink replacement
temp_link = latest + ".tmp." + str(os.getpid())
os.symlink(session_file, temp_link)
os.rename(temp_link, latest)
EOF

# Verify session file was created
if [ ! -f "$SESSION_FILE" ]; then
    echo "ERROR: Failed to create session file: $SESSION_FILE" >&2
    exit 1
fi
