# Question Batching Guidelines

## When this rule applies

When using the `question` tool to ask the user one or more questions.

## Rule

When asking the user questions using the `question` tool, batch related questions
into a single invocation to minimize back-and-forth.

## Guidelines

- **Batch related questions**: Group questions about the same topic or context
  into a single `question` tool invocation
- **Split unrelated topics**: If questions cover different topics or contexts,
  ask them in separate invocations
- **Sequential when dependent**: If a later question depends on the answer
  to an earlier one, split them into separate invocations and wait for the answer
- **Clear and focused**: Each individual question should be specific
  and self-contained
