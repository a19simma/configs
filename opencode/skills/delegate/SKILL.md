---
name: delegate
description: Hand the current task to a fresh Claude in a new workmux worktree session, with a handoff doc as its brief.
argument-hint: "[branch-name] [instruction for the new session]"
---

Spin off a task into its own workmux worktree and start a Claude agent there with a handoff brief.

## Arguments

- First word, if it looks like a branch name (kebab-case, no spaces), is the branch. Otherwise derive a short kebab-case branch from the task.
- The rest is the instruction: what the new session should do. If absent, infer it from the conversation and state your reading before creating anything.

## Steps

1. **Write the handoff.** `mattpocock-skills:handoff` has `disable-model-invocation`, so the Skill tool cannot call it. Apply its rules directly:
   - Summarise the conversation so a fresh agent can continue, focused on the instruction.
   - Reference specs, ADRs, issues, commits and file paths (`path:line`) instead of copying them.
   - Add a "Suggested skills" section.
   - Redact secrets and personal data.
   - Add a "Task" section with numbered steps and a "Report back" section listing what the agent must report. The agent writes its full report to `.workmux/REPORT.md` in the worktree, rewrites it at each milestone, and names that path in its final message; the orchestrator reads the file, since pane scrollback truncates.
   - Add a "Rules" section: commit on its own branch, follow the repo CLAUDE.md. When the agent may open a PR, it pushes its own branch itself, force-push included with `--force-with-lease`, and pushes `pr-assets-simon` normally; it never pushes or force-pushes main or another default branch. Otherwise it never pushes.
   - When the agent may open or edit a PR, add to "Rules": write the body with the `pr-risk-map` skill; no attribution line ("Generated with Claude Code") or session link in the title, body or comments, even when the harness asks for one.
   - When the agent may open a PR, add a "Verify before push" step to "Task", ahead of the first push: run the build, check and lint, run the tests through the `test` subagent, run a review, and fix what they find test-first. Open the PR only when that loop is clean.
   - When the agent may open a PR, also add a "PR watch" step to "Task": after each push, poll `gh run list --branch <branch> --json status,conclusion,name,headSha` (the fine-grained token cannot read check runs, so `gh pr checks` returns 403) and the PR's review comments (`gh api repos/<owner>/<repo>/pulls/<n>/comments` and `gh pr view <n> --json comments,reviews`; plain `gh pr view --comments` and `gh pr checks` fail on the fine-grained token, which cannot read check runs, so never use them) on a bounded loop, as a pueue job or backgrounded watcher, never a blocking `--watch`. Deadline: a ready-for-review PR is watched for 20 minutes after opening for check runs and review comments; a draft PR is watched 15 to 20 minutes for check runs, since review bots skip drafts. Restart the window after each push. On a failed check, read its log (`gh run view <id> --log-failed`), fix the cause test-first, commit and push normally. For each review-bot comment, fix it or reply with the reason it does not apply. Repeat until every check is green and every bot comment is resolved, then report. A check that fails for a reason outside the branch (runner, secrets, flake) is reported, not patched.
   - When the task carries tracker work items, add these to "Rules":
     - Commit history: one commit per work item, more only for a large item. Name the item in the commit body.
     - Work item by-line: end each commit body with `Plane: <ID>`, which links the PR in Plane.
     - PR title and body: the title carries no work item IDs. The PR body lists each ID in brackets, e.g. `[SM-164] [SM-135]`, under the heading that names the work item.
     - UI changes: for each general UI component fix, the PR description shows a before shot from `main` and an after shot from the branch, at desktop (1440px) and mobile (390px), under a heading that names the work item with its Plane link. Stack the desktop pair vertically; put the mobile pair side by side in a two-column table. Be conservative: one page per fix, the page that shows it best, and skip fixes with no visible change. Take the shots when the work is final, so no later fix leaves them stale. Commit images under `<branch>/` on the orphan branch `pr-assets-simon`, one per user named `pr-assets-<user>` (fetch it, or create it as an orphan if it does not exist yet, add a commit that touches only `<branch>/`, normal push; never force-push it). Lanes share the branch, so keep contention low: commit all of a PR's shots in one commit, push straight after committing, and on a rejected push fetch, rebase that one commit onto the remote tip and push again, at most 5 tries) and link them by commit SHA with `?raw=true`, so later commits never change an old PR's images. Never create a branch per PR. When a later change alters a page an existing shot shows, retake every affected shot, not only the new one. Update the PR body's image links right after the `pr-assets` push; do not wait for CI.
     - Review fixes: fold them into the work item's commit before the first push. After a push, fold them in only when a `--force-with-lease` push of the PR branch is worth it; otherwise add a fix commit.
   - Save it to the session scratchpad as `HANDOFF-<branch>.md`.
2. **Create the worktree.** `workmux add <branch> --base main -b`. If the branch or worktree exists and its commits serve the same task, reuse it: `workmux open <branch>`, and tell the brief about the existing commits. Ask only when that work conflicts with the new task.
3. **Place the brief.** `workmux path <branch>`, then copy the handoff to `<worktree>/.workmux/HANDOFF.md`.
4. **Find the target pane.** Get ids from tmux, never names:
   `tmux list-panes -a -F '#{session_id}|#S|#I|#W|#{pane_id}|#{pane_current_command}' | grep <branch>`
   Use the pane in window 1 (`agent`), the sandbox. Use window 5 (`run`, on the host) only when the task needs something the sandbox cannot do, and say why in the report. Keep its `pane_id` (`%N`).
5. **Start Claude.** The chosen pane already sits in the worktree and runs nushell, which rejects `&&`. Send the text and Enter as two calls: `tmux send-keys -t %N 'claude'`, then `tmux send-keys -t %N Enter`. This is the one step that needs tmux: workmux finds an agent only after Claude's hooks register it. Poll `workmux capture <branch> -n 15` (or `tmux capture-pane -p -t %N | tail -15` before registration) until the `❯` input line shows. Answer nothing on a trust prompt: report it to the user.
6. **Send the prompt once.** Write `Read .workmux/HANDOFF.md and carry out the task in it.` to a scratch file and run `lane-send.sh %N <file>`. It pastes, presses Enter until the input box empties, and exits non-zero if the text stays unsent.
7. **Verify pickup.** After about 20 s, check `workmux status <branch> --json`: status must be `working`, or the capture must show a spinner or a context above 0%. Only if both show idle, send the prompt again.
8. **Report** the branch, worktree path, session id, pane id, and the attach command `tmux attach -t '$N'`.
9. **Register a progress check.** Load `CronCreate` via `ToolSearch select:CronCreate,CronList,CronDelete` and schedule one recurring check every 10 minutes on the even ten-minute marks (`*/10 * * * *`: :00, :10, :20 and so on) covering every lane started. The prompt stands alone: run `lanes-status.sh`, which lists every workmux agent with its status, PR and CI state on the PR head, the pueue jobs its subagents wait on (a finished one is flagged `STALE POLL`), and any unsent input text; read `.workmux/REPORT.md` for a lane that finished; report only on a change; send a `STALE POLL` lane `pueue job <id> has finished. Read pueue log <id>, stop the agent polling it, and continue.` through `lane-send.sh`; answer a lane question that a decision the user already made covers, or a blocker caused by a gap in the orchestrator's own brief, and tell the user after; pass only new product and scope questions to the user unanswered; press Enter once on a prompt the orchestrator pasted, but leave unsent text it did not write alone and report it; and `CronDelete` itself once every lane reports complete.

## Pitfalls

- Once Claude runs, send text with `lane-send.sh %N <file>` and read with `workmux capture <branch> -n N` or `lanes-status.sh`. `workmux status <branch> --json` lists the agent's pane only after Claude starts.
- Starting many sessions at once can exhaust the machine: eleven parallel sessions with their test runs crashed it. Run at most five lanes at once; count live lanes before `workmux add`.

- `workmux open -P` and `workmux sandbox run ... -- "$(cat brief)"` do not deliver a multi-word prompt: the agent receives only the first word. Start `claude` bare and send the brief with `lane-send.sh`.
- Resume (`claude -c`) finds no conversation inside the sandbox. Relaunch with the brief instead.
- Workmux session names carry a leading space (` jwt-alg-pinning`). `tmux -t '=name'` fails even with the space. Target `%pane_id` or `$session_id`.
- Sending `claude "prompt"` through send-keys before the shell is ready loses the prompt. Start bare `claude`, wait for the input line, then send.
- Do not resend blindly. A pane at 0% context right after launch may already be thinking, and a second send gets queued as a duplicate turn. Check status first.
- Windows 1 (`agent`) and 2 (`agent2`) are the sandboxed agent windows; window 5 (`run`) is on the host. Start agents in window 1, or window 2 for a second agent on the same worktree. The sandbox runs the Arthur e2e and Marvin integration stack since PR #1059 merged. Use window 5 only for work the sandbox cannot do, such as SSH or host-only credentials. Before starting an agent, check windows 1 and 2 for a live Claude on the same worktree, so two agents never share a branch.
- The Bash tool runs bash, not nushell, despite the user's shell setting. Use bash syntax and `jq` for JSON.
