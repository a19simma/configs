# Prescribed Packages — Allowlist

## The rule

**No package may be added unless it appears in a profile below, or the user has given express permission for that specific package.**

If a job is not covered here: write it with the platform (modern Node and modern browsers cover far more than they did), write the twenty lines yourself, or stop and ask. "It's only one small dependency" is not a reason. Every dependency is install time, semver risk, audit surface, transitive surface, and supply-chain surface — and npm's transitive fan-out makes the last two worse than any other ecosystem's.

**Monoculture.** One package per job, organisation-wide. Where two packages do the same work, this document names one and bans the rest, even when the loser is the better fit for some single project. A second HTTP client, schema library, test runner, or state library means two sets of idioms, two failure modes, two upgrade paths, and code that cannot move between services.

Adding an allowed package still requires:
- Exact-version or caret pin consistent with the rest of the workspace, and a committed lockfile.
- Placement in `devDependencies` unless it is genuinely imported by shipped runtime code.
- Declared once at the workspace root where multiple packages use it, so versions cannot drift between members.
- No new transitive `postinstall` scripts without reading what they do.

---

## Core — allowed in every project

### `typescript`

The compiler. `tsc --noEmit` is the type gate in CI even where the bundler does the emitting; bundlers strip types without checking them.

### `vite`

The build tool and dev server. **Rule:** the only bundler. Webpack, Rollup-direct, esbuild-direct, Parcel, and Turbopack are banned as project-level build tools — Vite already uses Rollup and esbuild underneath, and adding a second build graph doubles the config surface for nothing.

### `vitest`

> "Vite-native testing framework"
> — [vitest.dev](https://vitest.dev/)

**Rule:** the only unit test runner. Jest, Mocha, Jasmine, AVA, and `node:test` are banned as the project runner.
**Why:** Vitest reuses the Vite config, so tests resolve aliases, plugins, and transforms identically to the app. A second runner means a second module-resolution story and tests that pass against code the bundler builds differently.

### `@playwright/test`

**Rule:** the only browser and end-to-end runner. Cypress, Selenium, Puppeteer-direct, and WebdriverIO are banned.
**Why:** monoculture, and Playwright's auto-waiting removes the sleep-and-retry code that makes suites flaky.

---

## Frontend

### `svelte` + `@sveltejs/kit` + `@sveltejs/vite-plugin-svelte`

The UI framework and application framework. See `svelte/SKILL.md` for the rules that govern their use. React, Vue, Solid, Angular, and Qwik are banned in this organisation's frontends.

### `svelte-check`

Type-checks `.svelte` files, which `tsc` cannot. Runs in CI beside `tsc --noEmit`, not instead of it.

### `@sveltejs/adapter-node`

The deployment adapter. A different adapter needs approval, because it changes the runtime contract of every server `load` and form action.

### `tailwindcss` + `@tailwindcss/vite`

**Rule:** the only styling system beyond Svelte's own scoped `<style>` blocks. CSS-in-JS libraries, Sass, PostCSS plugin stacks, styled-components, UNO, and component kits that ship their own theming layer are banned.
**Why:** Tailwind v4 reads its config from CSS, so there is no second config language, and a utility layer plus Svelte's scoped styles already covers both ends. Two styling systems in one app means every component is a coin flip.

---

## RPC and data

### `@bufbuild/protobuf` + `@connectrpc/connect` (+ `@connectrpc/connect-node`)

The wire format and RPC client. **Rule:** the schema is the boundary parser — generated message types are the only sanctioned way to type a response from our own services. Do not re-validate a generated type with a second schema library, and do not hand-write an interface that mirrors a `.proto`.

`axios`, `superagent`, `got`, `ky`, and `node-fetch` are **banned**. For anything outside Connect, use the platform `fetch`, and parse the response as below.

### Schema validation for everything not covered by protobuf

`valibot` is the sanctioned choice, for exactly three jobs: parsing `process.env` into a typed config object at startup, parsing form input in SvelteKit actions, and parsing third-party HTTP responses.

**Why:** its API is a set of independent functions rather than a method chain, so a bundler keeps only the validators actually used. Schemas that ship to the browser — form validation in particular — cost a fraction of the chained-builder alternative.

**Rule:** import it namespaced (`import * as v from "valibot"`) and use the standalone entry points, `v.parse(Schema, input)` and `v.safeParse(Schema, input)`. Do not re-export a wrapper that rebuilds a chaining API on top; that gives back the bundle cost and hides the library from anyone reading the code.

`v.safeParse` returns `{ success, output, issues }` — note `output`, not `data`, and `v.flatten(result.issues)` for field-level errors.

`zod`, `yup`, `joi`, `ajv`, `superstruct`, `io-ts`, and `class-validator` are **banned** — monoculture.

**Rule:** parse once, at the boundary, into a domain type. A schema imported into a component is a boundary in the wrong place.

---

## Lint and format

### `eslint` + `typescript-eslint` (+ `@eslint/js`, `eslint-config-prettier`, `eslint-plugin-svelte`)

**Rule:** the only linter, configured type-aware. Config in `linting.md`.
**Why:** the rules that catch real defects — `no-floating-promises`, `no-misused-promises`, `switch-exhaustiveness-check`, `no-unnecessary-condition` — all need type information, which only the typed ESLint setup provides today.

### `prettier`

**Rule:** the only formatter, run with near-default config, checked in CI.
**Why:** any time spent configuring a formatter is time spent on nothing.

`biome` and `oxlint` are **not banned but not adopted** — they would replace both of the above with one fast binary, at the cost of the type-aware rules. Switching needs express permission and an explicit statement of what coverage is being dropped.

`eslint-plugin-import`, `eslint-plugin-unicorn`, and other opinion packs need approval per rule set; `strictTypeChecked` already covers most of what they add.

---

## Banned outright, with reasons

| Package(s) | Why |
| --- | --- |
| `lodash`, `underscore`, `ramda` | The platform has `Object.groupBy`, `structuredClone`, `Array.prototype.at`, `toSorted`, `flatMap`. Import a whole utility library to avoid writing four lines and you own its entire attack surface |
| `moment`, `dayjs`, `date-fns`, `luxon` | `Intl.DateTimeFormat` and `Temporal` cover formatting and arithmetic. Where `Temporal` is not yet available, ask before reaching for a polyfill |
| `anyhow`-equivalents: `neverthrow`, `fp-ts`, `effect`, `purify-ts` | The `Result` type is twelve hand-written lines (`errors.md`). These packages are a second language, not a utility |
| `axios` and friends | Platform `fetch` |
| `jest`, `mocha`, `chai`, `sinon` | Vitest, monoculture |
| `cypress`, `puppeteer`, `selenium-webdriver` | Playwright, monoculture |
| `redux`, `zustand`, `mobx`, `xstate`, `pinia` | Runes are the state model. See `svelte/references/state.md` |
| `styled-components`, `emotion`, `sass`, `less`, `stylus` | Tailwind plus scoped `<style>` |
| `express`, `fastify`, `koa`, `hono` | SvelteKit owns the HTTP surface. A second server framework in the same deployable needs express permission |
| `dotenv` | Node loads `.env` natively (`--env-file`), and Vite loads it in dev |
| `uuid` | `crypto.randomUUID()` |
| `classnames`, `clsx` | A four-line `cn` helper, or Tailwind's own composition |
| `ts-node` | Node runs TypeScript directly; Vite runs it in dev |
| `left-pad`-class micro-packages | Any package under ~50 lines of real logic is a supply-chain liability with no upside |

---

## Adding something new

When a genuine gap appears, do not install first and justify later. Produce this, then ask:

1. **The gap.** What does the platform, or what we already have, fail to do? Name the code you would otherwise write and roughly how long it is. If the answer is under ~50 lines, write it.
2. **Alternatives considered.** Two or three real candidates, and why this one. The monoculture rule means adding a package also bans its rivals from every future project — say which ones you are foreclosing.
3. **Maintenance signal.** Last release date, release cadence over the past year, open-issue trend, number of maintainers, whether it has a named funding or corporate backer. A single-maintainer package with a two-year gap is a fork you have not budgeted for.
4. **Weight.** Transitive dependency count and install size (`npm ls --all`, `npm pack --dry-run`), plus bundle impact for anything shipped to the browser. Transitive count matters more than size: each one is another publish key that can compromise you.
5. **Install scripts.** Does it or any transitive dependency run `postinstall`? If yes, read the script and say what it does.
6. **Types.** Ships its own types, or needs `@types/*`? A `@types` package maintained separately from the library will drift.
7. **Exit cost.** How much code touches it, and what replacing it looks like. A package behind one internal module is cheap to remove; one imported in ninety files is permanent.
8. **Licence.** Anything not MIT, Apache-2.0, BSD, or ISC needs explicit sign-off.

Approval is per-package and per-project. An approval in one repository does not carry to the next, and does not extend to that package's optional plugins.

## Enforcement

The allowlist is enforced by a check in CI, not by a reviewer's memory:

- A committed lockfile, and CI installs with `npm ci` (or the frozen-lockfile equivalent) so no resolution happens at build time.
- A dependency-diff gate on every pull request: any change to `dependencies` or `devDependencies` fails unless a maintainer has approved it.
- `npm audit --audit-level=high` (or equivalent) in CI.
- An unused-dependency sweep, so removals actually leave the manifest.
