---
name: css
description: Principles and guidelines for writing CSS.
---

# CSS

Principles and guidelines for writing CSS. This skill currently covers
architecture (BEM + controlled CSS Nesting) and minimal HTML markup (avoiding
layout-only wrapper elements). Additional sections may be added over time.

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
