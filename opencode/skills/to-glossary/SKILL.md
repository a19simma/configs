---
name: to-glossary
description: Create or update the domain glossary (CONTEXT.md) from the current conversation. Use when the user wants to capture domain terms, resolve naming conflicts, or document bounded contexts.
---

This skill extracts domain terms from the current conversation and writes them into the project's `CONTEXT.md` (or the relevant bounded-context file if a `CONTEXT-MAP.md` exists). Do NOT interview the user — synthesize what you already know, then ask only if something is genuinely ambiguous.

## When to use

- New domain terms surfaced in conversation that aren't in the glossary yet
- A naming conflict was resolved ("we'll call it X, not Y")
- A new bounded context is being introduced
- User explicitly asks to update the glossary

## Process

1. **Find the glossary** — check for `CONTEXT-MAP.md` first (multi-context repo), then root `CONTEXT.md`. If neither exists, create `CONTEXT.md` at the repo root lazily.

2. **Infer the context** — if multi-context, determine which context the current topic belongs to. Ask if genuinely unclear.

3. **Extract terms** — from the conversation, pull out:
   - Concepts with a specific meaning in this domain
   - Terms that were disambiguated or renamed
   - Relationships between concepts

4. **Write** — add or update terms following the format below. Existing terms: update if conversation changed them, leave untouched otherwise.

## Format

Follow the CONTEXT-FORMAT exactly:

```md
# {Context Name}

{1-2 sentence description.}

## Language

**TermName**:
{One sentence: what it IS, not what it does.}
_Avoid_: alias1, alias2

## Relationships

- A **Foo** belongs to exactly one **Bar**

## Flagged ambiguities

- "account" used to mean both **Customer** and **User** — resolved: distinct concepts.
```

## Rules

- One sentence per definition. What it IS, not what it does.
- List rejected synonyms under `_Avoid_`.
- Only project-specific concepts — no general programming terms.
- Flag any term used ambiguously with an explicit resolution.
- Bold term names in relationships.
- Only include terms specific to this project's domain — skip general programming concepts.
