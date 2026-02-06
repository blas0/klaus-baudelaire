# Teammate Skills System

> **Back to [README](../TLDR-README.md)** | **Prev: [Troubleshooting](15-troubleshooting.md)**

---

## Overview

Klaus v1.0.7 introduces **Native Teammate Skills** - a hybrid architecture combining Klaus's plugin system (hooks, agents) with Claude Code's experimental teammate capabilities. This enables cost-conscious team formation for parallel multi-agent workflows.

[!!!] **Experimental Feature**: Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` environment variable and `ENABLE_NATIVE_TEAMS="ON"` in `klaus-delegation.conf`.

---

## What Are Skills?

Skills are Claude Code's built-in mechanism for context-specific capabilities. Klaus's teammate skills live in `~/.claude/skills/` (separate from the plugin) and provide:

1. **Agent-to-teammate mapping** - 10 of Klaus's 17 agents can be spawned as teammates
2. **Team spawn templates** - Pre-configured team patterns for common workflows
3. **Progressive disclosure** - Detailed specs loaded on-demand via @references/ pattern
4. **Graceful degradation** - Falls back to subagent routing when teams unavailable

---

## The 4 Skills

| Skill | Purpose | Team Size | Cost Multiplier |
|-------|---------|-----------|-----------------|
| **klaus-team** | General-purpose team formation | 2-8 | 4-8x |
| **klaus-review-team** | 3-lens code review (security, performance, test) | 3 | ~4x |
| **klaus-research-team** | Multi-source research (docs, web, codebase) | 4 | ~6x |
| **klaus-impl-team** | Parallel implementation with file locks | 2-4 | ~5x |

---

## Skill Invocation Methods

### Method 1: Manual Slash Commands

```bash
/klaus-review-team
/klaus-research-team
/klaus-impl-team
```

Directly invokes the skill with full control.

### Method 2: Semi-Automatic Triggers

Skills can be triggered by description keywords in your prompts:

**klaus-team triggers**:
- "team", "swarm", "parallel agents", "coordinate agents"
- "work together", "full-stack", "multi-agent", "collaborate"

**klaus-review-team triggers**:
- "code review", "security audit", "performance review"
- "test coverage", "review team"

**klaus-research-team triggers**:
- "research", "documentation", "investigate", "compare options"

**klaus-impl-team triggers**:
- "implement in parallel", "multiple files", "implementation team"

[!!!] **Critical Gap**: Skills are NOT automatically routed via Klaus's `UserPromptSubmit` hook. The hook currently routes to agents, NOT skills. Semi-automatic triggering relies on Claude Code's internal skill-matching, which analyzes skill descriptions for keyword matches.

### Method 3: Plan-Orchestrator Delegation

The `plan-orchestrator` agent can manually invoke skills when it determines team formation is needed:

```
invoke skill klaus-review-team
```

This is the recommended approach for FULL-tier tasks requiring teams.

---

## Teammate Use Threshold

Before forming a team, evaluate the cost-benefit:

### SOLO (1x cost)
- Single-file edits, typo fixes, simple queries
- Tasks completable in under 2 minutes
- Research requiring one source

### SUBAGENT (1.5-2x cost)
- Multi-file exploration needing 2-3 parallel searches
- Documentation gathering from multiple sources
- Context validation before implementation
- **Tool**: Use `Task` with `subagent_type` parameter

### TEAM (4-8x cost)
- 3+ independent workstreams benefiting from discussion
- Code review across security + performance + testing dimensions
- Research requiring debate/challenge between perspectives
- Implementation spanning frontend + backend + tests
- **Require**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` enabled
- **Tool**: Use `Teammate` to create team, `Task` with `team_name` to spawn members

[!!] Always prefer SUBAGENT tier for parallel work unless inter-communication is critical.

---

## Agent-to-Teammate Mapping

### Teammate-Eligible Agents (10/17)

| Agent | Model | Teammate Role |
|-------|-------|---------------|
| plan-orchestrator | sonnet | Team Lead (IS the lead, not spawned) |
| research-lead | opus | Research Coordinator |
| explore-lead | sonnet | Codebase Analyst |
| docs-specialist | sonnet | Documentation Researcher |
| context-validator | sonnet | Pre-Implementation Validator |
| web-research-specialist | sonnet | Web Researcher |
| implementer | sonnet | Implementation Worker |
| test-infrastructure-agent | sonnet | Test Setup |
| code-simplifier | haiku | Code Reviewer |
| recursive-agent | opus | Document Analyst |

### Subagent-Only Agents (7/17)

These agents remain subagent-only due to lightweight/specialized nature:

| Agent | Model | Reason |
|-------|-------|--------|
| file-path-extractor | haiku | Single-purpose utility |
| git-orchestrator | haiku | Specialized git ops |
| composter | sonnet | Pattern extraction only |
| reminder-nudger-agent | haiku | Background monitor |
| chunk-analyzer | haiku | RLM chunk processor |
| conflict-resolver | sonnet | RLM merge step |
| synthesis-agent | sonnet | RLM final report |

---

## Skill Architecture

```
~/.claude/skills/
├── klaus-team/
│   ├── SKILL.md                     # Main skill definition
│   └── references/
│       ├── agent-registry.md        # 17 agents with full specs
│       ├── team-patterns.md         # Pre-built spawn templates
│       └── routing-thresholds.md    # SOLO/SUBAGENT/TEAM decision tree
├── klaus-review-team/
│   ├── SKILL.md
│   └── references/
│       └── review-lenses.md         # Security/performance/test specs
├── klaus-research-team/
│   ├── SKILL.md
│   └── references/
│       └── research-roles.md        # Docs/web/codebase researcher specs
└── klaus-impl-team/
    ├── SKILL.md
    └── references/
        └── impl-roles.md            # Implementer/validator/file lock specs
```

### Progressive Disclosure Pattern

Skills use `@references/` to load detailed specs on-demand:

```
// In skill prompt:
For full agent specifications, load @references/agent-registry.md

// Claude loads:
~/.claude/skills/klaus-team/references/agent-registry.md
```

This keeps skill definitions concise while preserving deep technical specs.

---

## Spawn Protocol

### Step 1: Create the Team

```javascript
Teammate({
  operation: "spawnTeam",
  team_name: "project-name",
  description: "Brief team purpose"
})
```

### Step 2: Create Tasks

Use `TaskCreate` to define work items with dependencies:

```javascript
TaskCreate({
  subject: "Security audit of authentication",
  description: "Review auth middleware for vulnerabilities",
  activeForm: "Auditing authentication security",
  metadata: {
    agent_type: "context-validator",
    reviewer_lens: "security"
  }
})
```

### Step 3: Spawn Teammates

Use `Task` tool with `team_name` to spawn each member:

```javascript
Task({
  subagent_type: "context-validator",
  team_name: "project-name",
  name: "security-reviewer",
  description: "Security auditor",
  prompt: `
    You are a Security Reviewer specialist.
    
    Tools: Read, Grep, Glob, WebSearch, Context7
    
    Review authentication middleware for:
    - SQL injection vulnerabilities
    - XSS attack vectors
    - CSRF protection gaps
    - JWT security best practices
    
    Return results in this format:
    === TASK RESULTS ===
    summary: [1-2 sentence summary]
    findings: [array of security issues]
    severity: [CRITICAL|HIGH|MEDIUM|LOW]
    recommendations: [array of fixes]
    ===
  `
})
```

[!!!] **Critical**: Teammates do NOT load agent definition files. All domain knowledge must be encoded in the spawn prompt.

---

## File Lock Coordination

When multiple implementer teammates work in parallel:

1. **Non-overlapping ownership** - Each implementer owns distinct file sets
2. **file-lock-coordinator.sh hook** - Enforces locks at PreToolUse level
3. **Lock timeout** - 5 minutes automatic release
4. **Conflict detection** - Immediate yield protocol if overlap detected

**Example ownership boundaries**:
```
implementer-frontend: src/components/*, src/styles/*
implementer-backend: src/api/*, src/services/*
implementer-tests: tests/*, __tests__/*
```

---

## Graceful Degradation

If `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is unavailable:

1. Skills detect the unavailability
2. Fall back to SUBAGENT tier using `Task` tool
3. Use `subagent_type` to invoke same agent expertise
4. Lose inter-communication but retain all specialist capabilities

**Example fallback**:
```javascript
// TEAM tier (if available):
Teammate({ operation: "spawnTeam", team_name: "review" })
Task({ subagent_type: "context-validator", team_name: "review", ... })

// SUBAGENT tier (fallback):
Task({ subagent_type: "context-validator", ... })
```

---

## Configuration

### Environment Variable

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

Add to `~/.zshrc` or `~/.bashrc` for persistence.

### Feature Flag

In `~/.claude/config/klaus-delegation.conf`:

```bash
ENABLE_NATIVE_TEAMS="ON"           # ON | OFF - Enable native teammate routing skills
```

When OFF, skills are disabled and Klaus uses subagent-only routing.

---

## Cost Awareness

| Team Pattern | Teammates | Approximate Cost | Best For |
|--------------|-----------|-----------------|----------|
| Review (3 reviewers) | 3 sonnet/haiku | ~4x single session | Security + Performance + Test review |
| Research (3 researchers + coordinator) | 4 sonnet/opus | ~6x single session | Multi-source research with debate |
| Implementation (2-3 implementers + validator) | 3-4 sonnet | ~5x single session | Parallel file creation across layers |
| Full Orchestration (all roles) | 5-8 mixed | ~8x single session | Complex multi-layer architecture |

[!!] Before forming a team with 4+ members, the skill prompts the user with cost estimates.

---

## Workflow Examples

### Example 1: Code Review Team

**Manual**:
```bash
/klaus-review-team
```

**Via plan-orchestrator**:
```
User: "Review this auth system for security, performance, and test coverage"
Klaus: Routes to FULL tier
plan-orchestrator: Analyzes request, invokes klaus-review-team skill
Skill: Spawns 3 reviewers (security, performance, test)
Result: 3-lens review with synthesized findings
```

### Example 2: Research Team

**Manual**:
```bash
/klaus-research-team "Compare Next.js vs Remix for our use case"
```

**Via keyword trigger**:
```
User: "Research and compare Next.js vs Remix for SSR with TypeScript"
Claude: Detects "research" + "compare" keywords, triggers klaus-research-team
Skill: Spawns docs-specialist, web-research-specialist, explore-lead, research-lead
Result: Multi-source comparison with debate synthesis
```

### Example 3: Implementation Team

**Manual**:
```bash
/klaus-impl-team
```

**Via plan-orchestrator**:
```
User: "Implement hero, footer, and navigation components in parallel"
Klaus: Routes to FULL tier
plan-orchestrator: Detects 3 independent components, invokes klaus-impl-team
Skill: Spawns 3 implementers with file ownership boundaries
  - implementer-hero: src/components/Hero.tsx
  - implementer-footer: src/components/Footer.tsx
  - implementer-nav: src/components/Navigation.tsx
context-validator: Pre-validates design specs
Result: 3 components implemented in parallel with validation
```

---

## Troubleshooting

### Team creation fails

**Symptom**: `Teammate` tool returns error

**Solutions**:
- Verify `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` environment variable is set
- Check `ENABLE_NATIVE_TEAMS="ON"` in klaus-delegation.conf
- Use `Teammate({ operation: "cleanup" })` to clear stale teams
- Fall back to SUBAGENT tier with `Task` tool

### Teammate goes idle unexpectedly

**Symptom**: Teammate stops responding

**Explanation**: This is NORMAL behavior. Teammates go idle between turns.

**Solution**: Send a message to wake them:
```javascript
SendMessage({
  type: "message",
  recipient: "teammate-name",
  message: "Continue with next task"
})
```

### File conflicts between implementers

**Symptom**: Two implementers attempt to edit same file

**Solutions**:
- Ensure non-overlapping file ownership in task descriptions
- Enable `file-lock-coordinator.sh` hook for automatic enforcement
- One implementer yields and waits for lock release

### Cost exceeds expectations

**Symptom**: Session token usage much higher than estimated

**Solutions**:
- Reduce team size: use 2 teammates instead of 4
- Switch lower-priority roles to SUBAGENT tier
- Use haiku-model agents (code-simplifier) for review tasks
- Evaluate if SOLO tier is sufficient for the task

### Skills not triggering automatically

**Symptom**: Keywords don't trigger skill

**Explanation**: Skills are NOT routed via Klaus's `UserPromptSubmit` hook. Triggering relies on Claude Code's internal skill description matching.

**Solutions**:
- Use manual slash commands: `/klaus-review-team`
- Have plan-orchestrator explicitly invoke skill
- Wait for Klaus integration with UserPromptSubmit (future enhancement)

---

## Current Limitations

### UserPromptSubmit Hook Gap

Klaus's `UserPromptSubmit` hook currently routes prompts to **agents**, not **skills**. This means:

- Skills are NOT automatically invoked based on Klaus's complexity scoring
- Skill triggering relies on Claude Code's keyword matching in skill descriptions
- plan-orchestrator must manually invoke skills when team formation is needed

**Future Enhancement**: Integrate skill routing into klaus-delegation.sh hook for unified tier-based routing (DIRECT → agents, FULL → skills).

### Teammate Spawn Overhead

Unlike subagents, teammates require explicit spawn prompts encoding all domain knowledge:

- Agent definition files are NOT loaded by teammates
- All expertise must be duplicated in spawn prompt
- Increases prompt size and initial context overhead

**Mitigation**: Skills use @references/ progressive disclosure to keep spawn prompts modular.

---

## Related Documentation

- [Agent Team Reference](11-agent-team.md) - Detailed agent capabilities
- [Task Management](12-task-management.md) - TaskCreate/TaskUpdate coordination
- [Plan Orchestration](09-plan-orchestration.md) - plan-orchestrator workflow
- [Delegation Architecture](02-delegation-architecture.md) - Klaus tier system
- [Configuration & Keywords](04-configuration-keywords.md) - Feature flags

---

## References

For skill implementation details, see:

- `~/.claude/skills/klaus-team/SKILL.md` - Main team formation skill
- `~/.claude/skills/klaus-review-team/SKILL.md` - 3-lens code review
- `~/.claude/skills/klaus-research-team/SKILL.md` - Multi-source research
- `~/.claude/skills/klaus-impl-team/SKILL.md` - Parallel implementation
- `~/.claude/skills/*/references/` - Progressive disclosure specs
