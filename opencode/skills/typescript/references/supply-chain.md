# Supply Chain — install-time hardening

The threat is not a CVE in a package you already have. It is a legitimate package publishing a malicious version after a maintainer account or a CI token is compromised. Against the real npm incidents of 2025, **a release cooldown plus disabled lifecycle scripts would have blunted every one; CVE scanning would have stopped none.** Attack windows ran to hours, not weeks: chalk was live under twelve hours, rspack one.

Defences here fall into two kinds, and the split governs how much to trust each. **Prevention** stops the code arriving. **Containment** assumes it arrived and limits what it reaches. Prevention covers install time only; everything past that is containment.

## `pnpm`

**Rule:** the only package manager. npm, Yarn (Classic and Berry), and Bun are banned as the project manager. Pin it in `packageManager` and install it directly, not via Corepack — pnpm no longer recommends that path.

**Why:** the defaults arrive with the tool. Every control below is on by default in current pnpm; the equivalents elsewhere need either an opt-in or a package-manager version no Node LTS ships.

**Rejected:**

- **npm.** npm 12 reached rough parity: scripts blocked by default, `allow-git`/`allow-remote` at `none`, `min-release-age`, native `npm patch`. The defect is distribution. No Node LTS bundles npm 12 — Node 24 ships 11.19, Node 22 ships 10.9.9 — so every default that matters becomes a version upgrade enforced separately, and a stock toolchain installs with none of it, silently. Two further edges: `npm patch` applies during install and is **not** disabled by `--ignore-scripts`, and `min-release-age` deadlocks against `audit fix`, holding a vulnerable version and exiting non-zero when the patch is too fresh.
- **Yarn Berry.** Pnpm's equal on defaults (`enableScripts: false` since 4.14, `npmMinimalAgeGate` since 4.10, `enableHardenedMode`). Rejected on blast radius: PnP changes module resolution for every tool in the repo, and Zero-Installs pushes toward committed binary caches, rejected below.
- **Yarn Classic.** Frozen at 1.22.22.

**Cost:** two majors in four months (v11 April 2026, v12 August 2026), and v11 was breaking — `.npmrc` narrowed to auth and registry only, config moved to `pnpm-workspace.yaml`, `onlyBuiltDependencies` replaced by `allowBuilds`. Budget for the upgrade tax. The project is thinly funded relative to its dependents.

Isolation is **semistrict**, not strict: `hoist` defaults true, so first-party code is protected from phantom dependencies and third-party packages inside `node_modules` are not. Claim no more than that.

## Install configuration

**Rule:** these four are fixed. Write them out even where they match the current pnpm default, and treat a change to any of them as a security review rather than a build fix. Pinning them means an upstream default moving, or a manager swap, lands as a visible diff instead of silently.

```yaml
# pnpm-workspace.yaml
allowBuilds: []                            # no dependency runs a build or lifecycle script
strictDepBuilds: true                      # fail the install when one wants to, rather than warn
minimumReleaseAge: 1440                    # minutes; applies to transitive dependencies too
minimumReleaseAgeIgnoreMissingTime: false  # a registry omitting `time` otherwise skips the delay
```

`minimumReleaseAgeIgnoreMissingTime` matters wherever a proxy or private registry sits in front of npm: left at its `true` default, a registry that omits the `time` field bypasses the cooldown with no signal.

`allowBuilds` governs **dependencies only**. The project's own `package.json` scripts still run, which is right — `prepare`, `build`, and test hooks are yours and are reviewed like any other code here.

**Rule:** an `allowBuilds` entry is a security decision, not a build fix. Almost every request comes from a package compiling a native addon (`node-gyp`) or downloading a prebuilt binary. Read the script, prefer a dependency needing none, and record why the entry exists.

**Rule:** any bot honours the cooldown. Renovate reads `minimumReleaseAge` and passes `--before=<date>` during lockfile generation; one that bypasses it reopens the hole. Security updates bypass the delay by design, which is the intended trade.

Two traps:

- Prefer the empty `allowBuilds` allowlist over the global `ignoreScripts: true`. The global setting blocks the project's own scripts too, so `prepare` and build hooks stop firing, and the usual repair is switching it off entirely and losing the dependency protection with it.
- `ignore-scripts=true` in `.npmrc` does nothing under pnpm 11+, which narrowed `.npmrc` to authentication and registry settings. It fails silently. Configuration belongs in `pnpm-workspace.yaml`.

## Install time is not the only execution

Disabling lifecycle scripts closes install time and nothing else. That is worth doing — it is the whole propagation mechanism of the Shai-Hulud worm, which spread through `preinstall` — but a payload moves to import time as soon as install hooks close.

**Import time is execution.** A dependency's module body runs arbitrary code the moment anything imports it. No package manager setting reaches this. Neither do the surfaces below, all of them third-party code:

- **Build and lint plugins.** Vite, ESLint, Prettier, PostCSS and Tailwind load plugin code from config at startup, in the developer's shell and in CI.
- **`node_modules/.bin`.** Every binary a script invokes.
- **`pnpm dlx` and `npx`.** These fetch and execute in one step, with no lockfile, no cooldown, no review. Treat each as an unpinned install; prefer a pinned devDependency.
- **Native addons.** Compiled code in the Node process, outside anything JavaScript-level can inspect.
- **Dev server and test runner**, which import the whole graph by design.

So install-time prevention is cheap and worth taking, and containment carries the rest: run installs, builds and agents in a container with default-deny network egress. Exfiltration is the payload in every incident above, so blocking the egress is what fails the attack.

## Pinning transitive dependencies

A committed lockfile already pins every transitive dependency to an exact version and integrity hash, and a frozen install replays it verbatim. **For a CI build, `overrides` change nothing.** Anyone presenting overrides as "pinning for CI" is selling what the lockfile already gives.

An override governs the *next* resolution. Whenever anything re-resolves — a new direct dependency, a bot bumping a parent, a lockfile regenerated to settle a merge conflict — the resolver may pick the vulnerable transitive again, and an override forbids it. It is a **ratchet**, not a pin, and it survives lockfile regeneration where a hand-edited lockfile entry does not.

**Rule:** overrides live in `pnpm-workspace.yaml`, never in `package.json`. pnpm 11 silently stopped reading `pnpm.overrides` from the manifest — no warning, no error, every CVE pin quietly inert.

**Rule:** prefer the minimum satisfying range (`"^1.2.3"`) over an exact version. An exact override added for one year's CVE caps you below the next year's fix, and no tool reports it. Detecting a stale override is unsolved in every manager, so annotate each with its CVE or issue link and re-check on a schedule.

**Rule:** scope the override where the fix is scoped. A bare `"foo": "2.0.0"` rewrites every consumer at every depth, including ones declaring `^1`. Use `"vulnerable-parent>foo": "2.0.0"`, or the convergence form `"foo@": ""` which dedupes only where declared ranges permit, then verify with `pnpm why foo`.

Patch with `pnpm patch`, which records the diff in `patches/` and hard-errors when a patch matches nothing or fails to apply. `patch-package` is banned: it works through a `postinstall` hook, so it is skipped under `--ignore-scripts` and its absence is silent.

## Vendoring — rejected

Committing `node_modules`, a Yarn Zero-Install cache, or per-dependency tarballs solves availability: registry outage, unpublish, deletion. It does nothing for integrity, which is the actual threat. A malicious version vendored on day zero is permanently yours, and none of the 2025 incidents would have been caught.

The costs are permanent. Repository size grows by orders of magnitude, binary caches are unreviewable in a diff, and history bloat cannot be undone. `bundleDependencies` is not an alternative — it is a publishing mechanism with no consumer-side effect, frequently miscited as a defence.

Where availability is the real concern, a pull-through caching proxy answers it and adds quarantine-before-availability, which vendoring cannot. Verdaccio is the free self-hosted option and has no native quarantine; Cloudsmith and Sonatype Repository Firewall have one, and cost money.

## Lockfile integrity is weaker than it reads

The `integrity` field proves the tarball matches the hash recorded in your lockfile. An attacker editing the lockfile controls both. Resolved-URL swaps, integrity downgrades, and ghost entries all survive a frozen install, and lockfile diffs are too noisy to catch by eye.

**Rule:** a CI gate fails any pull request changing the lockfile without a corresponding `package.json` change. A machine check, not a review instruction.

## CI is the larger hole

Two of the three biggest npm incidents of 2025 began in a GitHub Actions workflow, not at npm:

> "on: `pull_request_target` only ensures the *workflow* is being run as defined in the PR target, not the code being run."
> — PostHog post-mortem, November 2025

The attacker took an npm token from CI and published normally. No package-manager setting addresses that. Treat workflow files as production code under mandatory review, prefer trusted publishing over long-lived tokens, and assume any token in CI is exfiltratable.

Provenance is a signal, never a gate: npm's own docs say it "does not guarantee the package has no malicious code". It flagged the malicious Nx publishes, which lacked signatures. It would not have flagged chalk, where the attacker held the real account.
