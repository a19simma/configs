---
name: technical-writing
description: >
  Technical writing: plan and structure docs, READMEs, ADRs, commit messages, PR descriptions,
  doc comments, error messages and alt text. Use when a doc mixes purposes or misses its audience.
metadata:
  sources:
    - https://developers.google.com/tech-writing
    - https://developers.google.com/style
    - https://diataxis.fr/
---

Rules are paraphrased from Google's technical writing courses and developer style guide (CC BY 4.0) and from Diátaxis. The full courses sit in `references/`.

## Route

Take the first line that matches, read only what it names.

| Task | Read |
|---|---|
| New doc, or a doc that mixes purposes | Plan, then Doc types, then Sentences |
| Commit message, PR description, ADR | Doc types |
| Error message, CLI or log output | `references/error-messages.md` |
| Tightening existing text | Sentences, then stop-slop |
| Lists, tables, headings, code samples | Structure |
| Alt text, link text, inclusive wording | `references/accessibility.md` |
| A rule here needs its reasoning or an example | Courses |

## Plan

Before drafting, write down three things:

1. **Audience**: who reads it and what they already know. Name the terms they lack.
2. **Goal**: what the reader can do or understand after reading. One sentence.
3. **Mode**: pick one Diátaxis mode from the compass below. A doc serves one mode; split it when it needs two.

| The reader is | and needs to | Mode | Shape |
|---|---|---|---|
| learning | do something | Tutorial | A guaranteed path to one working result. Every step succeeds. No choices, no theory. |
| working | do something | How-to guide | Steps toward a goal the reader already has. Assumes competence. Starts at the goal, ends when it is met. |
| working | look something up | Reference | Dry, complete, structured like the thing it describes. Facts only. |
| learning | understand something | Explanation | Context, reasons, trade-offs, history. Prose, read away from the keyboard. |

Done when audience, goal and mode are each one line and the outline serves only that mode.

## Doc types

- **README**: what it is in the first sentence, then install, then the smallest working example. Link out for anything longer.
- **ADR**: context, decision, consequences. State the decision as a sentence a reader can disagree with. List the options rejected and why.
- **Commit message**: subject in the imperative, under about 72 characters, saying what the change does. Body says why, and what a reviewer cannot see in the diff. Follow the repo's existing convention, Conventional Commits included, when it has one.
- **PR description**: what changed, why, how it was verified, what to look at first. Link the issue.
- **Doc comment**: what the item does and the contract a caller relies on: inputs, outputs, errors, invariants. Leave out what the signature already says.
- **Error message**: what went wrong, why, and how to fix it, in that order. Name the bad input. See `references/error-messages.md`.

## Sentences

- One idea per sentence. Split a sentence that carries two.
- Active voice, with the actor named: "the scheduler retries the job", "you run `mise install`".
- Address the reader as "you". Write instructions in the imperative.
- Put the condition before the instruction: "To pin a version, run ...".
- Pick a specific verb. Replace "there is", "there are" and "occurs" with the actor and the action.
- Define a term at first use and keep using that exact term.
- Make each pronoun point at one obvious noun; repeat the noun when two are nearby.
- Open each paragraph with its point. Open each doc with its scope and audience.
- Cut words that carry nothing. A shorter sentence that says the same thing wins.

## Structure

- Numbered lists for steps in order; bulleted lists for unordered items. Keep list items parallel in grammar.
- One action per numbered step. Put the expected result after the step that produces it.
- Introduce every list and table with a sentence that says what it holds.
- Sentence case for titles and headings. Make a heading say what the section gives the reader.
- Table when items share the same attributes; prose when they don't.
- Code samples: short, runnable, correct, with the output when it helps. Mark placeholders and explain each one below the sample.
- Link text names the target: "see the mise github backend docs", never "click here".

## Courses

Load a course file only for the section you need; each file opens with a table of contents.

- `references/tech-writing-one.md`: [Technical Writing One](https://developers.google.com/tech-writing/one). Words, voice, clear and short sentences, lists and tables, paragraphs, audience, documents, punctuation, Markdown.
- `references/tech-writing-two.md`: [Technical Writing Two](https://developers.google.com/tech-writing/two). Self-editing, organizing large docs, illustrating, sample code, using LLMs in technical writing.
- `references/error-messages.md`: [Writing helpful error messages](https://developers.google.com/tech-writing/error-messages).
- `references/accessibility.md`: [Technical writing for accessibility](https://developers.google.com/tech-writing/accessibility).

Further reading, not bundled: [Google developer documentation style guide](https://developers.google.com/style), [Diátaxis](https://diataxis.fr/).
