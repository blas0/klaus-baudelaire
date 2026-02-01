# Memory Management Commands

> **Back to [README](../TLDR-README.md)** | **Prev: [Plan Orchestration](09-plan-orchestration.md)** | **Next: [Agent Team Reference](11-agent-team.md)**

---

## Overview

Klaus provides three commands to manage project documentation in the `.claude/project/` directory. These commands automate the creation, extraction, and synchronization of project knowledge that persists across Claude Code sessions.

---

## /fillmemory

**Purpose**: Initialize project documentation structure.

### What It Does

1. Creates `.claude/project/` directory structure
2. Spawns 6 `explore-light` agents in parallel
3. Fills documentation files:
   - `architecture.md` - System architecture overview
   - `frontend.md` - Frontend structure and patterns
   - `backend.md` - Backend structure and patterns
   - `database.md` - Database schema and queries
   - `infrastructure.md` - Deployment and DevOps setup
   - `testing.md` - Test infrastructure and conventions

### Usage

```
/fillmemory
```

### When to Use

- **New projects**: First time working with a codebase
- **After major refactors**: When architecture has changed significantly
- **Team onboarding**: Help new team members understand the project

### How It Works

The command spawns 6 parallel `explore-light` agents, each responsible for one documentation area. They read the codebase, analyze patterns, and write comprehensive documentation. This runs in parallel for speed.

---

## /compost

**Purpose**: Extract and document project-specific patterns from the codebase.

### What It Does

1. Analyzes actual code implementations
2. Documents patterns in:
   - `standards.md` - Code style conventions (naming, formatting, imports)
   - `coherence.md` - Error handling philosophy and patterns
   - `patterns.md` - Architectural patterns (state management, routing, etc.)

### Usage

```
/compost
```

### When to Use

- **After initial setup**: Once the project has enough code to analyze
- **Periodically**: To keep pattern documentation current
- **Before code reviews**: To ensure new code follows established patterns

### How It Works

The `composter` agent reads source files, identifies recurring patterns, and documents them as project standards. This creates a "living style guide" based on actual code rather than aspirational rules.

---

## /updatememory

**Purpose**: Sync documentation with codebase reality.

### What It Does

1. Detects mismatches between docs and code
2. Fills empty sections
3. Uses `AskUserQuestion` to resolve conflicts
4. Updates documentation after user confirmation

### Usage

```
/updatememory
```

### When to Use

- **After significant changes**: When code has diverged from documentation
- **Regular maintenance**: Weekly or after sprints
- **Before presentations**: Ensure docs reflect current state

### How It Works

The command compares existing `.claude/project/` documentation against the current codebase. When it finds mismatches (e.g., a new database table not documented), it prompts you to confirm the update.

---

## /klaus

**Purpose**: Force FULL tier execution for any prompt.

### What It Does

1. Bypasses automatic tier detection
2. Spawns complete intelligence pipeline:
   - explore-lead + research-lead + web-research-specialist + docs-specialist + plan-orchestrator
3. Creates comprehensive implementation plan
4. Executes with maximum intelligence

### Usage

```
/klaus Design and implement OAuth with JWT, tests, and CI/CD integration
```

### When to Use

- **Complex tasks**: When you know the task needs full research
- **Architecture decisions**: Major design work
- **Unfamiliar territory**: Working with new technologies
- **When automatic routing under-scores**: Force FULL when you disagree with tier

---

## Memory File Structure

After running `/fillmemory` and `/compost`:

```
.claude/
  project/
    architecture.md     # System architecture
    frontend.md         # Frontend structure
    backend.md          # Backend structure
    database.md         # Database schema
    infrastructure.md   # Deployment/DevOps
    testing.md          # Test infrastructure
    standards.md        # Code style conventions
    coherence.md        # Error handling philosophy
    patterns.md         # Architectural patterns
```

These files persist across Claude Code sessions and provide context for all future interactions.

---

## Related Documentation

- [Installation & Setup](01-installation.md) - Post-installation commands
- [Agent Team Reference](11-agent-team.md) - Agents used by memory commands
- [Delegation Architecture](02-delegation-architecture.md) - How /klaus bypasses routing
