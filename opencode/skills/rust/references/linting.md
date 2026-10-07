# Linting and Clippy

Sources: [Clippy configuration](https://doc.rust-lang.org/clippy/configuration.html), [Clippy lint index](https://rust-lang.github.io/rust-clippy/master/index.html), [Cargo `[lints]` reference](https://doc.rust-lang.org/cargo/reference/manifest.html#the-lints-section), [rustfmt config](https://rust-lang.github.io/rustfmt/).

## Two files, two jobs

- **`Cargo.toml` `[lints.*]`** sets lint *levels* (`allow`/`warn`/`deny`/`forbid`). Applies to the crate and is inherited across a workspace. This is the modern replacement for `#![warn(...)]` in `lib.rs`.
- **`clippy.toml`** configures lint *behaviour* (thresholds, disallowed lists, MSRV). It cannot set levels.

**Priority gotcha:** entries in `[lints]` apply in priority order, low to high. At equal priority the order is undefined ([`lint_groups_priority`](https://rust-lang.github.io/rust-clippy/master/index.html#lint_groups_priority)). A lint *group* must get a lower priority than the individual lints that override it. Cargo does not check this (cargo#12918); get the priorities right by hand.

## `Cargo.toml`

The workspace root holds the lint table. Every block below goes in the root `Cargo.toml`.

**Rust lints:**
```toml
[workspace.lints.rust]
unsafe_code = "forbid"
missing_docs = "warn"
rust_2018_idioms = { level = "warn", priority = -1 }
unreachable_pub = "warn"
unused_qualifications = "warn"
trivial_casts = "warn"
```
Drop `unsafe_code` to `"deny"` if the crate needs unsafe. In a binary, `missing_docs` asks for the `//!` crate doc in `main.rs` and a `///` on every `pub` item. Keep binary items private or `pub(crate)`.

**Clippy groups**, at negative priority so the individual entries below win:
```toml
[workspace.lints.clippy]
all      = { level = "warn", priority = -1 }
pedantic = { level = "warn", priority = -1 }
nursery  = { level = "warn", priority = -1 }
cargo    = { level = "warn", priority = -1 }
```
`nursery` is noisier. Drop it if it fights you.

**Hard denials**, always bugs, in the same `[workspace.lints.clippy]` table:
```toml
unwrap_used = "deny"
expect_used = "warn"
panic = "warn"
todo = "deny"
dbg_macro = "deny"
print_stdout = "warn"
undocumented_unsafe_blocks = "deny"
allow_attributes = "deny"
allow_attributes_without_reason = "deny"
mem_forget = "deny"
float_cmp = "deny"
lossy_float_literal = "deny"
integer_division = "warn"
indexing_slicing = "warn"
string_slice = "warn"
unwrap_in_result = "warn"
missing_errors_doc = "warn"
missing_panics_doc = "warn"
```
`indexing_slicing` pushes toward `.get()`. `allow_attributes` denies outer `#[allow]`, so the in-code escape is `#[expect]`, and `allow_attributes_without_reason` makes it carry a `reason`. Clippy skips crate-level `#![allow]`; review catches it.

`expect_used` is allowed in unit tests through `allow-expect-in-tests` in `clippy.toml`. Clippy 1.98 exempts `#[test]` fns under `tests/` but not their helpers or `tests/common/`; those return `Result` and use `?`. In a binary, `expect_used`, `print_stdout` and the `println!` entry in `disallowed-macros` get an `#[expect]` at the site, because a member crate cannot override inherited workspace lints (cargo#13157).

**Pedantic entries that cost more than they give:**
```toml
module_name_repetitions = "allow"
must_use_candidate = "allow"
missing_const_for_fn = "allow"
multiple_crate_versions = "allow"
```
`multiple_crate_versions` comes from the `cargo` group and is rarely actionable.

**Member crate opts in**, in its own `Cargo.toml`:
```toml
[lints]
workspace = true
```

## `clippy.toml` (repo root)

```toml
msrv = "1.85"
avoid-breaking-exported-api = true
```
`msrv` gates lints that need newer language features. `avoid-breaking-exported-api` stops clippy suggesting semver-breaking changes.

**Complexity budgets:**
```toml
cognitive-complexity-threshold = 20
too-many-arguments-threshold = 6
too-many-lines-threshold = 120
type-complexity-threshold = 250
enum-variant-size-threshold = 200
trivial-copy-size-limit = 16
large-error-threshold = 128
```

**Naming hygiene:**
```toml
disallowed-names = ["foo", "bar", "baz", "tmp", "data", ".."]
doc-valid-idents = ["OAuth", "PostgreSQL", "gRPC", "WebSocket", ".."]
```
`".."` extends the defaults.

**Banned APIs and test allowances:**
```toml
disallowed-methods = [
    { path = "std::env::set_var", reason = "unsound across threads; build config at startup" },
    { path = "std::time::SystemTime::now", reason = "inject a Clock port so tests are deterministic" },
]
disallowed-types = [
    { path = "std::sync::Mutex", reason = "prefer message passing; if shared state is needed, justify it in review" },
]
disallowed-macros = [
    { path = "std::println", reason = "use tracing" },
]
allow-unwrap-in-tests = true
allow-expect-in-tests = true
allow-panic-in-tests = true
allow-dbg-in-tests = true
```

## `rustfmt.toml`

Nightly-only options are marked; on stable they are ignored with a warning.

**Stable:**
```toml
edition = "2024"
max_width = 100
use_small_heuristics = "Default"
newline_style = "Unix"
```

**Nightly:**
```toml
group_imports = "StdExternalCrate"
imports_granularity = "Crate"
wrap_comments = true
comment_width = 90
format_code_in_doc_comments = true
normalize_comments = true
```
Format with `cargo +nightly fmt` in CI if you use the nightly keys; otherwise delete them.

## Local escape hatch

```rust
#[expect(clippy::expect_used, reason = "config is validated at build time; a missing file is a deploy bug")]
fn main() {
```
A binary whose job is terminal output takes one crate-level attribute at the top of `main.rs`:
```rust
#![expect(clippy::print_stdout, clippy::disallowed_macros, reason = "CLI output is this crate's purpose")]
```
`disallowed-macros` bans `std::println` separately from `print_stdout`, so the attribute names both. Crate-level `#![expect]` is allowed only in a binary's `main.rs`, and only for these two lints.

`#[expect]` and `reason =` are stable since Rust 1.81. `#[expect]` fails once the lint stops firing, so a stale exception cannot linger. The `reason` names a concrete invariant, not a preference.

## Commands

```
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo clippy --fix --allow-dirty
cargo fmt --all --check
cargo deny check
cargo machete
```
`clippy --fix` applies mechanical fixes. `cargo deny check` enforces the ban list, licences and advisories. `cargo machete` finds unused deps.

## Alternatives worth choosing between

1. **`pedantic` on with targeted allows vs `all` only.** Pedantic-on catches real API smells but needs a maintained allow-list; `all`-only is quieter and better for a legacy codebase being migrated incrementally.
2. **`nursery` on or off.** Nursery lints are unstable and produce false positives; enable in a fast-moving greenfield crate, skip in a shared library.
3. **`[lints]` in Cargo.toml vs `#![warn(...)]` in lib.rs.** Cargo.toml is workspace-inheritable and tool-visible; crate attributes still work but do not inherit and are easy to lose in a split. Prefer `[lints]`.
4. **`unsafe_code = "forbid"` vs `"deny"`.** `forbid` cannot be locally overridden: correct for most crates, blocking for anything doing FFI or hand-rolled data structures.
5. **`-D warnings` in CI vs `deny` in the manifest.** CI flags keep the build from breaking on new compiler releases for downstream users; manifest denials are visible in the editor. Use manifest `warn` + CI `-D warnings`.
