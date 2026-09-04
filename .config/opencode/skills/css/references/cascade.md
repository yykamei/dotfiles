# Cascade Control (`@layer`, `:is()` / `:where()`, `@scope`)

> Loaded by the `css` skill. See `../SKILL.md` for the overview and the
> decision checklist.

## Contents

- Cascade Layers
- `:is()` and `:where()`
- `@scope`
- Decision Guide

Specificity and priority are managed explicitly. Naming conventions help
readability; they do not control which rule wins.

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

## `@scope`

`@scope` limits rules to a DOM subtree and adds proximity to the cascade:
when two scoped rules with equal specificity target the same element, the
closer scope root wins. Proximity is evaluated after importance, layers,
and specificity, but before source order.

```css
@scope (.card) {
  :scope {
    background: white;
    border-radius: 8px;
  }

  .card-title {
    font-weight: 600;
  }

  .card-media {
    width: 100%;
    aspect-ratio: 16 / 9;
    object-fit: cover;
  }
}
```

An optional lower boundary stops styles from leaking into nested
components:

```css
@scope (.article-body) to (figure) {
  img {
    border-radius: 4px;
  }
}
```

Images inside nested `figure` elements are excluded.

### Prefer `@scope` over nesting when proximity matters

Nested descendant selectors resolve by specificity; `@scope` resolves by
closeness. For nestable themes, `@scope` gives the expected result where
nesting does not:

```css
@scope (.dark) {
  .invert {
    color-scheme: light;
  }
}

@scope (.light) {
  .invert {
    color-scheme: dark;
  }
}
```

The `.invert` closest to its theme root wins, regardless of source order.

### Support note

`@scope` is Baseline Newly Available (Chrome 118+, Safari 17.4+, Firefox
146+). Older browsers ignore the whole `@scope` block, so pair essential
rules with a plain-selector fallback when legacy support matters.
`@supports` cannot reliably detect at-rules cross-browser; write the
fallback as ordinary CSS alongside the scoped block.

## Decision Guide

| Situation                                        | Tool                                    |
| ------------------------------------------------ | --------------------------------------- |
| Control which stylesheet group wins              | `@layer` ordering                       |
| Keep resets and defaults easy to override        | `:where()`                              |
| Prevent styles leaking into child components     | `@scope` with a `to (...)` boundary     |
| Nested themes without specificity tricks         | `@scope` proximity                      |
| Co-locate responsive and base styles              | Native nesting + `@media` / `@container` |
| Override layered styles without `!important`     | A later layer, not specificity          |
| Protect critical resets                          | `!important` in the first-declared layer |

Avoid: leaving styles unlayered in a layered codebase, using
`!important` to win specificity battles, or nesting deeper than 2 levels
when `@scope` expresses the boundary better.
