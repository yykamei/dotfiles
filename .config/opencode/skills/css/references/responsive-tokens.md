# Responsive Design and Design Tokens

> Loaded by the `css` skill. See `../SKILL.md` for the overview and the
> decision checklist.

## Contents

- Container Queries over Media Queries for Components
- Media Range Syntax and Container Units
- Design Tokens with Custom Properties
- Color, Sizing, and Logical Properties
- `:has()` for Parent-Aware Styling
- Decision Checklist

## Container Queries over Media Queries for Components

`@media` responds to the viewport; `@container` responds to the component's
own container. Reusable components belong in containers — the same markup
placed in a sidebar and in a main column should adapt to each placement.

```css
.card-wrap {
  container-type: inline-size;
  container-name: card;
}

/* A container cannot query itself — the query targets descendants
   of the named container. */
@scope (.card) {
  :scope {
    display: grid;
    gap: 12px;
  }

  @container card (inline-size >= 420px) {
    :scope {
      grid-template-columns: 160px 1fr;
    }

    h3 {
      font-size: 1.25rem;
    }
  }
}
```

Name containers explicitly (`container-name`) when nesting runs two or more
levels deep, so queries resolve against the intended ancestor. Keep
`@media` for page-level breakpoints and `@container` for component-level
ones. Both nest naturally inside the rule they affect.

## Media Range Syntax and Container Units

Prefer range syntax for readability:

```css
@media (width >= 768px) {
  .container {
    padding: 32px;
  }
}

@scope (.card) {
  @container card (400px <= inline-size <= 800px) {
    h3 {
      font-size: 1.125rem;
    }
  }
}
```

Container-relative units (`cqi`, `cqb`, `cqw`, `cqh`, `cqmin`, `cqmax`)
size details against the container instead of the viewport:

```css
@scope (.card) {
  h3 {
    font-size: clamp(1rem, 4cqi + 0.5rem, 1.5rem);
  }
}
```

## Design Tokens with Custom Properties

Colors, spacing, typography, and radii shared across components belong in
tokens — CSS custom properties declared once, consumed everywhere:

```css
:root {
  --color-text: oklch(0.25 0.02 250);
  --color-surface: oklch(0.98 0.005 250);
  --space-2: 8px;
  --space-4: 16px;
  --radius-md: 8px;
  --font-body: "Inter", system-ui, sans-serif;
}

@scope (.card) {
  :scope {
    background: var(--color-surface);
    padding: var(--space-4);
    border-radius: var(--radius-md);
    font-family: var(--font-body);
  }
}
```

Unlike preprocessor variables, custom properties are runtime values:
themes switch without rebuilding, and `@container` / `:has()` variants can
rebind them per placement or state.

## Color, Sizing, and Logical Properties

- **Color**: prefer OKLCH and `color-mix()` for perceptually uniform
  palettes and runtime variants. Hex remains fine for one-off values.
- **Sizing**: prefer `clamp()` for fluid type and spacing that adapts
  without breakpoints.
- **Logical properties**: prefer `margin-block`, `padding-inline`,
  `inset-block-start` over physical `margin-top`, `padding-left`, `top`
  so layouts adapt to writing modes automatically.

```css
@scope (.alert) {
  :scope {
    padding-block: 12px;
    padding-inline: var(--space-4);
    background: color-mix(in oklch, var(--color-surface) 80%, transparent);
  }

  h2 {
    font-size: clamp(1rem, 2cqi + 0.75rem, 1.25rem);
  }
}
```

## `:has()` for Parent-Aware Styling

`:has()` replaces JavaScript class toggling for parent-based styles. Nest
it inside the component it affects:

```css
.nav-bar {
  &:has([aria-expanded="true"]) {
    background: rgb(0 0 0 / 0.9);
  }
}

.card {
  &:has(img) {
    gap: 0;
  }
}
```

Pseudo-elements inside `:has()` are invalid — keep arguments to selectors
the component already owns. Avoid nesting `:has()` inside `:has()`; it is
valid but expensive and hard to read. Bare arguments like
`[aria-expanded="true"]` match any descendant — narrow them with an
element type (`button[aria-expanded="true"]`) or the child combinator
(`& > button[aria-expanded="true"]`) when the component hosts other
components.

## Decision Checklist

1. Is this breakpoint about the viewport (page) or the placement
   (component)? → Page: `@media`; component: `@container` with a named
   container.
2. Is this value reused across components? → Tokenize it as a custom
   property on `:root` or the relevant scope.
3. Is this color part of a palette or theme? → Use OKLCH /
   `color-mix()` over hardcoded hex.
4. Does this spacing or type need fluidity? → Use `clamp()`; reserve
   breakpoints for structural changes.
5. Is this a physical direction (`top`, `left`, `margin-right`)? → Prefer
   the logical equivalent (`inset-block-start`, `inset-inline-start`,
   `margin-inline-end`).
6. Am I toggling a parent class from JavaScript just for styling? → Use
   `:has()` on the parent instead.
