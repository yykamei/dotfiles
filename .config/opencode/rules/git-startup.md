# Git Branch Hygiene at Work Start

## When this rule applies

When starting implementation work in a Git repository — code changes, commits,
or PR creation. Do NOT run this for read-only tasks such as code exploration,
answering questions, or producing plans that do not modify the repository.

## Rule

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
   `git switch -c <topic-branch>`. When the work will span multiple PRs as
   a stack (see the `commit-granularity` rule), create only the bottom layer
   branch here; the `pull-request` skill builds the upper layers on top of
   it with `gh stack add`.
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
   - Branches that belong to a tracked `gh stack` chain are cleaned with
     `gh stack sync --prune`, not `git branch -D`; a plain delete can leave
     stale stack tracking state.
   - NEVER delete: the default branch, the current branch, or a branch whose
     merged status cannot be confirmed. Report unconfirmed branches to the
     user and leave them untouched.
5. **Scope of deletion: local branches only.** Do not delete branches on
   `origin`; `git remote prune origin` already removes stale remote-tracking
   refs. Origin-side branches are left to the hosting service
   (e.g., GitHub auto-delete).
6. **Non-GitHub repositories:** `gh` is unavailable, so squash merge detection
   is skipped — rely on `git branch --merged` only and stay conservative.

## Related rules

- **Commit and PR Granularity**: never commit directly to the default branch;
  the topic branch created in step 3 is the branch mandated there.
