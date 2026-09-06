---
name: css
description: Load when authoring or editing plain CSS files (`.css`). Scope-first component styling with `@scope`, cascade layers, shallow nesting, minimal markup and classes, spacing, container queries, and design tokens. Detailed material lives in `references/`.
---

# CSS

Principles and guidelines for writing modern plain CSS. The detailed rules
and worked examples live in reference files; this top-level document is a
launchpad and a quick decision aid.

This skill targets current browsers. `@scope`, native nesting, cascade
layers, container queries, and custom properties are Baseline features —
prefer them over the naming conventions and preprocessor tricks older
methodologies (BEM and its relatives) used to solve specificity and
containment. `@scope` replaces class-naming discipline: draw the
component boundary with `@scope`, style its parts with element selectors
inside the block, and invent a class only where it earns its name (see
`references/architecture.md` and `references/cascade.md`).

## Scope

This skill applies to **plain CSS files (`.css`)**.

- **Sass / Less**: out of scope. Sass parent-selector concatenation
  (`&-suffix`) is valid in those preprocessors. The concatenation
  prohibition in `references/architecture.md` exists because pure CSS
  has no string concatenation — it still applies to the CSS output, not
  to `.scss` authoring. Mixed projects: apply this skill only to the
  plain CSS portion.
- **CSS Modules / CSS-in-JS**: scoping is handled by the toolchain
  there (CSS Modules, styled-components, Emotion, vanilla-extract,
  etc.), so class-identity concerns do not apply. Cascade, spacing,
  markup, responsive, and token principles still apply because they are
  about layout and cascade responsibility, not naming.

## Reference Files

Load the relevant reference when working on a specific concern:

| Concern                                                             | File                                                                     |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Scope roots, minimal classes, composition, nesting with depth limits | [`references/architecture.md`](references/architecture.md)               |
| `@scope`, cascade layers, `:is()` / `:where()`                       | [`references/cascade.md`](references/cascade.md)                         |
| Container queries, design tokens, `:has()`, logical properties      | [`references/responsive-tokens.md`](references/responsive-tokens.md)     |
| Avoiding layout-only wrappers and unnecessary classes               | [`references/markup.md`](references/markup.md)                           |
| padding / margin / gap responsibilities; cross-axis stretch pitfalls | [`references/spacing.md`](references/spacing.md)                         |

## Quick Principles

If you only remember seven things:

1. **Draw the component boundary with `@scope`.** Style parts with
   element selectors inside the block — `@scope (.card) { h3 { … }
   img { … } }`. Bare selectors inside `@scope` contribute zero root
   specificity, so they stay easy to override. Don't name a part class
   where an element selector will do. See `references/cascade.md`.
2. **Reserve `class` for what earns a name.** Scope roots, variants
   (`.alert.danger`), states (`.is-*`, or preferably the platform's own
   attributes: `[aria-expanded="true"]`, `[aria-current="page"]`,
   `[disabled]`), script hooks, and reusable layout traits
   (`.no-stretch`). Never prefix a part name with its component name —
   the scope already provides the context. See
   `references/architecture.md`.
3. **Components stay independent.** A component nested inside another
   component keeps its own boundary; fix the parent layout or use a
   reusable trait instead of renaming the child. When a parent hosts
   other components, bound its selectors with a donut limit
   (`@scope (.parent) to (...)`). See `references/architecture.md` and
   `references/spacing.md`.
4. **Don't add `<div>`s for layout alone.** Prefer Grid over nested
   Flex containers when wrappers exist only to group rows or columns.
   See `references/markup.md`.
5. **Padding belongs to the component; spacing between siblings belongs
   to the parent (`gap`).** Margin on a reusable component is
   discouraged. See `references/spacing.md`.
6. **Declare layer order once.** Put `@layer reset, base, components,
   utilities;` at the entry point and keep all styles layered. Unlayered
   styles beat layered ones — use that only intentionally. See
   `references/cascade.md`.
7. **Responsive components respond to their container.** Prefer
   `@container` over `@media` for reusable components; keep values in
   design tokens (custom properties). See
   `references/responsive-tokens.md`.

## Decision Aid

Before writing or modifying CSS, ask:

- Is this a `.css` file, or a Sass/CSS-in-JS/CSS-Modules file? If the
  latter, see Scope above before applying this skill.
- Am I about to define a component? → One `@scope (root)` block; style
  parts with element selectors; add classes only for the root,
  variants, states, and hooks. See `references/architecture.md` and
  `references/cascade.md`.
- Am I about to name a part class (`.card-title`, `.nav-link`)? → Try
  an element selector inside the scope first; a part class is justified
  only when selectors would be ambiguous, the part is styled from
  outside, or JavaScript needs a hook. See `references/architecture.md`.
- Will this component host other components? → Add a `to (...)` donut
  limit so its selectors never restyle the children's internals. See
  `references/cascade.md`.
- Am I fighting specificity? Reach for `@layer` ordering, scoped bare
  selectors, or `:where()` before adding specificity or `!important`.
  See `references/cascade.md`.
- Am I about to add a `<div>` only for layout, or a `class` only for
  styling? Read `references/markup.md`.
- Am I about to add `margin` to a reusable component? Read
  `references/spacing.md`.
- Is this breakpoint about the viewport or the component's container?
  For reusable components, prefer `@container`. See
  `references/responsive-tokens.md`.
- Is this value (color, spacing, type) reused? Put it in a token
  (custom property). See `references/responsive-tokens.md`.
