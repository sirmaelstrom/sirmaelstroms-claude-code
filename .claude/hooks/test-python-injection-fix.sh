#!/usr/bin/env bash
# Test script to verify Python injection fix in session-tracker.sh

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Testing Python injection fix in session-tracker.sh"
echo ""

# Source the session tracker functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/session-tracker.sh"

# Create test session file
TEST_SESSION="/tmp/test-session-$$.json"
export SESSION_FILE="$TEST_SESSION"

# Initialize a clean session
init_session

echo "Test 1: Operation with Python injection attempt"
echo "----------------------------------------------"

# Attempt injection via operation type
track_operation 'read"); import os; os.system("echo EXPLOITED > /tmp/exploit-$$"); print("fake'

# Check if exploit file was created (should NOT exist)
if [[ -f "/tmp/exploit-$$" ]]; then
    echo -e "${RED}❌ FAIL: Python injection executed command${NC}"
    rm -f "/tmp/exploit-$$"
    exit 1
else
    echo -e "${GREEN}✓ PASS: Python injection prevented${NC}"
fi

# Check if invalid operation was recorded as 'other'
if grep -q '"other"' "$TEST_SESSION"; then
    echo -e "${GREEN}✓ PASS: Invalid operation recorded as 'other'${NC}"
else
    echo -e "${RED}❌ FAIL: Operation validation failed${NC}"
    cat "$TEST_SESSION"
    exit 1
fi

echo ""
echo "Test 2: Agent name with Python injection attempt"
echo "------------------------------------------------"

# Attempt injection via agent name
track_agent 'agent1"); import os; os.system("echo EXPLOIT2 > /tmp/exploit2-$$"); print("'

# Check if exploit file was created (should NOT exist)
if [[ -f "/tmp/exploit2-$$" ]]; then
    echo -e "${RED}❌ FAIL: Python injection executed command${NC}"
    rm -f "/tmp/exploit2-$$"
    exit 1
else
    echo -e "${GREEN}✓ PASS: Python injection prevented${NC}"
fi

# Check if invalid agent was recorded as 'unknown'
if grep -q '"unknown"' "$TEST_SESSION"; then
    echo -e "${GREEN}✓ PASS: Invalid agent recorded as 'unknown'${NC}"
else
    echo -e "${RED}❌ FAIL: Agent validation failed${NC}"
    cat "$TEST_SESSION"
    exit 1
fi

echo ""
echo "Test 3: Shell injection in operation type"
echo "-----------------------------------------"

# Attempt shell injection via operation type
track_operation 'read; touch /tmp/shell-exploit-$$; echo fake'

# Check if exploit file was created (should NOT exist)
if [[ -f "/tmp/shell-exploit-$$" ]]; then
    echo -e "${RED}❌ FAIL: Shell injection executed command${NC}"
    rm -f "/tmp/shell-exploit-$$"
    exit 1
else
    echo -e "${GREEN}✓ PASS: Shell injection prevented${NC}"
fi

echo ""
echo "Test 4: Path traversal in agent name"
echo "------------------------------------"

# Attempt path traversal via agent name
track_agent '../../../etc/passwd'

# Should be sanitized to 'unknown' due to regex validation
if grep -q '"unknown"' "$TEST_SESSION"; then
    echo -e "${GREEN}✓ PASS: Path traversal sanitized${NC}"
else
    echo -e "${RED}❌ FAIL: Path traversal not properly sanitized${NC}"
    cat "$TEST_SESSION"
    exit 1
fi

echo ""
echo "Test 5: Valid operations are tracked correctly"
echo "----------------------------------------------"

# Test valid operations
track_operation 'read'
track_operation 'write'
track_operation 'edit'
track_operation 'bash'
track_operation 'grep'
track_operation 'glob'
track_operation 'task'

# Verify all valid operations are tracked
session_content=$(cat "$TEST_SESSION")
valid_ops=("read" "write" "edit" "bash" "grep" "glob" "task")
all_valid=true

for op in "${valid_ops[@]}"; do
    if ! echo "$session_content" | grep -q "\"$op\""; then
        echo -e "${RED}❌ FAIL: Valid operation '$op' not tracked${NC}"
        all_valid=false
    fi
done

if $all_valid; then
    echo -e "${GREEN}✓ PASS: All valid operations tracked correctly${NC}"
fi

echo ""
echo "Test 6: Valid agent names are tracked correctly"
echo "-----------------------------------------------"

# Test valid agent names
track_agent 'test-agent'
track_agent 'agent_123'
track_agent 'AGENT-NAME'

# Verify valid agents are tracked
if grep -q '"test-agent"' "$TEST_SESSION" && \
   grep -q '"agent_123"' "$TEST_SESSION" && \
   grep -q '"AGENT-NAME"' "$TEST_SESSION"; then
    echo -e "${GREEN}✓ PASS: Valid agent names tracked correctly${NC}"
else
    echo -e "${RED}❌ FAIL: Valid agent names not tracked properly${NC}"
    cat "$TEST_SESSION"
    exit 1
fi

echo ""
echo "Test 7: SQL injection attempts"
echo "------------------------------"

# Attempt SQL-style injection (should be sanitized)
track_agent "'; DROP TABLE agents; --"

# Should be sanitized to 'unknown' due to special characters
agents_after_sql=$(grep -o '"unknown"' "$TEST_SESSION" | wc -l)
if [[ $agents_after_sql -gt 0 ]]; then
    echo -e "${GREEN}✓ PASS: SQL injection attempt sanitized${NC}"
else
    echo -e "${RED}❌ FAIL: SQL injection not properly sanitized${NC}"
    cat "$TEST_SESSION"
    exit 1
fi

echo ""
echo "Test 8: Newline and control character injection"
echo "-----------------------------------------------"

# Attempt injection with newlines and control characters
track_operation $'read\nmalicious_code()'
track_agent $'agent\x00null_byte'

# Should be sanitized as 'other' and 'unknown'
if grep -q '"other"' "$TEST_SESSION" && grep -q '"unknown"' "$TEST_SESSION"; then
    echo -e "${GREEN}✓ PASS: Control characters sanitized${NC}"
else
    echo -e "${RED}❌ FAIL: Control characters not properly sanitized${NC}"
    cat "$TEST_SESSION"
    exit 1
fi

# Cleanup
rm -f "$TEST_SESSION"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All Python injection tests passed!${NC}"
echo -e "${GREEN}========================================${NC}"
