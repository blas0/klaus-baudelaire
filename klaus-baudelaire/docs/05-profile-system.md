# Profile System

> **Back to [README](../TLDR-README.md)** | **Prev: [Configuration & Keywords](04-configuration-keywords.md)** | **Next: [Feature Flags](06-feature-flags.md)**

---

## Overview

The Delegation Profile System provides configurable routing behavior profiles that adjust tier thresholds and keyword weights. Three preset profiles allow you to control how aggressively Klaus delegates tasks.

---

## Profiles

### Conservative

Fewer delegations, lower cost. Best for stable codebases or cost-sensitive environments.

| Setting | Value |
|---------|-------|
| TIER_MEDIUM_MIN | 7 |
| TIER_FULL_MIN | 12 |
| Impact | ~40% fewer Plan invocations vs balanced |

### Balanced (Default)

Standard routing behavior. Recommended starting point.

| Setting | Value |
|---------|-------|
| TIER_MEDIUM_MIN | 5 |
| TIER_FULL_MIN | 7 |
| Impact | Baseline behavior |

### Aggressive

More delegations, faster intelligence gathering. Best for greenfield projects or complex feature development.

| Setting | Value |
|---------|-------|
| TIER_MEDIUM_MIN | 3 |
| TIER_FULL_MIN | 8 |
| Impact | ~60% more Plan invocations vs balanced |

---

## Configuration

**Location**: `~/.claude/config/klaus-profiles.conf`

**Format**: Git-style configuration with `[profile "name"]` sections.

```ini
[profile "conservative"]
  tier_light_min = 5
  tier_medium_min = 7
  tier_full_min = 12
  weight_system = 2
  weight_implement = 1
  weight_refactor = 1
  weight_across_multiple = 1
  enable_plan_orchestration = true
  enable_routing_explanation = true

[profile "balanced"]
  tier_light_min = 3
  tier_medium_min = 5
  tier_full_min = 7
  weight_system = 2
  weight_implement = 1
  weight_refactor = 2
  weight_across_multiple = 2
  enable_plan_orchestration = true
  enable_routing_explanation = true

[profile "aggressive"]
  tier_light_min = 2
  tier_medium_min = 3
  tier_full_min = 8
  weight_system = 3
  weight_implement = 2
  weight_refactor = 3
  weight_across_multiple = 3
  enable_plan_orchestration = true
  enable_routing_explanation = true
```

---

## How to Switch Profiles

### Method 1: Environment Variable (Highest Priority)

```bash
export KLAUS_PROFILE=aggressive
claude
```

### Method 2: Repository Config File

Create a `.klaus-profile` file in your repository root:

```bash
echo "conservative" > .klaus-profile
```

Klaus auto-detects this file when starting a session in that repository.

### Method 3: Default Fallback

If neither environment variable nor `.klaus-profile` file exists, Klaus uses `balanced`.

### Priority Order

```
[1] KLAUS_PROFILE environment variable (highest)
[2] .klaus-profile file in repository root
[3] "balanced" default (lowest)
```

---

## Profile Loader

The profile loader is integrated into `hooks/klaus-delegation.sh`:

- `load_profile()` - Parses `klaus-profiles.conf`, extracts profile sections, validates thresholds
- `detect_and_load_profile()` - Auto-detection with priority order
- Profile overrides applied **after** config file sourcing
- Threshold validation: Checks monotonicity (LIGHT <= MEDIUM <= FULL)

**Validation Rules**:
- Thresholds must be monotonically increasing (LIGHT <= MEDIUM <= FULL)
- All values must be positive integers
- Invalid profiles fall back to `balanced`

---

## Testing

**Unit Tests** (12 tests in `tests/unit/profile-loader.test.sh`):
- Profile threshold loading for all 3 profiles
- Keyword weight adjustments
- `.klaus-profile` file auto-detection
- `KLAUS_PROFILE` env var override priority
- Invalid profile fallback to balanced
- Whitespace handling in `.klaus-profile` file

**Integration Tests** (16 tests in `tests/integration/profile-migration.test.sh`):
- Profile config migration to `~/.claude/`
- Hook-profile integration after migration
- All three profiles working after migration

---

## Related Documentation

- [Configuration & Keywords](04-configuration-keywords.md) - Base configuration
- [Scoring Algorithm](03-scoring-algorithm.md) - How profiles affect scoring
- [Feature Flags](06-feature-flags.md) - Runtime feature management
