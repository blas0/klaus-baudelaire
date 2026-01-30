#!/bin/bash
# klaus-session-state.sh - Session state management for async hooks
# This enables non-blocking hook execution with background context injection

# [!] Session identification
SESSION_ID="${CLAUDE_CODE_TASK_LIST_ID:-$$}"
STATE_DIR="${KLAUS_ROOT:-${HOME}/.claude}/sessions"
STATE_FILE="${STATE_DIR}/${SESSION_ID}.state.json"

# [!] Initialize session state
init_session() {
  mkdir -p "$STATE_DIR"

  # Create initial session state file
  cat > "$STATE_FILE" <<EOF
{
  "session_id": "$SESSION_ID",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tier": "ANALYZING",
  "score": 0,
  "context": "",
  "async": true,
  "status": "pending"
}
EOF
}

# [!] Update context atomically
update_context() {
  local additional_context="$1"
  local tier="$2"
  local score="$3"

  [[ ! -f "$STATE_FILE" ]] && return 1

  # Create temp file with updated state
  local temp_file="${STATE_FILE}.tmp.$$"

  # Use jq for atomic JSON update
  jq --arg ctx "$additional_context" \
     --arg t "$tier" \
     --argjson s "$score" \
     '.context = $ctx | .tier = $t | .score = $s | .status = "complete" | .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))' \
     "$STATE_FILE" > "$temp_file" 2>/dev/null

  # Atomic move (if jq succeeded)
  if [[ $? -eq 0 && -s "$temp_file" ]]; then
    mv "$temp_file" "$STATE_FILE"
  else
    rm -f "$temp_file"
    return 1
  fi
}

# [!] Get current context
get_context() {
  [[ -f "$STATE_FILE" ]] && cat "$STATE_FILE" || echo "{}"
}

# [!] Get session tier
get_tier() {
  [[ -f "$STATE_FILE" ]] && jq -r '.tier // "ANALYZING"' "$STATE_FILE" 2>/dev/null || echo "ANALYZING"
}

# [!] Get session score
get_score() {
  [[ -f "$STATE_FILE" ]] && jq -r '.score // 0' "$STATE_FILE" 2>/dev/null || echo "0"
}

# [!] Check if background analysis is complete
is_complete() {
  [[ -f "$STATE_FILE" ]] && [[ "$(jq -r '.status // "pending"' "$STATE_FILE" 2>/dev/null)" == "complete" ]]
}

# [!] Cleanup old sessions (>24h)
cleanup_sessions() {
  # Only cleanup if state directory exists
  [[ ! -d "$STATE_DIR" ]] && return 0

  # Find and delete session files older than 1 day
  find "$STATE_DIR" -name "*.state.json" -type f -mtime +1 -delete 2>/dev/null

  # Also cleanup temporary files
  find "$STATE_DIR" -name "*.tmp.*" -type f -mmin +60 -delete 2>/dev/null
}

# [!] Export functions for use in other scripts
export -f init_session update_context get_context get_tier get_score is_complete cleanup_sessions
