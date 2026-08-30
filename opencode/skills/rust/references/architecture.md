# Architecture

Sources: [The Rust Book ch.7 (packages, crates, modules)](https://doc.rust-lang.org/book/ch07-00-managing-growing-projects-with-packages-crates-and-modules.html), [ch.17 OOP patterns](https://doc.rust-lang.org/book/ch17-00-oop.html), [API Guidelines](https://rust-lang.github.io/api-guidelines/checklist.html), [Rust Design Patterns](https://rust-unofficial.github.io/patterns/).

## Module layout

Use the 2018+ file convention — `foo.rs` + `foo/` — not `mod.rs`. Directory listings stay readable.

```
src/
  lib.rs        # pub use re-exports = the crate's actual API surface
  domain.rs     # types + invariants, zero I/O deps
  domain/
    user.rs
    money.rs
  ports.rs      # traits the domain needs (Repo, Clock, Mailer)
  adapters/     # impls: postgres.rs, http.rs, fs.rs
  app.rs        # use-cases wiring ports
src/bin/cli.rs  # thin: parse args -> call app -> render
```

Rules:
- **Privacy is the default tool.** `pub(crate)` for cross-module internals, `pub` only for the intended surface (C-REEXPORT: re-export from the root so users write `mycrate::User`, not `mycrate::domain::user::User`).
- **Dependencies point inward.** `domain` imports nothing from `adapters`.
- **No `mod utils`.** It becomes a dumping ground; name modules after the concept.

## Workspaces

Split into member crates when: independent compile/test times matter, a piece is genuinely reusable, or you want a hard compile-enforced boundary. Not before — a module boundary is free and reversible; a crate boundary is not.

```toml
[workspace]
members = ["crates/*"]
resolver = "3"

[workspace.dependencies]
serde = { version = "1", features = ["derive"] }

[workspace.lints.clippy]
pedantic = { level = "warn", priority = -1 }
```
Members inherit with `serde.workspace = true` and `[lints] workspace = true`.

## Error architecture

```rust
// hand-written; no derive crate exists in this codebase. See errors.md
#[derive(Debug)]
#[non_exhaustive]
pub enum StoreError {
    NotFound(UserId),
    Db(sqlx::Error),
}
// impl Display, impl Error { fn source }, impl From<sqlx::Error>
```
- Errors implement `Error + Send + Sync + 'static`, are `Debug`, and never leak inner types you don't want in your semver contract (C-GOOD-ERR). Mark boundary enums `#[non_exhaustive]`.
- Binaries too: `main` returns `Result<(), YourError>` and walks `source()` in a ten-line reporter. `anyhow` and `thiserror` are both banned. Full treatment in `errors.md`.
- Context is added by adding a variant that carries it, not by attaching a string at the call site.

### Where errors live

One file: `src/error.rs`, holding the crate's error enum, its three impls, and the `From` macro. Re-export from the crate root so callers write `mycrate::Error`.

```
deny.toml       # dependency ban list, written by rust-setup
src/
  error.rs      # Error enum + Display + Error::source + From impls + impl_from!
  lib.rs        # pub use error::Error;
```

```rust
// src/error.rs
macro_rules! impl_from {
    ($outer:ty, $variant:ident, $inner:ty) => {
        impl From<$inner> for $outer {
            fn from(e: $inner) -> Self { <$outer>::$variant(e) }
        }
    };
}
pub(crate) use impl_from;     // macro_rules is not `pub` by path — re-export it
```

`macro_rules!` is textual and order-dependent: it must be *defined above* its uses in the same file, and `pub(crate) use` is what makes it visible to sibling modules. No proc-macro, no build-time cost, no dependency.

### How the enum grows

Start with one enum and let pressure split it — do not design the split up front.

1. **New crate:** a single `pub enum Error` in `src/error.rs`. Every fallible function in the crate returns it.
2. **It gets wide.** Fine on its own — `sqlx::Error` carries ~20 variants. Width is not the trigger.
3. **A split signal appears:** callers writing `_ => unreachable!()`, a `# Errors` section naming 3 of 20 variants, or two operation families with no overlapping recoverable failures.
4. **Split that family only.** `ReadError` next to `Error` in the same file, `impl_from!(Error, Read, ReadError)`, and the functions in that family narrow their return type. Everything else is untouched — callers who `?` still widen into `Error` for free.
5. **Repeat per family.** `Error` stays as the crate-level union and the boundary type.

The order matters. Splitting a wide enum later is a local refactor; merging enums you split too early means touching every signature and every caller.

**Semver caveat.** Narrowing a *public* function from `Error` to `ReadError` is a breaking change. Options, in order: do the split before 1.0; or keep public signatures on `Error` and use the narrow types internally, exposing them only when the API next breaks for other reasons. Internal (`pub(crate)`) functions can be narrowed at any time — which is where most of the value is anyway.

## Type-level design

- **Newtype** every id/unit/validated string. Parse at the boundary (`TryFrom<&str>`), then the interior is total.
- **Typestate** for protocols with illegal orderings (`Conn<Open>` -> `Conn<Auth>`); moves runtime checks into the compiler at the cost of generic churn.
- **RAII guards** for anything that must be released — the destructor is the only reliable cleanup path.
- **Traits as ports**, defined by the consumer, implemented by the adapter. Keep them small and object-safe if they must be `dyn`.

## Static vs dynamic dispatch

| | `impl Trait` / generics | `dyn Trait` |
| --- | --- | --- |
| Cost | monomorphised, inlinable | vtable indirection |
| Cost elsewhere | code bloat, slower compiles | fewer instantiations |
| Use when | hot path, few impls | plugin sets, heterogeneous collections, big generic surface |

## Async

Add `tokio` only when you have real concurrent I/O. Async colours the whole call graph and complicates testing. Keep the domain sync and pure; let the adapters be async. If a library must be runtime-agnostic, avoid depending on `tokio` directly — take the I/O trait as a parameter.

## Alternatives worth choosing between

1. **Layered/hexagonal (above) vs flat modules.** Hexagonal pays off past ~10k LOC or when swapping a datastore is plausible; below that it is ceremony.
2. **Single crate with modules vs workspace.** Start single, split when compile time or reuse forces it.
3. **Trait-object ports vs generic ports vs `#[cfg(test)]` fakes.** Generics keep it zero-cost, `dyn` keeps signatures readable, cfg-fakes avoid abstraction entirely for small codebases.
