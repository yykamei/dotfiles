# Plannotator Review Before Commit Or PR

## When this rule applies

After completing any changes, after any required self-review, and before
proceeding to commit, amend, push, PR creation, or any other subsequent
delivery step.

## Rule

Before committing, amending, pushing, or opening a pull request for any changes,
you MUST run a Plannotator review by loading the `plannotator-review` skill and
following its workflow. Do not proceed to commit, amend, push, or PR creation
until the Plannotator review has either passed or all requested changes have
been addressed.

## Workflow

1. **Finish implementation** -- Complete code changes and verification first.
2. **Run self-review first if applicable** -- If `self-review.md` applies, delegate
   to the `code-reviewer` agent and resolve any Critical Issues before running
   Plannotator.
3. **Load the Plannotator skill** -- Use the `skill` tool to load
   `plannotator-review`.
4. **Run Plannotator review** -- Follow the skill instructions, which run
   `plannotator review` for the current worktree or the relevant PR URL.
5. **Address feedback** -- If Plannotator returns requested changes, implement
   them, verify the result, and re-run any affected reviews as needed. Re-run
   self-review only when the follow-up changes are in scope for
   `self-review.md`; re-run Plannotator after addressing requested changes,
   repeating until it returns approval or no requested changes.
6. **Proceed** -- Only after Plannotator returns approval or no requested
   changes, move on to commit, amend, push, or PR creation.

## Scope

This rule applies to **all changes**, including documentation-only edits,
comment-only changes, typo fixes, auxiliary files, executable code, test code,
and configuration files.

## Tool failures

If `plannotator review` is unavailable or fails to launch, report the failure
and ask the user how to proceed before committing, amending, pushing, or opening
a pull request.
