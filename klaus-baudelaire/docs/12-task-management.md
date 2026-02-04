# Task Management System

> **Back to [README](../TLDR-README.md)** | **Prev: [Agent Team Reference](11-agent-team.md)** | **Next: [Hooks System](13-hooks-system.md)**

---

## Overview

Claude Code 2.1.16 introduced a native task management system designed for complex, multi-step work. Klaus uses this for coordination across its multi-agent system, treating TaskList as a shared "handshake/scratchpad" for complex collaboration.

---

## What Changed in Claude Code 2.1.16

### Tool Evolution

- **Before**: Single `TodoWrite` tool for simple task lists
- **After**: Four specialized tools:
  - `TaskCreate` - Creates tasks with dependencies
  - `TaskGet` - Retrieves task details
  - `TaskList` - Lists all tasks with status
  - `TaskUpdate` - Updates status, dependencies, metadata

### New Capabilities

- **Dependency tracking**: Tasks can block/be blocked by other tasks
- **Persistence**: Tasks survive context compactions
- **Multi-session coordination**: Share tasks via `CLAUDE_CODE_TASK_LIST_ID`
- **UI integration**: Press `Ctrl+T` to toggle task list view
- **Status tracking**: `pending`, `in_progress`, `completed` with indicators

---

## Klaus's Task Philosophy

**Simplicity < Complexity** -- Tasks are for coordination, not every operation.

### When Tasks ARE Used

- Complex multi-step implementations (3+ dependent operations)
- Work requiring dependency tracking (Task A blocks Task B)
- Projects benefiting from progress visualization
- Cross-session coordination (multiple Claude instances)

### When Tasks Are NOT Used

- Research operations (explore-light, research-lead) - fluid, ephemeral
- Simple edits or single-file changes - overhead not justified
- Quick fixes or typo corrections - direct execution faster
- Atomic operations with no dependencies - tasks add friction

---

## Task Tool Distribution (Centralized Ownership - v1.0.6)

Klaus centralizes Task tools to 3 orchestrator agents only:

| Role | Agents | Tools | Purpose |
|------|--------|-------|---------|
| **Task Orchestrators** | plan-orchestrator, recursive-agent, research-lead | TaskCreate, TaskUpdate, TaskGet, TaskList | Create tasks, own task state, update on worker completion |
| **Task Workers** | All other agents (13 total) | None | Return results via `=== TASK RESULTS ===` response format |
| **Task Monitor** | reminder-nudger-agent | TaskGet, TaskList | READ-ONLY monitoring for stagnation detection |

**Why centralized ownership**:
- **Root cause**: Distributed ownership caused coordination gaps - workers completed work but failed to call TaskUpdate
- **Solution**: Orchestrators own all task state; workers just return results in structured text
- **Benefit**: Eliminates orphaned pending tasks by design
- **Pattern**: Orchestrator creates task -> spawns worker -> parses worker response -> calls TaskUpdate

---

## Task Coordination Protocol (Centralized Model)

### Orchestrator Protocol (plan-orchestrator, recursive-agent, research-lead)

**Before Spawning Worker:**
1. Call `TaskCreate` with subject, description, activeForm
2. Call `TaskUpdate` to set task to `in_progress`
3. Spawn worker via `Task` tool

**After Worker Returns:**
1. Parse worker's `=== TASK RESULTS ===` response
2. Extract Status, Summary, Files Affected, Findings
3. Call `TaskUpdate` to mark task `completed` with metadata

### Worker Protocol (All Other Agents)

Workers do NOT call Task* tools. Instead:

1. Perform assigned work
2. Return results in structured format:

```
=== TASK RESULTS ===
Status: SUCCESS | PARTIAL | FAILED
Summary: [1-2 sentence summary]

Files Affected:
- path/to/file.ts

Findings:
- [Finding 1]

Recommendations:
- [Recommendation 1]
=== END RESULTS ===
```

3. Orchestrator handles all TaskUpdate calls

---

## Task Lifecycle

```
pending --> in_progress --> completed
```

---

## Coordination Flow Example (Centralized Model)

```
1. plan-orchestrator creates and owns task:
   TaskCreate:
     Subject: "Research React testing libraries for TypeScript"
     Description: "Compare Jest, Vitest, and bun:test for TS projects."
     ActiveForm: "Researching React testing libraries"
   TaskUpdate: task #1 --> in_progress

2. plan-orchestrator spawns worker:
   Task(subagent_type: "web-research-specialist", prompt: "...")
   [worker performs research...]

3. web-research-specialist returns results (NOT TaskUpdate):
   === TASK RESULTS ===
   Status: SUCCESS
   Summary: Compared 3 testing libraries. bun:test recommended for TS.
   Files Affected: None (research only)
   Findings:
   - bun:test fastest with native TS support
   - Vitest best Jest compatibility
   - Jest most mature ecosystem
   Recommendations:
   - Use bun:test for new projects
   === END RESULTS ===

4. plan-orchestrator updates task state:
   [parses worker response]
   TaskUpdate: task #1 --> completed (with metadata from response)

5. reminder-nudger monitors progress:
   TaskList --> Detect task #2 in_progress >2 min
   TaskGet: task #2 --> Inspect details
   [inject steering if stagnated]
```

---

## Integration with Tiered Workflow

The FULL tier workflow includes a **TASK PLANNING** step that precedes implementation:

```
[0] Create task breakdown using TaskCreate
    - Structure work as discrete, trackable tasks
    - Subject: Imperative verb + outcome
    - Description: Detailed context, acceptance criteria
    - ActiveForm: Present continuous form
    - Update tasks to in_progress when starting
    - Mark completed when done
```

### When Tasks Activate by Tier

| Tier | TaskList Usage |
|------|---------------|
| **DIRECT** | Never (no coordination needed) |
| **LIGHT** | Never (single-agent, no tracking) |
| **MEDIUM** | Optional (when work naturally decomposes) |
| **FULL** | Automatic (plan-orchestrator creates task breakdown) |

---

## Stagnation Detection

The **reminder-nudger-agent** uses TaskList for enhanced monitoring:

### Task-based Stagnation Indicators

- Task in `in_progress` status >2 minutes without `TaskUpdate`
- 3+ tasks with `blockedBy` dependencies creating bottlenecks
- Growing task count (5+) with <30% completion rate
- Multiple tasks with no clear owner/assignee
- Task count growing while completion rate stays <10%

### Example Steering Reminders

```
[!] TASK PROGRESS REMINDER
Observation: Task #3 "Implement OAuth" in progress for 3+ minutes without update.
Suggestion: Consider TaskUpdate to track progress or break into smaller subtasks.
```

```
[!!] DEPENDENCY BOTTLENECK DETECTED
Observation: 3 tasks blocked by dependencies, no progress on blocking tasks.
Recommendation: Focus on unblocking tasks first, or reorder to eliminate dependencies.
```

```
[!!!] ANALYSIS PARALYSIS ALERT
Issue: 8 tasks created, only 1 completed across 3 agents and 10 minutes.
Action Required: Simplify scope, focus on fewer tasks, or request user clarification.
```

---

## User Commands

### View Tasks

```bash
# In Claude Code session
Ctrl+T                    # Toggle task list view
"show me all tasks"       # Ask Claude to display
"clear all tasks"         # Ask Claude to clear
```

### Share Tasks Across Sessions

```bash
# Terminal 1
export CLAUDE_CODE_TASK_LIST_ID=my-project
claude

# Terminal 2 (shares same task list)
export CLAUDE_CODE_TASK_LIST_ID=my-project
claude
```

### Slash Commands

```bash
/tasks                    # List background tasks (NOT same as TaskList)
/todos                    # List TODO items (legacy command)
```

---

## No Automatic Task Creation

Klaus's delegation hook (`klaus-delegation.sh`) does NOT auto-create tasks because:
- DIRECT/LIGHT tier work does not need tracking
- Tasks should be deliberate decisions, not automatic noise
- Main Claude naturally uses `TaskCreate` when complexity warrants it
- Hooks cannot invoke tools (architectural limitation)

---

## Testing

- **Integration Tests**: Task coordination tests in `tests/integration/task-coordination.test.sh`
- **Hook Tests**: RLM workflow coordinator tests validate SubagentStop task coordination
- **Plan Orchestration Tests**: 53 integration tests validate Task Coordination Protocol across all 9 agents

---

## Related Documentation

- [Plan Orchestration](09-plan-orchestration.md) - How Plan agent uses tasks
- [Agent Team Reference](11-agent-team.md) - Task tool distribution
- [Hooks System](13-hooks-system.md) - Hook limitations with tasks
