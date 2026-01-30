# Feature Flag Management

> **Back to [README](../TLDR-README.md)** | **Prev: [Profile System](05-profile-system.md)** | **Next: [Coverage Tracking](07-coverage-tracking.md)**

---

## Overview

The Feature Flag Detection System provides runtime feature gates for enabling and disabling agents and capabilities. All flags can be managed via the `/klaus feature` slash command or by editing `klaus-delegation.conf` directly.

---

## Slash Command: /klaus feature

```bash
/klaus feature <action> [flag_name]
```

### Available Actions

| Action | Description | Example |
|--------|-------------|---------|
| `list` | Show all flags and their current state | `/klaus feature list` |
| `toggle` | Toggle a flag ON/OFF | `/klaus feature toggle ENABLE_WEB_RESEARCHER` |
| `enable` | Set a flag to ON | `/klaus feature enable ENABLE_WEB_RESEARCHER` |
| `disable` | Set a flag to OFF | `/klaus feature disable ENABLE_WEB_RESEARCHER` |
| `check` | Check if a flag is enabled | `/klaus feature check ENABLE_WEB_RESEARCHER` |
| `get` | Get the current value of a flag | `/klaus feature get ENABLE_WEB_RESEARCHER` |
| `describe` | Get human-readable description | `/klaus feature describe ENABLE_WEB_RESEARCHER` |

---

## Registered Feature Flags

### Agent Flags

| Flag | Default | Controls |
|------|---------|----------|
| `ENABLE_WEB_RESEARCHER` | OFF | web-research-specialist agent |
| `ENABLE_DOCS_SPECIALIST` | ON | docs-specialist agent |
| `ENABLE_FILE_PATH_EXTRACTOR` | ON | file-path-extractor agent |
| `ENABLE_TEST_INFRASTRUCTURE` | OFF | test-infrastructure-agent |
| `ENABLE_REMINDER_SYSTEM` | OFF | reminder-nudger-agent |

### System Flags

| Flag | Default | Controls |
|------|---------|----------|
| `ENABLE_CONTEXT7_DETECTION` | ON | Context7 MCP integration |
| `ENABLE_ASYNC_HOOKS` | OFF | Non-blocking hook execution |
| `ENABLE_ROUTING_HISTORY` | OFF | Privacy-first routing telemetry |
| `ENABLE_GITHUB_ACTIONS` | OFF | CI/CD integration templates |
| `ENABLE_SUB_DELEGATION` | OFF | Agent sub-delegation capability |
| `ROUTING_EXPLANATION` | ON | Routing decision transparency |

---

## Feature Flag Registry

**Location**: `~/.claude/hooks/feature-flag-registry.sh` (274 lines)

### Characteristics

- **Bash 3 compatible** (no associative arrays, works on macOS default shell)
- **11 registered flags** with human-readable descriptions
- **Automatic backup** before modifications (timestamped `.backup` files)
- **Flag validation** against registry (prevents typos and invalid operations)
- **Value validation** (ON/OFF only)

### Available Functions

```bash
list_feature_flags()         # List all registered flags
get_flag_value()             # Get current value
set_flag_value()             # Set value (ON/OFF)
toggle_feature_flag()        # Toggle current value
enable_feature_flag()        # Set to ON
disable_feature_flag()       # Set to OFF
check_feature_enabled()      # Returns 0 if ON, 1 if OFF
get_flag_description()       # Human-readable description
```

### CLI Usage (Direct Script Execution)

```bash
# List all flags
bash ~/.claude/hooks/feature-flag-registry.sh list

# Toggle a flag
bash ~/.claude/hooks/feature-flag-registry.sh toggle ENABLE_WEB_RESEARCHER

# Check status
bash ~/.claude/hooks/feature-flag-registry.sh check ENABLE_WEB_RESEARCHER
```

---

## Safety Features

[1] **Automatic Backups**: Every modification creates a timestamped backup
```
~/.claude/klaus-delegation.conf.backup-20260127-143022
```

[2] **Flag Validation**: Only registered flags can be modified (prevents typos)

[3] **Value Validation**: Only ON/OFF values accepted

[4] **Syntax Protection**: Proper quoting enforced (e.g., `ENABLE_WEB_RESEARCHER="ON"`)

---

## Common Patterns

### Enable an Agent

```bash
# Via slash command
/klaus feature enable ENABLE_WEB_RESEARCHER

# Via config file
# Edit ~/.claude/klaus-delegation.conf
ENABLE_WEB_RESEARCHER="ON"
# Restart Claude Code
```

### Check Before Using

```bash
/klaus feature check ENABLE_TEST_INFRASTRUCTURE
# Output: ENABLE_TEST_INFRASTRUCTURE is currently: OFF
```

### List All Flags

```bash
/klaus feature list
# Shows all 11 flags with ON/OFF status
```

---

## Testing

- **Unit Tests**: 8 tests in `tests/unit/feature-flags.test.sh`
- **Integration Tests**: 3 tests in `tests/integration/feature-flag-integration.test.sh`
- **E2E Tests**: 4+ tests in `tests/e2e/feature-flags.test.sh`

---

## Related Documentation

- [Configuration & Keywords](04-configuration-keywords.md) - Where flags live in config
- [Profile System](05-profile-system.md) - Profile-based feature settings
- [Agent Team Reference](11-agent-team.md) - Agents controlled by flags
