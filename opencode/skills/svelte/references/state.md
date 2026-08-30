# State Placement

Sources: [SvelteKit — state management](https://svelte.dev/docs/kit/state-management), [Svelte — context](https://svelte.dev/docs/svelte/context), [`$state`](https://svelte.dev/docs/svelte/$state).

## The ladder

Put state at the lowest rung that works. Every rung up costs traceability.

| Rung | Mechanism | Use when |
| --- | --- | --- |
| 1 | `$state` in the component | Only this component cares |
| 2 | Props down, callbacks up | A parent and its children care |
| 3 | A `.svelte.ts` module, instantiated per use | Several unrelated components share a concern, client-only |
| 4 | `setContext` / `getContext` | Shared down a subtree, and must be per-request-safe |
| 5 | The URL | It should survive reload, be shareable, and go in history |
| 6 | Server (`load` return, database) | It outlives the tab |

Rung 5 is underused. Filters, tabs, pagination, and search terms belong in the query string, where the back button works for free and no state synchronisation code exists at all.

## The server-safety rule

This is the one that causes incidents.

> "Browsers are _stateful_ — state is stored in memory as the user interacts with the application. Servers, on the other hand, are _stateless_"
> — [SvelteKit docs](https://svelte.dev/docs/kit/state-management)

A module-level variable on the server is shared by every concurrent request in that process. The docs' own example: if Alice submits sensitive information and Bob requests the page afterwards, Bob gets Alice's data.

```ts
// BANNED: user.svelte.ts — one `user` for the whole server process
export const user = $state<{ current: User | undefined }>({ current: undefined });
```

**Rule:** no module-scope mutable state that is reachable during SSR. Two safe shapes:

```ts
// 1. A factory, instantiated per component tree and put in context
export function createCartState() {
  let items = $state<Item[]>([]);
  return {
    get items() { return items; },
    get total() { return items.reduce((n, i) => n + i.price, 0); },
    add(item: Item) { items = [...items, item]; },
  };
}
```

```ts
// 2. Genuinely client-only state, guarded, for things that cannot exist on a server
import { browser } from "$app/environment";
```

Note the getter in shape 1. Runes are not values, so you cannot return `items` and keep it reactive — you return an object whose getters read it at access time.

## Context is the safe global

```ts
// cart.svelte.ts
import { getContext, setContext } from "svelte";
const KEY = Symbol("cart");

export function provideCart() { return setContext(KEY, createCartState()); }
export function useCart(): ReturnType<typeof createCartState> { return getContext(KEY); }
```

Called in `+layout.svelte`, consumed anywhere below. State is created per component tree, which means per request on the server — that is the whole point, and why context exists rather than a module singleton.

- The key is a `Symbol`, not a string, so it cannot collide.
- `setContext` only during component initialisation, never in a handler or an effect.
- Wrap `getContext` in a typed `useCart()` helper. Raw `getContext` returns `unknown` and invites an `as`.

## `load` functions are pure

The docs are direct: do not write to stores or global state inside `load`, even when it seems convenient. Return the data.

```ts
// smell: on the server this writes into shared state; on the client it races navigation
export const load: PageLoad = async ({ fetch }) => {
  currentUser.set(await getUser(fetch));   // no
};

// idiomatic
export const load: PageLoad = async ({ fetch }) => ({ user: await getUser(fetch) });
```

The returned data reaches the component as `data`, is per-request by construction, and re-runs correctly on navigation.

## Reading page state

`page` from `$app/state` is the sanctioned way to read the current URL, params, and merged `data`. It is request-safe. Do not build a parallel copy of routing state in a module.

## No global state manager

Runes plus context cover what Redux, Zustand, MobX, XState, and Pinia are for, without a second mental model or a devtools dependency. All of them are banned; see `typescript/references/packages.md`.

If the argument for one is "the state machine is complex", model the machine as a discriminated union and a transition function in a plain `.ts` module. It will be smaller, testable without a DOM, and readable by someone who has not learned the library.

## Derived state does not get stored

The most common reactivity bug is a `$state` that should have been a `$derived`, kept in sync by an `$effect`. If a value can be computed from other state, it is not state. See `runes.md`.
