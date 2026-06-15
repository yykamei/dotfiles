---
name: css
description: Load when authoring or editing plain CSS files (`.css`). Provides BEM + controlled CSS Nesting rules, minimal HTML markup principles, and padding/margin/gap responsibilities. Detailed material lives in `references/`.
---

# CSS

Principles and guidelines for writing CSS. The detailed rules and worked
examples live in three reference files; this top-level document is a
launchpad and a quick decision aid.

## Scope

This skill applies to **plain CSS files (`.css`)**.

- **Sass / Less**: out of scope. Sass-specific patterns such as
  `&--modifier` parent-selector concatenation are valid in those
  preprocessors and the prohibitions in `references/architecture.md`
  do not apply when writing `.scss` or `.sass` (they apply only when
  the output is plain CSS). Mixed projects: apply this skill only to
  the plain CSS portion.
- **CSS Modules / CSS-in-JS**: out of scope. When class names are
  scoped automatically by the toolchain (CSS Modules, styled-components,
  Emotion, vanilla-extract, etc.), the BEM naming convention in
  `references/architecture.md` is unnecessary — local scoping already
  prevents the collisions BEM is designed to avoid. The Spacing and
  Minimal HTML Markup principles still apply because they are about
  layout responsibility, not naming.

## Reference Files

Load the relevant reference when working on a specific concern:

| Concern                                                              | File                                                       |
| -------------------------------------------------------------------- | ---------------------------------------------------------- |
| BEM naming, HTML class identity, Block composition, nesting examples | [`references/architecture.md`](references/architecture.md) |
| Avoiding layout-only wrapper elements; Flex vs Grid decision         | [`references/markup.md`](references/markup.md)             |
| padding / margin / gap responsibilities; cross-axis stretch pitfalls | [`references/spacing.md`](references/spacing.md)           |

## Quick Principles

If you only remember five things:

1. **BEM names are flat.** Modifiers (`.block--modifier`) and Elements
   (`.block__element`) are always top-level rules. CSS Nesting is allowed
   only for pseudo-classes, pseudo-elements, at-rule queries, and
   attribute selectors. See `references/architecture.md`.
2. **One element has one BEM identity.** In HTML, assign either one Block
   or one Element as the BEM identity. Multiple Modifiers are allowed only
   when they belong to that same BEM identity. See
   `references/architecture.md`.
3. **Don't add `<div>`s for layout alone.** Prefer Grid over nested
   Flex containers when wrappers exist only to group rows or columns.
   See `references/markup.md`.
4. **Padding belongs to the component; spacing between siblings belongs
   to the parent (`gap`).** Margin on a reusable Block is an
   anti-pattern. See `references/spacing.md`.
5. **Nested Blocks stay independent.** Do not rename a reusable child
   Block as a parent Element to avoid layout side effects. Fix the
   parent layout or use a child Modifier that is independent of any
   specific parent Block. See `references/architecture.md` and
   `references/spacing.md`.

## Decision Aid

Before writing or modifying CSS, ask:

- Is this a `.css` file, or a Sass/CSS-in-JS/CSS-Modules file? If the
  latter, see Scope above before applying these rules.
- Am I assigning more than one BEM identity (Block or Element) to the
  same HTML element? Keep either one Block or one Element, plus only
  Modifiers for that same identity. See `references/architecture.md`.
- Am I about to nest a selector? Verify against the rules in
  `references/architecture.md`.
- Am I about to add a `<div>` only for layout? Read `references/markup.md`.
- Am I about to add `margin` to a Block? Read `references/spacing.md`.
- Am I turning a reusable child Block into a parent Element to avoid
  layout side effects? Keep it as a Block; fix the parent layout or use a
  Modifier that is independent of any specific parent Block.
