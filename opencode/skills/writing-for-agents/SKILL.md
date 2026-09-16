---
name: writing-for-agents
description: Writing documents for agents. Use when creating or editing skills, or modifying AGENTS.md or CLAUDE.md.
---

Applies to any document an agent consumes: a skill, an `AGENTS.md` / `CLAUDE.md`, a doc reached by a pointer. The packaging differs, the writing does not.

## Route

Take the first line that matches, read only the sections it names.

| Task | Read |
|---|---|
| Writing a new doc | Placement, then Wording |
| Doc too long, or the agent misses material inside it | Placement |
| Agent never reaches the doc, or fires it on the wrong thing | Pointers |
| Agent rushes or half-finishes the work | Completion |
| Tightening existing prose | Pruning, then Wording |
| Creating or changing a skill's frontmatter | Skills |

## Pointers

A **pointer** names out-of-context material and encodes when to reach it: a skill `description`, an `AGENTS.md` line naming a doc. Its wording, not its target, decides whether the agent gets there. A weak pointer to must-have material is a variance bug: sharpen the wording before you inline the material.

- Front-load the leading word.
- One trigger per branch the doc handles; collapse synonyms that rename one branch.
- Cut identity the body already carries.
- Pointers stay loaded every turn, so prune them harder than the body.

## Placement

Every doc and pointer spends one of two budgets:

- **Context load**: tokens and attention, every turn, whether it fires or not.
- **Cognitive load**: the human remembering the doc exists. Spend it where human judgement matters.

Three rungs, nearest need first:

1. **In-file step**: what the agent does, in order.
2. **In-file reference**: consulted on demand. A flat peer-set (every rule of a review on one rung) is fine.
3. **Disclosed reference**: a separate file behind a pointer, from a sibling in the same folder through fully external.

- Inline what every branch needs; disclose what only some branches reach.
- Keep a concept's definition, rules and caveats under one heading, so reading one part brings its neighbours.
- In a doc with steps, undisclosed reference buries them and makes attending to them a coin-flip.
- Split a run of steps when the later ones tempt the agent to rush the one in front. Needs a real context boundary: a hand-off or a subagent dispatch, since an inline call clears nothing.
- Splitting spends a load, so make the cut earn it.

## Completion

Every step ends on a **completion criterion**.

- Make it checkable: can the agent tell done from not-done? A fuzzy bound ("understanding reached") ends the step early.
- Make it exhaustive: "every modified model accounted for" forces the digging that "produce a change list" does not. Binds flat reference too, as "every rule applied".
- Sharpen the bound first. Hide the later steps only when the bound is irreducibly fuzzy and you see the rush.

## Wording

A **leading word** is a compact concept already in pretraining that the agent thinks with while running the doc (_lesson_, _fog of war_, _tracer bullets_). Repeat it as a token, never as a sentence. Reach for an existing word: a coined one recruits no priors, so you pay its definition in tokens.

- Collapse restatements into one word: "fast, deterministic, low-overhead" → _tight_; "a loop you believe in" → _red_. Assume every doc carries some, go find them.
- Reuse the word across your prompts, docs and code so its pointer fires more reliably.
- Prompt the positive. A prohibition drags the banned behaviour into context and makes it more available, so write "write one-line comments" rather than the ban. Keep a prohibition only as a hard guardrail, paired with the positive target.

## Pruning

- One meaning, one place. Duplication costs maintenance and inflates a meaning's rank.
- The environment is a source of truth too (`package.json` scripts, config files, `--help`). Restating it caches a lookup, worth its load only when the lookup is expensive: cache the unwritten convention, the reason behind a choice, the gotcha no config confesses, and leave one-command lookups where they cannot go stale.
- Check relevance line by line: mere exposition, a branch that should be disclosed, anything gone stale as the world it describes changed.
- Hunt no-ops sentence by sentence: an instruction the model already obeys by default. Settle it by running the doc, not by debate, and delete the whole sentence rather than trim words. It grades leading words too: _be thorough_ is a no-op, and the fix is a stronger word (_relentless_), not another technique.

## Skills

- **Model-invoked** (omit `disable-model-invocation`): the agent fires it on its own, other skills can reach it, and you can still type its name. Its `description` is a pointer forced to stay loaded, so write it by the Pointers rules. An all-reference model-invoked skill is also the home for reference several skills share.
- **User-invoked** (`disable-model-invocation: true`): only the human typing the name. Zero context load, paid in cognitive load. The `description` becomes a human-facing one-liner with triggers stripped.
- Default to user-invoked. Pick model-invocation when the agent or another skill must reach the skill on its own.
- Split off a model-invoked skill when a distinct leading word should trigger it, or another skill must reach it.
- Reference that two user-invoked skills share goes in a plain file outside the skill system: with no descriptions, neither can fire the other.
- When user-invoked skills outgrow what you remember, add a **router skill**: one user-invoked skill naming the others and when to reach for each. It can only hint, never fire them.
