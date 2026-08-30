# Styling

Sources: [Svelte — scoped styles](https://svelte.dev/docs/svelte/scoped-styles), [`class` attribute](https://svelte.dev/docs/svelte/class), [Tailwind CSS v4](https://tailwindcss.com/docs/styling-with-utility-classes).

## Two mechanisms, and only two

| Mechanism | For |
| --- | --- |
| Tailwind utilities in the markup | Layout, spacing, colour, typography — the ordinary 95% |
| A scoped `<style>` block in the component | Things utilities express badly: keyframes, complex selectors, `::part`, container queries with awkward thresholds |

Everything else is banned: CSS-in-JS, Sass, styled-components, and any component kit shipping its own theming layer. See `typescript/references/packages.md`.

## Scoping

Svelte adds a hash class to the component's elements, so a `<style>` block cannot leak. It also removes unused selectors at compile time and warns about them — that warning is usually correct and means the selector is dead.

`:global(...)` needs a comment saying why. The legitimate cases are narrow: styling markup from `{@html}`, or reaching into a third-party widget's DOM. Both are boundaries; label them.

The single app-level stylesheet is the only global CSS. It holds the Tailwind import, the theme tokens, and the base element rules. Nothing else.

## Tailwind v4

Config lives in CSS, not a JavaScript file:

```css
/* app.css */
@import "tailwindcss";

@theme {
  --color-brand-500: oklch(0.62 0.19 259);
  --font-display: "Inter Variable", ui-sans-serif, system-ui, sans-serif;
  --radius-card: 0.75rem;
}
```

**Rule:** every colour, spacing step, radius, and font in the app comes from a theme token. A raw `#3b82f6` or `mt-[13px]` in a component is a design-system leak — arbitrary values are for genuine one-offs, and each one is a small decision nobody else can find later.

## Conditional classes

Svelte takes objects and arrays in `class`, so no helper package is needed:

```svelte
<button
  class={[
    "rounded-card px-4 py-2 font-medium transition",
    variant === "primary" && "bg-brand-500 text-white hover:bg-brand-600",
    variant === "ghost" && "bg-transparent text-brand-500 hover:bg-brand-50",
    disabled && "cursor-not-allowed opacity-50",
  ]}
>
```

`clsx` and `classnames` are banned for this reason — the framework already does it.

## Long class lists

A long utility list is not automatically a problem; a *repeated* one is. When the same list appears three times, the fix is a component or a snippet, not a CSS class that hides the styling somewhere else.

Order utilities consistently — layout, box, typography, colour, state — so diffs stay readable.

## Dark mode and motion

- Dark mode through tokens, so components never carry `dark:` variants for colours the theme already knows.
- Respect `prefers-reduced-motion` on anything that moves more than a few pixels. Svelte's transitions do not do this for you.

## Transitions

`transition:`, `in:`, `out:`, and `animate:` are part of the framework and preferred over hand-written CSS animation for element enter/exit — they handle the removal timing that CSS alone cannot.

`animate:flip` with a keyed `{#each}` is the correct tool for reordering lists. Doing it by hand is a large amount of code that will be wrong.
