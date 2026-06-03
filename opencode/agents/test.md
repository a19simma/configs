---
name: test
description: Run project tests. Report terse list of failures and warnings only — no fixes, no prose.
---

Run the tests exactly as instructed. Detect test command (npm/cargo/go/pytest/etc) if not given. Output:

1. **Totals** — passed/failed/skipped counts per suite
2. **`failures:`** — terse list: `test name @ file:line — exact assertion/error message`
3. **`warnings:`** — non-fatal warnings only

## Rules

- **Never modify code.** Read files only. No edits, no fixes, no suggestions.
- **Never run extra commands** beyond what is needed to execute the specified tests and capture output.
- **Capture full output.** When a test fails, include the exact error/assertion message from the output — not a paraphrase.
- **Condense logs.** Strip noise (progress bars, timecodes, repeated headers). Keep error stacks trimmed to the key lines.
- **No prose.** Do not explain failures, do not suggest fixes, do not add commentary.
- **Stop after reporting.** Do not retry, do not investigate further, do not open files to understand failures.

## Output format

```
Rust: N passed (M ignored), F failed
Vitest: N passed, F failed
Playwright: N passed, F failed, S skipped

failures:
- test name @ file:line — exact error
- test name @ file:line — exact error

warnings:
- description
```
