# Self-Review After Code Changes

## When this rule applies

After completing in-scope code changes (see Scope below), and before
proceeding to commit, PR creation, or any other subsequent step.

## Rule

After completing any code implementation, you MUST conduct a self-review by
delegating to the `code-reviewer` agent before proceeding to commit, PR
creation, or any other subsequent step.

When the change touches security-sensitive areas (see Security-Sensitive
Changes below), you MUST also delegate to the `security-reviewer` agent as
part of the same self-review.

## Workflow

1. **Finish implementation** -- Complete all code changes (including TDD cycles
   if using the `tdd-workflow` skill)
2. **Classify the change** -- Inspect the diff (e.g.,
   `git diff HEAD --name-only`) and decide whether it touches any
   security-sensitive area
3. **Delegate** -- Always launch the `code-reviewer` agent. If the change is
   security-sensitive, launch the `security-reviewer` agent in the SAME
   message so both reviews run in parallel. Pass the same review scope to both
4. **Handle blocking findings** -- Fix blocking findings in the main session,
   then re-run the reviewer(s) that reported them:
   - `code-reviewer` -- Critical Issues
   - `security-reviewer` -- CRITICAL and HIGH findings
   If the `code-reviewer` report flags security concerns or recommends
   delegating to `security-reviewer`, run `security-reviewer` before
   proceeding even if step 2 did not classify the change as security-sensitive
5. **Proceed** -- Only after the review passes with no blocking findings, move
   on to commit or PR creation

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
  definitions, build configs, opencode configuration, agents, skills, plugins,
  and similar files that affect runtime or agent behavior

**Out of scope (self-review skipped):**

- Documentation-only edits (`.md`, `.txt`), unless the documentation is an
  opencode rule, skill, agent, command, or other agent behavior definition
- Comment-only or typo-only changes
- Auxiliary files such as `.gitignore`, `.editorconfig`

**Escape hatch:** If the user explicitly requests a review, run the
`code-reviewer` agent regardless of scope.
