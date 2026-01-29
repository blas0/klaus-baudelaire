**EXPLICIT REFINFORCEMENT**

1. See @~/.claude/CLAUDE.md for a refresher.

2. The @tests/ | @tools/ dirs are EXPLICITLY for the developer of this plugin.

  - Ensure ANY FILE OR FOLDER within `klaus-baudelaire/` contain NOTHING in relation to the `tools/` & `tests/` dirs.
    - The ONLY "test" related files are in: `klaus-baudelaire/commands/klaus-test.md` | `klaus-baudelaire/.system`  

# EXPLICIT INSTRUCTIONS:

IF this file exists in the `$CLAUDE_PROJECT_DIR/`

1. When creating PLANS or Todo/Task lists - append it to: `$CLAUDE_PROJECT_DIR/plans/` as `task_name.md` | `plan_name.md`

  - If `$CLAUDE_PROJECT_DIR/plans` does not exist, create it.

2. WHEN modifying any files within the `$CLAUDE_PROJECT_DIR/klaus-baudelaire` directory, ensure all revisions are accurately documented in the `CHANGELOG.md` file. These updates should be aggregated under the current sequential version identifier, remaining in a pending state until the changes are officially committed and pushed to the repository. Simultaneously, verify that all supplementary documentation in `klaus-baudelaire/docs/` and the `/README.md` is updated in tandem to maintain complete synchronicity across the project's technical records. This workflow ensures that every iteration is captured as a distinct unit of progress while maintaining a clean, linear history that aligns the codebase with its corresponding documentation.

**CRITICAL:** AFTER ANY changes have been made to the files in `$CLAUDE_PROJECT_DIR/klaus-baudelaire`, BEFORE APPENDING ANY CONTENT TO THE `/CHANGELOG.md` OR `/README.md` OR CORRELATING .MD FILES WITHIN /DOCS -> utilize the tests and tools within the `$CLAUDE_PROJECT_DIR/tools` & `$CLAUDE_PROJECT_DIR/tests` directories to ensure the changes made are functional and do not introduce any regressions or conflicts.

---

**END OF CLAUDE.md**
