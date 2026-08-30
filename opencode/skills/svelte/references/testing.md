# Testing Svelte

Sources: [Svelte — testing](https://svelte.dev/docs/svelte/testing), [Vitest browser mode](https://vitest.dev/guide/browser/), [Playwright](https://playwright.dev/docs/intro), [Testing Library principles](https://testing-library.com/docs/guiding-principles/).

Read `typescript/references/testing.md` first. This file covers only what is specific to components.

## Push logic out of components

The cheapest component test is the one you did not write. Business rules belong in `.ts` or `.svelte.ts` modules and are tested with no DOM at all — faster, clearer failures, no rendering to debug.

**Rule:** a component test asserts on what a user can see and do. If a test needs to reach inside for internal state, the logic is in the wrong place.

## Runes outside components

Rune-based logic in `.svelte.ts` is testable directly, but effects and deriveds need a reactive context. Name the test file `*.svelte.test.ts` so the Svelte plugin processes it, and wrap in `$effect.root` when the code under test uses effects:

```ts
// cart.svelte.test.ts
import { flushSync } from "svelte";
import { describe, expect, it } from "vitest";
import { createCartState } from "./cart.svelte";

describe("createCartState", () => {
  it("totals the items", () => {
    const cleanup = $effect.root(() => {
      const cart = createCartState();
      cart.add(anItem({ price: cents(500) }));
      cart.add(anItem({ price: cents(250) }));
      flushSync();
      expect(cart.total).toEqual(cents(750));
    });
    cleanup();
  });
});
```

`flushSync()` before asserting on anything an effect produced. Effects run in a microtask, so a synchronous assertion after a state change sees the old value.

## Component tests

Render, interact through the same affordances a user has, assert on output.

```ts
it("emits the selected id", async () => {
  const onselect = vi.fn();
  render(OrderRow, { props: { order: anOrder({ id: orderId("ord_1") }), onselect } });

  await userEvent.click(screen.getByRole("button", { name: "Select" }));

  expect(onselect).toHaveBeenCalledWith(orderId("ord_1"));
});
```

- Query by role, label, and text. `data-testid` only for genuinely unnamed elements; never CSS classes.
- `userEvent` over raw `fireEvent` — it produces the full event sequence a real interaction does, including focus changes.
- Assert on rendered output and on callback props. Never on internal state.
- Real browser mode (Vitest browser mode or Playwright component tests) for anything involving layout, focus management, or scroll. jsdom will happily lie about all three.

## SvelteKit

| Unit | How |
| --- | --- |
| `load` function | Plain async function. Call it with a fake event object; assert on the returned data |
| Form action | Same. Build a `FormData`, call the action, assert on `fail`/`redirect`/return value |
| `+server.ts` handler | Call it with a `Request`, assert on the `Response` |
| Route as a whole | Playwright |

These are all ordinary functions. Testing them does not need a running server, and a test that boots one to check a `load` is testing SvelteKit rather than your code.

Mock at your own boundary — the `locals` interface — not at `fetch`. An in-memory `OrderStore` passed through `locals` is type-checked; a mocked `fetch` is a string comparison.

## End-to-end

Playwright, on the critical paths only: sign-in, the money path, the destructive action. Everything else is cheaper and more precise one layer down.

Test the no-JavaScript path for form actions at least once. Progressive enhancement that nobody verified is a claim, not a feature.

## What not to test

- Svelte's own reactivity. It works.
- Snapshot tests of rendered markup. They fail on every restyle and assert nothing about behaviour.
- That a component "renders without crashing". This is the weakest possible assertion and it crowds out a real one.
