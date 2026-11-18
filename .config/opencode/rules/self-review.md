# Self-Review After Code Changes

## When this rule applies

After completing in-scope code changes (see Scope below), and before
proceeding to commit, PR creation, or any other subsequent step.

## Rule

After completing the implementation, load the `code-review` skill and
self-review the diff against its criteria in the main session.

When the change touches security-sensitive areas (see Security-Sensitive
Changes below), also delegate security review to the `security-reviewer`
subagent -- an orchestrator that dispatches all nine per-perspective security
subagents in parallel and returns one consolidated, cross-referenced report.
Run it in the same message alongside the code review so both run
concurrently.

The `security-review` skill remains as a manual reference checklist for the
main session. If the code review flags security concerns or recommends
delegating to `security-reviewer`, run `security-reviewer` before proceeding
even if the change was not classified as security-sensitive.

## Workflow

1. **Finish implementation** -- Complete all code changes, including TDD
   cycles.
2. **Classify the change** -- Inspect the diff (e.g.,
   `git diff HEAD --name-only`) and decide whether it touches a
   security-sensitive area.
3. **Review** -- Load the `code-review` skill and review the pending diff in
   the main session. If the change is security-sensitive, also launch the
   `security-reviewer` subagent in the same message.
4. **Handle blocking findings** -- Fix Critical Issues, structural design
   Warnings (Information Leakage, Shallow Module, Temporal Decomposition, and
   Cosmetic Decomposition), and security CRITICAL/HIGH findings, then repeat
   the review. Localized design Red Flags (Overexposure, Pass-Through
   Methods, Hard-to-name Entity, Comment Repeats Code) remain Suggestions.
5. **Proceed** -- Commit or open the PR only after no blocking findings
   remain.

If a structural design Warning cannot be resolved without expanding beyond
the current task, changing public behavior, or contradicting a design the
user mandated, stop and present the trade-off instead of iterating.

## Security-Sensitive Changes

A change is security-sensitive when it touches any of the following. These
areas cover all nine perspectives of the `security-reviewer` agent:

- User input handling -- parsing, validation, sanitization
- Authentication, authorization, or session management
- API endpoints, external requests, or network communication
- Sensitive data -- secrets, credentials, tokens, PII, cryptographic
  operations
- Dependency manifests or lock files
- CSRF/CORS/Cookie or other security-relevant configuration
- Audit logging or logging of security-relevant events

## Scope

This rule applies to changes in **executable code, test code, and
configuration files**, regardless of the implementation method used (TDD,
direct implementation, refactoring, etc.).

**In scope (self-review required):**

- Executable code -- `.ts`, `.js`, `.py`, `.go`, `.rs`, `.sh`, `.lua`, `.rb`,
  and similar source files
- Test code -- any file under test directories or matching test naming
  conventions
- Configuration files -- `.yaml`, `.yml`, `.toml`, `.json`, `Dockerfile`, CI workflow
  definitions, build configs, agent configuration (rules, skills, agents, and
  plugins), and similar files that affect runtime or agent behavior

**Out of scope (self-review skipped):**

- Documentation-only edits (`.md`, `.txt`), unless the documentation is an
  agent rule, skill, command, or other agent behavior definition
- Comment-only or typo-only changes
- Auxiliary files such as `.gitignore`, `.editorconfig`

**Escape hatch:** If the user explicitly requests a review, conduct it
regardless of scope.
