---
disable-model-invocation: true
name: svelte-review
description: Review a Svelte or SvelteKit diff against the svelte skill: server/client boundary, state placement, effect audit, component surface, styling, tests. Reports findings only, makes no edits.
---

# Svelte Review

Reviews Svelte 5 and SvelteKit against the conventions in the `svelte` skill. **That skill is the rule source — this one is the procedure.** Supersedes the generic `code-review` skill for Svelte changes; do not run both. TypeScript inside `.ts` files is `typescript-review`'s job — run that too when a diff touches both, and do not duplicate its findings here.

## Procedure

### 0. Scope

Determine the diff: `git diff <base>...HEAD`, a named branch/PR, or specified files. Review only changed lines plus enough surrounding context to judge them.

### 1. Machine pass (before reading anything)

```
svelte-check --fail-on-warnings
tsc --noEmit
eslint .
```
Run tests via the `test` subagent, not directly. `svelte-check` warnings include the a11y rules — they are merge blockers, not noise. Anything a tool found is not a human finding.

### 2. The `$effect` grep — do this second, always

```
rg '\$effect' -- '*.svelte' '*.svelte.ts'
```

**Every `$effect` in the diff is a finding until justified.** For each one, decide which it is:

| Shape | Verdict |
| --- | --- |
| Assigns to `$state` that could be `$derived` | **MAJOR**. Rewrite as `$derived` / `$derived.by`. |
| Synchronises two pieces of state | **MAJOR**. One is derived from the other, or they are one value. |
| Reads a value after an `await` and expects it tracked | **BLOCKER**. Only synchronous reads are tracked; the dependency is silently missing. |
| Writes to something it also reads | **BLOCKER**. Infinite loop or a swallowed update. |
| Talks to a non-Svelte thing (canvas, media element, third-party widget, analytics) | Legitimate. Check it returns a teardown function. |
| Missing cleanup on a subscription, timer, or listener | **MAJOR**. |
| Reachable on the server | **BLOCKER**. `$effect` does not run during SSR; the logic is missing there. |

### 3. Server/client boundary — blocking

- A secret, database client, or `$env/static/private` import reachable from client code → **BLOCKER**. It belongs behind `$lib/server/`.
- Module-scope mutable state in a `.svelte.ts` file that a server load or hook touches → **BLOCKER**. That is one variable per process, shared across users. Factory + `setContext` with a `Symbol` key.
- `+page.ts` where `+page.server.ts` belongs — anything touching the database, a credential, or logic a user must not see → **BLOCKER**.
- A `load` function that writes to a store, a global, or a module variable → **BLOCKER**. `load` is pure.
- Authorisation checked only in a layout or only in the UI → **BLOCKER**. A layout guard does not protect the endpoints beneath it.
- An action returning sensitive data → **BLOCKER**. It is serialised into the page.
- Form input reaching a mutation without server-side parsing → **BLOCKER**, even where the client already validated.

### 4. Rule passes

Load one reference file per pass.

| Pass | Reference | Looking for |
| --- | --- | --- |
| State | `svelte/references/state.md` | state placed higher on the ladder than it needs to be; a `.svelte.ts` module singleton; context without a `Symbol` key or a typed accessor; state that belongs in the URL held in memory; a global state manager |
| Runes | `svelte/references/runes.md` | a rune passed as a value or destructured out of reactivity; `$state` where `$derived` fits; a deep `$state` proxy over data that is never mutated (`$state.raw`); a proxy handed to a non-Svelte API without `$state.snapshot`; a Svelte 4 store surviving where a rune belongs |
| Components | `svelte/references/components.md` | props without an explicit `interface Props`; `$bindable` without a justification comment; a slot instead of a snippet; an untyped `Snippet`; an unkeyed `{#each}` over identified items; `on:click` (Svelte 4 form); `use:action` where `{@attach}` belongs; `createEventDispatcher`; a loading/error/success render that is not a discriminated union |
| SvelteKit | `svelte/references/sveltekit.md` | a hand-written `load` argument type instead of `./$types`; the global `fetch` inside `load`; `await parent()` blocking work that could run in parallel; `invalidateAll()` where `depends`/`invalidate` fits; a mutation via `fetch` in `onclick` instead of a form action; a missing `use:enhance`; a redirect that is not 303; a `+server.ts` feeding our own page |
| Styling | `svelte/references/styling.md` | `:global` without a stated reason; a CSS-in-JS or preprocessor import; a class-string helper package; a style that duplicates a Tailwind utility |
| Testing | `svelte/references/testing.md` | logic tested through the component that should have been extracted; a query by CSS class or test id where role/label/text works; `fireEvent` where `userEvent` fits; `flushSync()` missing after a state change; a `load`/action tested through the browser instead of as a function; mocking `fetch` instead of `locals` |

### 5. Verify before reporting

1. **Cite the rule.** File + rule name from the `svelte` skill. No citation → not a finding.
2. **Concrete failure.** Which user, which sequence, what goes wrong. For a server-state finding, name the two concurrent requests.
3. **Read the surrounding code.** An `$effect` with a comment naming the external system it drives is doing its job.

## Severity

| Level | Meaning |
| --- | --- |
| **BLOCKER** | Any boundary violation from step 3; a server-shared mutable module; an `$effect` reading after `await` or writing what it reads; unvalidated form input; a `svelte-check` or a11y failure |
| **MAJOR** | `$effect` where `$derived` belongs; missing effect cleanup; state on the wrong rung; a slot instead of a snippet; new behaviour with no test |
| **MINOR** | Prop surface, naming, an unkeyed each over stable data, an avoidable `:global` |
| **NOTE** | Suggestion with a trade-off; explicitly optional |

## Output

Findings only, most severe first, `file.svelte:line` for each:

```
BLOCKER  src/lib/cart.svelte.ts:3  Module-scope $state shared across all server requests
  Rule:    state.md, "server safety"; module state is one variable per process
  Failure: Alice adds an item; Bob's SSR render includes it
  Fix:     export function createCart() { ... } and setContext(CART, createCart())
```

End with a one-line verdict: `PASS`, `PASS WITH MINORS`, or `BLOCKED (n blockers)`.

## Constraints

- **Read only.** Suggested changes are minimal snippets with locations.
- Do not restate what `svelte-check` already printed.
- No praise section. Silence is the pass signal.
