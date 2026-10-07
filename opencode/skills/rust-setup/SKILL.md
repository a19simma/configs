---
disable-model-invocation: true
name: rust-setup
description: Scaffold a new Rust project from the rust skill: short interview, then deny.toml, Cargo.toml lints, clippy.toml, rustfmt.toml, src/error.rs and CI.
---

# Rust Project Setup

Interview, then write the configuration. Rules come from the `rust` skill. Read `rust/references/crates.md` and `rust/references/linting.md` before writing anything, and copy their current content rather than the examples in this file, which may lag.

## 1. Interview

Ask only what changes the output. Skip a question whose answer is already visible in the repo or was given in the request. Prefer `AskUserQuestion`: one call, all open questions at once.

| Question | Changes |
| --- | --- |
| Shape: CLI, web service, library, desktop/TUI? | which profile's crates go in `Cargo.toml`; whether `clap`/`axum`/`tauri` appear |
| Single crate or workspace? | `[workspace]` + `[workspace.dependencies]` + `[workspace.lints]`, or plain `[package]` |
| Datastore? | `sqlx` with which engine feature; whether CI needs `DATABASE_URL` or a committed `.sqlx/` cache |
| Published to crates.io, or internal? | `publish = false` on internal crates, `#[non_exhaustive]` strictness, `cargo-semver-checks` in CI |
| Does it need `unsafe`? | `unsafe_code = "forbid"` vs `"deny"` |
| MSRV, or latest stable? | `rust-version` in `Cargo.toml`, `msrv` in `clippy.toml` |
| CI: GitHub Actions, or none? | whether to write `.github/workflows/ci.yml` |

Defaults when the user says "just pick": single crate, latest stable, internal, no `unsafe`, GitHub Actions.

## 2. Write

Every project gets all of these. State the file list before writing, then write them.

### `deny.toml`

The executable copy of the allowlist, written whole. Check it against `rust/references/crates.md` § Never allowed and § Rejected, with reasons before writing, and add any named crate those sections have gained. Schema: [cargo-deny bans docs](https://embarkstudios.github.io/cargo-deny/checks/bans/cfg.html).

**`deny.toml`**, at the workspace root:
```toml
[graph]
all-features = true

[bans]
multiple-versions = "warn"
wildcards = "deny"
allow-wildcard-paths = true

deny = [
    { crate = "anyhow",       reason = "erases the error type; write a concrete enum" },
    { crate = "thiserror",    reason = "boilerplate only; hand-write Display/Error/From" },
    { crate = "eyre",         reason = "same slot as anyhow" },
    { crate = "color-eyre",   reason = "same slot as anyhow" },
    { crate = "miette",       reason = "same slot as anyhow" },
    { crate = "snafu",        reason = "same slot as anyhow" },

    { crate = "diesel",    use-instead = "sqlx" },
    { crate = "sea-orm",   use-instead = "sqlx" },
    { crate = "rusqlite",  use-instead = "sqlx with features = [\"sqlite\"]" },

    { crate = "ureq",      use-instead = "reqwest with features = [\"blocking\"]" },
    { crate = "attohttpc", use-instead = "reqwest" },

    { crate = "actix-web", use-instead = "axum" },
    { crate = "rocket",    use-instead = "axum" },
    { crate = "warp",      use-instead = "axum" },
    { crate = "poem",      use-instead = "axum" },
    { crate = "salvo",     use-instead = "axum" },
    { crate = "ntex",      use-instead = "axum" },
    { crate = "loco-rs",   use-instead = "axum" },

    { crate = "env_logger", use-instead = "tracing-subscriber" },

    { crate = "mockall",           reason = "hand-write the fake" },
    { crate = "mockito",           reason = "fake the port trait, or bind a TcpListener on port 0" },
    { crate = "wiremock",          reason = "fake the port trait, or bind a TcpListener on port 0" },
    { crate = "insta",             reason = "snapshots record observations, not intent" },
    { crate = "proptest",          reason = "named boundary examples; cargo-fuzz for input exploration" },
    { crate = "quickcheck",        reason = "same category as proptest" },
    { crate = "criterion",         reason = "profile instead; benchmark in CI on fixed hardware" },
    { crate = "divan",             reason = "same category as criterion" },
    { crate = "rstest",            reason = "loop a const array of cases; call fixtures as functions" },
    { crate = "assert_cmd",        reason = "CARGO_BIN_EXE_<name> plus a local helper" },
    { crate = "pretty_assertions", reason = "ergonomics only" },
    { crate = "similar-asserts",   reason = "ergonomics only" },
    { crate = "predicates",        reason = "CARGO_BIN_EXE_<name> plus a local helper" },
    { crate = "test-case",         reason = "loop a const array of cases" },
    { crate = "assert_matches",    reason = "assert!(matches!(..))" },
    { crate = "assert_fs",         use-instead = "tempfile" },
    { crate = "expect-test",       reason = "write expected values by hand" },
    { crate = "serial_test",       reason = "static LazyLock<Mutex<()>> guard, or --test-threads=1" },
    { crate = "snapbox",           reason = "write expected values by hand" },
    { crate = "trycmd",            reason = "CARGO_BIN_EXE_<name> plus a local helper" },
]

[bans.workspace-dependencies]
unused = "deny"
duplicates = "deny"

[advisories]
yanked = "deny"

[licenses]
allow = ["MIT", "Apache-2.0", "Apache-2.0 WITH LLVM-exception", "BSD-3-Clause", "ISC", "Unicode-3.0"]
```

The `deny` list groups crates by job: error handling (hand-written types only, see `crates.md`), database (`sqlx` only), HTTP client (`reqwest` only), web (`axum` only), logging (`tracing` only), and the test crates the testing profile rejects. `env_logger` is rarely transitive, so it is listed; `log` is not, see below.

`multiple-versions` warns because transitive duplicates are rarely yours to fix. `wildcards` denies `version = "*"` and version-less path or git dependencies; `allow-wildcard-paths` exempts version-less path and git dependencies in crates with `publish = false`, and path or git dev-dependencies in any crate. `workspace-dependencies.unused` fails on a `[workspace.dependencies]` entry nobody uses, and `duplicates` fails when two or more members declare the same crate and at least one skips `workspace = true`.

**`[bans]` is graph-wide, which limits what belongs here.** cargo-deny checks every crate in the dependency graph, not just your direct dependencies. So a crate that arrives transitively cannot be denied without failing the build on somebody else's dependency. Three of this policy's bans are like that:

- **`log`**: pulled in by a large share of the ecosystem. Banned as policy, enforced on *direct* dependencies by review and `rust-review`, not by `deny.toml`.
- **`once_cell` / `lazy_static`**: also common transitively, so they get the same treatment.

The `deny` list above therefore covers only crates a developer would have to add deliberately. For the transitive-common ones, `rust-review` is the only enforcement; `cargo tree -e normal --depth 1` shows what was declared. cargo-deny's `wrappers` field can allow named parents of a denied crate, but maintaining that list for something as widespread as `log` is not worth it.

**Why a deny-list and not an allow-list.** `[bans]` also supports `allow = [...]`, where anything absent is denied, which is this policy. It is impractical: the list applies to the whole transitive graph, so allowing `axum` means also listing `hyper`, `http`, `tower`, `bytes`, `mio` and a hundred more, and every patch release churns it. The deny-list catches what this policy cares about (the direct dependency somebody reached for); `rust-review` catches unlisted direct dependencies. Revisit `allow-workspace = true` with a full allow-list only if supply-chain requirements ever demand it.

**Keep it in sync.** Every crate named in **Never allowed** or **Rejected, with reasons** gets a matching `deny` line, except `log`, `once_cell` and `lazy_static` (see above). Open-ended entries such as "every other ORM" need no line of their own. **Not allowed without permission** entries (`itertools`, `indexmap`, `rayon` and the rest) arrive transitively through common crates, so they get no `deny` line; `rust-review` blocks them as direct dependencies until permission is granted. The file is the executable copy of this document.

### `Cargo.toml`
`[lints.rust]` and `[lints.clippy]` from `rust/references/linting.md`. In a workspace, put them under `[workspace.lints]` and give every member `[lints] workspace = true`. Group lints take a negative `priority` so individual entries win. Set `rust-version` and `edition = "2024"`.

Dependencies: only the crates the chosen profile allows, each with an explicit feature list. Nothing "for later".

### `clippy.toml`
From `rust/references/linting.md`: thresholds, `disallowed-methods`, `msrv` matching `rust-version`.

### `rustfmt.toml`
From the same file. Drop the nightly-only keys unless CI runs `cargo +nightly fmt`.

### `src/error.rs`
The crate's error enum, its three impls, and the `impl_from!` macro, per `rust/references/errors.md` and `rust/references/architecture.md`. Start with one enum; splitting comes later, when a split signal appears. Re-export from `lib.rs`/`main.rs`.

### `.github/workflows/ci.yml`
```yaml
- run: cargo fmt --all --check
- run: cargo clippy --workspace --all-targets --all-features -- -D warnings
- run: cargo test --workspace
- run: cargo test --doc
- run: cargo deny check
```
Add `cargo machete` and `cargo semver-checks` where they apply. Pin the toolchain with `dtolnay/rust-toolchain` and cache with `Swatinem/rust-cache`.

## 3. Report

List what was written, then state explicitly:
- which profile was applied and which crates it allows;
- that `anyhow`, `thiserror`, and every framework outside the allowlist are banned, and that `cargo deny check` now enforces it;
- anything the interview deferred (a datastore not yet chosen, CI skipped).

## Existing projects

Same files, but do not overwrite silently. Read what is there, show a diff of the intended change, and get approval before touching a config the project already has. Banned crates already in `Cargo.toml` are reported as findings, not deleted. Removing `anyhow` from working code is a refactor, not a setup step, and belongs in its own change.
