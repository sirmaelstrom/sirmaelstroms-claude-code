#!/bin/bash
# Discord webhook notification for Claude Code with rich embeds

# Configuration - set your Discord webhook URL here
DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-}"

# Exit early if no webhook configured
[ -z "$DISCORD_WEBHOOK_URL" ] && exit 0

# Get basic context
PROJECT_NAME=$(basename "$PWD")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_START=${CLAUDE_SESSION_START:-$(date +%s)}
CURRENT_TIME=$(date +%s)
DURATION=$((CURRENT_TIME - SESSION_START))
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

# Gather session context
gather_context() {
    local files_modified="N/A"
    local git_status=""
    local test_status="N/A"
    local build_status="N/A"
    local color=5763719  # Default: blue (0x57F287 would be green)

    # Check git status for modified files
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local modified_count=$(git status --short 2>/dev/null | wc -l)
        if [ "$modified_count" -gt 0 ]; then
            files_modified="$modified_count file(s)"
            color=16776960  # Yellow (0xFEE75C)
        else
            files_modified="No changes"
            color=5763719   # Green (0x57F287)
        fi

        # Check for recent commits (last 5 minutes)
        local recent_commits=$(git log --since="5 minutes ago" --oneline 2>/dev/null | wc -l)
        if [ "$recent_commits" -gt 0 ]; then
            git_status=$(git log -1 --pretty=format:"%s" 2>/dev/null | head -c 50)
            [ ${#git_status} -gt 50 ] && git_status="${git_status}..."
        fi
    fi

    # Check for recent test results (look for dotnet test output in /tmp or session logs)
    if [ -f "/tmp/claude_last_test.log" ]; then
        if grep -q "Failed.*0" /tmp/claude_last_test.log 2>/dev/null; then
            local passed=$(grep -oP "Passed.*\K\d+" /tmp/claude_last_test.log 2>/dev/null | head -1)
            test_status="${passed:-0} passed"
            color=5763719  # Green
        else
            test_status="Some failures"
            color=15548997  # Red (0xED4245)
        fi
    fi

    # Output gathered context as JSON-friendly format
    echo "$files_modified|$git_status|$test_status|$build_status|$color"
}

# Build Discord embed JSON
build_embed() {
    local context=$(gather_context)
    IFS='|' read -r files_modified git_status test_status build_status color <<< "$context"

    # Build fields array
    local fields='['
    fields+="{\"name\":\"📁 Files Modified\",\"value\":\"$files_modified\",\"inline\":true}"

    if [ "$DURATION_MIN" -gt 0 ]; then
        fields+=",{\"name\":\"⏱️ Duration\",\"value\":\"${DURATION_MIN}m ${DURATION_SEC}s\",\"inline\":true}"
    fi

    if [ -n "$git_status" ]; then
        fields+=",{\"name\":\"📝 Last Commit\",\"value\":\"$git_status\",\"inline\":false}"
    fi

    if [ "$test_status" != "N/A" ]; then
        fields+=",{\"name\":\"✅ Tests\",\"value\":\"$test_status\",\"inline\":true}"
    fi

    fields+=']'

    # Build complete embed
    cat <<EOF
{
  "embeds": [{
    "title": "🤖 Claude Code Session Ready",
    "description": "Project: **$PROJECT_NAME**",
    "color": $color,
    "fields": $fields,
    "timestamp": "$TIMESTAMP",
    "footer": {
      "text": "Ready for next task"
    }
  }]
}
EOF
}

# Send notification
if command -v jq >/dev/null 2>&1; then
    # Use jq for reliable JSON formatting
    build_embed | jq -c . | \
    curl -s -X POST "$DISCORD_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d @- > /dev/null 2>&1
else
    # Send without jq (embed already formatted)
    curl -s -X POST "$DISCORD_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$(build_embed)" > /dev/null 2>&1
fi

# Always exit successfully to not block Claude
exit 0
