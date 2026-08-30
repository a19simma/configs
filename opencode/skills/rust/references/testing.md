# Unit and Integration Testing

Sources: [The Rust Book ch.11](https://doc.rust-lang.org/book/ch11-00-testing.html), [ch.11.3 test organization](https://doc.rust-lang.org/book/ch11-03-test-organization.html).

Crate choices live in `crates.md` § Profile: testing — that file is authoritative. This one covers how to test, not what to depend on.

## Layout (Book ch.11.3)

| Kind | Location | Sees | Purpose |
| --- | --- | --- | --- |
| Unit | `#[cfg(test)] mod tests` in same file | private items | logic, edge cases |
| Integration | `tests/*.rs`, each file = own crate | only `pub` API | contracts, wiring |
| Doc | `///` examples | public API | docs that cannot rot; run by `cargo test` |

Shared integration helpers go in `tests/common/mod.rs` (a directory module — not `tests/common.rs`, which would compile as its own test binary).

Binary crates: put logic in `src/lib.rs`, keep `src/main.rs` a shell. Integration tests cannot import a binary crate.

## Unit test shape

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rejects_empty_username() {
        let err = Username::try_from("").unwrap_err();
        assert!(matches!(err, NameError::Empty));
    }

    #[test]
    fn parse_config_reports_missing_key() -> Result<(), Box<dyn std::error::Error>> {
        let cfg = Config::parse("port = 8080")?;   // `?` in tests instead of unwrap
        assert_eq!(cfg.port, 8080);
        Ok(())
    }
}
```
- One behaviour per test; name = the assertion (`rejects_empty_username`), not `test_1`.
- `assert!(matches!(..))` for enum errors; never assert on `Display` strings unless the string *is* the contract.
- `#[should_panic(expected = "...")]` only for real panic contracts.
- Test through the public interface. Tests that touch privates break on every refactor.

## Integration test shape

```rust
// tests/api.rs
mod common;

#[tokio::test]
async fn create_then_fetch_user() {
    let app = common::spawn_app().await;      // real router, ephemeral port, throwaway DB
    let created = app.post_user("ada").await;
    let fetched = app.get_user(created.id).await;
    assert_eq!(fetched.name, "ada");
}
```
Real dependencies (containerised DB) over mocks at this level. Mocks at the integration layer test your mock.

## Crates

`crates.md` § Profile: testing is the ruling: **`tempfile`** is the allowlist, `testcontainers`/`loom`/`tokio-test` need permission, and everything else is rejected there with its reason. `rand`, `regex`, `uuid` and one date crate are allowed here as they are everywhere.

What that leaves you writing yourself, and how:

**Fakes, in place of a mocking crate.**
```rust
struct FixedClock(Timestamp);
impl Clock for FixedClock { fn now(&self) -> Timestamp { self.0 } }
```
Shorter than the mock setup it replaces, and it cannot assert on *how* a dependency was called, which a test should not do. For outbound HTTP, fake the port trait; where the wire itself matters, bind a `TcpListener` on port 0 and answer with a canned response.

**Table cases, in place of a fixture macro.**
```rust
#[test]
fn parses_units() {
    const CASES: &[(&str, u64)] = &[("1k", 1024), ("2M", 2 << 20), ("0", 0)];
    for (input, expected) in CASES {
        assert_eq!(parse_size(input).unwrap(), *expected, "input: {input}");
    }
}
```
The assert message carries the case, so a loop loses only the per-case test name.

**CLI runs, in place of `assert_cmd`.** Cargo exports the path to your own binary:
```rust
fn run(args: &[&str]) -> (i32, String, String) {
    let out = std::process::Command::new(env!("CARGO_BIN_EXE_mytool"))
        .args(args).output().expect("failed to spawn");
    (
        out.status.code().unwrap_or(-1),
        String::from_utf8_lossy(&out.stdout).into_owned(),
        String::from_utf8_lossy(&out.stderr).into_owned(),
    )
}

#[test]
fn rejects_missing_file() {
    let (code, _, stderr) = run(&["build", "nope.toml"]);
    assert_eq!(code, 2, "stderr: {stderr}");
    assert!(stderr.contains("nope.toml"), "stderr: {stderr}");
}
```
Passing `stderr` into the assert message recovers the diagnostic the crate was providing.

**Boundaries, in place of generated inputs.** Name the cases you can state: empty, one, many, maximum, malformed, duplicate. Each gets a test whose name says which case it is, which a generated input never does.

**Projections, in place of snapshots.** When writing the expected value by hand feels unbearable, assert on a projection instead: a count, a sorted list of names, one field. If no projection captures it, the output under test is doing too much.

**Profilers, in place of benchmarks.** `samply` or `cargo-flamegraph` answer where the time goes. Where a number must be tracked, measure it in CI on fixed hardware with a harness you own.

Async tests use `#[tokio::test]`, which ships with `tokio`.

## CI

```
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo nextest run --all-features
cargo test --doc
cargo llvm-cov --workspace --fail-under-lines 70   # optional
```

## Alternatives worth choosing between

1. **`cargo test` vs `cargo-nextest`.** nextest isolates each test in its own process, so global state cannot leak between tests, and it is faster. It does not run doctests, so keep `cargo test --doc` beside it. Neither is a dependency; pick freely.
2. **`testcontainers` vs a CI-provisioned database.** Containers started from the test give per-test isolation at the cost of Docker in the loop and slower runs. A shared CI database is faster but needs per-test schema or transaction rollback. If the project already provisions one in CI, use it, as sqlx does.
