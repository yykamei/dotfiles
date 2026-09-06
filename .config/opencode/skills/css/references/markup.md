# Minimal HTML Markup

> Loaded by the `css` skill. See `../SKILL.md` for the overview and the
> decision checklist.

## Contents

- Guidelines
- Minimal Classes
- Examples
- Decision Checklist

Do not add HTML elements solely to satisfy a CSS layout model. If a layout
requires wrapper elements that carry no semantic meaning and no accessibility
role, consider whether a different CSS approach can eliminate them.

## Guidelines

1. **Prefer CSS Grid when it removes layout-only wrappers.** If a
   two-dimensional layout (rows _and_ columns) would require extra `<div>`s
   under Flexbox to group items into rows, use Grid instead — it can lay out
   children in both dimensions from a single container.
2. **Keep Flexbox for genuinely one-dimensional cases.** A row of buttons, an
   inline icon-and-label pair, or a simple horizontal navigation — these are
   naturally one-dimensional. Flexbox handles them with less ceremony than Grid.
   Do not force Grid where it adds verbosity without reducing markup.
3. **Test each `<div>` for purpose.** Before adding an element, ask: _"Does this
   element exist for semantics or accessibility, or only for layout?"_ If the
   answer is only layout, look for a CSS-only alternative first.

## Minimal Classes

A `class` attribute is a naming decision and a coupling point — add one
only when it earns its keep. With `@scope` (see
[`cascade.md`](cascade.md)), most elements need no class at all: style
them through their semantic position inside a scoped block.

Reserve `class` for:

- the scope root (`class="card"`),
- variants (`class="alert danger"`),
- runtime states with no platform attribute (`.is-active`, `.is-sticky`;
  when the state exists as an attribute, select the attribute instead),
- hooks required by JavaScript or tests,
- reusable layout traits (`class="no-stretch"`).

Prefer the platform's own state attributes over invented classes:

```html
<!-- State already lives in the markup — style it, don't rename it -->
<a href="/" aria-current="page">Home</a>
<button aria-expanded="true" aria-controls="menu">Menu</button>
<button disabled>Save</button>
```

```css
@scope (.nav-bar) {
  a[aria-current="page"] {
    font-weight: bold;
  }
}
```

## Examples

### Bad — Flex with row wrappers

The outer container uses `flex-direction: column`, and each row is itself a Flex
container — all to achieve a consistent three-column card layout:

```html
<div class="card-grid">
  <div class="card-grid-row">
    <!-- layout-only wrapper -->
    <div class="card">…</div>
    <div class="card">…</div>
    <div class="card">…</div>
  </div>
  <div class="card-grid-row">
    <!-- layout-only wrapper -->
    <div class="card">…</div>
    <div class="card">…</div>
    <div class="card">…</div>
  </div>
</div>
```

```css
.card-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.card-grid-row {
  display: flex;
  gap: 16px;
}

.card {
  flex: 1;
}
```

### Good — Grid without wrappers

Grid eliminates the row wrappers entirely:

```html
<div class="card-grid">
  <div class="card">…</div>
  <div class="card">…</div>
  <div class="card">…</div>
  <div class="card">…</div>
  <div class="card">…</div>
  <div class="card">…</div>
</div>
```

```css
.card-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
```

### Good — Flexbox for a one-dimensional layout

A horizontal navigation is genuinely one-dimensional. Flexbox is the natural
fit, and `@scope` means the links need no part classes — the scope and the
platform's attributes say everything:

```html
<nav class="nav-bar">
  <a href="/" aria-current="page">Home</a>
  <a href="/about">About</a>
  <a href="/contact">Contact</a>
</nav>
```

```css
@scope (.nav-bar) {
  :scope {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  a {
    color: inherit;
    text-decoration: none;
  }
}
```

When a component adapts to where it is placed rather than to the viewport,
prefer container queries over extra wrappers or viewport breakpoints — see
[`responsive-tokens.md`](responsive-tokens.md#container-queries-over-media-queries-for-components).

## Decision Checklist

Before adding an HTML element, consider:

1. Does this element carry semantic meaning or an accessibility role?
2. Does this element aid assistive technology (e.g., landmark, grouping)?
3. Is there no CSS-only alternative that achieves the same layout?

If the element serves layout alone, look for a CSS-only alternative
(e.g., switching from nested Flex containers to Grid, or using container
queries) before adding it.

Before adding a `class` attribute, consider:

1. Could an element selector inside a `@scope` block reach this element
   instead?
2. Is the state already available as an attribute (`aria-current`,
   `aria-expanded`, `disabled`, `hidden`)?
3. Is this a scope root, variant, state, script hook, or reusable
   trait? If not, it does not need a name.
