---
name: delegate
description: Hand the current task to a fresh Claude in a new workmux worktree session, with a handoff doc as its brief.
argument-hint: "[branch-name] [instruction for the new session]"
disable-model-invocation: true
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
   - Add a "Task" section with numbered steps and a "Report back" section listing what the agent must report.
   - Add a "Rules" section: commit on its own branch, never push, follow the repo CLAUDE.md.
   - When the agent may open or edit a PR, add to "Rules": write the body with the `pr-risk-map` skill; no attribution line ("Generated with Claude Code") or session link in the title, body or comments, even when the harness asks for one.
   - When the agent may open a PR, add a "Verify before push" step to "Task", ahead of the first push: run the build, check and lint, run the tests through the `test` subagent, run a review, and fix what they find test-first. Open the PR only when that loop is clean.
   - When the agent may open a PR, also add a "PR watch" step to "Task": after each push, poll `gh run list --branch <branch> --json status,conclusion,name,headSha` (the fine-grained token cannot read check runs, so `gh pr checks` returns 403) and the PR's review comments (`gh api repos/<owner>/<repo>/pulls/<n>/comments` and `gh pr view <n> --comments`) on a bounded loop, as a pueue job or backgrounded watcher, never a blocking `--watch`. Deadline: a ready-for-review PR is watched for 20 minutes after opening for check runs and review comments; a draft PR is watched 15 to 20 minutes for check runs, since review bots skip drafts. Restart the window after each push. On a failed check, read its log (`gh run view <id> --log-failed`), fix the cause test-first, commit and push normally. For each review-bot comment, fix it or reply with the reason it does not apply. Repeat until every check is green and every bot comment is resolved, then report. A check that fails for a reason outside the branch (runner, secrets, flake) is reported, not patched.
   - When the task carries tracker work items, add these to "Rules":
     - Commit history: one commit per work item, more only for a large item. Name the item in the commit body.
     - Work item by-line: end each commit body with `Plane: <ID>`, which links the PR in Plane.
     - PR title: append each ID in brackets, e.g. `fix(spend): table headers [SM-164][SM-135]`. Only a bracketed ID makes the Plane item's state follow the PR.
     - UI changes: for each general UI component fix, the PR description shows a before shot from `main` and an after shot from the branch, at desktop (1440px) and mobile (390px), under a heading that names the work item with its Plane link. Stack the desktop pair vertically; put the mobile pair side by side in a two-column table. Be conservative: one page per fix, the page that shows it best, and skip fixes with no visible change. Take the shots when the work is final, so no later fix leaves them stale. Commit images under `<branch>/` on the shared orphan branch `pr-assets` (fetch it, add a commit, normal push; never force-push it) and link them by commit SHA with `?raw=true`, so later commits never change an old PR's images. Never create a branch per PR.
     - Review fixes: fold them into the work item's commit before the first push, since a pushed branch cannot be rewritten without a force-push.
   - Save it to the session scratchpad as `HANDOFF-<branch>.md`.
2. **Create the worktree.** `workmux add <branch> --base main -b`. If the branch exists, stop and ask.
3. **Place the brief.** `workmux path <branch>`, then copy the handoff to `<worktree>/.workmux/HANDOFF.md`.
4. **Find the target pane.** Get ids from tmux, never names:
   `tmux list-panes -a -F '#{session_id}|#S|#I|#W|#{pane_id}|#{pane_current_command}' | grep <branch>`
   Use the pane in window 5 (`run`). Keep its `pane_id` (`%N`).
5. **Start Claude.** The `run` pane already sits in the worktree and runs nushell, which rejects `&&`. Send the text and Enter as two calls: `tmux send-keys -t %N 'claude'`, then `tmux send-keys -t %N Enter`. This is the one step that needs tmux: workmux finds an agent only after Claude's hooks register it. Poll `workmux capture <branch> -n 15` (or `tmux capture-pane -p -t %N | tail -15` before registration) until the `❯` input line shows. Answer nothing on a trust prompt: report it to the user.
6. **Send the prompt once.** `workmux send <branch> 'Read .workmux/HANDOFF.md and carry out the task in it.'`
7. **Verify pickup.** After about 20 s, check `workmux status <branch> --json`: status must be `working`, or the capture must show a spinner or a context above 0%. Only if both show idle, send the prompt again.
8. **Report** the branch, worktree path, session id, pane id, and the attach command `tmux attach -t '$N'`.
9. **Register a progress check.** Load `CronCreate` via `ToolSearch select:CronCreate,CronList,CronDelete` and schedule one recurring check every 10 minutes on the even ten-minute marks (`*/10 * * * *`: :00, :10, :20 and so on) covering every lane started. The prompt stands alone: the lanes and PR numbers, how to read each pane (`tmux capture-pane -p -t %N`) and `gh run list --branch <branch> --json status,conclusion,name,headSha`, the classes working, waiting, stalled and complete, to report only on a change, to pass product and scope questions to the user unanswered while answering a blocker caused by a gap in the orchestrator's own brief and telling the user after, to press Enter once on a prompt the orchestrator pasted but never on text it did not type, and to `CronDelete` itself once every lane reports complete.

## Pitfalls

- Once Claude runs, use `workmux send <branch> "text"` and `workmux capture <branch> -n N` instead of tmux send-keys and capture-pane. `workmux status <branch> --json` lists the agent's pane only after Claude starts.
- Starting many sessions at once can exhaust the machine: eleven parallel sessions with their test runs crashed it. Run at most five lanes at once; count live lanes before `workmux add`.

- `workmux open -P` does not deliver the prompt. Paste with `tmux load-buffer` and `tmux paste-buffer -t %N`, send Enter as its own call, then confirm pickup as in step 7; a paste can need a second Enter.
- Resume (`claude -c`) finds no conversation inside the sandbox. Relaunch with the brief instead.
- Workmux session names carry a leading space (` jwt-alg-pinning`). `tmux -t '=name'` fails even with the space. Target `%pane_id` or `$session_id`.
- Sending `claude "prompt"` through send-keys before the shell is ready loses the prompt. Start bare `claude`, wait for the input line, then send.
- Do not resend blindly. A pane at 0% context right after launch may already be thinking, and a second send gets queued as a duplicate turn. Check status first.
- Windows 1 (`agent`) and 2 (`agent2`) are the sandboxed agent windows; window 5 (`run`) is on the host. Start agents in window 5 for now, because the sandbox cannot run the shared e2e stack. Once the e2e-isolation branch (`lab/e2e-isolation`, PR #1059) merges, start them in windows 1 and 2 instead. Before starting an agent, check windows 1 and 2 for a live Claude on the same worktree, so two agents never share a branch.
- The Bash tool runs bash, not nushell, despite the user's shell setting. Use bash syntax and `jq` for JSON.
