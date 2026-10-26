---
name: mutant-review
description: Run mutation testing (cargo-mutants for Rust, StrykerJS for TypeScript and Svelte) on a schedule, triage every surviving mutant, and add the smallest tests that kill the real ones.
disable-model-invocation: true
argument-hint: [rust|ts, package or path glob, default every language present]
---

# Mutant review

Scope: $ARGUMENTS

Mutation testing proves tests fail when code changes. It is slow, so it runs on a schedule (weekly, or before a release), never per task. Implementation tasks write a minimal covering test set and leave mutation to this skill. The tools are `cargo-mutants` for Rust and StrykerJS for TypeScript and Svelte, not hand-edited mutants. Nushell has no mutation tool and is skipped. Run each language the repo contains, steps 1 to 5 once per language, one report.

## 1. Preconditions

- Refuse on a dirty working tree and on `main` or `master`. Work on a branch `chore/mutants-<date>`.
- Read the repo `CLAUDE.md` files and the verify command in `.ralph/goal.md` when it exists. Run the verify command once through the `test` agent. A red baseline stops the skill: cargo-mutants exits 4 on a failing baseline.
- For Rust, check `cargo mutants --version`. When missing, install with `cargo install --locked cargo-mutants`, or add the mise `cargo:cargo-mutants` backend. The `github:sourcefrog/cargo-mutants` release has no macOS arm64 asset, only x86_64 darwin and linux, so prefer the cargo build there.

## 2. Plan the run

The bullets below describe Rust. The TypeScript and Svelte equivalents are in the last section of this file.

- List first: `cargo mutants --workspace --list` and count the lines. Estimate time as mutants times (incremental build plus one test run), using the baseline test time from step 1.
- Tests that bind fixed ports, start a shared database or spawn children collide under parallel jobs. Use `-j1` unless the repo's tests allocate ephemeral ports and per-run databases. Each job copies the tree and has its own target dir, often 2 GB or more, so check free disk.
- Run tests for the whole workspace per mutant with `--test-workspace=true`, because mutants in a library crate are often killed by tests in another crate. By default only the mutated package's tests run.
- Put stable exclusions in `.cargo/mutants.toml` (`exclude_re`, `exclude_globs`, `skip_calls`), never in inline comments. Prefer config over `#[mutants::skip]`, which needs the `mutants` crate as a dependency.
- Add a `[profile.mutants]` with `inherits = "test"` and `debug = "none"` to cut build time when the repo has none.
- Above about 500 mutants, split with `--shard k/n` across separate runs and pass identical arguments to every shard.

## 3. Run

- Launch as a pueue job with the whole command as one quoted string, through `mise exec` when the repo uses mise: `cargo mutants --workspace --test-workspace=true -j1 --no-shuffle -- --all-targets`. Add `--in-diff <file>` only for a quick check of one branch, because it does not guarantee full coverage.
- Poll in short slices. Compare `mutants.out/outcomes.json` growth with the estimate. A job with no new outcome for ten minutes, or running far past the estimate, gets killed with `pueue kill`, then diagnosed. Resume a killed run with `--iterate`, which skips mutants already caught or unviable.
- Exit codes: 0 all caught, 2 survivors, 3 timeouts, 4 baseline failing, 5 and 6 a bad `--in-diff` file. Exit 2 and 3 are normal results, not failures.

## 4. Triage

Read `mutants.out/missed.txt`, `timeout.txt` and the matching files in `mutants.out/diff/`. Classify every entry into exactly one class:

- **Test gap**: the mutant changes behaviour a caller can observe. Write the smallest test that asserts that behaviour, one test per cluster of related mutants. Confirm the test fails on the mutant by rerunning only that mutant with `-F '<regex>'` and `--file <path>`, and passes on the original.
- **Equivalent**: the mutant cannot change observable behaviour (a clamp that no input reaches, a redundant bound). Add an anchored `exclude_re` line to `.cargo/mutants.toml` and record the reason in the report. Do not delete the code unless it is dead.
- **Weak oracle**: the code is covered but the test asserts too little. Strengthen the assertion, do not add a new test.
- **Timeout**: decide between an infinite loop the mutant caused (counts as killed once the test has an outer timeout) and a timeout set too low (raise `--minimum-test-timeout`).
- **Unviable**: ignore, the mutant did not compile.

Tests follow the repo's rules. No inline comments, seams are injected parameters, and timing assertions use wide bands.

## 5. Report and close

- Write `mutants-report.md` in `.ralph/` when it exists, otherwise in the scratchpad. It holds counts (caught, missed, unviable, timeout), the score caught over caught plus missed, survivors by file with their class, each exclusion with its reason, and the run time per phase.
- Commit the new tests and `.cargo/mutants.toml` as semantic commits on the working branch, with no attribution lines.
- Confirm with a final `cargo mutants --iterate` over the same scope, then once without `--iterate` on any package that changed, and state the new score. Never push.
- Done when every survivor has a class, every test gap has a killing test or a stated reason it was not added, and the report lists any package left unexamined.

## TypeScript and Svelte (StrykerJS)

Applies steps 1 to 5 with these differences.

- **Install:** `npm i -D @stryker-mutator/core @stryker-mutator/vitest-runner @stryker-mutator/typescript-checker`. It needs Node 22 or newer and Vitest 2 or newer. Check the repo's package manager and use it instead of npm when it differs.
- **Config:** `stryker.config.mjs` with `testRunner: "vitest"`, `checkers: ["typescript"]`, `mutate` globs for `src/**/*.ts` and `src/**/*.svelte` minus spec and test files, `incremental: true`, `reporters: ["clear-text", "progress", "html", "json"]`, and `thresholds.break` set only when the human wants a hard floor (default `null`, never fails the run).
- **Svelte:** `.svelte` files are mutated with the installed Svelte compiler. Whether rune code (`$state`, `$derived`) and `.svelte.ts` files mutate cleanly is unverified: try one component first and record the result in the report. Code covered only by browser-mode Vitest tests may be invisible to Stryker, so prefer logic in `.ts` modules that Node-mode Vitest tests exercise.
- **Run:** `npx stryker run` as a pueue job. Use `--force` for the full pass. For a branch check pass changed files from `git diff --name-only origin/main...HEAD` to `--mutate`, which has no `--since`. Incremental mode sees changes only in mutated and test files, so a config or shared-helper change needs `--force`.
- **Results:** read the clear-text survivors or filter `reports/mutation/mutation.json` for status `Survived` and `NoCoverage`. A score under `thresholds.break` exits 1.
- **Equivalent mutants:** no inline `// Stryker disable` comments. Use `mutator.excludedMutations` for a whole operator, or an `ignorers` plugin file registered in `plugins` for a finer rule, and record the reason in the report.
- **Concurrency:** set `concurrency` to 1 when tests bind fixed ports or share a database.
