# Cascade Control (`@scope`, `@layer`, `:is()` / `:where()`)

> Loaded by the `css` skill. See `../SKILL.md` for the overview and the
> decision checklist.

## Contents

- `@scope`
- Cascade Layers
- `:is()` and `:where()`
- Decision Guide

Specificity and priority are managed explicitly with `@scope`, `@layer`,
and `:where()` — not with naming conventions. Class names aid readability;
they do not control which rule wins.

## `@scope`

`@scope` is the primary containment tool. It limits rules to a DOM
subtree, keeps their specificity low, and adds a proximity rule to the
cascade. It replaces what BEM-style part naming used to solve — style
leakage, name collisions, specificity inflation — while the markup needs
fewer classes.

```css
@scope (.card) {
  :scope {
    /* the scope root itself */
    padding: var(--space-4);
    background: var(--color-surface);
  }

  /* parts — plain element selectors, no part classes needed */
  h3 {
    font-weight: 600;
  }

  img {
    width: 100%;
    aspect-ratio: 16 / 9;
    object-fit: cover;
  }
}
```

### Donut scopes — the `to (...)` limit

An optional `to (limit)` clause defines the lower boundary. The upper
bound is inclusive; the lower bound is exclusive:

```css
@scope (.article-body) to (figure) {
  img {
    border-radius: 4px;
  }
}
```

Images inside nested `figure` elements are excluded. Use the limit
whenever the component hosts other components — it guarantees the
component's element selectors never restyle a child component's
internals (the limit must match the child component's boundary element).
Attach `> *` to the limit to push the exclusive boundary one level down:
`to (figure > *)` puts the `figure` elements themselves back in scope,
while their children become the new limit. Similarly, `> *` on the root
makes the upper bound exclusive. Root and limit may both be selector
lists: `@scope (.light, .dark) to (figure)`.

### Specificity inside `@scope`

Bare selectors and `&` inside the block behave as if `:where(:scope)`
were prepended — the scope root contributes **zero** specificity:

| Selector inside `@scope (.card)` | Specificity | Matches               |
| -------------------------------- | ----------- | --------------------- |
| `img` / `& img`                  | 0-0-1       | descendant images     |
| `&.featured`                     | 0-1-0       | root with `.featured` |
| `:scope`                         | 0-1-0       | the root              |
| `:scope img`                     | 0-1-1       | descendant images     |

A scoped `img` rule (0-0-1) is easier to override than a flat
`.card-title` (0-1-0) — containment does not cost specificity. Use
`:scope` to style the root itself, or to raise precedence deliberately.
Where possible prefer bare selectors: engine handling of `&` inside
`@scope` has varied across releases.

### Scoping proximity

When two scoped rules with equal specificity target the same element, the
rule whose scope root is **closer in the DOM** wins. Proximity is
evaluated after importance, layers, and specificity, but before source
order:

```css
@scope (.light) {
  p {
    color: black;
  }
}

@scope (.dark) {
  p {
    color: white;
  }
}
```

A `p` inside `.dark` inside `.light` renders white — one hop from the
`.dark` root, two from `.light`. Nested themes resolve correctly without
specificity tricks, regardless of source order.

### Inline `<style>` blocks

`@scope` inside a `<style>` element omits the prelude and scopes to the
`<style>` element's parent — handy for self-contained HTML components:

```html
<section class="article-body">
  <style>
    @scope to (figure) {
      img {
        border-radius: 4px;
      }
    }
  </style>
  …
</section>
```

### Inheritance caveat

`@scope` limits selector matching, not inheritance. Inherited properties
(`color`, `font-family`, …) flow past the scope limit into nested
subtrees.

### Support note

`@scope` is Baseline Newly Available (March 2026; Chrome 118+, Safari
17.4+, Firefox 146+). This skill targets current browsers. Older
browsers ignore an entire `@scope` block, and `@supports` cannot
reliably detect at-rules cross-browser.

## Cascade Layers

`@layer` assigns each rule to a named priority zone. Rules in a later layer
beat rules in an earlier layer regardless of selector specificity or source
order.

Declare the order once at the entry point:

```css
@layer reset, base, components, utilities;
```

Priority (lowest to highest): `reset` < `base` < `components` <
`utilities`. A single class in `utilities` overrides a more specific
selector in `components` — no `!important` needed.

```css
@layer reset {
  *,
  *::before,
  *::after {
    box-sizing: border-box;
  }
}

@layer components {
  .card {
    padding: 16px;
  }
}

@layer utilities {
  .text-center {
    text-align: center;
  }
}
```

### Unlayered styles win — be intentional

Styles outside any `@layer` beat all layered styles. Keep all styles
layered in a layered codebase; reserve unlayered styles for deliberate
page-specific overrides.

Third-party CSS should be imported into a layer so it cannot accidentally
override component styles:

```css
@import url("vendor.css") layer(vendor);

@layer reset, vendor, base, components, utilities;
```

Keep the order declaration in one place — layer priority is fixed by its
first declaration, so update the single entry-point list rather than
re-declaring partial orders per file.

### `!important` inverts layer order

With `!important`, the first-declared layer wins instead of the last. This
lets early layers (e.g. resets guarding accessibility essentials) protect
critical declarations. Avoid relying on this; prefer plain layer ordering.

### Nesting inside layers

`@scope` and component rules nest naturally inside `@layer` blocks:

```css
@layer components {
  @scope (.card) {
    :scope {
      background: var(--surface);
    }
  }
}
```

## `:is()` and `:where()`

Use `:is()` to group selectors without repetition; it takes the
specificity of its most specific argument. Use `:where()` for the same
grouping with zero added specificity — ideal for resets, base styles, and
easily-overridable defaults.

```css
/* Specificity of the most specific argument */
:is(h1, h2, h3) {
  text-wrap: balance;
}

/* Zero specificity — easy to override later */
:where(ul, ol) {
  padding-inline-start: 1.5em;
}
```

Prefer `:where()` for cross-cutting defaults so component rules override
them without specificity tricks.

## Decision Guide

| Situation                                        | Tool                                     |
| ------------------------------------------------ | ---------------------------------------- |
| Contain a component's styles                     | `@scope (root)`                          |
| Style a component's parts                        | Element selectors inside `@scope` first — part classes only when justified (see `architecture.md`) |
| Keep styles out of nested child components       | `@scope ... to (limit)` donut boundary   |
| Nested themes without specificity tricks         | `@scope` proximity                       |
| Control which stylesheet group wins              | `@layer` ordering                        |
| Keep resets and defaults easy to override        | `:where()`                               |
| Co-locate responsive and base styles             | Native nesting + `@media` / `@container` |
| Override layered styles without `!important`     | A later layer, not specificity           |
| Protect critical resets                          | `!important` in the first-declared layer |

Avoid: inventing part classes where an element selector inside `@scope`
suffices, leaving styles unlayered in a layered codebase, using
`!important` to win specificity battles, or nesting deeper than 2 levels
when `@scope` expresses the boundary better.
