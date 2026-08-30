# Vendored Skill Attribution

## writing-for-agents

From [mattpocock/skills](https://github.com/mattpocock/skills), path `skills/productivity/writing-for-agents`. MIT licensed, (c) 2026 Matt Pocock. Fetched 2026-08-30.

## Product Manager Skills (removed 2026-08-30)

Thirteen discovery and delivery skills from [deanpeters/Product-Manager-Skills](https://github.com/deanpeters/Product-Manager-Skills) by Dean Peters, CC BY-NC-SA 4.0, were vendored here and have been removed: `jobs-to-be-done`, `problem-statement`, `customer-journey-map`, `proto-persona`, `discovery-interview-prep`, `opportunity-solution-tree`, `discovery-process`, `roadmap-planning`, `user-story`, `user-story-splitting`, `epic-breakdown-advisor`, `epic-hypothesis`, `prd-development`.

Reasons: fourteen overlapping model-invoked descriptions competed on every planning prompt and spent roughly 2400 characters of context per turn, several bodies ran past 600 lines with no progressive disclosure, and several carried "Related skills" pointers to skills never vendored here.

Reinstall the full set through the marketplace if wanted:

```
claude /plugin marketplace add deanpeters/Product-Manager-Skills
```

Or recover the vendored copies from git history: `git log --diff-filter=D --name-only`.
