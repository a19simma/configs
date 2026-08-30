---
disable-model-invocation: true
name: typescript-review
description: Review a TypeScript diff against the typescript skill: package allowlist, compiler strictness, type design, error shape, architecture, tests. Reports findings only, makes no edits.
---

# TypeScript Review

Reviews TypeScript against the conventions in the `typescript` skill. **That skill is the rule source — this one is the procedure.** Supersedes the generic `code-review` skill for TypeScript changes; do not run both. For `.svelte` files use `svelte-review` instead. Do not invent rules here; if a rule is missing there, say so and propose it as a rule change rather than flagging it as a violation.

## Procedure

### 0. Scope

Determine the diff: `git diff <base>...HEAD`, a named branch/PR, or specified files. Review only changed lines plus enough surrounding context to judge them. Unchanged legacy code is out of scope unless the change made it wrong.

### 1. Machine pass (before reading anything)

```
tsc --noEmit
eslint .
prettier --check .
npx depcheck            # unused and undeclared dependencies
```
Run tests via the `test` subagent, not directly. Anything a tool found is not a human finding — report the tool output and move on. Human attention goes only to what tools cannot see.

If `tsc --noEmit` passes but the tsconfig is missing `strict` or any of the four required flags, the pass means nothing. Check the config before trusting the result.

### 2. Dependency gate — blocking

Diff `package.json` and the lockfile. For each added dependency, check `typescript/references/packages.md`.

- On the ban table (`lodash`, `moment`, `dayjs`, `date-fns`, `axios`, `zod`, `jest`, `cypress`, `redux`/`zustand`/`xstate`, `styled-components`/`emotion`/`sass`, `express`/`fastify`/`hono`, `dotenv`, `uuid`, `clsx`/`classnames`, `neverthrow`/`fp-ts`/`effect`, `ts-node`, …) → **BLOCKER**. Name the sanctioned replacement from the same table.
- Not on the allowlist and no express permission in this conversation → **BLOCKER**, no exceptions, no "it's small". Check both the core and the domain sections before flagging.
- Two packages for one job in the same workspace (two schema libraries, two test runners, two date libraries) → **BLOCKER**. Monoculture.
- A dependency added without a lockfile change, or a lockfile change with no `package.json` change → finding. Someone installed outside the tooling.
- Belongs in `devDependencies` but sits in `dependencies` → finding. Anything that does not run in production is a dev dependency.
- A micro-package — under ~50 lines of actual logic — → **BLOCKER**. Write it.
- `"latest"`, `"*"`, or an unpinned git URL as a version → finding.
- Approval granted in conversation but not recorded in the project's dependency notes → finding.

### 3. Rule passes

Load one reference file per pass.

| Pass | Reference | Looking for |
| --- | --- | --- |
| Compiler | `typescript/references/linting.md` | `strict` off or weakened; a missing `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noImplicitOverride`, `verbatimModuleSyntax`; a new `@ts-ignore` (banned — `@ts-expect-error` with a reason is the only form); a new `eslint-disable` without a justification comment; `skipLibCheck` used to hide a real error |
| Types | `typescript/references/types.md` | `any` in any position; an assertion (`as`) papering over a mismatch; `as unknown as`; a non-null `!`; external data typed by assertion instead of parsed; illegal states representable where a discriminated union fits; a `switch` over a union with no `assertNever`; a type parameter appearing once in a signature; mutable arrays/fields that should be `readonly`; an enum where a union of literals works |
| Errors | `typescript/references/errors.md` | exceptions as control flow in the domain layer; `Result<T, string>` instead of a union error type; a caught error typed as `any`; a `catch` that swallows or rethrows without `{ cause }`; an `Error` subclass without `override readonly name`; a boundary conversion outside the three sanctioned ones; a rejected promise with a non-`Error` reason |
| Style | `typescript/references/style-and-smells.md` | the smells table; `null` used where `undefined` means absence; boolean parameters; default exports; `import` of a type without `import type`; circular imports; a floating promise; `async` with no `await`; a comment restating the code |
| Architecture | `typescript/references/architecture.md` | a domain module importing an adapter; a barrel file outside a package boundary; a service located by import rather than passed in; a second composition root; a missing `exports` field on a published package; a path alias that crosses a layer |
| Testing | `typescript/references/testing.md` | new behaviour with no test; a test asserting on internals; `vi.mock` where an in-memory implementation of an owned interface would do; a fixture where a builder belongs; a test whose name does not state the behaviour; a snapshot standing in for an assertion |

### 4. Verify before reporting

Every finding must survive:
1. **Cite the rule.** File + rule name from the `typescript` skill. No citation → not a finding.
2. **Concrete failure.** Name inputs or a change that makes it break, or state plainly that it is a convention violation with no runtime consequence.
3. **Read the surrounding code.** An `as` next to a comment explaining why the compiler cannot see it is not a finding.

Drop anything that fails these. A false positive costs more trust than a missed nit.

## Severity

| Level | Meaning |
| --- | --- |
| **BLOCKER** | Unapproved or banned dependency; `any` on a shipped path; strictness weakened; `@ts-ignore`; unparsed external data reaching the domain; `tsc`/`eslint` failure |
| **MAJOR** | Illegal state representable; exceptions as domain control flow; layer violation; new behaviour with no test; a public API leaking an internal type |
| **MINOR** | Naming, signature ergonomics, a missing `readonly`, an avoidable assertion, a mutable default |
| **NOTE** | Suggestion with a trade-off; explicitly optional |

## Output

Findings only, most severe first, `file.ts:line` for each:

```
BLOCKER  src/http/client.ts:12  Unapproved dependency `axios` added in package.json:24
  Rule:    packages.md, ban table; axios listed under "banned — use fetch"
  Failure: no approval in this conversation
  Fix:     global fetch with a typed wrapper; see packages.md § HTTP
```

End with a one-line verdict: `PASS`, `PASS WITH MINORS`, or `BLOCKED (n blockers)`.

## Constraints

- **Read only.** Suggested changes are minimal snippets with locations.
- Do not restate what `tsc` or `eslint` already printed.
- No praise section. Silence is the pass signal.
