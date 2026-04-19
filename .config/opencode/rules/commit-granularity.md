# Commit and PR Granularity

## Rule

When planning code changes in Plan Mode, the plan MUST satisfy the following:

- First, ask the user whether a pull request is needed for this task.
- If a PR is needed: follow the **1 PR = 1 commit** principle below.
- If a PR is NOT needed (e.g., personal repositories like dotfiles): push the
  commit(s) directly to the current branch and skip the PR workflow.
- Every commit MUST be independently deployable without regressions or breakage.
- The **granularity principles** below apply equally to PRs and to commits.

## Deciding Whether a PR Is Needed

At the beginning of plan creation in Plan Mode, use the `question` tool to
confirm with the user whether this task requires a pull request.

Consider the following signals when framing the question:

- Repository nature (personal vs shared/team)
- Whether human review is expected
- Branch protection rules
- CI / deployment flow

If the user decides a PR is not needed, plan the work to be pushed directly to
the current branch and skip the `pull-request` skill / `gh pr create` workflow.

## Granularity

Because **1 PR = 1 commit**, the granularity criteria for a PR and for a
single commit are identical. The following apply to both, regardless of
whether a PR is opened:

- **1 logical change per unit.** A commit (and therefore a PR) represents
  exactly one logical change. Do not mix unrelated concerns.
- **Refactoring vs. feature addition are separate commits.** Changes that
  preserve behavior and changes that alter behavior MUST NOT share a commit.
- **Mechanical vs. semantic changes are separate commits.** Formatting,
  renaming, and auto-generated updates MUST NOT be bundled with changes
  that alter meaning.
- **Test and implementation belong in the same commit.** Do not separate
  a test from the production code it exercises (see also Commit Health).
- **Cross-file but single-purpose changes are still one commit.** A single
  logical change may span multiple files; do not artificially split it.
- **Revertability is the guiding heuristic.** If reverting the commit in
  isolation would not produce a coherent, deployable state, the commit is
  either too large (mixes concerns) or too small (incomplete change).

### Additional rules when a PR is needed

- Squash merge is NOT assumed. A PR branch MUST contain exactly one commit
  at the time the PR is opened.
- If intermediate commits accumulated during development, integrate them
  into a single commit before pushing and opening the PR. Use non-interactive
  approaches such as `git reset --soft <base>` followed by a single
  `git commit`, or `git commit --amend` when only the latest commit needs
  to be updated. Do NOT use `git rebase -i` (interactive flags are not
  supported by the non-interactive shell).
- If the PR branch has already been pushed, ask the user before force-pushing
  the consolidated commit.
- If a diff grows too large for comfortable review, split it into multiple
  PRs along logical boundaries -- each still being a single commit.

## Commit Health

Every commit MUST satisfy:

- **Build passes**: No compile errors, type errors, or lint failures.
- **Tests pass**: No broken intermediate states. Include both the test and its
  corresponding implementation in the same commit. When following TDD, the
  final commit MUST contain the test and the production code together. Do not
  commit a failing test separately.
- **Independently deployable**: Each commit can be deployed on its own without
  causing regressions.

## Changes That Require Isolation

The following types of changes MUST be isolated into their own dedicated unit
(PR when a PR is used, commit otherwise), separate from the code that depends
on them:

- **DB migrations**
- **Configuration schema changes**
- **API schema changes** (OpenAPI, GraphQL schema, protobuf, etc.)

This ensures flexibility in deploy ordering and reduces the blast radius of
each deployment.

## Reflecting in Plans

When creating a plan in Plan Mode for a coding task:

1. **First**, ask the user whether a PR is needed (see above).
2. If a PR is needed:
   - Break the work into steps where each step is one PR = one commit,
     following the Granularity criteria above.
   - Explicitly state the PR boundary and its single purpose in the plan.
   - If the task involves schema or migration changes, plan them as a
     preceding, independent PR.
3. If a PR is not needed:
   - Break the work into commits following the Granularity criteria above,
     each also satisfying Commit Health.
   - State the target branch to push to (typically the current branch).

## Related skills

Before writing the commit message itself (including for `git commit --amend`),
load the `git-commit` skill via the `skill` tool. This rule governs commit
**granularity**; the `git-commit` skill governs commit **message content**
(language, subject/body format, `-F`-based multi-line commits, post-commit
verification). The two are complementary and BOTH apply when creating a commit.
