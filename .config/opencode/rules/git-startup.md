# Git Worktree and Branch Hygiene at Work Start

## When this rule applies

When starting implementation work in a Git repository — code changes, commits,
or PR creation. Do NOT run this for read-only tasks such as code exploration,
answering questions, or producing plans that do not modify the repository.

## Rule

All implementation work happens in a dedicated git worktree, not in the main
checkout. The main worktree stays parked on the default branch.

Before creating any topic worktree or making changes:

1. **Identify the default branch.** Usually `main`; when uncertain, check with
   `git symbolic-ref refs/remotes/origin/HEAD` or
   `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.
2. **Remove unnecessary worktrees** before creating a new one. Run
   `git worktree prune` first, then enumerate the rest with
   `git worktree list --porcelain`:
   - A non-main worktree is removable when its branch is deletable under the
     criteria in step 5 AND the worktree has no uncommitted changes or
     untracked files. Remove it with `git worktree remove <path>`. Treat a
     detached-HEAD worktree the same way, based on whether its checked-out
     commit is reachable from the default branch; for a stack-tracked branch,
     replace its deletion with `gh stack sync --prune` (step 5).
   - NEVER use `git worktree remove --force`; if git refuses because the
     worktree is dirty, keep it and report to the user.
   - When removing a worktree whose branch is also deleted (step 5), remove
     the worktree FIRST: a branch checked out in any worktree cannot be
     deleted.
   - NEVER remove: the main worktree, a worktree with uncommitted changes or
     untracked files, or a worktree whose branch's merge status cannot be
     confirmed. Report them to the user and leave them untouched.
3. **Sync the default branch** without leaving the current directory:

   ```
   git -C <main-worktree> switch <default-branch> \
     && git -C <main-worktree> pull --ff-only \
     && git remote prune origin
   ```

   The main worktree path comes from `git worktree list`. If it has
   uncommitted changes, or untracked files that would be overwritten by the
   switch, do NOT stash or discard them automatically — ask the user how to
   handle them before switching.
4. **Create the topic worktree** from the updated default branch:
   - If a worktree for `<topic-branch>` already exists, move into it and
     reuse it instead of creating a new one.
   - Otherwise: `mkdir -p ~/.worktrees/<repo>` first, then `git worktree add
     ~/.worktrees/<repo>/<topic-branch> -b <topic-branch>`, where `<repo>` is
     the basename of the main worktree. Topic worktrees always live under the
     dedicated directory `~/.worktrees/`, which OpenCode and Claude Code are
     permitted to access without prompts. `mkdir -p` is required because
     `git worktree add` does not create parent directories. Pre-existing
     worktrees under `../<repo>.worktrees/` may remain, but new ones must go
     under `~/.worktrees/`. Do not place symlinks inside worktrees —
     permission checks match lexical paths, so a symlink could escape the
     permitted directory.
   - When the work will span multiple PRs as a stack (see the
     `commit-granularity` rule), create only the bottom layer worktree here;
     the `pull-request` skill builds the upper layers on top of it with
     `gh stack add`.
5. **Delete merged local branches** (after any worktree on them was removed
   in step 2; a branch still checked out in a kept, dirty worktree is
   undeletable — skip it and report):
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
6. **Scope of deletion: local branches only.** Do not delete branches on
   `origin`; `git remote prune origin` already removes stale remote-tracking
   refs. Origin-side branches are left to the hosting service
   (e.g., GitHub auto-delete). Worktrees are local-only by nature; the same
   local-only scope applies.
7. **Non-GitHub repositories:** `gh` is unavailable, so squash merge detection
   is skipped — rely on `git branch --merged` only and stay conservative.

## Related rules

- **Commit and PR Granularity**: never commit directly to the default branch;
  the topic worktree created in step 4 is on the branch mandated there.
