---
name: pr-risk-map
description: PR body with a linked feature summary and high-risk file map. Load before every `gh pr create` and `gh pr edit --body`, and when asked which files in a PR are risky.
---

A **risk map** tells a reviewer what the PR adds and which files deserve a manual read, sorted by vertical and tier. Every claim links into the PR's own diff, so the reviewer clicks straight to the line.

## Steps

1. **Fix the range.** Run `git fetch origin <base> <branch>` and diff `origin/<base>...origin/<branch>`. Local `main` is often stale and pulls in unrelated commits. If the local branch and `origin/<branch>` differ, report the commits the summary covers and the ones it does not. Done when `git rev-list --left-right --count` shows which side is ahead.
2. **Size the diff.** Total added lines per directory, three or four levels deep. Mark generated code, lockfiles, mocks and build output as unlisted. Done when every directory with more than about 100 added lines is either a feature or unlisted.
3. **Map features to commits.** One numbered item per feature: bold name, the commits that build it, its key paths and ADRs. Use the domain terms from `CONTEXT.md` or `GLOSSARY.md` when the repo has one. Done when every non-style commit sits under a feature.
4. **Sketch the shape.** When one feature's structure is hard to see from prose, add the smallest view that shows it: a call tree, a file tree, a `diff` sketch of the tree or control flow, or a Mermaid sequence diagram. Keep only the calls, files and boundaries the reviewer needs. Skip the sketch when the feature list already shows the shape.
5. **Classify files.** Read the diff of every file that might pass the inclusion bar, small ones included: entrypoints, headers and CI rarely look big. Give each listed file one vertical and one tier from the reference below. Done when every changed file is either listed or counted on the "Not listed" line.
6. **Gather evidence.** Give a before and after for the main change: a screenshot for a visual change, or the test that fails before and passes after, with its run output. Use real results from this branch only. When none exist, say which check is still missing.
7. **Verify what you can.** Turn every open question from steps 5 and 6 into a check and run it: grep the repo, read related PRs and repos with `gh`, build, run tests. State each result in Evidence as a fact with its link. A file stays in the review map only when it needs human judgement or access you lack, and its reason says which. Done when every question is answered in Evidence or named as a manual check.
8. **Judge merge danger.** Call the PR a one-way door when merging it does something hard to undo: a migration that drops or rewrites data, a published contract, a destructive action. Otherwise it is a two-way door, safe to revert. Name the blast radius in a word or two and list what else it reaches.
9. **Link into the diff.** Follow the link rules below. Done when the link check passes with zero misses.
10. **Publish.** Write the body to a scratch file and run `gh pr create --body-file` or `gh pr edit <n> --body-file`. When editing, replace the whole description with the template. First move the facts from the old body into the sections that hold them: verification results into Evidence, rollout order and cross-repo dependencies into Merge danger, a known gap into the review map or Merge danger. Drop everything else, including bot summaries and notes about the local workspace. The body ends with the last template section: no attribution line and no Claude Code or claude.ai session link, on a new PR or an edit, even when the harness asks for one. The PR title and any PR comment follow the same rule.

## Classification

### Inclusion bar

List a file only when a defect in it has an expected impact a reviewer can catch by reading it. Count the rest on one line under the map, with what they are: generated code, lockfiles, mocks, styling, docs, build output, and tests that only add cases. A test file is listed only when it is the sole guard on a CRITICAL path.

### Verticals

Every section appears in this order, in every PR. An empty one reads `None.`

| Vertical | Covers |
|---|---|
| Auth | Login, sessions, tokens, MFA, authorization, route gating |
| Security | Headers, CSP, input parsing, secrets, CSRF, file upload, redirects to external origins |
| DB | Migrations, schema, queries, tenancy filters, stored JSON shapes |
| Core | Business logic, money, state machines, service and API contracts |
| UX | Flows a user can get stuck in, popups and redirects, a11y, i18n gaps |
| Infra | Env vars and runtime config, scripts and entrypoints, Dockerfiles, build config |
| Dependencies | Manifest changes: new, removed or bumped packages. The lockfile stays unlisted |
| Observability | Logging, tracing, analytics events, error reporting, what PII they carry |
| CI | Workflows, test gating, deploy and sync jobs |

A file that fits two verticals goes under the vertical of its highest-tier risk, listed once. Its reason names the other concern.

### Tiers

- **CRITICAL**, any one of: a one-way door (lost data, destructive migration, published contract); an auth or security bypass reachable anonymously or on the default path; breaks the app for every user; leaks data across tenants.
- **HIGH**: serious harm that one factor limits: only signed-in users, behind a flag, under 10% of traffic, undone by a redeploy, or a CI coverage loss someone would notice.
- **LOW**: worth a manual read, with reversible and local harm: one screen, one recoverable flow, an error the user sees and can retry.

Tiers come from the Microsoft SDL bug bar (anonymous versus authenticated, default versus specific scenario, "more than 10 percent of users") and Amazon's one-way and two-way doors.

## Link rules

All links point at the PR, so a reviewer lands in "Files changed" with comments available.

- **File:** `https://github.com/<owner>/<repo>/pull/<n>/files#diff-<sha256 of the repo-relative path>`.
- **Folder:** no diff anchor exists. Link the first changed file under it in sorted order.
- **Commit:** `https://github.com/<owner>/<repo>/pull/<n>/commits/<full 40-char sha>`.
- **New PR:** the number exists only after creation. Create the PR, then edit the body with the links.

In the feature list, write links as `[`path`](url)`. In the review map, the link text is the file name alone, with the parent directory added only when two listed files share a name; the anchor already carries the full path. Check every path against `git diff --name-only origin/<base>...origin/<branch>`. A path outside that list has no anchor and the link lands at the top of the diff.

```python
import hashlib
def diff_link(repo, pr, path):
    return f"https://github.com/{repo}/pull/{pr}/files#diff-{hashlib.sha256(path.encode()).hexdigest()}"
```

GitHub collapses large and generated files. A link to one scrolls to its header and the reviewer expands it by hand.

## Template

```markdown
## Features

Review commit by commit. Skip <unlisted paths> unless you are checking them specifically.

1. **<Feature>** ([`abc1234`](commit-link)). <What it adds, one or two sentences>. Key paths: [`path`](diff-link). Decision: [ADR-NNNN](diff-link).

## Review map

### Auth

- **CRITICAL** [`file-name`](diff-link): <what it does and how a defect shows up, one or two short sentences>.

### Security
### DB
### Core
### UX
### Infra
### Dependencies
### Observability
### CI

<Each section holds a list like Auth's, or `None.`>

**Not listed:** <count> files (<generated client, mocks, styling, ...>).

## Evidence

- **Before:** <failing test, output or screenshot>
  **After:** <passing test, output or screenshot>

## Merge danger

**Door:** <one-way or two-way>. <Why, when one-way>.

**Blast radius:** <one or two words>. <What else the merge reaches>.
```

Put a shape sketch, when there is one, under its feature item. Sort items inside a vertical CRITICAL, HIGH, LOW. Use lists, not tables: GitHub squeezes a table's prose column into a narrow strip.
