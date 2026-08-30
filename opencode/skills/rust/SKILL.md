---
name: rust
description: Rust coding standards: idiomatic style, module and crate architecture, hand-written error types, testing, the crate allowlist, clippy and rustfmt config. Load before writing or editing any .rs file or Cargo.toml, and when asked whether Rust code is idiomatic, which crate to use, or how to test it.
---

# Rust Best Practices

Grounded in [The Rust Book](https://doc.rust-lang.org/book/), [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/checklist.html), [Rust Design Patterns](https://rust-unofficial.github.io/patterns/), and [Clippy docs](https://doc.rust-lang.org/clippy/).

## Load order

| Question | File |
| --- | --- |
| Is this idiomatic? What smells? | `references/style-and-smells.md` |
| How do I lay out modules and crates? | `references/architecture.md` |
| How do I write or split an error type? | `references/errors.md` |
| How do I test this? | `references/testing.md` |
| Which crate for X? Is this one allowed? | `references/crates.md` |
| Why is that crate banned? Who else uses it? | `references/adoption.md` |
| What lints do I turn on? | `references/linting.md` |

Read only the file that answers the question. Do not preload them.

**Reviewing a Rust diff:** read `rust-review/SKILL.md` and follow it. **Scaffolding a new Rust project:** read `rust-setup/SKILL.md` and follow it. Both are user-invoked, so they carry no description and cannot be fired as skills; reach them by path.

## Non-negotiables

1. **`unwrap`/`expect` never in library code.** `expect` allowed in `main`, tests, and where an invariant is proven — with the message stating *why* it cannot fail (Book ch.9).
2. **Make illegal states unrepresentable.** Enum + newtype over `bool` flags and stringly-typed fields.
3. **Borrow in arguments, own in returns.** Take `&str`/`&[T]`/`impl AsRef<Path>`, not `String`/`Vec<T>`/`&String`.
4. **Errors are hand-written typed enums.** `anyhow` and `thiserror` are both banned. One `#[non_exhaustive]` enum per crate by default, split into scoped enums only when a function family has a distinct recoverable set. Erasure (`Box<dyn Error>`) only where the set is structurally open. Never `Result<_, String>`.
5. **`cargo clippy --all-targets -- -D warnings` + `cargo fmt --check` gate CI.** No exceptions merged without an `#[allow]` carrying a reason comment.
6. **Public item without a doc comment is a bug.** `#![warn(missing_docs)]` on every lib crate.
7. **No new dependency without approval.** Only crates listed in `references/crates.md`, or expressly permitted by the user. Everything else: use `std` or ask. Every project scaffolds a `deny.toml` in its first commit so the ban list is enforced by `cargo deny check` in CI, not by a reviewer's memory.
8. **Unsafe needs a `// SAFETY:` comment** naming the invariant upheld. Enforced by `clippy::undocumented_unsafe_blocks`.

## Reviewing

The rules live in `references/` and nowhere else. `rust-review` and `rust-setup` are procedure that reads them.

Order: machine pass → dependency gate → style → architecture → tests. Machine-findable smells are not worth human attention.
