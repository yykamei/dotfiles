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
   consolidated to exactly one commit per PR before that PR is opened.
3. A PR opened by following the `pull-request` skill, applying the
   Draft Policy below. When the work spans multiple PRs, this becomes a
   stack (see Stacked Pull Requests below).

Every commit MUST be independently deployable without regressions or
breakage, evaluated relative to its base: the default branch for a standalone
change, or the layer below for a stack layer. Because an upper layer may
depend on lower layers, deployability and revertibility are evaluated
bottom-up, not in isolation (see Stacked Pull Requests below). The
**granularity principles** below apply equally to PRs and to commits.

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

When the work is a stack, apply this policy to every layer.

## Granularity

Because **1 PR = 1 commit relative to its base branch**, the granularity
criteria for a PR and for a single commit are identical. The following apply
to both:

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
- **Revertability is the guiding heuristic.** If reverting the commit while
  its base is present would not produce a coherent, deployable state, the
  commit is either too large (mixes concerns) or too small (incomplete
  change). In a stack, revert from the top down: a lower layer is unsafe to
  revert while upper layers still depend on it.

### Additional rules for PR branches

- Squash merge is NOT assumed. A PR branch MUST contain exactly one commit
  relative to its base branch at the time the PR is opened. For a stacked
  PR, that base is the layer below; only the bottom layer targets the
  default branch.
- If intermediate commits accumulated during development, integrate them
  into a single commit before pushing and opening the PR. See the
  `git-commit` skill for the concrete consolidation procedure.
- If the PR branch has already been pushed, ask the user before force-pushing
  the consolidated commit. Exception: responses to PR review comments follow
  the `pr-review-response` skill, which pre-authorizes the force-push.
- If a diff grows too large for comfortable review, split it into multiple
  PRs along logical boundaries -- each still being a single commit -- and
  stack them as described below when possible.

### Stacked Pull Requests

Keep one session's work in one pull request by default. Do not split a task
just to create a stack; split only when the Granularity criteria require it
(for example, a diff too large to review, mixed concerns, or an
isolation-required change). When such a split produces multiple PRs, open
them as a stacked pull request chain whenever the branches can live in the
repository that receives the PRs. A stack is an ordered chain where each PR
targets the branch of the PR below it, and only the bottom PR targets the
default branch.

- **Stack when possible.** GitHub does not support cross-fork stacks, so a
  fork-based contribution to another repository is opened as independent
  PRs; the same fallback applies when the repository or host rejects
  stacks.
- **1 layer = 1 PR = 1 commit.** Each layer is one logical change with
  exactly one commit relative to its base branch: the default branch for
  the bottom layer, the layer below for every other layer.
- **Order by dependency.** Foundational changes go in the bottom layer, so
  lower layers can merge and deploy first.
- **Bottom-up deployability.** An upper layer may depend on lower layers, so
  it is not deployable in isolation; each layer must build and pass tests on
  top of its base, and deployments follow the merge order bottom up.
- **Merge bottom up.** A stack supports merging the whole chain or only the
  layers up to a chosen PR, keeping partial delivery possible.

See the `pull-request` skill for the concrete `gh stack` commands.

## Commit Health

Every commit MUST satisfy the following, so that any commit can be checked
out, bisected, or reverted without landing on a broken state:

- **Build passes**: No compile errors, type errors, or lint failures.
- **Tests pass**: No broken intermediate states. Include both the test and its
  corresponding implementation in the same commit. When following TDD, the
  final commit MUST contain the test and the production code together. Do not
  commit a failing test separately.
- **Independently deployable**: Each commit can be deployed on its own without
  causing regressions. For a stack layer, this means it builds, passes tests,
  and is revertible on top of its base; deployment happens bottom up.

## Changes That Require Isolation

The following types of changes MUST be isolated into their own dedicated
PR, separate from the code that depends on them:

- **DB migrations**
- **Configuration schema changes**
- **API schema changes** (OpenAPI, GraphQL schema, protobuf, etc.)

This ensures flexibility in deploy ordering and reduces the blast radius of
each deployment. When the work is stacked, put these changes in the lowest
layer(s), each in its own layer and ordered by dependency (for example, a DB
migration below an API schema change), and stack the dependent changes above;
never share a layer with the dependent code. Merge and deploy the bottom layer
before merging the layers above, which the bottom-up merge of a stack
supports.

## Reflecting in Plans

When creating a plan in Plan Mode for a coding task:

1. Break the work into steps where each step is one PR = one commit,
   following the Granularity criteria above. Keep the task in a single PR
   unless those criteria require a split; if the work does yield multiple
   PRs, group the steps into a single stack, ordered bottom to top, when
   stacking is possible.
2. Explicitly state the PR boundary and its single purpose in the plan,
   plus the topic branch to push and whether the PR will be a draft (per
   the Draft Policy above). For a stack, list every layer in order with
   its branch name, base branch, single purpose, and draft status; if the
   work is instead opened as independent PRs, state why stacking is not
   possible.
3. If the task involves schema or migration changes, plan each as its own
   layer at the bottom of the stack, ordered by dependency (or as a
   preceding, independent PR when the work is not stacked).

## Related skills

Before writing the commit message itself (including for `git commit --amend`),
load the `git-commit` skill via the `skill` tool. This rule governs commit
**granularity**; the `git-commit` skill governs commit **message content**
(language, subject/body format, `-F`-based multi-line commits, post-commit
verification). The two are complementary and BOTH apply when creating a commit.
