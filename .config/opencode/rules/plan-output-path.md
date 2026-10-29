# Plan File Path in Plan Output

## When this rule applies

Whenever you present a plan in Plan Mode, including a plan submitted through
Plannotator's `submit_plan`.

## Background

When Plannotator reviews a plan, it stores the plan in a file, but the path
never reaches the conversation, so the user cannot open or keep the plan
without searching the filesystem.

## Rule

Include the plan file's absolute path in the message that presents the plan,
on its own line:

```text
Plan file: /absolute/path/to/plan.md
```

Keep the `Plan file:` label literal even when responding in Japanese.

- **With Plannotator**: `submit_plan` writes the plan to
  `~/.plannotator/active/<project>/_active-plan.md` when it runs. `<project>`
  is the working directory's basename sanitized by Plannotator: lowercase,
  trim, whitespace and underscores become hyphens, other characters are
  removed, repeated hyphens collapse, leading and trailing hyphens are
  removed, and the result is truncated to 30 characters; if fewer than 2
  characters remain, use `_unknown`. Derive this path deterministically and
  print it before calling `submit_plan`.
- **After approval**: the result contains `Saved to: <path>` for the archived
  copy. Print that path in the next message; the active file is deleted on
  approval.
- **After denial**: the active file remains the current plan, so the path
  already shown stays valid.
- **Without Plannotator**: OpenCode 2 keeps the plan in the conversation and
  names only a directory for explicit saves, so state that no plan file
  exists unless the user asked for one. OpenCode 1 names the plan file in its
  plan-mode instructions; use it.

If the plan is not stored as a file, say so instead of guessing a path.
