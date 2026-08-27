# Code Comment Guidelines

## When this rule applies

When writing or editing source code, or when reviewing code where the
question of adding/removing comments arises.

## Principle: Comments Signal Missing Abstraction

If you feel the need to explain something in a comment, the code itself
likely lacks proper abstraction. Before writing a comment:

1. **Critically consider refactoring** — restructure the code so that the
   explanation becomes code (extract a well-named function/variable, introduce
   a meaningful abstraction, etc.).
2. **Choose the comment only if it is genuinely more advantageous** after
   that critical consideration — e.g., when the code itself cannot convey
   the information (why-not decisions, external constraints, historical
   background).
3. **If the judgment is difficult, explain the situation to the user and ask
   them to decide** instead of silently picking either option.

## Mandatory Comments on Top-Level Definitions

Every top-level implementation definition — OOP classes, mixin modules, and
similar reusable abstractions — MUST carry a code comment describing:

- **Purpose** — what the class/module is for
- **Usage** — how it should be used
- **A concrete code example** of how it should be used

"Top-level" means a definition at file/module scope, as opposed to nested or
local declarations. These interface comments are not the smell described
above — they document the abstraction's contract (purpose/usage), not its
implementation, and must not restate the implementation details.

```ts
/**
 * Sends usage analytics events to the backend.
 *
 * Use it after any significant user action; events are batched and flushed
 * automatically on an interval.
 *
 * ```ts
 * const analytics = new AnalyticsClient();
 * analytics.track("plan_selected", { plan: "pro" });
 * ```
 */
export class AnalyticsClient {}
```

## When NOT to Write Comments

- Do NOT write comments that restate what the code does — this is
  Ousterhout's **Comments Repeat Code** Red Flag (*A Philosophy of Software
  Design*)
- Do NOT write comments that describe the obvious behavior of a function or
  variable
- Do NOT add comments to every function, class, or block by default — except
  the mandatory top-level definition comments above

## When to Write Comments

Only write comments that explain:

- **Why not?** — Why an alternative approach was NOT chosen
  (e.g., "Avoided recursion here because the input can exceed stack depth limits")
- **Background context** — The business rule, constraint, or historical reason
  behind a decision that cannot be inferred from the code alone
- **Non-obvious trade-offs** — Performance, security, or compatibility
  considerations that influenced the implementation
- **Workarounds** — Temporary fixes with references to issues or tickets
- **Purpose and usage of top-level definitions** — see the mandatory rule above

## Bad vs Good Examples

Bad (restates the code — Comments Repeat Code):

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

A comment that merely explains what the code does is a smell: critically
consider refactoring so the code carries the explanation itself. Keep the
comment only when it wins the critical comparison, and always document
top-level definitions with purpose, usage, and a usage example.
