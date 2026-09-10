# Commit and PR Granularity

## When this rule applies

When planning code changes in Plan Mode, and when preparing commits or
pull requests.

## Rule

Every change ends in a pull request. Do NOT ask the user whether a pull
request is needed, and never push commits directly to the default branch
(`main` / `master`). Both the PR requirement and the branch prohibition
are waived only when the user explicitly instructs otherwise in the
current request (e.g., "push directly to main"). Without such an
instruction, always finish with:

1. A topic branch (never commit directly on the default branch).
2. Commit(s) satisfying the Granularity and Commit Health criteria below,
   consolidated to exactly one commit before the PR is opened.
3. A PR opened by following the `pull-request` skill, applying the
   Draft Policy below.

Every commit MUST be independently deployable without regressions or
breakage. The **granularity principles** below apply equally to PRs and
to commits.

## Draft Policy

Determine the repository's visibility with
`gh repo view --json visibility -q .visibility`:

- **PUBLIC (open source)**: NEVER open the PR as a draft. Some
  open-source repositories forbid draft pull requests, and creating one
  can fail or be rejected. Open the PR only after the self-review rule
  has completed with no blocking findings and you have full confidence in
  the change. If any doubt remains, do NOT open the PR; report the
  remaining concerns to the user instead of falling back to a draft.
- **PRIVATE / INTERNAL**: ALWAYS open the PR as a draft
  (`gh pr create --draft`). Mark it ready for review only when the user
  explicitly asks.

## Granularity

Because **1 PR = 1 commit**, the granularity criteria for a PR and for a
single commit are identical. The following apply to both:

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

### Additional rules for PR branches

- Squash merge is NOT assumed. A PR branch MUST contain exactly one commit
  at the time the PR is opened.
- If intermediate commits accumulated during development, integrate them
  into a single commit before pushing and opening the PR. See the
  `git-commit` skill for the concrete consolidation procedure.
- If the PR branch has already been pushed, ask the user before force-pushing
  the consolidated commit. Exception: responses to PR review comments follow
  the `pr-review-response` skill, which pre-authorizes the force-push.
- If a diff grows too large for comfortable review, split it into multiple
  PRs along logical boundaries -- each still being a single commit.

## Commit Health

Every commit MUST satisfy the following, so that any commit can be checked
out, bisected, or reverted without landing on a broken state:

- **Build passes**: No compile errors, type errors, or lint failures.
- **Tests pass**: No broken intermediate states. Include both the test and its
  corresponding implementation in the same commit. When following TDD, the
  final commit MUST contain the test and the production code together. Do not
  commit a failing test separately.
- **Independently deployable**: Each commit can be deployed on its own without
  causing regressions.

## Changes That Require Isolation

The following types of changes MUST be isolated into their own dedicated
PR, separate from the code that depends on them:

- **DB migrations**
- **Configuration schema changes**
- **API schema changes** (OpenAPI, GraphQL schema, protobuf, etc.)

This ensures flexibility in deploy ordering and reduces the blast radius of
each deployment.

## Reflecting in Plans

When creating a plan in Plan Mode for a coding task:

1. Break the work into steps where each step is one PR = one commit,
   following the Granularity criteria above.
2. Explicitly state the PR boundary and its single purpose in the plan,
   plus the topic branch to push and whether the PR will be a draft
   (per the Draft Policy above).
3. If the task involves schema or migration changes, plan them as a
   preceding, independent PR.

## Related skills

Before writing the commit message itself (including for `git commit --amend`),
load the `git-commit` skill via the `skill` tool. This rule governs commit
**granularity**; the `git-commit` skill governs commit **message content**
(language, subject/body format, `-F`-based multi-line commits, post-commit
verification). The two are complementary and BOTH apply when creating a commit.
