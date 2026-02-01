# Production Testing Framework

> **Back to [README](../TLDR-README.md)** | **Prev: [Coverage Tracking](07-coverage-tracking.md)** | **Next: [Plan Orchestration](09-plan-orchestration.md)**

---

## Overview

The Production Testing Framework provides a sandbox-based deployment pipeline with automatic validation and rollback. Changes flow through an isolated sandbox environment before reaching production (`~/.claude/`).

---

## Workflow

```
klaus-baudelaire/ --> sandbox-env/ --> validate --> ~/.claude/ (production)
                                       |
                                       v
                                  [FAIL] rollback
```

**Philosophy**: Never deploy to production without validation. Automatic rollback on failure.

---

## Tools

### sandbox-migrate.sh

Copies klaus-baudelaire files to an isolated sandbox environment.

```bash
bash tests/sandbox/sandbox-migrate.sh
```

**What it does**:
- Backs up existing sandbox (timestamped)
- Cleans and recreates sandbox directory structure
- Copies all klaus-baudelaire files: hooks, config, agents, commands, tools, tests
- Sets executable permissions for hooks and scripts
- Verifies critical files exist (klaus-delegation.sh, klaus-delegation.conf)

### sandbox-validate-system4.sh

Validates sandbox integrity with 6 checks.

```bash
bash tests/sandbox/sandbox-validate-system4.sh
```

**Validation Checks**:

| Check | What It Validates |
|-------|-------------------|
| [1] File structure | hooks/ and config/ directories exist |
| [2] Required files | klaus-delegation.sh and klaus-delegation.conf present |
| [3] Permissions | All scripts are executable |
| [4] Bash syntax | `bash -n` on all bash scripts |
| [5] Feature flags | Registry functionality with KLAUS_ROOT override |
| [6] Profiles | Conservative, balanced, aggressive profiles present |

**Exit codes**: 0 = all pass, 1 = any fail

### sandbox-rollback.sh

Restores sandbox from most recent backup.

```bash
bash tests/sandbox/sandbox-rollback.sh
```

**What it does**:
- Lists available backups sorted by timestamp (most recent first)
- Restores most recent backup automatically
- Verifies critical files after rollback
- Reports rollback success with backup timestamp

### sandbox-deploy.sh

Deploys validated sandbox to production (`~/.claude/`).

```bash
bash tests/sandbox/sandbox-deploy.sh
```

**6-Phase Deployment**:

| Phase | Action |
|-------|--------|
| [1] Validate | Run sandbox-validate-system4.sh (automatic gate) |
| [2] Backup | Back up production to `~/.claude/backups/sandbox-deploy-<timestamp>/` |
| [3] Create dirs | Ensure target directories exist |
| [4] Deploy | Copy sandbox files to `~/.claude/` |
| [5] Permissions | Set executable permissions on hooks and tools |
| [6] Smoke test | Feature flag registry + profile config validation |

**Automatic rollback** if smoke test fails.

---

## Complete Workflow

```bash
# [1] Make changes in klaus-baudelaire/

# [2] Migrate to sandbox
bash tests/sandbox/sandbox-migrate.sh

# [3] Validate sandbox
bash tests/sandbox/sandbox-validate-system4.sh

# [4] Run tests against sandbox
KLAUS_ROOT=tests/sandbox/sandbox-env bash tests/unit-tests.sh

# [5] Deploy to production (if validation passes)
bash tests/sandbox/sandbox-deploy.sh

# [6] Verify production
bash ~/.claude/tests/unit-tests.sh
```

---

## Safety Features

[1] **Automatic backups** before every migration and deployment (timestamped)

[2] **Validation gates** prevent broken deployments (must pass 6 checks)

[3] **Automatic rollback** on smoke test failure

[4] **Manual rollback** available for recovery

[5] **Zero-downtime** deployments with atomic operations

---

## Backup Locations

| Operation | Backup Location |
|-----------|----------------|
| Sandbox migration | `tests/sandbox/backups/sandbox-backup-<timestamp>/` |
| Production deployment | `~/.claude/backups/sandbox-deploy-<timestamp>/` |

---

## Testing

- **Integration Tests**: 8 tests in `tests/integration/sandbox-workflow.test.sh`
  - Migration creates correct directory structure
  - Migration copies required files
  - Migration sets executable permissions
  - Validation passes after migration
  - Validation detects missing files
  - Validation detects bash syntax errors
  - Rollback restores from backup
  - Complete workflow (migrate then validate) succeeds

---

## Related Documentation

- [Coverage Tracking](07-coverage-tracking.md) - Code coverage for Bash scripts
- [Testing & Verification](14-testing-verification.md) - Full test documentation
- [Troubleshooting](15-troubleshooting.md) - Rollback procedures
