# Architecture

Sources: [TypeScript Handbook — Modules](https://www.typescriptlang.org/docs/handbook/2/modules.html), [TSConfig Reference — Projects](https://www.typescriptlang.org/tsconfig/#Projects_6255), [Node.js — Packages](https://nodejs.org/api/packages.html).

## Layers

Three, and the dependency arrow only ever points inward.

| Layer | Contains | May import |
| --- | --- | --- |
| **Domain** | Types, invariants, pure business rules | Nothing but other domain modules |
| **Application** | Use cases, orchestration, transactions | Domain |
| **Adapters** | HTTP handlers, RPC clients, DB access, UI components | Application, Domain |

The domain layer imports no framework, no client, no environment. It should compile and test with no I/O available at all. When a domain module needs to `import { db }`, the design is wrong: pass the capability in as a parameter, typed as an interface the domain owns.

**Rule:** the direction is enforced by a lint rule (`import/no-restricted-paths` or equivalent), not by discipline. Every architecture that relies on people remembering the arrow has already lost it.

## Files and modules

- One concept per file. The file is named after the concept, in `kebab-case.ts`.
- A file over ~300 lines is a question, not an error: is it one concept or four?
- Colocate the test beside the source: `order-total.ts`, `order-total.test.ts`.
- Types that describe a module's own surface live in that module. A single `types.ts` holding every interface in the app is a circular-import generator and tells you nothing about ownership.

### Barrel files

**Rule:** no `index.ts` that re-exports a whole directory, except at a published package boundary.

Inside a package, import from the module that defines the thing. Barrels cost you tree-shaking (bundlers must prove the unused branches are side-effect free), they create import cycles that only appear at runtime, and they turn one changed file into a rebuild of everything that touched the barrel.

At a package boundary — `@paas/ui`, `@paas/client` — a single deliberate entry point is correct and is the whole point: it is the API surface, hand-curated, and everything not exported there is private.

## Package boundaries

A workspace package earns its existence when at least one is true:

- Two or more applications consume it.
- It has a genuinely different release or ownership story.
- It is generated (protobuf clients) and must not be hand-edited.

Otherwise it is a directory. Splitting into packages "for cleanliness" buys you version skew, a build-order graph, and an editor that no longer jumps to the real definition.

Every package declares its public surface in `exports` in `package.json`. No deep imports into another package's `src/`. If a consumer needs something unexported, the fix is to export it deliberately, not to reach through the wall.

```json
{
  "name": "@paas/ui",
  "type": "module",
  "exports": { ".": "./src/index.ts", "./styles.css": "./src/styles.css" }
}
```

## Path aliases

Use the framework's alias (`$lib` in SvelteKit) and the workspace package names. Do not invent a parallel set of `@/`-style aliases on top — every alias is another thing that must be configured identically in `tsconfig`, Vite, Vitest, and the editor, and one of them will drift.

Relative imports within a module's own directory (`./order-total`) are fine and clearer than an alias for a file three lines away.

## Dependency injection without a framework

Pass the capability as a parameter. That is the whole pattern.

```ts
// domain owns the interface it needs
export interface Clock { now(): Date }
export interface OrderStore { byId(id: OrderId): Promise<Order | undefined> }

// application takes them
export function makeCancelOrder(deps: { clock: Clock; orders: OrderStore }) {
  return async function cancelOrder(id: OrderId): Promise<Result<void, CancelError>> { ... };
}

// adapter wires the real ones, once, at the composition root
const cancelOrder = makeCancelOrder({ clock: systemClock, orders: pgOrderStore });
```

**Rule:** one composition root per deployable — the entry point, and nowhere else, knows about concrete implementations. No DI container, no decorators, no reflection metadata. A closure over an options object does everything a container does, with types the compiler can actually see.

The interface belongs to the consumer, not the implementation. `OrderStore` lives in the domain because the domain is what needs it; the Postgres adapter imports the domain to implement it, never the reverse.

## Configuration

Parse the whole environment once, at startup, into a frozen typed object. Every module takes what it needs from that object as a parameter or an import of the parsed value — never `process.env` directly.

```ts
import * as v from "valibot";

const Env = v.object({
  DATABASE_URL: v.pipe(v.string(), v.url()),
  PORT: v.optional(v.pipe(v.string(), v.transform(Number), v.integer(), v.minValue(1)), 3000),
  LOG_LEVEL: v.optional(v.picklist(["debug", "info", "warn", "error"]), "info"),
});
export const env = Object.freeze(v.parse(Env, process.env));
```

A missing variable then fails at boot with a message naming the variable, instead of at 2am as `undefined` concatenated into a URL.

## Project references

For a workspace with more than a couple of packages, TypeScript project references give you incremental builds and enforce the dependency graph at the compiler level — a package cannot import from one it does not reference. Worth the setup once the full-workspace `tsc` run stops being instant; not worth it before then.
