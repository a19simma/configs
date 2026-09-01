# Proposal: replace autocompact with handoff + clear

Status: **not implemented.** Written 2026-08-30, parked until the slow compact is annoying enough to be worth the risk.

## Problem

`/compact` takes 2–3 minutes. `/handoff` does the same job in 20–30 seconds.

The cost is output tokens, not input. `/compact` generates an exhaustive structured summary — numbered sections, every user message quoted verbatim, exact code snippets, a file-by-file inventory — roughly 4–5k output tokens on Opus. The 140k prefill is largely cached and fast; the generation is the wait. A handoff writes ~600 tokens and finishes in a normal turn.

So the fix is not a faster compactor. It is not invoking that prompt.

## What exists off the shelf

Nothing that does this. Checked:

- [magic-compact](https://github.com/aerovato/magic-compact) — per-turn summarisation with pruned tool output. Development paused. Still a summariser.
- [compact-plus](https://github.com/u-ichi/compact-plus) — saves and restores working state around compaction. Fixes lost context, not latency.

## Design

Two hooks, confirmed against the [hooks reference](https://code.claude.com/docs/en/hooks):

- `PreCompact` receives `trigger: "manual" | "auto"` and **exit code 2 blocks compaction**.
- `SessionStart` receives `how: "startup" | "resume" | "clear" | "compact" | "fork"` and can return `additionalContext` for injection.

Flow:

1. Autocompact fires. `PreCompact` (matcher `auto`) exits 2, killing the slow summariser, and tells the model via stderr to write the handoff now.
2. Model writes the handoff to a fixed path. ~30s.
3. User types `/clear`.
4. `SessionStart` sees `how == "clear"`, reads the handoff file, injects it as `additionalContext`.

### The gap

**No hook can execute `/clear`.** Hooks return decisions and context; they do not drive the TUI. Step 3 stays a keystroke. Everything else is automatic.

If that keystroke is unacceptable, the alternative is a wrapper process driving the TUI, which is a much larger and more fragile thing. Not proposed here.

### Settings

```json
"PreCompact": [{
  "matcher": "auto",
  "hooks": [{ "type": "command", "command": "~/.claude/hooks/handoff-instead.sh" }]
}],
"SessionStart": [{
  "hooks": [{ "type": "command", "command": "~/.claude/hooks/handoff-restore.sh" }]
}]
```

### `handoff-instead.sh`

```bash
echo "Autocompact blocked. Write the handoff to $HANDOFF now, then tell the user to /clear." >&2
exit 2
```

### `handoff-restore.sh`

```bash
# gate on how == "clear" and on the file being fresh
jq -n --arg c "$(cat "$HANDOFF")" '{additionalContext: $c}'
```

## Risks — read before implementing

**Blocking the safety net can strand the session.** Autocompact exists so a session degrades instead of failing. If the handoff never gets written and the user does not clear, every subsequent autocompact attempt hits the same block and the session walks into a hard context error with no summary and no recovery.

Mitigation: block once, then let the next attempt through. A marker file keyed on session id, removed on `SessionStart`, does it. **The blocking hook must not go live without this.**

**Stale handoffs are worse than none.** `SessionStart` fires on `startup` and `resume` too. Gate on `how == "clear"` and on the file's mtime being within a few minutes, or a fresh session gets last week's context injected as fact.

**No hook fires when the threshold is reached**, only once compaction has already been decided. So there is no way to write the handoff pre-emptively in the background; the block is the only trigger point.

## Two problems in `handoff/SKILL.md`

The skill exists at `opencode/skills/handoff/SKILL.md`. Reading it surfaces two mismatches with the design above, both fixable, neither optional.

**1. The output path is not fixed.** The skill says to save "to the temporary directory of the user's OS", with no filename given. `handoff-restore.sh` cannot read a file whose name it cannot predict. Options:

- Have the skill write to a fixed path (`$TMPDIR/claude-handoff-$CLAUDE_SESSION_ID.md`), which the hook can then reconstruct from `session_id` in its JSON input. Cleanest.
- Or have the restore hook glob the temp directory for the newest matching file, which makes the staleness gate load-bearing rather than defensive.

The first option is a one-line edit to the skill and is what the rest of this document assumes.

**2. The skill is `disable-model-invocation: true`.** It is user-invoked only, so a `PreCompact` hook cannot cause `/handoff` to fire. The model can still be told to read `opencode/skills/handoff/SKILL.md` by path and follow it — the same route the `*-review` and `*-setup` skills use — but the stderr message must say that explicitly. "Write the handoff" alone will produce an ad-hoc summary that ignores the skill's rules on redaction, artifact references, and the suggested-skills section.

Neither problem blocks the design. Both silently break it if unaddressed.

## Cheaper things to try first

- Raise `autoCompactWindow` (currently 140000; `--autocompact` accepts up to 1M) so autocompact rarely fires at all.
- `/handoff` then `/clear` manually. Same 30s path, zero new machinery, no safety net removed. **This is the whole proposal minus the automation, and it is available today.**
- Push fan-out reads into subagents so their tool output never enters the main context. Biggest single win against context growth, no configuration.
