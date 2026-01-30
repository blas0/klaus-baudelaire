# Plan Agent Orchestration

> **Back to [README](../TLDR-README.md)** | **Prev: [Production Testing](08-production-testing.md)** | **Next: [Memory Management](10-memory-management.md)**

---

## Overview

The Plan Orchestrator is the **primary delegator** for MEDIUM and FULL tier tasks. It decomposes complex work into atomic sub-tasks, selects appropriate specialist agents, delegates work with dependency tracking, and synthesizes results.

**Critical constraint**: The Plan agent NEVER writes code. It ONLY plans and orchestrates.

---

## Architecture

```
User Prompt --> Tier Detection --> Plan Orchestrator --> Agent Delegation --> Synthesis --> User
                  (score 5+)           |
                                       v
                              TaskCreate (breakdown)
                              Task (delegate to agents)
                              TaskList (monitor progress)
                              TaskGet (inspect results)
```

---

## 7-Phase Workflow

### Phase 1: Analyze & Decompose

Break the user's request into atomic, trackable sub-tasks.

- Identify discrete deliverables
- Determine dependencies between tasks
- Estimate complexity per task

### Phase 2: Agent Discovery

Match each sub-task to the best specialized agent.

- Consult Agent Capability Registry (9 agents documented)
- Consider agent model capabilities (Haiku for speed, Sonnet for depth)
- Identify parallel vs sequential execution opportunities

### Phase 3: Task Delegation

Create tasks and delegate to agents.

```
TaskCreate:
  Subject: "Research React testing libraries for TypeScript"
  Description: "Compare Jest, Vitest, and bun:test. Focus on type safety, speed, DX."
  ActiveForm: "Researching React testing libraries"
```

### Phase 4: Monitor Progress

Track agent completion via TaskList.

- Poll TaskList for status updates
- Detect stalled tasks (>2 minutes without update)
- Identify blocked dependencies

### Phase 5: Synthesize Results

Merge findings from multiple agents.

- Collect TaskUpdate metadata from each agent
- Resolve conflicting findings
- Build unified understanding

### Phase 6: Quality Assurance

Verify completeness before returning.

- All tasks marked completed
- Dependencies resolved
- No information gaps
- Results answer the original question

### Phase 7: Return Summary

Present structured results to user.

- Summary of findings
- Files affected
- Recommendations
- Next steps

---

## Agent Capability Registry

The Plan Orchestrator maintains a registry of all 9 specialized agents:

| Agent | Model | Best For | Tools |
|-------|-------|----------|-------|
| `explore-light` | Haiku | Quick codebase reconnaissance | Read, Grep, Glob, Edit, Write |
| `research-light` | Haiku | Quick web research | WebSearch, WebFetch, Read |
| `docs-specialist` | Haiku | Official documentation lookup | Context7, WebSearch, WebFetch, Read, Write |
| `web-research-specialist` | Sonnet | Deep web research | WebSearch, WebFetch, Read, Write |
| `file-path-extractor` | Haiku | File path extraction from output | Read, Grep, Glob |
| `code-simplifier` | Haiku | Refactoring analysis | Read, Write, Edit |
| `test-infrastructure-agent` | Sonnet | Test setup and configuration | Write, Edit, Bash, Read |
| `git-orchestrator` | Haiku | Advanced git operations | Bash, Read, Write |
| `reminder-nudger-agent` | Haiku | Progress monitoring (READ-ONLY) | Read, Write, Bash, TaskGet, TaskList |

---

## Task Coordination Protocol

All 9 executor agents include a standardized protocol:

### When Invoked by Plan Agent

```markdown
1. TaskGet(taskId) - Read task details and context
2. Execute specialized work
3. TaskUpdate(taskId, metadata) - Report results
4. Mark task as completed
```

### TaskUpdate Metadata Format

```json
{
  "summary": "Brief description of findings",
  "findings": ["finding 1", "finding 2"],
  "files_affected": ["path/to/file.ts"],
  "data": {},
  "recommendations": ["recommendation 1"]
}
```

---

## Hook Integration

The Plan agent is activated via `klaus-delegation.sh`:

- **MEDIUM tier** (score 5-6): Plan agent orchestration context injected
- **FULL tier** (score 7+): Plan agent orchestration context injected with enhanced agent roster

The hook injects `additionalContext` containing:
- 7-step workflow instructions
- Available agent list
- Task coordination instructions
- Tier-specific metadata

---

## Delegation Best Practices

### Parallel Delegation

Use for independent tasks:

```
TaskCreate: "Research React libraries" (no blockedBy)
TaskCreate: "Explore current test setup" (no blockedBy)
TaskCreate: "Check CI/CD configuration" (no blockedBy)
--> All three run simultaneously
```

### Sequential Delegation

Use for dependent tasks:

```
TaskCreate: "Research best practices" (task #1)
TaskCreate: "Design implementation plan" (blockedBy: #1)
TaskCreate: "Write tests" (blockedBy: #1)
--> #2 and #3 wait for #1 to complete
```

---

## Plan Orchestrator Frontmatter

```yaml
---
name: plan-orchestrator
description: "Primary delegator for MEDIUM/FULL tier tasks"
model: sonnet
tools: TaskCreate, TaskUpdate, TaskGet, TaskList, Task, Read, Grep, Glob, Bash, AskUserQuestion
disallowedTools: Write, Edit, NotebookEdit
permissionMode: default
color: blue
---
```

**Key constraint**: `disallowedTools: Write, Edit, NotebookEdit` ensures the Plan agent is a PLANNER, not an IMPLEMENTER.

---

## Testing

- **Unit Tests**: 6 tests in `tests/unit/plan-orchestration.test.sh`
  - MEDIUM tier triggers Plan agent orchestration
  - FULL tier triggers Plan agent orchestration
  - LIGHT tier skips Plan agent
  - Plan agent prompt contains required workflow steps
  - Plan agent has correct tools
  - Plan agent disallows Write/Edit/NotebookEdit

- **Integration Tests**: 53 tests in `tests/integration/plan-orchestration.test.sh`
  - Plan-orchestrator.md exists with valid frontmatter
  - All 9 agents have Task Coordination Protocol
  - Klaus-delegation.sh contains Plan agent logic
  - Agent Capability Registry is complete (9/9 agents)

---

## Related Documentation

- [Delegation Architecture](02-delegation-architecture.md) - Tier system overview
- [Task Management](12-task-management.md) - TaskList coordination details
- [Agent Team Reference](11-agent-team.md) - All agent specifications
