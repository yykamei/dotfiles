---
name: pull-request
description: MUST be loaded before opening a pull request with `gh pr create`. Defines language detection (delegated to git-commit), base-branch verification, PR title/body conventions, template/CONTRIBUTING checks, body submission via `--body-file`, label/reviewer policy, and the mandatory draft confirmation.
---

# Pull Request Creation Workflow

Workflow for opening pull requests that respect the repository's conventions,
templates, and contribution guidelines.

## Workflow

Before creating a pull request, execute the following steps in order.

### Step 0: Verify the Base Branch and Commit Range

Before composing anything, confirm the PR scope.

1. Determine the intended base branch (default: the repository's
   default branch, typically `main`). If the user has indicated a
   different base, use it.
2. Run `git log <base>..HEAD --oneline` to inspect the commits the PR
   will introduce.
3. If the range is empty, the branch has nothing to propose — stop and
   report this to the user.
4. If the range contains commits that clearly do not belong (merge
   commits from the base branch, unrelated work pulled in by a botched
   rebase, etc.), stop and ask the user how to proceed before opening
   the PR.
5. Per the `commit-granularity` rule, the branch must contain exactly
   one commit at the time the PR is opened. If multiple commits exist,
   consolidate them first using the procedure in the `git-commit`
   skill.

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

### Step 3: Check for PR Templates

1. Check whether a PR template exists at any of the following paths:
   - `.github/PULL_REQUEST_TEMPLATE.md`
   - `.github/PULL_REQUEST_TEMPLATE/` (directory containing multiple templates)
   - `docs/PULL_REQUEST_TEMPLATE.md`
   - `PULL_REQUEST_TEMPLATE.md` (repository root)
2. If a template exists, follow its structure, sections, and checklists when
   composing the PR body.
3. If no template exists, compose the PR body with the following default
   structure. Keep the section headers in English regardless of the determined
   language:

   ```
   ## Summary
   [1-3 sentence summary of what changed and why]

   ## Background
   [Why this change is needed -- the problem or context]

   ## Changes
   [What was changed and how]

   ## Testing
   [How to verify the change, or "N/A" if not applicable]

   ## Related Issues
   [Links to related issues/tickets, or "None"]
   ```

### Step 4: Check CONTRIBUTING Guide and Code of Conduct

1. Check whether the following files exist:
   - `CONTRIBUTING.md` (or `CONTRIBUTING`)
   - `CODE_OF_CONDUCT.md`
2. If they exist, read their contents and ensure the PR complies with the
   guidelines (e.g., commit message conventions, branch naming rules, testing
   requirements, sign-off requirements).
3. If the CONTRIBUTING guide conflicts with other rules (e.g., the git-commit
   skill), the CONTRIBUTING guide takes precedence.

### Step 5: Confirm Draft Status

Before opening the PR, you MUST use the `question` tool to ask the user whether
to open the PR as a draft.

- If draft is selected: use `gh pr create --draft`.
- If not draft: use `gh pr create` as usual.

### Step 6: Submit the PR Body Reliably

Multi-line PR bodies should not be passed as a single `--body` string.
Use one of the following two patterns so newlines, blank lines, and
Markdown structure are preserved exactly.

#### Preferred — `--body-file`

Write the body to a file and pass the path to `gh`:

```bash
# Write the body
cat > /tmp/PR_BODY.md <<'EOF'
## Summary
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
## Summary
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
