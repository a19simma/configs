---
disable-model-invocation: true
name: rust-review
description: Review a Rust diff against the rust skill: dependency allowlist, error shape, style, architecture, tests, lints. Reports findings only, makes no edits.
---

# Rust Review

Reviews Rust against the conventions in the `rust` skill. **That skill is the rule source — this one is the procedure.** Supersedes the generic `code-review` skill for Rust changes; do not run both. Do not invent rules here; if a rule is missing there, say so and propose it as a rule change rather than flagging it as a violation.

## Procedure

### 0. Scope

Determine the diff: `git diff <base>...HEAD`, a named branch/PR, or specified files. Review only changed lines plus enough surrounding context to judge them. Unchanged legacy code is out of scope unless the change made it wrong.

### 1. Machine pass (before reading anything)

```
cargo fmt --all --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --doc
cargo machete
cargo deny check          # fails on any banned crate; deny.toml must exist
```
Run tests via the `test` subagent, not directly. Anything a tool found is not a human finding — report the tool output and move on. Human attention goes only to what tools cannot see.

### 2. Dependency gate — blocking

Diff `Cargo.toml` / `Cargo.lock`. For each added dependency, check `rust/references/crates.md`.

- `anyhow`, `thiserror`, `eyre`, `color-eyre`, `miette`, `snafu` → **BLOCKER**, unconditionally. Not approvable.
- No `deny.toml` at the workspace root, or a banned crate missing from its `deny` list → finding.
- `log`, `env_logger`, `once_cell` or `lazy_static` as a **direct** dependency → **BLOCKER**. These cannot be caught by `deny.toml` (they arrive transitively throughout the ecosystem), so this check is the only enforcement. Transitive occurrences are fine and expected.
- `tracing-subscriber` with `default-features = false` and no explicit `tracing-log` feature → finding. Drops the `LogTracer` bridge, so every dependency's `log` output disappears silently.
- `tracing` with the `log` or `log-always` feature enabled → finding.
- Not on the allowlist and no express permission in this conversation → **BLOCKER**, no exceptions, no "it's small". Check both **Core** and **Core — std gaps** (`rand`, `regex`, `uuid`, `jiff`/`chrono`) before flagging.
- Two date crates, or two of `regex`/`regex-lite`, in one workspace → finding. One per job.
- Any web framework other than `axum` → **BLOCKER**.
- On the allowlist but with `features = ["full"]` or missing `default-features = false` → finding.
- In `[dependencies]` when it belongs in `[dev-dependencies]` → finding.
- Not declared through `[workspace.dependencies]` in a workspace → finding.

### 3. Rule passes

Load one reference file per pass. Do not preload all of them.

| Pass | Reference | Looking for |
| --- | --- | --- |
| Errors | `rust/references/errors.md` | untyped returns (`String`, `Box<dyn Error>`) where the set is closed; `BoxError` outside an open-set boundary or without a comment justifying it; missing `#[non_exhaustive]` on a public error enum; `Display` that also prints its `source` (duplicated chain); uppercase or trailing-punctuation messages; `From` impls that skip a layer; a fat variant unboxed in a crate-wide enum; public fallible fn with no `# Errors` doc; callers writing `_ => unreachable!()` (split signal) |
| Style | `rust/references/style-and-smells.md` | naming/conversion prefixes, `&String`/`&Vec`, `Result<_, String>`, clone-to-appease-borrowck, stringly-typed fields, bool params, `unwrap` in libs |
| Architecture | `rust/references/architecture.md` | inward-pointing deps, privacy/re-exports, errors in `src/error.rs` re-exported from the root; error enum granularity — one per crate by default, split only on a stated trigger, sub-enums composing upward via `From`; a split that narrows a public signature is a semver break, newtypes at boundaries, async leaking into the domain, `dyn` vs generics |
| Testing | `rust/references/testing.md` | new behaviour without a test, tests asserting on privates or `Display` strings, integration tests that mock the thing under test, missing `// SAFETY:`/panic docs |
| Lints | `rust/references/linting.md` | new `#![allow]` without a reason, lint config drift, `#[deny(warnings)]` in source |

### 4. Verify before reporting

Every finding must survive:
1. **Cite the rule.** File + rule name from the `rust` skill. No citation → not a finding.
2. **Concrete failure.** Name inputs or a change that makes it break, or state plainly that it is a convention violation with no runtime consequence.
3. **Read the surrounding code.** A `clone()` next to a comment explaining the borrow is not a finding.

Drop anything that fails these. A false positive costs more trust than a missed nit.

## Severity

| Level | Meaning |
| --- | --- |
| **BLOCKER** | `anyhow` present anywhere; unapproved dependency; `unwrap`/`panic` on a library path; undocumented `unsafe`; clippy/fmt failure |
| **MAJOR** | Wrong error architecture; leaked internals in the public API; new behaviour with no test; illegal state representable |
| **MINOR** | Naming, signature ergonomics, avoidable clone, missing `#[must_use]` |
| **NOTE** | Suggestion with a trade-off; explicitly optional |

## Output

Findings only, most severe first, `file.rs:line` for each:

```
BLOCKER  src/store.rs:42  Unapproved dependency `dashmap` added in Cargo.toml:18
  Rule:    crates.md, allowlist; dashmap listed under "not allowed without permission"
  Failure: no approval in this conversation
  Fix:     std HashMap behind a Mutex, or request approval with the stated justification form
```

End with a one-line verdict: `PASS`, `PASS WITH MINORS`, or `BLOCKED (n blockers)`.

## Constraints

- **Read only.** Show suggested changes as minimal snippets with locations. Do not edit files.
- Do not restate what clippy already printed.
- No praise section. Silence is the pass signal.
