# Git Hygiene at Plan and Work Start

## When this rule applies

When starting planning or implementation work in a Git repository:

- **Planning** includes read-only exploration that will produce a plan.
- **Implementation** includes code changes, commits, and PR creation.

Do NOT run this for standalone questions that neither produce a plan nor
change the repository. This rule does not cover reviewing or responding to an
existing branch or PR; use that branch's checkout as the workflow requires.

## Rule

Do not switch or pull an existing checkout except as provided in step 4.
Another AI session may be using it. Refresh the remote default branch instead,
and base all new work on `<target-remote>/<default-branch>`. The local
`<default-branch>` may stay behind; that is intentional.

Let `<target-remote>` be the remote of the repository that receives the
change (usually `origin`). Let `<target-repo>` be its `owner/name` (the
current repository when `<target-remote>` is `origin`). If the repository has
no remote, use the local `<default-branch>` wherever
`<target-remote>/<default-branch>` appears and skip remote and `gh`
operations. Planning runs steps 1–4. Implementation runs all steps; steps 5–8
prepare and clean up the branch.

Before creating any worktree or making changes:

1. **Identify the default branch.** Usually `main`; when uncertain, run:

   ```sh
   git symbolic-ref refs/remotes/<target-remote>/HEAD
   gh repo view <target-repo> --json defaultBranchRef -q .defaultBranchRef.name
   ```

   If the repository has no remote, use its configured default branch (for
   example, `git config --get init.defaultBranch`, or `main`/`master` when
   that is the convention); ask the user when uncertain.
2. **Refresh the remote default branch.** Run
   `git fetch <target-remote> <default-branch>` followed by
   `git remote prune <target-remote>`. This updates
   `<target-remote>/<default-branch>` and never changes a checkout. Do not run
   `git switch` or `git pull` as part of this refresh. If the repository has
   no remote, skip the fetch and prune and use the local default branch.
3. **Remove stale worktrees** before creating a new one. Run
   `git worktree prune` first, then enumerate the rest with
   `git worktree list --porcelain`:
   - Before removing or reusing any non-main worktree, check whether another
     session may be using it. If active use cannot be ruled out, do not remove
     or reuse it; report it and ask the user.
   - A non-main worktree is removable when its branch is deletable under the
     criteria in step 6 AND the worktree has no uncommitted changes or
     untracked files. Remove it with `git worktree remove <path>`. For a
     stack-tracked branch, replace its deletion with `gh stack sync --prune`
     (step 6).
   - A temporary investigation worktree (`investigate-*`, created in step 4)
     is removable when it has no uncommitted changes or untracked files and
     either the plan it supported is approved and the topic worktree exists,
     or the investigation is abandoned. If you cannot tell whether it is still
     in use, leave it and report it instead of guessing.
   - A detached-HEAD worktree other than `investigate-*` is removable when its
     commit is reachable from `<target-remote>/<default-branch>` and it has no
     uncommitted changes or untracked files.
   - NEVER use `git worktree remove --force`; if git refuses because the
     worktree is dirty, keep it and report to the user.
   - When removing a worktree whose branch is also deleted (step 6), remove
     the worktree FIRST: a branch checked out in any worktree cannot be
     deleted.
   - NEVER remove: the main worktree, the worktree containing the session's
     current working directory, a worktree with uncommitted changes or
     untracked files, or a worktree whose branch's merge status cannot be
     confirmed. Report them to the user and leave them untouched.
4. **Create the workspace for this task** from
   `<target-remote>/<default-branch>`:
   - **Implementation:** if the current checkout is already the topic worktree
     for this task, use it. Otherwise create or reuse the topic worktree at
     `~/.worktrees/<repo>/<topic-branch>`, where `<repo>` is the basename of
     the main worktree. For a new branch:

     ```sh
     mkdir -p ~/.worktrees/<repo>
     git worktree add ~/.worktrees/<repo>/<topic-branch> \
       -b <topic-branch> <target-remote>/<default-branch>
     ```

     If the topic branch is already checked out in another worktree (check
     `git worktree list --porcelain`), reuse that worktree or ask the user. If
     the worktree may be used by another session, ask before reusing it. If
     the local branch exists without a worktree, create the worktree for it
     and, when the branch is behind `<target-remote>/<default-branch>`, ask
     the user whether to rebase it before continuing. When the work will span
     multiple PRs as a stack (see the `commit-granularity` rule), create only
     the bottom layer worktree here; the `pull-request` skill builds the upper
     layers on top of it with `gh stack add`.
   - **Planning or read-only investigation:** create or reuse a temporary
     detached worktree at `~/.worktrees/<repo>/investigate-<slug>`, where
     `<slug>` is a short kebab-case task name:

     ```sh
     mkdir -p ~/.worktrees/<repo>
     git worktree add --detach \
       ~/.worktrees/<repo>/investigate-<slug> \
       <target-remote>/<default-branch>
     ```

     If it already exists and is clean, update it to the refreshed ref with
     `git -C <path> reset --hard <target-remote>/<default-branch>` before
     reading. If it is dirty, do not reset; ask the user. Use that directory
     as the working directory for exploration commands and file reads, so
     another session's branch or uncommitted changes cannot leak into the
     investigation. Do not modify tracked files there. Before removing it,
     move the session outside it. Remove it when it has no uncommitted changes
     or untracked files and either the plan is approved and the topic worktree
     exists, or the investigation is abandoned.
   - **If the user explicitly asks to work in the current checkout instead of
     a worktree:** treat it as an override of the worktree requirement. Do not
     switch or pull it during preparation. Investigate in a temporary detached
     worktree as above. When you are ready to implement, ask the user to
     confirm that the checkout is clean and not in use by another session, and
     check `git worktree list --porcelain` for the topic branch. If it is
     already checked out in another worktree, reuse that worktree or ask the
     user. For a new branch, create it from
     `<target-remote>/<default-branch>` with
     `git switch -c <topic-branch> <target-remote>/<default-branch>`. For an
     existing branch, check it out with `git switch <topic-branch>` and ask
     the user whether to rebase it when it is behind
     `<target-remote>/<default-branch>`. This is the only permitted switch in
     this rule.
   - Topic and investigation worktrees always live under `~/.worktrees/`,
     which OpenCode and Claude Code are permitted to access without prompts.
     `mkdir -p` is required because `git worktree add` does not create parent
     directories. Pre-existing worktrees under `../<repo>.worktrees/` may
     remain, but new ones must go under `~/.worktrees/`. Do not place symlinks
     inside worktrees — permission checks match lexical paths, so a symlink
     could escape the permitted directory.
5. **Use the remote-tracking default ref as the base for a standalone PR.**
   Use `<target-remote>/<default-branch>` as `<base>` for
   `git log <base>..HEAD`, `git diff <base>...HEAD`, and
   `git merge-base <base> HEAD`. Do not use a local `<default-branch>` that
   may be stale. For a stacked PR, use the layer below as the base. Refresh a
   non-default base before comparing it. The `pull-request` and `git-commit`
   skills define the exact commands.
6. **Delete merged local branches** (after any worktree on them was removed
   in step 3; a branch still checked out in a kept, dirty worktree is
   undeletable — skip it and report):
   - `git branch --merged <target-remote>/<default-branch>` finds branches
     merged by regular or fast-forward merges; delete them with
     `git branch -d`. If `git branch -d` refuses with `not fully merged`
     because HEAD is a topic branch, but the `--merged` check listed the
     branch, retry with `git branch -D`.
   - Squash and rebase merges leave the tip commit unreachable from the
     default branch, so the above cannot detect them. For remaining branches,
     confirm their merge status with
     `gh pr list --repo <target-repo> --state merged --json headRefName --limit 200`
     (covers the most recent 200 merged PRs; older branches are left alone)
     and delete branches whose name matches a merged PR's head branch. If the
     name matches more than one PR, or the branch contains commits not covered
     by any merged PR, keep it and report to the user. These branches diverge
     from `<target-remote>/<default-branch>`, so use `git branch -D` — safe
     because the merge status was confirmed via `gh`.
   - Branches that belong to a tracked `gh stack` chain are cleaned with
     `gh stack sync --prune`, not `git branch -D`; a plain delete can leave
     stale stack tracking state.
   - NEVER delete: the default branch, the current branch, or a branch whose
     merged status cannot be confirmed. Report unconfirmed branches to the
     user and leave them untouched.
7. **Scope of deletion: local branches only.** Do not delete branches on
   `<target-remote>`; `git remote prune <target-remote>` already removes stale
   remote-tracking refs. If there is no remote, skip the prune. Remote-side
   branches are left to the hosting service (e.g., GitHub auto-delete).
   Worktrees are local-only by nature; the same local-only scope applies.
8. **Non-GitHub repositories:** `gh` is unavailable, so squash merge detection
   is skipped — rely on
   `git branch --merged <target-remote>/<default-branch>` only and stay
   conservative.

## Related rules

- **Commit and PR Granularity**: never commit directly to the default branch;
  the topic worktree created in step 4 is on the branch mandated there.
