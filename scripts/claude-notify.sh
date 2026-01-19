#!/bin/bash

# Unified notification script for Claude Code hooks (Discord + Slack)
# Usage: claude-notify.sh [event_type]
# event_type: "Stop" (default), "SessionStart", "SessionEnd", or "PermissionRequest"
#
# Environment variables:
#   DISCORD_WEBHOOK_URL - Discord webhook URL (optional)
#   SLACK_WEBHOOK_URL   - Slack webhook URL (optional)
#   NOTIFY_DISCORD      - Enable Discord notifications (default: true if webhook set)
#   NOTIFY_SLACK        - Enable Slack notifications (default: true if webhook set)
#   At least one webhook must be set and enabled

EVENT_TYPE="${1:-Stop}"

# Ensure cache directory exists
mkdir -p "$HOME/.cache"

SESSION_FILE="$HOME/.cache/claude_session_latest.json"
DEBUG_LOG="$HOME/.cache/claude_hook_debug.log"

# Platform enable/disable (default: true if webhook is set)
NOTIFY_DISCORD="${NOTIFY_DISCORD:-true}"
NOTIFY_SLACK="${NOTIFY_SLACK:-true}"

# Debug: Log environment variables (first event only, to avoid log spam)
if [ ! -f "$HOME/.cache/claude_hook_env_logged" ]; then
    echo "=== HOOK ENVIRONMENT DEBUG ($(date -u +%Y-%m-%dT%H:%M:%SZ)) ===" >> "$DEBUG_LOG"
    echo "DISCORD_WEBHOOK_URL: ${DISCORD_WEBHOOK_URL:+SET (${#DISCORD_WEBHOOK_URL} chars)}${DISCORD_WEBHOOK_URL:-UNSET}" >> "$DEBUG_LOG"
    echo "SLACK_WEBHOOK_URL: ${SLACK_WEBHOOK_URL:+SET (${#SLACK_WEBHOOK_URL} chars)}${SLACK_WEBHOOK_URL:-UNSET}" >> "$DEBUG_LOG"
    echo "NOTIFY_DISCORD: $NOTIFY_DISCORD" >> "$DEBUG_LOG"
    echo "NOTIFY_SLACK: $NOTIFY_SLACK" >> "$DEBUG_LOG"
    touch "$HOME/.cache/claude_hook_env_logged"
fi

# Validate webhook URLs if set
if [[ -n "$DISCORD_WEBHOOK_URL" ]] && [[ ! "$DISCORD_WEBHOOK_URL" =~ ^https://discord\.com/api/webhooks/ ]]; then
    echo "Error: Invalid Discord webhook URL format" >&2
    exit 1
fi

if [[ -n "$SLACK_WEBHOOK_URL" ]] && [[ ! "$SLACK_WEBHOOK_URL" =~ ^https://hooks\.slack\.com/services/ ]]; then
    echo "Error: Invalid Slack webhook URL format" >&2
    exit 1
fi

# Read hook input from stdin if available
if [ ! -t 0 ]; then
    HOOK_INPUT=$(cat)

    # Log the input for debugging
    echo "=== $(date -u +%Y-%m-%dT%H:%M:%SZ) ===" >> "$DEBUG_LOG"
    echo "EVENT_TYPE: $EVENT_TYPE" >> "$DEBUG_LOG"
    echo "HOOK_INPUT: $HOOK_INPUT" >> "$DEBUG_LOG"

    # Extract reason (for SessionEnd), source (for SessionStart), and cwd (for all)
    EXIT_REASON=$(echo "$HOOK_INPUT" | python3 -c "import json, sys; data=json.load(sys.stdin); print(data.get('reason', 'unknown'))" 2>/dev/null || echo "unknown")
    SESSION_SOURCE=$(echo "$HOOK_INPUT" | python3 -c "import json, sys; data=json.load(sys.stdin); print(data.get('source', 'unknown'))" 2>/dev/null || echo "unknown")
    HOOK_CWD=$(echo "$HOOK_INPUT" | python3 -c "import json, sys; data=json.load(sys.stdin); print(data.get('cwd', ''))" 2>/dev/null || echo "")

    echo "EXIT_REASON: $EXIT_REASON" >> "$DEBUG_LOG"
    echo "SESSION_SOURCE: $SESSION_SOURCE" >> "$DEBUG_LOG"
    echo "HOOK_CWD: $HOOK_CWD" >> "$DEBUG_LOG"
else
    EXIT_REASON="unknown"
    SESSION_SOURCE="unknown"
    HOOK_CWD=""
    echo "=== $(date -u +%Y-%m-%dT%H:%M:%SZ) ===" >> "$DEBUG_LOG"
    echo "EVENT_TYPE: $EVENT_TYPE" >> "$DEBUG_LOG"
    echo "No stdin input received" >> "$DEBUG_LOG"
fi

# Determine project-specific session file if cwd is available
if [ -n "$HOOK_CWD" ]; then
    # Extract project name from cwd (same logic as init-session.sh)
    CURRENT_PROJECT=$(basename "$HOOK_CWD" | sed "s/[^a-zA-Z0-9._-]/_/g")

    # Validate project name
    if [ -z "$CURRENT_PROJECT" ] || [ "$CURRENT_PROJECT" = "." ] || [ "$CURRENT_PROJECT" = ".." ]; then
        CURRENT_PROJECT="unknown-project-$(date +%s)"
    fi

    PROJECT_SESSION_DIR="$HOME/.cache/claude_sessions/$CURRENT_PROJECT"

    # Find most recent session file for this project
    if [ -d "$PROJECT_SESSION_DIR" ]; then
        LATEST_SESSION=$(ls -t "$PROJECT_SESSION_DIR"/*.json 2>/dev/null | head -1)
        if [ -n "$LATEST_SESSION" ]; then
            SESSION_FILE="$LATEST_SESSION"
            echo "Using project-specific session: $SESSION_FILE" >> "$DEBUG_LOG"
        else
            echo "No session files found in $PROJECT_SESSION_DIR, creating new session" >> "$DEBUG_LOG"
            # Create new session file for this project
            mkdir -p "$PROJECT_SESSION_DIR"
            NEW_SESSION_ID=$(date +%s)
            SESSION_FILE="$PROJECT_SESSION_DIR/$NEW_SESSION_ID.json"
            python3 <<EOF
import json
from datetime import datetime

data = {
    "session_id": "$NEW_SESSION_ID",
    "project": "$CURRENT_PROJECT",
    "start_time": datetime.now().isoformat(),
    "operations": {"read": 0, "edit": 0, "write": 0, "bash": 0, "grep": 0, "glob": 0, "task": 0, "other": 0},
    "agents": [],
    "files_modified": []
}

with open("$SESSION_FILE", "w") as f:
    json.dump(data, f, indent=2)
EOF
            echo "Created new session file: $SESSION_FILE" >> "$DEBUG_LOG"
        fi
    else
        echo "Project session directory not found: $PROJECT_SESSION_DIR, creating" >> "$DEBUG_LOG"
        # Create directory and new session file
        mkdir -p "$PROJECT_SESSION_DIR"
        NEW_SESSION_ID=$(date +%s)
        SESSION_FILE="$PROJECT_SESSION_DIR/$NEW_SESSION_ID.json"
        python3 <<EOF
import json
from datetime import datetime

data = {
    "session_id": "$NEW_SESSION_ID",
    "project": "$CURRENT_PROJECT",
    "start_time": datetime.now().isoformat(),
    "operations": {"read": 0, "edit": 0, "write": 0, "bash": 0, "grep": 0, "glob": 0, "task": 0, "other": 0},
    "agents": [],
    "files_modified": []
}

with open("$SESSION_FILE", "w") as f:
    json.dump(data, f, indent=2)
EOF
        echo "Created new session file: $SESSION_FILE" >> "$DEBUG_LOG"
    fi
fi

# Read session state if available
if [ -f "$SESSION_FILE" ]; then
    echo "Session file exists: $SESSION_FILE" >> "$DEBUG_LOG"
    SESSION_DATA=$(cat "$SESSION_FILE")
    echo "Session data: $SESSION_DATA" >> "$DEBUG_LOG"

    START_TIME=$(echo "$SESSION_DATA" | python3 -c "import json, sys; from datetime import datetime; data=json.load(sys.stdin); start_time_str=data.get('start_time', ''); print(int(datetime.fromisoformat(start_time_str).timestamp()) if start_time_str else 0)")
    OPERATIONS=$(echo "$SESSION_DATA" | python3 -c "import json, sys; ops=json.load(sys.stdin)['operations']; print(f\"{ops['edit']} edits, {ops['read']} reads\")")
    AGENTS=$(echo "$SESSION_DATA" | python3 -c "import json, sys; print(', '.join(json.load(sys.stdin).get('agents', [])))")

    echo "START_TIME: $START_TIME" >> "$DEBUG_LOG"

    # Calculate duration
    if [ -n "$START_TIME" ] && [ "$START_TIME" -gt 0 ]; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        DURATION_STR="$((DURATION / 60))m $((DURATION % 60))s"
        echo "DURATION: $DURATION_STR" >> "$DEBUG_LOG"
    else
        DURATION_STR="Unknown"
        echo "DURATION: Unknown (START_TIME <= 0)" >> "$DEBUG_LOG"
    fi
else
    echo "Session file NOT found: $SESSION_FILE" >> "$DEBUG_LOG"
    OPERATIONS="No data"
    AGENTS="None"
    DURATION_STR="Unknown"
fi

# Get project context
PROJECT=$(basename "$(pwd)")
FILES_CHANGED=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
# Use -z for null-terminated output and safe format specifiers to prevent command injection
LAST_COMMIT=$(git log -1 -z --format='%h - %s' 2>/dev/null | tr '\0' ' ' | head -c 100 || echo "No commits")

# Configure message based on event type
case "$EVENT_TYPE" in
    "SessionEnd")
        # SessionEnd: Different colors based on exit reason
        case "$EXIT_REASON" in
            "prompt_input_exit"|"clear"|"logout"|"exit")
                DISCORD_COLOR=5763719  # Green - normal exit
                SLACK_COLOR="good"
                ;;
            *)
                DISCORD_COLOR=15548997  # Red - unexpected exit
                SLACK_COLOR="danger"
                ;;
        esac

        EMOJI="🏁"
        TITLE="Claude Code Session Ended"
        FOOTER_TEXT="Session ended: $EXIT_REASON"

        # Clean up session file on session end
        echo "Deleting session file" >> "$DEBUG_LOG"
        rm -f "$SESSION_FILE" 2>/dev/null
        ;;

    "SessionStart")
        # Different emoji/color based on source
        case "$SESSION_SOURCE" in
            "startup")
                DISCORD_COLOR=5763719  # Green - fresh start
                SLACK_COLOR="good"
                EMOJI="🚀"
                TITLE="Claude Code Session Started"
                FOOTER_TEXT="New session started"
                ;;
            "resume")
                DISCORD_COLOR=3447003  # Blue - resuming
                SLACK_COLOR="#5DADE2"
                EMOJI="🔄"
                TITLE="Claude Code Session Resumed"
                FOOTER_TEXT="Resuming previous session"
                ;;
            "clear")
                DISCORD_COLOR=16776960  # Yellow - cleared
                SLACK_COLOR="warning"
                EMOJI="🔄"
                TITLE="Claude Code Session Cleared"
                FOOTER_TEXT="Session cleared and restarted"
                ;;
            "compact")
                DISCORD_COLOR=16744192  # Orange - compacted
                SLACK_COLOR="#FF9800"
                EMOJI="🔄"
                TITLE="Claude Code Session Compacted"
                FOOTER_TEXT="Context compacted"
                ;;
            *)
                DISCORD_COLOR=5763719  # Green - default
                SLACK_COLOR="good"
                EMOJI="🚀"
                TITLE="Claude Code Session Started"
                FOOTER_TEXT="Session started"
                ;;
        esac
        DURATION_STR="Starting now"
        ;;

    "PermissionRequest")
        DISCORD_COLOR=16744192  # Orange - waiting for user action
        SLACK_COLOR="#FF9800"
        EMOJI="🔐"
        TITLE="Claude Code Awaiting Permission"
        FOOTER_TEXT="Waiting for permission"

        # Extract tool name from hook input if available
        TOOL_NAME=$(echo "$HOOK_INPUT" | python3 -c "import json, sys; data=json.load(sys.stdin); print(data.get('tool_name', 'Unknown tool'))" 2>/dev/null || echo "Unknown tool")
        echo "TOOL_NAME: $TOOL_NAME" >> "$DEBUG_LOG"
        ;;

    "Stop")
        # Stop: Color based on changes pending
        if [ "$FILES_CHANGED" -eq 0 ]; then
            DISCORD_COLOR=3447003  # Blue - idle, no changes
            SLACK_COLOR="#5DADE2"
        else
            DISCORD_COLOR=16776960  # Yellow - idle with changes pending
            SLACK_COLOR="warning"
        fi

        EMOJI="⏸️"
        TITLE="Claude Code Waiting"
        FOOTER_TEXT="Ready for next task"
        ;;

    *)
        DISCORD_COLOR=8421504  # Gray - unknown event
        SLACK_COLOR="#808080"
        EMOJI="❓"
        TITLE="Claude Code Event: $EVENT_TYPE"
        FOOTER_TEXT="Unknown event type"
        ;;
esac

# Send to Discord if webhook is configured and enabled
if [ -n "$DISCORD_WEBHOOK_URL" ] && [ "$NOTIFY_DISCORD" = "true" ]; then
    echo "Sending Discord notification" >> "$DEBUG_LOG"

    # Build fields based on event type using jq for safe JSON generation
    if [ "$EVENT_TYPE" = "PermissionRequest" ]; then
        DISCORD_FIELDS=$(jq -n \
            --arg tool "$TOOL_NAME" \
            --arg duration "$DURATION_STR" \
            --arg files "$FILES_CHANGED" \
            '[
                {name: "🔧 Tool Requested", value: $tool, inline: true},
                {name: "⏱️ Session Duration", value: $duration, inline: true},
                {name: "📁 Files Modified", value: ($files + " file(s)"), inline: true}
            ]') || {
            echo "ERROR: Failed to generate Discord fields for PermissionRequest" >&2
            echo "ERROR: Failed to generate Discord fields for PermissionRequest" >> "$DEBUG_LOG"
            exit 1
        }
    elif [ "$EVENT_TYPE" = "SessionStart" ]; then
        DISCORD_FIELDS=$(jq -n \
            --arg project "$PROJECT" \
            --arg files "$FILES_CHANGED" \
            '[
                {name: "📂 Project", value: $project, inline: true},
                {name: "📁 Git Status", value: ($files + " file(s) modified"), inline: true}
            ]') || {
            echo "ERROR: Failed to generate Discord fields for SessionStart" >&2
            echo "ERROR: Failed to generate Discord fields for SessionStart" >> "$DEBUG_LOG"
            exit 1
        }
    else
        DISCORD_FIELDS=$(jq -n \
            --arg duration "$DURATION_STR" \
            --arg ops "$OPERATIONS" \
            --arg files "$FILES_CHANGED" \
            --arg agents "${AGENTS:-None}" \
            --arg commit "${LAST_COMMIT:-No commits}" \
            '[
                {name: "⏱️ Duration", value: $duration, inline: true},
                {name: "🔧 Operations", value: $ops, inline: true},
                {name: "📁 Files Modified", value: ($files + " file(s)"), inline: true},
                {name: "🤖 Agents", value: $agents, inline: false},
                {name: "📝 Last Commit", value: $commit, inline: false}
            ]') || {
            echo "ERROR: Failed to generate Discord fields for Stop/SessionEnd" >&2
            echo "ERROR: Failed to generate Discord fields for Stop/SessionEnd" >> "$DEBUG_LOG"
            exit 1
        }
    fi

    # Build complete Discord payload with jq for safe JSON generation
    DISCORD_PAYLOAD=$(jq -n \
        --arg emoji "$EMOJI" \
        --arg title "$TITLE" \
        --arg project "$PROJECT" \
        --arg color "$DISCORD_COLOR" \
        --arg footer "$FOOTER_TEXT" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson fields "$DISCORD_FIELDS" \
        '{embeds: [{
            title: ($emoji + " " + $title),
            description: ("📁 Project: **`" + $project + "`**"),
            color: ($color | tonumber),
            fields: $fields,
            timestamp: $timestamp,
            footer: {text: $footer}
        }]}') || {
        echo "ERROR: Failed to generate Discord payload" >&2
        echo "ERROR: Failed to generate Discord payload" >> "$DEBUG_LOG"
        exit 1
    }

    curl -s -X POST "$DISCORD_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "$DISCORD_PAYLOAD"
fi

# Send to Slack if webhook is configured and enabled
if [ -n "$SLACK_WEBHOOK_URL" ] && [ "$NOTIFY_SLACK" = "true" ]; then
    echo "Sending Slack notification" >> "$DEBUG_LOG"

    # Build complete Slack payload with inline text generation for safe JSON generation
    if [ "$EVENT_TYPE" = "PermissionRequest" ]; then
        SLACK_PAYLOAD=$(jq -n \
            --arg color "$SLACK_COLOR" \
            --arg emoji "$EMOJI" \
            --arg title "$TITLE" \
            --arg project "$PROJECT" \
            --arg tool "$TOOL_NAME" \
            --arg duration "$DURATION_STR" \
            --arg files "$FILES_CHANGED" \
            --arg footer "$FOOTER_TEXT" \
            --arg ts "$(date +%s)" \
            '{attachments: [{
                color: $color,
                title: ($emoji + " " + $title),
                text: ("📁 Project: *`" + $project + "`*"),
                fields: [{
                    value: ("*Tool:* " + $tool + "\n*Duration:* " + $duration + "\n*Files:* " + $files + " modified"),
                    short: false
                }],
                footer: $footer,
                ts: ($ts | tonumber)
            }]}') || {
            echo "ERROR: Failed to generate Slack payload for PermissionRequest" >&2
            echo "ERROR: Failed to generate Slack payload for PermissionRequest" >> "$DEBUG_LOG"
            exit 1
        }
    elif [ "$EVENT_TYPE" = "SessionStart" ]; then
        SLACK_PAYLOAD=$(jq -n \
            --arg color "$SLACK_COLOR" \
            --arg emoji "$EMOJI" \
            --arg title "$TITLE" \
            --arg project "$PROJECT" \
            --arg files "$FILES_CHANGED" \
            --arg footer "$FOOTER_TEXT" \
            --arg ts "$(date +%s)" \
            '{attachments: [{
                color: $color,
                title: ($emoji + " " + $title),
                text: ("📁 Project: *`" + $project + "`*"),
                fields: [{
                    value: ("*Project:* " + $project + "\n*Status:* " + $files + " file(s) modified"),
                    short: false
                }],
                footer: $footer,
                ts: ($ts | tonumber)
            }]}') || {
            echo "ERROR: Failed to generate Slack payload for SessionStart" >&2
            echo "ERROR: Failed to generate Slack payload for SessionStart" >> "$DEBUG_LOG"
            exit 1
        }
    else
        SLACK_PAYLOAD=$(jq -n \
            --arg color "$SLACK_COLOR" \
            --arg emoji "$EMOJI" \
            --arg title "$TITLE" \
            --arg project "$PROJECT" \
            --arg duration "$DURATION_STR" \
            --arg ops "$OPERATIONS" \
            --arg files "$FILES_CHANGED" \
            --arg agents "${AGENTS:-None}" \
            --arg commit "${LAST_COMMIT:-No commits}" \
            --arg footer "$FOOTER_TEXT" \
            --arg ts "$(date +%s)" \
            '{attachments: [{
                color: $color,
                title: ($emoji + " " + $title),
                text: ("📁 Project: *`" + $project + "`*"),
                fields: [{
                    value: ("*Duration:* " + $duration + "\n*Operations:* " + $ops + "\n*Files:* " + $files + " modified\n*Agents:* " + $agents + "\n*Last Commit:* " + $commit),
                    short: false
                }],
                footer: $footer,
                ts: ($ts | tonumber)
            }]}') || {
            echo "ERROR: Failed to generate Slack payload for Stop/SessionEnd" >&2
            echo "ERROR: Failed to generate Slack payload for Stop/SessionEnd" >> "$DEBUG_LOG"
            exit 1
        }
    fi

    curl -s -X POST "$SLACK_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "$SLACK_PAYLOAD"
fi
