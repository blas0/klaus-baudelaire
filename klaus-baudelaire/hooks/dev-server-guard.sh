#!/bin/bash
# dev-server-guard.sh - Detect existing dev server processes before starting new ones
# PreToolUse hook for Bash tool operations
# Recommendation R-002 from LOGANALYSIS.md

# [!] Configuration
COMMON_DEV_PORTS=(3000 3001 5173 8080 4321 5000 8000)
LOCK_FILES=(".next/dev/lock" ".vite/dev" "node_modules/.vite")

# [!] Check if this is a dev server command
is_dev_server_command() {
  local cmd="$1"

  # Match common dev server start patterns
  if [[ "$cmd" =~ (next\ dev|bun\ run\ dev|npm\ run\ dev|yarn\ dev|vite|astro\ dev) ]]; then
    return 0
  fi
  return 1
}

# [!] Check for processes on common dev ports
check_ports() {
  local conflicts=""

  for port in "${COMMON_DEV_PORTS[@]}"; do
    if lsof -i ":$port" -sTCP:LISTEN >/dev/null 2>&1; then
      local process_info=$(lsof -i ":$port" -sTCP:LISTEN -t 2>/dev/null | head -1)
      local process_name=$(ps -p "$process_info" -o comm= 2>/dev/null || echo "unknown")
      conflicts="${conflicts}  [!] Port $port in use by $process_name (PID: $process_info)\n"
    fi
  done

  echo -e "$conflicts"
}

# [!] Check for lock files indicating running dev server
check_lock_files() {
  local project_root="${CLAUDE_PROJECT_DIR:-.}"
  local locks=""

  for lock in "${LOCK_FILES[@]}"; do
    if [[ -e "$project_root/$lock" ]]; then
      locks="${locks}  [!] Lock file exists: $lock\n"
    fi
  done

  echo -e "$locks"
}

# [!] Main guard logic
guard_dev_server() {
  local command="$1"

  # Only check for dev server commands
  if ! is_dev_server_command "$command"; then
    exit 0
  fi

  local port_conflicts=$(check_ports)
  local lock_conflicts=$(check_lock_files)

  if [[ -n "$port_conflicts" || -n "$lock_conflicts" ]]; then
    cat <<EOF
[DEV SERVER GUARD] Potential conflict detected:

${port_conflicts}${lock_conflicts}
[?] A dev server may already be running.

Options:
1. Kill existing process: kill -9 <PID>
2. Use different port: --port <number>
3. Proceed anyway (may cause "port in use" error)

EOF
    # Exit with warning (non-blocking, just informational)
    exit 0
  fi

  exit 0
}

# [!] Entry point - expects command as argument or via HOOK_TOOL_INPUT
COMMAND="${1:-$HOOK_TOOL_INPUT}"
guard_dev_server "$COMMAND"
