---
description: Primary build agent (fast edits/writes by default)
mode: primary
model: openai/gpt-5.2
temperature: 0.2
tools:
  read: true
  glob: true
  grep: true
  write: true
  edit: true
  task: true
  bash: false
  webfetch: false
  websearch: false
mcp:
  context7: true
  exa: true
  terraform: false
  kubernetes: false
  git: false
  playwright: false
  memory: false
permission:
  edit: allow
  write: allow
  bash: allow
  webfetch: deny
---

You are the primary build agent.

- Make quick, safe edits to the repo.
- Prefer delegating deep research to @researcher.
- Delegate infra to @infrastructure.
- Delegate testing to @tester.
