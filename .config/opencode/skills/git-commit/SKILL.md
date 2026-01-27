---
name: git-commit
description: Git commit message guidelines for creating human-friendly commit messages.
---

# Git Commit Message Guidelines

Act as an experienced software engineer.
Based on the provided `git diff` or `git diff --cached`, create a commit message following the rules below.

## Basic Format

Strictly adhere to the following structure.

```
[Type]: [Subject] (Max 50 characters)

[Body] (Why this change was necessary, detailed background, solution. Max 72 characters per line)
```

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
  Use the imperative mood.
  Describe the action in the form of "do ~" or "fix ~" instead of the past tense.
- **Body**:
  Focus on "Why" rather than "What".
  Do not write what is obvious from the code; describe the intent and the scope of influence.
  Ensure the Body is written in natural prose that is easy for humans to understand, using punctuation appropriately.
  Besides, the body should be written in present tense, so you should write "implement A" instead of "implemented A".


## Commit message language rules

- **Primary Rule**: Write commit messages in **English** by default.
- **Exception (Auto-detection)**: You must switch to **Japanese** if either of the following conditions is met:
  - The project's `README.md` is primarily written in Japanese.
  - The recent git log (`git log`) shows that previous commits are written in Japanese.
- **Formatting**: Regardless of the language, always follow the **Conventional Commits** format (feat, fix, etc.).
  - English: `feat: add login function`
  - Japanese: `feat: ログイン機能を追加`
- **Japanese style**: When you write Japanese commit messages, use です・ます調. Write "Aを実装します" instead of "Aを実装する".
- **Japanese line characters**: Japanese characters usually require double-width. If all characters are Japanese, 36 characters is the max per line.

## Anti-patterns

- Vague messages like "Update file", "Fix bug", or "WIP" are prohibited.
- Avoid bullet points. Use conjunctions to connect sentences naturally.

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

### Bad Example

```
fix: WIP bugfix

(The content of the fix is unclear, and the reason for the fix is not written)
```

