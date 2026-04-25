# Self-Review After Code Changes

## When this rule applies

After completing in-scope code changes (see Scope below), and before
proceeding to commit, PR creation, or any other subsequent step.

## Rule

After completing any code implementation, you MUST conduct a self-review by
delegating to the `code-reviewer` agent before proceeding to commit, PR
creation, or any other subsequent step.

## Workflow

1. **Finish implementation** -- Complete all code changes (including TDD cycles
   if using the `tdd-workflow` skill)
2. **Delegate to the `code-reviewer` agent** -- Use the Task tool to launch the
   `code-reviewer` agent. The agent will gather the diff, review it, and return
   a structured review report
3. **Handle Critical Issues** -- If the agent reports any Critical Issues, fix
   them in the main session and re-run the self-review by launching the agent
   again
4. **Proceed** -- Only after the review passes with no Critical Issues, move on
   to commit or PR creation

## Scope

This rule applies to changes in **executable code, test code, and
configuration files**, regardless of the implementation method used (TDD,
direct implementation, refactoring, etc.).

**In scope (self-review required):**

- Executable code -- `.ts`, `.js`, `.py`, `.go`, `.rs`, `.sh`, `.lua`, `.rb`,
  and similar source files
- Test code -- any file under test directories or matching test naming
  conventions
- Configuration files -- `.yaml`, `.yml`, `.toml`, `.json`, `Dockerfile`, CI workflow
  definitions, build configs, and similar files that affect runtime behavior

**Out of scope (self-review skipped):**

- Documentation-only edits (`.md`, `.txt`)
- Comment-only or typo-only changes
- Auxiliary files such as `.gitignore`, `.editorconfig`

**Escape hatch:** If the user explicitly requests a review, run the
`code-reviewer` agent regardless of scope.
