# Delegation Architecture

> **Back to [README](../TLDR-README.md)** | **Prev: [Installation](01-installation.md)** | **Next: [Scoring Algorithm](03-scoring-algorithm.md)**

---

## Overview

Klaus organizes work into tiers, like chapters in a book. Simple tasks get quick treatment (DIRECT), while complex problems get the full research team (FULL).

---

## The 4-Tier System

Klaus routes tasks to 4 tiers based on complexity scores:

| Tier | Score | What Klaus Does | Agents Invoked | Use Cases |
|------|-------|-----------------|----------------|-----------|
| **DIRECT** | 0-2 | Executes immediately (no coordination) | None | Simple edits, typos, single-file changes |
| **LIGHT** | 3-4 | Quick reconnaissance | explore-light | Straightforward features, basic research |
| **MEDIUM** | 5-6 | Light intelligence team | explore-light + research-light + plan-orchestrator | Multi-file changes, moderate complexity |
| **FULL** | 7+ | Full research committee | explore-lead + docs-specialist + research-lead + file-path-extractor + plan-orchestrator | Complex features, architecture changes |

---

## How It Works (30-Second Overview)

```
Your Prompt --> Klaus Analyzes --> Calculates Score --> Determines Tier --> Coordinates Agents --> Claude Executes
```

**Example**:

1. **You type**: "Set up OAuth with tests and CI/CD integration"
2. **Klaus analyzes**: Matches keywords (oauth:+2, tests:+3, ci/cd:+2) = Score: 7
3. **Klaus determines**: Score 7 = FULL tier (comprehensive intelligence)
4. **Klaus coordinates**: Spawns explore-lead + research-lead + web-research-specialist + plan-orchestrator agents
5. **Claude executes**: Follows workflow autonomously with full context

**Result**: Comprehensive research, planning, and implementation without manual agent orchestration.

---

## Two Approaches to Routing

### Option 1: Automatic Routing (UserPromptSubmit Hook)

Klaus analyzes **every prompt** you submit automatically:

```
Your Prompt --> Klaus Analyzes --> Score --> Tier --> Agents --> Execution
```

**Best for**: Users who want hands-free intelligence routing for all tasks.

### Option 2: Manual Control (/klaus Command)

Bypass automatic routing and force **FULL tier execution** on demand:

```bash
/klaus Design and implement OAuth with JWT, tests, and CI/CD integration
```

**Best for**: Users who want explicit control or prefer not to install hooks.

---

## Agent Coordination Patterns

### Parallel Execution (Speed Optimization)

**When Klaus uses parallel**:
- Multiple independent agents spawned simultaneously
- Research operations that do not depend on each other
- Maximize throughput for complex tasks

**Examples**:
- MEDIUM tier: `explore-light` + `research-light` in parallel, then `plan-orchestrator`
- FULL tier: `explore-lead` + `research-lead` + `web-research-specialist` + `docs-specialist` + `file-path-extractor` all in parallel

### Sequential Execution (Dependency Chain)

**When Klaus uses sequential**:
- Operations that depend on previous results
- Planning must wait for exploration/research to complete
- Implementation must wait for planning

**Examples**:
- LIGHT tier: `explore-light` then implementation (sequential)
- All tiers: Research/Exploration then `plan-orchestrator` then Implementation (sequential phases)

### Documentation Delegation Pattern (2-Attempt Validation)

When **any documentation** is needed, Klaus follows a strict protocol:

```
[Attempt 1] docs-specialist fetches from official sources --> research-lead validates
[Attempt 2] docs-specialist refines query --> research-lead re-validates
[Escalation] Only after 2 failures does research-lead search the web
```

**Source Quality Hierarchy**:
- **Tier 1 - Official**: developer.apple.com, docs.python.org, react.dev (ALWAYS prefer)
- **Tier 2 - Ecosystem**: Official GitHub repos with READMEs
- **Tier 3 - Community**: Stack Overflow (specific answers only)
- **NEVER**: Random blogs, outdated tutorials, unofficial cheat sheets

---

## Workflow Coordination

**LIGHT Tier**: Klaus injects `tiered-workflow.txt` PHASE 1-LIGHT as additional context.

**MEDIUM/FULL Tiers**: Klaus bypasses `tiered-workflow.txt` and builds custom `additionalContext` instructing Claude to invoke the `plan-orchestrator` agent (see `klaus-delegation.sh` lines 441-522). The MEDIUM/FULL sections in `tiered-workflow.txt` exist as documentation reference but are never injected.

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "[WORKFLOW TEXT or PLAN ORCHESTRATION INSTRUCTIONS]",
    "metadata": {
      "score": 7,
      "tier": "FULL",
      "plan_agent_active": true  // Only for MEDIUM/FULL
    }
  }
}
```

Claude receives this as context and follows Klaus's recommended workflow autonomously.

---

## MEDIUM/FULL Tier: Plan Agent Orchestration

For MEDIUM and FULL tier tasks, Klaus injects Plan Agent orchestration instructions:

1. **Analyze & Decompose** - Break task into atomic sub-tasks
2. **Agent Discovery** - Match sub-tasks to specialized agents
3. **Task Delegation** - Create TaskCreate entries with dependencies
4. **Monitor Progress** - Track agent completion via TaskList
5. **Synthesize Results** - Merge findings from multiple agents
6. **Quality Assurance** - Verify completeness before returning
7. **Return Summary** - Present structured results to user

See [Plan Agent Orchestration](09-plan-orchestration.md) for full details.

---

## Related Documentation

- [Scoring Algorithm](03-scoring-algorithm.md) - How Klaus calculates complexity scores
- [Configuration & Keywords](04-configuration-keywords.md) - Customizing tier thresholds
- [Agent Team Reference](11-agent-team.md) - All available agents
- [Hooks System](13-hooks-system.md) - Hook architecture details
