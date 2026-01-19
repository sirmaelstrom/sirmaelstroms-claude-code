#!/usr/bin/env bash
# test-obsolete-hook-cleanup.sh

set -euo pipefail

echo "Testing obsolete hook cleanup..."

# Create a fake obsolete hook
mkdir -p ~/.claude/hooks
touch ~/.claude/hooks/discord-notify.sh
echo "#!/bin/bash" > ~/.claude/hooks/discord-notify.sh
chmod +x ~/.claude/hooks/discord-notify.sh

# Verify it exists
if [ -f ~/.claude/hooks/discord-notify.sh ]; then
    echo "✓ Setup: Created obsolete hook for testing"
else
    echo "❌ Setup failed: Could not create test hook"
    exit 1
fi

# Run install script (simulate cleanup section)
# Extract just the cleanup logic and test it
bash -c '
OBSOLETE_HOOKS=(
    "discord-notify.sh"
)

CLEANED=0
for hook in "${OBSOLETE_HOOKS[@]}"; do
    if [ -f ~/.claude/hooks/"$hook" ]; then
        echo "  Removing obsolete hook: $hook"
        rm ~/.claude/hooks/"$hook"
        CLEANED=$((CLEANED + 1))
    fi
done

echo "Removed $CLEANED obsolete hook(s)"
'

# Verify it was removed
if [ ! -f ~/.claude/hooks/discord-notify.sh ]; then
    echo "✓ PASS: Obsolete hook was removed"
else
    echo "❌ FAIL: Obsolete hook still exists"
    exit 1
fi

# Test that running cleanup again doesn't error
bash -c '
OBSOLETE_HOOKS=(
    "discord-notify.sh"
)

CLEANED=0
for hook in "${OBSOLETE_HOOKS[@]}"; do
    if [ -f ~/.claude/hooks/"$hook" ]; then
        rm ~/.claude/hooks/"$hook"
        CLEANED=$((CLEANED + 1))
    fi
done

if [ $CLEANED -eq 0 ]; then
    echo "No obsolete hooks found (expected)"
fi
'

echo ""
echo "Obsolete hook cleanup test passed!"
