# Style and Smells

Sources: [The Rust Book](https://doc.rust-lang.org/book/), [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/checklist.html), [Rust Design Patterns — anti-patterns](https://rust-unofficial.github.io/patterns/anti_patterns/index.html), [Clippy lint index](https://rust-lang.github.io/rust-clippy/master/index.html).

## Naming (API Guidelines C-CASE, C-CONV, C-GETTER)

`UpperCamelCase` types/traits/enum variants. `snake_case` fns/vars/modules. `SCREAMING_SNAKE_CASE` consts/statics.

Conversion prefixes are a contract, not taste:

| Prefix | Cost | Receiver |
| --- | --- | --- |
| `as_` | free | `&self` -> `&T` |
| `to_` | expensive (alloc/clone) | `&self` -> `T` |
| `into_` | variable, consumes | `self` -> `T` |

Getters have no `get_` prefix: `fn name(&self) -> &str`, not `get_name`. Exception: `get_unchecked`, `get_mut`.
Iterator triple: `iter()`, `iter_mut()`, `into_iter()` (C-ITER).

## Signatures

```rust
// smell
fn load(path: String, names: &Vec<String>) -> Result<String, String>

// idiomatic
fn load(path: impl AsRef<Path>, names: &[String]) -> Result<Config, LoadError>
```

- `&str` over `&String`, `&[T]` over `&Vec<T>` (`clippy::ptr_arg` catches this).
- `impl AsRef<Path>` / `impl Into<String>` for ergonomic generic args (C-GENERIC).
- Return concrete types or `impl Trait`; box only when the type must be erased.
- Never `Result<_, String>`. Errors are types.
- `#[must_use]` on any pure fn whose return being dropped is a bug.

## Ownership smells

| Smell | Fix |
| --- | --- |
| `.clone()` to silence borrowck | Restructure the borrow, or take `&self` and return owned once |
| `Rc<RefCell<T>>` webs | Ownership tree + indices/ids; `RefCell` panics are runtime borrowck |
| `Arc<Mutex<HashMap>>` as app state | Actor/channel (`tokio::sync::mpsc`), or shard by hand into `[Mutex<HashMap>; N]` keyed on a hash. `dashmap` is not allowed; see `crates.md`. |
| `String` fields that are really enums | Enum with `FromStr`/`Display` |
| `bool` params (`send(true, false)`) | Named enums; `clippy::fn_params_excessive_bools` |
| `unwrap()` chains | `?`, `ok_or_else`, `let ... else` |

## Control flow

```rust
// smell: match on Option to unwrap
let cfg = match maybe_cfg { Some(c) => c, None => return Err(E::Missing) };
// idiomatic
let Some(cfg) = maybe_cfg else { return Err(E::Missing) };
```

- `if let` / `let else` over single-arm `match`.
- Iterator adapters over index loops; but a `for` loop beats a 5-adapter chain nobody can read.
- `?` everywhere; `.map_err(...)` only where context is added.
- Avoid `impl Deref` for inheritance-flavoured reuse — documented anti-pattern (`Deref` polymorphism).

## Documented anti-patterns

- **`clone()` to satisfy the borrow checker** — hides a design problem, costs allocations.
- **`#[deny(warnings)]` in source** — breaks downstream builds on new compiler releases. Put denials in CI flags instead.
- **`Deref` polymorphism** — `Deref` is for smart pointers, not inheritance.
- **Stringly-typed APIs** — no compile-time checking, no exhaustiveness.
- **Premature `async`** — async in a CPU-bound or single-shot CLI buys complexity, not throughput.

## Alternatives worth choosing between

1. **Newtype vs raw primitives.** `struct UserId(u64)` costs nothing at runtime, blocks arg-order bugs. Pick raw primitives only for genuinely local scratch values. [Newtype pattern](https://rust-unofficial.github.io/patterns/patterns/behavioural/newtype.html)
2. **Builder vs typestate builder.** Plain builder = runtime error on missing field; typestate builder = compile error, at the cost of generic noise. Use typestate only for constructors with hard required-field invariants. [greyblake: builder with typestate](https://www.greyblake.com/blog/builder-with-typestate-in-rust/)
3. **Hand-written impls vs a `macro_rules!` of your own.** Newtype and builder boilerplate is repetitive enough to justify a local declarative macro (see `architecture.md` for the `impl_from!` pattern). Derive crates — `derive_more`, `bon`, `strum` — are not allowed; a `macro_rules!` in the crate does the same job with no dependency and no proc-macro compile cost.
