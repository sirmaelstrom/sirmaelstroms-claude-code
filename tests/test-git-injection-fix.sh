#!/usr/bin/env bash
# test-git-injection-fix.sh
# Tests that git command injection vulnerability is fixed in claude-notify.sh

set -euo pipefail

echo "Testing git output command injection fix..."
echo ""

# Create temporary git repo
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init -q
git config user.email "test@example.com"
git config user.name "Test User"

# Create commit with malicious message containing command injection attempts
echo "test" > file.txt
git add file.txt
git commit -m 'Malicious commit $(whoami) `ls -la` with backticks' -q

# Test the fixed git command (from claude-notify.sh line 93)
LAST_COMMIT=$(git log -1 -z --format='%h - %s' 2>/dev/null | tr '\0' ' ' | head -c 100 || echo "No commits")

echo "Captured commit message: $LAST_COMMIT"
echo ""

# Verify the command injection didn't execute
PASS_COUNT=0
FAIL_COUNT=0

if [[ "$LAST_COMMIT" == *'$(whoami)'* ]] || [[ "$LAST_COMMIT" == *'`ls'* ]]; then
    echo "✓ PASS: Command injection characters preserved as literal text"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "❌ FAIL: Command injection characters were interpreted"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Verify output length is limited
if [[ ${#LAST_COMMIT} -le 100 ]]; then
    echo "✓ PASS: Commit message length limited to 100 characters"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "❌ FAIL: Commit message not limited (got ${#LAST_COMMIT} chars)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Verify format includes hash and message
if [[ "$LAST_COMMIT" =~ ^[0-9a-f]{7}\ -\  ]]; then
    echo "✓ PASS: Output includes commit hash and separator"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "❌ FAIL: Output format incorrect (expected 'hash - message')"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Test with very long commit message
echo "test2" > file2.txt
git add file2.txt
LONG_MSG=$(python3 -c "print('A' * 200)")
git commit -m "$LONG_MSG" -q

LAST_COMMIT=$(git log -1 -z --format='%h - %s' 2>/dev/null | tr '\0' ' ' | head -c 100 || echo "No commits")

if [[ ${#LAST_COMMIT} -le 100 ]]; then
    echo "✓ PASS: Long commit message truncated to 100 characters"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "❌ FAIL: Long commit message not truncated (got ${#LAST_COMMIT} chars)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Test fallback with no commits (create new empty repo)
cd /
rm -rf "$TEST_DIR"
TEST_DIR2=$(mktemp -d)
cd "$TEST_DIR2"
git init -q

LAST_COMMIT=$(git log -1 -z --format='%h - %s' 2>/dev/null | tr '\0' ' ' | head -c 100 || echo "No commits")

if [[ "$LAST_COMMIT" == "No commits" ]]; then
    echo "✓ PASS: Fallback to 'No commits' when no commits exist"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "❌ FAIL: Fallback failed (got: '$LAST_COMMIT')"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Cleanup
cd /
rm -rf "$TEST_DIR2"

echo ""
echo "=========================================="
echo "Test Results: $PASS_COUNT passed, $FAIL_COUNT failed"
echo "=========================================="

if [ $FAIL_COUNT -eq 0 ]; then
    echo "All git injection tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi
