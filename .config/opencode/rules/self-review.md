# Self-Review After Code Changes

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

This rule applies to **all** code changes, regardless of the implementation
method used (TDD, direct implementation, refactoring, etc.).
