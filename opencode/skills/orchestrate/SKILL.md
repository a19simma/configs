---
name: orchestrate
description: List every workmux agent session with a status of running, waiting, stalled, complete, merged, idle or gone.
argument-hint: "[worktree-name ...]"
disable-model-invocation: true
---

Show the state of all workmux agents in one table. With arguments, limit it to those worktrees.

## Steps

1. Read state: `lanes-status.sh` prints one line per agent: pane, project/worktree, status and minutes since change, PR and CI on its head, pueue jobs its subagents wait on (`STALE POLL` when finished), and unsent input text. For detail, `workmux status --all --json --git`. Use `jq`; the Bash tool runs bash.
2. List live panes: `tmux list-panes -a -F '#{session_id}|#S|#I|#W|#{pane_id}|#{pane_current_command}'`.
3. For each worktree on a branch other than the base, check whether it landed: `gh pr list --repo <owner/repo> --head <branch> --state merged --json number,mergedAt` run from `project_path`. If no PR exists, fall back to `git -C <project_path> merge-base --is-ancestor <branch> origin/main` after `git fetch origin main`, and count it only when the branch has commits of its own.
4. For each agent with status `working`, capture it twice, 15 s apart: `workmux capture <name> -n 20`. Compare the spinner line, token count and elapsed timer. Fall back to `tmux capture-pane -p -t %N | tail -20` only for a pane workmux does not track.
5. Classify each agent:

| Status | Rule |
|---|---|
| running | `working`, and the capture changed between the two reads |
| waiting | a permission, trust or question prompt shows in the pane, or status is `waiting` |
| stalled | `working`, but the capture did not change and `elapsed_secs` exceeds 600 |
| complete | `done`, and the last capture holds a final report or a commit |
| idle | `done` or `-` with an empty prompt and no report: the agent never started or lost its prompt |
| merged | the branch has a merged PR, or its commits are in `origin/main`. Wins over complete and idle |
| gone | a state entry exists but its `pane_id` is not in the live pane list |

6. Print one table sorted by status (waiting, stalled, running, idle, complete, merged, gone): worktree, project, session id, pane id, status, last activity (from `elapsed_secs`, human readable), unmerged commits from `--git`, and a one-line summary from the pane's last lines.
7. Under the table, list the actions that need the user: waiting prompts to answer, stalled agents to inspect, complete worktrees ready for `workmux merge`, and merged worktrees ready for `workmux remove`. Do not merge, remove, kill or send to any agent unless the user asks.

## Resurrect

When the user asks to bring back `gone` worktrees (after a crash or reboot), touch only the ones named:

1. `workmux open <name>` from the project path recreates the tmux session.
2. Find the `run` pane (window 5) with `tmux list-panes -a`. It runs nushell. Send `claude --continue` and Enter as two separate `tmux send-keys` calls; this resumes the last conversation in that worktree.
3. Wait for the `❯` input line, then `lane-send.sh %N <file>` with a note that the session was restored, any auth or environment facts the agent needs, and the instruction to re-check git status and continue its handoff.
4. Verify with `workmux status <name> --json` and `workmux capture`.

## Restart

When a sandboxed lane needs a fresh container (an allowlist change, a broken session):

1. Write a resume brief to `.workmux/PROMPT-resume.md`: why it restarted, the original brief's path, the report so far, and the next task.
2. In the agent pane, clear the input with `C-u`, send `/exit` and Enter, and wait for the shell prompt.
3. Start the same `workmux sandbox run <worktree> -- <agent command>` the pane ran before (read it with `ps --ppid <pane_pid>`), with no prompt argument.
4. Wait for the `❯` input line, then `lane-send.sh %N .workmux/PROMPT-resume.md`.
5. Done when `lanes-status.sh` shows the lane `working` and its capture shows work on the resume brief.

## Pitfalls

- Always arm a watcher on every busy agent after starting, resuming or sending it work: a backgrounded shell loop or a cron heartbeat that wakes you when the agent stops. Never promise to check later without one, since you only act when woken.
- To wait on an agent, watch the workmux session (`workmux status <name> --json` for `.agents[0].status`, plus `workmux capture`), never an external service such as the PR or CI. Treat `waiting` as done, and `done` as done only when the capture lacks "Waiting for … background agent". Give every watch a deadline.

- Use `workmux send` and `workmux capture` for agents that run. tmux is needed only to start `claude` in a shell pane, before Claude's hooks register the agent with workmux. Until then `workmux status` shows no agent for that worktree.
- An agent stuck on a slow command (e.g. `gh` waiting on a locked keyring) keeps `working`. Probe the command yourself with `timeout`, then interrupt the agent and send it the result.

- Session names carry a leading space. Target panes by `%pane_id`, never by `=session` name.
- `elapsed_secs` counts time since the last status change, not runtime. A long `done` time is normal.
- Squash and rebase merges leave `has_unmerged_commits` true locally. Trust the PR state over `--git` for merged.
- `-` status means workmux has no hook state for that pane. Check the capture before calling it idle.
