# Self-Review After Code Changes

## Rule

After completing any code implementation, you MUST conduct a self-review using
the `code-review` skill before proceeding to commit, PR creation, or any other
subsequent step.

## Workflow

1. **Finish implementation** -- Complete all code changes (including TDD cycles
   if using the `tdd-workflow` skill)
2. **Load the `code-review` skill** -- Use the skill tool to load `code-review`
3. **Gather the diff** -- Use `git diff` commands to collect all changes made
   during the implementation
4. **Review against criteria** -- Evaluate the diff using the code-review skill's
   review process (Correctness, Completeness, Clarity, Consistency, Testability)
5. **Classify and report findings** -- Categorize issues as Critical, Warning,
   or Suggestion using the code-review skill's output format
6. **Fix Critical Issues** -- If any Critical Issues are found, fix them
   immediately and re-run the self-review
7. **Proceed** -- Only after the self-review passes with no Critical Issues,
   move on to commit or PR creation

## Scope

This rule applies to **all** code changes, regardless of the implementation
method used (TDD, direct implementation, refactoring, etc.).
