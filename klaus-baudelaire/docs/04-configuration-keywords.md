# Configuration & Keywords

> **Back to [README](../TLDR-README.md)** | **Prev: [Scoring Algorithm](03-scoring-algorithm.md)** | **Next: [Profile System](05-profile-system.md)**

---

## Overview

Klaus's personality is defined by his configuration -- the keywords he recognizes and the thresholds he uses. Easy to configure right out of the box.

---

## Configuration File

**Location**: `~/.claude/klaus-delegation.conf`

```bash
#!/bin/bash
# klaus-delegation.conf - Klaus's card catalog

# Core Settings
SMART_DELEGATE_MODE="ON"          # Klaus is active
MIN_LENGTH=30                     # Minimum prompt length to analyze
DEBUG_MODE="OFF"                  # Debug logging

# Tier Thresholds
TIER_LIGHT_MIN=3                  # Score >= 3 = LIGHT
TIER_MEDIUM_MIN=5                 # Score >= 5 = MEDIUM
TIER_FULL_MIN=7                   # Score >= 7 = FULL

# Length-Based Scoring
LENGTH_100_SCORE=1                # Points for >100 chars
LENGTH_200_SCORE=1                # Points for >200 chars
LENGTH_400_SCORE=2                # Points for >400 chars

# COMPLEX_KEYWORDS (array of "pattern:weight")
COMPLEX_KEYWORDS=(
  "system:1"
  "architecture:1"
  "design:1"
  "integrate:1"
  "across|multiple|all files|every|codebase:1"
  "best practice|documentation|research|how to:2"
  "refactor|restructure|redesign:3"
  "security|authentication|authorization:1"
  "investigate|deep dive|thorough analysis:2"
  "compare.*versus|compare.*with:3"
  "set up tests|test infrastructure:3"
  "initialize project|scaffold|bootstrap:3"
  "oauth|authentication.*provider|authorization:1"
  "database migration|schema changes:3"
  "api integration|rest|graphql:1"
  "docker|containerization|deployment:2"
  "ci/cd|github actions|pipeline:2"
  "benchmark|performance.*analysis:3"
  "and.*also|as well as|plus|additionally:1"
  "not only.*but also|both.*and:2"
  "comprehensive|extensive:3"
  "thorough:1"
  "implementation:2"
  "implement:1"
  "build out:1"
  "error.?handling|exception|validation:1"
  "performance|optimize|optimization:2"
  "propose|strategy|approach|plan:1"
  "improve|enhance|upgrade:1"
)

# SIMPLE_KEYWORDS (array of "pattern:weight")
SIMPLE_KEYWORDS=(
  "fix typo|add comment|rename|update:4"
  "simple|quick|small|minor:3"
  "this file|this function|this line:2"
  "just|only|simply:2"
  "straightforward|basic|elementary:2"
  "single file|this specific|that specific:3"
  "skip.*research|no need to.*:2"
  "what is|where is|how do i|show me:2"
)

# Feature Flags
ENABLE_WEB_RESEARCHER="OFF"       # web-research-specialist agent
ENABLE_FILE_PATH_EXTRACTOR="ON"   # file-path-extractor agent (default ON)
ENABLE_TEST_INFRASTRUCTURE="OFF"  # test-infrastructure-agent
ENABLE_REMINDER_SYSTEM="OFF"      # reminder-nudger-agent

# Routing Transparency
ROUTING_EXPLANATION="ON"          # Show routing rationale (default ON)
```

---

## Modifying Configuration

### Step 1: Edit the config file

```bash
nano ~/.claude/klaus-delegation.conf
# or
code ~/.claude/klaus-delegation.conf
```

### Step 2: Make changes

```bash
# Enable an agent
ENABLE_WEB_RESEARCHER="ON"

# Add a custom keyword
COMPLEX_KEYWORDS=(
  "${COMPLEX_KEYWORDS[@]}"        # Preserve existing
  "my custom pattern:3"           # Add new
)

# Adjust tier threshold
TIER_FULL_MIN=10                  # Raise bar for FULL tier
```

### Step 3: Restart Claude Code

Klaus reloads configuration at session start.

### Step 4: Verify changes

```bash
bash ~/.claude/tests/unit-tests.sh
```

---

## Keyword Dictionary

### Complex Keywords (Positive Scoring)

These patterns tell Klaus: "This needs research, planning, or architectural thinking."

| Pattern | Weight | Example Prompt | Why |
|---------|--------|----------------|-----|
| `system` | +1 | "design the system for scaling" | Architectural term (split for multi-match) |
| `architecture` | +1 | "system architecture review" | Architectural work indicator |
| `design` | +1 | "design the authentication flow" | Design thinking required |
| `integrate` | +1 | "integrate payment system" | Integration complexity |
| `across\|multiple\|all files\|every\|codebase` | +1 | "refactor across multiple files" | Multi-file scope |
| `best practice\|documentation\|research\|how to` | +2 | "research best practices for React" | Explicit research request |
| `refactor\|restructure\|redesign` | +3 | "refactor authentication system" | Major code restructuring |
| `security\|authentication\|authorization` | +1 | "add authentication middleware" | Security work co-occurs |
| `investigate\|deep dive\|thorough analysis` | +2 | "investigate performance issue" | Deep analysis work |
| `compare.*versus\|compare.*with` | +3 | "compare React versus Vue" | Comparative research |
| `set up tests\|test infrastructure` | +3 | "set up test infrastructure" | Test infrastructure setup |
| `initialize project\|scaffold\|bootstrap` | +3 | "bootstrap new project" | Project initialization |
| `oauth\|authentication.*provider\|authorization` | +1 | "add OAuth with Google" | OAuth-specific patterns |
| `database migration\|schema changes` | +3 | "create database migration" | Schema work complexity |
| `api integration\|rest\|graphql` | +1 | "integrate REST API" | API work baseline |
| `docker\|containerization\|deployment` | +2 | "set up Docker" | Deployment infrastructure |
| `ci/cd\|github actions\|pipeline` | +2 | "configure CI/CD" | DevOps workflows |
| `benchmark\|performance.*analysis` | +3 | "benchmark database queries" | Performance measurement |
| `and.*also\|as well as\|plus\|additionally` | +1 | "add tests and also docs" | Multi-task indicator |
| `not only.*but also\|both.*and` | +2 | "not only tests but also CI" | Complex multi-task |
| `comprehensive\|extensive` | +3 | "comprehensive security audit" | High-complexity scope |
| `thorough` | +1 | "thorough code review" | Thoroughness indicator |
| `implementation` | +2 | "authentication implementation" | Actual implementation work (noun) |
| `implement` | +1 | "implement new feature" | Implementation request (verb) |
| `build out` | +1 | "build out API layer" | Construction work |
| `error.?handling\|exception\|validation` | +1 | "add error handling" | Error handling work |
| `performance\|optimize\|optimization` | +2 | "optimize database queries" | Performance work |
| `propose\|strategy\|approach\|plan` | +1 | "propose architecture approach" | Planning indicators |
| `improve\|enhance\|upgrade` | +1 | "improve test coverage" | Enhancement work |

### Simple Keywords (Negative Scoring)

These patterns tell Klaus: "This is straightforward - no need for the full research team."

| Pattern | Weight | Example Prompt | Why |
|---------|--------|----------------|-----|
| `fix typo\|add comment\|rename\|update` | -4 | "fix typo in README" | Simple maintenance tasks |
| `simple\|quick\|small\|minor` | -3 | "make a quick change" | Explicitly simple work |
| `this file\|this function\|this line` | -2 | "update this file" | Single-location work |
| `just\|only\|simply` | -2 | "just add a comment" | Minimizing language |
| `straightforward\|basic\|elementary` | -2 | "straightforward refactor" | Explicitly basic work |
| `single file\|this specific\|that specific` | -3 | "modify single file" | Narrow scope |
| `skip.*research\|no need to.*` | -2 | "skip research, just implement" | Explicit bypass request |
| `what is\|where is\|how do i\|show me` | -2 | "where is config file?" | Simple informational question |

### Pattern Syntax

Keywords use extended regex (grep -E compatible):
- `|` = OR operator (matches any alternative)
- `.*` = any characters (greedy matching)
- No anchors (pattern can match anywhere in prompt)

---

## Context7 Keywords

When Context7 MCP integration is enabled, additional documentation-related keywords boost the score:

```bash
CONTEXT7_KEYWORDS=(
  "documentation|docs|api reference:2"
  "how to use|usage example:2"
  "library|framework|package:2"
  # ... 20+ patterns
)

CONTEXT7_SCORE_BOOST=1             # Additional boost when Context7 keywords detected
```

---

## Related Documentation

- [Scoring Algorithm](03-scoring-algorithm.md) - How keywords feed into scoring
- [Profile System](05-profile-system.md) - Profile-based keyword weight adjustments
- [Feature Flags](06-feature-flags.md) - Enabling/disabling features via config
