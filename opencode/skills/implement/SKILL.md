---
name: implement
description: "Implement a piece of work based on a spec or a set of local tickets under .scratch/."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Tickets are local markdown files under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, written by
`/to-tickets`. There is no external issue tracker.

## Picking the work

If the user named a ticket, take that one. Otherwise read every ticket in the feature's `issues/`
directory and work the **frontier**: any ticket whose "Blocked by" entries are all `Status: done`.
If several are ready, list them and ask which to take. Never start a ticket whose blockers are open.

Set the ticket's `**Status:**` to `in-progress` before you start.

## Building

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly and single test files regularly. Run the full suite once at the end,
through the `test` subagent.

Tick each acceptance criterion's checkbox in the ticket file as it starts passing. A criterion is
ticked only when a test or a demonstrable behaviour backs it, never on the strength of the code
having been written.

## Finishing

Once done, use /code-review to review the work.

Set the ticket's `**Status:**` to `done`.

Leave all changes in the working tree. Do not stage, commit, amend, branch or tag: report what
would be committed and let the user run git themselves.
