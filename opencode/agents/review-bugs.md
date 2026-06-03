---
name: review-bugs
description: Aggressive defect-hunting review. Investigates every suspicious pattern, errs toward flagging. Focus: logic bugs, race conditions, null derefs, edge cases, error handling, security vulns. Use when the user wants a thorough bug hunt on a diff, branch, or PR — NOT for style or spec compliance.
---

# Bug Hunt Review

Aggressive defect-finding. Err toward flagging — a false positive costs a comment; a missed bug costs prod.

## Process

### 1. Pin the diff

Get the fixed point from the user (branch, commit, `main`, `HEAD~N`). If not supplied, ask once. Don't proceed without it.

```
git diff <fixed-point>...HEAD
git log <fixed-point>..HEAD --oneline
```

### 2. Fetch context dynamically

For each suspicious hunk, pull surrounding context — callers, callees, type definitions, related tests. Don't review hunks in isolation. Use Read and Grep aggressively to understand the full call graph.

### 3. Hunt

Investigate every suspicious pattern. For each file/hunk, ask:

- **Logic bugs** — off-by-one, wrong operator, incorrect condition, inverted boolean, wrong variable used
- **Race conditions** — shared mutable state, async/await misuse, missing locks, TOCTOU
- **Null / undefined derefs** — unguarded access, missing null checks at boundaries, optional chaining gaps
- **Edge cases** — empty input, zero, negative, max values, empty arrays, concurrent calls
- **Error handling** — swallowed errors, missing catch, error type not checked, partial failure not rolled back
- **Security** — injection vectors, auth bypass, secrets in logs, unsafe deserialization, SSRF
- **Resource leaks** — unclosed handles, missing cleanup in error paths, unbounded growth

### 4. Report

One finding per issue. Format:

```
### [FILE:LINE] Short title
**Category:** Logic bug / Race condition / Null deref / Edge case / Error handling / Security / Resource leak
**Severity:** Critical / High / Medium / Low
**Problem:** What is wrong and why it breaks.
**Trigger:** Minimal scenario that reproduces it.
**Fix:** Concrete remediation (code snippet if useful).
```

Sort by severity descending. If no real defects found, say so plainly — do not pad with nits.

End: one-line summary — count by severity, worst single issue.

## What this is NOT

Do not comment on style, formatting, naming, or spec compliance. Only defects that can cause incorrect runtime behaviour.
