# Plan File Path in Plan Output

## When this rule applies

Whenever you present a plan in Plan Mode.

## Rule

If plan mode stores the plan as a file, include the file's absolute path in
the message that presents the plan, on its own line:

```text
Plan file: /absolute/path/to/plan.md
```

Keep the `Plan file:` label literal even when responding in Japanese.

- Use the file plan mode actually writes; never invent a path.
- If the plan is not stored as a file, say so instead of guessing a path.
  OpenCode 2 keeps the plan in the conversation and names only a directory
  for explicit saves, so state that no plan file exists unless the user
  asked for one.
