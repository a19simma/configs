# Prescribed Crates — Allowlist

## The rule

**No crate may be added unless it appears in a profile below, or the user has given express permission for that specific crate.**

If a job is not covered here: write it with `std`, or stop and ask. "It's only one small dependency" is not a reason. Every dependency is compile time, semver risk, audit surface, and supply-chain surface.

**Monoculture.** One crate per job, organisation-wide. Where two crates do the same work, this document names one and bans the rest, even when the loser is the better fit for some single project. A second HTTP client, query layer, logging facade or web framework means two sets of idioms, two failure modes, two upgrade paths, and code that cannot move between services. The word appears throughout as the reason for a ban.

Adding an allowed crate still requires:
- `default-features = false` plus an explicit feature list where the crate supports it — but **read what the defaults were before switching them off**. Disabling defaults on `regex` drops Unicode handling, on `reqwest` drops the TLS backend, on `tokio` drops the runtime itself. The goal is a deliberate feature list, not the smallest one.
- Declared in `[workspace.dependencies]`, inherited by members with `crate.workspace = true`.
- Passing `cargo deny check` and not appearing in `cargo machete` output.

Citations below are verbatim quotes from each project's own documentation, fetched and checked rather than recalled. Where a claim is this skill's judgement rather than the vendor's, it is written as a **Rule** or **Why**, not as a quote.

---

## Core — allowed in every project

### `serde` (+ `serde_json`)

> "a framework for **_ser_**ializing and **_de_**serializing Rust data structures efficiently and generically"
> — [serde.rs](https://serde.rs/)

**Rule:** the only sanctioned serialization layer. `serde_json` for JSON; add `toml` only if the project reads TOML config.
**Why:** hand-rolled parsing of external data is where bugs and CVEs live, and serde is compile-time generated, so it costs no runtime reflection.

### Error handling — no crate

`anyhow` and `thiserror` are both **banned outright**. Every fallible function returns a hand-written typed enum.

Writing or reviewing error types: read `errors.md`. It carries the handle-vs-report axis, the three impls, the `From` chain, crate-level enums and when to split them, the message convention, and when erasure to `BoxError` is allowed.

### `tracing` (+ `tracing-subscriber`)

> "tracing is a framework for instrumenting Rust programs to collect structured, event-based diagnostic information"
> — [tokio-rs/tracing](https://github.com/tokio-rs/tracing)

The same README on why plain logging fails under async:

> "the span remains entered for as long as the future exists, rather than being entered only when it is polled, leading to very confusing and incorrect output"

**Rule:** required in any binary that runs unattended, and the **only** logging facade — `log` and `env_logger` are banned as direct dependencies, including in synchronous CLIs. `println!` is not logging.
**Why:** in concurrent code a flat log line cannot say which request it belongs to; a span can, and `#[instrument]` attaches the span to the future so it is entered only while polled.

**Features:** `tracing-subscriber = { features = ["env-filter", "fmt", "tracing-log"] }`.

#### `tracing` and `log` — three separate directions

| Direction | Mechanism | State |
| --- | --- | --- |
| Your code → output | `tracing::info!` events, rendered by the `fmt` layer | this *is* your logging; never write `log::info!` |
| Dependencies' `log` records → your subscriber | `LogTracer`, from the `tracing-log` feature | **on by default — keep it** |
| Your events → a `log` logger | `tracing`'s `log` / `log-always` features | off, and stays off |

**Dependency logs are captured for free, but the switch is easy to flip off by accident.** Per [`tracing_subscriber::fmt::init`](https://docs.rs/tracing-subscriber/latest/tracing_subscriber/fmt/fn.init.html):

> "If the `tracing-log` feature is enabled, this will also install the `LogTracer` to convert `Log` records into `tracing` `Events`."

That feature is on by default, so a dependency calling `log::warn!` lands in your subscriber with your filter applied. Setting `default-features = false` on `tracing-subscriber` — which this document's feature rule otherwise pushes toward — silently removes that bridge and your dependencies go quiet. Hence the explicit `tracing-log` in the feature list above. Banning `log` as a *direct* dependency does not mean suppressing it transitively; it means one call-site idiom and one output stream.

**Do not enable `tracing`'s `log` or `log-always` features.** From the [`tracing` docs](https://docs.rs/tracing/latest/tracing/): the `log` feature emits a `log` record "if no `tracing` Subscriber is active", and `log-always` emits "even if a `tracing` Subscriber is set" — the docs add that "libraries generally should not enable the 'log-always' feature". With no `log` logger installed there is nothing to receive them, and `log-always` doubles every line.

**Trap:** the subscriber must be initialised explicitly or nothing is emitted at all — no warning, no output. Initialise it on the first line of `main`.

---

## Core — std gaps

`std` has no answer at all for these four jobs. Not ergonomics — missing capabilities. Allowed everywhere, no request needed.

| Crate | Job | Adoption | Note |
| --- | --- | --- | --- |
| [`rand`](https://docs.rs/rand/) | random number generation | 10/14 | No RNG in `std`. `rand::rng()` for general use; `rand::rngs::OsRng` for anything security-relevant. |
| [`regex`](https://docs.rs/regex/) | regular expressions | 9/14 | No regex in `std`. Linear-time, no backtracking, so no ReDoS. Compile patterns once into a `LazyLock<Regex>`, never inside a loop. |
| [`uuid`](https://docs.rs/uuid/) | UUID type | 6/14 | No UUID in `std`. `features = ["v4", "serde"]`; v7 when you want time-sortable ids. |
| [`jiff`](https://docs.rs/jiff/) or [`chrono`](https://docs.rs/chrono/) | dates, times, timezones | 10/14 combined | No date/time arithmetic in `std` — only `Instant`/`SystemTime`. **One per project.** `jiff` for new code (tz-correct by construction); `chrono` when a dependency already exposes it in its API (sqlx, serde ecosystems) and mixing would mean converting at every boundary. |

Still bound by the general rules: explicit features, workspace-declared. `regex-lite` is the swap when binary size matters more than speed; `fastrand` when randomness quality does not matter and you want no dependency tree.

## Profile: CLI

Opt in when the deliverable is a command-line binary. A service or a Tauri app does not get these by default.

### `clap` — argument parsing

> "Command Line Argument Parser for Rust"
> — [clap docs](https://docs.rs/clap/latest/clap/)

**Rule:** derive API (`features = ["derive"]`), not the builder. **Floor:** below roughly one flag and one positional argument, use `std::env::args()` and take no dependency — clap is the usual answer to "why is my Rust CLI 4MB".
**Why:** `std::env::args()` hands you a `Vec<String>`; flag/value pairing, `-abc` bundling, the `--` terminator, subcommand routing, type conversion, error messages and the whole help text are yours to write and keep in sync. Help text drifting from behaviour is the classic CLI failure, and it is exactly what the lightweight alternatives (`lexopt`, `pico-args`, `argh`) hand back to you.

Its docs commit to semver with breaking majors "typically spacing major breaking changes 6-9 months apart" while supporting the last two minor Rust releases — budget for a major bump roughly annually across every binary.
`clap_complete` is allowed as part of this entry for shell-completion generation. Machine-readable output for a CLI is `serde_json` behind a `--format json` flag, already allowed in core.

---

## Profile: async / web service

Opt in only when the project is a network service.

### `tokio`

> "provides the building blocks needed for writing networking applications"
> — [Tokio tutorial](https://tokio.rs/tokio/tutorial)

The same page names when it is the wrong tool:

> "Tokio provides no advantage here compared to an ordinary threadpool"  (bulk file reading)

**Rule:** allowed only where there is genuinely concurrent I/O. Features are explicit — `["rt-multi-thread", "macros", "net", "time"]`, not `["full"]`.
**Why:** async colours every caller and makes tests harder. A CPU-bound job wants threads; a single request wants a blocking call.

### `axum` — HTTP server

> "`axum` doesn't have its own middleware system but instead uses `tower::Service`. This means `axum` gets timeouts, tracing, compression, authorization, and more, for free."
> — [tokio-rs/axum](https://github.com/tokio-rs/axum)

**Rule:** the only allowed HTTP server. `tower`/`tower-http` come with it and are allowed as its middleware layer; `tower` with `features = ["util"]` is allowed as a **dev-dependency** for testing (see below). No other web framework is permitted — not `actix-web`, `rocket`, `warp`, `poem`, `salvo`, `ntex`, or `loco`.

**Why:** shared `tower` middleware means the HTTP and gRPC sides of a service run the same timeout/tracing/auth stack instead of two. And the ecosystem has converged: 110.9M downloads in 90 days against 9.9M for `actix-web`, the nearest alternative — an 11× gap (crates.io, August 2026). `actix-web` carries its own `Service` abstraction, so choosing it means maintaining a second middleware stack alongside `tonic`. `rocket` has had no release since May 2024; `tide` none since 2021.

**Testing needs no dependency.** A `Router` implements `tower::Service`, so tests call it directly — no server, no port:

```rust
use tower::ServiceExt;   // dev-dependency: tower = { features = ["util"] }

let response = app().oneshot(Request::get("/users/7").body(Body::empty())?).await?;
assert_eq!(response.status(), StatusCode::OK);
let bytes = axum::body::to_bytes(response.into_body(), usize::MAX).await?;
```

This is the pattern from [axum's own testing example](https://github.com/tokio-rs/axum/blob/main/examples/testing/src/main.rs): *"`Router` implements `tower::Service<Request<Body>>` so we can call it like any tower service, no need to run an HTTP server."* Use `axum::body::to_bytes` rather than adding `http-body-util`, which that example pulls in. Where the socket itself matters (TLS, streaming, timeouts), bind a `TcpListener` on port 0, `tokio::spawn` the server, and drive it with `reqwest`.

### `tonic` — gRPC

> "a gRPC over HTTP/2 implementation focused on high performance, interoperability, and flexibility"
> — [hyperium/tonic](https://github.com/hyperium/tonic)

**Rule:** allowed only when the `.proto` is doing real work — **consumers in another language or another team**, or streaming that JSON cannot serve. Two Rust services owned by one team do **not** qualify: a shared types crate plus axum JSON gives the same safety with no toolchain. "We might want RPC later" is not a reason. Pulls `prost` (Protobuf codec) and `tonic-build` as a build-dependency — both allowed as part of this entry, neither allowed on their own.

**Disqualifiers.** A browser client (needs a `grpc-web` proxy); a public API consumers must be able to `curl`; a two-service system where an axum JSON endpoint would do. Debugging needs `grpcurl` — the wire is not readable with `curl` or browser devtools — and `.proto` evolution is its own discipline (reserved field numbers, no reuse, backward-compatibility rules).

tonic is additive to `axum`: both sit on `hyper`/`tower` and share one middleware stack, so a service can serve gRPC internally and JSON externally without a second runtime.

**Why:** the cost of gRPC is the schema toolchain (codegen in the build, `.proto` versioning, harder debugging without `grpcurl`). That cost only pays for itself when the schema is doing real cross-team work.

### `reqwest` — HTTP client

> "a convenient, higher-level HTTP Client" that "handles many of the things that most people just expect an HTTP client to do for them"
> — [reqwest docs](https://docs.rs/reqwest/latest/reqwest/)

**Rule:** `default-features = false, features = ["rustls-tls", "json"]`. TLS is on by default via `default-tls`; the docs list `rustls` and `native-tls` as the explicit alternatives, and `native-tls` means OpenSSL on Linux.
**Why:** never bring OpenSSL into a build for a handful of outbound calls — it is a system dependency, a cross-compilation problem, and a CVE feed. `rustls` keeps the stack pure Rust.

**Sync callers use `features = ["blocking"]`, not a second crate.** `ureq` is banned despite being the leaner choice for a tokio-free CLI: monoculture, and `reqwest::blocking` covers the case. Always call `.error_for_status()?` — a 4xx body will otherwise deserialize into something confusing rather than failing.

---

## Profile: native app

### `tauri`

> "Tauri is a framework for building tiny, fast binaries for all major desktop and mobile platforms."
> — [Tauri v2 docs](https://v2.tauri.app/start/)

**Rule:** the sanctioned desktop/mobile shell. Business logic lives in a plain Rust crate the Tauri command layer calls — the Tauri crate must not spread past that boundary.
**Why:** it uses the system webview instead of shipping a browser, and keeping logic outside means it stays testable without a GUI harness. Both surveyed Tauri apps (gitbutler, spacedrive) are structured this way.

**Known costs, accepted.** The frontend is a second toolchain — Node, a bundler, a JS framework — so the "Rust app" is substantially TypeScript. And the webview is the platform's, not yours: WebKitGTK on Linux, WebView2 on Windows, WKWebView on macOS, three engines with different bugs and CSS support. Electron's bloat buys consistency; this trades it for size. Linux needs distro webview packages and CI needs per-platform runners.

Terminal UI instead of a window:

> "Ratatui is a Rust library for building fast, lightweight, and rich terminal user interfaces"
> — [ratatui.rs](https://ratatui.rs/)

Immediate-mode rendering — the whole frame is redrawn each tick, so there is no retained widget tree to keep in sync: your state *is* the source of truth. It ships no terminal backend, so pick one (`crossterm`) and declare it as part of this entry.

---

## Profile: database

One SQL crate, organisation-wide: `sqlx`. 34.2M downloads per 90 days, ahead of every alternative.

### `sqlx` — the only SQL crate

> "an async, pure Rust SQL crate featuring compile-time checked queries without a DSL"
> — [launchbadge/sqlx](https://github.com/launchbadge/sqlx)

The same README, on what it is not:

> "not an ORM"

**Rule:** all SQL access, every engine. `features = ["postgres", "runtime-tokio", "tls-rustls", "macros", "migrate"]` — swap `sqlite` for `postgres` on an embedded database. `rusqlite` is banned: `sqlx` covers SQLite, and monoculture applies.
**Why:** the queries are real SQL checked against a real schema at build time — the type safety of an ORM without the ORM.

**No ORM, ever.** `diesel` (6.5M/90d, 0/14 surveyed), `sea-orm` (4.0M) and the rest are banned. Diesel's pitch — it "eliminate[s] the possibility of incorrect database interactions at compile time" ([diesel.rs](https://diesel.rs/)) — is the same guarantee sqlx gives by a different route, and a second query layer means two dialects of database code in one organisation. Its one genuine advantage, needing no live database at build time, is answered by `cargo sqlx prepare` and a checked-in `.sqlx/` offline cache.

**Build-time database.** The `query!` macros verify against a live schema, so CI needs `DATABASE_URL` at compile time or a committed `.sqlx/` cache regenerated whenever a query changes. Pick one per project and write it in the README — a stale cache fails confusingly. `sqlx::query` without the `!` skips checking entirely and is the escape hatch for genuinely dynamic SQL.

---

## Profile: testing (dev-dependencies)

Allowed in `[dev-dependencies]` only — never in `[dependencies]`. The `std`-gap crates (`rand`, `regex`, `uuid`, one date crate) are allowed here as well.

| Crate | Job | Adoption (26 repos) |
| --- | --- | --- |
| [`tempfile`](https://docs.rs/tempfile/) | temp files/dirs, removed on drop even on panic | **18/26** — the most-used test dependency in Rust |
| `tower` with `features = ["util"]` | `ServiceExt::oneshot`, to call an axum `Router` directly in tests | axum projects only — `tower` is already a runtime dependency there |

That is the whole list. Everything else a test needs is `std`, cargo, or a helper you write once per crate — see `testing.md` for the CLI-runner and fake-port patterns.

### Permission required

| Crate | Adoption | When to ask |
| --- | --- | --- |
| [`testcontainers`](https://crates.io/crates/testcontainers) | 2/26 — both database-shaped (datafusion, loco) | A project with a real datastore where CI does **not** already provision one. Where a compose file or CI service container exists, connect to that instead: same coverage, no dependency, no Docker daemon required inside the test process. Ask with the datastore named and a note on why the CI-provisioned route does not fit. |
| [`loom`](https://docs.rs/loom/) | — | Exhaustive concurrency-interleaving checks. Ask when hand-writing a lock-free structure or a `Sync` primitive. |
| [`tokio-test`](https://docs.rs/tokio-test/) / [`tower-test`](https://docs.rs/tower-test/) | 2/26 each — vector, linkerd2-proxy | Hand-writing a `Future`, `Stream`, `AsyncRead`/`AsyncWrite` or tower `Service`, where the assertion is about poll states (`Pending` before the wake, `Ready` after, waker registered) rather than the returned value. Granted on that basis because the alternative is a hand-rolled `RawWakerVTable`, which is worse than the dependency. Ordinary async tests use `#[tokio::test]`, which ships with `tokio`. |

### Rejected, with reasons

| Crate | Adoption | Why not |
| --- | --- | --- |
| `mockall` | 0/26 | Trait mocking. Not one repo in the survey uses it. Its expectation API (`times`, `in_sequence`) asserts on *how* the code calls its dependency — implementation detail, and the exact thing a test should not pin. Hand-write the fake struct; a port trait narrow enough to be a good port is narrow enough to implement inline. |
| `wiremock` / `mockito` | 2/26, 1/26 | HTTP mock servers. Abstract outbound HTTP behind a port trait and fake that. Where the wire itself must be exercised, bind a `std::net::TcpListener` on port 0 and write the handler — canned responses are a small amount of code, and the listener gives a real port with no dependency. |
| `pretty_assertions` / `similar-asserts` | 6 / 2 of 26 | Prettier diffs on a failing `assert_eq!`. Real ergonomics, no new capability. |
| `assert_cmd` + `predicates` | 4/26 | CLI end-to-end. Rejected: cargo already exports `CARGO_BIN_EXE_<name>`, so locating the binary — the part that looks hard — is std. What remains is UTF-8 conversion and a nicer panic message, for two dependencies. A fifteen-line local helper returning `(code, stdout, stderr)` covers it. |
| `criterion` | 10/26 | Benchmarking. Rejected: the largest dev dependency tree on the list (plotters, clap, regex, serde_json, rayon), minutes per run, and meaningful only against a stored CI baseline on stable hardware — on a laptop the numbers are decoration. Performance work starts with a profiler, which is tooling, not a dependency. |
| `divan` | 2/26 | Same category as `criterion`, same answer. |
| `proptest` | 7/26 | Property-based testing. Rejected: it pays only where a real invariant exists, and outside parsers and encoders most code has no property that is not a restatement of the implementation. Edge cases are covered by named example tests; genuine input-space exploration belongs in `cargo-fuzz`, which is tooling, not a dependency. |
| `insta` | 8/26 | Snapshot testing. Rejected despite solid adoption: an accepted snapshot records an observation, not an intent, so a test states nothing about what it is checking; and `cargo insta accept` on an unread diff silently converts a regression into the baseline. Write expected values by hand — the resulting cap on output size is a design signal, not a limitation. |
| `quickcheck` | 3/26 | Same category as `proptest`, same answer. |
| `test-case` / `assert_matches` / `assert_fs` / `expect-test` / `serial_test` / `snapbox` / `trycmd` | 1–3 of 26 each | Each duplicates something on this list or in `std` (`assert!(matches!(..))`, a loop over a `const` array, `tempfile`). |

**`rstest` — 6/26, and 4 of the 11 service repos** (qdrant, vector, datafusion, loco) against 2 of the 15 tool repos. Rejected on a considered re-read of that split, not on the weaker tool-only number. It does two separable things and neither is a capability: table cases become a `#[test]` looping a `const` array with the input in the assert message, and fixtures become a plain function call at the top of the test. The service skew is real and comes from the fixture half — service tests have setup that composes (pool needs container needs config). If this codebase turns service-shaped and that composition gets painful, this is the entry to revisit first.

### Tooling — not dependencies

Installed binaries, so the allowlist does not apply: `cargo-nextest` (per-test process isolation), `cargo-llvm-cov` (coverage), `miri` (UB in `unsafe`), `cargo-fuzz`, and the profilers — `samply`, `cargo-flamegraph`, `perf`, Instruments. Profiling answers *where* the time goes, which is the question benchmarking usually gets asked in place of.

---

## Adoption evidence

Per-crate counts below come from reading the workspace `Cargo.toml` of 26 real repositories. Method, cohort list, cohort bias, and the table of banned crates with high adoption: `adoption.md`. Read it when a ban is being challenged or a new crate is proposed.

## Never allowed

`anyhow` — see the error handling section. No exception, no feature flag, no `main.rs` carve-out.

`diesel`, `sea-orm`, and every other ORM or query DSL. `sqlx` is the only SQL crate; monoculture.

`rusqlite` — `sqlx` with `features = ["sqlite"]` covers embedded SQLite, with compile-time checked queries that `rusqlite` cannot offer.

`thiserror` — a derive that writes `Display`, `Error::source` and `From` from message strings you supply yourself. The impls are ~25 lines; a `macro_rules!` covers the repetitive part. Not requestable.

`eyre`, `color-eyre`, `miette`, `snafu` — same slot as `anyhow`, same answer.

`log`, `env_logger`. `tracing` is the only logging facade, in CLIs as well as services; monoculture.

`ureq`, `attohttpc`, and other HTTP clients — `reqwest` with `features = ["blocking"]` covers synchronous callers.

**Any web framework other than `axum`** — `actix-web`, `rocket`, `warp`, `poem`, `salvo`, `ntex`, `loco`. Not requestable. Monoculture, and a second stack means a second middleware layer, a second set of extractor idioms, and no shared `tower` code with `tonic`.

## Not allowed without permission

`lazy_static`/`once_cell` (use `std::sync::LazyLock`), `itertools`, `derive_more`, `strum`, `rayon`, `dashmap`, `indexmap`, `nom`/`winnow`, any crate whose job `std` already does.

Each of these is a fine crate. None is automatic.

## Enforcement

Every project carries a `deny.toml` at the workspace root from its first commit, and CI runs `cargo deny check` beside `clippy` and `fmt`. `rust-setup` writes it; its content is generated from the ban sections above.

Two rules the config cannot express itself:

- **Keep it in sync.** A new entry in **Never allowed** or **Not allowed without permission** gets a matching `deny` line. A granted permission gets its line removed, with the approval in the `reason` field.
- **`[bans]` is graph-wide.** cargo-deny checks every crate in the dependency graph, so a crate that arrives transitively cannot be denied without failing on somebody else's dependency. `log`, `once_cell` and `lazy_static` are therefore banned as *direct* dependencies only, enforced by `rust-review`, never by `deny.toml`.

## Requesting an addition

State: the job, the `std`-only alternative and why it fails, the crate, its maintenance signal (last release, maintainer count, downloads), its transitive dependency count (`cargo tree -e normal | wc -l`), and its licence. Then wait for approval.
