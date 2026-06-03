---
name: to-adr
description: Turn the current conversation context into an ADR. Use when user wants to record an architectural decision from the current context.
---

This skill takes the current conversation context and codebase understanding and produces an ADR. Do NOT interview the user — synthesize what you already know.

## When to use

All three must be true:

1. **Hard to reverse** — cost of changing your mind later is meaningful
2. **Surprising without context** — future reader will wonder "why did they do it this way?"
3. **Result of a real trade-off** — genuine alternatives existed and one was picked for specific reasons

If any fail, say so and skip the ADR.

## Process

1. Identify the core decision from the conversation. Distill to: what context led here, what was decided, why.

2. Check `docs/adr/` for existing ADRs — scan for highest number to determine next sequence number. Create `docs/adr/` if it doesn't exist.

3. Write the ADR using the format below and save to `docs/adr/NNNN-slug.md`.

## Format

```md
# {Short title of the decision}

{1-3 sentences: context, decision, and why.}
```

An ADR can be a single paragraph. Value is in recording *that* a decision was made and *why*.

## Optional sections

Include only when they add genuine value:

- **Status** (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — when decisions are revisited
- **Considered Options** — only when rejected alternatives are worth remembering
- **Consequences** — only when non-obvious downstream effects need calling out

## Numbering

Scan `docs/adr/` for highest existing number, increment by one. Format: `0001-slug.md`.
