# GitHub Actions: Optional Feature Flag

## Overview

GitHub Actions CI/CD integration for Klaus System is **completely optional** and disabled by default. This design ensures Klaus remains CI/CD agnostic and works in any environment.

## Design Philosophy

### Why Optional?

1. **Not all users need CI/CD** - Klaus works perfectly for local development without any CI/CD
2. **Alternative CI/CD platforms** - Users may prefer GitLab CI, CircleCI, Jenkins, Bitbucket Pipelines, etc.
3. **Privacy concerns** - Some organizations prefer not to run CI on external platforms
4. **Repository flexibility** - Works in non-GitHub repositories or private infrastructure
5. **No surprises** - Opt-in by design, never opt-out

### Key Principle

> The test infrastructure works **everywhere**, not just GitHub Actions.

All test commands (`run-with-coverage.sh`, test suites) are platform-agnostic shell scripts that work in any environment.

## Implementation

### Feature Flag

**File**: `~/.claude/klaus-delegation.conf`

```bash
# === CI/CD INTEGRATION (Phase 1, Week 4 - OPTIONAL) ===
ENABLE_GITHUB_ACTIONS="OFF"        # OFF by default, opt-in via setup-github-actions.sh
                                   # ON = workflows enabled in .github/workflows/
                                   # OFF = workflows remain as templates in .github-workflows-templates/
```

**Default**: `OFF` (disabled)

### Directory Structure

```
klaus-baudelaire/
├── .github-workflows-templates/    # Inactive templates (default)
│   ├── README.md                   # Documentation
│   ├── ci.yml                      # Multi-platform testing
│   ├── test-suite.yml              # Test execution
│   ├── coverage.yml                # Coverage reporting
│   └── claude-code-review.yml      # Automated reviews (optional)
│
├── .github/workflows/              # Active workflows (created on enable)
│   └── (empty until enabled)
│
└── klaus-baudelaire/
    └── setup-github-actions.sh     # Enable/disable script
```

### Setup Script

**File**: `klaus-baudelaire/setup-github-actions.sh`

**Commands**:
```bash
# Check status
./klaus-baudelaire/setup-github-actions.sh status

# Enable GitHub Actions
./klaus-baudelaire/setup-github-actions.sh enable

# Disable GitHub Actions
./klaus-baudelaire/setup-github-actions.sh disable
```

**What it does**:
- `enable`: Copies templates from `.github-workflows-templates/` to `.github/workflows/`
- `disable`: Removes workflows from `.github/workflows/` (templates preserved)
- `status`: Shows current status and available templates

## Enabling GitHub Actions

### Prerequisites

1. Git repository initialized: `git init`
2. Repository hosted on GitHub
3. Week 4 workflow templates implemented

### Step-by-Step

```bash
# 1. Check status
./klaus-baudelaire/setup-github-actions.sh status

# 2. Enable workflows
./klaus-baudelaire/setup-github-actions.sh enable

# 3. Review workflows
ls -la .github/workflows/

# 4. Commit workflows
git add .github/workflows
git commit -m "Enable GitHub Actions workflows"

# 5. Push to GitHub
git push origin main

# 6. Configure secrets (if needed)
# Go to: Repository Settings → Secrets and variables → Actions
# Add: CODECOV_TOKEN (optional, for coverage.yml)
```

### Verification

After pushing, GitHub Actions will automatically:
- Run tests on pull requests
- Run tests on pushes to main
- Generate coverage reports
- Post test results as PR comments

## Disabling GitHub Actions

```bash
# 1. Disable workflows
./klaus-baudelaire/setup-github-actions.sh disable

# 2. Commit removal
git add .github/workflows
git commit -m "Disable GitHub Actions workflows"

# 3. Push to GitHub
git push origin main
```

Templates remain preserved in `.github-workflows-templates/` and can be re-enabled anytime.

## Alternative CI/CD Platforms

Klaus test infrastructure works with **any CI/CD platform**. Use these commands directly in your CI configuration:

### GitLab CI (.gitlab-ci.yml)

```yaml
test:
  image: oven/bun:latest
  script:
    - bash klaus-baudelaire/tests/run-with-coverage.sh
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: .claude/coverage/bun/cobertura.xml
```

### CircleCI (.circleci/config.yml)

```yaml
version: 2.1
jobs:
  test:
    docker:
      - image: oven/bun:latest
    steps:
      - checkout
      - run: bash klaus-baudelaire/tests/run-with-coverage.sh
```

### Jenkins (Jenkinsfile)

```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh 'bash klaus-baudelaire/tests/run-with-coverage.sh'
            }
        }
    }
}
```

### No CI/CD (Local Development)

```bash
# Run all tests locally
bash klaus-baudelaire/tests/run-with-coverage.sh

# Run specific test suites
bash klaus-baudelaire/tests/hooks-suite.sh
bash klaus-baudelaire/tests/e2e-suite.sh
bun klaus-baudelaire/tests/integration-tests.ts
```

## Week 4 Workflow Templates

When Week 4 is implemented, these workflow templates will be available:

### 1. ci.yml - Continuous Integration
- **Triggers**: Pull requests, pushes to main
- **Platforms**: Ubuntu (latest), macOS (latest)
- **Bun versions**: 1.0.25, latest
- **Tests**: All test suites (hook, E2E, unit, integration)

### 2. test-suite.yml - Test Execution
- **Triggers**: Pull requests, manual dispatch
- **Runs**: All test suites with detailed reporting
- **Outputs**: Test results as PR comments

### 3. coverage.yml - Coverage Reporting
- **Triggers**: Pull requests, pushes to main
- **Generates**: TypeScript coverage with Bun
- **Uploads**: Optional codecov integration
- **Threshold**: Validates 80%+ coverage

### 4. claude-code-review.yml - Automated Reviews (Optional)
- **Triggers**: Pull requests
- **Reviews**: Test failures, coverage changes
- **Comments**: Automated PR feedback

## Configuration

### Repository Secrets

Some workflows may require GitHub secrets:

| Secret | Required For | Description |
|--------|-------------|-------------|
| `CODECOV_TOKEN` | coverage.yml | Codecov.io uploads (optional) |
| `CLAUDE_API_KEY` | claude-code-review.yml | Automated reviews (optional) |

Configure in: **Repository Settings → Secrets and variables → Actions**

### Workflow Customization

After enabling, edit workflows in `.github/workflows/` to customize:
- Trigger conditions
- Platform matrix
- Bun versions
- Coverage thresholds
- Notification settings

## Benefits of Opt-In Design

### For Users
✅ **No vendor lock-in** - Switch CI/CD platforms anytime
✅ **Privacy control** - Choose where code runs
✅ **Cost control** - Avoid unexpected CI/CD usage
✅ **Flexibility** - Use with any git hosting (GitHub, GitLab, Bitbucket, self-hosted)
✅ **Simplicity** - Works locally without any CI/CD setup

### For Klaus System
✅ **Platform agnostic** - Test infrastructure works everywhere
✅ **User freedom** - Users choose their tools
✅ **Reduced assumptions** - No GitHub dependency
✅ **Better defaults** - Disabled until explicitly wanted
✅ **Clear documentation** - Explicit opt-in process

## Status

**Phase 1, Week 4**: PLANNED (not yet implemented)

### Completed
- ✅ Feature flag added to klaus-delegation.conf
- ✅ Setup script created (setup-github-actions.sh)
- ✅ Templates directory structure created
- ✅ Documentation written
- ✅ Design philosophy established

### Remaining
- ⏳ Implement actual workflow files (ci.yml, test-suite.yml, coverage.yml)
- ⏳ Test workflows on GitHub repository
- ⏳ Validate codecov integration (optional)
- ⏳ Document GitHub secrets setup

## Support

- **Setup**: `./klaus-baudelaire/setup-github-actions.sh`
- **Tests**: `klaus-baudelaire/tests/README.md`
- **Progress**: `rlmTest/phase1-progress.md`
- **Templates**: `.github-workflows-templates/README.md`

## Related

- [Phase 1 Progress](../rlmTest/phase1-progress.md)
- [Test Infrastructure](../klaus-baudelaire/tests/README.md)
- [Configuration Reference](../klaus-baudelaire/klaus-delegation.conf)
