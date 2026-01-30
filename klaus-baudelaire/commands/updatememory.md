---
description: Syncs project documentation with codebase reality, identifies discrepancies, fills gaps, and prompts user to resolve conflicts.
allowed-tools: Bash, Grep, Glob, Edit
---

## CRITICAL/REQUIRED/BLOCKING: Scaffold Detection

BEFORE updating memory documents, ensure the scaffolding structure exists.

```
CLAUDE_DIR="$CLAUDE_PROJECT_DIR/.claude"
RULES_DIR="$CLAUDE_DIR/rules"
PROJECT_DIR="$CLAUDE_DIR/project"
INDEX_FILE="$RULES_DIR/project-index.md"
```

### EXPLICIT INSTRUCTION POST DETECTION
IF ANY PATH DIRS/FILE (CLAUDE_DIR, RULES_DIR, PROJECT_DIR, INDEX_FILE) DO NOT EXIST, WITH NO EXCEPTION FOR ANY REASON:

OUTPUT TO THE USER, THEN EXIT. 

```
[!!!] You need to run /fillmemory before updating memory.
```

Invoke 6 agents in parallel to analyze the gaps, detect discrepancies, and sync each of these files with the actual codebase state:
- `$CLAUDE_PROJECT_DIR/.claude/project/architecture.md`
- `$CLAUDE_PROJECT_DIR/.claude/project/frontend.md`
- `$CLAUDE_PROJECT_DIR/.claude/project/backend.md`
- `$CLAUDE_PROJECT_DIR/.claude/project/database.md`
- `$CLAUDE_PROJECT_DIR/.claude/project/infrastructure.md`
- `$CLAUDE_PROJECT_DIR/.claude/project/testing.md`

Do NOT process files in the `standards/` subdirectory. Standards documentation should be maintained separately.

Each agent should:
1. Read its assigned documentation file and the relevant codebase sections
2. Identify empty sections, unfilled `<excerpt>` tags, or placeholder content
3. Detect mismatches between documented values and actual code (frameworks, libraries, APIs, schemas, configs)
4. When a discrepancy is found, use `AskUserQuestion` to resolve: "Your code uses [actual] but docs say [documented]. Which is correct?"
5. Update the documentation file after user confirmation
6. Fill any remaining gaps with accurate analysis
