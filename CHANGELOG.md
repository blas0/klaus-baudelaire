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

**1.0.6** | **Feb. 1st, 2026**

- fixed [P0] Word boundary regex in SIMPLE_KEYWORDS - prevents "adjust" matching "just" false positives
- added [P1] UI/feature detection keywords: cursor positioning, toggle/switch/button, mirror/sync
- added [P2] Multi-feature detection - bullet point counting adds +2 score when 3+ items detected
- added [P3] Delegation enforcement instructions injected into MEDIUM/FULL tier routing context
- added tests/verify-audit-fixes.sh and tests/audit-fixes-test.sh for P0-P3 validation

---

**1.0.5** | **Jan. 30th, 2026**

- fixed [P0] Agent resume interruption - replaced with RETURN-TO-PARENT pattern for plan approval
- added [EXECUTE_APPROVED_PLAN] marker for execution mode detection in plan-orchestrator
- added Parent Approval Handling Instructions injection in MEDIUM/FULL tier additionalContext
- fixed [P3] Task-notification scoring skip - subagent communication no longer triggers routing
- fixed test path errors in klaus-delegation-hook.test.sh for config and restore operations

---

**1.0.4** | **Jan. 30th, 2026**

- feature Phase 1.5 User Approval Checkpoint added to plan-orchestrator workflow
- added AskUserQuestion integration for plan review before execution
- added revision cycle support with max 3 iterations before forcing proceed/abandon
- added structured plan display format showing tasks, agents, dependencies
- optimized user control over agent delegation with APPROVE/NO flow

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
