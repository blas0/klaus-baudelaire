#!/bin/bash
# file-lock-coordinator.sh - Prevent parallel file write collisions
# PreToolUse/PostToolUse hook for Write/Edit operations
# Recommendation R-009 from LOGANALYSIS.md

# [!] Configuration
LOCK_DIR="${HOME}/.claude/locks"
LOCK_TIMEOUT=300  # 5 minutes max lock duration

# [!] Initialize lock directory
init_locks() {
  mkdir -p "$LOCK_DIR"

  # Cleanup stale locks on init (older than LOCK_TIMEOUT)
  find "$LOCK_DIR" -name "*.lock" -type f -mmin +5 -delete 2>/dev/null
}

# [!] Generate lock file path from file path
get_lock_path() {
  local file_path="$1"
  # Hash the file path to create unique lock filename
  local hash=$(echo -n "$file_path" | md5sum | cut -d' ' -f1)
  echo "${LOCK_DIR}/${hash}.lock"
}

# [!] Acquire lock for a file
acquire_lock() {
  local file_path="$1"
  local lock_path=$(get_lock_path "$file_path")
  local session_id="${CLAUDE_CODE_TASK_LIST_ID:-$$}"

  # Check if lock exists and is owned by another session
  if [[ -f "$lock_path" ]]; then
    local lock_owner=$(cat "$lock_path" 2>/dev/null | jq -r '.session_id // ""')
    local lock_time=$(cat "$lock_path" 2>/dev/null | jq -r '.timestamp // 0')
    local now=$(date +%s)
    local age=$((now - lock_time))

    # If lock is stale (older than timeout), allow override
    if [[ $age -gt $LOCK_TIMEOUT ]]; then
      rm -f "$lock_path"
    elif [[ "$lock_owner" != "$session_id" ]]; then
      # Lock held by another session
      cat <<EOF
[FILE LOCK] Write collision detected:

  File: $file_path
  Locked by session: $lock_owner
  Lock age: ${age}s

[!!] Another agent may be writing to this file.
     Wait for completion or verify no conflict exists.

EOF
      return 1
    fi
  fi

  # Create lock file
  cat > "$lock_path" <<EOF
{
  "session_id": "$session_id",
  "file_path": "$file_path",
  "timestamp": $(date +%s),
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

  return 0
}

# [!] Release lock for a file
release_lock() {
  local file_path="$1"
  local lock_path=$(get_lock_path "$file_path")
  local session_id="${CLAUDE_CODE_TASK_LIST_ID:-$$}"

  # Only release if we own the lock
  if [[ -f "$lock_path" ]]; then
    local lock_owner=$(cat "$lock_path" 2>/dev/null | jq -r '.session_id // ""')
    if [[ "$lock_owner" == "$session_id" ]]; then
      rm -f "$lock_path"
    fi
  fi

  return 0
}

# [!] Extract file path from tool input (Write or Edit tool)
extract_file_path() {
  local tool_input="$1"

  # Try to extract file_path from JSON-like input
  echo "$tool_input" | grep -oP '"file_path"\s*:\s*"\K[^"]+' 2>/dev/null || \
  echo "$tool_input" | grep -oP 'file_path=\K[^\s]+' 2>/dev/null || \
  echo ""
}

# [!] Main entry point
main() {
  local action="${1:-acquire}"  # acquire or release
  local tool_input="${2:-$HOOK_TOOL_INPUT}"

  init_locks

  local file_path=$(extract_file_path "$tool_input")

  if [[ -z "$file_path" ]]; then
    # No file path detected, skip locking
    exit 0
  fi

  case "$action" in
    acquire|pre)
      if acquire_lock "$file_path"; then
        exit 0
      else
        # Lock conflict - output warning but don't block
        exit 0
      fi
      ;;
    release|post)
      release_lock "$file_path"
      exit 0
      ;;
    *)
      echo "[FILE LOCK] Unknown action: $action" >&2
      exit 1
      ;;
  esac
}

main "$@"
