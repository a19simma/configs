---
name: typescript
description: TypeScript coding standards: strict compiler config, type design, module architecture, typed errors without exceptions-as-control-flow, ESLint and formatter config. Load before writing or editing any .ts/.tsx file, tsconfig.json, or package.json, and when asked whether TypeScript code is idiomatic, which package to use, or how to test it.
---

# TypeScript Best Practices

Grounded in the [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html), [TSConfig Reference](https://www.typescriptlang.org/tsconfig/), [typescript-eslint](https://typescript-eslint.io/rules/), and [Total TypeScript](https://www.totaltypescript.com/books/total-typescript-essentials).

## Load order

| Question | File |
| --- | --- |
| How do I model this as a type? | `references/types.md` |
| Is this idiomatic? What smells? | `references/style-and-smells.md` |
| How do I lay out modules and packages? | `references/architecture.md` |
| How do I signal and handle failure? | `references/errors.md` |
| How do I test this? | `references/testing.md` |
| Which package for X? Is this one allowed? | `references/packages.md` |
| What compiler options and lints do I turn on? | `references/linting.md` |

Read only the file that answers the question. Do not preload them.

Writing Svelte components: read `svelte/SKILL.md` as well. It owns runes, reactivity, and the SvelteKit server/client boundary; this skill owns everything underneath.

## Non-negotiables

1. **`strict: true` plus the four checks it does not include.** `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noImplicitOverride`, `verbatimModuleSyntax`. `strict` is a moving target by design — the Handbook says "Future versions of TypeScript may introduce additional stricter checking under this flag" — so take the upgrades rather than pinning around them. Config in `references/linting.md`.
2. **`any` never ships.** `unknown` at every boundary, narrowed by a predicate or a schema parse. `@typescript-eslint/no-explicit-any` is an error, and an `// eslint-disable` needs a reason comment naming what makes the type genuinely unknowable.
3. **No type assertions to paper over a mismatch.** `as` is allowed for a genuine narrowing the compiler cannot see, with a comment stating the invariant. `as any`, `as unknown as T`, and non-null `!` are banned outside tests. If the type is wrong, fix the type.
4. **Make illegal states unrepresentable.** Discriminated unions and branded types over optional-field soups and stringly-typed fields. Four optional properties describe sixteen states; you meant three.
5. **External data is parsed, never asserted.** Every HTTP response, `JSON.parse`, `process.env` read, and file load crosses the boundary through a schema. A typed fetch wrapper that lies is worse than an untyped one.
6. **Errors are values in the domain layer.** Typed result unions for expected failure; `throw` reserved for bugs and truly exceptional conditions. Never `catch (e)` and continue without narrowing `e` — it is `unknown`, not `Error`. See `references/errors.md`.
7. **Exported symbol without a doc comment is a bug** in any package consumed outside its own directory. Internal helpers need a comment only where the *why* is not obvious.
8. **No new dependency without approval.** Only packages listed in `references/packages.md`, or expressly permitted by the user. Everything else: use the platform, write the twenty lines, or ask. Every project pins an allowlist gate in CI so the ban list is enforced by a check, not by a reviewer's memory.
9. **`tsc --noEmit` + `eslint` + format check gate CI.** No exceptions merged without an `eslint-disable` carrying a reason comment. `@ts-ignore` is banned outright; `@ts-expect-error` with a reason is the only escape hatch, because it fails loudly once the underlying bug is fixed.

## Reviewing

The rules live in `references/` and nowhere else.

Order: machine pass (`tsc`, `eslint`) → dependency gate → type design → architecture → tests. Machine-findable smells are not worth human attention.

**Reviewing a TypeScript diff:** read `typescript-review/SKILL.md` and follow it. **Scaffolding a new TypeScript project:** read `typescript-setup/SKILL.md` and follow it. Both are user-invoked, so they cannot be fired as skills; reach them by path.
