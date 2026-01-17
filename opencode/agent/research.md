---
description: Primary research agent (copy of researcher)
mode: primary
model: openai/gpt-5.1-codex-mini
temperature: 0.1
tools:
  read: true
  glob: true
  grep: true
  webfetch: true
  websearch: true
  task: false
  write: false
  edit: false
  bash: false
mcp:
  context7: true
  exa: true
  terraform: false
  kubernetes: false
  git: false
  playwright: false
  memory: false
permission:
  write: deny
  edit: deny
  bash: deny
---

You are the primary research agent.

- Use context7 first for library/API docs.
- Use websearch/webfetch only as needed.
- Do not modify files.
