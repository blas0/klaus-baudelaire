# Changelog

All notable changes to Klaus Baudelaire will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.6] - 2026-02-04

### Changed
- **Centralized Task Ownership Architecture** - Root cause fix for orphaned pending tasks
  - Task state management now centralized to 3 orchestrator agents only
  - Workers return results via structured `=== TASK RESULTS ===` response format
  - Orchestrators parse responses and handle all TaskUpdate calls

### Architecture

**Orchestrators (KEEP Task* tools):**
| Agent | Tools |
|-------|-------|
| plan-orchestrator | TaskCreate, TaskUpdate, TaskGet, TaskList |
| recursive-agent | TaskCreate, TaskUpdate, TaskGet, TaskList |
| research-lead | TaskCreate, TaskUpdate, TaskList |

**Workers (REMOVED Task* tools):**
| Agent | Removed Tools |
|-------|---------------|
| implementer | TaskUpdate, TaskGet, TaskList |
| explore-lead | TaskUpdate, TaskGet, TaskList |
| docs-specialist | TaskUpdate, TaskGet, TaskList |
| web-research-specialist | TaskUpdate, TaskGet, TaskList |
| context-validator | TaskUpdate, TaskGet, TaskList |
| code-simplifier | TaskUpdate, TaskGet, TaskList |
| test-infrastructure-agent | TaskUpdate, TaskGet, TaskList |
| file-path-extractor | TaskUpdate, TaskGet, TaskList |
| git-orchestrator | TaskUpdate, TaskGet, TaskList |
| composter | TaskUpdate, TaskList |
| chunk-analyzer | TaskUpdate |
| synthesis-agent | TaskUpdate, TaskGet, TaskList |
| conflict-resolver | TaskUpdate, TaskGet, TaskList |

**Monitor (READ-ONLY - unchanged):**
| Agent | Tools |
|-------|-------|
| reminder-nudger-agent | TaskList, TaskGet |

### Worker Response Format

Workers now return results in structured text:
```
=== TASK RESULTS ===
Status: SUCCESS | PARTIAL | FAILED
Summary: [1-2 sentence summary]

Files Affected:
- path/to/file1.ts

Findings:
- [Finding 1]

Recommendations:
- [Recommendation 1]
=== END RESULTS ===
```

### Fixed
- Root cause: 12 tasks (#13-24) remained pending despite work completion
- Issue: Distributed task ownership created coordination gaps
- Solution: Orchestrators own all task state; workers just return results

### Documentation
- Updated `docs/11-agent-team.md` with new task tool distribution
- Updated `docs/12-task-management.md` with centralized ownership model

### Notes
- Net task state owners: 16 -> 3 (orchestrators only)
- Coordination gap risk eliminated by design
- Workers no longer need to remember TaskUpdate calls

---

## [1.0.5] - 2026-02-03

### Added
- **Implementer Safety Protocols** - Hardening based on LOGANALYSIS.md recommendations
  - Safe File Writing Protocol: Detects `${}` template literals, routes to Write tool (R-003)
  - Directory Preparation Protocol: Ensures `mkdir -p` before file creation (R-006)
  - Pre-Build Type Verification: Runs `bun tsc --noEmit` after .tsx modifications (R-004)
  - Completion Verification Protocol: Confirms files exist before TaskUpdate(completed) (R-005)
  - TypeScript Best Practices: Prefers `React.ReactNode` over `JSX.Element` (R-010)

- **dev-server-guard.sh** - New PreToolUse hook for Bash tool (R-002)
  - Detects existing dev server processes before allowing new ones
  - Checks common ports (3000, 3001, 5173, 8080, 4321, 5000, 8000)
  - Checks lock files (.next/dev/lock, .vite/dev)
  - Non-blocking warning with recovery options

- **file-lock-coordinator.sh** - New PreToolUse/PostToolUse hook for Write/Edit (R-009)
  - Prevents parallel file write collisions
  - Session-based lock ownership
  - 5-minute automatic lock timeout
  - Lock directory: `~/.claude/locks/`

- **Sibling Tool Call Error Isolation** - plan-orchestrator recovery protocol (R-008)
  - Detection pattern for `<tool_use_error>Sibling tool call errored</tool_use_error>`
  - Sequential isolation for critical operations (never mix Bash with TaskUpdate)
  - Retry isolation pattern for cancelled operations

### Documentation
- Updated `docs/11-agent-team.md` with implementer safety protocols
- Updated `docs/13-hooks-system.md` with new hooks documentation
- Updated `docs/15-troubleshooting.md` with file size limits section (R-011)

### Notes
- Recommendations R-001 (atomic TaskCreate) and R-007 (TaskBatchUpdate) require Claude Code core changes and are out of scope
- Implementation based on comprehensive log analysis from LOGANALYSIS.md

---

## [1.0.4] - 2026-02-02

### Added
- **TeammateTool Integration Preparation** - System readiness for anticipated Sonnet 5 release
  - Created comprehensive analysis documents in `plans/` directory
  - Documented 5-phase implementation roadmap for team-based multi-agent orchestration
  - Added agent cross-reference validation requirements to prevent redundancy
  - Deferred implementation pending I9() feature flag public availability

### Documentation
- Created `BACKBURNER.md` - Deferred features tracking document
  - TeammateTool multi-agent orchestration integration plan (DEFERRED)
  - Prerequisites checklist including agent redundancy validation
  - 5-phase implementation summary with dependency graph

---

## [1.0.3] - 2026-02-02

### Added
- **context-validator agent** (Sonnet) - New validation phase between discovery and implementation
  - Validates version compatibility, breaking changes, and syntax differences
  - Compares documentation against project reality (package.json, requirements.txt, config files)
  - Returns GO/CAUTION/NO-GO recommendation before implementation proceeds
  - Tools: Read, Grep, Glob, WebSearch, Context7, TaskUpdate, TaskGet, TaskList
  - Feature flag: `ENABLE_CONTEXT_VALIDATOR` (ON by default)

### Changed
- **docs-specialist upgraded from Haiku to Sonnet model**
  - Better synthesis and reduced interpretation errors when fetching documentation
  - Prevents version mismatches (e.g., Tailwind CSS v3 docs for v4 projects)

- **explore-lead now used for all tiers** (LIGHT, MEDIUM, FULL)
  - Replaces explore-light for consistent quality exploration
  - Uses Sonnet model instead of Haiku

- **Tier agent routing updated**:
  | Tier | Before | After |
  |------|--------|-------|
  | LIGHT | explore-light | explore-lead |
  | MEDIUM | explore-light + research-light + plan-orchestrator | explore-lead + docs-specialist + context-validator + plan-orchestrator |
  | FULL | explore-lead + research-lead + docs-specialist + web-research-specialist + file-path-extractor + plan-orchestrator | Same + context-validator |

### Removed
- **explore-light agent** - Replaced by explore-lead for better quality
- **research-light agent** - Functionality consolidated into docs-specialist and explore-lead

### Fixed
- Root cause of "too much interpretability" issues during delegation
  - Haiku agents were misinterpreting documentation versions
  - Context validation now catches version conflicts before implementation

### Documentation
- Updated `02-delegation-architecture.md` with new tier routing
- Updated `06-feature-flags.md` with ENABLE_CONTEXT_VALIDATOR flag
- Updated `11-agent-team.md` with context-validator and model changes
- Updated `tiered-workflow.txt` with new agent workflows
- Updated `klaus-delegation.conf` with CORE/OPTIONAL agent flag categories

### Notes
- Net agent count: 18 -> 17 (removed 2, added 1)
- Model allocation strategy: Haiku phased out for discovery, Sonnet for quality, Opus for research coordination

---

## [1.0.2] - 2026-01-27

### Added
- Profile system (conservative/balanced/aggressive routing)
- Multi-feature detection (+2 score bonus for 3+ bullet prompts)
- Delegation enforcement instructions for MEDIUM/FULL tiers

---

## [1.0.1] - 2026-01-26

### Added
- E2E test calibration for keyword weights
- Context7 keyword detection and scoring

### Fixed
- Keyword weight calibration based on test results

---

## [1.0.0] - 2026-01-25

### Added
- Initial release of Klaus Baudelaire
- 4-tier routing system (DIRECT, LIGHT, MEDIUM, FULL)
- 18 specialized agents
- TaskList coordination across agents
- Feature flag system
- Complexity scoring algorithm
- Hook-based automatic routing

---

[1.0.6]: https://github.com/blas0/klaus-baudelaire/compare/v1.0.5...v1.0.6
[1.0.5]: https://github.com/blas0/klaus-baudelaire/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/blas0/klaus-baudelaire/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/blas0/klaus-baudelaire/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/blas0/klaus-baudelaire/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/blas0/klaus-baudelaire/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/blas0/klaus-baudelaire/releases/tag/v1.0.0
