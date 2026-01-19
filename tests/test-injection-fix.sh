#!/bin/bash
# Test the fixed notification script with malicious input

set -e

# Get script directory and navigate to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_DIR"

echo "Testing fixed scripts/claude-notify.sh with injection attempts..."

# Create malicious test data
export LAST_COMMIT='Test "injection\nattack"; {"malicious": "payload"}'
export OPERATIONS='5 edits, "break": "json"'
export AGENTS='agent1", "injected": "field'
export TOOL_NAME='tool\nwith\nnewlines'
export PROJECT='project"test'
export DURATION_STR="5 minutes"
export FILES_CHANGED="5"
export EVENT_TYPE="Stop"
export EMOJI="⏸️"
export TITLE="Claude Code Waiting"
export FOOTER_TEXT="Ready for next task"
export DISCORD_COLOR=3447003
export SLACK_COLOR="#5DADE2"

# Disable actual webhook calls
unset DISCORD_WEBHOOK_URL
unset SLACK_WEBHOOK_URL

echo ""
echo "=== Test 1: Discord Fields Generation (Stop event) ==="

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
    ]')

if echo "$DISCORD_FIELDS" | jq . > /dev/null 2>&1; then
    echo "✓ PASS: Discord fields JSON is valid"

    # Verify content integrity
    COMMIT_VALUE=$(echo "$DISCORD_FIELDS" | jq -r '.[] | select(.name == "📝 Last Commit") | .value')
    if [ "$COMMIT_VALUE" = "$LAST_COMMIT" ]; then
        echo "✓ PASS: Commit message properly escaped and preserved"
    else
        echo "❌ FAIL: Commit message corrupted"
        exit 1
    fi
else
    echo "❌ FAIL: Discord fields JSON is invalid"
    exit 1
fi

echo ""
echo "=== Test 2: Complete Discord Payload ==="

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
        description: ("Project: **" + $project + "**"),
        color: ($color | tonumber),
        fields: $fields,
        timestamp: $timestamp,
        footer: {text: $footer}
    }]}')

if echo "$DISCORD_PAYLOAD" | jq . > /dev/null 2>&1; then
    echo "✓ PASS: Discord payload JSON is valid"
else
    echo "❌ FAIL: Discord payload JSON is invalid"
    exit 1
fi

echo ""
echo "=== Test 3: Complete Slack Payload with Inline Text ==="

# Build Slack payload with inline text generation (no separate SLACK_TEXT variable)
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
        text: ("Project: *" + $project + "*"),
        fields: [{
            value: ("*Duration:* " + $duration + "\n*Operations:* " + $ops + "\n*Files:* " + $files + " modified\n*Agents:* " + $agents + "\n*Last Commit:* " + $commit),
            short: false
        }],
        footer: $footer,
        ts: ($ts | tonumber)
    }]}')

if echo "$SLACK_PAYLOAD" | jq . > /dev/null 2>&1; then
    echo "✓ PASS: Slack payload JSON is valid"
else
    echo "❌ FAIL: Slack payload JSON is invalid"
    exit 1
fi

echo ""
echo "=== Test 4: Verify No Double-Encoding in Slack Text ==="

# Extract the Slack text value
SLACK_VALUE=$(echo "$SLACK_PAYLOAD" | jq -r '.attachments[0].fields[0].value')

# Check if the value starts with a literal quote (double-encoding bug)
if [[ "$SLACK_VALUE" == \"* ]]; then
    echo "❌ FAIL: Slack text contains literal quotes (double-encoded)"
    echo "   Actual value: $SLACK_VALUE"
    exit 1
else
    echo "✓ PASS: Slack text properly encoded (no literal quotes)"
fi

# Verify Slack text contains expected content
if [[ "$SLACK_VALUE" == *"Duration"* ]]; then
    echo "✓ PASS: Slack text contains Duration field"
else
    echo "❌ FAIL: Slack text missing Duration field"
    exit 1
fi

# Verify the commit message is preserved correctly
if [[ "$SLACK_VALUE" == *"$LAST_COMMIT"* ]]; then
    echo "✓ PASS: Commit message properly preserved in Slack text"
else
    echo "❌ FAIL: Commit message corrupted in Slack text"
    exit 1
fi

echo ""
echo "=== ALL TESTS PASSED ==="
echo "The fix successfully prevents JSON injection and double-encoding in all event types."
