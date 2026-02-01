#!/bin/bash
# routing-telemetry.sh - Privacy-first routing outcome tracking
# Part of Klaus System B1 - Async-native telemetry for routing analysis

# [!] Configuration defaults
ENABLE_TELEMETRY="${ENABLE_ROUTING_HISTORY:-OFF}"
HISTORY_FILE="${ROUTING_HISTORY_FILE:-${KLAUS_ROOT:-${HOME}/.claude}/telemetry/routing-history.jsonl}"
SANITIZE="${ROUTING_HISTORY_SANITIZE:-ON}"

# [!] Log routing decision to JSONL file
log_routing_decision() {
  # Skip if telemetry disabled
  [[ "$ENABLE_TELEMETRY" != "ON" ]] && return 0

  local prompt="$1"
  local score="$2"
  local tier="$3"
  local context7_relevant="${4:-false}"
  local context7_score="${5:-0}"
  local matched_patterns="${6:-}"

  # [!] Privacy-first: Hash prompt by default
  local prompt_identifier
  if [[ "$SANITIZE" == "ON" ]]; then
    prompt_identifier=$(echo -n "$prompt" | shasum -a 256 | cut -d' ' -f1)
  else
    # Only store unhashed if user explicitly disabled sanitization
    prompt_identifier="$prompt"
  fi

  # [!] Create telemetry directory if needed
  mkdir -p "$(dirname "$HISTORY_FILE")"

  # [!] Append JSONL entry (newline-delimited JSON)
  cat >> "$HISTORY_FILE" <<EOF
{"timestamp":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","prompt_hash":"$prompt_identifier","prompt_length":${#prompt},"score":$score,"tier":"$tier","context7_relevant":$context7_relevant,"context7_score":$context7_score,"matched_patterns":"$matched_patterns"}
EOF
}

# [!] Cleanup old telemetry entries (>30 days)
cleanup_telemetry() {
  [[ ! -f "$HISTORY_FILE" ]] && return 0

  # Create temp file with recent entries only
  local cutoff_date=$(date -u -v-30d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '30 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)
  local temp_file="${HISTORY_FILE}.tmp.$$"

  # Filter entries newer than 30 days
  if command -v jq &> /dev/null; then
    jq -c --arg cutoff "$cutoff_date" 'select(.timestamp >= $cutoff)' "$HISTORY_FILE" > "$temp_file" 2>/dev/null

    # Replace file if filtering succeeded
    if [[ $? -eq 0 && -s "$temp_file" ]]; then
      mv "$temp_file" "$HISTORY_FILE"
    else
      rm -f "$temp_file"
    fi
  fi
}

# [!] Export functions for use in other scripts
export -f log_routing_decision cleanup_telemetry
