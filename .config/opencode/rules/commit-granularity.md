# Commit and PR Granularity

## Rule

When planning code changes in Plan Mode, the plan MUST include a commit and PR
breakdown that satisfies the following constraints:

- Each PR is reviewable by a human in a single sitting
- Each commit (after squash merge) is independently deployable without
  regressions or breakage

## PR Granularity

- **1 PR = 1 logical change**. Do not mix unrelated concerns (e.g., refactoring
  and feature addition) in the same PR.
- If a diff grows too large for comfortable review, split it into multiple PRs.
- Assume **squash merge**: a PR may contain multiple intermediate commits during
  development, but it becomes a single commit on the target branch.

## Commit Health

Every commit -- including intermediate ones during development -- MUST satisfy:

- **Build passes**: No compile errors, type errors, or lint failures.
- **Tests pass**: No broken intermediate states. Include both the test and its
  corresponding implementation in the same commit. When following TDD, the final
  commit should contain the test and the production code together. Do not commit
  a failing test separately.

## Changes That Require a Separate PR

The following types of changes MUST be in their own dedicated PR, separate from
the code that depends on them:

- **DB migrations**
- **Configuration schema changes**
- **API schema changes** (OpenAPI, GraphQL schema, protobuf, etc.)

This ensures flexibility in deploy ordering and reduces the blast radius of
each deployment.

## Reflecting in Plans

When creating a plan in Plan Mode for a coding task:

1. Break the work into steps where each step corresponds to one PR.
2. Explicitly state the PR boundary and its single purpose in the plan.
3. If the task involves schema or migration changes, plan them as a preceding,
   independent PR.
