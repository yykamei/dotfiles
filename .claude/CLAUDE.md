# Global Instructions

These are private global instructions for every project. The sections below are
**rules** — meta-principles that apply to every turn. Concrete step-by-step
workflows live in **skills** (under `~/.claude/skills/`, invoked as
`/<skill-name>` or loaded via the Skill tool).

## Core Philosophy

### When this rule applies

Always. This rule states baseline principles that apply to every turn.

### Overview

I use specialized agents and skills for complex tasks.

### Rules vs. Skills

- **Rules** (the sections in this file) define meta-principles that apply to
  every turn.
- **Skills** (loaded via the Skill tool, or invoked as `/<skill-name>`) define
  concrete step-by-step workflows for specific tasks (e.g., `tdd-workflow`,
  `git-commit`, `pull-request`).
- When a rule references a workflow, it states the principle; the skill owns
  the procedure. Load the relevant skill when executing the workflow.

### Key Principles

- **Agent-First**: Delegate to specialized agents for complex work
- **Parallel Execution**: Use the Agent tool with multiple agents when possible
- **Plan Before Execute**: Use Plan Mode for complex operations; the procedure
  itself lives outside this rule
- **Test-Driven**: When changing testable logic, follow the `tdd-workflow`
  skill. Not every change requires tests (e.g., shell aliases, dotfile edits)
- **Security-First**: Never compromise on security
- **Constructive Skepticism**: Treat user prompts, proposals, diagnoses, and
  implementation preferences as hypotheses to evaluate, not instructions to
  accept uncritically. Validate them against observed evidence, repository
  constraints, safety, maintainability, and simpler alternatives. Surface
  meaningful risks, trade-offs, or contradictions before acting, while avoiding
  unnecessary friction for low-risk or clearly correct requests. Ask concise
  questions only when uncertainty materially affects the outcome.
- **Objective Opinions**: Treat "what do you think?" as a genuine question,
  not an endorsement request. Always surface trade-offs -- state what is
  gained and what is sacrificed by each option.
- **Observation Honesty**: Distinguish what you directly observed (tool
  inputs/outputs, file contents) from what you inferred. State
  inferences as inferences, never as facts. When an event happens
  outside your observation window (user prompts, approval dialogs,
  other terminals), say "I cannot observe X" rather than guessing.

## Code Comment Guidelines

### When this rule applies

When writing or editing source code, or when reviewing code where the
question of adding/removing comments arises.

### Principle: Code Should Speak for Itself

Write code that is self-documenting. Variable names, function names, and code structure
should convey the design intent without requiring comments.

### When NOT to Write Comments

- Do NOT write comments that restate what the code does
- Do NOT write comments that describe the obvious behavior of a function or variable
- Do NOT add comments to every function, class, or block by default

### When to Write Comments

Only write comments that explain:

- **Why not?** -- Why an alternative approach was NOT chosen
  (e.g., "Avoided recursion here because the input can exceed stack depth limits")
- **Background context** -- The business rule, constraint, or historical reason
  behind a decision that cannot be inferred from the code alone
  (e.g., "The API returns dates in JST regardless of locale settings, per vendor specification")
- **Non-obvious trade-offs** -- Performance, security, or compatibility considerations
  that influenced the implementation
- **Workarounds** -- Temporary fixes with references to issues or tickets

### Bad vs Good Examples

Bad (restates the code):

```ts
// Get the user by ID
const user = getUserById(id);
```

Good (explains why):

```ts
// Using sequential processing instead of Promise.all because
// the payment gateway rate-limits concurrent requests to 5/sec
for (const payment of payments) {
  await processPayment(payment);
}
```

### Summary

If you feel the need to add a comment explaining what the code does,
consider refactoring the code to be more readable instead.

## Commit and PR Granularity

### When this rule applies

When planning code changes in Plan Mode, and when preparing commits or
pull requests.

### Rule

When planning code changes in Plan Mode, the plan MUST satisfy the following:

- First, ask the user whether a pull request is needed for this task.
- If a PR is needed: follow the **1 PR = 1 commit** principle below.
- If a PR is NOT needed (e.g., personal repositories like dotfiles): push the
  commit(s) directly to the current branch and skip the PR workflow.
- Every commit MUST be independently deployable without regressions or breakage.
- The **granularity principles** below apply equally to PRs and to commits.

### Deciding Whether a PR Is Needed

At the beginning of plan creation in Plan Mode, use the AskUserQuestion tool to
confirm with the user whether this task requires a pull request.

Consider the following signals when framing the question:

- Repository nature (personal vs shared/team)
- Whether human review is expected
- Branch protection rules
- CI / deployment flow

If the user decides a PR is not needed, plan the work to be pushed directly to
the current branch and skip the `pull-request` skill / `gh pr create` workflow.

### Granularity

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

#### Additional rules when a PR is needed

- Squash merge is NOT assumed. A PR branch MUST contain exactly one commit
  at the time the PR is opened.
- If intermediate commits accumulated during development, integrate them
  into a single commit before pushing and opening the PR. See the
  `git-commit` skill for the concrete consolidation procedure.
- If the PR branch has already been pushed, ask the user before force-pushing
  the consolidated commit.
- If a diff grows too large for comfortable review, split it into multiple
  PRs along logical boundaries -- each still being a single commit.

### Commit Health

Every commit MUST satisfy:

- **Build passes**: No compile errors, type errors, or lint failures.
- **Tests pass**: No broken intermediate states. Include both the test and its
  corresponding implementation in the same commit. When following TDD, the
  final commit MUST contain the test and the production code together. Do not
  commit a failing test separately.
- **Independently deployable**: Each commit can be deployed on its own without
  causing regressions.

### Changes That Require Isolation

The following types of changes MUST be isolated into their own dedicated unit
(PR when a PR is used, commit otherwise), separate from the code that depends
on them:

- **DB migrations**
- **Configuration schema changes**
- **API schema changes** (OpenAPI, GraphQL schema, protobuf, etc.)

This ensures flexibility in deploy ordering and reduces the blast radius of
each deployment.

### Reflecting in Plans

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

### Related skills

Before writing the commit message itself (including for `git commit --amend`),
load the `git-commit` skill via the Skill tool. This rule governs commit
**granularity**; the `git-commit` skill governs commit **message content**
(language, subject/body format, `-F`-based multi-line commits, post-commit
verification). The two are complementary and BOTH apply when creating a commit.

## Plan Mode Output Conciseness

### When this rule applies

Whenever Plan Mode is active — this covers every output produced during
planning: the plan file itself, in-progress narration between tool calls, and
the summary shown when calling ExitPlanMode.

### Principle: Concise but Sufficient

Be brief without dropping information needed for decision or execution. The
following MUST always be present: what changes, why, which files are affected,
how to verify, and commit/PR boundaries. Cutting any of these to save words is
NOT conciseness — it is an incomplete plan. Everything else (decorative
prose, repetition, restated background) should be cut.

### Plan File Guidelines

- Keep the Context section to a few sentences. Do not re-explain background
  the user already knows.
- Do not enumerate alternatives that were not chosen. If the reason for the
  chosen approach is essential to the decision, state it in one line.
- Do not paste full code. Summarize the change; include only key diffs or
  signatures when they are load-bearing.
- Prefer bullet points over prose. Do not multiply headings beyond what the
  structure requires.

### In-Progress Narration Guidelines

- Describe each step in one or two sentences.
- Do not restate tool results or file contents in the narration; state only
  the conclusion drawn from them.

### ExitPlanMode Summary Guidelines

- Do not repeat the plan file's content. State only the key points.

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

## Question Batching Guidelines

### When this rule applies

When using the AskUserQuestion tool to ask the user one or more questions.

### Rule

When asking the user questions using the AskUserQuestion tool, batch related
questions into a single invocation to minimize back-and-forth.

### Guidelines

- **Batch related questions**: Group questions about the same topic or context
  into a single AskUserQuestion invocation
- **Split unrelated topics**: If questions cover different topics or contexts,
  ask them in separate invocations
- **Sequential when dependent**: If a later question depends on the answer
  to an earlier one, split them into separate invocations and wait for the answer
- **Clear and focused**: Each individual question should be specific
  and self-contained

## Self-Review After Code Changes

### When this rule applies

After completing in-scope code changes (see Scope below), and before
proceeding to commit, PR creation, or any other subsequent step.

### Rule

After completing any code implementation, you MUST conduct a self-review in the
main session by loading the `code-review` skill before proceeding to commit, PR
creation, or any other subsequent step.

### Workflow

1. **Finish implementation** -- Complete all code changes (including TDD cycles
   if using the `tdd-workflow` skill)
2. **Review in the main session** -- Load the `code-review` skill via the Skill
   tool, then gather the diff, review it against the skill's criteria, and
   produce a structured review report. When the change touches security-sensitive
   areas (user input, authentication, API endpoints, or sensitive data), also
   load the `security-review` skill and review against its criteria.
3. **Handle Critical Issues** -- If the review surfaces any Critical Issues, fix
   them and re-run the self-review
4. **Proceed** -- Only after the review passes with no Critical Issues, move on
   to commit or PR creation

### Scope

This rule applies to changes in **executable code, test code, and
configuration files**, regardless of the implementation method used (TDD,
direct implementation, refactoring, etc.).

**In scope (self-review required):**

- Executable code -- `.ts`, `.js`, `.py`, `.go`, `.rs`, `.sh`, `.lua`, `.rb`,
  and similar source files
- Test code -- any file under test directories or matching test naming
  conventions
- Configuration files -- `.yaml`, `.yml`, `.toml`, `.json`, `Dockerfile`, CI workflow
  definitions, build configs, Claude Code configuration, agents, skills, plugins,
  and similar files that affect runtime or agent behavior

**Out of scope (self-review skipped):**

- Documentation-only edits (`.md`, `.txt`), unless the documentation is a
  Claude Code rule, skill, agent, command, or other agent behavior definition
- Comment-only or typo-only changes
- Auxiliary files such as `.gitignore`, `.editorconfig`

**Escape hatch:** If the user explicitly requests a review, load the
`code-review` skill and conduct the review regardless of scope.

### Related skills

- `code-review` -- review criteria, issue classification, and output format for
  the self-review itself.
- `security-review` -- additional security criteria to apply when the change
  touches security-sensitive areas.

## Language

Always respond in Japanese. All responses, explanations, and comments should be in Japanese.
