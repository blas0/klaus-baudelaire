# Hooks System

> **Back to [README](../TLDR-README.md)** | **Prev: [Task Management](12-task-management.md)** | **Next: [Testing & Verification](14-testing-verification.md)**

---

## Overview

Hooks are Klaus's sensors -- bash scripts that Claude Code invokes at specific lifecycle events. They detect when you submit a prompt, when a tool is used, and when a session ends.

---

## What Are Hooks?

Hooks are **bash scripts** that Claude Code invokes at specific lifecycle events. They can:
- Block/allow tool calls (via exit codes)
- Add context (via `additionalContext` JSON field)
- Modify inputs (via `updatedInput` JSON field)

**Critical limitation**: Hooks run as external subprocesses and **cannot** invoke slash commands or trigger agent spawning. They can only provide data/context.

---

## Available Hook Events

| Event | When Fired | Klaus Use Cases | Input Format |
|-------|------------|-----------------|--------------|
| **UserPromptSubmit** | User submits prompt | Route tasks, add context | `{"prompt":"user text"}` |
| **PreToolUse** | Before tool execution | Block dangerous commands | `{"tool":"Bash","input":{...}}` |
| **PostToolUse** | After tool execution | Log results, track files | `{"tool":"Bash","output":"..."}` |
| **Stop** | Session ends | Cleanup, save state | `{}` |

---

## Hook Output Format

Hooks communicate via **JSON to stdout**:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Text to add as context for Claude",
    "updatedInput": {"modified": "input"},
    "metadata": {"custom": "data"}
  }
}
```

**Exit codes**:
- `0` = Success, continue
- `1` = Block (for PreToolUse hooks)
- `2+` = Error

---

## klaus-delegation.sh (Primary Hook)

**Location**: `~/.claude/hooks/klaus-delegation.sh`
**Event**: UserPromptSubmit

The main coordination logic. Analyzes prompt complexity and injects appropriate workflow.

See [Scoring Algorithm](03-scoring-algorithm.md) and [Delegation Architecture](02-delegation-architecture.md) for full details.

---

## Hook Registration Scope

**IMPORTANT**: Only `klaus-delegation.sh` is registered in `hooks.json` as a Claude Code hook. All other hook scripts are **sourced internally** by klaus-delegation.sh.

**Registered Hook** (in hooks.json):
- `klaus-delegation.sh` - Registered for `UserPromptSubmit` event

**Internally Sourced Scripts** (NOT independently registered):
- `klaus-session-state.sh` - Session management (async)
- `routing-telemetry.sh` - Telemetry tracking
- `rlm-workflow-coordinator.sh` - RLM workflow orchestration
- `recursive-agent-trigger.sh` - Recursive agent detection
- `feature-flag-registry.sh` - Standalone utility script (not a hook)

**Why this architecture?**
- Single entry point handles all UserPromptSubmit events
- Modular functionality sourced on-demand
- Easier debugging (one registered hook to trace)
- Simpler hook lifecycle management

---

## Async Hook Execution

Klaus supports **asynchronous hook execution** for non-blocking prompt routing.

### Architecture

```
User Prompt --> Async Hook --> Provisional Response (~113ms) --> Background Analysis --> Session State Updated
                                     |
                               User Sees "ANALYZING"
                               Claude Continues Working
                                     |
                               Background completes (<2s)
                               Enhanced context available
```

### Configuration

**Location**: `~/.claude/klaus-delegation.conf`

```bash
ENABLE_ASYNC_HOOKS="OFF"          # ON | OFF (default: OFF for stability)
ASYNC_TIMEOUT=5000                 # Max wait for background analysis (ms)
ASYNC_SESSION_TTL=86400            # Session state lifetime (24 hours)
ASYNC_DEBUG_MODE="OFF"             # Enable async-specific debug logging
```

### Dual-Mode Operation

**Synchronous Mode** (default, `ENABLE_ASYNC_HOOKS=OFF`):
- Original behavior preserved
- Hook blocks until tier determination complete (150-300ms)
- Returns full workflow injection immediately

**Asynchronous Mode** (`ENABLE_ASYNC_HOOKS=ON`):
- Returns provisional response immediately (~113ms)
- Forks background process for tier analysis
- Updates session state when complete

### Performance

| Metric | Synchronous | Asynchronous | Improvement |
|--------|-------------|--------------|-------------|
| Provisional Response | 150-300ms | ~113ms | ~2x faster |
| Background Analysis | N/A | <2s | Non-blocking |
| User Wait Time | 150-300ms | ~113ms | 40-60% reduction |

### Session State Management

**Script**: `~/.claude/hooks/klaus-session-state.sh`

**Functions**:
- `init_session()` - Create session state file
- `update_context()` - Atomically update session with tier analysis
- `get_context()` - Read current session state
- `cleanup_sessions()` - Remove old session files (>24h)

**Session Files**: `~/.claude/sessions/[SESSION_ID].state.json`

### hooks.json Configuration (for async)

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/klaus-delegation.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

---

## Routing Telemetry

Klaus can optionally track routing decisions for analysis and optimization. **Privacy-first, opt-in only, disabled by default.**

### Configuration

```bash
ENABLE_ROUTING_HISTORY="OFF"       # OFF by default, opt-in only
ROUTING_HISTORY_FILE="${HOME}/.claude/telemetry/routing-history.jsonl"
ROUTING_HISTORY_SANITIZE="ON"      # ON = hash prompts, OFF = plaintext
```

### Data Format

```jsonl
{"timestamp":"2026-01-26T17:00:00Z","prompt_hash":"cb2fea287f...","prompt_length":75,"score":8,"tier":"FULL","context7_relevant":true,"context7_score":12,"matched_patterns":"system architecture research"}
```

### Analysis Tool

```bash
# Basic analysis (last 7 days)
bash ~/.claude/hooks/analyze-routing-accuracy.sh

# Last 30 days with statistics
bash ~/.claude/hooks/analyze-routing-accuracy.sh --days 30 --stats

# Filter by tier
bash ~/.claude/hooks/analyze-routing-accuracy.sh --tier FULL --stats
```

### Privacy Guarantees

1. Disabled by default (ENABLE_ROUTING_HISTORY="OFF")
2. Prompts hashed with SHA-256 by default (SANITIZE="ON")
3. Automatic cleanup of entries >30 days
4. Data never leaves your machine
5. Requires explicit opt-in

---

## Related Documentation

- [Delegation Architecture](02-delegation-architecture.md) - How hooks feed into routing
- [Scoring Algorithm](03-scoring-algorithm.md) - What the hook calculates
- [Configuration & Keywords](04-configuration-keywords.md) - Hook configuration options
- [Testing & Verification](14-testing-verification.md) - Hook test suites
