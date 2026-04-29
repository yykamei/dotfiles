---
name: git-commit
description: MUST be loaded before running `git commit` or `git commit --amend`. Defines commit message language detection, subject/body formatting, multi-line commits via `-F` (never `-m`), and post-commit verification with `git log -1 --format=%B`.
---

# Git Commit Message Guidelines

Act as an experienced software engineer.
Based on the provided `git diff` or `git diff --cached`, create a commit message following the rules below.

## Basic Format

Strictly adhere to the following structure.

```
[Type]: [Subject] (Max 50 characters)

[Body] (Why this change was necessary, detailed background, solution. Keep English body lines around 72 characters. For Japanese body text, target around 35-45 full-width characters per line and do not exceed roughly 50 full-width characters; respect natural sentence and paragraph boundaries instead of forcing a fixed width.)
```

## Execution Rules

These rules govern HOW the commit message is delivered to git, not its
content. They apply regardless of language or commit type.

- **Never use `-m` for multi-line bodies**: The `-m` flag stores its
  argument as a single line and will not wrap text automatically.
  For any commit with a body, write the full message (subject + blank
  line + body) to a file and pass it via `git commit -F <path>`.
  Short fixup commits with only a subject line may use `-m`.
  Also avoid stacking multiple `-m` flags for paragraphs; each `-m`
  argument is still stored unwrapped.
- **Temporary message file location**: When writing a message file for
  `-F`, use a path under `/tmp/` such as `/tmp/COMMIT_EDITMSG.txt` (or
  `/tmp/COMMIT_EDITMSG-<short-slug>.txt` when running multiple commits
  in parallel). This keeps the file outside the repository so it cannot
  be accidentally staged, and the OS clears `/tmp/` on reboot. Do not
  place the message file inside the working tree.
- **Verify after committing**: Immediately after `git commit`, run
  `git log -1 --format=%B` and visually confirm that:
  - Subject is on its own line, followed by a blank line.
  - English body lines stay around 72 characters.
  - Japanese body lines stay within roughly 50 full-width characters
    (about 100 columns), with most lines around 35-45 full-width
    characters. Lines noticeably wider than this should be re-wrapped.
  - Japanese body text keeps natural paragraph flow and is not wrapped
    at a fixed narrow width (e.g., 36 characters).
  - Mixed-language lines stay readable in common terminal widths.
  - Paragraph breaks are preserved as blank lines.
    If English lines become excessively long or Japanese paragraphs become hard to read, amend with
    `git commit --amend -F <path>` using the corrected file (only if
    the commit has not been pushed; otherwise ask the user before
    force-pushing, consistent with the Git Safety Protocol).

## Consolidating multiple commits into one

Use this procedure when a PR branch must be reduced to a single commit
before being opened (per the `commit-granularity` rule), or whenever
several work-in-progress commits need to be folded into one.

- **Preferred path -- soft reset to base**: Run `git reset --soft <base>`
  (where `<base>` is the merge-base with the target branch, typically
  `origin/main`), which preserves the working tree and index while
  collapsing the previous commits. Then create the consolidated commit
  with a single `git commit -F <path>` using a message file.
- **Latest commit only -- amend**: When only the most recent commit
  needs to be updated (e.g., to absorb a small fixup), use
  `git commit --amend -F <path>`. Confirm the amend conditions in the
  Git Safety Protocol first.
- **Never use interactive flags**: Do not use `git rebase -i`,
  `git add -i`, or any other `-i` based workflow. The shell available
  here is non-interactive and cannot drive these UIs.
- **Pushed branches require confirmation**: If the branch has already
  been pushed, the consolidated commit can only land via a force push.
  Ask the user before running `git push --force-with-lease`, and never
  force push to `main` / `master` without explicit approval.
- **Verify afterward**: After the consolidation commit lands, run
  `git log <base>..HEAD --oneline` to confirm exactly one commit
  remains, then run the standard `git log -1 --format=%B` verification
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
  Ensure the Body is written in natural prose that is easy for humans to understand, using punctuation appropriately.
  Besides, the body should be written in present tense, so you should write "implement A" instead of "implemented A".

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
- **Japanese body wrapping**: Aim for around 35-45 full-width
  characters per line and keep each line within roughly 50 full-width
  characters as an upper bound. Because each full-width character
  occupies 2 columns, 50 full-width characters already fills about 100
  columns. Do not enforce a fixed narrow width such as 36 characters;
  preserve natural sentence and paragraph boundaries, and break lines
  at natural punctuation (。、) rather than mid-clause. If a line
  noticeably exceeds the upper bound, re-wrap it at the nearest
  natural break.

## Anti-patterns

- Vague messages like "Update file", "Fix bug", or "WIP" are prohibited.
- A body composed only of bullet points is prohibited. Explain the
  reasoning in prose so the "why" reads as natural sentences. Bullet
  points may be used to enumerate items (e.g., a list of affected
  modules or release-note-style entries) when they supplement, not
  replace, the prose explanation.

## Examples

### Good Example

```
feat: Add validation to the user registration screen

We are seeing an increase in inquiries about undelivered emails. Upon
investigation, we found that some users are entering email addresses in formats
not accepted by SMTP servers. In short, we were failing to prevent invalid
email formats at the input stage.

Therefore, we are introducing email format validation to prevent the
registration of invalid data.

Note that since some existing records already contain invalid email addresses,
this validation is applied only during new user creation. We plan to fix the
existing invalid email addresses separately.
```

### Good Japanese Example

各行を全角 35-45 文字程度で折り返し、上限の全角 50 文字を超えないように
している点に注目してください。句点・読点で自然に区切ることで、ターミナル
表示でも読みやすさが保たれます。

```
docs: 日本語コミット本文の整形ルール調整

OpenCode で利用するモデルによっては、日本語本文を極端に短い幅で折り返して
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
