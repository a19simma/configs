---
disable-model-invocation: true
name: typescript-setup
description: Scaffold a new TypeScript project from the typescript skill: short interview, then tsconfig, eslint.config.js, Prettier, package.json scripts, the dependency gate and CI.
---

# TypeScript Project Setup

Interview, then write the configuration. Rules come from the `typescript` skill. Read `typescript/references/packages.md` and `typescript/references/linting.md` before writing anything, and copy their current content rather than the examples in this file, which may lag.

For a SvelteKit app, run this first and `svelte-setup` after — this one owns the compiler, the linter, and the dependency gate; that one owns everything Svelte.

## 1. Interview

Ask only what changes the output. Skip a question whose answer is already visible in the repo or was given in the request. Prefer `AskUserQuestion` — one call, all open questions at once.

| Question | Changes |
| --- | --- |
| Shape: library, Node service, SvelteKit app, CLI? | which allowlist profile applies; `lib` and `module` targets; whether `@sveltejs/kit` appears |
| Single package or workspace? | root `tsconfig` with project references and a `packages/*` layout, or one flat config |
| Runtime: Node version, or browser too? | `lib`, `target`, `types`, whether `dom` is in scope |
| Published to npm, or internal? | the `exports` field, `declaration`, `"private": true`, whether API surface gets a doc gate |
| Does anything cross a trust boundary — env, forms, third-party HTTP? | whether `valibot` goes in at setup or waits |
| CI: GitHub Actions, or none? | whether to write `.github/workflows/ci.yml` |

Defaults when the user says "just pick": single package, latest LTS Node, internal, GitHub Actions, `valibot` included.

## 2. Write

State the file list before writing, then write them.

### `tsconfig.json`

Copy the block from `typescript/references/linting.md` whole. `strict` plus the four required flags — `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noImplicitOverride`, `verbatimModuleSyntax` — are not negotiable and not a starting point to be relaxed later. In a workspace, a base config at the root and one `tsconfig.json` per package extending it, with `references` between them.

Never add `skipLibCheck` to silence an error in your own code, and never weaken a flag to make an existing file compile. If a dependency's types do not check, that is a finding about the dependency.

### `eslint.config.js`

Flat config, `tseslint.configs.strictTypeChecked` plus `stylisticTypeChecked`, with `projectService: true` so the type-aware rules actually run. From `typescript/references/linting.md`. Add the escape-hatch rules from that file's table: `@ts-ignore` banned, `@ts-expect-error` allowed with a description.

The layer rule from `typescript/references/architecture.md` is enforced here, as an import restriction — domain may not import adapters. Write it at setup, while there is nothing to fix.

### `.prettierrc` and `.prettierignore`

From `typescript/references/linting.md`. Prettier owns formatting; ESLint owns correctness. Do not install a formatting-rule plugin for ESLint.

### `package.json`

- `"type": "module"`. `"private": true` unless publishing.
- The `exports` field if publishing; no `main`, no deep imports into the package.
- Scripts: `typecheck`, `lint`, `format`, `format:check`, `test`.
- Dependencies: only what the chosen profile allows, each pinned to a real version. Nothing "for later".
- Commit the lockfile. CI installs with `npm ci`, never `npm install`.

### `.github/workflows/ci.yml`

The five-command gate from `typescript/references/linting.md`:

```yaml
- run: npm ci
- run: npx tsc --noEmit
- run: npx eslint .
- run: npx prettier --check .
- run: npx vitest run
```

Add `npx svelte-check --fail-on-warnings` for a SvelteKit app, `npm audit --audit-level=high`, and a dependency-diff step that fails when `package.json` gains a dependency the allowlist does not cover. The allowlist is only a rule until something checks it on every PR.

### Dependency notes

A short `docs/dependencies.md`, or a section in the README: the allowlist profile in force, and a dated line for every package approved outside it with the justification given. An approval nobody wrote down is an approval that gets re-litigated.

## 3. Report

List what was written, then state explicitly:
- which profile was applied and which packages it allows;
- that everything on the ban table is banned, that new dependencies need per-package, per-project approval, and that CI now checks it;
- anything the interview deferred.

## Existing projects

Same files, but do not overwrite silently. Read what is there, show a diff of the intended change, and get approval before touching a config the project already has.

Turning on `strict` in a project that never had it will produce hundreds of errors. Do not do it in the setup change. Write the config with the flags on, report the error count, and propose fixing it per-directory in its own change. Banned packages already in `package.json` are reported as findings, not removed — ripping out `axios` is a refactor, not a setup step.
