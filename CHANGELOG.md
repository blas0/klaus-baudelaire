### EXPLICIT CHANGELOG INSTRUCTIONS

All notable changes to the Klaus Baudelaire plugin will be documented in this file.

**Format changes by following this template:**

**Flags: `fixed`, `added`, `optimized`, `removed`, `feature`**

**Versioning: Linear versioning (ex. 1.0.0 -> 1.0.1 -> 1.0.2 -> ...)**

```
**<version>** | **<date>**

- <flag> <description of modification in 20 words or less>
- <flag> <description of modification in 20 words or less>
- <flag> <description of modification in 20 words or less>
- <flag> <description of modification in 20 words or less>

---

```

```
---

**1.0.0** | **Jan. 28th, 2026**

- fixed bug in login functionality
- added support for multiple languages
- optimized performance by 20%
- removed redundant feature within user dashboard

---
```

---

**Append changes to the changelog file below this line**

---

**1.0.1** | **Jan. 30th, 2026**

- fixed install.sh now supports clone-anywhere installation with automatic source detection
- added timestamped backup system to ~/.claude-backups/ before installation
- added settings.json hook merging (appends to existing hooks instead of replacing)
- added --mode, --target, --dry-run, --verbose, --no-backup flags to install.sh
- optimized installation preserves user's CLAUDE.md and existing config files
- fixed README.md installation instructions to show clone-anywhere approach
- fixed docs/01-installation.md with comprehensive guide and uninstallation steps

---

**1.0.3** | **Jan. 30th, 2026**

- added MANDATORY plan-orchestrator invocation for `/klaus` commands (no longer advisory)
- added KLAUS_COMMAND detection flag with forced FULL tier routing override
- added mandatory directive language in additionalContext for `/klaus` requests
- added `klaus_command` and `invocation_method: "mandatory"` metadata fields

---

**1.0.2** | **Jan. 30th, 2026**

- fixed slash command early-exit bug in klaus-delegation.sh line 175
- fixed `/klaus` commands now properly trigger FULL tier routing and plan-orchestrator invocation
- added explicit allowlist pattern `^/klaus[[:space:]]` to bypass slash command skip check

---

**1.0.0** | **Jan. 29th, 2026**

- feature plugin release

---
