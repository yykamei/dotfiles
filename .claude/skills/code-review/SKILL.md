---
name: code-review
description: MUST be loaded before reviewing a pull request or self-reviewing a local diff. Defines context gathering via `gh`/`git`, language-agnostic evaluation criteria, Critical/Warning/Suggestion classification, and the standard Markdown output format.
---

# Code Review Workflow

Guidelines for conducting effective code reviews on pull requests, local diffs,
and any code changes.

> **How this skill is used**: Load this skill directly in the main session
> whenever you perform a review -- the post-implementation self-review required
> by the Self-Review rule (in CLAUDE.md), reviewing a teammate's PR, or any
> manual review of a local diff.

## Gathering Context

Determine whether you are reviewing a **pull request** or a **local diff**
(e.g., self-review before committing), then gather the following before
reviewing. The review process, issue classification, and output format are
shared between the two.

- **For PRs** (via `gh`): the PR description, title, and labels; the full
  diff; the commit list; CI check status; and existing review/issue comments.
- **For local diffs** (via `git`): all uncommitted changes (staged and
  unstaged), plus any commits not yet pushed when they are part of the review
  target.

## Review Process

### 1. Understand Context

Before diving into code:

1. **For PRs**: Read the PR description, check linked issues, and review commit
   history
2. **For local diffs**: Recall the intent of the changes -- what problem is being
   solved and what approach was taken

### 2. Evaluate Code Changes

Review the diff with these language-agnostic criteria:

- **Correctness**: Does the code do what it claims to do?
- **Completeness**: Are all edge cases handled?
- **Clarity**: Is the code easy to understand?
- **Consistency**: Does it follow existing patterns in the codebase?
- **Testability**: Is the code testable? Are tests included?
- **Test quality**: Are there leftover scaffolding tests from TDD that
  should have been cleaned up? Flag as Warnings (see the IMPROVE phase
  in the `tdd-workflow` skill for cleanup guidance).

### 3. Review Metadata Quality (PR Only)

#### PR Description

Verify the PR description includes:

- **Background/Context**: Why is this change needed?
- **What changed**: Summary of the modifications
- **How to test**: Steps to verify the change (if applicable)
- **Related issues**: Links to tickets or issues

#### Commit Messages

Verify commit messages:

- Clearly describe the intent of each change
- Follow the project's commit message conventions
- Are atomic (one logical change per commit)

**Ideal**: One PR should contain one focused commit (squashed if necessary).

## Issue Classification

Categorize findings by severity:

### Critical Issues (Must Fix)

Issues that block merging:

- Security vulnerabilities
- Data loss or corruption risks
- Breaking changes without migration path
- Obvious bugs that will cause failures

### Warnings (Should Fix)

Issues that should be addressed:

- Performance problems
- Missing error handling
- Incomplete test coverage for critical paths
- Violations of established patterns
- Leftover scaffolding tests from TDD (existence-only checks, redundant
  mock assertions, duplicates after refactoring)

### Suggestions (Nice to Have)

Improvements that enhance quality:

- Code style improvements
- Refactoring opportunities
- Documentation additions
- Minor optimizations

## Output Format

Structure review feedback as follows:

```markdown
## Code Review Summary

[1-2 sentence overall assessment]

## Critical Issues

[List critical issues or "None"]

### [Issue Title]

- **Location**: `file_path:line_number`
- **Problem**: [Description]
- **Impact**: [Why this matters]
- **Suggestion**: [How to fix]

## Warnings

[List warnings or "None"]

## Suggestions

[List suggestions or "None"]

## Positive Highlights

[Optional: acknowledge good practices found in the code. Omit this
section entirely for trivial diffs where there is nothing distinctive
to highlight.]
```

## Review Principles

Point to exact locations, offer concrete fixes rather than bare criticism,
and prioritize the findings that matter most.

## Specialized Reviews

For concerns beyond general code review:

- **Security concerns**: Load the `security-review` skill and review in the main session
- **Architecture decisions**: Consider consulting domain experts
- **Performance critical code**: May need profiling or benchmarks
