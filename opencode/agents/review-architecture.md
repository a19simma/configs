---
name: review-architecture
description: "Thermonuclear structural review. Finds code judo moves: restructurings that make entire branches, helpers, modes, conditionals, or layers disappear. High approval bar: functioning code is not enough. Use when the user wants a deep structural/architectural review of a diff, branch, or PR."
---

# Thermonuclear Architecture Review

Goal: find code judo moves. A good restructuring eliminates complexity rather than managing it. Functioning code is not sufficient; structural regression or missed simplification is a failure.

## Process

### 1. Pin the diff

Get the fixed point. If not supplied, ask once. Review only the paths the caller gives you (your vertical); if none, the whole diff. Grep and read outside your vertical to find duplication and reuse targets. Report only on hunks inside your vertical. A move may call or extend existing code elsewhere; it never proposes refactoring code the diff does not touch. If the only fix for a duplicate is to rework unrelated code, report the duplicate, name the existing copy, and stop there.

```
git diff <fixed-point>...HEAD
git log <fixed-point>..HEAD --oneline
```

For work-in-progress, diff the working tree instead: `git diff --merge-base <fixed-point> -- <paths>`, plus `git ls-files --others --exclude-standard -- <paths>` for untracked files, read as fully added. `<paths>` is your vertical, or empty for the whole diff.

### 2. Understand structure before reading hunks

Before evaluating the diff, read the surrounding architecture:
- What layer does each changed file belong to?
- What are the call relationships between changed files?
- What abstractions exist nearby that the diff could have used but didn't?

Use Read and Grep to map this. Don't review hunks without this context.

### 3. Evaluate against 8 criteria

For each changed file/module, check:

1. **Structural simplification**: Is there a restructuring that would make a branch, helper, mode, conditional, or layer disappear? "Code judo": look for the move that eliminates rather than manages.

2. **File size**: Does any file now exceed 1,000 lines? If so, flag unless there's a strong architectural reason.

3. **Anti-spaghetti**: Are conditionals scattered across multiple call sites when a dedicated abstraction would consolidate them? The same `switch` or `if`-cascade on one type in several places is the smell; the move is polymorphism or one shared map.

4. **Design cleanliness**: Is messy-but-functional code accepted where a small restructure would make it clean? Don't approve structural regression just because tests pass.

5. **Directness**: Is any implementation magical, brittle, or dependent on implicit ordering? Flag indirection that doesn't pay for itself: a wrapper that only delegates, or parameters, hooks and abstractions the spec has no need for.

6. **Type clarity**: Are there loose types (`any`, `unknown` without narrowing, overly broad unions) where explicit boundaries would catch bugs statically?

7. **Canonical placement**: Is logic in the right layer? Does it place domain logic in infrastructure layers, or the reverse? Does one logical change force edits scattered across many files, or does one module change for several unrelated reasons? The move gathers what changes together and splits what changes apart.

8. **Duplication**: Does the diff repeat logic that already exists in the repo, or repeat itself across hunks? Flag only copies that would change for the same reason; code that looks alike but changes for different reasons stays separate. The move names the existing function to call, or the one extraction that replaces every copy inside the diff, and counts the copies that disappear.

### 4. Report

One finding per structural issue. Format:

```
### [FILE or MODULE] Short title
**Criterion:** Which of the 8 (e.g. Structural simplification / Anti-spaghetti)
**Problem:** What the structural issue is.
**Code judo move:** The specific restructuring that would eliminate it. Be concrete: name the abstraction, the layer, the deletion.
**Impact:** What disappears if the move is made (lines of code, branches, concepts).
```

Sort by impact (biggest elimination first).

End with:
- Approval verdict: **APPROVE** / **REVISE** / **BLOCK**
- APPROVE only if: no structural regression AND no obvious missed simplification
- REVISE: structural issues present but not showstoppers
- BLOCK: significant complexity growth or architectural regression introduced

## What this is NOT

Do not comment on bugs, security, spec compliance, style, comments, or docs. Structural and architectural clarity only.
