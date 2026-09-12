---
name: pull-request
description: Load before `gh pr create` or `gh pr edit --body`. Defines PR title/body conventions, self-contained and concise descriptions, safe body editing, the visibility-based draft policy (draft for private repositories, never draft for open source), and the stacked-PR workflow for work that spans multiple PRs.
---

# Pull Request Creation Workflow

Workflow for opening pull requests that respect the repository's conventions,
templates, and contribution guidelines.

## Workflow

Before creating a pull request, execute the following steps in order.

### Step 0: Verify the Base Branch and Commit Range

Before composing anything, confirm the PR scope.

1. Determine the intended base branch. For a standalone PR this is the
   repository's default branch (typically `main`), or a different base
   the user specified. For a stacked PR, the base is the branch of the
   layer directly below; only the bottom layer targets the default
   branch. See "Stacked Pull Requests" below.
2. Run `git log <base>..HEAD --oneline` to inspect the commits the PR
   will introduce.
3. If the range is empty, the branch has nothing to propose — stop and
   report this to the user.
4. If the range contains commits that clearly do not belong (merge
   commits from the base branch, unrelated work pulled in by a botched
   rebase, etc.), stop and ask the user how to proceed before opening
   the PR.
5. Per the `commit-granularity` rule, the branch must contain exactly
   one commit relative to its base branch at the time the PR is opened.
   If multiple commits exist, consolidate them first using the
   procedure in the `git-commit` skill.

### Step 0.5: Decide the PR Topology (Stack or Independent)

Decide whether this is a standalone PR or one layer of a stack before
composing anything.

1. Keep one session's work in a single PR by default; do not split a task
   just to create a stack. If the work is a single PR, continue to Step 1.
2. If the plan splits the task into multiple PRs because of the
   `commit-granularity` criteria, open the resulting PRs as a stack
   whenever the layer branches can live in the repository that receives
   the PRs. GitHub does not support cross-fork stacks, so a fork-based
   contribution (for example, sending a PR to a third-party open-source
   project) cannot be stacked; open independent PRs there and describe the
   dependencies in each body per Step 3.5.
3. Confirm whether this is a fork contribution:

   ```bash
   gh repo view --json nameWithOwner,isFork,parent \
     --jq '{repo: .nameWithOwner, isFork: .isFork,
            parent: (if .parent then (.parent.owner.login + "/" + .parent.name) else null end)}'
   ```

   `isFork: true` means this checkout is a fork. When the PRs target the
   parent repository (the usual fork-based contribution), cross-fork stacks
   are impossible, so open independent PRs there and do not follow the stack
   workflow. Only when the user explicitly says the PRs target the fork
   itself may a fork be stacked; for a non-fork checkout, follow "Stacked
   Pull Requests" below.
4. If the current branch already belongs to a stack, treat this as a new
   layer on top of it or an update to an existing layer rather than
   starting a new stack. Confirm the current state with
   `gh stack view --short`.

### Step 1: Determine Language

Language detection follows the same rules as the `git-commit` skill —
do not duplicate the algorithm here. Apply that detection and use the
result for the PR title and body.

In short: count the language of the last 10 non-merge, non-bot commit
subjects (after the Conventional Commits prefix); majority wins; ties
and near-ties fall back to the most recent three commits, then to
`README.md`, then to English. See the `git-commit` skill's
"Commit message language rules" for the authoritative procedure.

#### Japanese Style Rules

When the determined language is Japanese, follow these rules for the PR
title and body:

- Always use **polite form (です・ます調)**.
- Do NOT use plain form (だ・である調).
- Good: 「〜を修正しました。」「〜に対応します。」「〜が必要です。」
- Bad: 「〜を修正した。」「〜に対応する。」「〜が必要だ。」

### Step 2: PR Title Convention

- For single-commit PRs, use the commit subject as the PR title.
- For multi-commit PRs, write a title that summarizes the overall change.
- The title is the primary statement of what changed: make the change
  understandable from the title alone, and do not restate it in the body.

### Step 3: Check for PR Templates

1. Check whether a PR template exists at any of the following paths:
   - `.github/PULL_REQUEST_TEMPLATE.md`
   - `.github/PULL_REQUEST_TEMPLATE/` (directory containing multiple templates)
   - `docs/PULL_REQUEST_TEMPLATE.md`
   - `PULL_REQUEST_TEMPLATE.md` (repository root)
2. If a template exists, follow its structure, sections, and checklists when
   composing the PR body.
3. When a template exists, apply these rules:
   - A Changes-like section: keep it as terse as possible and add no
     extraneous content — the title and the diff already convey what changed.
   - A Testing-like section: fill it in only when manual testing is needed.
     Never list automated test cases; the diff already shows them.
   - Any other missing context: put it in the most natural existing section,
     or append additional sections at the end. Do not remove or rewrite
     template checklists, guidance, or repository-specific fields.
4. If no template exists, compose the PR body with the following default
   structure. Keep the section headers in English regardless of the determined
   language. Omit any section marked "omit if not applicable" entirely rather
   than writing a placeholder.

   ```
   ## Purpose
   [1-2 sentences: the outcome or goal this PR achieves]

   ## Background
   [1-3 sentences: the prior situation, problem, or product/technical reason]

   ## Out of Scope
   [1-2 sentences or bullets: deliberate non-goals, or "None"]

   ## Rollout Role
   [1-2 sentences: this PR's role in the release; omit if not applicable]

   ## Testing
   [Manual testing that automated tests cannot cover; omit if not applicable]

   ## Post-Release Verification
   [1-2 sentences: what to check after release; omit if not applicable]

   ## Operational Notes
   [1-2 sentences: cautions, monitoring, rollback; omit if not applicable]
   ```

### Step 3.5: Make the PR Description Self-Contained

The PR body must stand on its own for a developer who has not read any
planning document, previous session transcript, or local notes. A reviewer
should be able to understand the intent, background, scope, and relevant
sequence by reading this PR alone.

The same self-containment rules as the `git-commit` skill's "Make the Commit
Message Self-Contained" section apply: do not explain the PR only with
plan-local or order-only references such as `PR2`, `previous PR`,
`part 2 of 3`, or `phase 2`.

If you need to mention another PR, put it in the most natural section (e.g.,
Background or Operational Notes) and include all of the following:

- The PR URL, preferably in `https://github.com/owner/repo/pull/N` form.
- A 1-2 sentence explanation of what that PR completed, or is expected to
  complete.
- A clear statement of how this PR depends on, follows from, or supports that
  related PR.

Example:

```markdown
## Background

- https://github.com/example/app/pull/123 added the `users.deleted_at` column and shipped the migration. This PR uses that column to hide deleted users from the admin API response.
```

When the work is part of a phased rollout, the body must describe this PR's
role in domain terms, not only by sequence number. For example, write
"This PR wires the already-created database column into the read API" rather
than "This is PR2 after PR1".

The same self-containment applies to environment details: do not include
the versions of tools, binaries, or dependencies installed on your
machine, local filesystem paths, host names, or personal setup in the PR
body. Version and environment facts are welcome only when reviewers on
another machine would act on them, such as a supported runtime range or a
dependency upgrade target. See the `git-commit` skill's "Avoid
Environment-Specific Details" section for the authoritative boundary and
examples.

### Step 3.6: Keep the Body Concise

Concise means tighter wording, not less context. Keep every section that
carries background; compress the sentences instead.

- Each section: 1-3 sentences (or up to ~5 bullets when genuinely
  enumerating items). One idea per sentence; cut filler and vague
  qualifiers; prefer concrete names and numbers.
- The title is the primary statement of what changed; do not restate it
  in the body.
- Give each section a distinct job and never repeat content across
  sections: Purpose = the outcome or goal; Background = why it is needed
  (problem/cause); Out of Scope = deliberate non-goals. If two sections
  would say the same thing, write it in the more natural one and leave
  the other at "None" where the structure allows.
- Total body: aim within about 30 lines so a reviewer can read it in
  one pass.
- Do not hard-wrap lines in the PR body: write each paragraph and bullet
  on a single line and let the Markdown renderer soft-wrap. Fixed-column
  wrapping is a commit-message convention, not a PR-description one.
- When conciseness would force you to drop background, keep the
  background and exceed the target instead — cut wording, never context.

### Step 4: Check CONTRIBUTING Guide and Code of Conduct

1. Check whether the following files exist:
   - `CONTRIBUTING.md` (or `CONTRIBUTING`)
   - `CODE_OF_CONDUCT.md`
2. If they exist, read their contents and ensure the PR complies with the
   guidelines (e.g., commit message conventions, branch naming rules, testing
   requirements, sign-off requirements).
3. If the CONTRIBUTING guide conflicts with other rules (e.g., the git-commit
   skill), the CONTRIBUTING guide takes precedence.

### Step 5: Draft Policy (Visibility-Based)

Do not ask the user whether to open the PR as a draft. Determine the
draft status from the repository's visibility instead.

1. Run `gh repo view --json visibility -q .visibility`.
2. If the result is `PUBLIC` (open source):
   - NEVER use `gh pr create --draft`. Some open-source repositories
     forbid draft pull requests, and creating one can fail or be rejected.
   - Open the PR with a plain `gh pr create` only after the self-review
     rule has completed with no blocking findings and you have full
     confidence in the change. If any uncertainty remains, stop before
     `gh pr create` and report the concerns to the user — do not open a
     draft as a workaround.
3. If the result is `PRIVATE` or `INTERNAL`:
   - Always open the PR as a draft with `gh pr create --draft`.
   - Do not mark it ready for review unless the user explicitly asks.

### Step 6: Submit the PR Body Reliably

Multi-line PR bodies should not be passed as a single `--body` string.
Use one of the following two patterns so newlines, blank lines, and
Markdown structure are preserved exactly.

#### Preferred — `--body-file`

Write the body to a file and pass the path to `gh`:

```bash
# Write the body
cat > /tmp/PR_BODY.md <<'EOF'
## Purpose
…

## Background
…
EOF

gh pr create --title "…" --body-file /tmp/PR_BODY.md
```

Use a path under `/tmp/` (e.g., `/tmp/PR_BODY.md` or
`/tmp/PR_BODY-<slug>.md` when running multiple PRs in parallel) so the
file stays outside the working tree and cannot be accidentally
committed.

#### Acceptable — Inline HEREDOC

When writing a temporary file is undesirable, an inline HEREDOC works
too:

```bash
gh pr create --title "…" --body "$(cat <<'EOF'
## Purpose
…
EOF
)"
```

Always quote the HEREDOC delimiter (`'EOF'`) to prevent shell
expansion of backticks and `$` inside the body.

### Step 7: Labels, Reviewers, and Assignees

Do **not** add labels, reviewers, or assignees automatically when
opening the PR.

- Add `--label`, `--reviewer`, or `--assignee` only when the user has
  explicitly requested specific values, or when the repository's
  `CONTRIBUTING.md` mandates them (e.g., a required label such as
  `needs-review`).
- If the user has not specified anything and the project does not
  mandate any, open the PR without these flags. Adding them
  speculatively can ping the wrong people or trigger unintended
  workflows.
- After the PR is open, mention to the user that labels and reviewers
  were left unset, so they can attach what they want.

### Step 8: Editing an Existing PR Body

These rules apply to any existing PR body edit, including `gh pr edit --body`
and `gh pr edit --body-file`.

Before editing, always retrieve the latest remote body:

```bash
gh pr view <PR> --json body -q .body > /tmp/PR_BODY-current.md
```

Then:

1. Use the latest remote body as the base for your edit.
2. If you have a previous local draft or intended body, compare it with the
   latest remote body before editing so you can detect intervening changes.
3. Preserve additions from users, reviewers, automation, or other agents,
   including checklist state, review notes, follow-up questions, operational
   cautions, and verification results.
4. Update only the sections that need to change. Keep unrelated sections in
   their latest remote form.
5. Do not replace the whole body with an empty body, stale local draft, or
   older body version.
6. Submit the edited body through `--body-file`, following Step 6. For example:

   ```bash
   gh pr edit <PR> --body-file /tmp/PR_BODY-current.md
   ```

Do not skip the latest-body retrieval even if you created the PR moments ago.
The cost of checking is lower than the cost of overwriting someone else's
checklist item, note, or verification result.

## Stacked Pull Requests

A stack is an ordered chain of pull requests in the same repository where
each PR targets the branch of the PR below it, and the bottom PR targets the
repository's default branch. It is the shape for a split the plan already
required, not a reason to split a single-PR task. Reviewers see only the
layer's own diff, and the stack merges from the bottom up. GitHub supports
stacks natively; this workflow drives them with the `gh stack` CLI
extension.

Reference:
https://docs.github.com/en/pull-requests/get-started/about-stacked-prs

### Requirements

- Every layer branch must live in the repository that receives the PRs.
  Cross-fork stacks are not supported, so a fork-based contribution cannot
  be stacked (Step 0.5).
- Install the extension if it is missing:
  `gh extension install github/gh-stack`.
- Stacks are a public preview feature. If the commands fail because the
  repository or host does not support stacks, report this to the user and
  fall back to independent PRs; do not hand-roll stack metadata.

### Layer Rules

- One layer = one logical change = exactly one commit relative to its base
  branch (see the `commit-granularity` rule).
- Order layers bottom to top by dependency. Put foundational changes,
  including migrations and schema changes, in the bottom layer.
- Keep each layer buildable and tested on top of its base. Upper layers may
  depend on lower ones, so deploy from the bottom up; a layer is not expected
  to work in isolation.
- Never bundle unrelated changes into one layer to reduce the number of PRs;
  split them into a lower or higher layer instead.
- Run the self-review rule on each layer's diff before opening that layer's
  PR.

### Build the Stack

Create and commit layers bottom to top. Each commit follows the `git-commit`
skill.

```bash
# Bottom layer: base is the default branch
# (pass -b <trunk> when the stack targets a different trunk)
gh stack init <branch-1>
# Edit, stage, and commit on <branch-1>.

# Each further layer is created on top of the current branch
gh stack add <branch-2>
# Edit, stage, and commit on <branch-2>.

gh stack view --short
```

If the branches already exist, adopt them and rebuild the chain:

```bash
gh stack init <branch-1> <branch-2> <branch-3>
gh stack rebase
```

### Open the PRs

Push all layer branches, then create each PR from bottom to top with Steps
1-7 applied per layer (language, title from the layer's commit, template,
body, draft policy). The base is the layer below; only the bottom layer
targets the default branch.

```bash
gh stack push

gh pr create --base <default-branch> --head <branch-1> \
  --body-file /tmp/PR_BODY-1.md
gh pr create --base <branch-1> --head <branch-2> \
  --body-file /tmp/PR_BODY-2.md
```

Apply the Step 5 draft policy per layer (private/internal: `--draft`; public:
no draft). Keep each body self-contained (Step 3.5): refer to another layer by
its PR URL plus a short dependency explanation, never by layer position alone.
Because layers are created bottom to top, a body can reference only the layers
already below or equal to it; add any upward references after the stack exists
via Step 8.

### Link the Stack

After the PRs exist, link them bottom to top:

```bash
gh stack link <branch-1> <branch-2> <branch-3>
```

To append a layer to an existing stack, pass the stack number first:

```bash
gh stack link <stack-number> <branch-4>
```

Do not reach for `gh stack submit` here. Its editor cannot be driven from a
non-interactive shell, so `submit` (with or without `--auto`) falls back to
auto-generated titles and draft PRs; on a public repository that violates the
Draft Policy. Use the manual `gh pr create` + `gh stack link` path above. A
human in an interactive terminal may instead run plain `gh stack submit` and
fill in each layer's title, description, and draft state there. If `submit` is
ever run non-interactively, correct every PR afterward: titles with
`gh pr edit --title`, bodies per Step 8, and draft state with `gh pr ready`
(or the equivalent draft toggle) to match the Draft Policy.

### Keep the Stack in Sync

- After a lower PR merges, GitHub rebases the remaining layers server-side.
  Run `gh stack sync` locally to match, adding `--prune` to drop local
  branches for merged PRs.
- If a rebase stops on a conflict, `gh stack rebase --continue` (or
  `--abort`) recovers. Never use interactive rebase tools.
- After review changes to a layer, follow the `pr-review-response` skill,
  which cascades the rebase to the layers above.
- Merging is the user's call and always proceeds bottom up; `gh stack merge`
  merges the whole stack or everything up to a chosen PR. It requires every
  layer to be open and not a draft, so a private/internal stack cannot merge
  until the user asks you to mark the layers ready.
