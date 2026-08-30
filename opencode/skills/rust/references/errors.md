# Error Handling

No crate. `anyhow` and `thiserror` are both banned; see `crates.md` for the ruling. Write the type and its three impls by hand.

## How we do it

The Book covers `Result`, `?`, and `std::error::Error`. It does **not** mention `thiserror` or `anyhow` — those are ecosystem convention. This codebase does not follow that convention.

**`anyhow` is never allowed.** Not in binaries, not in `main.rs`, not behind a feature flag. **`thiserror` is not allowed either.**

**Why.** `anyhow::Error` erases the error type. Once a value is an `anyhow::Error`, no caller can ask what went wrong — only `downcast_ref`, which is a stringly-typed API in a hat. It is sold as harmless "at the top layer, where nobody branches", but the top layer moves: today's `main` is tomorrow's library function, and by then every intermediate signature has forgotten what it could fail with. It also makes the lazy path the default — `?` swallows anything, so nothing forces you to decide whether a failure is recoverable.

**`thiserror` is banned too.** It is a boilerplate remover and nothing else: you write the enum and every `#[error("...")]` message string yourself, and the derive expands them into the `Display`, `Error::source` and `From` impls shown below. It infers nothing and generates no message you did not type. A `macro_rules!` in `src/error.rs` covers the repetitive part (see `architecture.md`) with no proc-macro in the build.

### What you write instead

You write the specific type — which you would write anyway, with or without a derive macro — plus three impls:

```rust
#[derive(Debug)]
pub enum StoreError {
    NotFound(UserId),
    Db(sqlx::Error),
}

impl std::fmt::Display for StoreError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NotFound(id) => write!(f, "user {id} not found"),
            Self::Db(_) => write!(f, "database failure"),
        }
    }
}

impl std::error::Error for StoreError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            Self::Db(e) => Some(e),
            Self::NotFound(_) => None,
        }
    }
}

impl From<sqlx::Error> for StoreError {
    fn from(e: sqlx::Error) -> Self { Self::Db(e) }
}
```

That is the entire cost. `From` makes `?` convert automatically; `source()` preserves the chain so a caller can walk it. This is exactly what `thiserror` expands to — the derive reads your `#[error("...")]` string literals and emits these `match` arms. It infers nothing, and generates no message you did not write.

### Rules

1. **Every fallible function returns a typed error.** No erasure for "the caller only propagates it" — that is a prediction about the future, and it is the expensive one to get wrong. Typing is reversible (erase later in one line); erasure is not (`downcast_ref` needs the type you threw away).
2. **`Result<T, String>` and `Result<T, Box<dyn Error>>` are out** as default return types. Neither lets a caller branch; `String` has no `source()`.
3. **Errors implement `Error + Display + Debug`, and are `Send + Sync + 'static`** — required to nest inside `std::io::Error` and to cross threads ([API Guidelines C-GOOD-ERR](https://rust-lang.github.io/api-guidelines/interoperability.html#error-types-are-meaningful-and-well-behaved-c-good-err)).
4. **Variants name the problem domain, not the dependency.** `Db(sqlx::Error)` is fine as a leaf; `SqlxFailed` as a public variant is not.
5. **`#[non_exhaustive]` on every public error enum**, so adding a variant is not a breaking change.

### One enum per crate, split when it earns it

**Default: a single crate-level error enum.** This is the mainstream Rust shape, not a compromise — [`sqlx::Error`](https://github.com/launchbadge/sqlx/blob/main/sqlx-core/src/error.rs) is one `#[non_exhaustive]` enum of ~20 variants (`RowNotFound`, `PoolTimedOut`, `Database`, `Tls`, …); `std::io::Error`, `serde_json::Error` and `rusqlite::Error` are the same. Callers match the one or two recoverable variants and `_` the rest. That is the intended usage, not a smell.

Note what `#[non_exhaustive]` already concedes: external callers are **forced** to write a `_` arm regardless. So "a catch-all destroys exhaustiveness" costs nothing across a public API — it was given up deliberately the moment adding a variant became non-breaking. Exhaustiveness still works inside the crate, where the attribute does not apply to you, and consolidation does not take that away.

**Split into scoped enums when a function family has a distinct recoverable set.** Splitting is cheap because the narrow types compose upward through `From`:

```rust
pub enum ReadError    { NotFound(Id), Decode(DecodeError), Db(DbError) }
pub enum WriteError   { Conflict(Id), Constraint(String), Db(DbError) }
pub enum ConnectError { Timeout, Tls(TlsError), Refused }

#[non_exhaustive]
pub enum Error {                       // crate-level enum still exists
    Read(ReadError),
    Write(WriteError),
    Connect(ConnectError),
}
// From<ReadError> for Error, etc. — `?` widens automatically
```

`fn get() -> Result<User, ReadError>` shows a caller three variants, all of which can actually occur. A caller that does not care still `?`s straight into `Error` and never sees the difference. **Narrow at the function, wide at the boundary.**

**Trigger for splitting** — a signal, not taste:
- callers writing `_ => unreachable!()`, or matching on variants the function cannot produce;
- a `# Errors` doc section that lists 3 of the enum's 20 variants;
- two operation families with no overlap in their recoverable failures (read vs write vs connect).

Until one of those appears, stay with the single enum. Costs of splitting, to weigh: a shared leaf (`Db`) now appears in several sub-enums, so "any database failure" becomes a multi-arm match; and each split adds a `From` impl — use the `macro_rules!` above.

### Consequences of a wide enum

**The signature stops documenting failure modes.** `fn ping() -> Result<(), Error>` tells the caller nothing about which of the twenty can occur. Docs must carry it: a `# Errors` section on every public fallible fn, enforced by `clippy::missing_errors_doc` (already on in `linting.md`).

**Enum size.** A crate-wide enum is as large as its fattest variant, and every `Result<T, Error>` in the crate pays that — including hot paths that return `Ok`. Box large payloads. `clippy::result_large_err` and `clippy::large_enum_variant` catch it; both are already enabled.

### Message convention

Rust is **not** Go. In Go, `fmt.Errorf("reading config: %w", err)` folds the child's text into the parent, so one `Error()` call yields the whole colon-joined chain. Rust splits the two jobs: each `Display` prints **only its own layer**, and a reporter walks `source()` to assemble the chain.

std states the rule directly — a wrapped error should be either returned by `Error::source()` **or** rendered in `Display`, [not both](https://doc.rust-lang.org/std/error/trait.Error.html), to avoid duplicating the same context across the chain.

```rust
// WRONG — Go habit. Duplicates every layer below it once a reporter walks source().
write!(f, "reading config: {}", self.source)

// RIGHT — this layer only. The chain is assembled by the reporter.
write!(f, "reading config")
```

Message style, per the [`std::error::Error` docs](https://doc.rust-lang.org/std/error/trait.Error.html): concise, **lowercase, no trailing punctuation** — `invalid digit found in string`, not `Invalid digit found in string.`. No `"Error: "` prefix; the reporter adds that.

Rendering is the reporter's choice, and both are legitimate:

```
error: signup failed          # multi-line, one layer per line (anyhow/eyre style)
  caused by: database failure
  caused by: connection refused (os error 61)

error: signup failed: database failure: connection refused (os error 61)   # Go-style one-liner
```

Same `Display` impls produce both — because they contain no chaining. Pick one format in the reporter and keep it. Multi-line for a CLI a human reads; single-line where a log line must stay one line.

### Erasure — last resort

Erasure is a **one-way door**. Once a value is `Box<dyn Error>`, the only way back is `downcast_ref` — a fallible runtime check that requires naming the concrete type you avoided writing, with no exhaustiveness and no compile error when a new case appears.

So the bar is not "nobody branches on this today". It is: **the error set cannot be enumerated, because someone outside this crate writes the implementations.**

```rust
pub type BoxError = Box<dyn std::error::Error + Send + Sync + 'static>;

trait Plugin {
    fn run(&self) -> Result<(), BoxError>;   // third-party impls — set is structurally open
}
```

**That is the only sanctioned use.** `main`, HTTP handlers, and background tasks are *closed* sets — they get a real top-level enum like everything else. Every `BoxError` in the codebase carries a comment saying why the set cannot be enumerated.

Std supplies the conversion, so widening into it needs no code:

```rust
impl<E: Error + Send + Sync + 'static> From<E> for Box<dyn Error + Send + Sync>
```

(That blanket impl is legal only because `Box<dyn Error>` does not itself implement `Error`, so it does not overlap std's reflexive `impl<T> From<T> for T`. The same impl is impossible to write for your own error enum — which is why per-layer `From` impls exist at all.)

**Always `+ Send + Sync`.** Bare `Box<dyn Error>` cannot cross a thread, enter `tokio::spawn`, or nest into `io::Error::new`. Free now, painful to retrofit.

**Gotcha:** `fn main() -> Result<(), E>` prints only `Error: {Debug}` of the outer error — `Termination` does not walk `source()`, so the chain is lost. Keep the manual reporter:

```rust
fn main() -> ExitCode {
    if let Err(e) = run() {
        report(&e);
        return ExitCode::FAILURE;
    }
    ExitCode::SUCCESS
}
```

### Evidence that this is workable

Checked against real workspace `Cargo.toml` files, not blog posts. Several substantial projects already ship with no error crates:

| Repo | Started | Error stack |
| --- | --- | --- |
| [microsoft/edit](https://github.com/microsoft/edit/blob/main/Cargo.toml) | 2025 | none — almost no third-party dependencies at all |
| [tokio-rs/toasty](https://github.com/tokio-rs/toasty/blob/main/Cargo.toml) | 2024 | none — hand-written error type |
| [polars](https://github.com/pola-rs/polars/blob/main/crates/polars-error/Cargo.toml) | 2020 | none — dedicated `polars-error` crate |
| [ripgrep](https://github.com/BurntSushi/ripgrep/blob/master/Cargo.toml) | 2016 | `grep-*` libraries hand-write their error types |

The majority position is the opposite, and this file records that honestly: [uv](https://github.com/astral-sh/uv/blob/main/Cargo.toml), [ruff](https://github.com/astral-sh/ruff/blob/main/Cargo.toml), [zed](https://github.com/zed-industries/zed/blob/main/Cargo.toml), [deno](https://github.com/denoland/deno/blob/main/Cargo.toml), [wasmtime](https://github.com/bytecodealliance/wasmtime/blob/main/Cargo.toml), [turso](https://github.com/tursodatabase/turso/blob/main/Cargo.toml) and [pixi](https://github.com/prefix-dev/pixi/blob/main/Cargo.toml) all ship both crates, and [jj](https://github.com/jj-vcs/jj/blob/main/Cargo.toml) uses `eyre`. [rust-analyzer](https://github.com/rust-lang/rust-analyzer/blob/master/Cargo.toml) and [oxc](https://github.com/oxc-project/oxc/blob/main/Cargo.toml) take `anyhow` but no derive crate.

Note what the newer cohort splits on: `thiserror` is genuinely optional — rolldown, oxc, toasty and edit ship without it — while the reporter slot is contested rather than settled (anyhow vs `eyre` vs `miette`). A slot with three competing answers and no consensus is a slot worth filling with ten lines of your own code.

**No authority is being overruled here.** The [Rust Foundation](https://rustfoundation.org/media/rust-foundations-2025-technology-report-showcases-year-of-rust-security-advancements-ecosystem-resilience-strategic-partnerships/) publishes supply-chain infrastructure (Trusted Publishing, TUF signing) but issues no guidance on which crates to depend on. [blessed.rs](https://blessed.rs/crates) is community curation, not doctrine. The strongest design argument in the space is about types, not crates: *"Specific types make writing good documentation easier. They repay their weight in gold when you start testing your code"* — [mmapped.blog, *Designing error types in Rust*](https://mmapped.blog/posts/12-rust-error-handling). Hand-written impls satisfy that in full.

