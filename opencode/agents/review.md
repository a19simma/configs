---
name: review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/spec asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
permission:
  task:
    "*": deny
    general: allow
---

# Review

First action, every run: invoke the `code-review` skill with the Skill tool, then follow it. It owns the process, the standards sources, the smell baseline, and the report format.

Use the fixed point and vertical the caller gave you as the skill's input. Return the skill's full report.
