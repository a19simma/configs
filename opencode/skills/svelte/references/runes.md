# Runes

Sources: [What are runes?](https://svelte.dev/docs/svelte/what-are-runes), [`$state`](https://svelte.dev/docs/svelte/$state), [`$derived`](https://svelte.dev/docs/svelte/$derived), [`$effect`](https://svelte.dev/docs/svelte/$effect), [`$props`](https://svelte.dev/docs/svelte/$props).

## What they are

> "Runes are symbols that you use in `.svelte` and `.svelte.js` / `.svelte.ts` files to control the Svelte compiler."
> — [svelte.dev](https://svelte.dev/docs/svelte/what-are-runes)

They differ from functions in three ways the docs spell out:

1. "You don't need to import them — they are part of the language"
2. "They're not values — you can't assign them to a variable or pass them as arguments to a function"
3. "Just like JavaScript keywords, they are only valid in certain positions"

Consequence that catches people: you cannot pass reactive state as an argument and keep it reactive. Pass a getter, or a whole object whose properties are read at use time.

```ts
// smell: count is read once, at call time. The value is dead on arrival.
track(count);

// idiomatic: the reader is deferred
track(() => count);
```

## The decision table

| You need | Rune |
| --- | --- |
| A value that changes | `$state` |
| A value computed from other values | `$derived` / `$derived.by` |
| A component's inputs | `$props` |
| A prop the child may write back | `$bindable` |
| To reach outside Svelte (canvas, third-party lib, subscription, analytics) | `$effect` |
| To debug what changed | `$inspect` |

If the answer looks like `$effect`, read the next two sections before writing it.

## `$state`

```svelte
<script lang="ts">
  let count = $state(0);
  let user = $state<User | undefined>(undefined);
  let items = $state<Item[]>([]);
</script>
```

Deeply reactive: `items.push(x)` and `user.name = "x"` both work, because `$state` proxies objects and arrays. That proxying costs something on large structures and changes identity, which matters when passing to a non-Svelte library.

- `$state.raw` for large immutable data (a parsed dataset, a big config): no proxy, so reassignment is the only way to update it. Cheaper, and honest about how it is used.
- `$state.snapshot(x)` before handing state to anything outside Svelte — `structuredClone`, `JSON.stringify`, a canvas library, an RPC call. Passing a proxy across that line produces confusing failures.
- Class fields work: `class Cart { items = $state<Item[]>([]); }`. This is the sanctioned way to bundle state with its operations.

## `$derived` — the default for anything computed

```svelte
<script lang="ts">
  let items = $state<Item[]>([]);
  let subtotal = $derived(items.reduce((n, i) => n + i.price * i.qty, 0));
  let total = $derived.by(() => {
    const tax = Math.round(subtotal * TAX_RATE);
    return subtotal + tax + shippingFor(subtotal);
  });
</script>
```

`$derived(expr)` for an expression; `$derived.by(() => { ... })` when it needs statements. They are the same thing.

Derived values are lazy and cached: not recomputed until read, not re-run when the inputs settle back to the same value. That is strictly better than an effect writing to state, which runs on every change whether or not anyone is looking.

## `$effect` — the escape hatch, not the tool

> "Effects are functions that run when state updates, and can be used for things like calling third-party libraries, drawing on `<canvas>` elements, or making network requests."
> — [svelte.dev](https://svelte.dev/docs/svelte/$effect)

Mechanics worth knowing:

- Runs after mount, then in a microtask after state changes. "Re-runs are batched […] and happen after any DOM updates have been applied."
- Tracks "which pieces of state (and derived state) are accessed (unless accessed inside `untrack`)".
- **Only synchronous reads are tracked.** Anything read after an `await`, or inside a `setTimeout`, is not a dependency. This is the single most common source of "my effect doesn't re-run".
- Return a cleanup function; it runs before each re-run and on destroy. An effect that subscribes without returning an unsubscribe is a leak.
- `$effect.pre` "runs code _before_ the DOM updates" — for measuring or preserving scroll position.

### The rule

**Rule:** an `$effect` that assigns to `$state` is a defect until proven otherwise. Every one needs a comment explaining why `$derived` cannot express it.

```svelte
<!-- smell -->
<script lang="ts">
  let doubled = $state(0);
  $effect(() => { doubled = count * 2; });
</script>

<!-- idiomatic -->
<script lang="ts">
  let doubled = $derived(count * 2);
</script>
```

The smell version is worse in four ways: it renders once with a stale `0`, it runs after paint, it cannot be lazy, and it opens the door to a cycle.

### Two values that must track each other

Not an effect. Use function bindings, so each side has one owner:

```svelte
<input bind:value={() => spend, (v) => { spend = Math.min(v, MAX); }} />
```

### When you genuinely must write state in an effect

Wrap the read that would cause a cycle in `untrack`, and say why in a comment. An effect that re-triggers itself is an infinite loop that Svelte will report at runtime, not compile time.

## `$props` and `$bindable`

```svelte
<script lang="ts">
  interface Props {
    user: User;
    variant?: "primary" | "ghost";
    onselect?: (id: UserId) => void;
    children?: Snippet;
  }
  let { user, variant = "primary", onselect, children }: Props = $props();
</script>
```

- Destructure once, with defaults inline, typed by an explicit `interface Props`.
- Props are read-only. Assigning to one is a compile error in runes mode, and correctly so.
- Callback props (`onselect`) replace `createEventDispatcher`, which is gone. Name them `onthing`, lowercase, matching the DOM convention.
- `$props.id()` for a unique id to wire `<label for>` to an input across SSR and hydration.
- `$bindable` only where two-way flow is genuinely the simplest model — form field wrappers, a controlled input. Everywhere else, data down and callbacks up. See `components.md`.

## `.svelte.ts` modules

Runes work in `.svelte.ts` files, which is how state escapes a single component without a store. This is also where the server-safety rule bites hardest: a module-scope `let x = $state()` is shared by every request on the server. Read `state.md` before writing one.

## Migration reference

| Svelte 4 | Svelte 5 |
| --- | --- |
| `export let x` | `let { x } = $props()` |
| `$: y = x * 2` | `let y = $derived(x * 2)` |
| `$: sideEffect(x)` | `$effect(() => sideEffect(x))` — and check it should not be `$derived` |
| `on:click={fn}` | `onclick={fn}` |
| `createEventDispatcher` | Callback props |
| `writable`/`readable` store | `$state` in a `.svelte.ts` module, or context |
| `$store` auto-subscription | Direct property access on the state object |
| `<slot />` | `{@render children()}` with a `Snippet` prop |
| `<slot name="x" />` | A named snippet prop |
| `svelte:component` | A component-valued variable rendered directly |
