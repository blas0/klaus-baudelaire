# Testing & Verification

> **Back to [README](../TLDR-README.md)** | **Prev: [Hooks System](13-hooks-system.md)** | **Next: [Troubleshooting](15-troubleshooting.md)**

---

## Overview

Klaus maintains comprehensive test suites to verify the delegation system. Two complementary approaches: unit tests validate individual components, integration/E2E tests validate real-world workflows.

---

## Test Organization

**Location**: `klaus-baudelaire/tests/` (before installation) or `~/.claude/tests/` (after installation)

> [!] **Testing from klaus-baudelaire/ directory:**
> When running tests BEFORE installation, use the `KLAUS_ROOT` environment variable:
>
> ```bash
> KLAUS_ROOT=/path/to/klaus-baudelaire bash klaus-baudelaire/tests/unit-tests.sh
> KLAUS_ROOT=/path/to/klaus-baudelaire bun klaus-baudelaire/tests/integration-tests.ts
> ```
>
> By default, `klaus-delegation.sh` loads configuration from `~/.claude/`. The `KLAUS_ROOT` override ensures it loads from `klaus-baudelaire/` during development.

---

## Test Suites

### Unit Tests (unit-tests.sh)

**Purpose**: Validates scoring algorithm, configuration, agent existence, and system integration.

```bash
bash klaus-baudelaire/tests/unit-tests.sh
# or after installation:
bash ~/.claude/tests/unit-tests.sh
```

**Coverage** (79 tests):
- Scoring boundaries and limits
- Keyword pattern matching
- Configuration loading
- Feature flags
- Agent file existence
- Workflow integration

### Integration Tests (integration-tests.sh / integration-tests.ts)

**Purpose**: Tests real-world prompt routing across all 4 tiers with 12 sample prompts.

```bash
# Bun/TypeScript (recommended for macOS)
bun klaus-baudelaire/tests/integration-tests.ts

# Bash
bash klaus-baudelaire/tests/integration-tests.sh
```

**Coverage** (12 prompts):
- DIRECT tier (0-2 points): Simple tasks
- LIGHT tier (3-4 points): Research and investigation
- MEDIUM tier (5-6 points): Multi-file refactoring
- FULL tier (7+ points): Complex system design

### Hook Tests (hooks-suite.sh)

**Purpose**: Validates all hook components.

```bash
bash klaus-baudelaire/tests/hooks-suite.sh
# With verbose output:
bash klaus-baudelaire/tests/hooks-suite.sh --verbose
# Filter specific tests:
bash klaus-baudelaire/tests/hooks-suite.sh --filter=async
```

**Coverage** (128 tests, 215+ assertions):

| Suite | Tests | Assertions |
|-------|-------|------------|
| klaus-delegation-hook.test.sh | 33 | 33 |
| async-execution.test.sh | 17 | 36 |
| session-state.test.sh | 30 | 49 |
| routing-telemetry.test.sh | 20 | 43 |
| rlm-workflow-coordinator.test.sh | 28 | 54 |

### E2E Tests (e2e-suite.sh)

**Purpose**: End-to-end validation of complete workflows.

```bash
bash klaus-baudelaire/tests/e2e-suite.sh
# With verbose:
bash klaus-baudelaire/tests/e2e-suite.sh --verbose
# Filter:
bash klaus-baudelaire/tests/e2e-suite.sh --filter=delegation
```

**Coverage** (26 tests):
- delegation-routing.test.sh - Tier routing accuracy
- config-loading.test.sh - Configuration parsing
- context7-detection.test.sh - Library/framework detection
- feature-flags.test.sh - Feature flag behavior

### System-Specific Tests

| Suite | Tests | File |
|-------|-------|------|
| Profile System | 12 | tests/unit/profile-loader.test.sh |
| Feature Flags | 8 | tests/unit/feature-flags.test.sh |
| Coverage Instrumentation | 5 | tests/unit/coverage-instrumentation.test.sh |
| Plan Orchestration (unit) | 6 | tests/unit/plan-orchestration.test.sh |
| Plan Orchestration (integration) | 53 | tests/integration/plan-orchestration.test.sh |
| Sandbox Workflow | 8 | tests/integration/sandbox-workflow.test.sh |
| Feature Flag Integration | 3 | tests/integration/feature-flag-integration.test.sh |
| Profile Migration | 16 | tests/integration/profile-migration.test.sh |
| Task Coordination | varies | tests/integration/task-coordination.test.sh |
| RLM Workflows | 3+3 | tests/unit/ and tests/integration/ |

---

## Test Statistics

| Suite | Tests | Assertions | Pass Rate | Time |
|-------|-------|------------|-----------|------|
| Hook Tests | 128 | 215+ | 100% | ~6-7s |
| E2E Tests | 26 | N/A | Varies | ~15-20s |
| Integration | 12 | N/A | Varies | ~5-10s |
| Unit Tests | 79 | N/A | 100% | ~2-3s |
| **Total** | **245+** | **215+** | **~99%** | **~28-40s** |

---

## Run All Tests

```bash
# [1] Hook tests (128 tests, ~6-7s)
bash klaus-baudelaire/tests/hooks-suite.sh

# [2] E2E tests (26 tests)
bash klaus-baudelaire/tests/e2e-suite.sh

# [3] Integration tests (12 prompts)
bun klaus-baudelaire/tests/integration-tests.ts

# [4] Unit tests (79 tests)
bash klaus-baudelaire/tests/unit-tests.sh
```

---

## Coverage Reporting

```bash
bash klaus-baudelaire/tests/run-with-coverage.sh
```

Runs all test suites with TypeScript coverage reporting:
- Hook tests (128 tests)
- E2E tests (26 tests)
- Unit tests (79 tests)
- TypeScript integration tests with Bun coverage (36%+ function coverage)
- LCOV report at `~/.claude/coverage/bun/lcov.info`

---

## Manual Testing

### Test Individual Prompts

```bash
# After installation
echo '{"prompt":"YOUR PROMPT HERE"}' | bash ~/.claude/hooks/klaus-delegation.sh | jq '.hookSpecificOutput.metadata'

# Before installation (with KLAUS_ROOT override)
echo '{"prompt":"YOUR PROMPT HERE"}' | \
  KLAUS_ROOT=/path/to/klaus-baudelaire \
  bash klaus-baudelaire/hooks/klaus-delegation.sh | \
  jq '.hookSpecificOutput.metadata'
```

**Example outputs**:
```json
{"score": 0, "tier": "DIRECT"}
{"score": 5, "tier": "MEDIUM"}
{"score": 10, "tier": "FULL"}
```

### Test with Debug Mode

```bash
# Edit ~/.claude/klaus-delegation.conf
DEBUG_MODE="ON"

# Run test and see keyword matches
echo '{"prompt":"test prompt with keywords"}' | bash hooks/klaus-delegation.sh 2>&1
```

### Test Agent Loading

```bash
# List agents
ls -la ~/.claude/agents/

# Check frontmatter
head -10 ~/.claude/agents/web-research-specialist.md
```

### Test Workflow Integration

```bash
# Check workflow references agents
grep "web-research-specialist\|file-path-extractor\|test-infrastructure-agent\|reminder-nudger-agent" ~/.claude/hooks/tiered-workflow.txt
```

---

## Continuous Verification

**After configuration changes**:
```bash
bash ~/.claude/tests/unit-tests.sh
bun ~/.claude/tests/integration-tests.ts
```

**After keyword additions**:
```bash
echo '{"prompt":"prompt with new keyword"}' | bash ~/.claude/hooks/klaus-delegation.sh | jq '.hookSpecificOutput.metadata.score'
```

**After agent modifications**:
```bash
head -10 ~/.claude/agents/<agent-name>.md | grep "^name:\|^model:\|^tools:"
```

---

## Test Helpers

Located in `tests/helpers/`:

| Helper | Purpose |
|--------|---------|
| `mock-helpers.sh` | Mock config generation |
| `json-helpers.sh` | JSON parsing for Bash |
| `timing-helpers.sh` | Performance measurement |
| `test-utils.sh` | Test framework with assertion helpers |

---

## Related Documentation

- [Coverage Tracking](07-coverage-tracking.md) - Bash code coverage tools
- [Production Testing](08-production-testing.md) - Sandbox deployment pipeline
- [Troubleshooting](15-troubleshooting.md) - Diagnosing test failures
