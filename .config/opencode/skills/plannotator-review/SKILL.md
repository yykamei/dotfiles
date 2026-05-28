---
name: plannotator-review
description: MUST be loaded before running Plannotator review for local changes or PRs. Defines the correct `plannotator review` commands, avoids the hanging `plannotator review --help` form, and describes the feedback loop before commit, push, or PR delivery.
---

# Plannotator Review Workflow

Use this skill when the `plannotator-review.md` rule requires a Plannotator
review before committing, amending, pushing, or opening a pull request.

## Commands

- Review the current worktree: `plannotator review`
- Review an existing pull request: `plannotator review <PR_URL>`

Do not run `plannotator review --help`. That form can enter the review flow and
wait indefinitely. If help output is needed, run `plannotator --help` instead.
If `plannotator review --help` is already hanging, send Ctrl-C or terminate the
process, then run `plannotator --help` instead.

## Workflow

Follow `plannotator-review.md` for the surrounding preconditions and delivery
gate. This skill defines the command selection and retry loop.

1. Decide the review target:
   - If a PR already exists and the task is to review that PR, run
     `plannotator review <PR_URL>`.
   - Otherwise, run `plannotator review` for the current worktree.
2. Read the Plannotator output and classify the result:
   - Approval or no requested changes: proceed with the next delivery step.
   - Requested changes: implement the requested changes, verify them, and run
     Plannotator review again.
3. When implementing requested changes from step 2, if those changes are in
   scope for `self-review.md`, run the `code-reviewer` self-review before
   re-running Plannotator review.
4. Repeat until Plannotator returns approval or no requested changes.

## Failures

If `plannotator` is unavailable, fails to launch, or times out, report the
failure and ask the user how to proceed before committing, amending, pushing, or
opening a pull request.
