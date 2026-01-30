---
description: Extracts and documents project-specific standards, patterns, and coherence principles from actual codebase implementations.
allowed-tools: Glob, Grep, Read, Edit
---

# compost

Invoke Composter agent to extract and document codebase-specific standards, patterns, and coherence principles.

**CRITICAL SCOPE LIMITATION:**
The Composter agent ONLY interacts with files in `$CLAUDE_PROJECT_DIR/.claude/project/`.
The Composter agent ONLY EDITS files in `$CLAUDE_PROJECT_DIR/.claude/project/standards/`.

**Invoke Composter agent:**

Use delegate_task with subagent_type="composter" to spawn agent.
The agent will process these files sequentially:
1. `standards.md` - Code style, formatting, naming conventions
2. `coherence.md` - Logical philosophy, error handling consistency
3. `patterns.md` - Architectural blueprints, design patterns

**Expected Behavior:**
- Agent reads [introduction] blocks to understand each file's philosophical intent
- Agent analyzes codebase for concrete examples matching each file's intent
- Agent fills remaining sections with real code examples (file:line references)
- Agent preserves [introduction] blocks verbatim

**Critical Rules:**
- Agent does NOT invent or suggest standards/patterns - ONLY extracts what exists
- All examples include file paths and line numbers
- If a section has no examples: `<!-- No examples found in current codebase -->`
