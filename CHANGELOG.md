**Append changes to the changelog file below this line**
---

**1.0.3** | **Feb. 2nd, 2026**

- fixed README.md doc links from docs/ to klaus-baudelaire/docs/
- added implementer agent to README agent list (18 agents total)
- added explore-light discovery-only designation to README
- added new feature flag categories to README Configuration section
- optimized docs/06-feature-flags.md with CORE, OPTIONAL, UTILITY, RLM flag categories (16 flags)
- added Discovery vs Implementation Separation section to docs/02-delegation-architecture.md

---



---

**1.0.2** | **Feb. 2nd, 2026**

- added feature flags for all 18 agents organized into CORE, OPTIONAL, UTILITY, and RLM categories
- added ENABLE_CODE_SIMPLIFIER, ENABLE_COMPOSTER, ENABLE_GIT_ORCHESTRATOR, ENABLE_RLM_AGENTS flags
- optimized flag organization: CORE agents (implementer, docs-specialist, file-path-extractor) marked essential

---

**1.0.1** | **Feb. 2nd, 2026**

- added implementer agent (Sonnet model) for quality code implementation after discovery phase
- fixed explore-light to be discovery-only by removing Edit/Write tools
- added Phase 4.5: Implementation Delegation to plan-orchestrator workflow
- added ENABLE_IMPLEMENTER feature flag (ON by default) to klaus-delegation.conf
- optimized agent hierarchy: discovery agents (Haiku) gather context, implementer agents (Sonnet) write code
- added deterministic invocation syntax for parallel/sequential implementer execution

---

**1.0.0** | **Jan. 29th, 2026**

- feature plugin release

---

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
