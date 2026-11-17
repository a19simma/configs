---
name: ralph
description: "Run a ralph loop: split a goal into tasks and drive fresh subagents through build, test, review and commit until all pass."
argument-hint: [goal]
---

# Ralph

Goal: $ARGUMENTS

A ralph loop gives each task to a fresh subagent. Memory lives in `.ralph/` files and git, never in an agent's context. You are the conductor: you plan, dispatch, judge reports, and hold the gates. Workers implement and commit, they never mark a task done and never push.

## 0. Goal

When the goal above is empty or only whitespace, ask the human for it in one plain question and end the turn. Do nothing else, create nothing, until the answer arrives. A goal is done-able when a command or an observable result can prove it. When the stated goal has no such proof, ask what would prove it.

## 1. Spec

When `.ralph/tasks.json` already exists, resume: read `goal.md`, `tasks.json` and `progress.md`, confirm the current branch matches, run the lane Sweep (see Parallel lanes), and go to the loop without re-planning. Done when stale lanes are closed and the next unfinished task is named.

Refuse on `main` or `master`. Work on branch `swarm/<slug>` when `SWARM_BOX=1`, otherwise `ralph/<slug>`.

Create `.ralph/` at the repo root and add `.ralph/` to `.git/info/exclude`. Done when every file below exists, `check-tasks.py` exits 0, and the human has confirmed `goal.md`.

- `goal.md`: the goal in one paragraph, then one `key: value` line each:
  - `verify:` the command that proves a task is green (build, lint, tests). Exit 0 means green. Run it once now through the `test` agent. A verify command that is already red stops the skill.
  - `authorize:` `none`, `push`, or `push+deploy`. Record only what the human said in this session. Default `none`.
  - `deploy-verify:` commands that prove a deployment is live, or `none`.
  - `max-iterations:` default 20. `max-fails:` default 5 per task. `max-lanes:` default 2, the number of tasks that run at once, since each lane runs its own build and verify.
  - `lane-env:` the variables the verify binds or writes that two lanes would collide on (ports, database names, scratch directories), or `none`. Default `none`.
- `tasks.json`: array of `{"id","title","acceptance","slices":[],"depends":[],"why":"","passes":false,"fails":0}`. Size each task to finish in one subagent session: one behavior, one commit. A task titled "build the dashboard" is too big, split it. `acceptance` names a check the verify command or the reviewer can observe. `slices` names every slice the task writes (see `slices.json`). `depends` lists the ids whose commits this task builds on, and `why` states the link in one line, naming the slice or contract that carries it ("the server task reads the field that task T3 adds to the contract slice"). Dispatch the `architect` agent over the draft list to set all three on every task. A task missing `depends` waits for the task before it in the array, and a task missing `slices` owns every slice, so an old list runs serially. An empty `slices` list owns none.
- `slices.json`: `{"slices":{"<name>":{"paths":[...],"role":"<one line>"}},"mergeable":[...]}`. A slice is a vertical with one owner at a time: a package or module, the shared contract that several packages read or generate from (schemas, wire definitions, migrations; name it `contract`), the deploy files. Paths are repo-relative, a directory covers everything under it, and no path belongs to two slices. `mergeable` lists the paths any task may edit and git can merge, such as ADR indexes, status lines, READMEs and changelogs. Text that merges is not a vertical, so these never block a pick. Dispatch the `architect` agent to cut the slices from the repo layout, then confirm them with the human in `goal.md`.
- `.ralph/check-tasks.py`: exits 0 when ids are unique, every `depends` id exists, the graph has no cycle, every `depends` entry has a `why`, every task slice exists in `slices.json`, no two slices share a path, and no `mergeable` path lies inside a slice. Run it after every write to `tasks.json` or `slices.json`.
- `slices.md`: empty at planning. One line per friction event or proposal: `<task id or source>: <path or slice> | <what happened> | <proposed cut>`. It sits beside `progress.md` and holds only slice evidence. Workers, you and the retro append to it; only the retro edits `slices.json` from it.
- `progress.md`: empty. Workers read it and append learnings.
- `improvements.md`: empty. Only you append to it, see Improvements.

Ask the human about every unknown in `goal.md` before the loop starts. Each question carries your recommendation, in the open-decisions format.

## 2. Loop

A turn ends only when every remaining task is passed, blocked, or waiting on a human decision, or the iteration cap is hit. A running job alone never justifies a report: end the turn silently after dispatching, and rely on the notification and the heartbeat to wake you. Ready tasks plus free lanes means dispatch in this turn. A landing, verify result or gate result is a step, never a stopping point: do the next step in the same turn and report only at Exit or on a block. Arm the heartbeat (below) at loop start. On every wake-up, run Sweep, then Pick, before anything else.

### Heartbeat

A lost notification, a killed agent or a dead pueue job stalls a loop that waits on them. The heartbeat is the one wake-up that needs no notification.

- **Arm** at loop start and on resume, after `CronList` shows none whose prompt starts `ralph heartbeat <slug>`. Create it with `CronCreate`, every 20 minutes, prompt `ralph heartbeat <slug>: in <main-tree path>, read .ralph/tasks.json and progress.md, run Sweep, then Pick, dispatch every ready task, and end the turn silently when nothing is ready or waiting on a human`.
- **Wake-up**: a task `running` for longer than twice its last verify wall time with no new `progress.md` line, a verify job with no new suite result for 3 minutes, and a lane with no commit past its base after a worker report are stalled. Diagnose, `pueue kill` the job by id and retry, or count the failure. A wake-up that finds every lane progressing changes nothing and says nothing.
- **Only while lanes work**: keep it armed while a lane has a running worker or verify. Delete it with `CronDelete` the moment none does: a block, a wait on a human decision, a cap hit, any Exit state. Re-arm it with the next dispatch or on resume. A heartbeat with no working lane wakes a loop that has nothing to do.

Repeat until no task has `passes: false` and unblocked, or the iteration cap is hit. Each task runs in its own lane (see Parallel lanes). Record that lane's `base=$(git rev-parse HEAD)` before each dispatch. Before each dispatch, compare `git reflog <integration branch>` with your own landings: an entry you did not make is reported to the human and its task gets the gate and verify before anything builds on it.

1. **Pick** every ready task in array order, up to `max-lanes` at once. Ready means `passes: false`, not blocked, every `depends` id passed, and no slice shared with a running task. Each pick runs steps 2 to 6 in its own lane.
2. **Work**: dispatch one `claude` subagent with the worker brief below. It returns a short report. For a security or contract task, quote the design's normative lines in the brief and name both sides of any limit; tell the worker to take the stricter reading when the design is ambiguous and report it. When the brief fences a flow or mode as unchanged, it names which rule groups are fenced (layout versus colour), and the worker reads the measuring code before choosing a layout property.
3. **Check commit**: HEAD must differ from `base`. No commit counts as a failure. Assert `git log -1 --format=%s` matches `type(scope): subject` at 72 characters or fewer, since a mangled commit command once left the subject `x`. Every path in `git diff --name-only <base>..HEAD` must lie inside the task's slices or the `mergeable` list; a path outside them counts as a failure naming that path.
4. **Verify**: dispatch the `test` agent to run the `verify:` command, in the same message as the gate. Red counts as a failure. A run that ends in seconds with no build or test output is not a run: rerun it and require per-suite counts. Set the verify time cap from the observed range of earlier runs (record each wall time in `progress.md`), never from a guess. The verify prints per-suite test counts so a live run shows progress. A docs-only change may skip the full verify when the conductor says so in the brief and states it in `progress.md`. Tell the `test` agent to run verify exactly once and to stop, not restart, when the conductor kills its job. Never start a verify while a retry worker runs in the same tree. Merge the integration branch into the lane before verifying, so the verify runs once on the final tree. After killing a verify, wait for its test agent's completion notification before starting the next one on the same database port, or use a fresh port per run. Allocate each `lane-env` value (port, database name) once from a counter in `progress.md`, across verifies and worker briefs. Kill a verify with no new suite result for 3 minutes and diagnose it. A binary that takes 30 s on the nose in the `finished in` lines is a pool or acquire timeout, not work: diagnose it before the next task.
5. **Gate**: dispatch the `review` agent on `git diff <base>..HEAD` with the task and its acceptance. It must end with `GATE:PASS` or `GATE:FAIL`. A missing or unparsable verdict is retried once, then counts as FAIL. The gate cannot see worker reports, so tell it where the evidence lives (test names in the commit body). Brief it that only a code defect or an egregious doc error blocks. Egregious means a doc claim that would mislead an operator into an unsafe or broken action, or contradicts the design on a security or contract point. Every other doc finding (stale status lines, wording, missing mentions, text in an edited hunk) is DEFER: the gate lists it as `DEFER: <file:line> <finding>` and does not fail on it. The gate lists all blocking findings in one pass. Append every DEFER line to `.ralph/docs-backlog.md`. Brief the gate with the stated scope and every known DEFER up front, and quote the repo's allowed form beside any banned pattern. Tell it to read commits with `git show <hash>:<path>` or `git diff` and never to check out, reset or switch refs in the lane. Tell it to scan the diff for leftover mutants, scratch files and stub early returns, and to fail on any.
6. **Record**: on pass, set `passes: true` yourself and append one line to `progress.md`. On failure, increment `fails`, append the failure and the key lines of the red output, and at `max-fails` mark the task `blocked: true`. On every failure and every retry, also append one entry to `improvements.md`.

**Retry**: the retry worker squashes onto `base` (`git reset --soft <base>`, one recommit) and fixes the listed findings only, touching no other file or doc. Extra edits give the gate new text to fail on. When the lane has merged the integration branch since the original base, the retry base is the integration HEAD at the last merge, never the original base: state the sha in the retry brief, and run `git diff --name-only <base>..HEAD` after the retry, since any path outside the task's own files means the squash folded integration content or reverted newer base work. A retry for doc findings only happens for egregious ones. The retry brief ends with `git status --short` empty and `git show --stat HEAD` listing the fixed files; the conductor checks status before verify. When a retry answers a finding on a closed list (decorations, hidden characters, ranges), tell the worker to replace the list with a set derived from the input's grammar or an authoritative source and to name the sibling variants it covers, so the retry does not fix one entry per round. When the last failure leaves only trivial wording findings and the code and verify are green, a further attempt is allowed once if the human is told.

**Docs lane**: when the code tasks are done and before Exit, add one docs-reconciliation task per vertical to `tasks.json`, fed by `docs-backlog.md` (ADR status lines, READMEs, plan, crate docs). Each sets `depends` to the code tasks it documents and leaves `slices` empty, since docs are mergeable, so verticals reconcile in parallel. Its gate is the normal one. Doc claims drift as code lands, so reconciling once at the end replaces a doc round per task.

### Audits

A rendered or browser audit is scoped, parallel and capped. Split it into independent `designer` instances, one per flow and viewport, run in one message. Cap each at about 20 minutes of wall time. A re-audit covers the changed path plus a short regression spot-check, never the full scope again. A fix worker answering a browser-audit finding brings real-browser before and after counts. Never ask the human about audit length: the human set this rule.

### Parallel lanes

A lane is a git worktree on its own branch, so concurrent workers share no files. The integration branch is the branch the loop started on.

1. **Open**: when a task is picked, run `mkdir -p ~/.worktrees/<repo>` and `git worktree add ~/.worktrees/<repo>/<slug>-<id> -b ralph/<slug>-<id>` from the integration branch, with the path resolved to an absolute one once. Lanes live outside `~/repos`, so `ls ~/.worktrees/<repo>` lists them and no repo scan picks them up. Link the memory with `ln -s <main-tree>/.ralph <lane>/.ralph` and add `.ralph` without a trailing slash to `.git/info/exclude`: a trailing slash matches directories only, and a symlink is not one. Export the `lane-env:` variables from `goal.md` with values unique to the lane.
2. **Run**: steps 2 to 6 happen in the lane. Name the lane path in every brief (worker, `test`, `review`), so each command and each diff read happens there. Retries stay in the lane.
3. **Land**: one lane lands at a time. On gate pass, run `git merge <integration branch>` inside the lane. A lane lands when its own verify and gate were green and the merge of the integration branch into it was conflict-free and touched only files outside the lane's diff. A conflict or an overlapping file forces a lane verify rerun. A conflict in a `mergeable` path is resolved in the lane by keeping both sides and is not a failure. Two lanes that took the same sequence number (a migration, an ADR) are resolved by renumbering the later lane's file. Any other conflict, or a red verify, counts as a failure of this task, and its retry worker fixes it in the lane. When the lane is green on top of the integration HEAD, run `git merge --ff-only <lane branch>` in the main tree. When `--ff-only` refuses because another lane landed first, repeat Land. The conductor runs one main-tree verify per batch of at most 3 landings and before any dispatch that depends on them. A red main verify is bisected across the batch and the culprit lane is reopened. Run the landing git writes (merge, branch delete, worktree remove) inline as the conductor: the `runner` agent may refuse git writes.
4. **Close**: every lane closes on every outcome: landed, `blocked: true`, abandoned, or cap hit. Remove the worktree with `git worktree remove --force <literal path>`, which also deletes its `target/`. Delete the lane branch with `git branch -d` only after Land. A blocked or abandoned lane keeps its branch, and `progress.md` records the branch name and its last commit hash. Run each as its own command. A conflict between lanes means a slice owns a path it should not, or two slices share one: append a line to `slices.md` and correct `slices.json`.

5. **Sweep**: run it at resume and at Exit in every state. List lanes with `git worktree list --porcelain` and keep the entries under `~/.worktrees/<repo>/` whose branch starts with `ralph/<slug>-`. Close every lane that has no running task as in Close. Run `git worktree prune` for entries whose directory is gone. Resolve each path first and print it, then remove with one literal command each. Done when `git worktree list` shows only the main tree and the lanes of running tasks.

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

Only you edit `tasks.json`, and `check-tasks.py` runs after every edit. A worker's claim of success counts for nothing without steps 3 to 5.

Keep your own context lean: read reports, not diffs. Done when every task is `passes: true` or `blocked: true`, or the cap is hit.

### Worker brief

Send this to each worker, with the task filled in:

> You are one worker in a ralph loop. Do exactly one task, then stop. Task: `<the task JSON>`. Work in `<lane path>` and write only paths inside the task's `slices` or the `mergeable` list; when the task needs another path, stop, append a line to `.ralph/slices.md`, and report it. Read `.ralph/goal.md`, `.ralph/progress.md` and the `CLAUDE.md` files of the repo root and of each directory you touch first. Search the codebase before assuming anything is missing. Implement the task fully, with no placeholders. Write the smallest set of tests that covers each acceptance check and each new branch, and watch each new test fail on the old behaviour first. Name each new test and the red output it gave on the old code in the report, or say it was skipped. For any parser, matcher or filter on untrusted input, include a hostile-input table. For a security policy, include a test under the production setting with the real tool. When a progress.md CONTRACT NOTE names a consumer of the task's output, the brief quotes it. Do not run mutation testing: the `mutant-review` skill does that on a schedule. When a mutation check is part of the task, run it against a copy of the file or a throwaway worktree, never by editing the tracked file in place, and confirm with `git diff` before the commit that no mutant remains. Report your progress lines in the report and do not write `.ralph/progress.md`: it is a symlink git refuses to add inside a lane, and the conductor appends your lines. Keep scratch (scripts, logs) outside `.ralph/` in a `mktemp` directory and delete it before reporting. Run every cheap step of `verify:` (the fmt check and clippy, with the full flags it writes) and only the test targets your change touches (for Rust, `cargo test -p <crate> --test <name>`), not the full verify command and not a whole workspace: the conductor runs it. Also run every test binary that references the seam you changed or the fake it replaces: grep `tests/` for the binary name (for example `gh` or `claude_bin`) and run each hit. When the brief explains a flag, key or mode, it quotes what the code does with it (file:line) instead of paraphrasing from memory, and the worker re-reads that line before writing the claim. Run the lint command exactly as `verify:` writes it, never a narrower form, through `mise exec --`, and report its exit code: a toolchain-dependent failure is not pre-existing, and the conductor verify is the authority on whether a failure predates the task. Bound every command you run. Lanes share one pueue queue: read the log of the id printed by your own `pueue add`, never the latest id, and put exports such as DATABASE_URL in a script file, since `mise exec` drops env set by `sh -c` under pueue. macOS has no `timeout` binary, so run a long command as one quoted-string pueue job (`pueue add --print-task-id -- '<command>'`), poll it, and `pueue kill` it when it stalls. Add no env var or flag that weakens a protection. Never read `~/.config/fleet`, env files or secrets, and never tell a `runner` to. The brief names the repo's private-pattern list and box-name format from its `CLAUDE.md`: run `git grep -nE` for the private pattern over your diff before the final report, and build any name the pattern forbids at runtime in tests. When replacing a framework loop or wrapper, list every extension, header and truncation marker the old one provided and test each. When a finding names a category or standard set, generate the full set from an authoritative source and test by iterating it. Commit once on the current branch with a semantic commit message and no attribution lines. Before reporting, assert `git log -1 --format=%s | wc -c` is at most 73 (the count includes the newline) and `git status --short` is empty. Append two lines of learnings to `progress.md`. Follow the repo's and the user's standing rules for file edits, comments and commits. Do not edit `tasks.json`, do not push, do not switch branches, do not touch other tasks. Report in six lines: what changed, files, verify result, commit hash, elapsed time of your longest command and whether other cargo jobs ran, surprises (name any trap you hit that those `CLAUDE.md` files do not already state).

## 3. Retro

Review `improvements.md` on a schedule: every 5 tasks that pass, whenever an entry reaches a count of 3, and once when the loop ends, before Exit. Each review leaves the file smaller or states why not. Dispatch one `claude` subagent with `improvements.md`, `progress.md` and this ruleset:

- Each `repo` entry becomes a line in the narrowest `CLAUDE.md` that governs the code it concerns, created if missing. Root `CLAUDE.md` holds only what spans directories. Write the rule as an imperative with the one-line reason. Check the file for an existing line on the same trap and strengthen it, never duplicate. Prune lines the code no longer needs.
- Each `general` entry is not applied by the subagent. It writes the proposed line for the user's global config to `.ralph/skill-proposals.md`, and you show it to the human like a harness proposal. Repo `CLAUDE.md` files hold only facts specific to this repo: a rule that would read the same in another repo does not belong there, and the subagent moves any such existing line out as a global proposal.
- Before writing a rule for a repeated or unexplained failure, send a `researcher` for docs and trusted sources on the technique, and cite what it found in the entry. Prefer an established method or tool over an invented one.
- Each `harness` entry is not applied by the subagent. It writes the proposed edit to the skill as a diff in `.ralph/skill-proposals.md`. You show that diff to the human with your recommendation, because the skill lives outside the repo.
- Read `slices.md` and settle each line: edit `slices.json` when the same friction repeated or the cut was plainly wrong, otherwise keep the line with the evidence still needed. Run `check-tasks.py` after the edit.
- Settle every entry into exactly one outcome:
  - **adopt**: the rule is folded or proposed, then the entry is deleted.
  - **evaluating**: keep it, set `status: evaluating`, and write what evidence would settle it (for example "no repeat in the next 5 tasks"). On a later review, a rule with that evidence adopts, and one that keeps recurring after it was adopted is rewritten stronger.
  - **drop**: the cause was a one-off or the code changed, so delete the entry with one line in `progress.md` saying why.
- Review the verify loop time. From the `[ Ns]` stamps in the latest `verify-last*.log` files and the wall times in `progress.md`, report the phase split (fmt, clippy, test build, test run, scans), the 10 slowest test binaries by their `finished in` line, the total test count and its growth since the last review, and whether binaries run serially. Compare against the previous review. When the run grew more than 10% or a binary takes more than 10 s, open a lane to measure what it waits on and cut it before adding more tests: merge test binaries, table-test repeated cases, shrink real waits through injected clocks, run independent binaries in parallel. Record each review as one line in `progress.md` and each proposal in `improvements.md` with class `harness` or `repo`. Name the saving and measure it with the same verify.
- The subagent commits its `CLAUDE.md` changes as one semantic commit, `docs: ...`, no attribution, on the working branch.
- Done when no entry is `open`: each is deleted, `evaluating` with its evidence stated, or a harness proposal awaiting the human (kept as `evaluating` until the human answers).

When `harness` entries recur across runs and the proposals outgrow a few lines, move the ruleset into a dedicated `ralph` subagent definition and have this section dispatch it.

## 4. Exit

Run the lane Sweep first, in every state below.

| State | You do |
|---|---|
| all tasks pass | go to 5 |
| a task is blocked | report the blocker with its `progress.md` lines, ask whether to re-split it or drop it, and name what stays unfinished, including every task that depends on it |
| iteration cap | report the remaining tasks, ask before raising the cap |

## 5. Review, push, verify

1. Run the five review agents from the global review rules over `git diff <merge-base>..HEAD`. Fix findings through a second, smaller loop with a new `tasks.json`, not by hand. Suggest the human run `mutant-review` when the loop added logic that tests guard.
2. Push only when `authorize:` allows it, or `SWARM_BOX=1` on a `swarm/` branch. Never push `main`. In any other case stop and show the human the commands.
3. After a push, watch CI with `gh run watch` on the pushed commit. A red run reopens the loop with the failure as a task.
4. When `authorize:` is `push+deploy` and `deploy-verify:` is set, run each command through the `runner` agent and report its output. With `none`, say deployment is unverified.

Done when each of these is stated: review findings resolved or listed, push state, CI result, deploy state as verified or unverified.

## Headless

Under `claude -p` nobody answers questions. Launch with `CLAUDE_CODE_FORK_SUBAGENT=0` so each subagent finishes before the next step, and with a permission mode that allows Agent and Bash. Where section 1 would ask, take the stated default, record it in `goal.md`, and carry on. A missing goal ends the run with the question as the result. A blocked task is written to `progress.md` and the run ends. Rerun the same command to resume.
