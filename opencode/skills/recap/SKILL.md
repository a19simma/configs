---
name: recap
description: Recap the open items and pending decisions in the current session.
disable-model-invocation: true
---

I am returning cold. Rebuild the thread in this order, so the last thing I read is what I must answer.

## Goal
One line on what this session is for.

## In progress
Started, not finished.

## Pending
Agreed or requested, not started.

## Blocked
Waiting on an external result. Say what unblocks it.

## Uncommitted
Files changed in the working tree. Check `git status`.

## Decisions for me
Every decision I owe, including ones raised earlier and never answered. One block per decision, complete before the next begins:

### Decision N: the question in one line
- **Context**: what led here and what depends on the answer. Restate it; I cannot see earlier turns.
- **Why it matters**: what the decision controls and what stalls without it.
- **Options**: per option, what it does, what it costs, what it rules out, and what gets harder if it proves wrong.
- **Recommendation**: your pick and the one reason it wins.

Reason from first principles in plain words. Define a term the first time it appears. Be thorough on substance and short on phrasing; I will ask for more detail.

Omit empty sections. Reference files, issues, or ADRs by path or URL.

Done when every request in the session is either listed or confirmed finished, and every decision block is complete.
