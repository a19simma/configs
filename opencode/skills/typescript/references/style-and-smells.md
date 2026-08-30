# Style and Smells

Sources: [typescript-eslint rules](https://typescript-eslint.io/rules/), [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html), [MDN JavaScript reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference).

## Naming

`PascalCase` types, interfaces, enums, classes, components. `camelCase` functions, variables, properties, methods. `SCREAMING_SNAKE_CASE` module-level constants that are genuinely constant configuration. `kebab-case.ts` filenames.

- No `I` prefix on interfaces, no `T` prefix on types. The compiler knows what they are.
- Booleans read as assertions: `isLoading`, `hasAccess`, `canEdit`, `shouldRetry`.
- Functions are verbs; a function named `userData` is a bug report about itself.
- Async functions are not suffixed `Async`. The `Promise` in the signature says it.

## Signatures

```ts
// smell
function load(path: string, opts: any, cb: Function): any

// idiomatic
function load(path: string, opts: LoadOptions): Promise<Config>
```

- Return concrete types, never `any`. `void` is a real return type; use it.
- Two or more parameters of the same primitive type: take an options object. `resize(true, false, 10)` is unreadable at the call site and unsafe at every refactor.
- Never take a `boolean` flag that selects behaviour. Two functions, or a string-literal union.
- Optional parameters go last and mean *absent*, not *default* — if there is a default, give it one.
- Overloads only where the return type genuinely depends on the argument type. Otherwise a union parameter is clearer.

## Nullability

Pick one absence value per codebase and hold the line. **Rule:** `undefined` for "not present" throughout; `null` only where an external API or database column forces it, converted at the boundary.

```ts
// smell: three ways to be missing
if (user && user.name && user.name !== "") { ... }

// idiomatic
const name = user?.name ?? "anonymous";
```

- `?.` and `??` over `&&` chains. `||` is a bug generator on `0`, `""`, and `false`.
- Never `!` outside tests. It is `as any` wearing a hat.
- Return `T | undefined` for "might not find it"; do not return `null` from one function and `undefined` from its neighbour.

## Smells table

| Smell | Fix |
| --- | --- |
| `as` to make an error go away | Fix the type, or parse the value |
| `any` in a signature | `unknown` plus narrowing, or a real type |
| `enum` | String-literal union, or `as const` object. Numeric `enum` is unsound; `enum` is not erasable syntax |
| `namespace` | ES modules. Namespaces are a pre-module artefact |
| Class with only static methods | Module with exported functions |
| Constructor that does I/O | Plain constructor plus a static async factory |
| `Object.assign`/spread to build a required shape | Build it complete in one literal |
| Long `if/else if` on a `type` string field | Discriminated union plus `switch` plus `assertNever` |
| `Array<T>` and `T[]` mixed | One form; `T[]` for simple, `Array<T>` for complex elements |
| `for (let i = 0; ...)` over an array | `for...of`, or `map`/`filter`/`reduce` where it reads better |
| A five-adapter chain nobody can read | A `for...of` loop with a name for each step |
| `JSON.parse(JSON.stringify(x))` to clone | `structuredClone(x)` |
| `let` that is assigned exactly once | `const` |
| Barrel file re-exporting a whole directory | Import from the module that defines it. See `architecture.md` |
| `process.env.FOO` read deep in a module | Parse the whole environment once at startup into a typed config object |

## Async

```ts
// smell: sequential awaits with no dependency between them
const user = await getUser(id);
const orders = await getOrders(id);

// idiomatic
const [user, orders] = await Promise.all([getUser(id), getOrders(id)]);
```

- `async`/`await` throughout. `.then()` chains only inside a function that must not be async.
- `Promise.all` for independent work; `Promise.allSettled` where one failure must not cancel the rest.
- Never `async` on a function with no `await` in it — it changes the error semantics for no reason.
- Floating promises are errors (`@typescript-eslint/no-floating-promises`). Fire-and-forget is written `void doThing()` with a comment, so the reader knows it was deliberate.
- Every `await` in a loop is a question: did you mean to serialise this? Sometimes yes — rate limits, ordering. Say so in a comment.

## Modules

- Named exports only. Default exports rename themselves at every import site and break `find all references`. The exception is a framework that requires one (SvelteKit route modules, some bundler entry points).
- `import type { Foo }` for type-only imports. `verbatimModuleSyntax` is on:

> "any imports or exports without a `type` modifier are left around. Anything that uses the `type` modifier is dropped entirely."
> — [TypeScript 5.0 release notes](https://www.typescriptlang.org/tsconfig/#verbatimModuleSyntax)

Meaning a value import you only used as a type stays in the emitted JavaScript and drags the module in at runtime. Mark it.

- No circular imports. If two modules need each other, the shared thing belongs in a third.
- Side effects at module top level are banned outside the entry point. Importing a module must not start a server, open a socket, or mutate globals.

## Comments

Explain *why*. The code already says what.

```ts
// smell
// increment the counter
count += 1;

// useful
// Retry budget is per-connection, not per-request: the upstream resets it on reconnect.
count += 1;
```

TSDoc (`/** ... */`) on every exported symbol: one summary line, `@param` only where the name is not self-explanatory, `@throws` wherever the function can throw.
