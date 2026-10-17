# Mandatory Skill Rules in Plan Output

## When this rule applies

Whenever a plan is produced in Plan Mode (including plans submitted via
`submit_plan`).

## Background

Plans created in Plan Mode may be executed in a fresh session or handed to a
different AI agent for implementation. That agent may not know which skills
apply or may not have the `skill` tool, so the plan itself must carry the
skill references and workflow rules explicitly.

## Rule

Every plan MUST contain a section titled **"Rules for the Implementer"** that
lists all skills to be used during implementation. For each skill, state the
skill name, its definition file path (`SKILL.md`), and when or in which step
of the plan it applies, and instruct the implementer to load the skill via
the `skill` tool (or read the `SKILL.md` directly if the `skill` tool is
unavailable) and follow it before performing the corresponding action:

1. **Standard workflow skills** (mandatory for any plan that modifies a
   repository):
   - **`tdd-workflow`** (`~/.config/opencode/skills/tdd-workflow/SKILL.md`) —
     follow the RED → GREEN → IMPROVE → LINT cycle when implementing or
     modifying testable logic.
   - **`code-review`** (`~/.config/opencode/skills/code-review/SKILL.md`) —
     after implementation and before committing, delegate to the
     `code-reviewer` agent (or self-review the diff against `SKILL.md` if
     subagents are unavailable); fix any blocking findings and re-review (see
     Self-Review After Code Changes). For security-sensitive changes, the
     plan must also require delegating to the `security-reviewer` agent.
   - **`git-commit`** (`~/.config/opencode/skills/git-commit/SKILL.md`) —
     follow it for every `git commit` (including `--amend`): message
     language, subject/body format, `-F`-based multi-line commits,
     post-commit verification.
   - **`pull-request`** (`~/.config/opencode/skills/pull-request/SKILL.md`) —
     follow it before `gh pr create` or `gh pr edit --body`; every change
     ends in a PR.
2. **Task-specific skills**: Review the available skills (under
   `~/.config/opencode/skills/`, configured `skills.paths`,
   `~/.claude/skills/`, `~/.agents/skills/`, and project-local skill
   directories) when creating the plan, and include every additional skill
   that applies to the planned work (for example, `css`,
   `no-metaprogramming`, `hallmark`, `naturalize-japanese`, `pbi-create`,
   `customize-opencode`, or project-specific skills). For each applicable
   skill, state its `SKILL.md` file path (or note that it is a built-in skill
   when no file path exists on disk) and the specific step or condition in
   the plan where it must be applied.

Referencing the skills by name alone is NOT sufficient; the file paths and
trigger conditions above MUST appear in the plan so that an agent without
skill support can still comply.
