---
disable-model-invocation: true
name: rust-setup
description: Scaffold a new Rust project from the rust skill: short interview, then deny.toml, Cargo.toml lints, clippy.toml, rustfmt.toml, src/error.rs and CI.
---

# Rust Project Setup

Interview, then write the configuration. Rules come from the `rust` skill. Read `rust/references/crates.md` and `rust/references/linting.md` before writing anything, and copy their current content rather than the examples in this file, which may lag.

## 1. Interview

Ask only what changes the output. Skip a question whose answer is already visible in the repo or was given in the request. Prefer `AskUserQuestion` — one call, all open questions at once.

| Question | Changes |
| --- | --- |
| Shape: CLI, web service, library, desktop/TUI? | which profile's crates go in `Cargo.toml`; whether `clap`/`axum`/`tauri` appear |
| Single crate or workspace? | `[workspace]` + `[workspace.dependencies]` + `[workspace.lints]`, or plain `[package]` |
| Datastore? | `sqlx` with which engine feature; whether CI needs `DATABASE_URL` or a committed `.sqlx/` cache |
| Published to crates.io, or internal? | `missing_docs`, `#[non_exhaustive]` strictness, `cargo-semver-checks` in CI |
| Does it need `unsafe`? | `unsafe_code = "forbid"` vs `"deny"` |
| MSRV, or latest stable? | `rust-version` in `Cargo.toml`, `msrv` in `clippy.toml` |
| CI: GitHub Actions, or none? | whether to write `.github/workflows/ci.yml` |

Defaults when the user says "just pick": single crate, latest stable, internal, no `unsafe`, GitHub Actions.

## 2. Write

Every project gets all of these. State the file list before writing, then write them.

### `deny.toml`

The executable copy of the allowlist, written whole. Check it against `rust/references/crates.md` § Never allowed and § Not allowed without permission before writing, and add any entry those sections have gained. Schema: [cargo-deny bans docs](https://embarkstudios.github.io/cargo-deny/checks/bans/cfg.html).

```toml
# deny.toml — workspace root
[graph]
all-features = true

[bans]
multiple-versions = "warn"          # transitive duplicates are usually not yours to fix
wildcards = "deny"                  # no `version = "*"`

deny = [
    # error handling — hand-written types only, see crates.md
    { crate = "anyhow",       reason = "erases the error type; write a concrete enum" },
    { crate = "thiserror",    reason = "boilerplate only; hand-write Display/Error/From" },
    { crate = "eyre",         reason = "same slot as anyhow" },
    { crate = "color-eyre",   reason = "same slot as anyhow" },
    { crate = "miette",       reason = "same slot as anyhow" },
    { crate = "snafu",        reason = "same slot as anyhow" },

    # database — sqlx only
    { crate = "diesel",    use-instead = "sqlx" },
    { crate = "sea-orm",   use-instead = "sqlx" },
    { crate = "rusqlite",  use-instead = "sqlx with features = [\"sqlite\"]" },

    # http client — reqwest only
    { crate = "ureq",      use-instead = "reqwest with features = [\"blocking\"]" },
    { crate = "attohttpc", use-instead = "reqwest" },

    # web — axum only
    { crate = "actix-web", use-instead = "axum" },
    { crate = "rocket",    use-instead = "axum" },
    { crate = "warp",      use-instead = "axum" },
    { crate = "poem",      use-instead = "axum" },
    { crate = "salvo",     use-instead = "axum" },
    { crate = "ntex",      use-instead = "axum" },
    { crate = "loco-rs",   use-instead = "axum" },

    # logging — tracing only (env_logger is rarely transitive; `log` is not listed, see note below)
    { crate = "env_logger", use-instead = "tracing-subscriber" },

    # test crates rejected in the testing profile
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
]

[bans.workspace-dependencies]
unused = "deny"                     # a dep nobody uses is a dep to delete
duplicates = "deny"                 # members must inherit with `workspace = true`

[advisories]
version = 2
yanked = "deny"

[licenses]
version = 2
allow = ["MIT", "Apache-2.0", "Apache-2.0 WITH LLVM-exception", "BSD-3-Clause", "ISC", "Unicode-3.0"]
```

**`[bans]` is graph-wide — that limits what belongs here.** cargo-deny checks every crate in the dependency graph, not just your direct dependencies. So a crate that arrives transitively cannot be denied without failing the build on somebody else's dependency. Three of this policy's bans are like that:

- **`log`** — pulled in by a large share of the ecosystem. Banned as policy, enforced on *direct* dependencies by review and `rust-review`, not by `deny.toml`.
- **`once_cell` / `lazy_static`** — same situation, extremely common transitively. Same treatment.

The `deny` list above therefore covers only crates a developer would have to add deliberately. For the transitive-common ones, `[bans.workspace-dependencies]` plus review is the enforcement, and `cargo tree -e normal --depth 1` shows what was actually declared. cargo-deny's `wrappers` field can allow named parents of a denied crate, but maintaining that list for something as widespread as `log` is not worth it.

**Why a deny-list and not an allow-list.** `[bans]` also supports `allow = [...]`, where anything absent is denied — which is literally this policy. It is impractical: the list applies to the whole transitive graph, so allowing `axum` means also listing `hyper`, `http`, `tower`, `bytes`, `mio` and a hundred more, and every patch release churns it. The deny-list catches what this policy actually cares about — the direct dependency somebody reached for — while `workspace-dependencies.unused` catches the rest by attrition. Revisit `allow-workspace = true` with a full allow-list only if supply-chain requirements ever demand it.

**Keep it in sync.** Every new entry in **Never allowed** or **Not allowed without permission** gets a matching `deny` line, and a granted permission gets its line removed with the approval noted in the reason. The file is the executable copy of this document.

### `Cargo.toml`
`[lints.rust]` and `[lints.clippy]` from `rust/references/linting.md`. In a workspace, put them under `[workspace.lints]` and give every member `[lints] workspace = true`. Group lints take a negative `priority` so individual entries win. Set `rust-version` and `edition = "2024"`.

Dependencies: only the crates the chosen profile allows, each with an explicit feature list. Nothing "for later".

### `clippy.toml`
From `rust/references/linting.md` — thresholds, `disallowed-methods`, `msrv` matching `rust-version`.

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

Same files, but do not overwrite silently. Read what is there, show a diff of the intended change, and get approval before touching a config the project already has. Banned crates already in `Cargo.toml` are reported as findings, not deleted — removing `anyhow` from working code is a refactor, not a setup step, and belongs in its own change.
