#!/bin/bash
# feature-flag-registry.sh - Feature Flag Detection and Manipulation System
# Part of System 2: Klaus Baudelaire
# Created: 2026-01-27

# [!] Registry of all feature flags with human-readable descriptions
# Bash 3 compatible approach (no associative arrays)
# Format: "FLAG_NAME|Description"
FEATURE_FLAGS=(
  "ENABLE_WEB_RESEARCHER|Web research specialist agent"
  "ENABLE_DOCS_SPECIALIST|Documentation specialist agent"
  "ENABLE_FILE_PATH_EXTRACTOR|File path extraction from bash output"
  "ENABLE_TEST_INFRASTRUCTURE|Test infrastructure setup agent"
  "ENABLE_REMINDER_SYSTEM|Reminder nudger agent"
  "ENABLE_CONTEXT7_DETECTION|Library/framework detection"
  "ROUTING_EXPLANATION|Show routing decision rationale"
  "ENABLE_ASYNC_HOOKS|Async hook execution"
  "ENABLE_ROUTING_HISTORY|Routing outcome tracking telemetry"
  "ENABLE_GITHUB_ACTIONS|GitHub Actions CI/CD integration"
  "ENABLE_SUB_DELEGATION|Sub-delegation to specialized agents"
)

# [!] Get klaus-delegation.conf path
get_config_path() {
  local config_path="${KLAUS_ROOT:-$HOME/.claude}/config/klaus-delegation.conf"
  echo "$config_path"
}

# [!] Function: list_feature_flags()
# Lists all flags with current status in formatted table
list_feature_flags() {
  local config_path=$(get_config_path)

  if [[ ! -f "$config_path" ]]; then
    echo "Error: Configuration file not found at $config_path" >&2
    return 1
  fi

  # Print table header
  printf "%-35s %-10s %s\n" "FLAG NAME" "STATUS" "DESCRIPTION"
  printf "%-35s %-10s %s\n" "$(printf '=%.0s' {1..35})" "$(printf '=%.0s' {1..10})" "$(printf '=%.0s' {1..50})"

  # Iterate through all registered flags
  for flag_entry in "${FEATURE_FLAGS[@]}"; do
    local flag_name="${flag_entry%%|*}"
    local description="${flag_entry#*|}"

    # Extract current value from config file
    local current_value=$(grep "^${flag_name}=" "$config_path" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "'" | awk '{gsub(/#.*/, ""); gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print}')

    # Default to OFF if not found
    [[ -z "$current_value" ]] && current_value="OFF"

    # Format and print row
    printf "%-35s %-10s %s\n" "$flag_name" "$current_value" "$description"
  done | sort
}

# [!] Function: get_flag_value(flag_name)
# Returns current value of flag (ON/OFF)
get_flag_value() {
  local flag_name="$1"
  local config_path=$(get_config_path)

  if [[ ! -f "$config_path" ]]; then
    echo "Error: Configuration file not found at $config_path" >&2
    return 1
  fi

  # Extract value from config
  local value=$(grep "^${flag_name}=" "$config_path" | head -n 1 | cut -d'=' -f2 | tr -d '"' | tr -d "'" | awk '{gsub(/#.*/, ""); gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print}')

  # Return value or default to OFF
  if [[ -z "$value" ]]; then
    echo "OFF"
  else
    echo "$value"
  fi
}

# [!] Function: set_flag_value(flag_name, new_value)
# Sets flag to specified value (ON/OFF)
set_flag_value() {
  local flag_name="$1"
  local new_value="$2"
  local config_path=$(get_config_path)

  if [[ ! -f "$config_path" ]]; then
    echo "Error: Configuration file not found at $config_path" >&2
    return 1
  fi

  # Validate flag name exists in registry
  local flag_found=false
  for flag_entry in "${FEATURE_FLAGS[@]}"; do
    local entry_name="${flag_entry%%|*}"
    if [[ "$entry_name" == "$flag_name" ]]; then
      flag_found=true
      break
    fi
  done

  if [[ "$flag_found" != "true" ]]; then
    echo "Error: Unknown flag '$flag_name'" >&2
    echo "Run 'list_feature_flags' to see available flags" >&2
    return 1
  fi

  # Validate new value
  if [[ "$new_value" != "ON" && "$new_value" != "OFF" ]]; then
    echo "Error: Invalid value '$new_value'. Must be ON or OFF" >&2
    return 1
  fi

  # Create backup
  local backup_path="${config_path}.backup-$(date +%Y%m%d-%H%M%S)"
  cp "$config_path" "$backup_path"

  # Check if flag exists in config
  if grep -q "^${flag_name}=" "$config_path"; then
    # Update existing flag using sed
    # Use | as delimiter to avoid conflicts with = and "
    sed -i.tmp "s|^${flag_name}=.*|${flag_name}=\"${new_value}\"|" "$config_path"
    rm "${config_path}.tmp" 2>/dev/null
  else
    # Flag doesn't exist - add it to appropriate section
    echo "${flag_name}=\"${new_value}\"" >> "$config_path"
  fi

  echo "✓ Set ${flag_name}=${new_value}"
  echo "  Backup: $backup_path"
  return 0
}

# [!] Function: toggle_feature_flag(flag_name)
# Toggles flag between ON and OFF
toggle_feature_flag() {
  local flag_name="$1"

  # Get current value
  local current_value=$(get_flag_value "$flag_name")

  if [[ $? -ne 0 ]]; then
    return 1
  fi

  # Determine new value
  local new_value
  if [[ "$current_value" == "ON" ]]; then
    new_value="OFF"
  else
    new_value="ON"
  fi

  # Set new value
  set_flag_value "$flag_name" "$new_value"
}

# [!] Function: enable_feature_flag(flag_name)
# Enables a feature flag (sets to ON)
enable_feature_flag() {
  local flag_name="$1"
  set_flag_value "$flag_name" "ON"
}

# [!] Function: disable_feature_flag(flag_name)
# Disables a feature flag (sets to OFF)
disable_feature_flag() {
  local flag_name="$1"
  set_flag_value "$flag_name" "OFF"
}

# [!] Function: check_feature_enabled(flag_name)
# Returns 0 if enabled (ON), 1 if disabled (OFF)
# Exit code can be used in conditionals: if check_feature_enabled "FLAG"; then ...
check_feature_enabled() {
  local flag_name="$1"
  local value=$(get_flag_value "$flag_name")

  if [[ $? -ne 0 ]]; then
    return 1
  fi

  if [[ "$value" == "ON" ]]; then
    return 0
  else
    return 1
  fi
}

# [!] Function: get_flag_description(flag_name)
# Returns human-readable description of flag
get_flag_description() {
  local flag_name="$1"

  # Find flag in registry
  for flag_entry in "${FEATURE_FLAGS[@]}"; do
    local entry_name="${flag_entry%%|*}"
    if [[ "$entry_name" == "$flag_name" ]]; then
      echo "${flag_entry#*|}"
      return 0
    fi
  done

  echo "Error: Unknown flag '$flag_name'" >&2
  return 1
}

# [!] If executed directly (not sourced), provide CLI interface
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    list)
      list_feature_flags
      ;;
    get)
      if [[ -z "$2" ]]; then
        echo "Error: Flag name required" >&2
        echo "Usage: $0 get <flag_name>" >&2
        exit 1
      fi
      get_flag_value "$2"
      ;;
    set)
      if [[ -z "$2" || -z "$3" ]]; then
        echo "Error: Flag name and value required" >&2
        echo "Usage: $0 set <flag_name> <ON|OFF>" >&2
        exit 1
      fi
      set_flag_value "$2" "$3"
      ;;
    toggle)
      if [[ -z "$2" ]]; then
        echo "Error: Flag name required" >&2
        echo "Usage: $0 toggle <flag_name>" >&2
        exit 1
      fi
      toggle_feature_flag "$2"
      ;;
    enable)
      if [[ -z "$2" ]]; then
        echo "Error: Flag name required" >&2
        echo "Usage: $0 enable <flag_name>" >&2
        exit 1
      fi
      enable_feature_flag "$2"
      ;;
    disable)
      if [[ -z "$2" ]]; then
        echo "Error: Flag name required" >&2
        echo "Usage: $0 disable <flag_name>" >&2
        exit 1
      fi
      disable_feature_flag "$2"
      ;;
    check)
      if [[ -z "$2" ]]; then
        echo "Error: Flag name required" >&2
        echo "Usage: $0 check <flag_name>" >&2
        exit 1
      fi
      if check_feature_enabled "$2"; then
        echo "ON"
        exit 0
      else
        echo "OFF"
        exit 1
      fi
      ;;
    describe)
      if [[ -z "$2" ]]; then
        echo "Error: Flag name required" >&2
        echo "Usage: $0 describe <flag_name>" >&2
        exit 1
      fi
      get_flag_description "$2"
      ;;
    *)
      echo "Klaus Baudelaire Feature Flag Registry"
      echo ""
      echo "Usage: $0 <command> [args]"
      echo ""
      echo "Commands:"
      echo "  list                    List all flags with status"
      echo "  get <flag>              Get current value of flag"
      echo "  set <flag> <ON|OFF>     Set flag to specific value"
      echo "  toggle <flag>           Toggle flag ON ↔ OFF"
      echo "  enable <flag>           Enable flag (set to ON)"
      echo "  disable <flag>          Disable flag (set to OFF)"
      echo "  check <flag>            Check if flag enabled (exit 0=ON, 1=OFF)"
      echo "  describe <flag>         Get description of flag"
      echo ""
      echo "Examples:"
      echo "  $0 list"
      echo "  $0 toggle ENABLE_WEB_RESEARCHER"
      echo "  $0 check ENABLE_CONTEXT7_DETECTION"
      exit 1
      ;;
  esac
fi
