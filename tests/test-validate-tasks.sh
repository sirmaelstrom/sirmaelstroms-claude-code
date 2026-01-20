#!/bin/bash
# Test suite for validate-tasks.sh
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script locations
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATE_SCRIPT="${SCRIPT_DIR}/../scripts/validate-tasks.sh"

# Test state
TEST_DIR=""
ORIG_DIR=""
TESTS_PASSED=0
TESTS_FAILED=0

# Setup test environment
setup_test_env() {
    ORIG_DIR=$(pwd)
    TEST_DIR=$(mktemp -d /tmp/tasks-validation-test-XXXXX)
    cd "$TEST_DIR" || exit 1
}

# Teardown test environment
teardown_test_env() {
    # Return to original directory first
    if [[ -n "$ORIG_DIR" ]]; then
        cd "$ORIG_DIR" || cd /tmp
    fi

    # Then remove test directory
    if [[ -n "$TEST_DIR" ]] && [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Test result helper
assert_exit_code() {
    local expected=$1
    local actual=$2
    local test_name=$3

    if [[ $actual -eq $expected ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name (expected exit $expected, got $actual)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Test 1: Valid setup (happy path)
test_valid_setup() {
    setup_test_env

    # Create valid TASKS.md
    echo "# Tasks" > TASKS.md

    # Create valid TODO.md files
    mkdir -p project1 project2
    echo "# TODO" > project1/TODO.md
    echo "# TODO" > project2/TODO.md

    # Run validation (temporarily disable exit on error)
    set +e
    OUTPUT=$("$VALIDATE_SCRIPT" --working-dir "$TEST_DIR" 2>&1)
    EXIT_CODE=$?
    set -e

    teardown_test_env
    assert_exit_code 0 $EXIT_CODE "test_valid_setup"
}

# Test 2: TASKS.md missing (critical error)
test_tasks_md_missing() {
    setup_test_env

    # Don't create TASKS.md
    mkdir -p project1
    echo "# TODO" > project1/TODO.md

    # Run validation (temporarily disable exit on error)
    set +e
    OUTPUT=$("$VALIDATE_SCRIPT" --working-dir "$TEST_DIR" 2>&1)
    EXIT_CODE=$?
    set -e

    teardown_test_env
    assert_exit_code 2 $EXIT_CODE "test_tasks_md_missing"
}

# Test 3: TASKS.md is symlink (critical error)
test_tasks_md_symlink() {
    setup_test_env

    # Create target and symlink
    echo "# Tasks" > tasks-real.md
    ln -s tasks-real.md TASKS.md

    # Run validation (temporarily disable exit on error)
    set +e
    OUTPUT=$("$VALIDATE_SCRIPT" --working-dir "$TEST_DIR" 2>&1)
    EXIT_CODE=$?
    set -e

    teardown_test_env
    assert_exit_code 2 $EXIT_CODE "test_tasks_md_symlink"
}

# Test 4: TASKS.md not writable (critical error)
test_tasks_md_not_writable() {
    setup_test_env

    # Create TASKS.md and make it read-only
    echo "# Tasks" > TASKS.md
    chmod 444 TASKS.md

    # Run validation (temporarily disable exit on error)
    set +e
    OUTPUT=$("$VALIDATE_SCRIPT" --working-dir "$TEST_DIR" 2>&1)
    EXIT_CODE=$?
    set -e

    # Restore permissions for cleanup
    chmod 644 TASKS.md

    teardown_test_env
    assert_exit_code 2 $EXIT_CODE "test_tasks_md_not_writable"
}

# Test 5: TODO.md symlink rejected (warning)
test_todo_symlink_rejected() {
    setup_test_env

    # Create valid TASKS.md
    echo "# Tasks" > TASKS.md

    # Create TODO.md symlink
    mkdir -p project1
    echo "# TODO" > todo-real.md
    ln -s ../todo-real.md project1/TODO.md

    # Run validation (temporarily disable exit on error)
    set +e
    OUTPUT=$("$VALIDATE_SCRIPT" --working-dir "$TEST_DIR" 2>&1)
    EXIT_CODE=$?
    set -e

    teardown_test_env
    # Exit 1 because file was rejected (warning, not critical)
    assert_exit_code 1 $EXIT_CODE "test_todo_symlink_rejected"
}

# Test 6: TODO.md oversized rejected (warning)
test_todo_oversized_rejected() {
    setup_test_env

    # Create valid TASKS.md
    echo "# Tasks" > TASKS.md

    # Create oversized TODO.md (>100KB)
    mkdir -p project1
    dd if=/dev/zero of=project1/TODO.md bs=1024 count=101 2>/dev/null

    # Run validation (temporarily disable exit on error)
    set +e
    OUTPUT=$("$VALIDATE_SCRIPT" --working-dir "$TEST_DIR" 2>&1)
    EXIT_CODE=$?
    set -e

    teardown_test_env
    # Exit 1 because file was rejected (warning)
    assert_exit_code 1 $EXIT_CODE "test_todo_oversized_rejected"
}

# Test 7: TODO.md outside workspace (warning)
test_todo_outside_workspace() {
    setup_test_env

    # Create valid TASKS.md
    echo "# Tasks" > TASKS.md

    # Create TODO.md outside workspace
    mkdir -p /tmp/outside-workspace-test
    echo "# TODO" > /tmp/outside-workspace-test/TODO.md

    # Create symlink pointing outside (this should be caught)
    mkdir -p project1
    ln -s /tmp/outside-workspace-test/TODO.md project1/TODO.md

    # Run validation (temporarily disable exit on error)
    set +e
    OUTPUT=$("$VALIDATE_SCRIPT" --working-dir "$TEST_DIR" 2>&1)
    EXIT_CODE=$?
    set -e

    # Cleanup outside directory
    rm -rf /tmp/outside-workspace-test

    teardown_test_env
    # Exit 1 because symlink was rejected
    assert_exit_code 1 $EXIT_CODE "test_todo_outside_workspace"
}

# Test 8: Multiple files, some valid, some rejected (mixed)
test_multiple_files_validated() {
    setup_test_env

    # Create valid TASKS.md
    echo "# Tasks" > TASKS.md

    # Create mix of valid and invalid TODO.md files
    mkdir -p project1 project2 project3
    echo "# TODO" > project1/TODO.md  # Valid
    echo "# TODO" > project2/TODO.md  # Valid

    # Create symlink for project3 (invalid)
    echo "# TODO" > todo-real.md
    ln -s ../todo-real.md project3/TODO.md

    # Run validation (temporarily disable exit on error)
    set +e
    OUTPUT=$("$VALIDATE_SCRIPT" --working-dir "$TEST_DIR" 2>&1)
    EXIT_CODE=$?
    set -e

    teardown_test_env
    # Exit 1 because some files were rejected
    assert_exit_code 1 $EXIT_CODE "test_multiple_files_validated"
}

# Test 9: Total size limit (5MB)
test_size_limits() {
    setup_test_env

    # Create valid TASKS.md
    echo "# Tasks" > TASKS.md

    # Create multiple TODO.md files that exceed 5MB total
    # Each file 1MB, create 6 of them
    for i in {1..6}; do
        mkdir -p "project$i"
        dd if=/dev/zero of="project$i/TODO.md" bs=1024 count=1024 2>/dev/null
    done

    # Run validation (temporarily disable exit on error)
    set +e
    OUTPUT=$("$VALIDATE_SCRIPT" --working-dir "$TEST_DIR" 2>&1)
    EXIT_CODE=$?
    set -e

    teardown_test_env
    # Exit 1 because size limit exceeded (warning)
    assert_exit_code 1 $EXIT_CODE "test_size_limits"
}

# Test 10: JSON output format validation
test_json_output_format() {
    setup_test_env

    # Create valid TASKS.md
    echo "# Tasks" > TASKS.md

    # Create valid TODO.md
    mkdir -p project1
    echo "# TODO" > project1/TODO.md

    # Run validation and check JSON
    OUTPUT=$("$VALIDATE_SCRIPT" --working-dir "$TEST_DIR" 2>&1)
    EXIT_CODE=$?

    # Check if jq is available for JSON validation
    if command -v jq &>/dev/null; then
        if echo "$OUTPUT" | jq . >/dev/null 2>&1; then
            teardown_test_env
            assert_exit_code 0 $EXIT_CODE "test_json_output_format"
        else
            echo -e "${RED}✗${NC} test_json_output_format (invalid JSON output)"
            ((TESTS_FAILED++))
            teardown_test_env
            return 1
        fi
    else
        echo -e "${YELLOW}⊘${NC} test_json_output_format (jq not available, skipping)"
        teardown_test_env
        return 0
    fi
}

# Run all tests
run_all_tests() {
    echo "Running validate-tasks.sh tests..."
    echo ""

    # Check if validate script exists
    if [[ ! -f "$VALIDATE_SCRIPT" ]]; then
        echo -e "${RED}ERROR: validate-tasks.sh not found at $VALIDATE_SCRIPT${NC}"
        echo "Tests cannot run until the script is implemented."
        exit 1
    fi

    # Make sure it's executable
    if [[ ! -x "$VALIDATE_SCRIPT" ]]; then
        echo -e "${YELLOW}WARNING: validate-tasks.sh not executable, attempting to fix...${NC}"
        chmod +x "$VALIDATE_SCRIPT"
    fi

    # Run each test
    test_valid_setup
    test_tasks_md_missing
    test_tasks_md_symlink
    test_tasks_md_not_writable
    test_todo_symlink_rejected
    test_todo_oversized_rejected
    test_todo_outside_workspace
    test_multiple_files_validated
    test_size_limits
    test_json_output_format

    # Summary
    echo ""
    echo "================================"
    TOTAL=$((TESTS_PASSED + TESTS_FAILED))
    echo "Tests passed: $TESTS_PASSED/$TOTAL"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}$TESTS_FAILED test(s) failed${NC}"
        exit 1
    fi
}

# Run tests
run_all_tests
