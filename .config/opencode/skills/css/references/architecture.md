# CSS Architecture (Components + Nesting)

> Loaded by the `css` skill. See `../SKILL.md` for the overview and the
> decision checklist.

## Contents

- Class Names
- Component Composition
- CSS Nesting Rules
- Examples
- Complete Component Example
- Decision Checklist

This skill prescribes no naming convention. Use descriptive class names,
keep components independent when they nest inside each other, and manage
specificity explicitly with cascade layers and `:where()` (see
[`cascade.md`](cascade.md)). Native CSS nesting groups related styles —
keep it shallow.

## Class Names

Pick one naming style per project and stay consistent. Kebab-case
(`.search-form`, `.nav-link`) is recommended for plain CSS because there
is no build-time scoping to disambiguate names.

- **Components** get their own class: `.card`, `.button`, `.nav-bar`.
- **Parts** get a descriptive flat name: `.card-title`, `.nav-link`.
  Avoid chained names that mirror the DOM tree (`.card-header-title`) —
  split the component or use composition instead.
- **Variants** (state, size, emphasis) are extra classes combined with the
  base class in HTML: `class="alert alert-danger"`. For states that toggle
  at runtime or with placement — active, expanded, sticky — `.is-*`
  classes (`.is-active`, `.is-sticky`) or attribute selectors
  (`[aria-expanded="true"]`) read better than inventing a new variant
  name per state.
- Keep names searchable and reusable. A name coupled to one parent
  (`.button-in-toolbar`) cannot move with the component — prefer a name
  describing the reusable trait (`.no-stretch`).

Variant selectors stay single-class for low specificity; pairing with the
base happens in HTML, not in the selector. Reach for a compound selector
(`.nav-link.is-active`) only when the style must never apply without its
base.

```html
<button class="button">Save</button>
<div class="alert alert-danger">…</div>
<a class="nav-link is-active" href="/">Home</a>
```

## Component Composition

A component may be placed inside another component. This is composition,
not ownership: the nested component stays independent and must not be
renamed with a parent-specific class merely to satisfy the parent's
layout.

Avoid duplicating a reusable button under a parent-specific name:

```html
<div class="toolbar">
  <button class="toolbar-button">Save</button>
</div>
```

```css
.toolbar-button {
  /* duplicates .button just to work around .toolbar layout */
}
```

Prefer keeping the child as its own component with a reusable variant:

```html
<div class="toolbar">
  <button class="button no-stretch">Save</button>
</div>
```

```css
.button.no-stretch {
  align-self: flex-start;
}
```

This variant opts out of cross-axis stretch when the button participates
as a flex/grid child: width in a column flex layout, height in a row flex
layout, and the relevant axis in grid.

If every child in the parent layout needs the same alignment, fix the
parent layout instead of adding variants to each child:

```css
.toolbar {
  display: flex;
  align-items: center;
}
```

The parent may own placement, ordering, tracks, and spacing between its
children. It should not reach into a child component's internals. For
flex/grid sizing details, see
[`spacing.md`](spacing.md#cross-axis-stretching--side-effect-of-layout-containers).

## CSS Nesting Rules

Native nesting is Baseline widely available. Use it to group a component's
own styles; every nested rule still participates in the cascade with
`:is()`-equivalent specificity (see Specificity note below).

### Recommended

Nesting is recommended for:

1. **Pseudo-classes** — `&:hover`, `&:focus-visible`, `&:first-child`,
   `&:has(...)`, including compounds such as `&:hover::after`.
2. **Pseudo-elements** — `&::before`, `&::after`, `&::placeholder`.
3. **At-rule queries** — `@media`, `@container`, `@supports` nested inside
   a rule. An at-rule may contain further nested selectors.
4. **Attribute selectors** — `&[aria-expanded="true"]`, `&[disabled]`.
5. **Shallow child / descendant selectors** — one level of `.child`,
   `& > .child`, or `& .child` for the component's own direct parts,
   written with class selectors. Sibling selectors (`& + .sibling`,
   `& ~ .sibling`) are acceptable for one-off relationships such as
   stacked siblings; prefer parent `gap` for spacing (see `spacing.md`).

Depth guideline: **1 level, 2 at most**. A third level is a signal to
split the component, flatten the selectors, or move the boundary to
`@scope` (see [`cascade.md`](cascade.md)).

### Not allowed

Only the following stays prohibited:

1. **Concatenation** — In pure CSS, `&` is a reference to the parent
   selector, not string substitution. Writing `&-danger` inside `.alert`
   does **not** produce `.alert-danger` — the browser cannot build new
   class names from parts, silently producing dead rules. Always write
   the full class name (nested or top-level). See
   [MDN: Concatenation is not possible](https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Nesting/Using#concatenation_is_not_possible).

### Specificity note

A nested rule desugars roughly to `:is(<parent>) <child>`, so it carries
the specificity of its most specific parent selector. In particular, avoid
nesting inside a comma-separated parent list that mixes IDs and classes —
every nested rule inherits ID-level specificity. Keep parent selector lists
uniform, or split them into separate blocks. When a default must stay easy
to override, write it with `:where()` (see [`cascade.md`](cascade.md)).

## Examples

### Concatenation still does not work

In pure CSS, `&` is a reference to the parent selector — not a string
substitution mechanism.

Bad — suffix concatenation:

```css
.alert {
  padding: 16px;

  /* Does NOT produce .alert-danger in pure CSS */
  &-danger {
    color: red;
  }
}
```

Good — full class names, nested or flat:

```css
.alert {
  padding: 16px;
  border: 1px solid currentColor;
}

.alert-danger {
  color: red;
}

.alert-success {
  color: green;
}

.alert-icon {
  margin-inline-end: 8px;
}
```

Nesting the full part name inside its component is also fine and often
reads better for small components:

```css
.alert {
  padding: 16px;

  .alert-icon {
    margin-inline-end: 8px;
  }
}
```

### Shallow child nesting

Good — one level for the component's own parts:

```css
.card {
  padding: 16px;

  .card-body {
    padding: 16px;
  }

  & > .card-media {
    border-radius: 8px;
  }
}
```

A bare `.card-body` matches any descendant, including one inside a nested
`.card`. When only direct children are meant, prefer `& > .card-body`;
when a whole subtree with a boundary is meant, prefer
`@scope (.card) to (...)` — see [`cascade.md`](cascade.md).

Avoid — deeper than two levels; split or flatten instead:

```css
.page {
  .card {
    .card-body {
      .card-title {
        /* too deep — hard to read, hard to override */
      }
    }
  }
}
```

### Sibling relationships

Acceptable for one-off relationships:

```css
.card {
  & + .card {
    /* acceptable when no parent layout owns the stack;
       otherwise prefer gap on the parent — see spacing.md */
    margin-block-start: 16px;
  }
}
```

### Pseudo-class and pseudo-element nesting

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

/* Parent-aware styling without JavaScript — a top-level rule so the
   ancestor relationship stays explicit */
.card:has(.button:hover) {
  border-color: currentColor;
}
```

### Attribute selector nesting

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

### At-rule nesting

Good:

```css
.container {
  padding: 16px;

  @media (width >= 768px) {
    padding: 32px;

    /* At-rules may contain further nested selectors */
    .container-title {
      font-size: 1.25rem;
    }
  }

  @container (inline-size >= 400px) {
    padding: 24px;
  }

  @supports (display: grid) {
    display: grid;
  }
}
```

## Complete Component Example

Small parts may nest one level while larger sub-components stay flat —
both are acceptable; the example mixes them deliberately to show the two
equivalent styles:

```css
@layer components {
  .nav-bar {
    display: flex;
    align-items: center;
    padding: 8px 16px;

    /* Shallow child: the component's own part */
    .nav-logo {
      flex-shrink: 0;
    }

    /* Variant combined with the base class in HTML */
    &.is-sticky {
      position: sticky;
      inset-block-start: 0;
    }

    /* Parent-aware state */
    &:has(.nav-menu[aria-expanded="true"]) {
      background: rgb(0 0 0 / 0.9);
    }

    /* At-rule query */
    @media (width >= 1024px) {
      padding: 16px 32px;
    }
  }

  .nav-menu {
    display: none;

    &[aria-expanded="true"] {
      display: flex;
    }

    @media (width >= 1024px) {
      display: flex;
    }
  }

  .nav-link {
    color: inherit;
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }

    &::after {
      content: "";
      display: block;
      height: 2px;
      background: currentColor;
      scale: 0 1;
      transition: scale 0.2s ease;
    }

    &:hover::after {
      scale: 1 1;
    }
  }

  .nav-link.is-active {
    font-weight: bold;
  }
}
```

## Decision Checklist

Before naming a class, ask:

1. Is this class for an independent, reusable component? → Give it its
   own name (`.card`).
2. Is this class for a part owned by the component? → Use a descriptive
   flat name (`.card-title`, not a chained `.card-header-title`).
3. Is this a state, size, or emphasis variant? → Use an extra class
   combined with the base (`.alert alert-danger`); runtime boolean states
   read better as `.is-*` or attribute selectors.
4. Does the name include the parent context only to work around layout?
   → Fix the parent layout or rename toward a reusable trait.

Before nesting, ask:

1. Is it concatenation (`&-suffix`)? → Never nest it in pure CSS; write
   the full class name instead.
2. Is the depth 1–2 levels for states, direct children, or variants? → If
   deeper, split the component or flatten.
3. Is the resulting selector still easy to read, search for, and
   override? → If specificity (`:is()` effect) or overmatching is a
   concern, flatten or use `:where()` / `@scope`.
4. Should proximity rather than specificity decide the winner (e.g.
   nested themes)? → Prefer `@scope` — see
   [`cascade.md`](cascade.md).
