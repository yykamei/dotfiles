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
- **Pass-through methods**: a method that does little but delegate to
  another method with a similar signature.
- **Information leakage**: a design decision exposed through multiple
  modules (e.g., knowledge of a file format spread across layers).
- **Temporal decomposition**: modules split by execution-time order rather
  than by information they hide, coupling them to a single call order.
- **Over-exposure**: more parameters, members, or hooks than the common
  usage needs.
- **Hard-to-name entity**: struggling to describe a module in one clear
  phrase usually means its abstraction is wrong.

## Behavioral Guidance

- **New design**: apply the principles above when choosing module boundaries
  and interfaces. State the intended abstraction contract (what hides what)
  when presenting a design.
- **Refactoring opportunities**: while modifying existing code, if the change
  clearly violates these principles and the fix is contained to the current
  work, **propose the refactor first and get the user's approval** before
  applying it. Do not expand the diff silently. Scope the proposal to the
  code being touched (see Simplicity in Core Philosophy).

## Related rules

- **Code Comment Guidelines** — interface comments documenting purpose,
  usage, and an example are the surface side of "deep modules".
- **Core Philosophy → Simplicity** — this rule governs *how* to structure
  what is built; Simplicity governs *how much* to build.
