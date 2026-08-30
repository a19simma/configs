# Errors

Sources: [TypeScript Handbook — Narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html), [MDN Error](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error), [typescript-eslint `use-unknown-in-catch-callback-variable`](https://typescript-eslint.io/rules/use-unknown-in-catch-callback-variable/).

## The axis: handled or reported

Every failure is one of two things, and the answer decides the mechanism.

| | Caller can do something about it | Nobody can, at runtime |
| --- | --- | --- |
| Examples | Validation failed, not found, conflict, rate limited, payment declined | Null deref, bad invariant, unreachable branch, config missing at boot |
| Mechanism | **Typed result value** in the signature | **`throw`** |
| Visible in type | Yes | No |

`throw` is invisible to the type system. TypeScript has no checked exceptions, so a thrown domain error is a contract that only exists in a doc comment. That is why expected failures are values.

## Expected failure: a result union

```ts
export type Result<T, E> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: E };

export const ok = <T>(value: T): Result<T, never> => ({ ok: true, value });
export const err = <E>(error: E): Result<never, E> => ({ ok: false, error });
```

That is the whole implementation. **Rule:** hand-write it in one internal module. Do not add `neverthrow`, `fp-ts`, `effect`, or `purify-ts` to get it — see `packages.md`. A result type is twelve lines; a functional-effect framework is a second language in your codebase.

The error side is a discriminated union per domain, not a string:

```ts
export type CheckoutError =
  | { readonly kind: "out_of_stock"; readonly sku: Sku }
  | { readonly kind: "payment_declined"; readonly reason: DeclineReason }
  | { readonly kind: "address_invalid"; readonly field: keyof Address };

async function checkout(cart: Cart): Promise<Result<Order, CheckoutError>>;
```

At the call site, `switch` on `kind` and close with `assertNever`. Adding a failure mode becomes a compile error at every site that must react to it — which is the entire point, and what a bare `Error` subclass cannot give you.

**Never `Result<T, string>`.** A string is not a case analysis; it is a log line that escaped.

## Unexpected failure: throw an Error subclass

```ts
export class ConfigError extends Error {
  override readonly name = "ConfigError";
  constructor(message: string, options?: { cause?: unknown }) {
    super(message, options);
  }
}
```

- Always extend `Error`. Throwing a string or object literal loses the stack.
- Always set `name`. It is what appears in logs.
- Always pass `{ cause }` when re-throwing. It is the standard chaining mechanism; do not invent a `.originalError` property.
- Message states what failed and with what input, without a trailing period, and never includes a secret.

## `catch` gives you `unknown`

```ts
// smell: e is not an Error, and TypeScript will not stop you here without the flag
try { ... } catch (e) { logger.error(e.message); }

// idiomatic
try {
  ...
} catch (e: unknown) {
  if (e instanceof ConfigError) return err({ kind: "bad_config", detail: e.message });
  throw e;                       // not ours — let it go up
}
```

**Rule:** `useUnknownInCatchVariables` is on (it is part of `strict`). Every `catch` either narrows and handles, or re-throws. A `catch` that swallows is a defect; a `catch` that logs and continues with corrupt state is a worse one.

Never catch to convert an unexpected failure into a result value. Bugs must reach the top.

## Boundaries

Three places do the conversion, and only these three:

| Boundary | Job |
| --- | --- |
| Parsing external input | `unknown` → typed value or a `Result` with a field-level error |
| Calling a throwing library | Wrap once, narrow the thrown value, return a `Result` in your own error union |
| Top of the process (request handler, CLI `main`, job runner) | Catch everything left, log with the cause chain, map to a status code or exit code |

Below those, no `try` blocks in domain code. If a domain function needs one, a boundary is missing.

## What not to do

| Anti-pattern | Why |
| --- | --- |
| `throw` for validation failures | Invisible in the signature; forces `try` in the caller for an expected outcome |
| Exception used for control flow | Slow, untyped, and hides the branch from every reader |
| `catch (e) { return null }` | Deletes the reason. The caller now has two nulls with different meanings |
| Error message carrying structured data for the caller to regex | Put the data in a field on the error object |
| `Promise` rejection with a non-Error | Same stack loss as `throw "oops"`, plus it defeats `instanceof` |
| One `AppError` class with a `code: string` field | A union of codes with no per-case payload and no exhaustiveness. Use the discriminated union |
