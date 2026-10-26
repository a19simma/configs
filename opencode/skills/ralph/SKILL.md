---
name: ralph
description: Run a ralph loop: split a goal into tasks and drive fresh subagents through build, test, review and commit until all pass.
disable-model-invocation: true
argument-hint: [goal]
---

# Ralph

Goal: $ARGUMENTS

A ralph loop gives each task to a fresh subagent. Memory lives in `.ralph/` files and git, never in an agent's context. You are the conductor: you plan, dispatch, judge reports, and hold the gates. Workers implement and commit, they never mark a task done and never push.

## 0. Goal

When the goal above is empty or only whitespace, ask the human for it in one plain question and end the turn. Do nothing else, create nothing, until the answer arrives. A goal is done-able when a command or an observable result can prove it. When the stated goal has no such proof, ask what would prove it.

## 1. Spec

When `.ralph/tasks.json` already exists, resume: read `goal.md`, `tasks.json` and `progress.md`, confirm the current branch matches, and go to the loop without re-planning. Done when the next unfinished task is named.

Refuse on `main` or `master`. Work on branch `swarm/<slug>` when `SWARM_BOX=1`, otherwise `ralph/<slug>`.

Create `.ralph/` at the repo root and add `.ralph/` to `.git/info/exclude`. Done when all three files exist and the human has confirmed `goal.md`.

- `goal.md`: the goal in one paragraph, then one `key: value` line each:
  - `verify:` the command that proves a task is green (build, lint, tests). Exit 0 means green. Run it once now through the `test` agent. A verify command that is already red stops the skill.
  - `authorize:` `none`, `push`, or `push+deploy`. Record only what the human said in this session. Default `none`.
  - `deploy-verify:` commands that prove a deployment is live, or `none`.
  - `max-iterations:` default 20. `max-fails:` default 3 per task.
- `tasks.json`: array of `{"id","title","acceptance","passes":false,"fails":0}`. Size each task to finish in one subagent session: one behavior, one commit. A task titled "build the dashboard" is too big, split it. `acceptance` names a check the verify command or the reviewer can observe.
- `progress.md`: empty. Workers read it and append learnings.
- `improvements.md`: empty. Only you append to it, see Improvements.

Ask the human about every unknown in `goal.md` before the loop starts. Each question carries your recommendation, in the open-decisions format.

## 2. Loop

Repeat, one task at a time, until no task has `passes: false` and unblocked, or the iteration cap is hit. Record `base=$(git rev-parse HEAD)` before each dispatch.

1. **Pick** the first task with `passes: false` that is not blocked.
2. **Work**: dispatch one `claude` subagent with the worker brief below. It returns a short report. For a security or contract task, quote the design's normative lines in the brief and name both sides of any limit; tell the worker to take the stricter reading when the design is ambiguous and report it.
3. **Check commit**: HEAD must differ from `base`. No commit counts as a failure.
4. **Verify**: dispatch the `test` agent to run the `verify:` command, in the same message as the gate. Red counts as a failure. A run that ends in seconds with no cargo or test output is not a run: rerun it and require per-binary counts.
5. **Gate**: dispatch the `review` agent on `git diff <base>..HEAD` with the task and its acceptance. It must end with `GATE:PASS` or `GATE:FAIL`. A missing or unparsable verdict is retried once, then counts as FAIL. The gate cannot see worker reports, so tell it where the evidence lives (test names in the commit body). Brief it that only a code defect or an egregious doc error blocks. Egregious means a doc claim that would mislead an operator into an unsafe or broken action, or contradicts the design on a security or contract point. Every other doc finding (stale status lines, wording, missing mentions, text in an edited hunk) is DEFER: the gate lists it as `DEFER: <file:line> <finding>` and does not fail on it. The gate lists all blocking findings in one pass. Append every DEFER line to `.ralph/docs-backlog.md`. Brief the gate with the stated scope and every known DEFER up front, and quote the repo's allowed form beside any banned pattern. Tell it to read commits with `git show <hash>:<path>` or `git diff` and never to check out, reset or switch refs in the lane.
6. **Record**: on pass, set `passes: true` yourself and append one line to `progress.md`. On failure, increment `fails`, append the failure and the key lines of the red output, and at `max-fails` mark the task `blocked: true`. On every failure and every retry, also append one entry to `improvements.md`.

**Retry**: the retry worker squashes onto `base` (`git reset --soft <base>`, one recommit) and fixes the listed findings only, touching no other file or doc. Extra edits give the gate new text to fail on. A retry for doc findings only happens for egregious ones. When the last failure leaves only trivial wording findings and the code and verify are green, a further attempt is allowed once if the human is told.

**Docs lane**: when the code tasks are done and before Exit, add one docs-reconciliation task per vertical to `tasks.json`, fed by `docs-backlog.md` (ADR status lines, READMEs, plan, crate docs). Its gate is the normal one. Doc claims drift as code lands, so reconciling once at the end replaces a doc round per task.

### Improvements

Every failed gate, red verify, no-commit and retry teaches something. Record it the moment it happens, in `.ralph/improvements.md`, one entry each:

```
- task: <id>, attempt <n>
  symptom: <what the gate or verify said, one line>
  cause: <why the worker produced it, one line>
  class: repo | general | harness
  home: <narrowest CLAUDE.md path that governs the code, "global" for the user's global config, or "skill">
  rule: <the instruction that would have prevented it, one imperative line>
  status: open | evaluating
```

`repo` means the trap belongs to this codebase (a lint, a test trap, a doc convention). `general` means a coding or testing technique that applies to any repo (mutation method, seam rule, timing bands, cleanup order). It never goes into a repo file. `harness` means any ralph run would hit it (a gate brief that invites nit failures, a verify that can pass without running, a retry that widens its scope). Merge a repeat of an existing entry into it and count the repeat instead of writing a second one. A cause you did not observe is written as `unverified`. New entries start `open`. An entry is `evaluating` when its rule is not yet safe to adopt permanently (one occurrence, a cause still `unverified`, or a rule that might over-constrain workers). `improvements.md` holds only `open` and `evaluating` entries: a resolved entry is deleted, with one line in `progress.md` saying where it went.

Only you edit `tasks.json`. A worker's claim of success counts for nothing without steps 3 to 5.

Keep your own context lean: read reports, not diffs. Done when every task is `passes: true` or `blocked: true`, or the cap is hit.

### Worker brief

Send this to each worker, with the task filled in:

> You are one worker in a ralph loop. Do exactly one task, then stop. Task: `<the task JSON>`. Read `.ralph/goal.md`, `.ralph/progress.md` and the `CLAUDE.md` files of the repo root and of each directory you touch first. Search the codebase before assuming anything is missing. Implement the task fully, with no placeholders. Write the smallest set of tests that covers each acceptance check and each new branch, and watch each new test fail on the old behaviour first. Do not run mutation testing: the `mutant-review` skill does that on a schedule. Run clippy and the tests of the crates you touched, not the full verify command: the conductor runs it. Commit once on the current branch with a semantic commit message and no attribution lines. Append two lines of learnings to `progress.md`. Follow the repo's and the user's standing rules for file edits, comments and commits. Do not edit `tasks.json`, do not push, do not switch branches, do not touch other tasks. Report in six lines: what changed, files, verify result, commit hash, elapsed time of your longest command and whether other cargo jobs ran, surprises (name any trap you hit that those `CLAUDE.md` files do not already state).

## 3. Retro

Review `improvements.md` on a schedule: every 5 tasks that pass, whenever an entry reaches a count of 3, and once when the loop ends, before Exit. Each review leaves the file smaller or states why not. Dispatch one `claude` subagent with `improvements.md`, `progress.md` and this ruleset:

- Each `repo` entry becomes a line in the narrowest `CLAUDE.md` that governs the code it concerns, created if missing. Root `CLAUDE.md` holds only what spans directories. Write the rule as an imperative with the one-line reason. Check the file for an existing line on the same trap and strengthen it, never duplicate. Prune lines the code no longer needs.
- Each `general` entry is not applied by the subagent. It writes the proposed line for the user's global config to `.ralph/skill-proposals.md`, and you show it to the human like a harness proposal. Repo `CLAUDE.md` files hold only facts specific to this repo: a rule that would read the same in another repo does not belong there, and the subagent moves any such existing line out as a global proposal.
- Before writing a rule for a repeated or unexplained failure, send a `researcher` for docs and trusted sources on the technique, and cite what it found in the entry. Prefer an established method or tool over an invented one.
- Each `harness` entry is not applied by the subagent. It writes the proposed edit to the skill as a diff in `.ralph/skill-proposals.md`. You show that diff to the human with your recommendation, because the skill lives outside the repo.
- Settle every entry into exactly one outcome:
  - **adopt**: the rule is folded or proposed, then the entry is deleted.
  - **evaluating**: keep it, set `status: evaluating`, and write what evidence would settle it (for example "no repeat in the next 5 tasks"). On a later review, a rule with that evidence adopts, and one that keeps recurring after it was adopted is rewritten stronger.
  - **drop**: the cause was a one-off or the code changed, so delete the entry with one line in `progress.md` saying why.
- The subagent commits its `CLAUDE.md` changes as one semantic commit, `docs: ...`, no attribution, on the working branch.
- Done when no entry is `open`: each is deleted, `evaluating` with its evidence stated, or a harness proposal awaiting the human (kept as `evaluating` until the human answers).

When `harness` entries recur across runs and the proposals outgrow a few lines, move the ruleset into a dedicated `ralph` subagent definition and have this section dispatch it.

## 4. Exit

| State | You do |
|---|---|
| all tasks pass | go to 5 |
| a task is blocked | report the blocker with its `progress.md` lines, ask whether to re-split it or drop it, and name what stays unfinished |
| iteration cap | report the remaining tasks, ask before raising the cap |

## 5. Review, push, verify

1. Run the five review agents from the global review rules over `git diff <merge-base>..HEAD`. Fix findings through a second, smaller loop with a new `tasks.json`, not by hand. Suggest the human run `mutant-review` when the loop added logic that tests guard.
2. Push only when `authorize:` allows it, or `SWARM_BOX=1` on a `swarm/` branch. Never push `main`. In any other case stop and show the human the commands.
3. After a push, watch CI with `gh run watch` on the pushed commit. A red run reopens the loop with the failure as a task.
4. When `authorize:` is `push+deploy` and `deploy-verify:` is set, run each command through the `runner` agent and report its output. With `none`, say deployment is unverified.

Done when each of these is stated: review findings resolved or listed, push state, CI result, deploy state as verified or unverified.

## Headless

Under `claude -p` nobody answers questions. Launch with `CLAUDE_CODE_FORK_SUBAGENT=0` so each subagent finishes before the next step, and with a permission mode that allows Agent and Bash. Where section 1 would ask, take the stated default, record it in `goal.md`, and carry on. A missing goal ends the run with the question as the result. A blocked task is written to `progress.md` and the run ends. Rerun the same command to resume.
