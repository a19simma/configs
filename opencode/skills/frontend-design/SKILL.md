---
name: frontend-design
description: Choose a visual direction, write or extend DESIGN.md and design tokens, and critique rendered UI against them. Use for new UI, restyles, and design reviews. Skip for logic and backend work.
---

# Frontend Design

Four jobs, in order: **Lock** a direction, **Plan** against the brief, **Codify** the reference, **Build and critique** against it.

Check for `DESIGN.md` and a tokens file first. If both exist the direction is locked: extend them in Codify, then Build.

## 1. Lock the direction

Answer five questions before any code:

- **Purpose**: what problem does this interface solve, for whom?
- **Tone**: one extreme, named. Brutally minimal, maximalist, retro-futuristic, organic, luxury, playful, editorial, brutalist, art deco, pastel, industrial.
- **Constraints**: framework, performance, accessibility.
- **Differentiation**: the one thing someone remembers.
- **Surface**: persuade (landing pages), experience (editorial, immersive), operate (tools, dashboards) or read (docs, articles). Persuade and experience take full commitment. Operate and read show ambition as precision and restraint.

Draw from the subject's own world: its materials, vocabulary and audience. Name the outside reference (a magazine, an era, a physical object) so the choice traces to something the model did not invent.

Done when a second person could name the tone and the memorable thing from the writeup alone.

## 2. Plan against the brief

Write a compact plan before building:

- **Colour**: a base palette of 4 to 6 named hex values.
- **Type**: the typefaces and the role of each.
- **Layout**: a one-sentence concept, plus an ASCII wireframe for each option compared. State the alignment.
- **Principles**: what makes this interface its own.

Then review the plan against the brief. Any part you would produce for any similar page is a default, so replace it with a choice made for this brief and say what changed and why. The brief's own words win, including when it asks for a look listed under Defaults.

Run the swap test: replace the typeface and the layout with the usual ones. Wherever nothing changes, the plan defaulted there.

Done when every part of the plan traces to the brief and survives the swap test.

## 3. Codify the reference

Write `DESIGN.md` at the project root: the locked direction in prose, plus the plan's decisions. It is the single source of truth for every later UI task.

Land the tokens in code: CSS variables and Tailwind theme variables for colour, type scale, spacing, radii and shadow. Name them by role (`--surface-raised`), by role only, so a value change touches one line.

Done when a new component can be built from `DESIGN.md` and the tokens alone.

## 4. Build and critique

Build from `DESIGN.md`. Reuse existing components and tokens before writing new ones. Then critique the rendered result:

1. Screenshot at 320 and 1280 width as the minimum. `playwright-cli/references/ui-verification.md` names the four widths of the full sweep.
2. Compare each screenshot with the plan and `DESIGN.md`. Record each gap. Name what a glance reads first: it must be the memorable element.
3. Fix every gap that look showed, then screenshot again.

Stop after three rounds and report what remains.

Spend boldness in one place. One element is the memorable thing, and everything around it stays quiet. Cut decoration that serves no part of the brief.

Done when the screenshots match the plan, axe reports no critical or serious violations, and every `incomplete` item has been read.

## Defaults

These show up in generated pages whatever the subject. Each is a default, so use one only when the brief asks for it.

- Stock families (Inter, Roboto, Arial, system fonts) and purple gradients on white.
- Identical rounded cards with one radius and one soft grey shadow.
- A centred hero above a row of three feature cards.
- A cream background with a serif display face and a terracotta accent.
- A near-black background with one acid accent.
- An uppercase tracked eyebrow above every heading.
- Numbered markers (01, 02, 03) on content that has no sequence.
- One accented word in a headline.
- Fade-and-slide entrances on every section and hover effects on every card.

## Aesthetic levers

- **Typography**: one or two families with clearly distinct roles, a set type scale, lines under 80 characters.
- **Colour**: a dominant colour and a sharp accent, driven through theme variables.
- **Motion**: one orchestrated page-load moment. Other motion answers a person's action.
- **Composition**: asymmetry, overlap, generous negative space or controlled density, matched to the tone.
- **Depth**: texture, layering and shadow that serve the tone.

## Origin

The plan, review and screenshot-critique process adapts Anthropic's [frontend-design skill](https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md) (Apache-2.0), reworded. The swap test comes from [interface-design](https://github.com/Dammyjay93/interface-design) (MIT) and the surface modes from [impeccable](https://github.com/pbakaus/impeccable) (Apache-2.0), both reworded.
