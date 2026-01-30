# Coverage Tracking

> **Back to [README](../TLDR-README.md)** | **Prev: [Feature Flags](06-feature-flags.md)** | **Next: [Production Testing](08-production-testing.md)**

---

## Overview

The Bash Code Instrumentation system provides PS4-based coverage tracking for Bash scripts with no external dependencies beyond jq. It measures which lines of your Bash scripts are executed during test runs.

---

## How It Works

Klaus uses Bash's built-in tracing mechanism:

```
PS4='+ ${BASH_SOURCE}:${LINENO}: '
BASH_XTRACEFD=3
```

- **PS4**: Custom trace prefix that includes filename and line number
- **BASH_XTRACEFD**: Redirects trace output to file descriptor 3 (separates trace from stdout/stderr)

This approach requires **no external tools** -- only Bash and jq.

---

## Tools

### run-with-coverage.sh (Coverage Wrapper)

Runs a Bash script with coverage instrumentation.

```bash
bash tools/run-with-coverage.sh <script.sh> [args...]
```

**What it does**:
- Enables PS4 + BASH_XTRACEFD instrumentation
- Redirects trace output to `/tmp/klaus-coverage-<PID>.trace`
- Preserves the original script's exit code
- Automatically triggers coverage analysis

### analyze-coverage.sh (Coverage Analyzer)

Parses trace files to calculate coverage.

```bash
bash tools/analyze-coverage.sh <trace_file> <source_script>
```

**Output**:
- Coverage percentage (executed / total code lines)
- List of untested lines (lines not executed)
- JSON report at `coverage/<script>-coverage.json`

**JSON Report Format**:

```json
{
  "script": "klaus-delegation.sh",
  "coverage_percent": 87.5,
  "executed_lines": [1, 2, 3, 5, 7, 10],
  "untested_lines": [4, 6, 8, 9],
  "timestamp": "2026-01-27T10:30:00Z"
}
```

### merge-coverage.sh (Coverage Merge)

Aggregates multiple coverage reports.

```bash
bash tools/merge-coverage.sh [coverage_dir]
```

**Features**:
- Bash 3 compatible (pipe-delimited arrays)
- Aggregates all `*-coverage.json` files
- Calculates overall average coverage percentage
- Console summary table sorted by script
- Threshold validation (default: 80%, configurable via `COVERAGE_THRESHOLD` env var)
- Exit code: 0 if threshold met, 1 if not

### coverage-report.sh (HTML Report Generator)

Generates visual HTML coverage reports.

```bash
bash tools/coverage-report.sh [coverage_dir] [output.html]
```

**Features**:
- Color-coded status: Excellent (90%+), Good (80-89%), Fair (70-79%), Poor (<70%)
- Interactive coverage bars
- Summary metrics
- Self-contained HTML (no external dependencies)

---

## Complete Workflow

```bash
# [1] Run script with coverage
bash tools/run-with-coverage.sh hooks/klaus-delegation.sh

# [2] Analyze coverage
bash tools/analyze-coverage.sh /tmp/klaus-coverage-*.trace hooks/klaus-delegation.sh

# [3] Repeat for other scripts
bash tools/run-with-coverage.sh hooks/feature-flag-registry.sh
bash tools/analyze-coverage.sh /tmp/klaus-coverage-*.trace hooks/feature-flag-registry.sh

# [4] Merge all reports
bash tools/merge-coverage.sh coverage/
```

---

## Coverage Thresholds

Default threshold is 80%. Override via environment variable:

```bash
COVERAGE_THRESHOLD=90 bash tools/merge-coverage.sh coverage/
```

**Coverage Formula**:

```
coverage = (executed_lines / (total_lines - empty_lines - comment_lines)) * 100
```

---

## Testing

- **Unit Tests**: 5 tests in `tests/unit/coverage-instrumentation.test.sh`
  - Coverage wrapper generates trace file
  - Coverage analyzer parses trace correctly
  - Coverage analyzer calculates percentage correctly
  - Coverage analyzer generates JSON report
  - Merge coverage combines multiple reports

---

## Related Documentation

- [Testing & Verification](14-testing-verification.md) - Full test suite documentation
- [Production Testing](08-production-testing.md) - Sandbox-based deployment testing
