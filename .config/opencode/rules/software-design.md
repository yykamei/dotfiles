# Software Design Principles

## When this rule applies

- When designing new modules, classes, functions, or APIs.
- When writing or modifying code where design decisions arise (module
  boundaries, naming, splitting or merging functions, choosing interfaces).
- When reviewing code or plans for structure and abstraction quality.

## Principles

Based on John Ousterhout, *A Philosophy of Software Design*.

1. **Modules should be deep** — a module encapsulates significant
   functionality behind a small interface. Prefer deepening an existing
   module over adding a new shallow one. A deep module hides complexity so
   callers stay simple; a shallow module passes complexity through to them.
2. **Design interfaces for the most common usage** — the default/common path
   should require the least ceremony. Rarely needed detail belongs in
   optional parameters, separate functions, or lower layers — not in the
   common call site.
3. **Simple interface over simple implementation** — when the two conflict,
   put the complexity in the implementation, not the interface. A caller
   must not need to understand the implementation to use the interface
   correctly (e.g., a parameters-vs-return-value choice that hides an
   information leak).
4. **General-purpose modules are deeper** — when a module's functionality
   set is unclear, lean general. General-purpose interfaces often simplify
   the current use case too, since they expose fewer usage-specific details.
   But scope this to today's plausible needs, not speculative features —
   see Simplicity in Core Philosophy.
5. **Separate general-purpose and special-purpose code** — a general-purpose
   module must not absorb special-purpose details; layered composition keeps
   the general layer deep and the special layer replaceable.
6. **Design for ease of reading, not ease of writing** — code is read far
   more often than it is written. Prefer clarity over cleverness and over
   writing-convenience (e.g., do not scatter logic across many tiny shallow
   functions just to keep each function short).

## Red Flags

Watch for these smells when writing or reviewing code; each signals a
design that violates the principles above:

- **Shallow module**: small interface that reveals most of the
  implementation's complexity.
- **Cosmetic decomposition**: functions split out only to satisfy
  line-count or complexity linters, hiding no complexity. Short methods
  are not a goal in themselves; prefer inlining single-call chains over
  scattering logic (see Principle 6).
- **Pass-through methods**: a method that does little but delegate to
  another method with a similar signature.
- **Information leakage**: a design decision exposed through multiple
  modules (e.g., knowledge of a file format spread across layers).
- **Temporal decomposition**: modules split by execution-time order rather
  than by information they hide, coupling them to a single call order.
- **Overexposure**: more parameters, members, or hooks than the common
  usage needs.
- **Hard-to-name entity**: struggling to describe a module in one clear
  phrase usually means its abstraction is wrong.

## Detection Cues

Use these cues to spot the Red Flags in a diff. A cue is a prompt to look,
not proof: confirm the issue is real before flagging it. The remedy is a
candidate, not an obligation; code review assigns the severity.

| Cue in the diff | Likely Red Flag | Candidate remedy |
| --- | --- | --- |
| A function body is one call that forwards its arguments | Pass-through method | Inline it at the call site |
| The interface requires callers to know a format, ordering, or retry detail | Shallow module | Move the detail behind the interface; see the example below |
| Two files parse, validate, or serialize the same format | Information leakage | Move the format into one module |
| Each execution step gets its own module, and the modules share state | Temporal decomposition | Regroup by the information each module hides |
| Optional flags or parameters exist for a single caller | Overexposure | Give the common path a plain interface; move the variant to a separate function |
| A chain of single-caller methods reads as one block when inlined | Cosmetic decomposition | Inline the trivial extractions |
| A comment restates the code below it | Comment Repeats Code | Extract a name that carries the meaning |
| The name lists several responsibilities (`formatAndWriteFileV2`) | Hard-to-name entity | Rename around the responsibility |

`Comment Repeats Code` is defined in the Code Comment Guidelines; the other
flags are defined above.

Two alternative designs, differing only in what the caller must know:

```ts
// Shallow: every caller must know the storage format
function saveUser(user: User, destination: StorageDestination, asJson: boolean): void {}

// Deep: callers state intent; the module owns the format
function saveUser(user: User, destination: StorageDestination): void {}
```

## Behavioral Guidance

- **New design**: apply the principles above when choosing module boundaries
  and interfaces. State the intended abstraction contract (what hides what)
  when presenting a design.
- **Plans**: when a plan introduces or changes a module boundary, a public
  interface, or a new source file other code will call, the plan MUST include
  a `## Design` section. For each affected module, state:
  - its responsibility in one sentence;
  - what it hides (the decisions and details callers must not know);
  - the interface and the common call path;
  - the alternatives considered and why they were rejected;
  - the Red Flags the design avoids, and how.

  For a plan that changes only internals behind an unchanged interface, a
  one-line `## Design` section containing `No interface change: <reason>`
  satisfies the requirement.
- **Refactoring opportunities**: while modifying existing code, if the change
  clearly violates these principles and the fix is contained to the current
  work, **propose the refactor first and get the user's approval** before
  applying it. Do not expand the diff silently. Scope the proposal to the
  code being touched (see Simplicity in Core Philosophy).

## Related rules

- **Code Comment Guidelines** — interface comments documenting purpose,
  usage, and an example are the surface side of "deep modules"; the
  **Comment Repeats Code** Red Flag is governed there.
- **Core Philosophy → Simplicity** — this rule governs *how* to structure
  what is built; Simplicity governs *how much* to build.
- **Plan Structure** — the Design section fixes the boundaries; the
  implementation steps name the files that implement each boundary.
