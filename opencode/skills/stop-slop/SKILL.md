---
name: stop-slop
description: >
  Remove AI writing patterns from prose. Use when writing, drafting, rewriting, editing, revising,
  polishing, copyediting, humanizing or de-slopping any prose — blog posts, essays, docs, READMEs,
  PR descriptions, commit messages, emails, release notes, changelogs, landing copy — and when
  reviewing text for tone, voice, or style. Also use when the user says writing sounds robotic,
  generic, corporate, AI-generated, or "like ChatGPT wrote it".
metadata:
  upstream: https://github.com/hardikpandya/stop-slop
  author: Hardik Pandya (https://hvpandya.com)
  license: MIT
  local-additions: references/banned-lexicon.md, expanded references/examples.md, workflow + preserve-verbatim sections
---

# Stop Slop

Eliminate predictable AI writing patterns from prose.

The tells are mostly **shape**, not vocabulary. Swapping `delve` for `explore` while keeping the
structure still reads as AI. Fix structure first, words second.

## Reference files

| File | Load when |
| --- | --- |
| [references/structures.md](references/structures.md) | Always. The core payload — pattern skeletons to kill. |
| [references/phrases.md](references/phrases.md) | Always. Openers, crutches, jargon, adverbs, vague declaratives. |
| [references/banned-lexicon.md](references/banned-lexicon.md) | Always for drafting. Single-word tells and forbidden openers. |
| [references/examples.md](references/examples.md) | During revision, or when demonstrating before/after. |
| [references/voice-samples.md](references/voice-samples.md) | Whenever it has content. Matching a real sample beats every rule here. |

## Core Rules

1. **Cut filler phrases.** Remove throat-clearing openers, emphasis crutches, and all adverbs. See [references/phrases.md](references/phrases.md).

2. **Break formulaic structures.** Avoid binary contrasts, negative listings, dramatic fragmentation, rhetorical setups, false agency. See [references/structures.md](references/structures.md).

3. **Use active voice.** Every sentence needs a human subject doing something. No passive constructions. No inanimate objects performing human actions ("the complaint becomes a fix").

4. **Be specific.** No vague declaratives ("The reasons are structural"). Name the specific thing. No lazy extremes ("every," "always," "never") doing vague work. A number, name, date, filename, or quote beats an adjective.

5. **Put the reader in the room.** No narrator-from-a-distance voice. "You" beats "People." Specifics beat abstractions.

6. **Vary rhythm.** Mix sentence lengths. Two items beat three. End paragraphs differently. No em dashes.

7. **Trust readers.** State facts directly. Skip softening, justification, hand-holding.

8. **Cut quotables.** If it sounds like a pull-quote, rewrite it.

9. **Plain copulas.** Write `is`, `was`, `has`. Not `serves as`, `stands as`, `emerged as`, `represents`, `constitutes`.

10. **No summary paragraph.** No `In conclusion`, no closing restatement. End on the last real point.

## Workflow

**Drafting:** read `voice-samples.md` first and match its sentence-length spread and vocabulary
ceiling. Then draft to the rules above — do not write freely and clean up after. Then run Quick
Checks and score.

**Revising:** read the whole text and identify what it is actually trying to say; preserve that
claim. Structural pass (kills 20-40% of length), then lexical pass, then concreteness pass, then
rhythm pass. Score.

## Quick Checks

Before delivering prose:

- Any adverbs? Kill them.
- Any passive voice? Find the actor, make them the subject.
- Inanimate thing doing a human verb ("the decision emerges")? Name the person.
- Sentence starts with a Wh- word? Restructure it.
- Any "here's what/this/that" throat-clearing? Cut to the point.
- Any "not X, it's Y" contrasts? State Y directly.
- Three consecutive sentences match length? Break one.
- Three-item list or triadic clause? Use two or four.
- Paragraph ends with punchy one-liner? Vary it.
- Em-dash anywhere? Remove it.
- Two paragraphs opening with the same word or part of speech? Rewrite one.
- Vague declarative ("The implications are significant")? Name the specific implication.
- Narrator-from-a-distance ("Nobody designed this")? Put the reader in the scene.
- Meta-joiners ("The rest of this essay...")? Delete. Let the essay move.
- Closing paragraph that restates the piece? Delete it.
- Bulleted list of full sentences that should be a paragraph? Convert it.

## Scoring

Rate 1-10 on each dimension:

| Dimension | Question |
|-----------|----------|
| Directness | Statements or announcements? |
| Rhythm | Varied or metronomic? |
| Trust | Respects reader intelligence? |
| Authenticity | Sounds human? |
| Density | Anything cuttable? |

Below 35/50: revise.

## Preserve verbatim

Never rewrite or "simplify" code, commands, config, identifiers, file paths, log output, error
messages, quotations, names, version numbers, API field names, legal or licence text, or anything
the user marked fixed.

## Exception clause

Break any rule rather than say something false or unclear. When jargon, passive voice, or a long
word is the precise choice, keep it and flag it in a short list after the draft. Never trade
accuracy for style silently.

## Silence

Apply all of this silently. Never mention the rules, lists, or score inside the delivered prose. If
the user asked for a review, keep findings separate from the text.

## Examples

See [references/examples.md](references/examples.md) for before/after transformations.

## License

MIT. Upstream: https://github.com/hardikpandya/stop-slop
