# Breaking Changes in Public Repositories

## When this rule applies

When changing a repository whose artifacts are consumed outside the
repository — a published package or library, a CLI, a GitHub Action, a public
API, a configuration schema, or a plugin interface. A consumer's application
can break when it updates to a release that changes that surface.

1. Determine the visibility of the repository that receives the PR (the
   parent repository for a fork contribution), not necessarily the current
   checkout:

   ```sh
   gh repo view <target-repo> --json visibility -q .visibility
   ```

2. If the visibility is not `PUBLIC`, skip this rule. Private repositories
   may still use the disclosure below, but it is not required.
3. If the repository is `PUBLIC` but publishes nothing that another project
   consumes (for example, personal dotfiles or a public application with no
   documented API), skip this rule.
4. If you cannot tell whether the artifact has external consumers, ask the
   user before deciding.

## Rule

Treat backward compatibility as part of the product. Prefer a change that
existing consumers can adopt without editing their code or configuration, and
treat breaking compatibility as the last resort.

A breaking change is acceptable when the requirement genuinely needs it — for
example, a security fix that cannot preserve the old behavior, or a redesign
the user explicitly asked for. In that case, do NOT silently land it: follow
"Mandatory disclosure" below.

## What counts as a breaking change

Each of these breaks at least one consumer and requires disclosure when the
artifact is published:

- Removing or renaming a public symbol, parameter, option, field, endpoint,
  route, CLI flag, environment variable, or configuration key.
- Making an optional input required, narrowing an accepted type or range, or
  changing a function signature, return shape, or error type.
- Changing a default value or default behavior in a way that alters the
  result a consumer observes.
- Changing an output format, serialization, error code, exit code, log format,
  or on-disk format that consumers read.
- Raising the minimum supported runtime or dependency version, or dropping a
  platform.
- Changing behavior that documentation promises, including reverting a
  long-standing behavior that consumers may rely on.

These are not breaking changes:

- Purely additive changes: a new optional parameter, a new endpoint, a new
  response field that consumers can ignore, a new CLI flag whose default keeps
  current behavior.
- Internal refactoring, performance work, documentation, and tests that leave
  the documented behavior unchanged.

When the repository declares its own versioning policy (for example, SemVer in
`README.md` or `CONTRIBUTING.md`), that policy decides the boundary and takes
precedence over this list.

## Prefer non-breaking paths

Before accepting a breaking change, check whether one of these preserves the
requirement:

1. **Add, do not replace**: introduce the new API, flag, or field beside the
   old one and keep the old one working.
2. **Deprecate before removal**: warn at runtime or in documentation now, and
   remove in a later major release.
3. **Keep a compatibility shim**: translate the old input to the new one and
   keep accepting it, with a deprecation warning.
4. **Opt in**: ship the new behavior behind a flag that defaults to the
   current behavior.
5. **Make migration mechanical**: when removal is unavoidable, ship a codemod
   or a step-by-step migration guide so consumers can move quickly.

State which of these you considered. "No path exists" is a conclusion, not an
assumption.

## Mandatory disclosure

When a breaking change is unavoidable, record it in all three places. The
wording must agree across them.

1. **Commit message** — add `!` after the type (and scope) and a
   `BREAKING CHANGE:` footer, following the `git-commit` skill.
2. **PR body** — add a `## Breaking Changes` section, following the
   `pull-request` skill: what breaks, who is affected, the migration steps,
   and the major version bump the release needs.
3. **Completion report** — tell the user in the final message that the change
   is breaking, so release planning is not a surprise.

## Self-check before commit and PR

Compare the diff against the artifact's public surface: exported symbols,
public functions and types, CLI flags, environment variables, configuration
keys, endpoints, response fields, and documented behavior. If the diff changes
any of them, run the disclosure steps above before committing. If it does not,
confirm the compatibility path you chose is still intact.
