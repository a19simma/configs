---
name: rush-delegate
description: Hand one urgent ticket to a workmux lane with a shortened test and review loop, to ship a fast release. Use for a high-priority fix where speed beats coverage.
argument-hint: "<work item id> [branch-name]"
---

Like `delegate`, with the verify loop cut down. Build the brief by the `delegate` skill's rules, then apply the changes below.

## Steps

1. **Read the ticket.** Fetch the work item and its comments (`workitem retrieve_by_identifier`, then `workitem_comment list`). A 403 on comments means the item id was wrong: use the `id` from the retrieve. Explain the ticket to the user in plain words. Stop and ask when a comment says blocked or when the ticket forks a product decision.
2. **Reuse a live lane.** `workmux list` and `lanes-status.sh`. When a worktree already holds commits for the ticket, brief that lane through `lane-send.sh %N <file>`, never a second worktree. Otherwise create one as `delegate` does.
3. **Write the rush brief** to the scratchpad as `HANDOFF-<branch>.md`, copy it to `<worktree>/.workmux/HANDOFF.md`. Paste the ticket text in full; sandbox lanes have no Plane access. Replace the `delegate` Verify loop with this one:
   - Write one red test for the reported symptom, then fix. No mutation sweep, no full-suite run.
   - Run the build, lint and only the spec files the change touches. Let CI run everything else.
   - One review pass: a single `review-bugs` agent on the diff. Skip the other four.
   - UI changes keep the `delegate` screenshot rule: before from `main`, after from the branch, desktop 1440px stacked and mobile 390px side by side, committed under `<branch>/` on `pr-assets-simon`, linked by SHA with `?raw=true`. One page per fix.
   - Squash the branch to one commit per work item before the push, with `Plane: <ID>` in the body. After a push, fold in only with `--force-with-lease`.
   - Open the PR ready for review the moment those pass. Title and body follow `pr-risk-map`, no attribution line, no session link.
   - PR watch: poll `gh run list --branch <b>` and `gh pr view <n> --json comments,reviews` (never `--comments` or `gh pr checks`: the fine-grained token cannot read check runs) for up to 20 minutes. Fix a red check on the branch. Report a red check from outside the branch.
   - The PR body lists what was skipped under a `Skipped for speed` heading: the checks not run locally, the review agents not run, the unverified paths.
4. **Mark the priority.** Tell the lane it goes first and that nothing outside the ticket's scope belongs in the diff. A question the ticket does not answer goes back to the orchestrator, not into a guess.
5. **Verify pickup, report, and register the cron check** exactly as `delegate` steps 7 to 9 say.

## Pitfalls

- Speed cuts the test and review loop. It never cuts security review of auth, money or access code: for those, keep `review-security` in the pass and say so in the brief.
- Never merge. The user merges and releases.
- Report the skipped checks to the user in the final message, not only in the PR.
