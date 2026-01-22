# Testing requirements

## Test-Driven development

MANDATORY workflow:

1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)

## When to use mocks/stubs

Basically, mocks and stubs shouldn't be used, but you can use them when:

- the test target requires external access, such as REST API calls.
- the test target requires I/O which always emits output differently.
