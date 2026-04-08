---
name: pull-request
description: Pull request creation workflow that respects repository conventions.
---

# Pull Request Creation Workflow

Workflow for opening pull requests that respect the repository's conventions,
templates, and contribution guidelines.

## Workflow

Before creating a pull request, execute the following steps in order.

### Step 1: Determine Language

1. Run `git log --oneline -10` to inspect the last 10 commit messages.
2. Classify each message's language based on the subject text after the
   Conventional Commits prefix (e.g., `feat: ログイン機能を追加` is Japanese).
   Ignore merge commits and bot-generated messages when counting.
3. If English messages are the majority, use **English**.
4. If Japanese messages are the majority, use **Japanese**.
5. If tied, default to **English**.
6. If the repository has fewer than 10 commits, evaluate all available commits.
   If there are no commits yet, check whether `README.md` is primarily written
   in Japanese; if so, use **Japanese**. Otherwise, default to **English**.
7. Apply the determined language to the PR title and body. Commit messages
   should follow the **git-commit** skill (loaded separately), which uses the
   same detection method.

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
