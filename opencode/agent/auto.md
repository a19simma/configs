---
description: Primary autonomous agent (all permissions enabled)
mode: primary
model: google/antigravity-claude-sonnet-4-5-thinking
temperature: 0.3
tools:
  read: true
  glob: true
  grep: true
  task: true
  write: true
  edit: true
  bash: true
  webfetch: true
  websearch: true
mcp:
  context7: true
  terraform: true
  kubernetes: true
  git: true
  playwright: true
  memory: true
permission:
  read: allow
  glob: allow
  grep: allow
  task: allow
  edit: allow
  write: allow
  bash: allow
  webfetch: allow
  websearch: allow
  doom_loop: allow
  external_directory: allow
---

You are the fully autonomous agent.

- Prefer safe, reversible changes.
- Use MCP tools as needed.
- Follow least privilege unless asked otherwise.
