# Installation & Setup

> **Back to [README](../TLDR-README.md)** | **Next: [Delegation Architecture](02-delegation-architecture.md)**

---

## Overview

Klaus can be installed from **any directory** - clone it wherever you want, then run the installer. The installer:
- **Backs up** your existing `~/.claude` automatically
- **Merges** Klaus components without destroying your customizations
- **Preserves** your CLAUDE.md, settings.json hooks, and config files

---

## Standard Installation (Recommended)

```bash
# [1] Clone Klaus anywhere you want
git clone https://github.com/blas0/klaus-baudelaire ~/klaus-baudelaire
# Or clone to any location:
# git clone https://github.com/blas0/klaus-baudelaire /opt/klaus
# git clone https://github.com/blas0/klaus-baudelaire ~/projects/klaus

# [2] Run the installer
~/klaus-baudelaire/.system/install.sh

# [3] Restart Claude Code
# Exit and restart your Claude Code session

# [4] Verify installation
/klaus-test
```

> [!] The installer automatically detects where it's run from and installs to `~/.claude`. Your existing `~/.claude` is backed up to `~/.claude-backups/` before any changes.

---

## Installation Options

### Preview Mode (Dry Run)

See what will be installed without making changes:

```bash
~/klaus-baudelaire/.system/install.sh --dry-run --verbose
```

### Custom Target Directory

Install to a different location:

```bash
~/klaus-baudelaire/.system/install.sh --target=/custom/path
```

### Fresh Install (No Existing ~/.claude)

For users without an existing `~/.claude`:

```bash
~/klaus-baudelaire/.system/install.sh --mode=standalone
```

> [!] Standalone mode will fail if `~/.claude` already exists. This is intentional - use the default append mode for existing installations.

### Skip Backup

If you don't need automatic backup:

```bash
~/klaus-baudelaire/.system/install.sh --no-backup
```

---

## What Gets Installed

The installer copies these Klaus components to `~/.claude`:

```
~/.claude/
  hooks/                          # Klaus hooks
    klaus-delegation.sh           # Main routing logic
    tiered-workflow.txt           # Workflow templates
    feature-flag-registry.sh      # Feature flag management
    klaus-session-state.sh        # Session state (async)
    routing-telemetry.sh          # Telemetry tracking
    analyze-routing-accuracy.sh   # Accuracy analysis
    recursive-agent-trigger.sh    # RLM triggers
    rlm-workflow-coordinator.sh   # RLM coordination
    hooks.json                    # Plugin hook registration
  agents/                         # Klaus agents (17 total)
    plan-orchestrator.md
    docs-specialist.md
    web-research-specialist.md
    explore-lead.md
    explore-light.md
    research-lead.md
    research-light.md
    ... (and more)
  commands/                       # Klaus slash commands
    klaus.md
    fillmemory.md
    compost.md
    updatememory.md
    feature.md
    suggestkeywords.md
    klaus-test.md
  config/                         # Klaus configuration
    klaus-delegation.conf
    klaus-profiles.conf
    recursive-agent-config.yaml
  .claude-plugin/                 # Plugin metadata
    plugin.json
    marketplace.json
```

---

## What Gets Preserved

The installer **NEVER overwrites**:

| File | Behavior |
|------|----------|
| `~/.claude/CLAUDE.md` | Preserved (your personal instructions) |
| `~/.claude/settings.json` | **Merged** (Klaus hook is appended to existing hooks) |
| `~/.claude/config/klaus-delegation.conf` | Preserved if exists (your customizations) |
| `~/.claude/config/klaus-profiles.conf` | Preserved if exists |

---

## Backup & Recovery

### Automatic Backups

Every installation creates a timestamped backup:

```
~/.claude-backups/
  claude-backup-20250130_143022/  # Full backup of ~/.claude
  claude-backup-20250129_091544/  # Previous backup
```

The installer keeps the 5 most recent backups and removes older ones.

### Manual Recovery

To restore from backup:

```bash
# List available backups
ls -la ~/.claude-backups/

# Restore a specific backup
rm -rf ~/.claude
cp -rp ~/.claude-backups/claude-backup-YYYYMMDD_HHMMSS ~/.claude
```

---

## Plugin Installation (Alternative)

For users who prefer the plugin system:

```bash
# [1] Add Klaus marketplace
/plugin marketplace add https://github.com/blas0/klaus-baudelaire

# [2] Install Klaus plugin
/plugin install klaus-baudelaire@klaus-marketplace

# [3] Configure hook (required workaround for bug #10225)
~/.local/share/claude/plugins/klaus-baudelaire/.system/install.sh --mode=plugin

# [4] Restart Claude Code
```

> [!] The `--mode=plugin` flag tells the installer to configure hooks for the plugin location instead of `~/.claude`.

**Updating via plugin:**

```bash
/plugin marketplace update
/plugin update klaus-baudelaire
```

---

## Post-Installation

### Verify Installation

```bash
# Quick test
/klaus-test

# Full test suite (from clone directory)
bash ~/klaus-baudelaire/tests/unit-tests.sh
bash ~/klaus-baudelaire/tests/hooks-suite.sh
```

### Initialize Project Memory

For new projects, initialize the memory structure:

```bash
/fillmemory
```

### Available Commands

After installation:

| Command | Purpose |
|---------|---------|
| `/klaus <prompt>` | Force FULL tier execution |
| `/klaus feature` | Manage feature flags |
| `/fillmemory` | Initialize project documentation |
| `/compost` | Extract codebase patterns |
| `/updatememory` | Sync documentation with code |
| `/suggestkeywords` | Analyze routing telemetry |
| `/klaus-test` | System diagnostics |

---

## Troubleshooting

### Klaus not routing tasks

1. Check hook is configured:
```bash
grep "klaus-delegation" ~/.claude/settings.json
```

2. Re-run installer:
```bash
~/klaus-baudelaire/.system/install.sh
```

### Hook execution failing

This is often due to Claude Code bug [#10225](https://github.com/anthropics/claude-code/issues/10225). The installer configures the hook manually to work around this.

### Installation failed

Check the install script location:
```bash
ls -la ~/klaus-baudelaire/.system/install.sh
```

Run with verbose output:
```bash
~/klaus-baudelaire/.system/install.sh --verbose
```

### Restore from backup

```bash
ls ~/.claude-backups/
cp -rp ~/.claude-backups/claude-backup-LATEST ~/.claude
```

For detailed troubleshooting, see [Troubleshooting Guide](15-troubleshooting.md).

---

## Uninstalling Klaus

To remove Klaus components while preserving your settings:

```bash
# Remove Klaus hooks (keep your other hooks)
rm ~/.claude/hooks/klaus-*.sh
rm ~/.claude/hooks/tiered-workflow.txt
rm ~/.claude/hooks/feature-flag-registry.sh
rm ~/.claude/hooks/routing-telemetry.sh
rm ~/.claude/hooks/analyze-routing-accuracy.sh
rm ~/.claude/hooks/recursive-agent-trigger.sh
rm ~/.claude/hooks/rlm-workflow-coordinator.sh

# Remove Klaus agents
rm ~/.claude/agents/plan-orchestrator.md
rm ~/.claude/agents/docs-specialist.md
# ... (remove other Klaus agents)

# Remove Klaus commands
rm ~/.claude/commands/klaus.md
rm ~/.claude/commands/fillmemory.md
# ... (remove other Klaus commands)

# Remove Klaus config
rm ~/.claude/config/klaus-*.conf
rm ~/.claude/config/recursive-agent-config.yaml

# Manually edit settings.json to remove Klaus hook
```

Or restore from a pre-installation backup:
```bash
rm -rf ~/.claude
cp -rp ~/.claude-backups/claude-backup-BEFORE_KLAUS ~/.claude
```

---

## Version History

See [CHANGELOG.md](../CHANGELOG.md) for complete version history.
