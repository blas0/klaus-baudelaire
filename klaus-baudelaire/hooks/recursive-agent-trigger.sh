#!/usr/bin/env bash
# hooks/recursive-agent-trigger.sh
# Optional UserPromptSubmit hook for auto-detecting large document analysis requests
#
# Analyzes user prompts to determine if recursive-agent should be suggested.
# NOT part of default delegation - user must explicitly enable this hook.
#
# Exit codes:
#   0 = No suggestion needed (continue normally)
#   1 = Error
#   2 = Suggest recursive-agent to user

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/recursive-agent-config.yaml"

# Token threshold for suggesting recursive-agent (default: 50000)
TOKEN_THRESHOLD=50000

# Minimum confidence score for auto-detection (0.0-1.0)
MIN_CONFIDENCE=0.7

# ============================================================================
# Utility Functions
# ============================================================================

log() {
    echo "[recursive-trigger] $*" >&2
}

error() {
    echo "[recursive-trigger ERROR] $*" >&2
}

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log "Loading config from $CONFIG_FILE"
        if command -v yq &>/dev/null; then
            TOKEN_THRESHOLD=$(yq eval '.trigger.token_threshold // 50000' "$CONFIG_FILE")
            MIN_CONFIDENCE=$(yq eval '.trigger.min_confidence // 0.7' "$CONFIG_FILE")
        fi
    fi
}

# Get user prompt from environment
get_user_prompt() {
    # $USER_PROMPT environment variable set by hook system
    echo "${USER_PROMPT:-}"
}

# Estimate token count (rough approximation: 1 token ≈ 4 characters)
estimate_tokens() {
    local text="$1"
    local char_count=${#text}
    echo $((char_count / 4))
}

# Check if prompt mentions file paths
contains_file_references() {
    local prompt="$1"

    # Look for common file path patterns
    if echo "$prompt" | grep -qE '\.(pdf|docx?|txt|md|csv|json|xml|html?)'; then
        return 0
    fi

    # Look for @ file references (Claude Code convention)
    if echo "$prompt" | grep -q '@[a-zA-Z0-9/_.-]\+'; then
        return 0
    fi

    return 1
}

# Check for analysis keywords
contains_analysis_keywords() {
    local prompt="$1"

    # Keywords suggesting document analysis
    local keywords=(
        "analyze"
        "extract"
        "summarize"
        "review"
        "audit"
        "compliance"
        "find all"
        "list all"
        "identify"
        "locate"
        "search for"
    )

    for keyword in "${keywords[@]}"; do
        if echo "$prompt" | grep -qiE "\\b${keyword}\\b"; then
            return 0
        fi
    done

    return 1
}

# Calculate confidence score for recursive-agent suggestion
calculate_confidence() {
    local prompt="$1"
    local confidence=0.0

    # Factor 1: File reference (+0.3)
    if contains_file_references "$prompt"; then
        confidence=$(echo "$confidence + 0.3" | bc -l)
        log "File reference detected (+0.3)"
    fi

    # Factor 2: Analysis keywords (+0.3)
    if contains_analysis_keywords "$prompt"; then
        confidence=$(echo "$confidence + 0.3" | bc -l)
        log "Analysis keywords detected (+0.3)"
    fi

    # Factor 3: Mentions "chunk", "large", "long" (+0.2)
    if echo "$prompt" | grep -qiE "\\b(chunk|large|long|extensive|comprehensive)\\b"; then
        confidence=$(echo "$confidence + 0.2" | bc -l)
        log "Size-related keywords detected (+0.2)"
    fi

    # Factor 4: Mentions specific extraction targets (+0.2)
    if echo "$prompt" | grep -qiE "\\b(date|amount|entity|clause|section|paragraph)s?\\b"; then
        confidence=$(echo "$confidence + 0.2" | bc -l)
        log "Extraction targets detected (+0.2)"
    fi

    echo "$confidence"
}

# ============================================================================
# Main Logic
# ============================================================================

main() {
    log "Checking if recursive-agent should be suggested"

    # Load configuration
    load_config

    # Get user prompt
    local prompt
    prompt=$(get_user_prompt)

    if [[ -z "$prompt" ]]; then
        log "No user prompt found, skipping"
        return 0
    fi

    # Estimate token count
    local token_count
    token_count=$(estimate_tokens "$prompt")

    log "Estimated token count: $token_count (threshold: $TOKEN_THRESHOLD)"

    # Calculate confidence
    local confidence
    confidence=$(calculate_confidence "$prompt")

    log "Confidence score: $confidence (min: $MIN_CONFIDENCE)"

    # Check if we should suggest recursive-agent
    if (( $(echo "$confidence >= $MIN_CONFIDENCE" | bc -l) )); then
        log "Confidence threshold met, suggesting recursive-agent"

        # Output suggestion message (will be shown to user)
        cat <<EOF

[!] Recursive Agent Suggestion

Your request appears to involve analyzing a large document or extracting structured data.
Consider using the recursive-agent for optimized performance:

  Use recursive-agent for this analysis

Benefits:
- Parallel chunk processing (faster for large documents)
- Structured extraction with confidence scores
- Automatic deduplication and conflict resolution
- Comprehensive markdown report output

Confidence: $(printf "%.0f" $(echo "$confidence * 100" | bc -l))%

To proceed with recursive-agent, respond with: "Yes, use recursive-agent"
To proceed normally, respond with: "No, continue"

EOF

        return 2  # Signal suggestion
    else
        log "Confidence below threshold, no suggestion"
        return 0
    fi
}

# ============================================================================
# Execute
# ============================================================================

main "$@"
exit $?
