# Vendored Skill Attribution

## Matt Pocock skills

From [mattpocock/skills](https://github.com/mattpocock/skills). MIT licensed, (c) 2026 Matt Pocock.
Synced from upstream `main` on 2026-08-31; earlier local modifications were discarded in favour of
upstream. Two exceptions, marked † below, are deliberately modified: see "Local deviations". Supporting files (`*-FORMAT.md`, `scripts/`, `template.sh`) vendored alongside.
Upstream `agents/openai.yaml` files are not vendored.

| Skill | Upstream path |
|---|---|
| `code-review` | `skills/engineering/code-review` |
| `codebase-design` | `skills/engineering/codebase-design` |
| `diagnosing-bugs` | `skills/engineering/diagnosing-bugs` |
| `domain-modeling` | `skills/engineering/domain-modeling` |
| `git-guardrails-claude-code` | `skills/misc/git-guardrails-claude-code` |
| `grill-me` | `skills/productivity/grill-me` |
| `grill-with-docs` | `skills/engineering/grill-with-docs` |
| `grilling` | `skills/productivity/grilling` |
| `handoff` | `skills/productivity/handoff` |
| `improve-codebase-architecture` | `skills/engineering/improve-codebase-architecture` |
| `prototype` | `skills/engineering/prototype` |
| `resolving-merge-conflicts` | `skills/engineering/resolving-merge-conflicts` |
| `tdd` | `skills/engineering/tdd` |
| `teach` | `skills/productivity/teach` |
| `to-questionnaire` | `skills/productivity/to-questionnaire` |
| `to-tickets` † | `skills/engineering/to-tickets` |
| `implement` † | `skills/engineering/implement` |
| `to-spec` | `skills/engineering/to-spec` |
| `wait-what` | `skills/productivity/wait-what` |
| `wayfinder` | `skills/engineering/wayfinder` |
| `wizard` | `skills/engineering/wizard` |
| `writing-for-agents` | `skills/productivity/writing-for-agents` |

Not vendored, and why: `ask-matt`, `setup-matt-pocock-skills` and `triage` are the rest of the
issue-tracker workflow, unused here; `research` collides with the local
`researcher` skill; `migrate-to-shoehorn`, `scaffold-exercises`, `setup-pre-commit` and
`setup-ts-deep-modules` assume a JS toolchain this repo does not use; everything under
`skills/in-progress/` is unstable upstream.

## Local deviations

`to-tickets` and `implement` are hardcoded to the local-markdown ticket mode: tickets live at
`.scratch/<feature-slug>/issues/<NN>-<slug>.md` and nowhere else. Removed from both: the
`/setup-matt-pocock-skills` prerequisite, the GitHub/GitLab/Linear publish branch, and the
tracker-flavoured issue template. `implement` was additionally rewritten to read the frontier from
those files, tick acceptance criteria as they pass, run the suite through the `test` subagent, and
**not** commit, per this repo's git policy (upstream ends with "Commit your work to the current
branch").

Resyncing either one from upstream will reintroduce the tracker branching and the commit step.

Resync: `gh api repos/mattpocock/skills/contents/<upstream path>/SKILL.md --jq .content | base64 -d`

## Product Manager Skills (removed 2026-08-30)

Thirteen discovery and delivery skills from [deanpeters/Product-Manager-Skills](https://github.com/deanpeters/Product-Manager-Skills) by Dean Peters, CC BY-NC-SA 4.0, were vendored here and have been removed: `jobs-to-be-done`, `problem-statement`, `customer-journey-map`, `proto-persona`, `discovery-interview-prep`, `opportunity-solution-tree`, `discovery-process`, `roadmap-planning`, `user-story`, `user-story-splitting`, `epic-breakdown-advisor`, `epic-hypothesis`, `prd-development`.

Reasons: fourteen overlapping model-invoked descriptions competed on every planning prompt and spent roughly 2400 characters of context per turn, several bodies ran past 600 lines with no progressive disclosure, and several carried "Related skills" pointers to skills never vendored here.

Reinstall the full set through the marketplace if wanted:

```
claude /plugin marketplace add deanpeters/Product-Manager-Skills
```

Or recover the vendored copies from git history: `git log --diff-filter=D --name-only`.
