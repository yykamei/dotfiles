# Full Diff Review for OSS Changes

## When this rule applies

When a change targets a public repository owned by someone other than the
signed-in user. This includes a fork-based contribution where the pull request
goes to an upstream project.

Repositories owned by the user and private or internal repositories are out of
scope.

## Identifying the Target Repository

Check the repository that will receive the change (the upstream), not the local
fork:

```sh
gh repo view <target-repo> --json visibility,owner \
  -q '{visibility: .visibility, owner: .owner.login}'
gh api user -q .login
```

Apply this rule only when `visibility` is `PUBLIC` and `owner` is not the
signed-in login. When the target is a fork's parent, run this check against the
parent repository.

## Rule

Delegating implementation to subagents is allowed. Before committing or opening
a pull request, the main session MUST obtain the complete diff itself and read
every hunk. A subagent's summary or report is not a substitute for reading the
diff.

Read all of these ranges:

- `git diff <base>...HEAD` for committed changes, where `<base>` is the target
  repository's default branch.
- `git diff` and `git diff --cached` for uncommitted changes.

Skip only the paths allowed by the `commit-granularity` rule's Reviewable Size
exclusions (for example, lockfiles, vendored or generated code, and binary
assets), and report what you skipped.

If the diff exceeds the reviewable size hard limit (600 changed lines), stop
before committing and propose splitting the change. Do not commit or open a pull
request without reading the full diff.

Report the reviewed base, changed files, and changed line counts to the user
before committing.

## Relationship to Other Rules

- This rule complements `self-review.md`; the code review still runs in the
  main session.
- Delegating read-only review (for example, to `security-reviewer`) remains
  allowed. The main session verifies the findings before proceeding.
