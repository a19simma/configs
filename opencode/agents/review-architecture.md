---
name: review-architecture
description: Thermonuclear structural review. Finds code judo moves — restructurings that make entire branches, helpers, modes, conditionals, or layers disappear. High approval bar: functioning code is not enough. Use when the user wants a deep structural/architectural review of a diff, branch, or PR.
---

# Thermonuclear Architecture Review

Goal: find code judo moves. A good restructuring eliminates complexity rather than managing it. Functioning code is not sufficient — structural regression or missed simplification is a failure.

## Process

### 1. Pin the diff

Get the fixed point. If not supplied, ask once.

```
git diff <fixed-point>...HEAD
git log <fixed-point>..HEAD --oneline
```

### 2. Understand structure before reading hunks

Before evaluating the diff, read the surrounding architecture:
- What layer does each changed file belong to?
- What are the call relationships between changed files?
- What abstractions exist nearby that the diff could have used but didn't?

Use Read and Grep to map this. Don't review hunks without this context.

### 3. Evaluate against 7 non-negotiables

For each changed file/module, check:

1. **Structural simplification** — Is there a restructuring that would make a branch, helper, mode, conditional, or layer disappear entirely? "Code judo": look for the move that eliminates rather than manages.

2. **File size** — Does any file now exceed 1,000 lines? If so, flag unless there's a strong architectural reason.

3. **Anti-spaghetti** — Are conditionals scattered across multiple call sites when a dedicated abstraction would consolidate them? Scattered `if type === X` is a smell.

4. **Design cleanliness** — Is messy-but-functional code accepted where a small restructure would make it clean? Don't approve structural regression just because tests pass.

5. **Directness** — Is any implementation magical, brittle, or dependent on implicit ordering? Flag indirection that doesn't pay for itself.

6. **Type clarity** — Are there loose types (`any`, `unknown` without narrowing, overly broad unions) where explicit boundaries would catch bugs statically?

7. **Canonical placement** — Is logic in the right layer? Does the diff introduce duplication of existing logic, or place domain logic in infrastructure layers (or vice versa)?

### 4. Report

One finding per structural issue. Format:

```
### [FILE or MODULE] Short title
**Criterion:** Which of the 7 (e.g. Structural simplification / Anti-spaghetti)
**Problem:** What the structural issue is.
**Code judo move:** The specific restructuring that would eliminate it. Be concrete — name the abstraction, the layer, the deletion.
**Impact:** What disappears if the move is made (lines of code, branches, concepts).
```

Sort by impact (biggest elimination first).

End with:
- Approval verdict: **APPROVE** / **REVISE** / **BLOCK**
- APPROVE only if: no structural regression AND no obvious missed simplification
- REVISE: structural issues present but not showstoppers
- BLOCK: significant complexity growth or architectural regression introduced

## What this is NOT

Do not comment on bugs, security, spec compliance, or style. Structural and architectural clarity only.
