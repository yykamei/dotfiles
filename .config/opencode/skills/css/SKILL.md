---
name: css
description: Principles and guidelines for writing CSS.
---

# CSS

Principles and guidelines for writing CSS. This skill currently covers
architecture (BEM + controlled CSS Nesting), minimal HTML markup (avoiding
layout-only wrapper elements), and spacing (padding, margin, and gap
responsibilities). Additional sections may be added over time.

**Scope**: This skill applies to plain CSS files (`.css`). It does not cover
CSS preprocessors such as Sass or Less.

---

## Architecture

BEM (Block, Element, Modifier) is the foundation for all CSS class naming.
CSS Nesting is a controlled tool — permitted only for specific use cases listed
below.

### BEM Naming Convention

| Concept  | Pattern                          | Example                    |
|----------|----------------------------------|----------------------------|
| Block    | `.block`                         | `.searchForm`              |
| Element  | `.block__element`                | `.searchForm__input`       |
| Modifier | `.block--modifier`               | `.searchForm--disabled`    |
|          | `.block__element--modifier`      | `.searchForm__input--large`|

#### Hyphen Restriction

Block and Element names **must not** contain hyphens. Use `camelCase` or single
words instead. This prevents visual confusion with the `--` modifier prefix.

Good:

```css
.searchForm { }
.searchForm__submitButton { }
```

Bad:

```css
/* "search-form" looks ambiguous next to "--disabled" */
.search-form { }
.search-form__submit-button { }
```

### CSS Nesting Rules

#### Allowed

Nesting is permitted **only** for the following cases:

1. **Pseudo-classes** — `&:hover`, `&:focus`, `&:first-child`, etc.
   Combinations such as `&:hover::after` are also permitted as a single nested
   rule.
2. **Pseudo-elements** — `&::before`, `&::after`, `&::placeholder`, etc.
3. **At-rule queries** — `@media`, `@container`, `@supports`, etc. nested inside
   a rule
4. **Attribute selectors** — `&[aria-expanded="true"]`, `&[disabled]`, etc.

#### Not Allowed

The following nesting patterns are **prohibited**:

1. **Concatenation** — In pure CSS, `&` does not perform string concatenation.
   Writing `&--modifier` or `&__element` does **not** produce
   `.block--modifier` or `.block__element` — the browser treats the nested
   part as a type selector, silently producing dead rules. Both Modifiers and
   Elements must be written as flat, top-level rules. See
   [MDN: Concatenation is not possible](https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Nesting/Using#concatenation_is_not_possible).
2. **Descendant / child combinators** — No `& .child` or `& > .child`
3. **Sibling combinators** — No `& + .sibling` or `& ~ .sibling`

### Examples

#### Concatenation Anti-patterns

In pure CSS, `&` is a reference to the parent selector — not a string
substitution mechanism. Concatenation like `&--modifier` or `&__element` does
not work as it would in Sass.

Bad — modifier concatenation:

```css
.alert {
  padding: 16px;

  /* NOT allowed: &--danger does NOT produce .alert--danger in pure CSS */
  &--danger {
    color: red;
  }
}
```

Bad — element concatenation:

```css
.alert {
  padding: 16px;

  /* NOT allowed: &__icon does NOT produce .alert__icon in pure CSS */
  &__icon {
    margin-right: 8px;
  }
}
```

Good — Modifiers and Elements as flat, top-level rules:

```css
.alert {
  padding: 16px;
  border: 1px solid currentColor;
}

.alert--danger {
  color: red;
}

.alert--success {
  color: green;
}

.alert__icon {
  margin-right: 8px;
}
```

Bad — element as descendant:

```css
.alert {
  padding: 16px;

  /* NOT allowed: descendant combinator */
  & .alert__icon {
    margin-right: 8px;
  }
}
```

#### Pseudo-class and Pseudo-element Nesting

Good:

```css
.button {
  background: blue;
  color: white;

  &:hover {
    background: darkblue;
  }

  &:focus-visible {
    outline: 2px solid orange;
  }

  &::after {
    content: "";
    display: block;
  }

  /* Compound pseudo-selector */
  &:hover::after {
    opacity: 1;
  }
}
```

#### Attribute Selector Nesting

Good:

```css
.dropdown {
  display: none;

  &[aria-expanded="true"] {
    display: block;
  }

  &[disabled] {
    opacity: 0.5;
    pointer-events: none;
  }
}
```

#### At-rule Nesting

Good:

```css
.container {
  padding: 16px;

  @media (width >= 768px) {
    padding: 32px;
  }

  @container (inline-size >= 400px) {
    padding: 24px;
  }

  @supports (display: grid) {
    display: grid;
  }
}
```

#### Anti-patterns

Bad — descendant combinator:

```css
.card {
  /* NOT allowed */
  & > .child {
    margin: 0;
  }
}
```

Bad — sibling combinator:

```css
.card {
  /* NOT allowed */
  & + .card {
    margin-top: 16px;
  }
}
```

The correct approach is to write flat, top-level rules:

```css
.card {
  margin: 0;
}

.card__body {
  padding: 16px;
}

.card + .card {
  margin-top: 16px;
}
```

> **Note**: The spacing above uses an adjacent-sibling margin to illustrate
> flat top-level rules. For spacing best practice, see the
> [Spacing](#spacing) section — `gap` on a parent layout is preferred.

### Complete Component Example

```css
.navBar {
  display: flex;
  align-items: center;
  padding: 8px 16px;

  /* Pseudo-class */
  &:has(.navBar__menu[aria-expanded="true"]) {
    background: rgba(0, 0, 0, 0.9);
  }

  /* At-rule query */
  @media (width >= 1024px) {
    padding: 16px 32px;
  }
}

/* Modifiers are always top-level */
.navBar--sticky {
  position: sticky;
  inset-block-start: 0;
}

/* Elements are always top-level */
.navBar__logo {
  flex-shrink: 0;
}

.navBar__menu {
  display: none;

  /* Attribute selector */
  &[aria-expanded="true"] {
    display: flex;
  }

  /* At-rule query */
  @media (width >= 1024px) {
    display: flex;
  }
}

.navBar__link {
  color: inherit;
  text-decoration: none;

  /* Pseudo-class */
  &:hover {
    text-decoration: underline;
  }

  /* Pseudo-element */
  &::after {
    content: "";
    display: block;
    height: 2px;
    background: currentColor;
    scale: 0 1;
    transition: scale 0.2s ease;
  }

  /* Compound pseudo-selector */
  &:hover::after {
    scale: 1 1;
  }
}

/* Modifier is a top-level rule */
.navBar__link--active {
  font-weight: bold;
}
```

### Decision Checklist

Before nesting, every answer must be "yes":

1. Is the nested selector a pseudo-class, pseudo-element, at-rule query, or
   attribute selector? (If it involves `&` concatenation such as `&--modifier`
   or `&__element`, the answer is "no" — write a flat top-level rule instead.)
2. Does the nesting stay at one level? (Exception: an at-rule query may
   contain other allowed selectors.)
3. Is the resulting selector still easy to read and search for?

If any answer is "no", write a flat top-level rule instead.

---

## Minimal HTML Markup

Do not add HTML elements solely to satisfy a CSS layout model. If a layout
requires wrapper elements that carry no semantic meaning and no accessibility
role, consider whether a different CSS approach can eliminate them.

### Guidelines

1. **Prefer CSS Grid when it removes layout-only wrappers.** If a
   two-dimensional layout (rows *and* columns) would require extra `<div>`s
   under Flexbox to group items into rows, use Grid instead — it can lay out
   children in both dimensions from a single container.
2. **Keep Flexbox for genuinely one-dimensional cases.** A row of buttons, an
   inline icon-and-label pair, or a simple horizontal navigation — these are
   naturally one-dimensional. Flexbox handles them with less ceremony than Grid.
   Do not force Grid where it adds verbosity without reducing markup.
3. **Test each `<div>` for purpose.** Before adding an element, ask: *"Does this
   element exist for semantics or accessibility, or only for layout?"* If the
   answer is only layout, look for a CSS-only alternative first.

### Examples

#### Bad — Flex with row wrappers

The outer container uses `flex-direction: column`, and each row is itself a Flex
container — all to achieve a consistent three-column card layout:

```html
<div class="cardGrid">
  <div class="cardGrid__row">          <!-- layout-only wrapper -->
    <div class="card">…</div>
    <div class="card">…</div>
    <div class="card">…</div>
  </div>
  <div class="cardGrid__row">          <!-- layout-only wrapper -->
    <div class="card">…</div>
    <div class="card">…</div>
    <div class="card">…</div>
  </div>
</div>
```

```css
.cardGrid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.cardGrid__row {
  display: flex;
  gap: 16px;
}

.card {
  flex: 1;
}
```

#### Good — Grid without wrappers

Grid eliminates the row wrappers entirely:

```html
<div class="cardGrid">
  <div class="card">…</div>
  <div class="card">…</div>
  <div class="card">…</div>
  <div class="card">…</div>
  <div class="card">…</div>
  <div class="card">…</div>
</div>
```

```css
.cardGrid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
```

#### Good — Flexbox for a one-dimensional layout

A horizontal navigation is genuinely one-dimensional. Flexbox is the natural
fit; no extra wrappers are needed:

```html
<nav class="navBar">
  <a class="navBar__link" href="/">Home</a>
  <a class="navBar__link" href="/about">About</a>
  <a class="navBar__link" href="/contact">Contact</a>
</nav>
```

```css
.navBar {
  display: flex;
  align-items: center;
  gap: 16px;
}
```

### Decision Checklist

Before adding an HTML element, every answer must be "yes":

1. Does this element carry semantic meaning or an accessibility role?
2. Does this element aid assistive technology (e.g., landmark, grouping)?
3. Is there no CSS-only alternative that achieves the same layout?

If any answer is "no", look for a CSS-only alternative (e.g., switching from
nested Flex containers to Grid) before adding the element.

---

## Spacing

Spacing in a component architecture follows a clear division of
responsibility:

- **Padding** belongs to the component itself — its internal breathing room.
- **Margin** (external spacing between components) belongs to the parent
  layout, not to the component.
- **`gap`** is the primary mechanism for the parent to distribute spacing
  between its children.

### Padding — Internal Space of a Component

Padding is the space a component needs to be visually complete on its own. A
Block declares its own padding because that space is part of the component's
visual identity, independent of where it is placed.

```css
.card {
  padding: 16px;
}

.alert {
  padding: 12px 16px;
}
```

### Margin — Do Not Apply to a Block

Applying margin to an independent Block is an anti-pattern in principle. When a
Block carries its own margin, it becomes coupled to a specific layout context
and loses its reusable nature — the same Block placed in a different container
would bring unwanted spacing.

Bad — margin on the Block itself:

```css
.card {
  padding: 16px;
  margin-bottom: 24px; /* couples .card to a vertical-stack context */
}
```

Good — the parent layout controls spacing (see next section):

```css
.card {
  padding: 16px;
}

.cardList {
  display: flex;
  flex-direction: column;
  gap: 24px;
}
```

#### Exception

For page-specific Blocks that are not intended for reuse (e.g., a one-off hero
section), margin may be acceptable when the overhead of an additional layout
wrapper outweighs the benefit. Even in these cases, prefer parent-controlled
spacing when practical.

### Component Spacing — Responsibility of the Parent Layout

The space between sibling components is entirely the responsibility of the
parent element that groups them. The parent — a layout component — uses `gap`
to distribute uniform spacing among its children.

Bad — children manage their own external spacing:

```css
.card {
  margin-bottom: 24px;
}

.card:last-child {
  margin-bottom: 0;
}
```

Good — the parent layout owns the spacing:

```css
.cardList {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.card {
  padding: 16px;
}
```

> **Note on the Architecture section examples**: The Anti-patterns section
> above shows `.card + .card { margin-top: 16px; }` as the "flat top-level"
> alternative to a nested sibling combinator. That example demonstrates *nesting
> rules*, not spacing best practice. From a spacing perspective, replacing the
> adjacent-sibling margin with a parent `gap` is preferred.

### Cross-Axis Stretching — Side Effect of Layout Containers

When a parent uses `display: flex` or `display: grid`, its children stretch
along the cross axis by default (`align-items: stretch`). This means:

- **`flex-direction: column`** — children stretch to the **full width** of
  the container.
- **`flex-direction: row`** (default) — children stretch to the **full
  height** of the tallest sibling.
- **`display: grid`** — children stretch to fill their grid area (both
  `align-items` and `justify-items` default to `stretch`).

This is often desirable (e.g., equal-height cards in a row), but it can
break components that rely on intrinsic sizing — buttons, badges, inline
inputs, and other elements whose width or height should be determined by
their content.

Bad — a vertical stack that unintentionally stretches button width:

```css
.actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
```

Each child — including `.button` — stretches to the full container width
even when the button's content is much narrower.

Bad — a horizontal row that unintentionally stretches children to equal
height:

```css
.toolbar {
  display: flex;
  gap: 12px;
}
```

If one child is taller than the others, every sibling stretches to match
its height. This may distort components like badges or single-line inputs.

Good — prevent stretching with `align-items`:

```css
.actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: flex-start;
}
```

Good — prevent height stretching in a horizontal row:

```css
.toolbar {
  display: flex;
  gap: 12px;
  align-items: center;
}
```

Good — the child opts out of stretching with `align-self`:

```css
.actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.actions > .button {
  align-self: flex-start;
}
```

Before using `gap` with Flex or Grid, verify that the default cross-axis
stretching is acceptable for every direct child. If not, set
`align-items` on the parent or `align-self` on the specific child.

### Fallback — When `gap` Is Not Available

`gap` requires a Flex or Grid formatting context. When the parent uses
`display: block` (normal flow), or when non-uniform spacing is needed between
specific children, alternative approaches are necessary.

#### Normal Flow (Block Layout)

When the parent is a block-level container and converting it to Flex or Grid is
not justified, the parent can apply margin to its children via a direct-child
selector. The key principle remains: the *parent* dictates the spacing, not the
child Block itself.

```css
.prose > * + * {
  margin-block-start: 1em;
}
```

#### Non-uniform Spacing

When certain children need different spacing from the uniform `gap`, the parent
layout can target specific children. Avoid pushing this responsibility into the
child Block.

```css
.sidebar {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.sidebar > .sidebar__section--featured {
  margin-block-end: 8px; /* 8px extra beyond the 16px gap */
}
```

In this pattern, `.sidebar` (the layout parent) retains control of spacing.
The child Block `.sidebar__section` does not declare margin on itself.

### Decision Checklist

Before adding spacing to a component, answer these questions:

1. Is this spacing *inside* the component's visual boundary? → Use
   **padding** on the Block.
2. Is this spacing *between* sibling components? → Use **`gap`** on the
   parent layout container.
3. Is `gap` unavailable (block flow) or insufficient (non-uniform spacing)?
   → Apply margin via the **parent** using child selectors, not on the
   Block itself.
4. Is the Block truly page-specific and never reused? → Margin on the
   Block may be acceptable as an exception, but prefer parent-controlled
   spacing.
5. Does the layout container's default `align-items: stretch` produce
   acceptable sizing for every direct child? → If not, set
   **`align-items`** on the parent or **`align-self`** on specific
   children.
