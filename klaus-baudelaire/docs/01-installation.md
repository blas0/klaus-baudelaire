# Installation & Setup

> **Back to [README](../TLDR-README.md)** | **Next: [Delegation Architecture](02-delegation-architecture.md)**

---

## Overview

Klaus can be installed as a **plugin** (recommended for version control and updates) or **standalone** (simpler for single projects).

---

## Option 1: Plugin Installation (Recommended)

**Advantages**: Semantic versioning, one-command updates, namespace isolation, marketplace distribution.

```bash
# [1] Add Klaus marketplace
/plugin marketplace add https://github.com/blas0/klaus-baudelaire

# [2] Install Klaus plugin (auto-installs commands & agents)
/plugin install klaus-system@klaus-marketplace

# [3] Configure UserPromptSubmit hook (required workaround for bug #10225)
~/.local/share/claude/plugins/klaus-system/install.sh

# [4] Restart Claude Code
# Exit and restart your Claude Code session
```

> [!] Step 3 is required until Claude Code fixes plugin hook execution bug [#10225](https://github.com/anthropics/claude-code/issues/10225). The install script safely adds Klaus's delegation hook to your `settings.json`.

**Updating Klaus**:

```bash
/plugin marketplace update
/plugin update klaus-system
```

---

## Option 2: Standalone Installation

**Advantages**: Shorter command names, no plugin dependencies, simpler setup.

```bash
# [1] Clone Klaus to ~/.claude
git clone https://github.com/blas0/klaus-baudelaire ~/.claude

# [2] Configure UserPromptSubmit hook
~/.claude/install.sh

# [3] Restart Claude Code
# Exit and restart your Claude Code session
```

**Updating Klaus**:

```bash
cd ~/.claude
git pull origin main
```

---

## Post-Installation

### Verify Installation

```bash
# Run unit tests (validates installed system)
bash ~/.claude/tests/unit-tests.sh

# Run integration tests (validates prompt routing)
bun ~/.claude/tests/integration-tests.ts

# Initialize project memory (recommended for new projects)
/fillmemory
```

### Available Commands

After installation, Klaus registers these slash commands:

| Command | Plugin Prefix | Purpose |
|---------|---------------|---------|
| `/klaus` | `/klaus:klaus` | Force FULL tier execution for any prompt |
| `/fillmemory` | `/klaus:fillmemory` | Initialize project documentation |
| `/compost` | `/klaus:compost` | Extract codebase patterns |
| `/updatememory` | `/klaus:updatememory` | Sync documentation with code |
| `/klaus feature` | `/klaus:feature` | Manage feature flags |
| `/suggestkeywords` | `/klaus:suggestkeywords` | Analyze routing telemetry |
| `/klaus-test` | `/klaus:klaus-test` | System diagnostics |

### Troubleshooting Installation

- **Klaus not routing tasks**: Verify `~/.claude/settings.json` contains the UserPromptSubmit hook
- **Hook execution failing**: Known bug [#10225](https://github.com/anthropics/claude-code/issues/10225) - use `install.sh` to configure manually
- **Check debug output**: Set `DEBUG_MODE="ON"` in `~/.claude/klaus-delegation.conf`
- **Run diagnostics**: `/klaus-test`

For detailed troubleshooting, see [Troubleshooting Guide](15-troubleshooting.md).

---

## File Locations

After installation, Klaus places files at:

```
~/.claude/
  hooks/
    klaus-delegation.sh           # Routing logic
    tiered-workflow.txt           # Workflow templates
    feature-flag-registry.sh      # Feature flag management
    klaus-session-state.sh        # Session state (async)
    routing-telemetry.sh          # Telemetry tracking
  agents/
    plan-orchestrator.md          # Plan agent
    docs-specialist.md            # Documentation specialist
    web-research-specialist.md    # Web researcher
    file-path-extractor.md        # File path tracker
    test-infrastructure-agent.md  # Test architect
    reminder-nudger-agent.md      # Progress monitor
    explore-light.md              # Quick explorer
    research-lead.md              # Research coordinator
    research-light.md             # Quick researcher
    code-simplifier.md            # Code simplifier
    composter.md                  # Pattern extractor
    git-orchestrator.md           # Git operations
  commands/
    klaus.md                      # /klaus command
    fillmemory.md                 # /fillmemory command
    compost.md                    # /compost command
    updatememory.md               # /updatememory command
    feature.md                    # /feature command
    suggestkeywords.md            # /suggestkeywords command
    klaus-test.md                 # /klaus-test command
  config/
    klaus-profiles.conf           # Profile configurations
  tests/
    unit-tests.sh                 # Scoring/config validation
    integration-tests.sh          # Prompt routing (Bash)
    integration-tests.ts          # Prompt routing (Bun)
    README.md                     # Test documentation
  klaus-delegation.conf           # Primary configuration
```

---

## Version History

See [CHANGELOG.md](../CHANGELOG.md) for complete version history.
