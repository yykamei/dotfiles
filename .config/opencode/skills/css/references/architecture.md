# CSS Architecture (Scope, Classes, Composition)

> Loaded by the `css` skill. See `../SKILL.md` for the overview and the
> decision checklist.

## Contents

- What Gets a Class
- Component Boundaries with `@scope`
- Component Composition
- CSS Nesting Rules
- Examples
- Complete Component Example
- Decision Checklist

`@scope` provides containment, so a component needs far fewer class names
than BEM-era conventions imply. A class is an API: name it only when it
marks a boundary (scope root), a variant, a state, or a hook — style
everything else with element selectors inside the scope. Manage
specificity with `@layer` and `:where()`, not with naming discipline
(see [`cascade.md`](cascade.md)).

## What Gets a Class

Pick one naming style per project and stay consistent. Kebab-case
(`.search-form`, `.no-stretch`) is recommended. A class must be one of:

1. **Scope root** — the component's boundary: `.card`, `.alert`,
   `.nav-bar`.
2. **Variant** — size, emphasis, or theme, combined with the base class
   in HTML: `class="alert danger"`. Keep the variant selector
   single-class for low specificity; pairing happens in HTML, not in the
   selector.
3. **State** — runtime booleans as `.is-*` (`.is-active`, `.is-sticky`)
   or, preferably, the platform's own state attributes:
   `[aria-expanded="true"]`, `[aria-current="page"]`, `[disabled]`. If
   the platform already carries the state, do not duplicate it in a
   class.
4. **Script hook** — a stable handle for JavaScript or tests.
5. **Reusable layout trait** — independent of any parent context:
   `.no-stretch`.

**Parts do not get classes.** Inside the scope, the element itself is
identifying enough:

```html
<!-- Before: every part named -->
<article class="card">
  <img class="card-media" src="…" alt="" />
  <h3 class="card-title">Card title</h3>
  <p>…</p>
</article>

<!-- After: only the boundary carries a class -->
<article class="card">
  <img src="…" alt="" />
  <h3>Card title</h3>
  <p>…</p>
</article>
```

```css
@scope (.card) {
  :scope {
    padding: var(--space-4);
    background: var(--color-surface);
  }

  img {
    width: 100%;
    aspect-ratio: 16 / 9;
    object-fit: cover;
  }

  h3 {
    font-weight: 600;
  }
}
```

Add a part class only when:

- element selectors would be ambiguous — e.g. two `<span>` elements with
  different roles in the same subtree;
- the part must be styled from outside the scope;
- JavaScript must target the part directly.

Even then, keep the name unprefixed (`.price`, never `.card-price`): the
context comes from the scope, and the prefix carries no information.

Prohibited: chained names that mirror the DOM (`.card-header-title`) and
parent-coupled names (`.button-in-toolbar`). A chain that deep signals a
component to split; a parent-coupled name cannot move with the
component.

The reusable layout trait (category 5) attaches to the component's own
class, independent of any parent:

```html
<div class="toolbar">
  <button class="button no-stretch">Save</button>
</div>
```

## Component Boundaries with `@scope`

One `@scope` block per component, wrapped in the `components` layer.
Variants of the root are compound selectors inside the same block:

```css
@layer components {
  @scope (.alert) {
    :scope {
      padding: 16px;
      border: 1px solid currentColor;
    }

    &.danger {
      color: var(--color-danger);
    }

    &.success {
      color: var(--color-success);
    }

    > svg {
      margin-inline-end: 8px;
    }
  }
}
```

```html
<div class="alert danger">…</div>
```

Bare selectors inside `@scope` add zero root specificity (`> svg` is
0-0-1), and `&` behaves the same — see
[`cascade.md`](cascade.md#specificity-inside-scope) for the specificity
table.

When the component hosts other components (article bodies, prose, cards
with embedded media), declare the lower bound so its selectors never
reach into the children's internals:

```css
@scope (.article-body) to (figure) {
  img {
    border-radius: 4px;
  }
}
```

Without `to (figure)`, that `img` rule would also restyle images inside
any embedded `<figure>`.

## Component Composition

A component may be placed inside another component. This is composition,
not ownership: the nested component stays independent and must not be
renamed with a parent-specific class merely to satisfy the parent's
layout.

Bad — duplicating a reusable button under a parent-specific name:

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

Good — the child keeps its own boundary plus a reusable trait:

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
children. It should not reach into a child component's internals — the
donut limit (`to (...)`) on the parent's scope guarantees its element
selectors stop at the child's boundary, provided the limit matches the
child component's boundary element (see [`cascade.md`](cascade.md)).
For flex/grid sizing details, see
[`spacing.md`](spacing.md#cross-axis-stretching--side-effect-of-layout-containers).

## CSS Nesting Rules

Native nesting is Baseline widely available. With the component boundary
drawn by `@scope`, nesting's job shrinks to states, pseudo-elements, and
at-rules — both inside a scope block and on standalone root rules.

### Recommended

1. **Pseudo-classes** — `&:hover`, `&:focus-visible`, `&:first-child`,
   `&:has(...)`, including compounds such as `&:hover::after`.
2. **Pseudo-elements** — `&::before`, `&::after`, `&::placeholder`.
3. **At-rule queries** — `@media`, `@container`, `@supports` nested
   inside a rule or a scope block. An at-rule may contain further nested
   selectors.
4. **Attribute/state selectors** — `&[aria-expanded="true"]`,
   `&:disabled`.
5. **Shallow structural selectors** — inside a scope block, one level of
   `img`, `> p`, `h3` for the component's own parts. Use `&` only to
   combine, e.g. `&.danger` on the root.

Depth guideline: **parts inside a scope sit at one level by default**;
nest a second level only for pseudo-classes or at-rules on a part. A
third level is a signal to split the component or reconsider the
boundary.

### Not allowed

Only the following stays prohibited:

1. **Concatenation** — In pure CSS, `&` is a reference to the parent
   selector, not string substitution. Writing `&-danger` inside `.alert`
   does **not** produce `.alert-danger` — the browser cannot build new
   class names from parts, silently producing dead rules. Always write
   the full class name (nested or top-level). See
   [MDN: Concatenation is not possible](https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Nesting/Using#concatenation_is_not_possible).

### Specificity note

Inside `@scope`, bare selectors and `&` contribute zero root specificity
— `img` stays 0-0-1 (see
[`cascade.md`](cascade.md#specificity-inside-scope)). Outside `@scope`, a
nested rule desugars roughly to `:is(<parent>) <child>` and carries the
specificity of its most specific parent selector. Avoid nesting inside a
comma-separated parent list that mixes IDs and classes — every nested
rule inherits ID-level specificity. Keep parent selector lists uniform,
or split them into separate blocks. When a default must stay easy to
override, write it with `:where()` (see [`cascade.md`](cascade.md)).

## Examples

### Naming a part class vs. using the scope

Ask for a class only when the scope cannot say it. Two `<span>` elements
with different roles are ambiguous for element selectors — that is the
moment a class earns its name:

```html
<div class="plan">
  <p><span class="price">$9</span> <span>per month</span></p>
</div>
```

```css
@scope (.plan) {
  .price {
    font-weight: 700;
  }
}
```

Note the name is still unprefixed — `.price`, not `.plan-price`.

### Concatenation still does not work

In pure CSS, `&` is a reference to the parent selector — not a string
substitution mechanism.

Bad — suffix concatenation:

```css
@scope (.alert) {
  /* Does NOT produce .alert-danger in pure CSS */
  &-danger {
    color: red;
  }
}
```

Good — full variant names:

```css
@scope (.alert) {
  :scope {
    padding: 16px;
    border: 1px solid currentColor;
  }

  &.danger {
    color: red;
  }

  &.success {
    color: green;
  }

  > svg {
    margin-inline-end: 8px;
  }
}
```

### Shallow structural selectors

Good — one level for the component's own parts:

```css
@scope (.card) {
  h3 {
    font-weight: 600;
  }

  > img {
    border-radius: 8px;
  }
}
```

A descendant selector (`h3`) matches at any depth inside the scope; the
child combinator (`> img`) restricts to direct children. When the
component hosts other components, bound the subtree with
`@scope (.card) to (...)` — see [`cascade.md`](cascade.md).

Avoid — deep nesting; split or flatten instead:

```css
.page {
  .card {
    .card-body {
      .card-title {
        /* too deep — and the chain mirrors the DOM */
      }
    }
  }
}
```

### Sibling relationships

Acceptable for one-off relationships:

```css
.card + .card {
  /* acceptable when no parent layout owns the stack;
     otherwise prefer gap on the parent — see spacing.md */
  margin-block-start: 16px;
}
```

### Pseudo-class and pseudo-element nesting

Good:

```css
@scope (.button) {
  :scope {
    background: blue;
    color: white;
  }

  :scope:hover {
    background: darkblue;
  }

  :scope:focus-visible {
    outline: 2px solid orange;
  }

  :scope::after {
    content: "";
    display: block;
  }

  :scope:hover::after {
    opacity: 1;
  }
}

/* Parent-aware styling without JavaScript — a top-level rule so the
   ancestor relationship stays explicit */
.card:has(.button:hover) {
  border-color: currentColor;
}
```

### At-rule nesting

Good:

```css
@scope (.container) {
  :scope {
    padding: 16px;
  }

  @media (width >= 768px) {
    :scope {
      padding: 32px;
    }

    h3 {
      font-size: 1.25rem;
    }
  }

  @container (inline-size >= 400px) {
    :scope {
      padding: 24px;
    }
  }

  @supports (display: grid) {
    :scope {
      display: grid;
    }
  }
}
```

## Complete Component Example

Parts, states, and variants are all expressed by the scope, element
selectors, attributes, and the single `.is-sticky` variant — no part
classes:

```css
@layer components {
  @scope (.nav-bar) {
    :scope {
      display: flex;
      align-items: center;
      gap: var(--space-4);
      padding: 8px 16px;
    }

    &.is-sticky {
      position: sticky;
      inset-block-start: 0;
    }

    @media (width >= 1024px) {
      :scope {
        padding: 16px 32px;
      }
    }

    a {
      color: inherit;
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }

      &[aria-current="page"] {
        font-weight: bold;
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
  }
}
```

```html
<nav class="nav-bar is-sticky">
  <a href="/" aria-current="page">Home</a>
  <a href="/about">About</a>
  <a href="/contact">Contact</a>
</nav>
```

## Decision Checklist

Before adding a class, ask:

1. Is this the component's boundary? → Make it the `@scope` root class.
2. Is this a variant, state, script hook, or reusable layout trait? →
   Class it (state preferably via the platform's attributes, not a new
   class).
3. Is this a part? → Style it with an element selector inside the scope;
   add a class only when element selectors would be ambiguous, the part
   is styled from outside, or JavaScript targets it.
4. Does the name include parent context (`.toolbar-button`,
   `.card-header-title`)? → Drop the prefix — the scope is the context —
   or split the component if the chain mirrors the DOM.

Before nesting, ask:

1. Is it concatenation (`&-suffix`)? → Never; write the full name.
2. Is the depth beyond pseudo-classes/at-rules on a part? → Split the
   component or flatten.
3. Does the selector style another component's internals? → Move the
   boundary: `@scope (parent) to (child)`.
4. Should proximity rather than specificity decide the winner (e.g.
   nested themes)? → `@scope` — see [`cascade.md`](cascade.md).
