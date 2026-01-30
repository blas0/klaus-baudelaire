# GitHub Actions Workflows (OPTIONAL)

GitHub Actions CI/CD integration for Klaus System is **completely optional** and disabled by default.

## Status: Templates (Inactive)

Workflow files in this directory are **templates only** and will **NOT run automatically**. They must be explicitly enabled using the setup script.

## Why Optional?

1. **Not all users need CI/CD** - Klaus works perfectly without GitHub Actions
2. **Alternative CI/CD platforms** - Users may prefer GitLab CI, CircleCI, Jenkins, etc.
3. **Privacy concerns** - Some users prefer not to run CI on external platforms
4. **Repository flexibility** - Works in non-GitHub repositories
5. **No surprises** - Opt-in by design, never opt-out

## Enabling GitHub Actions

### Prerequisites
- Git repository initialized (`git init`)
- Repository hosted on GitHub
- Week 4 workflow templates implemented

### Enable workflows
```bash
# From project root
./klaus-baudelaire/setup-github-actions.sh enable
```

This will:
1. Copy workflow templates from `.github-workflows-templates/` to `.github/workflows/`
2. Update `ENABLE_GITHUB_ACTIONS="ON"` in `klaus-delegation.conf`
3. Display next steps for committing and pushing workflows

### Disable workflows
```bash
# From project root
./klaus-baudelaire/setup-github-actions.sh disable
```

This will:
1. Remove workflow files from `.github/workflows/`
2. Update `ENABLE_GITHUB_ACTIONS="OFF"` in `klaus-delegation.conf`
3. Preserve templates in `.github-workflows-templates/`

### Check status
```bash
# From project root
./klaus-baudelaire/setup-github-actions.sh status
```

## Available Workflows (Week 4)

When Week 4 is implemented, the following workflow templates will be available:

### 1. **ci.yml** - Continuous Integration
- Multi-platform testing (Ubuntu, macOS)
- Bun version matrix (1.0.25+)
- Runs on PRs and pushes to main

### 2. **test-suite.yml** - Test Execution
- Hook tests (128 tests)
- E2E tests (26 tests)
- Unit tests (79 tests)
- Integration tests with coverage

### 3. **coverage.yml** - Coverage Reporting
- TypeScript coverage with Bun
- LCOV report generation
- Optional codecov upload
- Coverage threshold validation (80%+)

### 4. **claude-code-review.yml** (Optional)
- Automated PR reviews
- Test result summaries
- Coverage change reports

## Configuration

### Feature Flag
File: `~/.claude/klaus-delegation.conf`

```bash
# === CI/CD INTEGRATION (Phase 1, Week 4 - OPTIONAL) ===
ENABLE_GITHUB_ACTIONS="OFF"        # OFF by default, opt-in via setup-github-actions.sh
```

This flag documents your preference. Actual workflows are enabled/disabled by the setup script moving files between directories.

### GitHub Secrets (if needed)
Some workflows may require GitHub repository secrets:

- `CODECOV_TOKEN` - For codecov.io coverage uploads (optional)
- `CLAUDE_API_KEY` - For automated reviews (optional, claude-code-review.yml only)

Configure these in: Repository Settings → Secrets and variables → Actions

## Design Philosophy

Klaus System is designed to be **CI/CD agnostic**:

- ✅ Works with GitHub Actions (opt-in)
- ✅ Works with GitLab CI (use test commands directly)
- ✅ Works with CircleCI (use test commands directly)
- ✅ Works with Jenkins (use test commands directly)
- ✅ Works without any CI/CD (local development)

The test infrastructure (`run-with-coverage.sh`, test suites) works **everywhere**, not just GitHub Actions.

## Manual CI/CD Integration

If you prefer another CI/CD platform, use these commands directly:

```bash
# Run all tests with coverage
bash klaus-baudelaire/tests/run-with-coverage.sh

# Run specific test suites
bash klaus-baudelaire/tests/hooks-suite.sh
bash klaus-baudelaire/tests/e2e-suite.sh
bash klaus-baudelaire/tests/unit-tests.sh
bun klaus-baudelaire/tests/integration-tests.ts

# Check coverage
cat ~/.claude/coverage/bun/lcov.info | grep -E "^(SF|FNF|FNH)"
```

## Support

- **Setup script**: `./klaus-baudelaire/setup-github-actions.sh`
- **Test infrastructure**: `klaus-baudelaire/tests/README.md`
- **Phase 1 progress**: `rlmTest/phase1-progress.md`

## Status

**Phase 1, Week 4**: PLANNED (not yet implemented)

When Week 4 is complete, workflow templates will be available in this directory. Until then, the setup script will report "Week 4 not yet implemented".
