---
name: code-review
description: Code review workflow guidelines for reviewing pull requests and code changes.
---

# Code Review Workflow

Guidelines for conducting effective code reviews on pull requests, local diffs,
and any code changes.

## Determine Review Target

Before starting a review, determine whether you are reviewing a **pull request**
or a **local diff** (e.g., self-review before committing). The information
gathering steps differ, but the review process, issue classification, and output
format are shared.

---

## Gathering Context

### For Pull Requests

Use these GitHub CLI commands to gather context before reviewing:

#### View PR Details

```bash
# View PR description, title, labels, and metadata
gh pr view <PR_NUMBER>

# View PR in specific format
gh pr view <PR_NUMBER> --json title,body,labels,author,baseRefName,headRefName
```

#### View Code Changes

```bash
# View the diff of changes
gh pr diff <PR_NUMBER>

# View diff with specific options
gh pr diff <PR_NUMBER> --color=always
```

#### View Commits

```bash
# List commits in the PR
gh pr view <PR_NUMBER> --json commits --jq '.commits[].messageHeadline'

# View detailed commit information via API
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/commits
```

#### Check CI Status

```bash
# View CI check status
gh pr checks <PR_NUMBER>
```

#### View PR Comments

```bash
# View review comments
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments

# View issue-style comments
gh api repos/{owner}/{repo}/issues/<PR_NUMBER>/comments
```

### For Local Diffs (Self-Review)

Use these git commands to gather changes before reviewing:

#### View Changed Files

```bash
# List files with uncommitted changes (staged + unstaged)
git diff HEAD --name-only

# List only staged files
git diff --staged --name-only

# List only unstaged files
git diff --name-only
```

#### View the Diff

```bash
# View all uncommitted changes (staged + unstaged)
git diff HEAD

# View only staged changes
git diff --staged

# View only unstaged changes
git diff
```

#### View Recent Commits (if reviewing commits not yet pushed)

```bash
# View commits ahead of the remote
git log @{u}..HEAD --oneline

# View diff of commits not yet pushed
git diff @{u}..HEAD
```

---

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

[Acknowledge good practices found in the code]
```

## Review Principles

1. **Be constructive**: Offer solutions, not just criticism
2. **Be specific**: Point to exact locations and provide examples
3. **Be respectful**: Remember there's a person behind the code
4. **Prioritize**: Focus on important issues first
5. **Educate**: Explain why something is problematic
6. **Acknowledge good work**: Highlight well-written code

## Delegation

For specialized reviews, delegate to appropriate agents:

- **Security concerns**: Delegate to `security-reviewer` agent
- **Architecture decisions**: Consider consulting domain experts
- **Performance critical code**: May need profiling or benchmarks
