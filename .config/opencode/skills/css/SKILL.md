---
name: css
description: Load when authoring or editing plain CSS files (`.css`). Provides component organization, shallow CSS Nesting guidance, cascade layers / scope, minimal markup, spacing, container queries, and design tokens. Detailed material lives in `references/`.
---

# CSS

Principles and guidelines for writing modern plain CSS. The detailed rules
and worked examples live in reference files; this top-level document is a
launchpad and a quick decision aid.

Native nesting, cascade layers, container queries, and custom properties
are Baseline widely available; `@scope` is Baseline Newly Available — pair
essential scoped rules with a plain-selector fallback (see
`references/cascade.md`). Prefer them over naming discipline or
preprocessor tricks to solve specificity and scoping problems.

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
| Component organization, composition, nesting with depth limits      | [`references/architecture.md`](references/architecture.md)               |
| Cascade layers, `:is()` / `:where()`, `@scope`                      | [`references/cascade.md`](references/cascade.md)                         |
| Container queries, design tokens, `:has()`, logical properties      | [`references/responsive-tokens.md`](references/responsive-tokens.md)     |
| Avoiding layout-only wrapper elements; Flex vs Grid decision        | [`references/markup.md`](references/markup.md)                           |
| padding / margin / gap responsibilities; cross-axis stretch pitfalls | [`references/spacing.md`](references/spacing.md)                         |

## Quick Principles

If you only remember six things:

1. **Nest shallowly, not deeply.** Group a component's states, direct
   children, and variants with native nesting up to 1–2 levels. Avoid 3+
   levels; split the component instead. Never use `&` concatenation
   (`&-suffix`) in pure CSS — it does not work. See
   `references/architecture.md`.
2. **Components stay independent.** A component nested inside another
   component keeps its own class; fix the parent layout or use a
   reusable variant instead of renaming the child with a
   parent-specific class. See `references/architecture.md` and
   `references/spacing.md`.
3. **Don't add `<div>`s for layout alone.** Prefer Grid over nested
   Flex containers when wrappers exist only to group rows or columns.
   See `references/markup.md`.
4. **Padding belongs to the component; spacing between siblings belongs
   to the parent (`gap`).** Margin on a reusable component is discouraged.
   See `references/spacing.md`.
5. **Declare layer order once.** Put `@layer reset, base, components,
   utilities;` at the entry point and keep all styles layered. Unlayered
   styles beat layered ones — use that only intentionally. See
   `references/cascade.md`.
6. **Responsive components respond to their container.** Prefer
   `@container` over `@media` for reusable components; keep values in
   design tokens (custom properties). See
   `references/responsive-tokens.md`.

## Decision Aid

Before writing or modifying CSS, ask:

- Is this a `.css` file, or a Sass/CSS-in-JS/CSS-Modules file? If the
  latter, see Scope above before applying this skill.
- Am I about to nest? Keep it to 1–2 levels for states, direct children,
  or variants. Consider whether `@scope` fits better when proximity
  matters. See `references/architecture.md` and `references/cascade.md`.
- Am I fighting specificity? Reach for `@layer` ordering or `:where()`
  before adding specificity or `!important`. See `references/cascade.md`.
- Am I about to add a `<div>` only for layout? Read `references/markup.md`.
- Am I about to add `margin` to a reusable component? Read
  `references/spacing.md`.
- Is this breakpoint about the viewport or the component's container? For
  reusable components, prefer `@container`. See
  `references/responsive-tokens.md`.
- Is this value (color, spacing, type) reused? Put it in a token (custom
  property). See `references/responsive-tokens.md`.
