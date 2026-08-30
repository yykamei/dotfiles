---
name: tdd-workflow
description: Load when implementing or modifying logic that has meaningful test coverage value. Defines the RED → GREEN → IMPROVE → LINT cycle, keep-vs-discard criteria for test jigs, mock/stub boundaries, and project-aware coverage targets.
---

# Test-Driven Development Workflow

Follow this mandatory workflow when writing tests and implementing features.

## Scope — When to Apply This Skill

Apply this workflow to **changes whose behavior is meaningfully
testable**. The `core-philosophy` rule already says "not every change
requires tests"; this section makes that boundary concrete.

**In scope (TDD applies):**

- Production code that implements decisions, transformations, or
  state changes (parsers, business rules, API handlers, reducers,
  algorithms)
- Bug fixes for behavior that can be reproduced as a test case
- Refactors of code already covered by tests — tests guard the
  refactor

**Out of scope (TDD does not apply, though basic verification is
still expected):**

- Shell aliases, environment exports, or other dotfile edits whose
  "behavior" is just being present in a config file
- Pure documentation changes, comments, formatting
- Trivial wiring such as adding a constant export, registering a
  pre-existing component, or renaming a symbol the type system
  already validates
- Editor / tool / CI configuration where the round-trip cost of a
  test exceeds its value (verify by running the tool itself instead)

When in doubt, ask: *"Could a future regression here go unnoticed
without a test?"* If yes, this skill applies.

## TDD as a Design Jig

TDD is a design tool — a jig. Tests written during development guide
the shape of the implementation, but they are NOT automatically part
of the deliverable. A jig is invaluable while the design is being
formed, yet it may outlive its usefulness once development is done.

A stale jig can actively distort future work: when a new feature
breaks an existing test, the failure may simply mean the test pins an
outdated design decision. Conforming the new design to that stale
test would wrongly bend the design.

Therefore:

- Jigs are **not committed**. Remove them before committing (see
  "Which Tests to Keep vs. Discard").
- If a jig was already committed, delete it promptly in a follow-up
  commit.
- When an existing test fails during new-feature development, first
  ask: *"Is this test a jig pinning an outdated design, or a real
  regression guard?"* Rewrite or delete the jig rather than bending
  the new design to satisfy it.

## The TDD Cycle

### 1. RED - Write a Failing Test First

- Write a test that describes the expected behavior
- Run the test - it **MUST** fail
- If it passes, the test is not testing new functionality

### 2. GREEN - Write Minimal Implementation

- Write the simplest code that makes the test pass
- Do not add extra functionality
- Run the test - it **MUST** pass now

### 3. IMPROVE - Refactor

- Clean up the code while keeping tests green
- Remove duplication
- Improve naming and structure
- **Remove jig tests** -- Apply the "Which Tests to Keep vs. Discard"
  criteria: delete or consolidate tests that were written solely to
  drive the RED phase and are now redundant. The `code-review` skill
  flags leftover scaffolding as Warnings.
- Run tests after each refactor to ensure they still pass

### 4. LINT - Run Linters

- Identify the linters configured in the project (e.g., config files, CI workflows, `package.json` scripts, `Makefile` targets)
- Run all applicable linters and fix any violations before committing
- If a fix changes behavior, re-run the full test suite and return to the RED/GREEN cycle to update or add tests as needed

## Which Tests to Keep vs. Discard

Every test written during TDD is either a **regression guard** (worth
keeping) or a **jig** (discard). Decide deliberately:

| Dimension | Keep — regression guard | Discard — jig |
|---|---|---|
| What it verifies | Observable behavior of public APIs, business rules, input/output boundaries | Implementation details: private functions, mock call counts/order that pin internal call sequences, internal state |
| Meaning of failure | A real regression or contract violation → fix the implementation | The test fails because it pins an implementation detail or provisional behavior → update or delete the test, don't bend the design |
| Role after development | Guards future refactors and new features | None — its only role was guiding the design while it formed |
| Duplication | Is the sole (or best) verification of the behavior | Duplicates a higher-value test |
| Typical examples | Edge cases, boundary values, empty inputs, error handling, bug-reproduction (regression) tests | Existence checks ("function/class exists"), tests pinning placeholder or provisional behavior |

Procedure:

1. During development, when a test fails, classify it: real regression
   guard → fix the implementation; jig → rewrite or delete it.
2. In IMPROVE, review the suite and remove jigs.
3. Before committing, confirm no jigs remain — jigs are never committed
   (see "TDD as a Design Jig").
4. When an existing test fails during new-feature work, **default to
   treating it as a regression guard** if it verifies observable
   behavior. Delete it as a jig only when it verifies an
   implementation detail, an existence check, or clearly provisional
   behavior. If the new feature intentionally changes a behavior,
   update the test deliberately — that is not a jig. When in doubt,
   keep the test (see Scope: "Could a future regression here go
   unnoticed without a test?").
5. Coverage targets apply to the kept suite after jig removal — see
   "Coverage Target".

## When to Use Mocks/Stubs

Mocks and stubs should be avoided when possible, but use them when:

- The test target requires external access (REST API calls, database, third-party services)
- The test target requires I/O that produces non-deterministic output (timestamps, random values)
- The dependency is slow or expensive to set up

## Best Practices

1. **One behavior per test** — Each test should verify one specific
   behavior. Multiple assertions are fine when they all describe the
   same behavior (e.g., asserting both the returned status code and
   the response body of a single request); avoid bundling unrelated
   behaviors into one test.
2. **Descriptive test names** - Test names should describe what is being tested and expected outcome
3. **Arrange-Act-Assert** - Structure tests with clear setup, action, and verification phases
4. **Test edge cases** - Include tests for boundary conditions, empty inputs, and error scenarios
5. **Keep tests fast** - Unit tests should run in milliseconds

## Example Workflow

```
1. Define the interface/contract first
2. Write test: "should return empty array when no items exist"
3. Run test -> FAIL (function doesn't exist)
4. Implement: return []
5. Run test -> PASS
6. Write test: "should return all items when items exist"
7. Run test -> FAIL
8. Implement: add logic to return items
9. Run test -> PASS
10. Refactor if needed; remove jig tests per the Keep vs. Discard criteria
11. Run project linters -> fix violations
12. Run tests -> PASS (confirm lint fixes didn't break anything)
13. Confirm no jig tests remain -> commit (jigs are never committed)
```

## Coverage Target

Coverage targets are **project policy first**. If the project defines a
target (in `CONTRIBUTING.md`, a coverage configuration file, CI gates,
or an explicit team decision), follow that. If no project target
exists, use **80%** as a working default. Either way, prioritize
meaningful tests over chasing the number — coverage of code that
matters beats high coverage of trivial getters and wiring.

Coverage targets apply to the kept suite after jig removal — never
keep jigs to inflate coverage.
