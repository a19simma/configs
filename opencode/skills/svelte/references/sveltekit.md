# SvelteKit

Sources: [Routing](https://svelte.dev/docs/kit/routing), [Loading data](https://svelte.dev/docs/kit/load), [Form actions](https://svelte.dev/docs/kit/form-actions), [Server-only modules](https://svelte.dev/docs/kit/server-only-modules), [Errors](https://svelte.dev/docs/kit/errors).

## The file table

| File | Runs | Job |
| --- | --- | --- |
| `+page.svelte` | Client + SSR | The page |
| `+page.ts` | "both on the server and in the browser" | Universal load |
| `+page.server.ts` | "always run on the server" | Server load, form actions |
| `+layout.svelte` / `+layout.ts` / `+layout.server.ts` | As above | Shared shell and data |
| `+server.ts` | Server | JSON/HTTP endpoints |
| `+error.svelte` | Client + SSR | Error boundary for the subtree |
| `hooks.server.ts` | Server | Auth, request-scoped `locals`, header handling |

## The boundary is the whole design

> A server `load` function "must return data that can be serialized" — JSON-compatible values plus `BigInt`, `Date`, `Map`, `Set`, `RegExp`, and promises. A universal `load` function "can return an object containing any values, including things like custom classes and component constructors."
> — [SvelteKit docs](https://svelte.dev/docs/kit/load)

**Rule:** default to `+page.server.ts`. Reach for `+page.ts` only when you need the return value to carry something unserialisable, or the data genuinely must be fetched from the browser.

| Put it in server load | Put it in universal load |
| --- | --- |
| Anything touching the database | Data derived from an already-loaded value |
| Anything reading a secret or `$env/static/private` | A component constructor chosen at runtime |
| Anything a user must not see the mechanics of | A call to a public API where the round trip through our server is waste |

`$lib/server/*` and `$env/*/private` cannot be imported into client code — SvelteKit fails the build. That is a guardrail, not a suggestion: put every credentialed client behind `$lib/server/` and the compiler enforces the boundary for you.

## Load functions

```ts
// +page.server.ts
import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ params, locals, depends }) => {
  const order = await locals.orders.byId(orderId(params.id));
  if (!order) error(404, "Order not found");
  return {
    order,
    // streamed: the page renders before this settles
    recommendations: getRecommendations(order.id),
  };
};
```

- Always type with the generated `./$types`. Never hand-write the argument type.
- Pure. No writes to stores or globals — see `state.md`.
- Use the `fetch` from the event, not the global one. It forwards cookies, resolves relative URLs, and lets SSR-fetched responses be inlined into the page instead of re-fetched on hydration.
- Return a promise, unawaited, to stream slow non-critical data. Await only what the page cannot render without.
- Declare dependencies with `depends()` and refresh with `invalidate()`. `invalidateAll()` is a blunt instrument; use it when you mean it.
- Parent data comes from `await parent()`, and it serialises the loads — do not call it before the work that could run in parallel.

## Mutations: form actions

**Rule:** every mutation is a form action or a remote function. Not `fetch` inside `onclick`.

```ts
// +page.server.ts
export const actions = {
  cancel: async ({ request, locals }) => {
    const data = await request.formData();
    const parsed = v.safeParse(CancelSchema, Object.fromEntries(data));
    if (!parsed.success) return fail(400, { errors: v.flatten(parsed.issues).nested });

    const result = await locals.orders.cancel(parsed.output.id);
    if (!result.ok) return fail(409, { error: result.error.kind });

    redirect(303, "/orders");
  },
} satisfies Actions;
```

```svelte
<form method="POST" action="?/cancel" use:enhance>
  <input type="hidden" name="id" value={order.id} />
  <button>Cancel order</button>
</form>
```

- The form works with JavaScript disabled, and `use:enhance` upgrades it in place. This is why the pattern exists — you get the resilient version for free instead of building it twice.
- `fail(status, data)` for validation failures; it returns the data to the page. `error()` for genuinely exceptional conditions; it renders `+error.svelte`.
- Never return sensitive data from an action; it is serialised into the page.
- `redirect(303, ...)` after a successful mutation. 303 specifically, so the browser follows with GET.
- Validate on the server, always, even where the client already did. The client check is a courtesy; the server check is the rule.

## Endpoints

`+server.ts` is for non-page consumers: webhooks, a public JSON API, file downloads. Do not build a `+server.ts` to feed your own page — that is what `load` is for, and going through HTTP adds a round trip and loses type safety.

```ts
export const POST: RequestHandler = async ({ request }) => {
  const body = v.parse(WebhookSchema, await request.json());
  await handle(body);
  return json({ ok: true }, { status: 202 });
};
```

## Auth and `locals`

`hooks.server.ts` resolves the session once and puts request-scoped capabilities on `event.locals`, typed in `app.d.ts`. Every `load` and action reads from there. This is the request-scoped alternative to a module singleton, and the reason `locals` exists.

**Rule:** authorisation is checked in `+page.server.ts` / actions / `+server.ts`, never only in a layout and never only in the UI. A layout guard does not protect the endpoints beneath it, and a hidden button is not access control.

## Errors

- `error(404, "message")` for expected HTTP failures — it is a control-flow throw SvelteKit understands.
- Unexpected throws reach `handleError` in `hooks.server.ts`. Log with the cause chain there; return a message safe to render.
- `+error.svelte` at the right level of the tree, so a failed panel does not blank the whole app.

## Performance

- `export const prerender = true` on anything static. It is the cheapest possible page.
- `export const ssr = false` only for a genuinely client-only route; it costs you first paint and indexability.
- `data-sveltekit-preload-data` on navigation-heavy areas.
- Stream slow, non-essential data rather than blocking the shell on it.
