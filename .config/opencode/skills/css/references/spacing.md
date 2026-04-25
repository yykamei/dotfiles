# Spacing (padding / margin / gap)

> Loaded by the `css` skill. See `../SKILL.md` for the overview and the
> decision checklist.

Spacing in a component architecture follows a clear division of
responsibility:

- **Padding** belongs to the component itself — its internal breathing room.
- **Margin** (external spacing between components) belongs to the parent
  layout, not to the component.
- **`gap`** is the primary mechanism for the parent to distribute spacing
  between its children.

## Padding — Internal Space of a Component

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

## Margin — Do Not Apply to a Block

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

### Exception

For page-specific Blocks that are not intended for reuse (e.g., a one-off hero
section), margin may be acceptable when the overhead of an additional layout
wrapper outweighs the benefit. Even in these cases, prefer parent-controlled
spacing when practical.

## Component Spacing — Responsibility of the Parent Layout

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

> **Note on the architecture examples**: `architecture.md` shows
> `.card + .card { margin-top: 16px; }` as a "flat top-level"
> alternative to a nested sibling combinator. That example demonstrates
> _nesting rules_, not spacing best practice. From a spacing
> perspective, replacing the adjacent-sibling margin with a parent
> `gap` is preferred.

## Cross-Axis Stretching — Side Effect of Layout Containers

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

## Fallback — When `gap` Is Not Available

`gap` requires a Flex or Grid formatting context. When the parent uses
`display: block` (normal flow), or when non-uniform spacing is needed between
specific children, alternative approaches are necessary.

### Normal Flow (Block Layout)

When the parent is a block-level container and converting it to Flex or Grid is
not justified, the parent can apply margin to its children via a direct-child
selector. The key principle remains: the _parent_ dictates the spacing, not the
child Block itself.

```css
.prose > * + * {
  margin-block-start: 1em;
}
```

### Non-uniform Spacing

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

## Decision Checklist

Before adding spacing to a component, answer these questions:

1. Is this spacing _inside_ the component's visual boundary? → Use
   **padding** on the Block.
2. Is this spacing _between_ sibling components? → Use **`gap`** on the
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
