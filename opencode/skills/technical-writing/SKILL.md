---
name: technical-writing
description: >
  Plan, structure and word technical docs: READMEs, ADRs, commit and PR messages, doc comments,
  error and CLI output, code samples, alt and link text. Use when drafting or restructuring a doc,
  or when one mixes purposes or misses its audience.
metadata:
  sources:
    - https://developers.google.com/tech-writing
    - https://developers.google.com/style
    - https://diataxis.fr/
    - https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions
    - https://adr.github.io/madr/
    - https://cbea.ms/git-commit/
---

This skill paraphrases Google's technical writing courses and developer style guide (CC BY 4.0) and Diátaxis. Doc types also draw on Nygard and MADR for ADRs, and on git convention for commits. The full courses are in `references/`.

## Route

Take the first line that matches, read only what it names.

| Task | Read |
|---|---|
| New doc, or a doc that mixes purposes | Plan, then Doc types, then Sentences, then stop-slop |
| README, commit message, PR description, ADR, doc comment | Doc types |
| Error message, including in CLI or log output | `references/error-messages.md` |
| Tightening existing text | Sentences, then stop-slop |
| Lists, tables, headings, code samples | Structure |
| Alt text, link text | `references/accessibility.md` |
| Inclusive wording | [Inclusive documentation](https://developers.google.com/style/inclusive-documentation), not bundled |
| A rule here needs its reasoning or an example | Courses |

## Plan

Before drafting, write down four things:

1. **Audience**: who reads it and what they already know. Name the terms they lack.
2. **Goal**: what the reader can do or understand after reading. One sentence.
3. **Mode**: pick one Diátaxis mode from the compass. A doc serves one mode; split it when it needs two.
4. **Outline**: one heading per section.

| The reader is | and needs to | Mode | Shape |
|---|---|---|---|
| learning | do something | Tutorial | A reliable path to one working result. Every step shows the promised result. One fixed route, one-line reasons at most. |
| working | do something | How-to guide | Steps toward a goal the reader already has. Assumes competence. Starts and ends where the reader's own work joins it. |
| working | know something | Reference | Dry, complete, structured like the thing it describes. Facts only. |
| learning | know something | Explanation | Context, reasons, trade-offs, history. Read away from the keyboard. |

Done when audience, goal and mode are each one line and the outline serves only that mode.

## Doc types

- **README**: what it is in the first sentence, then install, then the smallest working example. Link out for anything longer.
- **ADR**: context, decision, consequences. State the decision as a sentence a reader can disagree with. List the options rejected and why.
- **Commit message**: subject in the imperative, 50 characters or fewer, saying what the change does. Wrap the body at 72. Body says why, and what a reviewer cannot see in the diff. Follow the repo's existing convention, Conventional Commits included, when it has one.
- **PR description**: what changed, why, how you verified it, what to look at first. Link the issue.
- **Doc comment**: what the item does and the contract a caller relies on: inputs, outputs, errors, invariants. Leave out what the signature already says.
- **Error message**: what went wrong, why, and how to fix it, in that order. Name the bad input. See `references/error-messages.md`.

Done when every part the doc type lists is present, in that order.

## Sentences

- One idea per sentence. Split a sentence that carries two.
- Write instructions in the imperative.
- Put the condition before the instruction: "To pin a version, run `mise use node@22`."
- Replace "there is", "there are" and "occurs" with the actor and the action.
- Define a term at first use and keep using that exact term.
- Make each pronoun point at one obvious noun; repeat the noun when two are nearby.
- Open each doc with its scope and audience.

Done when every sentence passes every rule above.

## Structure

- Numbered lists for steps in order; bulleted lists for unordered items. Keep list items parallel in grammar.
- One action per numbered step. Put the expected result after the step that produces it.
- Introduce a list or table with a sentence that states its content, unless the heading already does. State the content, not its position ("Each mode fits one reader need:", not "the table below").
- Sentence case for titles and headings. Make a heading say what the section gives the reader.
- Table when items share the same attributes; prose when they don't.
- Code samples: short, runnable, correct, with the output when it helps. Mark placeholders and explain each one below the sample.
- Link text names the target: "see the mise `github` backend docs", never "click here".

Done when every list, table, heading and code sample passes every rule above.

## Courses

Load a course file only for the section you need; each file opens with a table of contents.

- `references/tech-writing-one.md`: [Technical Writing One](https://developers.google.com/tech-writing/one). Words, voice, clear and short sentences, lists and tables, paragraphs, audience, documents, punctuation, Markdown.
- `references/tech-writing-two.md`: [Technical Writing Two](https://developers.google.com/tech-writing/two). Self-editing, organizing large docs, illustrating, sample code, using LLMs in technical writing.
- `references/error-messages.md`: [Writing helpful error messages](https://developers.google.com/tech-writing/error-messages).
- `references/accessibility.md`: [Technical writing for accessibility](https://developers.google.com/tech-writing/accessibility).

Further reading, not bundled: [Google developer documentation style guide](https://developers.google.com/style), [Diátaxis](https://diataxis.fr/).
