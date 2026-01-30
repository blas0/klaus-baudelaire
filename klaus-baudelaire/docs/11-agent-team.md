# Agent Team Reference

> **Back to [README](../TLDR-README.md)** | **Prev: [Memory Management](10-memory-management.md)** | **Next: [Task Management](12-task-management.md)**

---

## Overview

Klaus coordinates a team of specialized agents organized into four categories: delegation specialists, research agents, utility agents, and recursive language model (RLM) agents.

---

## Delegation Agents (Klaus Specialists)

These agents are Klaus's core team, each with a specific expertise.

### plan-orchestrator

| Property | Value |
|----------|-------|
| **Model** | Sonnet |
| **Purpose** | Primary delegator for MEDIUM/FULL tier tasks |
| **Tools** | TaskCreate, TaskUpdate, TaskGet, TaskList, Task, Read, Grep, Glob, Bash, AskUserQuestion |
| **DisallowedTools** | Write, Edit, NotebookEdit |
| **When Used** | MEDIUM and FULL tier (score 5+) |
| **Feature Flag** | Always active for MEDIUM/FULL |

Plans and orchestrates complex work without writing code. Decomposes tasks, selects agents, delegates work, monitors progress, and synthesizes results.

### docs-specialist

| Property | Value |
|----------|-------|
| **Model** | Haiku |
| **Purpose** | PRIMARY documentation gatherer |
| **Tools** | Context7 (resolve-library-id, query-docs), WebSearch, WebFetch, Read, Write, TaskUpdate, TaskList |
| **When Used** | All tiers (documentation needs) |
| **Feature Flag** | ENABLE_DOCS_SPECIALIST |

The first agent consulted for documentation. Uses official sources (developer.apple.com, docs.python.org, react.dev) before community sources. Follows a 2-attempt validation protocol with research-lead.

### web-research-specialist

| Property | Value |
|----------|-------|
| **Model** | Sonnet |
| **Purpose** | Web research for docs and best practices |
| **Tools** | WebSearch, WebFetch, Read, Write, TaskUpdate, TaskList |
| **When Used** | LIGHT (if enabled), FULL tier |
| **Feature Flag** | ENABLE_WEB_RESEARCHER (OFF by default) |

Deep web research when docs-specialist needs support. Searches for best practices, tutorials, and implementation examples.

### file-path-extractor

| Property | Value |
|----------|-------|
| **Model** | Haiku |
| **Purpose** | Extract file paths from bash output |
| **Tools** | Read, Grep, Glob, TaskUpdate, TaskList |
| **When Used** | MEDIUM and FULL tier |
| **Feature Flag** | ENABLE_FILE_PATH_EXTRACTOR (ON by default) |

Parses bash command output to extract file paths for context tracking. Helps maintain awareness of affected files during complex operations.

### test-infrastructure-agent

| Property | Value |
|----------|-------|
| **Model** | Sonnet |
| **Purpose** | Test infrastructure setup |
| **Tools** | Write, Edit, Bash, Read, TaskUpdate, TaskList |
| **When Used** | When test setup is requested |
| **Feature Flag** | ENABLE_TEST_INFRASTRUCTURE (OFF by default) |

Sets up test infrastructure with a preference for `bun:test`. Configures test runners, writes configuration files, and creates test templates.

### reminder-nudger-agent

| Property | Value |
|----------|-------|
| **Model** | Haiku |
| **Purpose** | Progress monitoring and stagnation detection |
| **Tools** | Read, Write, Bash, TaskGet, TaskList |
| **When Used** | Background monitoring |
| **Feature Flag** | ENABLE_REMINDER_SYSTEM (OFF by default) |

READ-ONLY monitor that detects stagnation. Identifies stuck tasks, blocked dependencies, and analysis paralysis. Injects steering reminders without modifying task state.

---

## Research Agents (Built-in Pattern)

These agents derive from Claude Code's native agent architecture.

### explore-light

| Property | Value |
|----------|-------|
| **Model** | Haiku |
| **Purpose** | Quick codebase reconnaissance |
| **Tools** | Read, Grep, Glob, Edit, Write, TaskUpdate, TaskList |
| **When Used** | LIGHT, MEDIUM tier |

Fast, lightweight exploration of the codebase. Reads files, searches patterns, and provides quick context.

### explore-lead

| Property | Value |
|----------|-------|
| **Model** | Sonnet |
| **Purpose** | Comprehensive codebase exploration for FULL tier |
| **Tools** | Glob, Grep, Read, Context7 (resolve-library-id), TaskUpdate, TaskGet, TaskList, Edit, Write, Bash |
| **When Used** | FULL tier |

Deep architectural analysis for complex tasks. Maps system architecture, identifies patterns, tracks cross-file dependencies, and provides comprehensive codebase understanding. Distinct from explore-light (haiku, quick) - explore-lead provides thorough multi-file exploration with architectural insights.

### research-lead

| Property | Value |
|----------|-------|
| **Model** | Opus |
| **Purpose** | Comprehensive research coordination |
| **Tools** | TaskCreate, TaskUpdate, TaskList, Task, Read, WebSearch, WebFetch |
| **When Used** | FULL tier |

The only agent with TaskCreate capability (besides plan-orchestrator). Coordinates multi-source research, decomposes complex research tasks, and validates documentation findings.

### research-light

| Property | Value |
|----------|-------|
| **Model** | Haiku |
| **Purpose** | Quick web research |
| **Tools** | WebSearch, WebFetch, Read, TaskUpdate, TaskList |
| **When Used** | MEDIUM tier |

Quick web lookups without spawning subagents. Fast answers for straightforward research questions.

---

## Utility Agents

### code-simplifier

| Property | Value |
|----------|-------|
| **Model** | Haiku |
| **Purpose** | Refactoring suggestions for clarity |
| **Tools** | Read, Write, Edit, TaskUpdate, TaskList |

Analyzes code for complexity and suggests simplifications. Focuses on readability, maintainability, and adherence to project patterns.

### composter

| Property | Value |
|----------|-------|
| **Model** | Sonnet |
| **Purpose** | Extract and document codebase patterns |
| **Tools** | Read, Write, Grep, Glob |

Used by the `/compost` command. Reads source files, identifies recurring patterns, and documents them as project standards.

### git-orchestrator

| Property | Value |
|----------|-------|
| **Model** | Haiku |
| **Purpose** | Advanced git operations |
| **Tools** | Bash, Read, Write, TaskUpdate, TaskList |

Handles complex git operations: interactive rebase, conflict resolution, history manipulation. Uses a dual-pathway OODA loop with safety-first principles (backup refs, pre-flight checks, rollback strategies).

---

## RLM (Recursive Language Model) Agents

For large document analysis (50K+ tokens).

### Pattern Selection

| Pattern | Use When | Workflow |
|---------|----------|----------|
| **Map-Reduce** | Independent chunks, parallel processing | Chunk → Analyze in parallel → Merge results |
| **Refine** | Sequential dependencies, cumulative state | Chunk → Analyze → Update state → Next chunk |
| **Scratchpad** | Multi-hop reasoning, cross-references | Chunk → Extract → Build global scratchpad → Reason |

**Map-Reduce**: Best for entity extraction, keyword analysis, compliance audits where chunks don't depend on each other.

**Refine**: Best for document summarization, narrative analysis, or when later chunks may contradict earlier findings.

**Scratchpad**: Best for dependency tracing, cross-reference resolution, or building knowledge graphs across the document.

### recursive-agent

| Property | Value |
|----------|-------|
| **Model** | Opus |
| **Purpose** | Orchestrator for large document analysis |
| **Patterns** | Map-Reduce, Refine, Scratchpad |

Coordinates RLM workflows: chunks documents, deploys worker agents, manages state via Task API, and synthesizes results.

### chunk-analyzer

| Property | Value |
|----------|-------|
| **Model** | Haiku |
| **Purpose** | Fast document chunk processing |

Worker agent that analyzes individual document chunks. Extracts structured data, entities, and findings from each chunk.

### conflict-resolver

| Property | Value |
|----------|-------|
| **Model** | Sonnet |
| **Purpose** | Deduplication and conflict resolution |
| **Tools** | TaskGet, TaskList |

Merges findings from parallel chunk analyses. Deduplicates, resolves naming conflicts, and assigns confidence scores.

### synthesis-agent

| Property | Value |
|----------|-------|
| **Model** | Sonnet |
| **Purpose** | Final report generation |
| **Tools** | TaskGet, TaskList |

Generates comprehensive final reports from complete analysis state. Includes executive summary, detailed findings, statistics, and methodology notes.

---

## Agent Invocation

### Via Plan Agent (Automatic)

For MEDIUM/FULL tier tasks, the Plan agent automatically selects and delegates to appropriate agents.

### Via Direct Mention

```
@"web-research-specialist" <query>
@"file-path-extractor" <bash output>
@"test-infrastructure-agent" <setup request>
@"code-simplifier" <review request>
@"composter" [auto-invoked by /compost]
```

---

## Task Tool Distribution

| Role | Agents | Tools |
|------|--------|-------|
| **Task Creators** | research-lead, plan-orchestrator | TaskCreate, TaskUpdate, TaskList |
| **Task Executors** | explore-light, research-light, docs-specialist, web-research-specialist, file-path-extractor, code-simplifier, test-infrastructure-agent, git-orchestrator, composter | TaskUpdate, TaskList |
| **Task Monitor** | reminder-nudger-agent | TaskGet, TaskList (READ-ONLY) |

---

## Related Documentation

- [Plan Orchestration](09-plan-orchestration.md) - How Plan agent delegates to agents
- [Task Management](12-task-management.md) - TaskList coordination across agents
- [Feature Flags](06-feature-flags.md) - Enabling/disabling agents
- [Delegation Architecture](02-delegation-architecture.md) - Which agents activate per tier
