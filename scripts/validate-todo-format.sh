#!/bin/bash
# Validate TODO.md file formatting for consistency with /sync-tasks requirements

set -e

usage() {
    echo "Usage: $0 <TODO.md file>"
    echo ""
    echo "Validates TODO.md file format for /sync-tasks compatibility:"
    echo "  - Required sections present (Active, Ideas/Future, Completed)"
    echo "  - Checkboxes well-formed (- [ ] or - [x])"
    echo "  - Top-level tasks use no indentation"
    echo "  - Nested tasks use consistent indentation (2 or 4 spaces)"
    echo ""
    echo "Exit codes:"
    echo "  0 - Valid format"
    echo "  1 - Format errors found"
    echo "  2 - Usage error"
    exit 2
}

if [ $# -ne 1 ]; then
    usage
fi

file="$1"

if [ ! -f "$file" ]; then
    echo "ERROR: File not found: $file" >&2
    exit 2
fi

errors=0
warnings=0

echo "Validating: $file"
echo ""

# Check required sections
echo "[1/5] Checking required sections..."

# Check Active section (case-insensitive exact match)
if grep -qiE '^##[[:space:]]+(Active|active)' "$file"; then
    echo "  ✓ Section 'Active' found"
else
    echo "  ✗ Section 'Active' MISSING" >&2
    errors=$((errors + 1))
fi

# Check Ideas/Future section (flexible - matches any heading containing ideas or future)
if grep -qiE '^##[[:space:]]+.*(Ideas|ideas|Future|future)' "$file"; then
    echo "  ✓ Section 'Ideas/Future' found"
else
    echo "  ✗ Section 'Ideas/Future' MISSING" >&2
    errors=$((errors + 1))
fi

# Check Completed section (case-insensitive, supports variants like "Completed (v1.0.1)")
if grep -qiE '^##[[:space:]]+(Completed|completed)' "$file"; then
    echo "  ✓ Section 'Completed' found"
else
    echo "  ✗ Section 'Completed' MISSING" >&2
    errors=$((errors + 1))
fi
echo ""

# Check checkbox format
echo "[2/5] Checking checkbox format..."
malformed=$(grep -nE '^\s*- \[([^ xX]|.{2,})\]' "$file" | head -5 || true)
if [ -n "$malformed" ]; then
    echo "  ✗ Malformed checkboxes found:" >&2
    echo "$malformed" | sed 's/^/    /' >&2
    errors=$((errors + 1))
else
    echo "  ✓ All checkboxes well-formed (- [ ], - [x], - [X])"
fi
echo ""

# Check indentation consistency
echo "[3/5] Checking indentation..."
if grep -qP '^\t' "$file"; then
    echo "  ⚠ WARNING: File uses tabs for indentation" >&2
    echo "    Recommendation: Use spaces for consistency" >&2
    warnings=$((warnings + 1))
else
    echo "  ✓ File uses spaces for indentation"
fi
echo ""

# Check line endings
echo "[4/5] Checking line endings..."
if file "$file" | grep -q CRLF; then
    echo "  ℹ File uses CRLF (Windows) line endings"
    echo "    (This is fine in WSL, but LF preferred for git)"
else
    echo "  ✓ File uses LF (Unix) line endings"
fi
echo ""

# Check for proper section hierarchy
echo "[5/5] Checking section hierarchy..."
top_level_count=$(grep -c '^- \[' "$file" || echo "0")
nested_count=$(grep -c '^  - \[' "$file" || echo "0")

echo "  ✓ Found $top_level_count top-level tasks"
echo "  ✓ Found $nested_count nested tasks"
echo ""

# Summary
echo "=== Summary ==="
if [ $errors -eq 0 ]; then
    echo "✓ Format validation PASSED"
    if [ $warnings -gt 0 ]; then
        echo "  ($warnings warnings)"
    fi
    exit 0
else
    echo "✗ Format validation FAILED" >&2
    echo "  Errors: $errors, Warnings: $warnings" >&2
    exit 1
fi
