# Minimal HTML Markup

> Loaded by the `css` skill. See `../SKILL.md` for the overview and the
> decision checklist.

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

## Examples

### Bad — Flex with row wrappers

The outer container uses `flex-direction: column`, and each row is itself a Flex
container — all to achieve a consistent three-column card layout:

```html
<div class="cardGrid">
  <div class="cardGrid__row">
    <!-- layout-only wrapper -->
    <div class="card">…</div>
    <div class="card">…</div>
    <div class="card">…</div>
  </div>
  <div class="cardGrid__row">
    <!-- layout-only wrapper -->
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

### Good — Grid without wrappers

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

### Good — Flexbox for a one-dimensional layout

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

## Decision Checklist

Before adding an HTML element, every answer must be "yes":

1. Does this element carry semantic meaning or an accessibility role?
2. Does this element aid assistive technology (e.g., landmark, grouping)?
3. Is there no CSS-only alternative that achieves the same layout?

If any answer is "no", look for a CSS-only alternative (e.g., switching from
nested Flex containers to Grid) before adding the element.
