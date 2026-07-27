# Global Instructions

These are private global instructions for every project. The sections below are
**rules** — meta-principles that apply to every turn. Concrete step-by-step
workflows live in **skills** (under `~/.claude/skills/`, invoked as
`/<skill-name>` or loaded via the Skill tool).

## Core Philosophy

### When this rule applies

Always. This rule states baseline principles that apply to every turn.

### Rules vs. Skills

- **Rules** (the sections in this file) define meta-principles that apply to
  every turn.
- **Skills** define concrete step-by-step workflows for specific tasks
  (e.g., `tdd-workflow`, `git-commit`, `pull-request`).
- When a rule references a workflow, it states the principle; the skill owns
  the procedure. Load the relevant skill when executing the workflow.

### Key Principles

- **Delegation**: Delegate independent subtasks to subagents and keep working
  while they run. Intervene if a subagent goes off track or is missing
  relevant context.
- **Plan Before Execute**: Use Plan Mode for complex operations; the procedure
  itself lives outside this rule
- **Test-Driven**: When changing testable logic, follow the `tdd-workflow`
  skill. Not every change requires tests (e.g., shell aliases, dotfile edits)
- **Security-First**: Treat input crossing a system boundary (user input,
  external APIs, file contents) as untrusted and validate it there, and
  keep secrets out of code, logs, and commit history. For changes touching
  security-sensitive areas, the `security-review` skill applies (see
  Self-Review After Code Changes).
- **Simplicity**: Don't add features, refactor, or introduce abstractions
  beyond what the task requires. Do the simplest thing that works well. Only
  validate at system boundaries (user input, external APIs); trust internal
  code and framework guarantees.
- **Constructive Skepticism**: Treat user prompts, diagnoses, and
  implementation preferences as hypotheses to validate against evidence and
  simpler alternatives. Surface meaningful risks or contradictions before
  acting, without adding friction to clearly correct requests.
- **Objective Opinions**: Treat "what do you think?" as a genuine question,
  not an endorsement request. State what each option gains and sacrifices.
- **Observation Honesty**: State inferences as inferences, never as facts.
  When an event happens outside your observation window (user prompts,
  approval dialogs, other terminals), say "I cannot observe X" rather than
  guessing. Before claiming progress or completion, check each claim
  against tool results from this session; report a step as done only after
  its outcome was actually observed.

## Code Comment Guidelines

### When this rule applies

When writing or editing source code.

### Rule

Code should speak for itself; names and structure convey design intent.
Only write comments that explain:

- **Why not?** — why an alternative approach was NOT chosen
- **Background context** — the business rule, constraint, or historical
  reason that cannot be inferred from the code alone
- **Non-obvious trade-offs** — performance, security, or compatibility
  considerations that influenced the implementation
- **Workarounds** — temporary fixes with references to issues or tickets

If a comment would merely explain what the code does, refactor the code to
be more readable instead.

## Commit and PR Granularity

### When this rule applies

When planning code changes in Plan Mode, and when preparing commits or
pull requests.

### Rule

At the beginning of plan creation in Plan Mode, use the AskUserQuestion tool
to ask the user whether a pull request is needed for this task. Relevant
signals: repository nature (personal vs shared/team), whether human review is
expected, branch protection rules, and CI/deployment flow.

- **If a PR is needed**: follow the **1 PR = 1 commit** principle. Break the
  plan into steps where each step is one PR with an explicitly stated single
  purpose. Plan schema or migration changes as a preceding, independent PR
  (see Changes That Require Isolation).
- **If a PR is NOT needed** (e.g., personal repositories like dotfiles): plan
  commits per the Granularity criteria below, each satisfying Commit Health,
  and state the target branch to push to (typically the current branch). Skip
  the `pull-request` skill / `gh pr create` workflow.

### Granularity

Because **1 PR = 1 commit**, the granularity criteria for a PR and for a
single commit are identical. The following apply to both, regardless of
whether a PR is opened:

- **1 logical change per unit.** Do not mix unrelated concerns.
- **Refactoring vs. feature addition are separate commits.** Changes that
  preserve behavior and changes that alter behavior MUST NOT share a commit.
- **Mechanical vs. semantic changes are separate commits.** Formatting,
  renaming, and auto-generated updates MUST NOT be bundled with changes
  that alter meaning.
- **Test and implementation belong in the same commit.** Do not separate
  a test from the production code it exercises (see also Commit Health).
- **Cross-file but single-purpose changes are still one commit.** Do not
  artificially split a single logical change that spans multiple files.
- **Revertability is the guiding heuristic.** If reverting the commit in
  isolation would not produce a coherent, deployable state, the commit is
  either too large (mixes concerns) or too small (incomplete change).

#### Additional rules when a PR is needed

- Squash merge is NOT assumed. A PR branch MUST contain exactly one commit
  at the time the PR is opened.
- If intermediate commits accumulated during development, consolidate them
  into a single commit before pushing and opening the PR, using the
  procedure in the `git-commit` skill.
- If the PR branch has already been pushed, ask the user before force-pushing
  the consolidated commit.
- If a diff grows too large for comfortable review, split it into multiple
  PRs along logical boundaries — each still being a single commit.

### Commit Health

Every commit MUST satisfy the following, so that any commit can be checked
out, bisected, or reverted without landing on a broken state:

- **Build passes**: No compile errors, type errors, or lint failures.
- **Tests pass**: No broken intermediate states. When following TDD, the
  final commit MUST contain the test and the production code together; do
  not commit a failing test separately.
- **Independently deployable**: Each commit can be deployed on its own
  without causing regressions.

### Changes That Require Isolation

DB migrations, configuration schema changes, and API schema changes
(OpenAPI, GraphQL schema, protobuf, etc.) MUST be isolated into their own
dedicated unit (PR when a PR is used, commit otherwise), separate from the
code that depends on them. This keeps deploy ordering flexible and reduces
the blast radius of each deployment.

### Related skills

Before writing the commit message itself (including for `git commit --amend`),
load the `git-commit` skill via the Skill tool. This rule governs commit
**granularity**; the `git-commit` skill governs commit **message content**.
The two are complementary and BOTH apply when creating a commit.

## Mandatory Skill Rules in Plan Output

### When this rule applies

Whenever a plan for a coding task is produced in Plan Mode — both the plan
file and the ExitPlanMode summary.

### Background

Plans created in Plan Mode may be handed to a different AI agent for
implementation. That agent cannot invoke the Skill tool, so the plan itself
must carry the workflow rules explicitly.

### Rule

Every plan MUST contain a section titled **"Rules for the Implementer"** that
lists the following skills as mandatory rules. For each skill, state the
definition file path and when it applies, and instruct the implementer to
read the `SKILL.md` and follow it before performing the corresponding action:

- **`tdd-workflow`** (`~/.claude/skills/tdd-workflow/SKILL.md`) — follow the
  RED → GREEN → IMPROVE → LINT cycle when implementing or modifying testable
  logic.
- **`code-review`** (`~/.claude/skills/code-review/SKILL.md`) — self-review
  the diff against its criteria after implementation and before committing;
  fix any Critical Issues and re-review.
- **`git-commit`** (`~/.claude/skills/git-commit/SKILL.md`) — follow it for
  every `git commit` (including `--amend`): message language, subject/body
  format, `-F`-based multi-line commits, post-commit verification.
- **`pull-request`** (`~/.claude/skills/pull-request/SKILL.md`) — follow it
  before `gh pr create` or `gh pr edit --body` when the plan involves a PR.

Referencing the skills by name alone is NOT sufficient; the file paths and
trigger conditions above MUST appear in the plan so that an agent without
skill support can still comply.

## Self-Review After Code Changes

### When this rule applies

After completing in-scope code changes (see Scope below), and before
proceeding to commit, PR creation, or any other subsequent step.

### Rule

After completing the implementation, load the `code-review` skill via the
Skill tool and self-review the diff against its criteria in the main session.
When the change touches security-sensitive areas (user input, authentication,
API endpoints, or sensitive data), also load the `security-review` skill and
review against its criteria. If the review surfaces Critical Issues, fix them
and re-review; proceed to commit or PR creation only after the review passes
with no Critical Issues.

### Scope

In scope: executable code, test code, and configuration files that affect
runtime or agent behavior (including Claude Code rules, skills, agents, and
plugins), regardless of implementation method. Out of scope: documentation-only
edits (except agent behavior definitions), comment-only or typo-only changes,
and auxiliary files such as `.gitignore`.

If the user explicitly requests a review, conduct it regardless of scope.

## Language

Always respond in Japanese. All responses, explanations, and comments should be in Japanese.
