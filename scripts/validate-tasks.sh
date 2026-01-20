#!/bin/bash
# validate-tasks.sh - Security validation for TASKS.md and TODO.md files
# Used by sync-tasks skill to validate file safety before processing
set -euo pipefail

# Constants
MAX_FILES=100
MAX_FILE_SIZE=102400      # 100KB per file
MAX_TOTAL_SIZE=5242880    # 5MB total

# Default working directory
WORKING_DIR="."

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --working-dir)
            WORKING_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--working-dir PATH]" >&2
            exit 2
            ;;
    esac
done

# Change to working directory
if [[ ! -d "$WORKING_DIR" ]]; then
    cat <<EOF
{
  "status": "critical_error",
  "tasks_md": {
    "exists": false,
    "is_symlink": false,
    "is_writable": false,
    "path": "$WORKING_DIR/TASKS.md"
  },
  "todo_files": {
    "discovered": 0,
    "validated": 0,
    "rejected": 0,
    "files": []
  },
  "errors": ["Working directory does not exist: $WORKING_DIR"],
  "warnings": [],
  "limits": {
    "max_files": $MAX_FILES,
    "max_file_size": $MAX_FILE_SIZE,
    "max_total_size": $MAX_TOTAL_SIZE,
    "total_size_processed": 0
  }
}
EOF
    exit 2
fi

cd "$WORKING_DIR" || exit 2

# Initialize result tracking
TASKS_MD_EXISTS=false
TASKS_MD_IS_SYMLINK=false
TASKS_MD_IS_WRITABLE=false
ERRORS=()
WARNINGS=()
TODO_FILES_DISCOVERED=0
TODO_FILES_VALIDATED=0
TODO_FILES_REJECTED=0
VALIDATED_FILES=()
REJECTED_FILES=()
TOTAL_SIZE=0
EXIT_CODE=0

# Validate TASKS.md
if [[ ! -f "TASKS.md" ]]; then
    ERRORS+=("TASKS.md not found in current directory")
    EXIT_CODE=2
else
    TASKS_MD_EXISTS=true

    if [[ -L "TASKS.md" ]]; then
        TASKS_MD_IS_SYMLINK=true
        ERRORS+=("SECURITY VIOLATION: TASKS.md is a symlink (not allowed)")
        EXIT_CODE=2
    fi

    # Verify TASKS.md is in current directory (no parent paths)
    if [[ "$(dirname "TASKS.md")" != "." ]]; then
        ERRORS+=("TASKS.md must be in current working directory")
        EXIT_CODE=2
    fi

    # Check if writable (only if it exists and is not a symlink)
    if [[ $TASKS_MD_IS_SYMLINK == false ]] && [[ -w "TASKS.md" ]]; then
        TASKS_MD_IS_WRITABLE=true
    else
        if [[ $TASKS_MD_IS_SYMLINK == false ]]; then
            ERRORS+=("TASKS.md is not writable")
            EXIT_CODE=2
        fi
    fi
fi

# Discover TODO.md files (if TASKS.md validation didn't fail critically)
if [[ $EXIT_CODE -ne 2 ]]; then
    # Find TODO.md files, excluding common non-project directories
    # Max depth 4 to avoid excessive recursion
    # Note: Don't use -type f as it skips symlinks; we want to discover and reject symlinks
    mapfile -t DISCOVERED_TODOS < <(find . -maxdepth 4 -name "TODO.md" \
        ! -path "*/.git/*" \
        ! -path "*/node_modules/*" \
        ! -path "*/vendor/*" \
        ! -path "*/packages/*" \
        ! -path "*/bin/*" \
        ! -path "*/obj/*" \
        ! -path "*/build/*" \
        ! -path "*/dist/*" \
        ! -path "*/target/*" \
        ! -path "*/archive/*" \
        ! -path "*/.archive/*" \
        2>/dev/null || true)

    TODO_FILES_DISCOVERED=${#DISCOVERED_TODOS[@]}

    # Validate each discovered TODO.md file
    for todo_file in "${DISCOVERED_TODOS[@]}"; do
        REJECT_REASON=""
        FILE_STATUS="valid"

        # SECURITY: Reject symlinks
        if [[ -L "$todo_file" ]]; then
            REJECT_REASON="symlink"
            FILE_STATUS="rejected"
            WARNINGS+=("Skipping $todo_file (symlink not allowed)")
            TODO_FILES_REJECTED=$((TODO_FILES_REJECTED + 1))
        fi

        # SECURITY: Verify it's a regular file
        if [[ -n "$REJECT_REASON" ]] || [[ ! -f "$todo_file" ]]; then
            if [[ -z "$REJECT_REASON" ]]; then
                REJECT_REASON="not_regular_file"
                FILE_STATUS="rejected"
                WARNINGS+=("Skipping $todo_file (not a regular file)")
                TODO_FILES_REJECTED=$((TODO_FILES_REJECTED + 1))
            fi
        fi

        # SECURITY: Verify file is within workspace
        if [[ -z "$REJECT_REASON" ]]; then
            realpath_file=$(realpath "$todo_file" 2>/dev/null || echo "")
            realpath_cwd=$(realpath "." 2>/dev/null || echo "")

            if [[ -z "$realpath_file" ]] || [[ -z "$realpath_cwd" ]]; then
                REJECT_REASON="path_resolution_failed"
                FILE_STATUS="rejected"
                WARNINGS+=("Skipping $todo_file (path resolution failed)")
                TODO_FILES_REJECTED=$((TODO_FILES_REJECTED + 1))
            elif [[ "$realpath_file" != "$realpath_cwd"/* ]]; then
                REJECT_REASON="outside_workspace"
                FILE_STATUS="rejected"
                WARNINGS+=("Skipping $todo_file (outside workspace)")
                TODO_FILES_REJECTED=$((TODO_FILES_REJECTED + 1))
            fi
        fi

        # SECURITY: Check file size
        if [[ -z "$REJECT_REASON" ]]; then
            if [[ "$(uname)" == "Darwin" ]]; then
                size=$(stat -f %z "$todo_file" 2>/dev/null || echo "")
            else
                size=$(stat -c %s "$todo_file" 2>/dev/null || echo "")
            fi

            if [[ -z "$size" ]] || [[ ! "$size" =~ ^[0-9]+$ ]]; then
                REJECT_REASON="size_unknown"
                FILE_STATUS="rejected"
                WARNINGS+=("Skipping $todo_file (cannot determine file size)")
                TODO_FILES_REJECTED=$((TODO_FILES_REJECTED + 1))
            elif (( size > MAX_FILE_SIZE )); then
                REJECT_REASON="too_large"
                FILE_STATUS="rejected"
                WARNINGS+=("Skipping $todo_file (>100KB, TODO.md should be small)")
                TODO_FILES_REJECTED=$((TODO_FILES_REJECTED + 1))
            else
                # Check total cumulative size
                new_total=$((TOTAL_SIZE + size))
                if (( new_total > MAX_TOTAL_SIZE )); then
                    REJECT_REASON="total_size_exceeded"
                    FILE_STATUS="rejected"
                    WARNINGS+=("Skipping $todo_file (total size would exceed 5MB limit)")
                    WARNINGS+=("Processing stopped at ${TODO_FILES_VALIDATED} validated files")
                    TODO_FILES_REJECTED=$((TODO_FILES_REJECTED + 1))
                    # Break out of loop, we've hit the limit
                    break
                else
                    TOTAL_SIZE=$new_total
                fi
            fi
        fi

        # Add to appropriate list
        if [[ "$FILE_STATUS" == "valid" ]]; then
            VALIDATED_FILES+=("$todo_file|$size|valid")
            TODO_FILES_VALIDATED=$((TODO_FILES_VALIDATED + 1))
        else
            REJECTED_FILES+=("$todo_file|$size|rejected|$REJECT_REASON")
        fi

        # Check if we've exceeded max file count
        if (( TODO_FILES_VALIDATED >= MAX_FILES )); then
            WARNINGS+=("Reached maximum file limit ($MAX_FILES files), stopping discovery")
            break
        fi
    done

    # Set exit code based on rejections
    if (( TODO_FILES_REJECTED > 0 )); then
        EXIT_CODE=1
    fi
fi

# Build JSON output
# Determine status string
if [ $EXIT_CODE -eq 0 ]; then
    STATUS_STR="success"
elif [ $EXIT_CODE -eq 1 ]; then
    STATUS_STR="validation_failed"
else
    STATUS_STR="critical_error"
fi

echo "{"
echo "  \"status\": \"$STATUS_STR\","
echo "  \"tasks_md\": {"
echo "    \"exists\": $TASKS_MD_EXISTS,"
echo "    \"is_symlink\": $TASKS_MD_IS_SYMLINK,"
echo "    \"is_writable\": $TASKS_MD_IS_WRITABLE,"
echo "    \"path\": \"./TASKS.md\""
echo "  },"
echo "  \"todo_files\": {"
echo "    \"discovered\": $TODO_FILES_DISCOVERED,"
echo "    \"validated\": $TODO_FILES_VALIDATED,"
echo "    \"rejected\": $TODO_FILES_REJECTED,"
echo "    \"files\": ["

# Output validated files
FIRST=true
for file_info in "${VALIDATED_FILES[@]}"; do
    IFS='|' read -r path size status <<< "$file_info"
    if [[ "$FIRST" == false ]]; then
        echo ","
    fi
    FIRST=false
    echo -n "      {"
    echo -n "\"path\": \"$path\", "
    echo -n "\"size\": $size, "
    echo -n "\"status\": \"$status\""
    echo -n "}"
done

# Output rejected files
for file_info in "${REJECTED_FILES[@]}"; do
    IFS='|' read -r path size status reason <<< "$file_info"
    if [[ "$FIRST" == false ]]; then
        echo ","
    fi
    FIRST=false
    echo -n "      {"
    echo -n "\"path\": \"$path\", "
    echo -n "\"size\": $size, "
    echo -n "\"status\": \"$status\", "
    echo -n "\"reason\": \"$reason\""
    echo -n "}"
done

echo ""
echo "    ]"
echo "  },"

# Output errors array
echo "  \"errors\": ["
FIRST=true
for error in "${ERRORS[@]}"; do
    if [[ "$FIRST" == false ]]; then
        echo ","
    fi
    FIRST=false
    # Escape quotes in error message
    escaped_error="${error//\"/\\\"}"
    echo -n "    \"$escaped_error\""
done
echo ""
echo "  ],"

# Output warnings array
echo "  \"warnings\": ["
FIRST=true
for warning in "${WARNINGS[@]}"; do
    if [[ "$FIRST" == false ]]; then
        echo ","
    fi
    FIRST=false
    # Escape quotes in warning message
    escaped_warning="${warning//\"/\\\"}"
    echo -n "    \"$escaped_warning\""
done
echo ""
echo "  ],"

# Output limits
echo "  \"limits\": {"
echo "    \"max_files\": $MAX_FILES,"
echo "    \"max_file_size\": $MAX_FILE_SIZE,"
echo "    \"max_total_size\": $MAX_TOTAL_SIZE,"
echo "    \"total_size_processed\": $TOTAL_SIZE"
echo "  }"
echo "}"

exit $EXIT_CODE
