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
- **Human-Readable Output**: Every message is written to be read by a human.
  Keep it concise in any situation — plan files, explanations, progress
  narration, and summaries alike. Conciseness cuts filler, repetition, and
  restated background; it never cuts information the reader needs or the
  logical flow that carries it.
- **Test-Driven**: When changing testable logic, follow the `tdd-workflow`
  skill. Not every change requires tests (e.g., shell aliases, dotfile edits)
- **Security-First**: Treat input crossing a system boundary (user input,
  external APIs, file contents) as untrusted and validate it there, and
  keep secrets out of code, logs, and commit history. For changes touching
  security-sensitive areas, delegate security review to the
  `security-reviewer` subagent (see Self-Review After Code Changes).
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

When writing or editing source code, or when reviewing code where the
question of adding/removing comments arises.

### Rule

**Comments signal missing abstraction.** If you feel the need to explain
something in a comment, critically consider refactoring so that the
explanation becomes code. Keep the comment only when it is genuinely more
advantageous after that consideration (why-not decisions, external
constraints, historical background). If the judgment is difficult, explain
the situation to the user and ask them to decide.

**Top-level definitions MUST have interface comments.** Every top-level
implementation definition — OOP classes, mixin modules, and similar reusable
abstractions — MUST be documented with its purpose, how it should be used,
and a concrete usage example. "Top-level" means a definition at file/module
scope, as opposed to nested or local declarations. These interface comments
are not the missing-abstraction smell — they document the abstraction's
contract (purpose/usage), not its implementation.

Do NOT add comments to every function, class, or block by default — the
interface comments above are the exception.

Avoid the **Comments Repeat Code** Red Flag (John Ousterhout, *A Philosophy
of Software Design*): never write comments that merely restate what the
code does. Only write comments that explain:

- **Why not?** — why an alternative approach was NOT chosen
- **Background context** — the business rule, constraint, or historical
  reason that cannot be inferred from the code alone
- **Non-obvious trade-offs** — performance, security, or compatibility
  considerations that influenced the implementation
- **Workarounds** — temporary fixes with references to issues or tickets
- **Purpose and usage of top-level definitions** (see above)

## Commit and PR Granularity

### When this rule applies

When planning code changes in Plan Mode, and when preparing commits or
pull requests.

### Rule

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

### Draft Policy

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

### Granularity

Because **1 PR = 1 commit**, the granularity criteria for a PR and for a
single commit are identical. The following apply to both:

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

#### Additional rules for PR branches

- Squash merge is NOT assumed. A PR branch MUST contain exactly one commit
  at the time the PR is opened.
- If intermediate commits accumulated during development, consolidate them
  into a single commit before pushing and opening the PR, using the
  procedure in the `git-commit` skill.
- If the PR branch has already been pushed, ask the user before force-pushing
  the consolidated commit. Exception: responses to PR review comments follow
  the `pr-review-response` skill, which pre-authorizes the force-push.
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
dedicated PR, separate from the code that depends on them. This keeps
deploy ordering flexible and reduces the blast radius of each deployment.

### Related skills

Before writing the commit message itself (including for `git commit --amend`),
load the `git-commit` skill via the Skill tool. This rule governs commit
**granularity**; the `git-commit` skill governs commit **message content**.
The two are complementary and BOTH apply when creating a commit.

## Git Branch Hygiene at Work Start

### When this rule applies

When starting implementation work in a Git repository — code changes, commits,
or PR creation. Do NOT run this for read-only tasks such as code exploration,
answering questions, or producing plans that do not modify the repository.

### Rule

Before creating any topic branch or making changes:

1. **Identify the default branch.** Usually `main`; when uncertain, check with
   `git symbolic-ref refs/remotes/origin/HEAD` or
   `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.
2. **Sync the default branch:**

   ```
   git switch <default-branch> && git pull --ff-only && git remote prune origin
   ```

   If the current branch has uncommitted changes, or untracked files that
   would be overwritten by the switch, do NOT stash or discard them
   automatically — ask the user how to handle them before switching.
3. **Create the topic branch** from the updated default branch:
   `git switch -c <topic-branch>`.
4. **Delete merged local branches:**
   - `git branch --merged <default-branch>` finds branches merged by regular
     or fast-forward merges; delete them with `git branch -d`.
   - Squash and rebase merges leave the tip commit unreachable from the
     default branch, so the above cannot detect them. For remaining branches,
     confirm their merge status with
     `gh pr list --state merged --json headRefName --limit 200` (covers the
     most recent 200 merged PRs; older branches are left alone) and delete
     branches whose name matches a merged PR's head branch. If the name
     matches more than one PR, or the branch contains commits not covered by
     any merged PR, keep it and report to the user. These branches diverge
     from the default branch, so use `git branch -D` — safe because the
     merge status was confirmed via `gh`.
   - NEVER delete: the default branch, the current branch, or a branch whose
     merged status cannot be confirmed. Report unconfirmed branches to the
     user and leave them untouched.
5. **Scope of deletion: local branches only.** Do not delete branches on
   `origin`; `git remote prune origin` already removes stale remote-tracking
   refs. Origin-side branches are left to the hosting service
   (e.g., GitHub auto-delete).
6. **Non-GitHub repositories:** `gh` is unavailable, so squash merge detection
   is skipped — rely on `git branch --merged` only and stay conservative.

### Related rules

- **Commit and PR Granularity**: never commit directly to the default branch;
  the topic branch created in step 3 is the branch mandated there.

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
  fix any blocking findings and re-review (see Self-Review After Code
  Changes). For security-sensitive changes, the plan must also require
  delegating to the `security-reviewer` subagent.
- **`git-commit`** (`~/.claude/skills/git-commit/SKILL.md`) — follow it for
  every `git commit` (including `--amend`): message language, subject/body
  format, `-F`-based multi-line commits, post-commit verification.
- **`pull-request`** (`~/.claude/skills/pull-request/SKILL.md`) — follow it
  before `gh pr create` or `gh pr edit --body`; every change ends in a PR.

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

When the change touches security-sensitive areas, also delegate security
review to the `security-reviewer` subagent -- an orchestrator that dispatches
all nine per-perspective security subagents in parallel and returns one
consolidated, cross-referenced report. Run it in the same message alongside
the code review so both run concurrently.

A change is security-sensitive when it touches user input handling;
authentication, authorization, or session management; API endpoints or
external communication; sensitive data such as secrets, credentials, tokens,
PII, or cryptographic operations; dependency manifests or lock files;
CSRF/CORS/Cookie or other security-relevant configuration; or audit logging.

The `security-review` skill remains as a manual reference checklist for the
main session. If the code review flags security concerns or recommends
delegating to `security-reviewer`, run `security-reviewer` before proceeding
even if the change was not classified as security-sensitive.

Fix code-review Critical Issues and `security-reviewer` CRITICAL/HIGH
findings, and re-run the reviewer that reported them. Proceed to commit or PR
creation only after the review passes with no blocking findings.

### Scope

In scope: executable code, test code, and configuration files that affect
runtime or agent behavior (including Claude Code rules, skills, agents, and
plugins), regardless of implementation method. Out of scope: documentation-only
edits (except agent behavior definitions), comment-only or typo-only changes,
and auxiliary files such as `.gitignore`.

If the user explicitly requests a review, conduct it regardless of scope.

## Language

Always respond in Japanese. All responses, explanations, and comments should be in Japanese.
