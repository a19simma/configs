# Component Design

Sources: [Svelte: snippets](https://svelte.dev/docs/svelte/snippet), [`$props`](https://svelte.dev/docs/svelte/$props), [`$bindable`](https://svelte.dev/docs/svelte/$bindable), [basic markup](https://svelte.dev/docs/svelte/basic-markup).

## The surface is the props interface

Write it first. A component whose `interface Props` you cannot write in one sitting is doing more than one thing.

```svelte
<script lang="ts">
  import type { Snippet } from "svelte";

  interface Props {
    /** The order being summarised. */
    order: Order;
    /** Rendered in place of the default footer. */
    footer?: Snippet<[{ total: Cents }]>;
    variant?: "compact" | "full";
    oncancel?: (id: OrderId) => void;
  }

  let { order, footer, variant = "full", oncancel }: Props = $props();
</script>
```

- Explicit `interface Props`, always. Inline destructured types make the surface unreadable and give worse errors.
- Defaults live in the destructure, not in an `$effect` and not in the template.
- No `[key: string]: unknown` catch-all unless the component forwards to a DOM element, and then use `HTMLButtonAttributes` and `...rest` so the types are real.

## Data down, callbacks up

The default direction. A child receives values and reports events; the parent owns the state.

**Parent:**

```svelte
<OrderRow {order} oncancel={(id) => cancel(id)} />
```

`$bindable` inverts this, and is correct in one situation: the child *is* the control for that value. Examples are a form field wrapper, a custom input, and a dialog's own open state.

```svelte
<!-- @component Field wrapper. `value` is bindable because the value is what this component exists for. -->
<script lang="ts">
  interface Props { value: string; label: string }
  let { value = $bindable(), label }: Props = $props();
</script>
```

**Rule:** every `$bindable` needs a one-line justification in the component's `@component` doc or the prop's doc comment. See `docs.md`. Two-way binding across three levels of components is how state becomes impossible to trace.

## Snippets replace slots

Definition and use in one component:

```svelte
{#snippet row(item: Item)}
  <li class="flex justify-between"><span>{item.name}</span><span>{fmt(item.price)}</span></li>
{/snippet}

<ul>{#each items as item (item.id)}{@render row(item)}{/each}</ul>
```

Passed as props, they are typed.

**Parent:**

```svelte
<OrderSummary {order}>
  {#snippet footer({ total })}
    <strong>{fmt(total)}</strong>
  {/snippet}
</OrderSummary>
```

**Child:**

```svelte
{#if footer}{@render footer({ total })}{:else}<DefaultFooter {total} />{/if}
```

- `children` is the implicit snippet for content between the tags. Type it `Snippet` and render it with `{@render children?.()}`.
- Snippets are values, unlike runes: you can pass them around and store them.
- Prefer a snippet over a component when the fragment has no state of its own and is only used by its parent. It stays in one file and needs no props interface.

## Keyed each

```svelte
{#each items as item (item.id)}
  <Row {item} />
{/each}
```

**Rule:** every `{#each}` over anything that can reorder, filter, or be removed carries a key. Without one, Svelte reuses DOM nodes by index. Component state and input focus attach to the wrong row.

The key is a stable id. Never the index; never the object itself unless it is stable by identity.

## Component size and splitting

- Split when a chunk has its own state and its own name. Do not split to hit a line count.
- A component that takes twelve props is usually two components, or one that should take an object.
- Extract to a snippet before extracting to a component; a snippet is free and stays local.
- Logic that is not about rendering belongs in a `.svelte.ts` module or a plain `.ts` module, tested without a DOM.

## Events and the DOM

- `onclick`, `oninput`, `onsubmit` are plain attributes, no colon. Svelte 5 removed `on:`.
- Modifiers are gone. `onsubmit={(e) => { e.preventDefault(); ... }}`, written out.
- `{@attach fn}` for imperative DOM work (a tooltip library, an intersection observer). Prefer it over `use:action` (Svelte 5.29+): it takes the element, re-runs when state it reads changes, and may return a cleanup function.
- Never `document.querySelector` in a component. `bind:this` gives you the element with the right lifetime.

## Accessibility

Svelte warns on a11y problems at compile time, and `--fail-on-warnings` means those warnings block the merge. That is deliberate: they are the cheapest accessibility feedback available.

- Interactive things are `<button>` and `<a>`, not `<div onclick>`. The keyboard and screen-reader behaviour comes free.
- Every input has a `<label for>`; use `$props.id()` to generate the id.
- Fix the warning. `<!-- svelte-ignore -->` is banned; silence a warning the project accepts with `compilerOptions.warningFilter` in `svelte.config.js`.

## Loading and error states

Every component that renders remote data renders three states. Model them as a discriminated union (`typescript/references/types.md`), not as parallel booleans:

```svelte
{#if request.status === "loading"}
  <Spinner />
{:else if request.status === "error"}
  <ErrorMessage error={request.error} />
{:else}
  <Content data={request.data} />
{/if}
```

`{#await}` is fine for a promise that arrives as a prop, such as a streamed promise from a SvelteKit `load`.
