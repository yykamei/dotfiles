# Mandatory Skill Rules in Plan Output

## When this rule applies

Whenever a plan is produced in Plan Mode.

## Background

Plans created in Plan Mode may be executed in a fresh session or handed to a
different AI agent for implementation. That agent may not know which skills
apply or may not have the `skill` tool, so the plan itself must carry the
skill references and workflow rules explicitly.

## Rule

Every plan MUST contain a section titled **"Rules for the Implementer"** that
lists all skills to be used during implementation. For each skill, state its
path-derived skill ID (normally the directory name), its definition file path
(`SKILL.md`), and the step where it applies. Then instruct the implementer to
load the skill through the harness's skill mechanism (or read the `SKILL.md`
directly if no skill tool is available) and follow it before performing the
corresponding action.

Let `<skills-dir>` be the platform's user-level skills directories:
`~/.claude/skills/` for Claude Code, `~/.agents/skills/` for Codex, and
`~/.config/opencode/skills/`, `~/.agents/skills/`, and `~/.claude/skills/`
for OpenCode.

1. **Standard workflow skills** (mandatory for any plan that modifies a
   repository):
   - **`no-metaprogramming`** (`<skills-dir>/no-metaprogramming/SKILL.md`) —
     load it before writing production code so its restrictions stay in
     context while implementing; metaprogramming tends to creep in
     mid-implementation, and the skill enumerates the permitted exceptions.
   - **`tdd-workflow`** (`<skills-dir>/tdd-workflow/SKILL.md`) — follow the
     RED → GREEN → IMPROVE → LINT cycle when implementing or modifying
     testable logic.
   - **`code-review`** (`<skills-dir>/code-review/SKILL.md`) — self-review
     the diff against its criteria after implementation and before
     committing; fix any blocking findings and re-review (see Self-Review
     After Code Changes). For security-sensitive changes, the plan must also
     require delegating to the `security-reviewer` subagent.
   - **`git-commit`** (`<skills-dir>/git-commit/SKILL.md`) — follow it for
     every `git commit` (including `--amend`): message language,
     subject/body format, `-F`-based multi-line commits, post-commit
     verification.
   - **`pull-request`** (`<skills-dir>/pull-request/SKILL.md`) — follow it
     before `gh pr create` or `gh pr edit --body`; every change ends in a
     PR.
2. **Task-specific skills**: Review the available skills (under
   `<skills-dir>`, configured `skills` sources, and project-local skill
   directories) when creating the plan, and include every additional skill
   that applies to the planned work (for example, `css`, `naturalize-japanese`,
   `security-review`, `pbi-create`, or project-specific skills). For each
   applicable skill, state its `SKILL.md`
   file path (or note that it is a built-in skill when no file path exists on
   disk) and the specific step or condition in the plan where it must be
   applied.

Referencing the skills by ID alone is NOT sufficient; the file paths and
trigger conditions above MUST appear in the plan so that an agent without
skill support can still comply.
