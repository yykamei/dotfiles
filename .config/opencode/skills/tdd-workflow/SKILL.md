---
name: tdd-workflow
description: Test-Driven Development workflow guidelines for writing tests before implementation.
---

# Test-Driven Development Workflow

Follow this mandatory workflow when writing tests and implementing features.

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
- Run tests after each refactor to ensure they still pass

## When to Use Mocks/Stubs

Mocks and stubs should be avoided when possible, but use them when:

- The test target requires external access (REST API calls, database, third-party services)
- The test target requires I/O that produces non-deterministic output (timestamps, random values)
- The dependency is slow or expensive to set up

## Best Practices

1. **One assertion per test** - Each test should verify one specific behavior
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
10. Refactor if needed
```

## Coverage Target

Aim for **80%+ code coverage**, but prioritize meaningful tests over coverage numbers.
