#!/usr/bin/env bash
# test-hook-configuration.sh
# Verify that all 4 Claude Code hooks are properly configured

set -e

echo "Testing hook configuration in ~/.claude/settings.json"
echo ""

SETTINGS_FILE="$HOME/.claude/settings.json"

# Verify file exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "❌ FAIL: settings.json not found at $SETTINGS_FILE"
    exit 1
fi

# Verify it's valid JSON
if ! python3 -c "import json; json.load(open('$SETTINGS_FILE'))" > /dev/null 2>&1; then
    echo "❌ FAIL: settings.json is not valid JSON"
    exit 1
fi

echo "✓ settings.json exists and is valid JSON"
echo ""

# Verify all 4 hooks are configured
REQUIRED_HOOKS=("SessionStart" "Stop" "SessionEnd" "PermissionRequest")
HOOK_SCRIPT="claude-notify.sh"

PASS_COUNT=0
FAIL_COUNT=0

for hook in "${REQUIRED_HOOKS[@]}"; do
    # Extract the command for this hook
    CONFIGURED_COMMAND=$(python3 -c "
import json
settings = json.load(open('$SETTINGS_FILE'))
hooks = settings.get('hooks', {}).get('$hook', [])
if hooks and len(hooks) > 0:
    hook_list = hooks[0].get('hooks', [])
    if hook_list and len(hook_list) > 0:
        print(hook_list[0].get('command', ''))
" 2>/dev/null || echo "")

    if [[ -n "$CONFIGURED_COMMAND" ]]; then
        # Check if command contains claude-notify.sh
        if [[ "$CONFIGURED_COMMAND" == *"$HOOK_SCRIPT"* ]]; then
            echo "✓ PASS: $hook hook configured correctly"
            echo "  Command: $CONFIGURED_COMMAND"
            ((PASS_COUNT++))
        else
            echo "⚠️  WARN: $hook hook exists but doesn't use $HOOK_SCRIPT"
            echo "  Command: $CONFIGURED_COMMAND"
            ((PASS_COUNT++))
        fi
    else
        echo "❌ FAIL: $hook hook not configured"
        ((FAIL_COUNT++))
    fi
done

echo ""
echo "Results: $PASS_COUNT passed, $FAIL_COUNT failed"

if [ $FAIL_COUNT -eq 0 ]; then
    echo ""
    echo "✓ All 4 hooks configured correctly!"
    exit 0
else
    echo ""
    echo "❌ Some hooks are missing. Run install.sh to configure them."
    exit 1
fi
