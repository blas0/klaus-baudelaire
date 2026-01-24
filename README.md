<p align="center">
  <h1 align="center">
    <u>Klaus Baudelaire</u><br/>
    <sub>The Polymathic Delegation System</sub>
  </h1>
</p>

<p align="center">
  <img src="klaus_claude.jpg" alt="klaus baudelaire" width="600">
</p>

---

<p align="center">
  <strong>
    Klaus was designed from the architectural design of the Claude Code harness, specifically around the focality of hard embedded idiosyncrasies within Claude Code. Instead of protecting his sisters from villains...he serves you, by delegating agents to ship your code with intelligence and precision.
  </strong>
</p>

<p align="center">
  <i>
    If you've read Lemony Snicket or watched the films, you know Klaus is the bookish, astute middle child. Here, instead of outsmarting Count Olaf, he's outsmarting your technical debt by reinforcing Claude Code's native capabilities.
  </i>
</p>

---

> [!CAUTION]
> **_Klaus is production-ready but continuously refined._**
>
> _**This system is actively maintained and documented.**_
>
> _**Expect progressive improvements aligned with Anthropic's Claude Code evolution.**_

---

**Mission Statement:**
_The core focus for Klaus is to reinforce and refine Claude Code's native **out-of-the-box** features, capabilities, and architectural design mechanics. Treating Klaus as a child of Claude - a system aligned through and by Anthropic's mission of AI safety, not against it._

---

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Section I: The Delegation Architecture](#section-i-the-delegation-architecture)
4. [Section II: The Scoring Algorithm](#section-ii-the-scoring-algorithm)
5. [Section III: Configuration & Keywords](#section-iii-configuration--keywords)
6. [Section IV: Managing Memory](#section-iv-managing-memory)
7. [Section V: Klaus's Agent Team](#section-v-klauss-agent-team)
8. [Section VI: Task Management System](#section-vi-task-management-system)
9. [Section VII: The Hooks System](#section-vii-the-hooks-system)
10. [Section VIII: Testing & Verification](#section-viii-testing--verification)
11. [Section IX: Troubleshooting](#section-ix-troubleshooting)
12. [Quick Reference](#quick-reference)

---

## Introduction

### What Is Klaus Baudelaire?

Klaus is an **intelligent task routing infrastructure** that automatically analyzes your prompts and routes them to appropriate execution tiers based on complexity. Like his literary namesake, Klaus reads everything (your prompts), analyzes patterns (complexity scoring), and coordinates his siblings (specialized agents) to solve problems efficiently.

**The Problem Klaus Solves:**
- **Before Klaus**: Manual judgment calls on every task: "Should I use an agent? Which one? Do I need research?"
- **After Klaus**: Automatic analysis routes tasks to optimal tier (DIRECT, LIGHT, MEDIUM, FULL)

### System Components

*Klaus's architecture is organized like a well-catalogued library:*

| Component | Purpose | Location |
|-----------|---------|----------|
| **klaus-delegation.sh** | The librarian - analyzes prompts and coordinates workflow | `~/.claude/hooks/klaus-delegation.sh` |
| **klaus-delegation.conf** | The card catalog - keywords and feature flags | `~/.claude/klaus-delegation.conf` |
| **tiered-workflow.txt** | The reading list - workflow templates for each tier | `~/.claude/hooks/tiered-workflow.txt` |
| **4 Delegation Agents** | The specialists - research, testing, monitoring, file tracking | `~/.claude/agents/*.md` |
| **Supporting Agents** | The assistants - exploration, research, planning, utilities | `~/.claude/agents/*.md` |
| **Test Suite** | The fact-checker - validates scoring and routing logic | `~/.claude/test-klaus-delegation.sh` |

### How Klaus Works (30-Second Overview)

```
Your Prompt → Klaus Analyzes → Calculates Score → Determines Tier → Coordinates Agents → Claude Executes
```

1. **You type**: "Set up OAuth with tests and CI/CD integration"
2. **Klaus analyzes**: Matches keywords (oauth:+2, tests:+3, ci/cd:+2) → Score: 7
3. **Klaus determines**: Score 7 → FULL tier (comprehensive intelligence)
4. **Klaus coordinates**: Spawns Explore + research-lead + web-research-specialist + Plan agents
5. **Claude executes**: Follows workflow autonomously with full context

**Result**: Comprehensive research, planning, and implementation without you manually orchestrating agents.

---

## Installation

Klaus can be installed as a **plugin** (recommended for version control) or **standalone** (simpler for single projects).

### Option 1: Plugin Installation (Recommended)

**Advantages**: Semantic versioning, one-command updates, namespace isolation, marketplace distribution.

```bash
# [1] Add Klaus marketplace
/plugin marketplace add https://github.com/user/klaus-marketplace

# [2] Install Klaus plugin (auto-installs commands & agents)
/plugin install klaus-system@klaus-marketplace

# [3] Configure UserPromptSubmit hook (required workaround for bug #10225)
~/.local/share/claude/plugins/klaus-system/install.sh

# [4] Restart Claude Code
# Exit and restart your Claude Code session
```

**Note**: Step 3 is required until Claude Code fixes plugin hook execution bug [#10225](https://github.com/anthropics/claude-code/issues/10225). The install script safely adds Klaus's delegation hook to your `settings.json`.

**Updating Klaus**:
```bash
/plugin marketplace update
/plugin update klaus-system
```

### Option 2: Standalone Installation

**Advantages**: Shorter command names, no plugin dependencies, simpler setup.

```bash
# [1] Clone Klaus to ~/.claude
git clone https://github.com/user/klaus-system ~/.claude

# [2] Configure UserPromptSubmit hook
~/.claude/install.sh

# [3] Restart Claude Code
# Exit and restart your Claude Code session
```

**Updating Klaus**:
```bash
cd ~/.claude
git pull origin main
```

### Post-Installation

**Verify installation**:
```bash
# Test delegation logic
~/.claude/test-klaus-delegation.sh

# Initialize project memory (recommended for new projects)
/fillmemory
```

**Available commands** (plugin adds `/klaus:` prefix):
- `/fillmemory` (or `/klaus:fillmemory`) - Initialize project documentation
- `/compost` (or `/klaus:compost`) - Extract codebase patterns
- `/updatememory` (or `/klaus:updatememory`) - Sync documentation with code

**Troubleshooting**:
- If Klaus isn't routing tasks, verify `~/.claude/settings.json` contains the UserPromptSubmit hook
- Check hook execution: look for `[DEBUG]` messages in Claude Code output
- Run test suite: `~/.claude/test-klaus-delegation.sh` to validate scoring
- See [Section IX: Troubleshooting](#section-ix-troubleshooting) for common issues

For version history and breaking changes, see [CHANGELOG.md](CHANGELOG.md).

---

## Section I: The Delegation Architecture

*Klaus organizes his work into tiers, like chapters in a book. Simple tasks get quick treatment (DIRECT), while complex problems get the full research team (FULL).*

### Klaus's Tier System

Klaus routes tasks to 4 tiers based on complexity scores:

| Tier | Score | What Klaus Does | Agents Invoked | Use Cases |
|------|-------|-----------------|----------------|-----------|
| **DIRECT** | 0-2 | Executes immediately (like fixing a typo - no research needed) | None | Simple edits, typos, single-file changes |
| **LIGHT** | 3-4 | Quick reconnaissance (checks the codebase card catalog) | explore-light | Straightforward features, basic research |
| **MEDIUM** | 5-6 | Light intelligence team (coordinates multiple specialists) | explore-light + research-light + Plan | Multi-file changes, moderate complexity |
| **FULL** | 7+ | Full research committee (the whole delegation network) | Explore + research-lead + web-research-specialist + Plan | Complex features, architecture changes |

### Klaus's Scoring Algorithm

*Klaus learned to read prompts like books - judging complexity by length, vocabulary, and subject matter.*

**Starting Score:** 0

**Klaus Adds Points For:**
- Prompt length >100 chars: +1 (longer prompts = more detail)
- Prompt length >200 chars: +1 (cumulative)
- Prompt length >400 chars: +2 (cumulative)
- Each COMPLEX_KEYWORDS match: +2 to +3 (signals architectural work)

**Klaus Subtracts Points For:**
- Each SIMPLE_KEYWORDS match: -2 to -4 (signals straightforward work)

**Bounds:**
- Minimum: 0 (Klaus never goes negative - keeps a positive outlook)
- Maximum: 50 (Klaus caps complexity to prevent overthinking)

### How Klaus Coordinates Workflow

When Klaus determines a task needs intelligence (LIGHT/MEDIUM/FULL tier), he injects `tiered-workflow.txt` as additional context:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "[TIERED WORKFLOW TEXT]",
    "metadata": {
      "score": 7,
      "tier": "FULL"
    }
  }
}
```

Claude receives this as context and follows Klaus's recommended workflow autonomously.

---

## Section II: The Scoring Algorithm

*Think of Klaus as a librarian categorizing books by complexity. He uses a weighted system based on prompt characteristics.*

### File Locations

**Hook script**: `~/.claude/hooks/klaus-delegation.sh`
**Configuration**: `~/.claude/klaus-delegation.conf`
**Workflow template**: `~/.claude/hooks/tiered-workflow.txt`

### How Klaus Analyzes Prompts

#### Step 1: Hook Trigger (UserPromptSubmit)

When you submit a prompt, Claude Code invokes all UserPromptSubmit hooks. Klaus is one of them.

**Klaus receives** (JSON via stdin):
```json
{
  "prompt": "Set up OAuth authentication with tests"
}
```

#### Step 2: Skip Conditions

Klaus skips analysis if:
- `SMART_DELEGATE_MODE="OFF"` in config (Klaus is taking a break)
- Prompt starts with `/` (slash commands bypass Klaus's routing)
- Prompt length < 30 characters (too short to analyze properly)

**When skipped, Klaus returns**: `{}`

#### Step 3: Scoring Logic

**Phase 1: Length-based scoring**
```bash
[[ $PROMPT_LENGTH -gt 100 ]] && ((SCORE += 1))
[[ $PROMPT_LENGTH -gt 200 ]] && ((SCORE += 1))
[[ $PROMPT_LENGTH -gt 400 ]] && ((SCORE += 2))
```

**Phase 2: Convert to lowercase** (Klaus reads case-insensitively)
```bash
LOWER_PROMPT=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')
```

**Phase 3: COMPLEX_KEYWORDS (add points)**
```bash
for entry in "${COMPLEX_KEYWORDS[@]}"; do
  pattern="${entry%:*}"     # Extract pattern (before colon)
  weight="${entry#*:}"      # Extract weight (after colon)
  if echo "$LOWER_PROMPT" | grep -qE "($pattern)"; then
    ((SCORE += weight))
  fi
done
```

**Phase 4: SIMPLE_KEYWORDS (subtract points)**
```bash
for entry in "${SIMPLE_KEYWORDS[@]}"; do
  pattern="${entry%:*}"
  weight="${entry#*:}"
  if echo "$LOWER_PROMPT" | grep -qE "($pattern)"; then
    ((SCORE -= weight))
  fi
done
```

**Phase 5: Apply bounds**
```bash
[[ $SCORE -lt 0 ]] && SCORE=0    # Floor at 0 (Klaus stays positive)
[[ $SCORE -gt 50 ]] && SCORE=50  # Cap at 50 (Klaus prevents overthinking)
```

#### Step 4: Tier Determination

```bash
if [[ $SCORE -lt $TIER_LIGHT_MIN ]]; then TIER="DIRECT"      # 0-2
elif [[ $SCORE -lt $TIER_MEDIUM_MIN ]]; then TIER="LIGHT"    # 3-4
elif [[ $SCORE -lt $TIER_FULL_MIN ]]; then TIER="MEDIUM"     # 5-6
else TIER="FULL"; fi                                          # 7+
```

#### Step 5: Output

**For DIRECT tier** (0-2):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "",
    "metadata": {
      "score": 0,
      "tier": "DIRECT"
    }
  }
}
```

**For LIGHT/MEDIUM/FULL** (3+):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "[WORKFLOW CONTENT WITH {{TIER}} REPLACED]",
    "metadata": {
      "score": 7,
      "tier": "FULL"
    }
  }
}
```

---

## Section III: Configuration & Keywords

*Klaus's personality is defined by his configuration - the keywords he recognizes and the thresholds he uses. Easy to configure right out-of-the-box.*

### Configuration Structure

**Location**: `~/.claude/klaus-delegation.conf`

```bash
#!/bin/bash
# klaus-delegation.conf - Klaus's card catalog

# Core Settings
SMART_DELEGATE_MODE="ON"          # Klaus is active
MIN_LENGTH=30                     # Minimum prompt length
DEBUG_MODE="OFF"                  # Debug logging

# Tier Thresholds (Klaus's complexity boundaries)
TIER_LIGHT_MIN=3                  # Score >= 3 → LIGHT
TIER_MEDIUM_MIN=5                 # Score >= 5 → MEDIUM
TIER_FULL_MIN=7                   # Score >= 7 → FULL

# Length-Based Scoring
LENGTH_100_SCORE=1                # Points for >100 chars
LENGTH_200_SCORE=1                # Points for >200 chars
LENGTH_400_SCORE=2                # Points for >400 chars

# COMPLEX_KEYWORDS (array of "pattern:weight")
COMPLEX_KEYWORDS=(
  "system|integrate|architecture|design:3"
  "across|multiple|all files|every|codebase:2"
  "best practice|research:3"
  # ... more keywords
)

# SIMPLE_KEYWORDS (array of "pattern:weight")
SIMPLE_KEYWORDS=(
  "fix typo|add comment|rename|update:4"
  "simple|quick|small|minor:3"
  "this file|this function|this line:2"
  # ... more keywords
)

# Feature Flags (Enable Klaus's specialist agents)
ENABLE_WEB_RESEARCHER="OFF"       # web-research-specialist agent
ENABLE_FILE_PATH_EXTRACTOR="ON"  # file-path-extractor agent (default ON)
ENABLE_TEST_INFRASTRUCTURE="OFF"  # test-infrastructure-agent
ENABLE_REMINDER_SYSTEM="OFF"      # reminder-nudger-agent
```

### How to Modify Klaus's Configuration

**Step 1: Edit the config file:**
```bash
nano ~/.claude/klaus-delegation.conf
# or
code ~/.claude/klaus-delegation.conf
```

**Step 2: Make your changes:**
```bash
# Enable an agent (give Klaus a new specialist)
ENABLE_WEB_RESEARCHER="ON"

# Add a custom keyword (teach Klaus new vocabulary)
COMPLEX_KEYWORDS=(
  "${COMPLEX_KEYWORDS[@]}"        # Preserve existing
  "my custom pattern:3"           # Add new
)

# Adjust tier threshold (change Klaus's judgment)
TIER_FULL_MIN=10                  # Raise bar for FULL tier
```

**Step 3: Restart Claude Code** (Klaus reloads his configuration)

**Step 4: Verify changes:**
```bash
cd ~/.claude
bash test-klaus-delegation.sh       # Run Klaus's test suite
```

### Klaus's Keyword Dictionary

*Klaus learned these keywords by reading thousands of prompts. He knows when you're asking for simple work versus complex research.*

#### Complex Keywords (Positive Scoring)

*These patterns tell Klaus: "This needs research, planning, or architectural thinking."*

| Pattern | Weight | Example Prompt | Why Klaus Cares |
|---------|--------|----------------|-----------------|
| `system\|integrate\|architecture\|design` | +3 | "system architecture for the project" | Architectural work requires deep research |
| `across\|multiple\|all files\|every\|codebase` | +2 | "refactor across multiple files" | Multi-file changes need careful planning |
| `best practice\|research` | +3 | "research best practices for React" | Explicit research request |
| `set up tests\|test infrastructure` | +3 | "set up test infrastructure" | Test setup requires comprehensive planning |
| `investigate\|deep dive\|thorough analysis` | +3 | "investigate performance issue" | Deep analysis signals complex work |
| `compare.*versus\|compare.*with` | +3 | "compare React versus Vue" | Comparative research needs multiple sources |
| `initialize project\|scaffold\|bootstrap` | +3 | "bootstrap new project" | Project initialization is complex |
| `oauth\|authentication.*provider\|authorization` | +2 | "add OAuth with Google" | Auth systems need careful implementation |
| `database migration\|schema changes` | +3 | "create database migration" | Schema work affects data integrity |
| `api integration\|rest\|graphql` | +2 | "integrate REST API" | API work needs documentation research |
| `docker\|containerization\|deployment` | +2 | "set up Docker" | Infrastructure requires planning |
| `ci/cd\|github actions\|pipeline` | +2 | "configure CI/CD" | DevOps workflows are multi-step |
| `benchmark\|performance analysis` | +3 | "benchmark database queries" | Performance work needs measurement |
| `and.*also\|as well as\|plus\|additionally` | +2 | "add tests and also docs" | Multi-task detection |
| `not only.*but also\|both.*and` | +3 | "not only tests but also CI" | Complex multi-task coordination |

**Pattern Syntax**: Extended regex (grep -E compatible)
- `|` = OR operator (matches any alternative)
- `.*` = any characters (greedy matching)
- No anchors (pattern can match anywhere in prompt)

#### Simple Keywords (Negative Scoring)

*These patterns tell Klaus: "This is straightforward - no need for the full research team."*

| Pattern | Weight | Example Prompt | Why Klaus Cares |
|---------|--------|----------------|-----------------|
| `fix typo\|add comment\|rename\|update` | -4 | "fix typo in README" | Simple maintenance tasks |
| `simple\|quick\|small\|minor` | -3 | "make a quick change" | Explicitly simple work |
| `this file\|this function\|this line` | -2 | "update this file" | Single-location work |
| `just\|only\|simply` | -2 | "just add a comment" | Minimizing language signals simplicity |
| `straightforward\|basic\|elementary` | -2 | "straightforward refactor" | Explicitly basic work |
| `single file\|this specific\|that specific` | -3 | "modify single file" | Narrow scope |
| `skip.*research\|no need to.*` | -2 | "skip research, just implement" | Explicit bypass request |
| `what is\|where is\|how do i\|show me` | -2 | "where is config file?" | Simple informational question |
| `explain\|describe\|clarify` | -2 | "explain this function" | Explanatory request |

#### How Klaus Matches Patterns

**Example**: Prompt "Set up OAuth authentication with tests"

1. Klaus converts to lowercase: "set up oauth authentication with tests"
2. Klaus checks COMPLEX_KEYWORDS:
   - "set up tests" matches → +3 points
   - "oauth" matches → +2 points
   - Running score = 5
3. Klaus checks SIMPLE_KEYWORDS:
   - No matches
   - Final score = 5 (unchanged)
4. Klaus determines: Score 5 → MEDIUM tier

**Important**: Each pattern matches **once** and awards its weight. Pattern "system|integrate|architecture" awards +3 if **ANY** of those words appear, not +3 per word.

### The Workflow Template

**Location**: `~/.claude/hooks/tiered-workflow.txt`

This file is Klaus's instruction manual - he injects it as context when coordination is needed (LIGHT/MEDIUM/FULL tiers).

#### Template Structure

```
TIERED IMPLEMENTATION PIPELINE ({{TIER}} MODE)

CURRENT TIER: {{TIER}}

[Klaus explains the tier routing logic]

PHASE 1-LIGHT: Quick Context
- Launch explore-light (quick reconnaissance)
- Optional: web-research-specialist (if enabled)

PHASE 1-MEDIUM: Light Intelligence
- Launch explore-light + research-light in parallel
- Optional: file-path-extractor (if enabled)
- Then Plan agent (design implementation)

PHASE 1-FULL: Full Intelligence
- Launch Explore + research-lead + web-research-specialist in parallel
- Optional: file-path-extractor (if enabled)
- Then Plan agent (comprehensive planning)

IMPLEMENTATION (all tiers)
[1] Edit/Write files (implementation)
[2] Run tests, fix if needed (max 3 attempts)
[3] Summarize changes (documentation)

[NEW] SPECIALIZED AGENTS (Optional):
- web-research-specialist (focused web research)
- file-path-extractor (track file access)
- test-infrastructure-agent (test setup)
- reminder-nudger-agent (progress monitoring)
- code-simplifier (refactoring suggestions)
```

**Template substitution**: Klaus replaces `{{TIER}}` with actual tier (LIGHT/MEDIUM/FULL) before injection.

---

## Section IV: Managing Memory

*Managing memory is where Klaus excels - organizing project documentation like a well-maintained library. I understand that everyone has their own method of managing memory. Letting an agent manage your codebase memory can cause technical debt, which is why Klaus was specifically designed according to Claude's native design. The commands are manually invocable to prevent edge cases from execution of wandered judgment.*

### Memory Scaffolding

Klaus scaffolds your `.claude/` directory structure to match Claude Code's native expectations:

```
$CLAUDE_PROJECT_DIR/.claude/
  rules/
    project-index.md         # Index to all documentation
  project/
    architecture.md          # System architecture
    frontend.md             # Frontend structure
    backend.md              # Backend structure
    database.md             # Database schema
    infrastructure.md       # Deployment/DevOps
    testing.md              # Test infrastructure
    standards/
      standards.md          # Code style standards
      coherence.md          # Logical philosophy
      patterns.md           # Design patterns
```

### Memory Commands

#### /fillmemory

**Location**: `~/.claude/commands/fillmemory.md`

**Purpose**: Analyzes project and fills all documentation files in `.claude/project/` directory.

**What Klaus does:**

**Phase 1: Scaffold Structure**
1. Validates `$CLAUDE_PROJECT_DIR` is set
2. Checks if all docs exist and have content
3. If needed, backs up existing `rules/` and `project/` to `.backup.claude.rules-project/`
4. Creates directory structure
5. Creates template files with `<excerpt>` instructions

**Phase 2: Fill Documentation**
1. Spawns 6 `@"explore-light"` agents in **parallel** (Klaus coordinates his team)
2. Each agent analyzes codebase per `<excerpt>` instructions in:
   - `architecture.md` - System architecture, tech stack, directory tree
   - `frontend.md` - Frontend structure, components, UI patterns
   - `backend.md` - Backend architecture, APIs, services
   - `database.md` - Database schema, models, migrations
   - `infrastructure.md` - Deployment, CI/CD, containers
   - `testing.md` - Test infrastructure, frameworks, coverage
3. Each agent replaces `<excerpt>` with comprehensive analysis

**Files NOT processed**: `standards/` subdirectory (use `/compost` instead)

**Usage:**
```
/fillmemory
```

**When to use:**
- New project (initialize documentation)
- Documentation is outdated or missing
- Want comprehensive project overview

---

#### /compost

**Location**: `~/.claude/commands/compost.md`

**Purpose**: Extracts and documents project-specific standards, patterns, and coherence principles from actual codebase implementations.

**What Klaus does:**

Invokes `@"composter"` agent to process 3 standards files:

1. **standards.md**
   - Code style conventions
   - Formatting rules
   - Naming patterns
   - Import/dependency organization

2. **coherence.md**
   - Error handling philosophy
   - State management approach
   - Data flow patterns
   - Conceptual consistency

3. **patterns.md**
   - Architectural patterns (MVC, layered, event-driven)
   - Design patterns (Factory, Observer, Strategy)
   - Integration patterns (API contracts, events)
   - Data patterns (access, transformation, validation)

**Process:**
1. Agent reads `[introduction]` blocks (philosophical intent)
2. Analyzes codebase for concrete examples
3. Fills sections with real code (file paths + line numbers)
4. Preserves introductions verbatim

**Critical scope limitation:**
- ONLY interacts with files in `$CLAUDE_PROJECT_DIR/.claude/project/`
- ONLY edits files in `$CLAUDE_PROJECT_DIR/.claude/project/standards/`

**Usage:**
```
/compost
```

**When to use:**
- After `/fillmemory` (architecture docs exist)
- Want to document actual code patterns (not invented)
- Onboarding new developers (show real examples)
- Enforce consistency (document what exists)

---

#### /updatememory

**Location**: `~/.claude/commands/updatememory.md`

**Purpose**: Syncs documentation with codebase reality, identifies discrepancies, fills gaps, prompts user to resolve conflicts.

**What Klaus does:**

**Phase 1: Scaffold Detection**
1. Checks if `.claude/` structure exists
2. If NOT: `[!!!] You need to run /fillmemory before updating memory.` (exits)

**Phase 2: Gap Analysis & Sync**
1. Spawns 6 agents in **parallel** to analyze:
   - `architecture.md`
   - `frontend.md`
   - `backend.md`
   - `database.md`
   - `infrastructure.md`
   - `testing.md`

2. Each agent:
   - Reads documentation file + relevant codebase
   - Identifies empty sections, unfilled `<excerpt>` tags
   - Detects mismatches (docs say X, code does Y)
   - Uses `AskUserQuestion` for conflicts: "Code uses [actual] but docs say [documented]. Which is correct?"
   - Updates documentation after user confirmation
   - Fills remaining gaps

**Files NOT processed**: `standards/` subdirectory (use `/compost` instead)

**Usage:**
```
/updatememory
```

**When to use:**
- Code changed since last `/fillmemory`
- Documentation is stale
- Want to verify docs match reality
- Quarterly/monthly documentation refresh

**User interaction**: Agent may pause to ask questions when conflicts detected.

---

#### /klaude

**Location**: `~/.claude/commands/klaude.md`

**Purpose**: Manual invocation of 3-agent intelligence pipeline (Explore + web-research + Plan).

**What Klaus does:**

Spawns 3 agents in **parallel** (Klaus's core intelligence team):
1. **Explore agent**: Searches codebase for architecture, patterns, files
2. **web-researcher agent**: Researches best practices and documentation
3. **Plan agent**: Designs implementation approaches

Then synthesizes findings and presents plan for approval.

**Usage:**
```
/klaude implement authentication with OAuth2
/klaude research API documentation for Gemini and Claude
/klaude refactor the user management system
```

**When to use:**
- Complex implementation requiring research + planning
- Want explicit control (instead of automatic routing)
- Need comprehensive context before implementation
- Prefer manual workflow invocation

**Relationship to smart-delegate**: Alternative to automatic FULL tier routing. `/klaude` gives manual control over 3-agent workflow.

---

## Section V: Klaus's Agent Team

*Klaus doesn't work alone - he coordinates a team of specialized agents, each with specific expertise. Think of them as Klaus's siblings and colleagues, each bringing unique skills to solve your problems.*

### Agent Categories

Klaus's team falls into 4 categories:

1. **Delegation Agents** (4 agents - Klaus's specialists)
   - web-research-specialist (the web researcher)
   - file-path-extractor (the file tracker)
   - test-infrastructure-agent (the test architect)
   - reminder-nudger-agent (the progress monitor)

2. **Built-in Research Agents** (Claude Code provided - Klaus's research team)
   - Explore (deep codebase exploration)
   - explore-light (quick reconnaissance)
   - research-lead (comprehensive research coordinator)
   - research-light (quick web research)
   - research-subagent (depth-first research worker)
   - Plan (implementation planning)

3. **Utility Agents** (Klaus's helpers)
   - code-simplifier (refactoring consultant)
   - composter (standards documenter)

4. **Other Built-in Agents** (see Claude Code docs)

### Delegation Agents (Klaus's Specialists)

#### web-research-specialist

**Location**: `~/.claude/agents/web-research-specialist.md`

**Purpose**: Focused web research for documentation, best practices, and code examples. Klaus's go-to researcher for quick answers.

**Model**: Sonnet (complex reasoning)
**Tools**: WebSearch, WebFetch, Read, Write
**Feature Flag**: `ENABLE_WEB_RESEARCHER="OFF"`

**When Klaus uses this agent:**
- Need current documentation or API reference
- Research framework best practices
- Gather code examples and snippets
- Compare approaches from multiple sources

**Process:**
1. **Discovery Phase**: 3-5 web_search calls (broad queries, <5 words)
2. **Deep Dive Phase**: 2-3 web_fetch calls (full content retrieval)
3. **Synthesis Phase**: Consolidate findings with citations

**Output format:**
```markdown
## Summary
[1-2 sentence overview]

## Findings
- [Fact + source URL]
- [Fact + source URL]

## Conflicts/Gaps
- [Conflicting information noted]
- [What couldn't be found]
```

**Tool call limits**: Max 20 total, typical ~10

**How to invoke:**
```
@"web-research-specialist" research OAuth best practices for Node.js
```

**When enabled in workflow**: Appears in LIGHT/FULL tiers when `ENABLE_WEB_RESEARCHER="ON"`

---

#### file-path-extractor

**Location**: `~/.claude/agents/file-path-extractor.md`

**Purpose**: Extracts file paths from bash command output and determines if commands display file contents. Klaus's file librarian.

**Model**: Haiku (optimized for speed)
**Tools**: Read, Grep, Glob (read-only)
**Feature Flag**: `ENABLE_FILE_PATH_EXTRACTOR="ON"` (enabled by default)

**When Klaus uses this agent:**
- After bash commands that output file information
- Track which files were accessed during debugging
- Build context about file relationships
- Log file reads for session summary

**Detection logic:**

**Commands that display contents** (`is_displaying_contents: true`):
- `cat`, `less`, `more`, `head`, `tail`
- `git diff`, `git show`, `git log -p`
- `grep -A`, `grep -B`, `grep -C` (with context flags)

**Commands that do NOT display contents** (`is_displaying_contents: false`):
- `ls`, `find`, `locate`, `pwd`
- `git status`, `git log` (without -p)

**Output format:**
```json
{
  "is_displaying_contents": true,
  "filepaths": ["/absolute/path/to/file1", "/absolute/path/to/file2"]
}
```

**How to invoke:**
```
@"file-path-extractor" [pass bash command output]
```

**When enabled in workflow**: Available in MEDIUM/FULL tiers after bash commands when `ENABLE_FILE_PATH_EXTRACTOR="ON"`

---

#### test-infrastructure-agent

**Location**: `~/.claude/agents/test-infrastructure-agent.md`

**Purpose**: Sets up complete test infrastructure for projects. Klaus's test architect who strongly prefers `bun:test`.

**Model**: Sonnet
**Tools**: Write, Edit, Bash, Read, Glob, Grep
**Feature Flag**: `ENABLE_TEST_INFRASTRUCTURE="OFF"`

**When Klaus uses this agent:**
- "set up tests"
- "test infrastructure"
- "configure testing"
- "add tests to project"

**Process:**

**1. Discovery Phase**
- Check for `package.json`, `tsconfig.json`, `bun.lockb`
- Detect existing test framework
- Identify project type (Bun, Node.js, TypeScript)

**2. Setup Phase**
- Create test directory structure (`test/` or `__tests__/`)
- Generate example test file with proper imports
- Configure test runner (prefer bun:test)

**3. Configuration Phase**
- Create `bunfig.toml` or `vitest.config.ts`
- Set up coverage reporting (80% threshold default)
- Add test scripts to package.json

**4. Integration Phase**
- Create GitHub Actions workflow (`.github/workflows/test.yml`)
- Configure CI/CD test integration

**Critical rule**: **ALWAYS uses `bun` commands** (from CLAUDE.md requirement)
- ✓ `bun test`
- ✓ `bun install`
- ✗ `npm test`
- ✗ `npx vitest`

**What Klaus's test agent creates:**
```
test/
  setup.ts              # Test configuration
  example.test.ts       # Example test with bun:test
  helpers/
    fixtures.ts         # Test data
    mocks.ts           # Mock utilities

bunfig.toml            # Bun test config
package.json           # Updated with test scripts
.github/workflows/test.yml  # CI/CD integration
```

**How to invoke:**
```
@"test-infrastructure-agent" set up comprehensive test infrastructure
```

**When enabled in workflow**: Available when `ENABLE_TEST_INFRASTRUCTURE="ON"` and prompt matches trigger keywords

---

#### reminder-nudger-agent

**Location**: `~/.claude/agents/reminder-nudger-agent.md`

**Purpose**: Monitors progress during task execution and provides strategic nudges when stagnation is detected. Klaus's progress monitor.

**Model**: Haiku (fast monitoring)
**Tools**: Read, Write, Bash
**Feature Flag**: `ENABLE_REMINDER_SYSTEM="OFF"`

**When Klaus uses this agent:**
- Long-running tasks (>5 min)
- Complex implementations prone to rabbit holes
- Multi-step workflows where focus can drift

**Stagnation Detection:**

**Time-based triggers:**
- Same operation for >2 minutes without progress
- Single file edited >5 times consecutively
- No file changes after 10+ tool calls

**Milestone-based triggers:**
- Writing code without prior research
- 3+ consecutive file edits without test runs
- Creating architecture without exploration phase

**Pattern-based triggers:**
- Over-engineering (abstractions for single use)
- Rabbit holes (exploring unrelated code)
- Repetitive failures (same error 3+ times)
- Analysis paralysis (researching without implementing)

**4-Level Escalation Protocol:**

**Level 1: Self-Correction** (`[!]`)
```
[!] TASK STEERING REMINDER

Suggestion: You've edited this file 6 times. Consider running tests.
Consider: Testing incrementally catches issues earlier.
```

**Level 2: Lead Agent Intervention** (`[!!]`)
```
[!!] AGENT STEERING REMINDER

Observation: Same file edited 8 times with no test runs.
Recommendation: Run tests now before additional changes.
```

**Level 3: User Intervention** (`[!!!]`)
```
[!!!] ESCALATION ALERT

Issue: Unable to proceed without clarification on requirements.
Action Required: User input needed to resolve ambiguity.
```

**Level 4: Timeout/Abort** (`[!!!]`)
```
[!!!] TIMEOUT WARNING

Issue: Task exceeding expected time (>15 min with no progress).
Action Required: Consider breaking into smaller tasks or alternative approach.
```

**Configuration** (in klaus-delegation.conf):
```bash
REMINDER_STAGNATION_TIMEOUT=120    # 2 minutes
REMINDER_TOOL_CALL_THRESHOLD=15    # 15 tool calls
REMINDER_ESCALATION_LEVELS=4       # 4 escalation levels
```

**How to invoke**: Automatically monitors when `ENABLE_REMINDER_SYSTEM="ON"`

**When enabled in workflow**: Active monitoring during MEDIUM/FULL tier execution

---

### Built-in Research Agents (Klaus's Research Team)

*These agents are provided by Claude Code and integrated into Klaus's delegation workflow.*

#### Explore

**Purpose**: Comprehensive codebase exploration with deep analysis (Klaus's deep researcher)

**Model**: Sonnet
**Tools**: All tools
**Tool call budget**: ~50-100 calls

**When Klaus uses this**: FULL tier tasks requiring deep codebase understanding

**Process:**
1. Broad discovery (glob patterns, directory structure)
2. Targeted searches (grep for specific patterns)
3. File reading (understand implementations)
4. Synthesis (map relationships and patterns)

**Invoked by**: FULL tier workflow

---

#### explore-light

**Purpose**: Quick codebase context gathering (Klaus's reconnaissance specialist)

**Model**: Haiku
**Tools**: Glob, Grep, Read
**Tool call budget**: ~10-15 calls

**When Klaus uses this**: LIGHT/MEDIUM tier tasks needing basic context

**Process:**
1. Quick pattern matching (glob for relevant files)
2. Targeted grep (find key implementations)
3. Minimal file reading (understand structure)

**Invoked by**: LIGHT/MEDIUM tier workflow

---

#### research-lead

**Purpose**: Comprehensive web research coordinator that spawns research-subagent workers (Klaus's research team leader)

**Model**: Sonnet
**Tools**: All tools + Task (can spawn subagents)
**Tool call budget**: ~30-50 calls + subagent delegation

**When Klaus uses this**: FULL tier tasks requiring multi-source web research

**Process:**
1. Break research into sub-questions
2. Spawn research-subagent for each question
3. Coordinate parallel research efforts
4. Synthesize findings from all subagents
5. Identify conflicts and gaps

**Invoked by**: FULL tier workflow

---

#### research-light

**Purpose**: Quick web research for simple queries (Klaus's quick researcher)

**Model**: Haiku
**Tools**: WebSearch, WebFetch
**Tool call budget**: ~5-10 calls

**When Klaus uses this**: MEDIUM tier tasks needing quick web lookup

**Process:**
1. 1-2 targeted web searches
2. 1-2 web fetches for details
3. Quick synthesis

**Invoked by**: MEDIUM tier workflow

---

#### research-subagent

**Purpose**: Depth-first research worker spawned by research-lead (Klaus's research assistant)

**Model**: Sonnet
**Tools**: WebSearch, WebFetch, Read, Write
**Tool call budget**: ~20 calls per subagent

**When Klaus uses this**: Spawned automatically by research-lead for parallel research

**Process:**
1. Focus on assigned sub-question
2. Multiple web searches (varying query approaches)
3. Deep fetch and analysis
4. Return findings to research-lead

**Invoked by**: research-lead agent (not directly by user)

---

#### Plan

**Purpose**: Implementation planning and architecture design (Klaus's strategic planner)

**Model**: Sonnet
**Tools**: All tools except Task (cannot spawn subagents)
**Tool call budget**: ~30-50 calls

**When Klaus uses this**: MEDIUM/FULL tier tasks after exploration/research phase

**Process:**
1. Review exploration findings
2. Consider multiple approaches
3. Design implementation steps
4. Identify risks and dependencies
5. Present plan for approval

**Invoked by**: MEDIUM/FULL tier workflow (after exploration phase)

---

### Utility Agents (Klaus's Helpers)

#### code-simplifier

**Location**: `~/.claude/agents/code-simplifier.md`

**Purpose**: Refactors code for clarity, consistency, and maintainability while preserving functionality. Klaus's refactoring consultant.

**Model**: Haiku (speed)
**Tools**: Read, Grep, Glob (read-only)

**When Klaus uses this:**
- After writing/modifying code
- Code review enforcement
- Identifying simplification opportunities

**Key capabilities:**
- Detects nested ternaries (suggests switch/if-else)
- Identifies complex nesting (>3 levels)
- Finds redundant code and abstractions
- Checks inconsistent naming
- Validates type annotations
- Ensures proper function style (arrow vs function keyword)

**Hook integration**: Can be called from PostToolUse hooks, returns JSON:
```json
{
  "issue": "Nested ternary at line 42",
  "fix": "Replace with if-else for clarity",
  "reason": "Improves readability and debugging"
}
```

**Returns when code is clean**: `{"issue":null,"fix":null,"reason":null}`

**How to invoke:**
```
@"code-simplifier" review recent changes for simplification
```

---

#### composter

**Location**: `~/.claude/agents/composter.md`

**Purpose**: Extracts and documents project-specific standards, patterns, and coherence principles from actual codebase. Klaus's standards documenter.

**Model**: Sonnet
**Tools**: Glob, Grep, Read, Edit

**When Klaus uses this**: Via `/compost` command

**What it does:**
1. Reads `[introduction]` blocks in standards files (understand intent)
2. Analyzes codebase for examples matching intent
3. Fills documentation with real code examples (file:line references)
4. Preserves philosophical introductions verbatim

**Critical rules:**
- ONLY extracts what exists (never invents standards)
- All examples include file paths and line numbers
- If no examples: `<!-- No examples found in current codebase -->`
- ONLY edits files in `$CLAUDE_PROJECT_DIR/.claude/project/standards/`

**Files processed:**
- `standards.md` - Code style, formatting, naming conventions
- `coherence.md` - Logical philosophy, consistency patterns
- `patterns.md` - Architectural blueprints, design patterns

**How to invoke**: Via `/compost` command

---

## Section VI: Task Management System

*Claude Code 2.1.16 introduced a native task management system designed for complex, multi-step work. Klaus uses this for coordination - not for every operation.*

### What Changed in Claude Code 2.1.16

**Tool Evolution:**
- **Before**: Single `TodoWrite` tool for simple task lists
- **After**: Four specialized tools:
  - `TaskCreate` - Creates tasks with dependencies
  - `TaskGet` - Retrieves task details
  - `TaskList` - Lists all tasks with status
  - `TaskUpdate` - Updates status, dependencies, metadata

**New Capabilities:**
- **Dependency tracking**: Tasks can block/be blocked by other tasks
- **Persistence**: Tasks survive context compactions
- **Multi-session coordination**: Share tasks via `CLAUDE_CODE_TASK_LIST_ID`
- **UI integration**: Press `Ctrl+T` to toggle task list view
- **Status tracking**: `pending`, `in_progress`, `completed` with indicators

### Klaus's Task Philosophy

**Simplicity < Complexity** - Tasks are for coordination, not every operation.

**When Main Claude Uses Tasks:**
- Complex multi-step implementations (3+ dependent operations)
- Work requiring dependency tracking (Task A blocks Task B)
- Projects benefiting from progress visualization
- Cross-session coordination (multiple Claude instances)

**When Tasks Are NOT Used:**
- Research operations (explore-light, research-lead) - Fluid, ephemeral
- Simple edits or single-file changes - Overhead not justified
- Quick fixes or typo corrections - Direct execution faster
- Atomic operations with no dependencies - Tasks add friction

**Integration with reminder-nudger:**

The reminder-nudger-agent has READ-ONLY task monitoring:
- `TaskList` - Monitor overall progress and detect stagnation
- `TaskGet` - Inspect specific stuck tasks for context

This allows stagnation detection based on task state:
- Task in `in_progress` >2 minutes without `TaskUpdate`
- 3+ tasks with `blockedBy` dependencies creating bottlenecks
- Growing task count with <30% completion (analysis paralysis)
- Task explosion: 10+ tasks with <10% completion

**No Automatic Task Creation:**

Klaus's delegation hook (`klaus-delegation.sh`) does NOT auto-create tasks because:
- DIRECT/LIGHT tier work doesn't need tracking
- Tasks should be deliberate decisions, not automatic noise
- Main Claude naturally uses `TaskCreate` when complexity warrants it
- Hooks can't invoke tools (architectural limitation)

### Task Management Commands

**View tasks:**
```bash
# In Claude Code session
Ctrl+T                    # Toggle task list view
"show me all tasks"       # Ask Claude to display
"clear all tasks"         # Ask Claude to clear

# Keyboard shortcuts
Ctrl+T                    # Task list view (shows 10 at a time)
```

**Share tasks across sessions:**
```bash
# Terminal 1
export CLAUDE_CODE_TASK_LIST_ID=my-project
claude

# Terminal 2 (shares same task list)
export CLAUDE_CODE_TASK_LIST_ID=my-project
claude
```

**Slash commands:**
```bash
/tasks                    # List background tasks (NOT same as TaskList)
/todos                    # List TODO items (legacy command)
```

### Example Task Workflow

**Scenario**: Implementing OAuth authentication (complex, multi-step)

1. **Main Claude creates tasks**:
   ```
   Task #1: Research OAuth libraries
   Task #2: Design auth flow (blockedBy: #1)
   Task #3: Implement endpoints (blockedBy: #2)
   Task #4: Write tests (blockedBy: #3)
   ```

2. **reminder-nudger monitors**:
   - Detects Task #3 stuck in `in_progress` for 3 minutes
   - Uses `TaskGet` to inspect: "Waiting for API credentials"
   - Injects steering: "Consider moving to Task #4 while waiting"

3. **Progress tracked**:
   - User presses `Ctrl+T` to see visual progress
   - Tasks persist through context compaction
   - Clear completion indicators guide work

---

## Section VII: The Hooks System

*Hooks are Klaus's way of listening to events in Claude Code's lifecycle. Think of them as Klaus's sensors - they detect when you submit a prompt, when a tool is used, when a session starts.*

### What Are Hooks?

Hooks are **bash scripts** that Claude Code invokes at specific lifecycle events. They can:
- Block/allow tool calls (via exit codes)
- Add context (via `additionalContext` JSON field)
- Modify inputs (via `updatedInput` JSON field)

**Critical limitation**: Hooks run as external subprocesses and **cannot** invoke slash commands or trigger agent spawning. They can only provide data/context.

### Available Hook Events

| Event | When Fired | Klaus's Use Cases | Input Format |
|-------|------------|-------------------|--------------|
| **UserPromptSubmit** | User submits prompt | Route tasks, add context | `{"prompt":"user text"}` |
| **PreToolUse** | Before tool execution | Block dangerous commands | `{"tool":"Bash","input":{...}}` |
| **PostToolUse** | After tool execution | Log results, track files | `{"tool":"Bash","output":"..."}` |
| **Stop** | Session ends | Cleanup, save state | `{}` |

### Hook Output Format

Hooks communicate via **JSON to stdout**:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Text to add as context for Claude",
    "updatedInput": {"modified":"input"},
    "metadata": {"custom":"data"}
  }
}
```

**Exit codes:**
- `0` = Success, continue
- `1` = Block (for PreToolUse hooks)
- `2+` = Error

### klaus-delegation.sh (UserPromptSubmit Hook)

**Location**: `~/.claude/hooks/klaus-delegation.sh`

**Purpose**: Analyzes prompt complexity and injects appropriate workflow. Klaus's main coordination logic.

See [Section II: The Scoring Algorithm](#section-ii-the-scoring-algorithm) for complete details.

---

## Section VIII: Testing & Verification

*Klaus maintains a comprehensive test suite to verify his judgment is sound. Like any good researcher, Klaus fact-checks his own work.*

### Test Suite

**Location**: `~/.claude/test-klaus-delegation.sh`

**Purpose**: Validates scoring logic, tier routing, agent loading, workflow integration, and backward compatibility.

#### Running Klaus's Test Suite

```bash
cd ~/.claude
bash test-klaus-delegation.sh
```

**Expected output:**
```
Testing klaus-delegation.sh scoring system
========================================

[27 test outputs...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total: 27 | Passed: 27 | Failed: 0
All tests passed!

Execution time: ~1.5 seconds
```

#### What Klaus Tests

**Scoring logic (10 tests):**
- Score upper bound (capped at 50)
- Score floor (minimum 0)
- Keyword conflict detection (COMPLEX - SIMPLE)
- Threshold boundaries (tier routing)
- New COMPLEX_KEYWORDS working
- New SIMPLE_KEYWORDS working
- Special character handling
- Case sensitivity (converts to lowercase)
- Length-based scoring (>100, >200, >400 chars)

**Configuration (2 tests):**
- Config file loads without errors
- Feature flags exist and load

**Agents (4 tests):**
- web-research-specialist exists, valid frontmatter
- file-path-extractor exists, valid frontmatter
- test-infrastructure-agent exists, valid frontmatter
- reminder-nudger-agent exists, valid frontmatter

**Integration (2 tests):**
- Workflow includes all specialist agents
- Specialist agents don't affect scoring (no regression)

**Backward compatibility (1 test):**
- Old prompts still route to same tiers

#### Manual Testing

**Test individual prompts:**
```bash
cd ~/.claude

# Test Klaus's score calculation
echo '{"prompt":"YOUR PROMPT HERE"}' | bash hooks/klaus-delegation.sh | jq '.hookSpecificOutput.metadata'

# Example outputs:
# Simple: {"score":0,"tier":"DIRECT"}
# Medium: {"score":5,"tier":"MEDIUM"}
# Complex: {"score":10,"tier":"FULL"}
```

**Test with debug mode:**
```bash
# Edit klaus-delegation.conf
DEBUG_MODE="ON"

# Run test
echo '{"prompt":"test prompt"}' | bash hooks/klaus-delegation.sh

# Check for debug output showing keyword matches
```

**Test agent loading:**
```bash
# List Klaus's agent team
ls -la ~/.claude/agents/

# Check frontmatter
head -10 ~/.claude/agents/web-research-specialist.md
```

**Test workflow integration:**
```bash
# Check workflow includes Klaus's agents
grep "web-research-specialist\|file-path-extractor\|test-infrastructure-agent\|reminder-nudger-agent" ~/.claude/hooks/tiered-workflow.txt
```

#### Continuous Verification

**After configuration changes:**
```bash
bash test-klaus-delegation.sh
```

**After keyword additions:**
```bash
# Test the new keyword
echo '{"prompt":"prompt with new keyword pattern"}' | bash hooks/klaus-delegation.sh | jq '.hookSpecificOutput.metadata.score'
```

**After agent modifications:**
```bash
# Verify frontmatter still valid
head -10 ~/.claude/agents/<agent-name>.md | grep "^name:\|^model:\|^tools:"
```

---

## Section IX: Troubleshooting

*Even Klaus makes mistakes sometimes (though rarely). Here's how to diagnose and fix issues when Klaus's judgment seems off.*

### Common Issues

#### Issue 1: Agent Not Loading

**Symptoms:**
- Agent doesn't appear in Claude Code
- Error: "agent not found"

**Diagnosis:**
```bash
# Check file exists
ls -la ~/.claude/agents/<agent-name>.md

# Check frontmatter
head -10 ~/.claude/agents/<agent-name>.md
```

**Solutions:**

1. **Verify file location**: Must be in `~/.claude/agents/`

2. **Check frontmatter syntax**:
   ```yaml
   ---
   name: agent-name
   description: "Description here"
   model: sonnet
   tools: Read, Write
   permissionMode: default
   color: yellow
   ---
   ```
   - Must start and end with `---`
   - Must have: `name`, `description`, `model`, `tools`
   - No syntax errors (colons, quotes, indentation)

3. **Restart Claude Code**: Agents load at session start (Klaus reloads his team)

4. **Check for YAML errors**:
   ```bash
   # Install yq if needed: brew install yq
   yq eval '.name' ~/.claude/agents/<agent-name>.md
   ```

---

#### Issue 2: Wrong Tier Routing

**Symptoms:**
- Prompt routes to unexpected tier
- FULL when expecting LIGHT (or vice versa)

**Diagnosis:**
```bash
# Check Klaus's exact score
echo '{"prompt":"YOUR PROMPT"}' | bash ~/.claude/hooks/klaus-delegation.sh | jq '.hookSpecificOutput.metadata'
```

**Common causes:**

1. **Prompt too short** (<30 chars)
   - Returns: `{}` (skipped)
   - Solution: Add more context (>30 chars)

2. **SIMPLE_KEYWORDS overwhelm COMPLEX_KEYWORDS**
   - Example: "just simple system architecture" → "just" (-2) + "simple" (-3) + "system" (+3) = -2 → 0 (floored)
   - Solution: Rephrase to avoid SIMPLE_KEYWORDS

3. **Pattern doesn't match**
   - Keywords use extended regex (grep -E)
   - Check pattern syntax: `echo "test prompt" | grep -qE "(pattern)" && echo "match"`

4. **Config not loaded**
   - Test: `bash -c 'source ~/.claude/klaus-delegation.conf && echo "OK"'`
   - If error: Fix syntax in config file

**Debug mode:**
```bash
# Edit ~/.claude/klaus-delegation.conf
DEBUG_MODE="ON"

# Run prompt and check Klaus's reasoning
echo '{"prompt":"test"}' | bash ~/.claude/hooks/klaus-delegation.sh 2>&1
```

---

#### Issue 3: Feature Flag Not Working

**Symptoms:**
- Agent doesn't appear in workflow despite flag = "ON"
- Changes don't take effect

**Diagnosis:**
```bash
# Check flag syntax
grep "ENABLE_" ~/.claude/klaus-delegation.conf

# Check workflow
grep "agent-name" ~/.claude/hooks/tiered-workflow.txt
```

**Solutions:**

1. **Verify flag syntax**:
   ```bash
   # Correct:
   ENABLE_WEB_RESEARCHER="ON"

   # Wrong:
   ENABLE_WEB_RESEARCHER=ON      # Missing quotes
   ENABLE_WEB_RESEARCHER="on"    # Wrong case
   ENABLE_WEB_RESEARCHER= "ON"   # Space before quote
   ```

2. **Restart Claude Code**: Config loads at session start (Klaus reloads configuration)

3. **Verify workflow updated**:
   ```bash
   # Agent should appear in tiered-workflow.txt
   grep "test-infrastructure-agent" ~/.claude/hooks/tiered-workflow.txt
   ```

4. **Check config loads**:
   ```bash
   bash -c 'source ~/.claude/klaus-delegation.conf && echo $ENABLE_WEB_RESEARCHER'
   # Should output: ON
   ```

---

#### Issue 4: Test Failures

**Symptoms:**
- `bash test-klaus-delegation.sh` reports failures
- Some tests pass, others fail

**Diagnosis:**
```bash
# Run tests
cd ~/.claude
bash test-klaus-delegation.sh 2>&1 | grep "FAIL"
```

**Solutions:**

1. **Check config integrity**:
   ```bash
   bash -n ~/.claude/klaus-delegation.conf
   # No output = valid syntax
   ```

2. **Compare with backup**:
   ```bash
   diff ~/.claude/klaus-delegation.conf ~/.claude/klaus-delegation.conf.backup-*
   ```

3. **Verify agents exist**:
   ```bash
   ls ~/.claude/agents/*.md | grep -E "(web-research|file-path|test-infrastructure|reminder-nudger)"
   # Should show 4 files (Klaus's core team)
   ```

4. **Check for corrupted keyword arrays**:
   ```bash
   grep -A 5 "COMPLEX_KEYWORDS=(" ~/.claude/klaus-delegation.conf
   # Verify array syntax is valid
   ```

5. **Rollback if needed** (see Rollback section below)

---

#### Issue 5: Prompt Not Triggering Agent

**Symptoms:**
- Say "set up tests" but test-infrastructure-agent doesn't activate
- Agent in workflow but not invoked

**Causes & Solutions:**

1. **Prompt too short**:
   - Minimum: 30 characters
   - Solution: "set up comprehensive test infrastructure for this project"

2. **Feature flag OFF**:
   - Check: `grep "ENABLE_TEST_INFRASTRUCTURE" ~/.claude/klaus-delegation.conf`
   - Solution: Set to `"ON"` and restart Claude Code

3. **Score routing to wrong tier**:
   - Check: `echo '{"prompt":"YOUR PROMPT"}' | bash ~/.claude/hooks/klaus-delegation.sh | jq '.hookSpecificOutput.metadata'`
   - Solution: Add more COMPLEX_KEYWORDS to prompt

4. **Agent not in workflow**:
   - Check: `grep "test-infrastructure-agent" ~/.claude/hooks/tiered-workflow.txt`
   - Solution: Verify implementation complete

5. **Claude interprets workflow as suggestion, not instruction**:
   - Workflow is context, not command
   - Claude may choose different approach based on judgment
   - Solution: Explicitly mention agent: `@"test-infrastructure-agent" set up tests`

---

### Rollback Procedure

**If Klaus's system breaks, restore baseline:**

#### Step 1: Restore Configuration
```bash
cp ~/.claude/klaus-delegation.conf.backup-YYYYMMDD ~/.claude/klaus-delegation.conf

# Find backup date:
ls ~/.claude/*.backup-*
```

#### Step 2: Remove New Agents
```bash
rm ~/.claude/agents/web-research-specialist.md
rm ~/.claude/agents/file-path-extractor.md
rm ~/.claude/agents/test-infrastructure-agent.md
rm ~/.claude/agents/reminder-nudger-agent.md
```

#### Step 3: Restore Workflow
```bash
cp ~/.claude/hooks/tiered-workflow.txt.backup ~/.claude/hooks/tiered-workflow.txt

# If backup doesn't exist, recreate minimal version:
cat > ~/.claude/hooks/tiered-workflow.txt << 'EOF'
TIERED IMPLEMENTATION PIPELINE ({{TIER}} MODE)

PHASE 1-{{TIER}}: Context Gathering
[Original simple workflow without new agents]
EOF
```

#### Step 4: Restart Claude Code
- Exit all sessions
- Start fresh session (Klaus reloads)

#### Step 5: Verify Baseline
```bash
cd ~/.claude
bash test-klaus-delegation.sh

# Backward compatibility tests should pass
# Tests for new agents will fail (expected)
```

#### Step 6: Document Issue
```bash
# Create issue report
cat > ~/.claude/rollback-report.txt << EOF
Rollback performed: $(date)
Reason: [describe issue]
Tests failed: [list failed tests]
Config changes: [list changes made before rollback]
EOF
```

---

### Debug Mode

**Enable detailed logging to see Klaus's reasoning:**

#### 1. Edit Configuration
```bash
nano ~/.claude/klaus-delegation.conf

# Change:
DEBUG_MODE="OFF"
# To:
DEBUG_MODE="ON"
```

#### 2. Test with Debug Output
```bash
echo '{"prompt":"test prompt with keywords"}' | bash ~/.claude/hooks/klaus-delegation.sh 2>&1
```

**Debug output shows:**
- Keyword pattern matches
- Score calculations at each step
- Tier determination logic
- Config values loaded

#### 3. Disable After Debugging
```bash
# Set back to OFF (Klaus returns to quiet mode)
DEBUG_MODE="OFF"
```

---

## Quick Reference

*Klaus's quick reference card - for when you need answers fast.*

### File Locations

```
~/.claude/
  hooks/
    klaus-delegation.sh           # Klaus's routing logic
    tiered-workflow.txt         # Workflow templates

  agents/
    web-research-specialist.md  # Klaus's web researcher
    file-path-extractor.md      # Klaus's file tracker
    test-infrastructure-agent.md # Klaus's test architect
    reminder-nudger-agent.md    # Klaus's progress monitor
    explore-light.md            # Built-in agent
    research-lead.md            # Built-in agent
    research-light.md           # Built-in agent
    code-simplifier.md          # Utility agent
    composter.md                # Utility agent

  commands/
    fillmemory.md               # Initialize docs
    compost.md                  # Extract standards
    updatememory.md             # Sync docs with code

  klaus-delegation.conf           # Klaus's configuration
  test-klaus-delegation.sh        # Klaus's test suite
  README.md                     # This guide
```

### Common Commands

```bash
# Test Klaus's judgment
cd ~/.claude && bash test-klaus-delegation.sh

# Test score calculation
echo '{"prompt":"YOUR PROMPT"}' | bash ~/.claude/hooks/klaus-delegation.sh | jq '.hookSpecificOutput.metadata'

# Edit Klaus's configuration
nano ~/.claude/klaus-delegation.conf

# Enable agent (give Klaus a new specialist)
# In config: ENABLE_<AGENT>="ON"

# Restart Claude Code
# Exit session, start new (Klaus reloads)

# Rollback if needed
cp ~/.claude/klaus-delegation.conf.backup-* ~/.claude/klaus-delegation.conf
rm ~/.claude/agents/{web-research-specialist,file-path-extractor,test-infrastructure-agent,reminder-nudger-agent}.md

# Enable debug mode (see Klaus's reasoning)
# In config: DEBUG_MODE="ON"
```

### Feature Flags

```bash
ENABLE_WEB_RESEARCHER="OFF"       # web-research-specialist
ENABLE_FILE_PATH_EXTRACTOR="ON"  # file-path-extractor (default ON)
ENABLE_TEST_INFRASTRUCTURE="OFF"  # test-infrastructure-agent
ENABLE_REMINDER_SYSTEM="OFF"      # reminder-nudger-agent
```

### Klaus's Tier Routing

| Score | Tier | Klaus's Coordination |
|-------|------|---------------------|
| 0-2 | DIRECT | Executes immediately (no coordination needed) |
| 3-4 | LIGHT | explore-light [+ web-research-specialist*] |
| 5-6 | MEDIUM | explore-light + research-light + Plan [+ file-path-extractor*] |
| 7+ | FULL | Explore + research-lead + Plan [+ web-research-specialist* + file-path-extractor*] |

*When feature flags enabled

### Score Calculation

```
Klaus's Score = 0
+ Length bonuses (>100: +1, >200: +1, >400: +2)
+ COMPLEX_KEYWORDS matches (×weight)
- SIMPLE_KEYWORDS matches (×weight)
= Final score (bounded 0-50)
```

### Slash Commands

```
/fillmemory      # Initialize .claude/project/ docs
/compost         # Extract standards from codebase
/updatememory    # Sync docs with current code
/klaude <task>   # Manual 3-agent intelligence pipeline
```

### Agent Invocation

```
@"web-research-specialist" <query>
@"file-path-extractor" <bash output>
@"test-infrastructure-agent" <setup request>
@"code-simplifier" <review request>
@"composter" [auto-invoked by /compost]
```

---

## References & Sources

### Claude Code Documentation Mirror

For advanced debugging or your own development, you can use the local Claude Code Documentation mirror repository:

**claude-code-docs**
https://github.com/ericbuess/claude-code-docs

### Core Principles

> **Managing Memory** (*View the [Manage Memory](https://code.claude.com/docs/en/memory?) documentation.*)

> **Hook Determinism** (*View the [Hooks Reference](https://code.claude.com/docs/en/hooks#hook-output) documentation.*)

> **Simplicity < Complexity** (*View the [Tool use with Claude](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview) documentation.*)

> **Amplify and Reinforce** (*View the [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) documentation.*)

### Memory Management

- https://www.anthropic.com/engineering/claude-code-best-practices
- https://code.claude.com/docs/en/memory

### Delegation, Routing & Hooks

- https://code.claude.com/docs/en/sub-agents
- https://code.claude.com/docs/en/hooks
- https://docs.anthropic.com/en/docs/claude-code/common-workflows
- https://code.claude.com/docs/en/hooks-guide

---

**End of Klaus Baudelaire Guide**

> _"I don't know if you've ever noticed, but first impressions are often entirely wrong."_
> — Lemony Snicket, _The Bad Beginning_

*Klaus hopes this guide served as a proper second impression. For Claude Code core documentation (hooks, tool use, keyboard shortcuts), run `claude docs` or check the official documentation.*

*Thank you for reading. Klaus is here to serve - delegating agents, coordinating workflows, and reinforcing Claude Code's native capabilities without adding bloat. PRs welcome.*
