#!/bin/bash

# Claude Code PostToolUse Hook: Automatic Code Formatting
# This script formats code files after Edit/Write tool usage
# Always exits 0 to avoid blocking Claude Code operations

FILE="$1"

# Exit silently if no file provided
if [[ -z "$FILE" ]]; then
    exit 0
fi

# Exit silently if file doesn't exist
if [[ ! -f "$FILE" ]]; then
    exit 0
fi

# Get file extension
EXT="${FILE##*.}"

# Function to find a file in parent directories
find_in_parents() {
    local pattern="$1"
    local dir="$(dirname "$FILE")"

    while [[ "$dir" != "/" ]]; do
        if ls "$dir"/$pattern &>/dev/null; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Format based on file type
case "$EXT" in
    cs|csproj|sln)
        # .NET files - use dotnet format
        if command -v dotnet &>/dev/null; then
            # Find solution or project file
            PROJECT_DIR=$(find_in_parents "*.sln")
            if [[ -z "$PROJECT_DIR" ]]; then
                PROJECT_DIR=$(find_in_parents "*.csproj")
            fi

            if [[ -n "$PROJECT_DIR" ]]; then
                # Find the actual solution or project file
                SLN_FILE=$(ls "$PROJECT_DIR"/*.sln 2>/dev/null | head -n 1)
                if [[ -n "$SLN_FILE" ]]; then
                    dotnet format "$SLN_FILE" --include "$FILE" &>/dev/null
                else
                    PROJ_FILE=$(ls "$PROJECT_DIR"/*.csproj 2>/dev/null | head -n 1)
                    if [[ -n "$PROJ_FILE" ]]; then
                        dotnet format "$PROJ_FILE" --include "$FILE" &>/dev/null
                    fi
                fi
            fi
        fi
        ;;

    js|jsx|ts|tsx|json)
        # JavaScript/TypeScript - use prettier
        if command -v prettier &>/dev/null; then
            prettier --write "$FILE" &>/dev/null
        fi
        ;;

    py)
        # Python - prefer black, fallback to autopep8
        if command -v black &>/dev/null; then
            black "$FILE" &>/dev/null
        elif command -v autopep8 &>/dev/null; then
            autopep8 --in-place "$FILE" &>/dev/null
        fi
        ;;

    sh)
        # Shell scripts - use shfmt
        if command -v shfmt &>/dev/null; then
            shfmt -w "$FILE" &>/dev/null
        fi
        ;;

    sql|ps1)
        # Skip - no standard formatter available
        ;;

    *)
        # Unknown file type - skip
        ;;
esac

# Always exit 0 to avoid blocking Claude Code
exit 0
