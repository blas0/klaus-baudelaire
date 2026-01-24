# Changelog

All notable changes to Klaus System will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-23

### Added
- **Commands**
  - `/fillmemory` - Initialize project documentation structure
  - `/compost` - Extract and document project-specific standards and patterns
  - `/updatememory` - Sync project documentation with codebase reality

- **Agents**
  - `web-research-specialist.md` - Dedicated web research with documentation lookup
  - `file-path-extractor.md` - Extract file paths from bash output for context tracking
  - `test-infrastructure-agent.md` - Setup and manage test infrastructure
  - `reminder-nudger-agent.md` - Monitor progress and provide strategic guidance
  - `explore-light.md` - Quick codebase exploration agent
  - `research-lead.md` - Comprehensive research coordination with subagents
  - `research-light.md` - Quick web lookup without spawning subagents
  - `code-simplifier.md` - Simplify and refine code for clarity
  - `composter.md` - Extract and document project patterns

- **Hooks**
  - `klaus-delegation.sh` - Smart task routing with tiered workflow system
  - `tiered-workflow.txt` - Workflow templates for LIGHT/MEDIUM/FULL tiers
  - `hooks.json` - Hook configuration for plugin system (manual setup still required)

- **Configuration**
  - `klaus-delegation.conf` - Configurable scoring thresholds and keywords
  - `test-klaus-delegation.sh` - Comprehensive test suite

- **Plugin Infrastructure**
  - Plugin manifest with semantic versioning
  - Marketplace catalog for distribution
  - Installation script for hook configuration
  - Support for ${CLAUDE_PLUGIN_ROOT} variable

### Known Issues
- **UserPromptSubmit Hook**: Plugin hooks require manual configuration due to bugs [#10225](https://github.com/anthropics/claude-code/issues/10225) (hook execution) and [#12151](https://github.com/anthropics/claude-code/issues/12151) (output not captured - STILL OPEN as of January 2026). The `install.sh` script configures hooks in `settings.json` as a workaround. Even when hooks execute successfully, their output may not be properly injected into agent context.

### Installation
See README.md for complete installation instructions. Quick start:

```bash
# If installing as plugin
/plugin marketplace add https://github.com/user/klaus-marketplace
/plugin install klaus-system@klaus-marketplace
~/.local/share/claude/plugins/klaus-system/install.sh

# If installing standalone
git clone https://github.com/user/klaus-system ~/.claude
~/.claude/install.sh
```

### Documentation
- Comprehensive README with architecture overview
- Hook system documentation
- Agent usage examples
- Configuration reference
- Testing guide

[1.0.0]: https://github.com/user/klaus-system/releases/tag/v1.0.0
