---
name: git-commit
description: Load before running `git commit` or `git commit --amend`. Defines commit message language detection, self-contained commit messages, subject/body formatting, multi-line commits via `-F` (never `-m`), and post-commit verification with `git log -1 --format=%B`.
---

# Git Commit Message Guidelines

Based on the provided `git diff` or `git diff --cached`, create a commit
message following the rules below.

## Basic Format

Strictly adhere to the following structure.

```
[Type]: [Subject] (Max 50 characters)

[Body] (Why this change was necessary, detailed background, solution.
For line-wrapping rules, see "Commit message language rules" below.)
```

## Execution Rules

These rules govern HOW the commit message is delivered to git, not its
content. They apply regardless of language or commit type.

- **Never use `-m` for multi-line bodies**: `-m` stores its argument
  unwrapped, and stacking multiple `-m` flags does not help. For any commit
  with a body, write the full message to a file and pass it via
  `git commit -F <path>`. Short fixup commits with only a subject line may
  use `-m`.
- **Temporary message file location**: Write the `-F` message file under
  `/tmp/` (e.g., `/tmp/COMMIT_EDITMSG.txt`, with a short slug suffix when
  running multiple commits in parallel). This keeps the file outside the
  working tree so it cannot be accidentally staged. Do not place the message
  file inside the repository.
- **Show the exact message before committing**: Before running `git commit`
  or `git commit --amend`, output the exact commit message as a fenced code
  block in an assistant message, so the user can inspect the final subject,
  wrapping, and body prose before the commit is created.
- **Verify after committing**: Immediately after `git commit`, run
  `git log -1 --format=%B` and confirm the subject is on its own line
  followed by a blank line, paragraph breaks are preserved, and the body
  follows the wrapping rules in "Commit message language rules". If not,
  amend with `git commit --amend -F <path>` using a corrected file (only if
  the commit has not been pushed; otherwise ask the user before
  force-pushing).
- **Delete the message file after committing**: After verification passes,
  delete the temporary message file with `rm <path>` so stale content is not
  reused in a future session.

## Consolidating multiple commits into one

Use this procedure when a PR branch must be reduced to a single commit
before being opened (per the `commit-granularity` rule), or whenever
several work-in-progress commits need to be folded into one.

- **Preferred path -- soft reset to base**: Run `git reset --soft <base>`
  (where `<base>` is the merge-base with the target branch, typically
  `origin/main`), then create the consolidated commit with a single
  `git commit -F <path>`.
- **Latest commit only -- amend**: When only the most recent commit needs to
  absorb a small fixup, use `git commit --amend -F <path>`.
- **Never use interactive flags**: Do not use `git rebase -i`, `git add -i`,
  or any other `-i` based workflow; the shell here is non-interactive.
- **Pushed branches require confirmation**: A consolidated commit on an
  already-pushed branch can only land via a force push. Ask the user before
  running `git push --force-with-lease`, and never force push to `main` /
  `master` without explicit approval.
- **Verify afterward**: Run `git log <base>..HEAD --oneline` to confirm
  exactly one commit remains, then run the standard post-commit verification
  from the Execution Rules above.

## Type Definitions (Conventional Commits compliant)

Select the appropriate prefix based on the changes.

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only changes
- `style`: Formatting changes that do not affect code execution (white-space, semi-colons, etc.)
- `refactor`: Code restructuring without adding features or fixing bugs
- `perf`: Performance improvements
- `test`: Adding or correcting tests
- `chore`: Changes to the build process or tools

## Style Guide

- **Language**: English or Japanese (See "Commit message language rules" for more details)
- **Subject**:
  Do not add punctuation (such as ".") at the end.
  Use the imperative mood (English) or 体言止め (Japanese).
  Describe the action in the form of "do ~" or "fix ~" instead of the past tense.
- **Body**:
  Focus on "Why" rather than "What".
  Do not write what is obvious from the code; describe the intent and the scope of influence.
  Write in natural, present-tense prose ("implement A", not "implemented A"),
  using punctuation appropriately.
  Do not report verification. Do not describe how the change was verified
  (e.g., "ran the tests", "confirmed behavior with ..."). Passing tests is a
  precondition for committing, so such statements add no information and even
  imply the commit may not pass. Include verification details only when the
  user explicitly asks for them.

## Make the Commit Message Self-Contained

The commit message must stand on its own for a developer who has not read any
planning document, previous session transcript, or local notes. A future reader
should be able to understand the intent, background, scope, and relevant
relationship to other work by reading `git log` alone.

Do not explain the commit only with plan-local or session-local references such
as:

- `PR1`, `commit 2`, `step 2`, or similar numbering from a plan.
- `previous commit`, `next commit`, `first commit`, or similar order-only
  references.
- `part 2 of 3`, `stack 2/3`, or similar sequence-only descriptions.
- `phase 2`, `the earlier step`, or section numbers that only exist in a
  planning document.
- `as discussed`, `as agreed`, or similar references that require reading a
  previous conversation.

If you need to mention another existing commit, include all of the following:

- The short SHA, preferably with the commit subject.
- A 1-2 sentence explanation of what that commit completed, or is expected to
  complete.
- A clear statement of how this commit depends on, follows from, or supports
  that related commit.

Example:

```
fix: hide deleted users from admin responses

Commit `a1b2c3d` (`feat: add deleted_at to users`) added the column and shipped
the migration needed to represent soft-deleted users. This commit uses that
column in the admin read path so deleted users no longer appear in API
responses.
```

When the work is part of a phased rollout, describe this commit's role in domain
terms, not only by sequence number. For example, write "This commit wires the
already-created database column into the read API" rather than "This is phase 2
after the first commit".

## Commit message language rules

- **Detection**: Run `git log --oneline -10` and count the language of each
  commit message. Classify language based on the subject text after the
  Conventional Commits prefix (e.g., `feat: ログイン機能を追加` is Japanese).
  Ignore merge commits and bot-generated messages when counting.
  - If English messages are the majority, use **English**.
  - If Japanese messages are the majority, use **Japanese**.
  - If tied, default to **English**.
  - If the repository has fewer than 10 commits, evaluate all available commits.
    If there are no commits yet, check whether `README.md` is primarily written
    in Japanese; if so, use **Japanese**. Otherwise, default to **English**.
- **Mixed-history tie-breakers**: When the count is close (within one
  message of a tie, e.g., 4 vs 6 in the last 10) the raw majority is
  fragile and can flip on adjacent commits. In this case, fall back to
  these signals in order and pick the first decisive one:
  1. The language of the **most recent 3 non-merge, non-bot commits**.
     If they unanimously use one language, follow them.
  2. The primary language of `README.md` when one is detectable.
  3. The default — **English**.
  This avoids the message language flipping back and forth on a
  repository whose history is genuinely bilingual.
- **Formatting**: Regardless of the language, always follow the **Conventional Commits** format (feat, fix, etc.).
  - English: `feat: add login function`
  - Japanese: `feat: ログイン機能を追加`
- **Japanese style**:
  - **Subject**: Use 体言止め (noun phrase ending). Write "ログイン機能を追加" instead of "ログイン機能を追加します".
  - **Body**: Use です・ます調. Write "Aを実装します" instead of "Aを実装する".
- **Body wrapping (authoritative)**:
  - English body lines: keep around 72 characters.
  - Japanese body lines: aim for around 35-45 full-width characters per line
    and keep each line within roughly 50 full-width characters as an upper
    bound (about 100 columns). Do not enforce a fixed narrow width such as
    36 characters; preserve natural sentence and paragraph boundaries, and
    break lines at natural punctuation (。、) rather than mid-clause.
  - Keep mixed-language lines readable in common terminal widths, and
    preserve paragraph breaks as blank lines.

## Anti-patterns

- Vague messages like "Update file", "Fix bug", or "WIP" are prohibited.
- A body composed only of bullet points is prohibited. Explain the
  reasoning in prose so the "why" reads as natural sentences. Bullet
  points may be used to enumerate items (e.g., a list of affected
  modules or release-note-style entries) when they supplement, not
  replace, the prose explanation.
- Verification reports are prohibited: do not report how the change was
  verified (e.g., "ran the tests", "verified by running X", "this guarantees
  the behavior"); they add no value for future readers and imply the commit
  may not pass its tests. Include them only when the user explicitly asks.
  This does not prohibit describing the change itself, such as the tests added
  in a `test:` commit — only reporting the verification act/result is banned.

## Examples

### Good Japanese Example

各行を全角 35-45 文字程度で折り返し、上限の全角 50 文字を超えないように
している点に注目してください。句点・読点で自然に区切ることで、ターミナル
表示でも読みやすさが保たれます。

```
docs: 日本語コミット本文の整形ルール調整

利用するモデルによっては、日本語本文を極端に短い幅で折り返して
しまうことがあります。そのため、日本語本文は 36 文字固定で整形するのを
やめ、段落を自然な形で保つ方針に変更します。

件名の制約と英語本文の 72 桁目安は維持しつつ、日本語本文だけ可読性を
優先します。各行は全角 35-45 文字を目安にし、上限の全角 50 文字を
超えないようにします。

行が長くなりすぎる場合にだけ自然な句点位置で折り返し、説明の途中で
不自然に改行される状態を避けます。
```

### Bad Example

```
fix: WIP bugfix

(The content of the fix is unclear, and the reason for the fix is not written)
```
