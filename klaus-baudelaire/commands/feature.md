---
name: feature
description: Manage Klaus Baudelaire feature flags at runtime
args:
  - name: action
    description: "Action to perform: list, toggle, check, enable, disable, get, describe"
    required: true
  - name: flag_name
    description: "Flag name (required for toggle/check/enable/disable/get/describe actions)"
    required: false
---

# Klaus Feature Flag Management

Manages Klaus Baudelaire feature flags at runtime without editing configuration files.

## Available Actions

### list
List all feature flags with their current status and descriptions.

```bash
/klaus feature list
```

Example output:
```
FLAG NAME                           STATUS     DESCRIPTION
===================================  ==========  ==================================================
ENABLE_CONTEXT7_DETECTION           OFF         Library/framework detection
ENABLE_DOCS_SPECIALIST              ON          docs-specialist agent
ENABLE_FILE_PATH_EXTRACTOR          ON          File path extraction from bash output
ENABLE_REMINDER_SYSTEM              OFF         Reminder nudger agent
ENABLE_ROUTING_HISTORY              OFF         Routing outcome tracking telemetry
ENABLE_TEST_INFRASTRUCTURE          OFF         Test infrastructure setup agent
ENABLE_WEB_RESEARCHER               OFF         Web research specialist agent
ROUTING_EXPLANATION                 ON          Show routing decision rationale
```

### toggle
Toggle a feature flag between ON and OFF.

```bash
/klaus feature toggle ENABLE_WEB_RESEARCHER
```

### enable
Enable a feature flag (set to ON).

```bash
/klaus feature enable ENABLE_CONTEXT7_DETECTION
```

### disable
Disable a feature flag (set to OFF).

```bash
/klaus feature disable ENABLE_REMINDER_SYSTEM
```

### check
Check if a feature flag is enabled. Returns status and exit code.

```bash
/klaus feature check ROUTING_EXPLANATION
```

### get
Get the current value of a feature flag.

```bash
/klaus feature get ENABLE_FILE_PATH_EXTRACTOR
```

### describe
Get the human-readable description of a feature flag.

```bash
/klaus feature describe ENABLE_WEB_RESEARCHER
```

## Feature Flags

### Agent Flags

- **ENABLE_WEB_RESEARCHER**: Web research specialist agent for deep research tasks
- **ENABLE_FILE_PATH_EXTRACTOR**: File path extraction from bash command output
- **ENABLE_TEST_INFRASTRUCTURE**: Test infrastructure setup agent
- **ENABLE_REMINDER_SYSTEM**: Reminder nudger agent for progress monitoring

### System Flags

- **ENABLE_CONTEXT7_DETECTION**: Library/framework detection and documentation lookup
- **ENABLE_ASYNC_HOOKS**: Async hook execution (Phase 1)
- **ENABLE_ROUTING_HISTORY**: Routing outcome tracking telemetry (privacy: opt-in)
- **ENABLE_GITHUB_ACTIONS**: GitHub Actions CI/CD integration
- **ENABLE_SUB_DELEGATION**: Sub-delegation to specialized agents
- **ROUTING_EXPLANATION**: Show routing decision rationale in output

## Safety Features

All flag modifications:
- Create automatic backups before changes
- Validate flag names against registry
- Validate values (ON or OFF only)
- Preserve comments and formatting where possible

## Implementation

This command executes the feature-flag-registry.sh script:

```bash
bash ~/.claude/hooks/feature-flag-registry.sh <action> [flag_name]
```

## Examples

```bash
# See all available flags
/klaus feature list

# Enable web research specialist
/klaus feature enable ENABLE_WEB_RESEARCHER

# Toggle routing explanation on/off
/klaus feature toggle ROUTING_EXPLANATION

# Check if Context7 detection is enabled
/klaus feature check ENABLE_CONTEXT7_DETECTION

# Get current value of file path extractor
/klaus feature get ENABLE_FILE_PATH_EXTRACTOR

# Describe what a flag does
/klaus feature describe ENABLE_REMINDER_SYSTEM
```

## Notes

- Changes take effect immediately for new sessions
- Existing sessions may need restart to reflect changes
- Backup files are created automatically in the same directory
- Flag names are case-sensitive and must match exactly
