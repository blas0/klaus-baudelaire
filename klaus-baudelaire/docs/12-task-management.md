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

## Task Tool Distribution

Klaus distributes Task tools across 11 agents based on their roles:

| Role | Agents | Tools | Purpose |
|------|--------|-------|---------|
| **Task Creators** | research-lead, plan-orchestrator | TaskCreate, TaskUpdate, TaskList | Creates task breakdowns for complex work |
| **Task Executors** | explore-light, research-light, web-research-specialist, docs-specialist, file-path-extractor, git-orchestrator, code-simplifier, test-infrastructure-agent, composter | TaskUpdate, TaskList | Updates task progress, marks completion |
| **Task Monitor** | reminder-nudger-agent | TaskGet, TaskList | READ-ONLY monitoring for stagnation detection |

**Why this distribution**:
- **research-lead / plan-orchestrator**: Only agents that decompose complex work into sub-tasks (need TaskCreate)
- **Executor agents**: Update task status as they complete their specialized work
- **reminder-nudger**: Monitors without modifying to detect bottlenecks

---

## Task Coordination Protocol

Every agent with Task tools includes a standardized protocol section.

### Before Starting Work

1. Call `TaskList` to see existing tasks
2. Check if work relates to any pending tasks
3. If yes: `TaskUpdate` that task to `in_progress`

### During Work

- Update task status as progress is made
- Add relevant context to task descriptions

### After Completing Work

- Mark tasks as `completed` with `TaskUpdate`
- Verify no orphaned `in_progress` tasks remain

---

## Task Lifecycle

```
pending --> in_progress --> completed
```

---

## Coordination Flow Example

```
1. research-lead creates task breakdown:
   TaskCreate:
     Subject: "Research React testing libraries for TypeScript"
     Description: "Compare Jest, Vitest, and bun:test for TS projects."
     ActiveForm: "Researching React testing libraries"

2. web-research-specialist picks up task:
   TaskList --> Find task #1 (pending)
   TaskUpdate: task #1 --> in_progress
   [performs research...]
   TaskUpdate: task #1 --> completed

3. reminder-nudger monitors progress:
   TaskList --> Detect task #1 in_progress >2 min
   TaskGet: task #1 --> Inspect details
   [inject steering if stagnated]

4. docs-specialist continues chain:
   TaskList --> See task #1 completed
   TaskUpdate: task #2 (blocked by #1) --> in_progress
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
