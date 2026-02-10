# Code Comment Guidelines

## Principle: Code Should Speak for Itself

Write code that is self-documenting. Variable names, function names, and code structure
should convey the design intent without requiring comments.

## When NOT to Write Comments

- Do NOT write comments that restate what the code does
- Do NOT write comments that describe the obvious behavior of a function or variable
- Do NOT add comments to every function, class, or block by default

## When to Write Comments

Only write comments that explain:

- **Why not?** -- Why an alternative approach was NOT chosen
  (e.g., "Avoided recursion here because the input can exceed stack depth limits")
- **Background context** -- The business rule, constraint, or historical reason
  behind a decision that cannot be inferred from the code alone
  (e.g., "The API returns dates in JST regardless of locale settings, per vendor specification")
- **Non-obvious trade-offs** -- Performance, security, or compatibility considerations
  that influenced the implementation
- **Workarounds** -- Temporary fixes with references to issues or tickets

## Bad vs Good Examples

Bad (restates the code):

```ts
// Get the user by ID
const user = getUserById(id);
```

Good (explains why):

```ts
// Using sequential processing instead of Promise.all because
// the payment gateway rate-limits concurrent requests to 5/sec
for (const payment of payments) {
  await processPayment(payment);
}
```

## Summary

If you feel the need to add a comment explaining what the code does,
consider refactoring the code to be more readable instead.
