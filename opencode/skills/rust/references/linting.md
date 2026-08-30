# Linting and Clippy

Sources: [Clippy configuration](https://doc.rust-lang.org/clippy/configuration.html), [Clippy lint index](https://rust-lang.github.io/rust-clippy/master/index.html), [Cargo `[lints]` reference](https://doc.rust-lang.org/cargo/reference/manifest.html#the-lints-section), [rustfmt config](https://rust-lang.github.io/rustfmt/).

## Two files, two jobs

- **`Cargo.toml` `[lints.*]`** sets lint *levels* (`allow`/`warn`/`deny`/`forbid`). Applies to the crate and is inherited across a workspace. This is the modern replacement for `#![warn(...)]` in `lib.rs`.
- **`clippy.toml`** configures lint *behaviour* (thresholds, disallowed lists, MSRV). It cannot set levels.

**Priority gotcha:** entries in `[lints]` apply in priority order, low to high; equal priority = unspecified order. A lint *group* must get a lower priority than the individual lints that override it, or Cargo errors out.

## `Cargo.toml`

```toml
[workspace.lints.rust]
unsafe_code = "forbid"          # drop to "deny" if you genuinely need unsafe
missing_docs = "warn"           # lib crates
rust_2018_idioms = { level = "warn", priority = -1 }
unreachable_pub = "warn"
unused_qualifications = "warn"
trivial_casts = "warn"

[workspace.lints.clippy]
# groups first, at negative priority so individual entries below win
all      = { level = "warn", priority = -1 }
pedantic = { level = "warn", priority = -1 }
nursery  = { level = "warn", priority = -1 }   # noisier; drop if it fights you
cargo    = { level = "warn", priority = -1 }

# hard denials — these are always bugs
unwrap_used = "deny"
expect_used = "warn"            # allowed in main/tests via #[allow] with a reason
panic = "warn"
todo = "deny"
dbg_macro = "deny"
print_stdout = "warn"           # libraries; allow in bins
undocumented_unsafe_blocks = "deny"
mem_forget = "deny"
float_cmp = "deny"
lossy_float_literal = "deny"
integer_division = "warn"
indexing_slicing = "warn"       # prefer .get()
string_slice = "warn"
unwrap_in_result = "warn"
missing_errors_doc = "warn"
missing_panics_doc = "warn"

# pedantic entries that cost more than they give
module_name_repetitions = "allow"
must_use_candidate = "allow"
missing_const_for_fn = "allow"
multiple_crate_versions = "allow"   # from the `cargo` group; rarely actionable

# member crate opts in:
# [lints]
# workspace = true
```

## `clippy.toml` (repo root)

```toml
msrv = "1.85"                       # gates lints that need newer language features
avoid-breaking-exported-api = true  # don't suggest semver-breaking changes

# complexity budgets
cognitive-complexity-threshold = 20
too-many-arguments-threshold = 6
too-many-lines-threshold = 120
type-complexity-threshold = 250
enum-variant-size-threshold = 200
trivial-copy-size-limit = 16
large-error-threshold = 128

# naming hygiene
disallowed-names = ["foo", "bar", "baz", "tmp", "data", ".."]   # ".." extends defaults
doc-valid-idents = ["OAuth", "PostgreSQL", "gRPC", "WebSocket", ".."]

# ban specific APIs
disallowed-methods = [
    { path = "std::env::set_var", reason = "unsound across threads; build config at startup" },
    { path = "std::time::SystemTime::now", reason = "inject a Clock port so tests are deterministic" },
]
disallowed-types = [
    { path = "std::sync::Mutex", reason = "prefer message passing; if shared state is genuinely needed, justify it in review" },
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

```toml
edition = "2024"
max_width = 100
use_small_heuristics = "Default"
newline_style = "Unix"
# nightly:
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
#[allow(clippy::unwrap_used, reason = "checked non-empty two lines above")]
```
`reason = ` requires the `lint_reasons` feature on older toolchains; on stable, use a comment. Never a bare crate-level `#![allow]` for a lint you introduced.

## Commands

```
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo clippy --fix --allow-dirty        # mechanical fixes
cargo fmt --all --check
cargo deny check                        # licences + advisories
cargo machete                           # unused deps
```

## Alternatives worth choosing between

1. **`pedantic` on with targeted allows vs `all` only.** Pedantic-on catches real API smells but needs a maintained allow-list; `all`-only is quieter and better for a legacy codebase being migrated incrementally.
2. **`nursery` on or off.** Nursery lints are unstable and produce false positives; enable in a fast-moving greenfield crate, skip in a shared library.
3. **`[lints]` in Cargo.toml vs `#![warn(...)]` in lib.rs.** Cargo.toml is workspace-inheritable and tool-visible; crate attributes still work but do not inherit and are easy to lose in a split. Prefer `[lints]`.
4. **`unsafe_code = "forbid"` vs `"deny"`.** `forbid` cannot be locally overridden — correct for most crates, blocking for anything doing FFI or hand-rolled data structures.
5. **`-D warnings` in CI vs `deny` in the manifest.** CI flags keep the build from breaking on new compiler releases for downstream users; manifest denials are visible in the editor. Use manifest `warn` + CI `-D warnings`.
