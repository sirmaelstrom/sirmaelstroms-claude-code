#!/usr/bin/env bash
# cleanup-old-sessions.sh
# Removes session files older than 30 days

set -euo pipefail

SESSIONS_DIR="$HOME/.cache/claude_sessions"
DAYS_OLD="${1:-30}"

if [ ! -d "$SESSIONS_DIR" ]; then
    echo "No sessions directory found at $SESSIONS_DIR"
    exit 0
fi

echo "Cleaning up sessions older than $DAYS_OLD days..."

DELETED=0
for project_dir in "$SESSIONS_DIR"/*; do
    if [ -d "$project_dir" ]; then
        PROJECT_NAME=$(basename "$project_dir")
        while IFS= read -r -d '' session_file; do
            rm "$session_file"
            DELETED=$((DELETED + 1))
        done < <(find "$project_dir" -name "*.json" -type f -mtime +"$DAYS_OLD" -print0 2>/dev/null) || true

        # Remove empty project directories
        if [ -z "$(ls -A "$project_dir")" ]; then
            rmdir "$project_dir"
            echo "  Removed empty project directory: $PROJECT_NAME"
        fi
    fi
done

if [ $DELETED -eq 0 ]; then
    echo "No sessions older than $DAYS_OLD days found"
else
    echo "Deleted $DELETED old session files"
fi
