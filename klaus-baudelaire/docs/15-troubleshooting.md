# Troubleshooting & Quick Reference

> **Back to [README](../TLDR-README.md)** | **Prev: [Testing & Verification](14-testing-verification.md)**

---

## Common Issues

### Issue 1: Agent Not Loading

**Symptoms**: Agent does not appear in Claude Code, error "agent not found"

**Diagnosis**:
```bash
ls -la ~/.claude/agents/<agent-name>.md
head -10 ~/.claude/agents/<agent-name>.md
```

**Solutions**:

[1] **Verify file location**: Must be in `~/.claude/agents/`

[2] **Check frontmatter syntax**:
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

[3] **Restart Claude Code**: Agents load at session start

[4] **Check for YAML errors**:
```bash
# Install yq if needed: brew install yq
yq eval '.name' ~/.claude/agents/<agent-name>.md
```

---

### Issue 2: Wrong Tier Routing

**Symptoms**: Prompt routes to unexpected tier (FULL when expecting LIGHT, or vice versa)

**Diagnosis**:
```bash
echo '{"prompt":"YOUR PROMPT"}' | bash ~/.claude/hooks/klaus-delegation.sh | jq '.hookSpecificOutput.metadata'
```

**Common causes**:

[1] **Prompt too short** (<30 chars) - Returns `{}` (skipped). Add more context.

[2] **SIMPLE_KEYWORDS overwhelm COMPLEX_KEYWORDS**:
   - Example: "just simple system architecture" = "just" (-2) + "simple" (-3) + "system" (+3) = -2 (floored to 0)
   - Solution: Rephrase to avoid SIMPLE_KEYWORDS

[3] **Pattern does not match** - Keywords use extended regex (grep -E)
   - Check: `echo "test prompt" | grep -qE "(pattern)" && echo "match"`

[4] **Config not loaded**:
   - Test: `bash -c 'source ~/.claude/klaus-delegation.conf && echo "OK"'`

**Debug mode**:
```bash
# Edit ~/.claude/klaus-delegation.conf
DEBUG_MODE="ON"

# Run prompt and check reasoning
echo '{"prompt":"test"}' | bash ~/.claude/hooks/klaus-delegation.sh 2>&1
```

---

### Issue 3: Feature Flag Not Working

**Symptoms**: Agent does not appear in workflow despite flag = "ON"

**Diagnosis**:
```bash
grep "ENABLE_" ~/.claude/klaus-delegation.conf
grep "agent-name" ~/.claude/hooks/tiered-workflow.txt
```

**Solutions**:

[1] **Verify flag syntax**:
```bash
# Correct:
ENABLE_WEB_RESEARCHER="ON"

# Wrong:
ENABLE_WEB_RESEARCHER=ON      # Missing quotes
ENABLE_WEB_RESEARCHER="on"    # Wrong case
ENABLE_WEB_RESEARCHER= "ON"   # Space before quote
```

[2] **Restart Claude Code** (config loads at session start)

[3] **Verify workflow updated**:
```bash
grep "test-infrastructure-agent" ~/.claude/hooks/tiered-workflow.txt
```

[4] **Check config loads**:
```bash
bash -c 'source ~/.claude/klaus-delegation.conf && echo $ENABLE_WEB_RESEARCHER'
# Should output: ON
```

---

### Issue 4: Test Failures

**Symptoms**: Unit or integration tests report failures

**Diagnosis**:
```bash
bash klaus-baudelaire/tests/unit-tests.sh 2>&1 | grep "FAIL"
```

**Solutions**:

[1] **Check config integrity**:
```bash
bash -n ~/.claude/klaus-delegation.conf
# No output = valid syntax
```

[2] **Compare with backup**:
```bash
diff ~/.claude/klaus-delegation.conf ~/.claude/klaus-delegation.conf.backup-*
```

[3] **Verify agents exist**:
```bash
ls ~/.claude/agents/*.md | grep -E "(web-research-specialist|file-path-extractor|test-infrastructure|reminder-nudger)"
# Should show 4 files
```

[4] **Check keyword arrays**:
```bash
grep -A 5 "COMPLEX_KEYWORDS=(" ~/.claude/klaus-delegation.conf
```

[5] **Rollback if needed** (see Rollback section below)

---

### Issue 5: Prompt Not Triggering Agent

**Symptoms**: Say "set up tests" but test-infrastructure-agent does not activate

**Causes & Solutions**:

[1] **Prompt too short**: Minimum 30 characters. Use "set up comprehensive test infrastructure for this project"

[2] **Feature flag OFF**: Check `grep "ENABLE_TEST_INFRASTRUCTURE" ~/.claude/klaus-delegation.conf`

[3] **Score routes to wrong tier**: Check score with debug prompt test

[4] **Agent not in workflow**: Check `grep "test-infrastructure-agent" ~/.claude/hooks/tiered-workflow.txt`

[5] **Claude interprets workflow as suggestion**: Workflow is context, not command. Explicitly mention agent: `@"test-infrastructure-agent" set up tests`

---

## Rollback Procedure

If Klaus's system breaks, restore baseline:

### Step 1: Restore Configuration

```bash
cp ~/.claude/klaus-delegation.conf.backup-YYYYMMDD ~/.claude/klaus-delegation.conf

# Find backup date:
ls ~/.claude/*.backup-*
```

### Step 2: Remove New Agents (if needed)

```bash
rm ~/.claude/agents/web-research-specialist.md
rm ~/.claude/agents/file-path-extractor.md
rm ~/.claude/agents/test-infrastructure-agent.md
rm ~/.claude/agents/reminder-nudger-agent.md
```

### Step 3: Restore Workflow

```bash
cp ~/.claude/hooks/tiered-workflow.txt.backup ~/.claude/hooks/tiered-workflow.txt
```

### Step 4: Restart Claude Code

Exit all sessions, start fresh.

### Step 5: Verify Baseline

```bash
bash klaus-baudelaire/tests/unit-tests.sh
```

### Step 6: Document Issue

```bash
cat > ~/.claude/rollback-report.txt << EOF
Rollback performed: $(date)
Reason: [describe issue]
Tests failed: [list failed tests]
Config changes: [list changes made before rollback]
EOF
```

---

## Debug Mode

### Enable

```bash
nano ~/.claude/klaus-delegation.conf
# Change: DEBUG_MODE="OFF"
# To:     DEBUG_MODE="ON"
```

### Test with Debug Output

```bash
echo '{"prompt":"test prompt with keywords"}' | bash ~/.claude/hooks/klaus-delegation.sh 2>&1
```

Debug output shows:
- Keyword pattern matches
- Score calculations at each step
- Tier determination logic
- Config values loaded

### Disable After Debugging

```bash
# Set back to OFF
DEBUG_MODE="OFF"
```

---

## Quick Reference

### File Locations

```
~/.claude/
  hooks/
    klaus-delegation.sh           # Routing logic
    tiered-workflow.txt           # Workflow templates
  agents/
    web-research-specialist.md    # Web researcher
    file-path-extractor.md        # File tracker
    test-infrastructure-agent.md  # Test architect
    reminder-nudger-agent.md      # Progress monitor
    explore-light.md              # Quick explorer
    research-lead.md              # Research coordinator
    research-light.md             # Quick researcher
    code-simplifier.md            # Code simplifier
    composter.md                  # Pattern extractor
  commands/
    klaus.md                      # Force FULL tier
    fillmemory.md                 # Initialize docs
    compost.md                    # Extract standards
    updatememory.md               # Sync docs
  tests/
    unit-tests.sh                 # Scoring validation
    integration-tests.sh          # Routing tests (Bash)
    integration-tests.ts          # Routing tests (Bun)
    README.md                     # Test documentation
  klaus-delegation.conf           # Configuration
```

### Common Commands

```bash
# Run tests
bash ~/.claude/tests/unit-tests.sh
bun ~/.claude/tests/integration-tests.ts

# Test score calculation
echo '{"prompt":"YOUR PROMPT"}' | bash ~/.claude/hooks/klaus-delegation.sh | jq '.hookSpecificOutput.metadata'

# Edit configuration
nano ~/.claude/klaus-delegation.conf

# Enable debug mode
# In config: DEBUG_MODE="ON"

# Rollback
cp ~/.claude/klaus-delegation.conf.backup-* ~/.claude/klaus-delegation.conf
```

### Tier Routing Summary

| Score | Tier | Agents |
|-------|------|--------|
| 0-2 | DIRECT | None (executes immediately) |
| 3-4 | LIGHT | explore-light [+ web-research-specialist*] |
| 5-6 | MEDIUM | explore-light + research-light + plan-orchestrator [+ file-path-extractor*] |
| 7+ | FULL | explore-lead + docs-specialist + research-lead + file-path-extractor + plan-orchestrator [+ web-research-specialist*] |

*When feature flags enabled

### Slash Commands

```
/klaus <prompt>       # Force FULL tier execution
/fillmemory           # Initialize .claude/project/ docs
/compost              # Extract standards from codebase
/updatememory         # Sync docs with current code
/klaus feature list   # List all feature flags
/klaus-test           # System diagnostics
/suggestkeywords      # Routing telemetry analysis
```

### Agent Invocation

```
@"web-research-specialist" <query>
@"file-path-extractor" <bash output>
@"test-infrastructure-agent" <setup request>
@"code-simplifier" <review request>
@"composter" [auto-invoked by /compost]
```

### Feature Flags

```bash
ENABLE_WEB_RESEARCHER="OFF"       # web-research-specialist
ENABLE_FILE_PATH_EXTRACTOR="ON"   # file-path-extractor (default ON)
ENABLE_TEST_INFRASTRUCTURE="OFF"  # test-infrastructure-agent
ENABLE_REMINDER_SYSTEM="OFF"      # reminder-nudger-agent
```

---

## References & Sources

### Claude Code Documentation

- [Managing Memory](https://code.claude.com/docs/en/memory)
- [Hooks Reference](https://code.claude.com/docs/en/hooks#hook-output)
- [Sub-agents](https://code.claude.com/docs/en/sub-agents)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Common Workflows](https://docs.anthropic.com/en/docs/claude-code/common-workflows)
- [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)

### Local Documentation Mirror

For advanced debugging or development:
- [claude-code-docs](https://github.com/ericbuess/claude-code-docs)

---

> _"I don't know if you've ever noticed, but first impressions are often entirely wrong."_
> -- Lemony Snicket, _The Bad Beginning_
