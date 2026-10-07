# Documentation

Sources: [RFC 1574](https://rust-lang.github.io/rfcs/1574-more-api-documentation-conventions.html), [rustdoc book](https://doc.rust-lang.org/rustdoc/how-to-write-documentation.html), [Rust 1.81.0 announcement](https://blog.rust-lang.org/2024/09/05/Rust-1.81.0/), [Clippy lint list](https://rust-lang.github.io/rust-clippy/stable/index.html).

## What may appear in code

| Form | Status |
| --- | --- |
| `///` on an item | Doc comment. Required on every public item |
| `//!` at the top of a crate or module | Doc comment. Crate and module docs only |
| `// SAFETY:` directly above an `unsafe` block | The one sanctioned inline comment |
| `#[expect(lint, reason = "…")]`; crate-level `#![expect]` only in a binary's `main.rs` for the two output lints (see `linting.md`) | The in-code lint escape. An attribute, not a comment |
| Any other `//` or `/* */` | Banned, tests included |
| `#[allow]`, `#![allow]` | Banned. Obey the lint or disable it in `[lints]`. Clippy denies `#[allow]`; review catches `#![allow]` |

> "Only use inner doc comments `//!` to write crate and module-level documentation, nothing else."
> Source: [RFC 1574](https://rust-lang.github.io/rfcs/1574-more-api-documentation-conventions.html)

## Summary line

The first line is a single-sentence summary in the third person: "Returns the parsed value", not "Return the parsed value".

> "Everything before the first empty line will be reused to describe the component in searches and module overviews."
> Source: [rustdoc book](https://doc.rust-lang.org/rustdoc/how-to-write-documentation.html)

**Rule:** the summary says what the item is for. Leave out what the signature already says.

## Sections

RFC 1574 names these headings: `# Examples`, `# Panics`, `# Errors`, `# Safety`, `# Aborts`, `# Undefined Behavior`.

| Section | Required when | Enforced by |
| --- | --- | --- |
| `# Errors` | a public fn returns `Result` | `clippy::missing_errors_doc` (pedantic) |
| `# Panics` | a public fn can panic | `clippy::missing_panics_doc` (pedantic) |
| `# Safety` | a public `unsafe fn` or `unsafe trait` | `clippy::missing_safety_doc` (style) |

`missing_docs` in `linting.md` covers the rest. All three check only exported functions and methods; `missing_safety_doc` also checks every `unsafe trait`, public or not.

```rust
/// Returns the parsed port.
///
/// # Errors
///
/// Returns `ParseError::Empty` if `input` is empty, and
/// `ParseError::Invalid` if it is not a number from 0 to 65535.
pub fn parse_port(input: &str) -> Result<u16, ParseError> {
    if input.is_empty() {
        return Err(ParseError::Empty);
    }
    input.parse().map_err(ParseError::Invalid)
}
```

## `// SAFETY:`

`clippy::undocumented_unsafe_blocks` is `deny` in `linting.md`. It wants `SAFETY:` (case-insensitive, colon required) on the line or lines before the block:

> "Note the comment must appear on the line(s) preceding the unsafe block with nothing appearing in between."
> Source: [clippy source](https://github.com/rust-lang/rust-clippy/blob/master/clippy_lints/src/undocumented_unsafe_blocks.rs)

**Rule:** the comment names the invariant the block relies on and nothing else.

```rust
// SAFETY: the caller guarantees `idx < buf.len()` (see `# Safety`).
let byte = unsafe { *buf.get_unchecked(idx) };
```

## `#[expect]`

Stable since Rust 1.81.0:

> "1.81 stabilizes a new lint level, `expect`, which allows explicitly noting that a particular lint _should_ occur, and warning if it doesn't."
> Source: [Rust 1.81.0 announcement](https://blog.rust-lang.org/2024/09/05/Rust-1.81.0/)

**Rule:** the `reason` names a concrete invariant ("checked non-empty above"), not a preference ("cleaner"). An `#[expect]` whose lint no longer fires is a finding.

## Wording

Doc comment prose follows `stop-slop`.
