#!/bin/bash
# klaus-delegation.sh - Cost-aware routing with configurable scoring
set -euo pipefail

# Support plugin installation (uses CLAUDE_PLUGIN_ROOT) or standalone (uses ~/.claude)
# Allow KLAUS_ROOT override for testing
KLAUS_ROOT="${KLAUS_ROOT:-${CLAUDE_PLUGIN_ROOT:-${HOME}/.claude}}"
CONFIG_FILE="${KLAUS_ROOT}/config/klaus-delegation.conf"
PROFILES_CONFIG_FILE="${KLAUS_ROOT}/config/klaus-profiles.conf"
TIERED_WORKFLOW="${KLAUS_ROOT}/hooks/tiered-workflow.txt"

# Defaults
SMART_DELEGATE_MODE="ON"
MIN_LENGTH=30
TIER_LIGHT_MIN=3
TIER_MEDIUM_MIN=5
TIER_FULL_MIN=7
LENGTH_100_SCORE=1
LENGTH_200_SCORE=1
LENGTH_400_SCORE=2
DEBUG_MODE="OFF"

COMPLEX_KEYWORDS=("refactor:3" "implement:2" "system|integrate|architecture:2" "across|multiple:1" "best practice|research:3")
SIMPLE_KEYWORDS=("fix typo|rename:4" "simple|quick:3" "this file:2")

# Context7 defaults
ENABLE_CONTEXT7_DETECTION="OFF"
CONTEXT7_SCORE_THRESHOLD=3
CONTEXT7_SCORE_BOOST=2

# Routing explanation defaults
ROUTING_EXPLANATION="ON"

# Async defaults
ENABLE_ASYNC_HOOKS="OFF"

# [!] PROFILE LOADER - System 1: Delegation Profile System
# Define functions BEFORE config file sourcing so they can be called afterward
load_profile() {
  local profile_name="$1"

  # Validate profile file exists
  [[ ! -f "$PROFILES_CONFIG_FILE" ]] && return 1

  # Extract profile section using awk (stop at next [section] or section delimiter)
  local profile_section=$(awk -v profile="$profile_name" '
    /^\[profile "'"$profile_name"'"\]$/ { in_section=1; next }
    in_section && /^$/ { empty_count++; next }
    in_section && empty_count > 0 && /^#/ { exit }
    in_section && /^\[/ { exit }
    in_section && !/^#/ { empty_count=0; print }
  ' "$PROFILES_CONFIG_FILE")

  # Validate profile exists
  [[ -z "$profile_section" ]] && return 1

  # Parse and validate thresholds (strip comments with #)
  local light_threshold=$(echo "$profile_section" | grep "^[[:space:]]*light_threshold" | awk -F'=' '{gsub(/#.*/, "", $2); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
  local medium_threshold=$(echo "$profile_section" | grep "^[[:space:]]*medium_threshold" | awk -F'=' '{gsub(/#.*/, "", $2); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
  local full_threshold=$(echo "$profile_section" | grep "^[[:space:]]*full_threshold" | awk -F'=' '{gsub(/#.*/, "", $2); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')

  # Validate monotonicity: LIGHT <= MEDIUM <= FULL
  [[ -z "$light_threshold" || -z "$medium_threshold" || -z "$full_threshold" ]] && return 1
  [[ ! "$light_threshold" =~ ^[0-9]+$ || ! "$medium_threshold" =~ ^[0-9]+$ || ! "$full_threshold" =~ ^[0-9]+$ ]] && return 1
  [[ $light_threshold -gt $medium_threshold || $medium_threshold -gt $full_threshold ]] && return 1

  # Override tier thresholds
  TIER_LIGHT_MIN=$light_threshold
  TIER_MEDIUM_MIN=$medium_threshold
  TIER_FULL_MIN=$full_threshold

  # Parse keyword weights (optional - use existing if not defined, strip comments)
  local weight_refactor=$(echo "$profile_section" | grep "^[[:space:]]*weight_refactor" | awk -F'=' '{gsub(/#.*/, "", $2); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
  local weight_implement=$(echo "$profile_section" | grep "^[[:space:]]*weight_implement" | awk -F'=' '{gsub(/#.*/, "", $2); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
  local weight_system=$(echo "$profile_section" | grep "^[[:space:]]*weight_system" | awk -F'=' '{gsub(/#.*/, "", $2); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
  local weight_across_multiple=$(echo "$profile_section" | grep "^[[:space:]]*weight_across_multiple" | awk -F'=' '{gsub(/#.*/, "", $2); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')

  # Override keyword weights by searching for patterns in COMPLEX_KEYWORDS array
  if [[ -n "$weight_refactor" ]]; then
    for i in "${!COMPLEX_KEYWORDS[@]}"; do
      if [[ "${COMPLEX_KEYWORDS[$i]}" =~ ^refactor ]]; then
        COMPLEX_KEYWORDS[$i]=$(echo "${COMPLEX_KEYWORDS[$i]}" | sed "s/:[0-9]*$/:$weight_refactor/")
        break
      fi
    done
  fi

  if [[ -n "$weight_implement" ]]; then
    for i in "${!COMPLEX_KEYWORDS[@]}"; do
      if [[ "${COMPLEX_KEYWORDS[$i]}" =~ ^implement ]]; then
        COMPLEX_KEYWORDS[$i]=$(echo "${COMPLEX_KEYWORDS[$i]}" | sed "s/:[0-9]*$/:$weight_implement/")
        break
      fi
    done
  fi

  if [[ -n "$weight_system" ]]; then
    for i in "${!COMPLEX_KEYWORDS[@]}"; do
      if [[ "${COMPLEX_KEYWORDS[$i]}" =~ ^system ]]; then
        COMPLEX_KEYWORDS[$i]=$(echo "${COMPLEX_KEYWORDS[$i]}" | sed "s/:[0-9]*$/:$weight_system/")
        break
      fi
    done
  fi

  if [[ -n "$weight_across_multiple" ]]; then
    for i in "${!COMPLEX_KEYWORDS[@]}"; do
      if [[ "${COMPLEX_KEYWORDS[$i]}" =~ ^across ]]; then
        COMPLEX_KEYWORDS[$i]=$(echo "${COMPLEX_KEYWORDS[$i]}" | sed "s/:[0-9]*$/:$weight_across_multiple/")
        break
      fi
    done
  fi

  # Parse feature flags (optional, strip comments)
  local enable_plan=$(echo "$profile_section" | grep "^[[:space:]]*enable_plan_orchestration" | awk -F'=' '{gsub(/#.*/, "", $2); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
  local enable_explanation=$(echo "$profile_section" | grep "^[[:space:]]*enable_routing_explanation" | awk -F'=' '{gsub(/#.*/, "", $2); gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')

  [[ "$enable_plan" == "false" ]] && ENABLE_PLAN_ORCHESTRATION="OFF"
  [[ "$enable_explanation" == "false" ]] && ROUTING_EXPLANATION="OFF"

  return 0
}

detect_and_load_profile() {
  local profile_name=""

  # [1] Check KLAUS_PROFILE environment variable (highest priority)
  if [[ -n "${KLAUS_PROFILE:-}" ]]; then
    profile_name="$KLAUS_PROFILE"
  # [2] Check .klaus-profile file in repository root (auto-detection)
  elif [[ -f "${PWD}/.klaus-profile" ]]; then
    profile_name=$(head -n 1 "${PWD}/.klaus-profile" | tr -d '[:space:]')
  # [3] Fall back to "balanced" default
  else
    profile_name="balanced"
  fi

  # Load profile (returns 1 if profile not found or invalid)
  if ! load_profile "$profile_name"; then
    # Invalid profile - fall back to balanced
    load_profile "balanced" || true  # Continue even if balanced fails
  fi
}

[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# Initialize CONTEXT7_KEYWORDS as empty array if not set by config
[[ -z "${CONTEXT7_KEYWORDS+x}" ]] && CONTEXT7_KEYWORDS=()

# [!] Load profile AFTER config file to override config defaults
detect_and_load_profile

# Source session state management for async mode
SESSION_STATE_SCRIPT="${KLAUS_ROOT}/hooks/klaus-session-state.sh"
if [[ "$ENABLE_ASYNC_HOOKS" == "ON" && -f "$SESSION_STATE_SCRIPT" ]]; then
  source "$SESSION_STATE_SCRIPT"
fi

# Source routing telemetry for outcome tracking (defer if async to avoid blocking provisional response)
if [[ "$ENABLE_ASYNC_HOOKS" != "ON" ]]; then
  TELEMETRY_SCRIPT="${KLAUS_ROOT}/hooks/routing-telemetry.sh"
  if [[ -f "$TELEMETRY_SCRIPT" ]]; then
    source "$TELEMETRY_SCRIPT"
  fi
fi

INPUT=$(cat)
USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')
LOWER_PROMPT=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')
PROMPT_LENGTH=${#USER_PROMPT}

# Skip checks
[[ "$SMART_DELEGATE_MODE" == "OFF" ]] && { echo '{}'; exit 0; }
[[ "$USER_PROMPT" == /* ]] && { echo '{}'; exit 0; }
[[ "$PROMPT_LENGTH" -lt "$MIN_LENGTH" ]] && { echo '{}'; exit 0; }

# [!] ASYNC MODE: Immediate provisional response + background analysis
if [[ "$ENABLE_ASYNC_HOOKS" == "ON" ]]; then
  # [1] Immediate provisional response (<10ms target)
  echo '{
    "hookSpecificOutput": {
      "hookEventName": "UserPromptSubmit",
      "additionalContext": "",
      "metadata": {
        "tier": "ANALYZING",
        "score": 0,
        "async": true,
        "provisional": true
      }
    }
  }'

  # [2] Fork background analysis process
  (
    # Initialize session in background to avoid blocking provisional response
    init_session

    # Source telemetry in background for async mode
    TELEMETRY_SCRIPT="${KLAUS_ROOT}/hooks/routing-telemetry.sh"
    if [[ -f "$TELEMETRY_SCRIPT" ]]; then
      source "$TELEMETRY_SCRIPT"
    fi

    # Run full scoring logic in background
    SCORE=0
    MATCHED_COMPLEX=()
    MATCHED_SIMPLE=()
    LENGTH_BONUSES=()

    # Length scoring
    if [[ $PROMPT_LENGTH -gt 100 ]]; then
      ((SCORE += LENGTH_100_SCORE))
      LENGTH_BONUSES+=("length>100 (+$LENGTH_100_SCORE)")
    fi
    if [[ $PROMPT_LENGTH -gt 200 ]]; then
      ((SCORE += LENGTH_200_SCORE))
      LENGTH_BONUSES+=("length>200 (+$LENGTH_200_SCORE)")
    fi
    if [[ $PROMPT_LENGTH -gt 400 ]]; then
      ((SCORE += LENGTH_400_SCORE))
      LENGTH_BONUSES+=("length>400 (+$LENGTH_400_SCORE)")
    fi

    # Complex keywords
    for entry in "${COMPLEX_KEYWORDS[@]}"; do
      pattern="${entry%:*}"; weight="${entry#*:}"
      if echo "$LOWER_PROMPT" | grep -qE "($pattern)"; then
        ((SCORE += weight))
        MATCHED_COMPLEX+=("${pattern%%|*} (+$weight)")
      fi
    done

    # Simple keywords
    for entry in "${SIMPLE_KEYWORDS[@]}"; do
      pattern="${entry%:*}"; weight="${entry#*:}"
      if echo "$LOWER_PROMPT" | grep -qE "($pattern)"; then
        ((SCORE -= weight))
        MATCHED_SIMPLE+=("${pattern%%|*} (-$weight)")
      fi
    done

    # Context7 detection
    CONTEXT7_SCORE=0
    CONTEXT7_RELEVANT="false"
    if [[ "$ENABLE_CONTEXT7_DETECTION" == "ON" ]]; then
      for entry in "${CONTEXT7_KEYWORDS[@]}"; do
        pattern="${entry%:*}"; weight="${entry#*:}"
        if echo "$LOWER_PROMPT" | grep -qE "($pattern)"; then
          ((CONTEXT7_SCORE += weight))
        fi
      done
      if [[ $CONTEXT7_SCORE -ge $CONTEXT7_SCORE_THRESHOLD ]]; then
        CONTEXT7_RELEVANT="true"
        ((SCORE += CONTEXT7_SCORE_BOOST))
      fi
    fi

    # Clamp score
    [[ $SCORE -lt 0 ]] && SCORE=0
    [[ $SCORE -gt 50 ]] && SCORE=50

    # Determine tier
    if [[ $SCORE -lt $TIER_LIGHT_MIN ]]; then TIER="DIRECT"
    elif [[ $SCORE -lt $TIER_MEDIUM_MIN ]]; then TIER="LIGHT"
    elif [[ $SCORE -lt $TIER_FULL_MIN ]]; then TIER="MEDIUM"
    else TIER="FULL"; fi

    # Generate enhanced context if needed
    ADDITIONAL_CONTEXT=""
    if [[ "$TIER" != "DIRECT" && -f "$TIERED_WORKFLOW" ]]; then
      WORKFLOW=$(cat "$TIERED_WORKFLOW")
      WORKFLOW="${WORKFLOW//\{\{TIER\}\}/$TIER}"

      # Prepend routing explanation if enabled
      if [[ "$ROUTING_EXPLANATION" == "ON" ]]; then
        EXPLANATION=$(generate_routing_explanation "$TIER" "$SCORE")
        ADDITIONAL_CONTEXT="${EXPLANATION}${WORKFLOW}"
      else
        ADDITIONAL_CONTEXT="$WORKFLOW"
      fi
    fi

    # [!] Log routing decision (telemetry)
    log_routing_decision "$USER_PROMPT" "$SCORE" "$TIER" "$CONTEXT7_RELEVANT" "$CONTEXT7_SCORE" "${MATCHED_COMPLEX[*]:-}"

    # Update session state
    update_context "$ADDITIONAL_CONTEXT" "$TIER" "$SCORE"

    # Cleanup old sessions and telemetry
    cleanup_sessions
    cleanup_telemetry

  ) &  # Run in background

  # [4] Exit immediately (non-blocking)
  exit 0
fi

# [!] SYNCHRONOUS MODE: Original logic (when ENABLE_ASYNC_HOOKS=OFF)

# Scoring
SCORE=0
MATCHED_COMPLEX=()
MATCHED_SIMPLE=()
LENGTH_BONUSES=()

if [[ $PROMPT_LENGTH -gt 100 ]]; then
  ((SCORE += LENGTH_100_SCORE))
  LENGTH_BONUSES+=("length>100 (+$LENGTH_100_SCORE)")
fi
if [[ $PROMPT_LENGTH -gt 200 ]]; then
  ((SCORE += LENGTH_200_SCORE))
  LENGTH_BONUSES+=("length>200 (+$LENGTH_200_SCORE)")
fi
if [[ $PROMPT_LENGTH -gt 400 ]]; then
  ((SCORE += LENGTH_400_SCORE))
  LENGTH_BONUSES+=("length>400 (+$LENGTH_400_SCORE)")
fi

for entry in "${COMPLEX_KEYWORDS[@]}"; do
  pattern="${entry%:*}"; weight="${entry#*:}"
  if echo "$LOWER_PROMPT" | grep -qE "($pattern)"; then
    ((SCORE += weight))
    MATCHED_COMPLEX+=("${pattern%%|*} (+$weight)")
  fi
done

for entry in "${SIMPLE_KEYWORDS[@]}"; do
  pattern="${entry%:*}"; weight="${entry#*:}"
  if echo "$LOWER_PROMPT" | grep -qE "($pattern)"; then
    ((SCORE -= weight))
    MATCHED_SIMPLE+=("${pattern%%|*} (-$weight)")
  fi
done

# Context7 detection
CONTEXT7_SCORE=0
CONTEXT7_RELEVANT="false"
CONTEXT7_MATCHED_KEYWORDS=()

if [[ "$ENABLE_CONTEXT7_DETECTION" == "ON" ]]; then
  for entry in "${CONTEXT7_KEYWORDS[@]}"; do
    pattern="${entry%:*}"; weight="${entry#*:}"
    if echo "$LOWER_PROMPT" | grep -qE "($pattern)"; then
      ((CONTEXT7_SCORE += weight))
      CONTEXT7_MATCHED_KEYWORDS+=("$pattern")
    fi
  done

  # Boost overall score if Context7 relevant
  if [[ $CONTEXT7_SCORE -ge $CONTEXT7_SCORE_THRESHOLD ]]; then
    CONTEXT7_RELEVANT="true"
    ((SCORE += CONTEXT7_SCORE_BOOST))
  fi
fi

[[ $SCORE -lt 0 ]] && SCORE=0
[[ $SCORE -gt 50 ]] && SCORE=50

# Generate routing explanation
generate_routing_explanation() {
  local tier="$1"
  local score="$2"

  cat <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[KLAUS ROUTING] Score: $score → $tier tier
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Matched patterns:
EOF

  # Length bonuses
  if [[ ${#LENGTH_BONUSES[@]} -gt 0 ]]; then
    for bonus in "${LENGTH_BONUSES[@]}"; do
      echo "  • $bonus"
    done
  fi

  # Complex keywords
  if [[ ${#MATCHED_COMPLEX[@]} -gt 0 ]]; then
    for match in "${MATCHED_COMPLEX[@]}"; do
      echo "  • $match"
    done
  fi

  # Simple keywords (negative)
  if [[ ${#MATCHED_SIMPLE[@]} -gt 0 ]]; then
    for match in "${MATCHED_SIMPLE[@]}"; do
      echo "  • $match"
    done
  fi

  # Context7 boost
  if [[ "$CONTEXT7_RELEVANT" == "true" ]]; then
    echo "  • Context7 documentation detected (+$CONTEXT7_SCORE_BOOST)"
  fi

  # Rationale
  echo ""
  echo "Rationale:"
  case "$tier" in
    "LIGHT")
      echo "  Quick reconnaissance with explore-light agent."
      echo "  Score 3-4 suggests straightforward task needing basic context."
      ;;
    "MEDIUM")
      echo "  Light intelligence: explore-light + research-light + plan-orchestrator agents."
      echo "  Score 5-6 suggests multi-file changes requiring coordination."
      ;;
    "FULL")
      echo "  Full intelligence: explore-lead + research-lead + web-research-specialist + plan-orchestrator."
      echo "  Score 7+ indicates complex work requiring comprehensive research and planning."
      ;;
  esac

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

# Routing
if [[ $SCORE -lt $TIER_LIGHT_MIN ]]; then TIER="DIRECT"
elif [[ $SCORE -lt $TIER_MEDIUM_MIN ]]; then TIER="LIGHT"
elif [[ $SCORE -lt $TIER_FULL_MIN ]]; then TIER="MEDIUM"
else TIER="FULL"; fi

# [!] Log routing decision (telemetry - all tiers including DIRECT)
log_routing_decision "$USER_PROMPT" "$SCORE" "$TIER" "$CONTEXT7_RELEVANT" "$CONTEXT7_SCORE" "${MATCHED_COMPLEX[*]:-}"

# For DIRECT tier, include metadata but no workflow injection (allows testing score calculation)
[[ "$TIER" == "DIRECT" ]] && {
  jq -n --arg t "$TIER" --arg s "$SCORE" --arg c7 "$CONTEXT7_RELEVANT" --arg c7s "$CONTEXT7_SCORE" \
    '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"","metadata":{"complexity_score":($s|tonumber),"tier":$t,"context7_relevant":($c7=="true"),"context7_score":($c7s|tonumber)}}}'
  exit 0
}

# [!!!] PLAN AGENT ORCHESTRATION (Phase 1.5 - System 5)
# When MEDIUM/FULL tier, provide additionalContext instructing to invoke plan-orchestrator agent
if [[ "$TIER" == "MEDIUM" || "$TIER" == "FULL" ]]; then
    # Build additionalContext with Plan agent orchestration instructions
    ADDITIONAL_CONTEXT="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    ADDITIONAL_CONTEXT+="[KLAUS ROUTING] Score: ${SCORE} → ${TIER} tier\n"
    ADDITIONAL_CONTEXT+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

    # [!!!] Add routing explanation if enabled
    if [[ "$ROUTING_EXPLANATION" == "ON" ]]; then
        ADDITIONAL_CONTEXT+="Matched patterns:\n"
        # Length bonuses
        if [[ ${#LENGTH_BONUSES[@]} -gt 0 ]]; then
            for bonus in "${LENGTH_BONUSES[@]}"; do
                ADDITIONAL_CONTEXT+="  • $bonus\n"
            done
        fi
        # Complex keywords
        if [[ ${#MATCHED_COMPLEX[@]} -gt 0 ]]; then
            for match in "${MATCHED_COMPLEX[@]}"; do
                ADDITIONAL_CONTEXT+="  • $match\n"
            done
        fi
        # Simple keywords (negative)
        if [[ ${#MATCHED_SIMPLE[@]} -gt 0 ]]; then
            for match in "${MATCHED_SIMPLE[@]}"; do
                ADDITIONAL_CONTEXT+="  • $match\n"
            done
        fi
        # Context7 boost
        if [[ "$CONTEXT7_RELEVANT" == "true" ]]; then
            ADDITIONAL_CONTEXT+="  • Context7 documentation detected (+$CONTEXT7_SCORE_BOOST)\n"
        fi

        ADDITIONAL_CONTEXT+="\nRationale:\n"
        if [[ "$TIER" == "MEDIUM" ]]; then
            ADDITIONAL_CONTEXT+="  Plan agent orchestration with light intelligence.\n"
            ADDITIONAL_CONTEXT+="  Score 5-6 suggests multi-file changes requiring task coordination.\n"
        else
            ADDITIONAL_CONTEXT+="  Plan agent orchestration with full intelligence pipeline.\n"
            ADDITIONAL_CONTEXT+="  Score 7+ indicates complex work requiring comprehensive research and planning.\n"
        fi
        ADDITIONAL_CONTEXT+="\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    fi

    # [!!!] CRITICAL: Use tagging invocation syntax (not verbose Task() instructions)
    ADDITIONAL_CONTEXT+="${TIER} TIER: Plan Agent Orchestration\n"
    ADDITIONAL_CONTEXT+="═══════════════════════════════════════\n\n"
    ADDITIONAL_CONTEXT+="@\"plan-orchestrator (agent)\" - Decompose and delegate this task\n\n"
    ADDITIONAL_CONTEXT+="User Request: ${USER_PROMPT}\n\n"
    ADDITIONAL_CONTEXT+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

    # [!!!] Output valid UserPromptSubmit hook JSON
    jq -n --arg ctx "$ADDITIONAL_CONTEXT" --arg tier "$TIER" --arg score "$SCORE" --arg c7 "$CONTEXT7_RELEVANT" --arg c7s "$CONTEXT7_SCORE" \
      '{
        "hookSpecificOutput": {
          "hookEventName": "UserPromptSubmit",
          "additionalContext": $ctx,
          "metadata": {
            "tier": $tier,
            "complexity_score": ($score|tonumber),
            "plan_agent_active": true,
            "invocation_method": "tagging",
            "context7_relevant": ($c7=="true"),
            "context7_score": ($c7s|tonumber)
          }
        }
      }'
    exit 0
fi

# For LIGHT tier, continue with static workflow injection
[[ ! -f "$TIERED_WORKFLOW" ]] && { echo '{}'; exit 1; }

WORKFLOW=$(cat "$TIERED_WORKFLOW")
WORKFLOW="${WORKFLOW//\{\{TIER\}\}/$TIER}"

# Prepend routing explanation if enabled
if [[ "$ROUTING_EXPLANATION" == "ON" ]]; then
  EXPLANATION=$(generate_routing_explanation "$TIER" "$SCORE")
  WORKFLOW="${EXPLANATION}${WORKFLOW}"
fi

jq -n --arg w "$WORKFLOW" --arg t "$TIER" --arg s "$SCORE" --arg c7 "$CONTEXT7_RELEVANT" --arg c7s "$CONTEXT7_SCORE" \
  '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":$w,"metadata":{"complexity_score":($s|tonumber),"tier":$t,"context7_relevant":($c7=="true"),"context7_score":($c7s|tonumber)}}}'
