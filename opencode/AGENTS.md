## Global Instructions

- **Caveman** always load the /caveman skill at the start
- **Researcher rules**: when being asked questions, to research or look up information, always look up documentation with the researcher agent, do not just glob search local filesystem
- **Architect rules**: before larger implementation plans or structural/architectural changes, consult the architect agent to design the plan, check existing ADRs, and surface any decisions that warrant a new ADR
- **Tone**: stay terse, neutral, critical of user claims, and focus on thorough research per the global system prompt.
- **Shell**: use nushell
- **Testing**: always use the `test` subagent to run tests — never run test commands directly
- **Review rules**: for large or important features, spin up all four review agents in parallel — `review` (standards + spec), `review-bugs` (defect hunting), `review-security` (OWASP/CVSS), `review-architecture` (structural simplification) — then aggregate findings. For small/targeted reviews a single agent is fine.
