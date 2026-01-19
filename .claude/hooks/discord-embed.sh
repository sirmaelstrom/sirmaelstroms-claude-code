#!/bin/bash

# Discord embed webhook helper
# Sends rich Discord embeds with color, title, fields, and formatting

# Color mappings (decimal values for Discord API)
declare -A COLORS=(
    ["green"]=5763719
    ["yellow"]=16776960
    ["red"]=15548997
    ["blue"]=3447003
    ["purple"]=10181046
    ["orange"]=15105570
)

# Default values
WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-}"
TITLE=""
DESCRIPTION=""
COLOR=""
FOOTER=""
USE_TIMESTAMP=false
declare -a FIELDS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --webhook)
            WEBHOOK_URL="$2"
            shift 2
            ;;
        --title)
            TITLE="$2"
            shift 2
            ;;
        --description)
            DESCRIPTION="$2"
            shift 2
            ;;
        --color)
            # Check if it's a named color or numeric
            if [[ -n "${COLORS[$2]}" ]]; then
                COLOR="${COLORS[$2]}"
            elif [[ "$2" =~ ^[0-9]+$ ]]; then
                COLOR="$2"
            else
                echo "Warning: Unknown color '$2', using blue as default" >&2
                COLOR="${COLORS[blue]}"
            fi
            shift 2
            ;;
        --field)
            FIELDS+=("$2")
            shift 2
            ;;
        --footer)
            FOOTER="$2"
            shift 2
            ;;
        --timestamp)
            USE_TIMESTAMP=true
            shift
            ;;
        *)
            echo "Warning: Unknown argument '$1'" >&2
            shift
            ;;
    esac
done

# Validate webhook URL
if [[ -z "$WEBHOOK_URL" ]]; then
    echo "Error: No webhook URL provided. Use --webhook or set DISCORD_WEBHOOK_URL environment variable." >&2
    exit 0  # Exit 0 to not block
fi

# Build JSON payload
build_json() {
    local json='{"embeds":[{'

    # Add title if present
    if [[ -n "$TITLE" ]]; then
        # Escape quotes and backslashes for JSON
        local escaped_title="${TITLE//\\/\\\\}"
        escaped_title="${escaped_title//\"/\\\"}"
        json+="\"title\":\"$escaped_title\""
    fi

    # Add description if present
    if [[ -n "$DESCRIPTION" ]]; then
        local escaped_desc="${DESCRIPTION//\\/\\\\}"
        escaped_desc="${escaped_desc//\"/\\\"}"
        [[ -n "$TITLE" ]] && json+=","
        json+="\"description\":\"$escaped_desc\""
    fi

    # Add color if present
    if [[ -n "$COLOR" ]]; then
        [[ -n "$TITLE" || -n "$DESCRIPTION" ]] && json+=","
        json+="\"color\":$COLOR"
    fi

    # Add fields if present
    if [[ ${#FIELDS[@]} -gt 0 ]]; then
        [[ -n "$TITLE" || -n "$DESCRIPTION" || -n "$COLOR" ]] && json+=","
        json+="\"fields\":["
        local first=true
        for field in "${FIELDS[@]}"; do
            # Split field on :: separator
            if [[ "$field" =~ ^(.*)::(.*)$ ]]; then
                local name="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"

                # Escape for JSON
                name="${name//\\/\\\\}"
                name="${name//\"/\\\"}"
                value="${value//\\/\\\\}"
                value="${value//\"/\\\"}"

                [[ "$first" == false ]] && json+=","
                json+="{\"name\":\"$name\",\"value\":\"$value\",\"inline\":false}"
                first=false
            fi
        done
        json+="]"
    fi

    # Add timestamp if requested
    if [[ "$USE_TIMESTAMP" == true ]]; then
        [[ -n "$TITLE" || -n "$DESCRIPTION" || -n "$COLOR" || ${#FIELDS[@]} -gt 0 ]] && json+=","
        json+="\"timestamp\":\"$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")\""
    fi

    # Add footer if present
    if [[ -n "$FOOTER" ]]; then
        local escaped_footer="${FOOTER//\\/\\\\}"
        escaped_footer="${escaped_footer//\"/\\\"}"
        [[ -n "$TITLE" || -n "$DESCRIPTION" || -n "$COLOR" || ${#FIELDS[@]} -gt 0 || "$USE_TIMESTAMP" == true ]] && json+=","
        json+="\"footer\":{\"text\":\"$escaped_footer\"}"
    fi

    json+="}]}"
    echo "$json"
}

# Build and send payload
PAYLOAD=$(build_json)

# Send to Discord webhook
if ! curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL" -s -o /dev/null -w "%{http_code}" | grep -q "^20"; then
    echo "Error: Failed to send Discord webhook" >&2
fi

# Always exit 0 to not block
exit 0
