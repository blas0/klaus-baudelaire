# Scoring Algorithm

> **Back to [README](../TLDR-README.md)** | **Prev: [Delegation Architecture](02-delegation-architecture.md)** | **Next: [Configuration & Keywords](04-configuration-keywords.md)**

---

## Overview

Klaus analyzes prompts like a librarian categorizing books by complexity. He uses a weighted system based on prompt characteristics to calculate a score that determines the execution tier.

---

## File Locations

| File | Purpose |
|------|---------|
| `~/.claude/hooks/klaus-delegation.sh` | Hook script (scoring logic) |
| `~/.claude/klaus-delegation.conf` | Configuration (keywords, thresholds) |
| `~/.claude/hooks/tiered-workflow.txt` | Workflow templates |

---

## How Klaus Analyzes Prompts

### Step 1: Hook Trigger (UserPromptSubmit)

When you submit a prompt, Claude Code invokes all UserPromptSubmit hooks. Klaus receives JSON via stdin:

```json
{
  "prompt": "Set up OAuth authentication with tests"
}
```

### Step 2: Skip Conditions

Klaus skips analysis if:
- `SMART_DELEGATE_MODE="OFF"` in config
- Prompt starts with `/` (slash commands bypass routing)
- Prompt length < 30 characters (too short to analyze)

When skipped, Klaus returns: `{}`

### Step 3: Scoring Logic

**Phase 1: Length-based scoring**

```bash
[[ $PROMPT_LENGTH -gt 100 ]] && ((SCORE += 1))
[[ $PROMPT_LENGTH -gt 200 ]] && ((SCORE += 1))
[[ $PROMPT_LENGTH -gt 400 ]] && ((SCORE += 2))
```

**Phase 2: Convert to lowercase** (case-insensitive matching)

```bash
LOWER_PROMPT=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')
```

**Phase 3: COMPLEX_KEYWORDS (add points)**

```bash
for entry in "${COMPLEX_KEYWORDS[@]}"; do
  pattern="${entry%:*}"     # Extract pattern (before colon)
  weight="${entry#*:}"      # Extract weight (after colon)
  if echo "$LOWER_PROMPT" | grep -qE "($pattern)"; then
    ((SCORE += weight))
  fi
done
```

**Phase 4: SIMPLE_KEYWORDS (subtract points)**

```bash
for entry in "${SIMPLE_KEYWORDS[@]}"; do
  pattern="${entry%:*}"
  weight="${entry#*:}"
  if echo "$LOWER_PROMPT" | grep -qE "($pattern)"; then
    ((SCORE -= weight))
  fi
done
```

**Phase 5: Apply bounds**

```bash
[[ $SCORE -lt 0 ]] && SCORE=0    # Floor at 0
[[ $SCORE -gt 50 ]] && SCORE=50  # Cap at 50
```

### Step 4: Tier Determination

```bash
if [[ $SCORE -lt $TIER_LIGHT_MIN ]]; then TIER="DIRECT"      # 0-2
elif [[ $SCORE -lt $TIER_MEDIUM_MIN ]]; then TIER="LIGHT"    # 3-4
elif [[ $SCORE -lt $TIER_FULL_MIN ]]; then TIER="MEDIUM"     # 5-6
else TIER="FULL"; fi                                          # 7+
```

### Step 5: Output

**For DIRECT tier** (0-2):

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "",
    "metadata": {
      "score": 0,
      "tier": "DIRECT"
    }
  }
}
```

**For LIGHT/MEDIUM/FULL** (3+):

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "[WORKFLOW CONTENT WITH {{TIER}} REPLACED]",
    "metadata": {
      "score": 7,
      "tier": "FULL"
    }
  }
}
```

---

## Example Walkthrough

**Prompt**: "Set up OAuth authentication with tests"

1. **Length check**: 43 chars (no length bonus)
2. **Lowercase**: "set up oauth authentication with tests"
3. **COMPLEX_KEYWORDS**:
   - `"set up tests|test infrastructure:3"` matches "set up...tests" = +3
   - `"oauth|authentication.*provider|authorization:2"` matches "oauth" = +2
4. **SIMPLE_KEYWORDS**: No matches
5. **Bounds**: Score = 5 (within 0-50 range)
6. **Tier**: Score 5 >= TIER_MEDIUM_MIN (5) and < TIER_FULL_MIN (7) = **MEDIUM**

---

## Score Summary

```
Score = 0
+ Length bonuses (>100: +1, >200: +1, >400: +2)
+ COMPLEX_KEYWORDS matches (x weight per pattern)
- SIMPLE_KEYWORDS matches (x weight per pattern)
= Final score (bounded 0-50)
```

| Score Range | Tier | Response |
|-------------|------|----------|
| 0-2 | DIRECT | Execute immediately, no coordination |
| 3-4 | LIGHT | Quick reconnaissance with explore-light |
| 5-6 | MEDIUM | Intelligence team with plan-orchestrator |
| 7+ | FULL | Full research committee with all agents |

---

## Routing Transparency

When `ROUTING_EXPLANATION="ON"` (default), Klaus includes an explanation of its routing decision:

```
[*] ROUTING DECISION
Score: 7 | Tier: FULL
Matched patterns: oauth, set up tests
Rationale: Complex task requiring research and multi-agent coordination
```

---

## Related Documentation

- [Configuration & Keywords](04-configuration-keywords.md) - Customize keywords and thresholds
- [Profile System](05-profile-system.md) - Adjust scoring behavior by profile
- [Delegation Architecture](02-delegation-architecture.md) - What happens after scoring
