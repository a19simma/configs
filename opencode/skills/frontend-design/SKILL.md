---
name: frontend-design
description: Lock one aesthetic direction and write it down as the project's design system.
disable-model-invocation: true
---

# Frontend Design

Two jobs, in order. **Locking** picks one aesthetic direction. **Codifying** writes that direction down as the design system, so every later UI task reads it instead of re-inventing it.

Check for the design system first (`DESIGN.md` and a tokens file). If it exists the direction is already **locked**: go straight to Codify and extend what's there.

## 1. Lock the direction

Answer four questions before any code:

- **Purpose**: what problem does this interface solve, for whom?
- **Tone**: one extreme, named. Brutally minimal, maximalist chaos, retro-futuristic, organic, luxury, playful, editorial, brutalist, art deco, pastel, industrial.
- **Constraints**: framework, performance, accessibility.
- **Differentiation**: the one thing someone remembers.

Pick fonts and palettes with a point of view: a distinctive display face paired with a refined body face, a dominant colour with a sharp accent. Name the outside reference you're drawing on (a magazine, an era, a physical object) so the choice is traceable to something the model didn't invent.

Commit to one direction. Bold maximalism and refined minimalism both work; intentionality is the lever, not intensity. Match implementation complexity to the vision: maximalism earns elaborate effects, minimalism earns restraint and precise spacing.

The direction is locked when a second person could name the tone and the memorable thing from the writeup alone.

## 2. Codify it as the reference

Write `DESIGN.md` at the project root: the locked direction in prose, plus the decisions below. This file is the single source of truth for every later UI task.

Land the tokens in code so the reference is executable, not aspirational: CSS variables and Tailwind theme vars for colour, type scale, spacing, radii, and shadow. Name them by role (`--surface-raised`), not by value (`--gray-200`).

Done when a new component can be built from `DESIGN.md` and the tokens alone, with no further aesthetic decisions.

## Aesthetic reference

- **Typography**: beautiful, unique, characterful faces. Pair a distinctive display font with a refined body font.
- **Colour & theme**: dominant colours with sharp accents outperform timid, evenly-distributed palettes. Drive everything through theme variables.
- **Motion**: CSS-only where possible, Motion.js when available. One well-orchestrated page load with staggered reveals (`animation-delay`) beats scattered micro-interactions. Scroll triggers and surprising hover states.
- **Spatial composition**: asymmetry, overlap, diagonal flow, grid-breaking elements. Generous negative space or controlled density.
- **Backgrounds & detail**: atmosphere and depth over flat fills. Gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, grain overlays.
