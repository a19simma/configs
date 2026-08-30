# Type Design

Sources: [TypeScript Handbook — Narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html), [Everyday Types](https://www.typescriptlang.org/docs/handbook/2/everyday-types.html), [TSConfig Reference](https://www.typescriptlang.org/tsconfig/).

## Start from the states, not the fields

The fields are the last step. Write down what the thing can *be*, then give each case exactly the data it carries.

```ts
// smell: 2^4 representable states, 3 of them real
interface Request {
  loading: boolean;
  data?: User;
  error?: Error;
  retryCount?: number;
}

// idiomatic: 3 states, each with its own payload
type Request =
  | { status: "loading" }
  | { status: "success"; data: User }
  | { status: "error"; error: RequestError; retryCount: number };
```

The discriminant is a string literal on a property every member shares. `switch` on it and the compiler narrows each branch; add a member and every non-exhaustive `switch` fails to compile if you close it with `assertNever`.

```ts
function assertNever(x: never): never {
  throw new Error(`unreachable: ${JSON.stringify(x)}`);
}
```

**Rule:** every `switch` over a discriminated union ends in `default: return assertNever(x)`. This is the single highest-value pattern in the language — it converts "add a case" from a runtime bug into a compile error.

## `unknown` at the boundary, never `any`

`any` disables checking and the disablement spreads through every value it touches. `unknown` disables *use* until you prove the shape, and the proof is where the runtime check belongs.

```ts
// smell
const user = (await res.json()) as User;

// idiomatic
const user = v.parse(UserSchema, await res.json());
```

Anything crossing a process boundary is `unknown`: HTTP bodies, `JSON.parse`, `localStorage`, `process.env`, message-channel payloads, third-party callbacks. `as User` on a fetch result is a lie the compiler will then propagate for you.

Type predicates are the hand-written alternative when a schema is overkill:

```ts
function isUser(v: unknown): v is User {
  return typeof v === "object" && v !== null && "id" in v && typeof v.id === "string";
}
```

The predicate body is unchecked — TypeScript trusts the `v is User` claim. That makes a wrong predicate strictly worse than a schema. Prefer the schema for anything with more than two fields.

## Branded types for values that share a runtime type

`string` is not an identifier. Two `string` parameters in either order compile fine and page someone at 3am.

```ts
declare const brand: unique symbol;
type Brand<T, B> = T & { readonly [brand]: B };

type UserId = Brand<string, "UserId">;
type OrderId = Brand<string, "OrderId">;

// the only way in is a checked constructor
function userId(raw: string): UserId {
  if (!/^usr_[0-9a-f]{16}$/.test(raw)) throw new TypeError(`bad user id: ${raw}`);
  return raw as UserId;
}
```

**Rule:** brand any string or number that has a validity rule — ids, emails, URLs, currency minor units, durations. The `as` inside the constructor is the one sanctioned assertion in the codebase, because it sits immediately after the check that makes it true.

## `interface` vs `type`

| Use | Which |
| --- | --- |
| Object shape that may be extended or implemented | `interface` |
| Union, intersection, tuple, mapped, conditional, function type | `type` |
| Public API of a library others augment | `interface` |

**Rule:** one house choice, applied consistently; do not mix both for object shapes in the same package. `interface` gives better error messages and supports declaration merging; `type` is the only option for everything that is not a plain object shape, so a `type`-only codebase is also coherent. Pick one, write it in the ESLint config (`@typescript-eslint/consistent-type-definitions`), stop discussing it.

## Readonly by default

```ts
function total(items: readonly LineItem[]): Cents { ... }
```

- `readonly T[]` in every parameter position that does not mutate. It documents intent and blocks accidental `push`.
- `readonly` on properties of anything shared across a boundary.
- `as const` on literal config objects and lookup tables; it gives you literal types and a frozen shape in one token.

`Readonly<T>` is shallow. For nested config, write the nesting readonly explicitly rather than reaching for a `DeepReadonly` helper.

## Inference is the default, annotation is the exception

Annotate:
- every exported function's parameters and return type — the signature is the contract, and inference makes it change silently
- empty containers (`const seen: Set<UserId> = new Set()`)
- anywhere inference produces `any` or a union you did not intend

Do not annotate local `const`s with types the initializer already gives. `const n: number = 1` is noise.

**`satisfies` over annotation** when you want the check without widening:

```ts
// annotation widens: config.port is number, keys are not known
const config: Record<string, string | number> = { host: "localhost", port: 5432 };

// satisfies checks and keeps the literal type
const config = { host: "localhost", port: 5432 } satisfies Record<string, string | number>;
//    config.port is 5432, config.host is "localhost"
```

## Generics

A type parameter earns its place only if it appears at least twice. Once is a disguised `any`.

```ts
// smell: T appears once — this is just (x: unknown) => void
function log<T>(x: T): void;

// idiomatic: the parameter links input to output
function first<T>(xs: readonly T[]): T | undefined;
```

- Constrain (`<T extends { id: string }>`) rather than leaving open and asserting inside.
- Default type arguments (`<T = string>`) for ergonomics on rarely-overridden parameters.
- Conditional and mapped types are for library surfaces. In application code, three nested conditionals is a signal you are modelling the wrong thing — try a discriminated union.

## `noUncheckedIndexedAccess`

> "Turning on `noUncheckedIndexedAccess` will add `undefined` to any un-declared field in the type."
> — [TSConfig Reference](https://www.typescriptlang.org/tsconfig/#noUncheckedIndexedAccess)

This is on. `arr[0]` is `T | undefined`, and that is the truth — the array may be empty.

```ts
// handle it
const first = xs[0];
if (first === undefined) return;

// or use the API that encodes non-emptiness
const [head, ...tail] = xs;      // head is still T | undefined
type NonEmpty<T> = readonly [T, ...T[]];   // head is T
```

Do not silence it with `!`. The whole value of the flag is that it found a real empty case.
