# Before/After Examples

Local expansion of the upstream file. Read during the revision pass.

Each pair shows one dominant tell. Real slop stacks several; fix them in the order
structure → lexicon → concreteness → rhythm.

---

## Prose and essays

### 1. Throat-clearing + binary contrast

**Before:**
> "Here's the thing: building products is hard. Not because the technology is complex. Because people are complex. Let that sink in."

**After:**
> "Building products is hard. Technology is manageable. People aren't."

Removed opener, binary contrast, emphasis crutch.

### 2. Filler + unnecessary reassurance

**Before:**
> "It turns out that most teams struggle with alignment. The uncomfortable truth is that nobody wants to admit they're confused. And that's okay."

**After:**
> "Teams struggle with alignment. Nobody admits confusion."

Cut hedging, throat-clearing, permission-granting ending.

### 3. Business jargon stack

**Before:**
> "In today's fast-paced landscape, we need to lean into discomfort and navigate uncertainty with clarity. This matters because your competition isn't waiting."

**After:**
> "Move faster. Your competition is."

### 4. Dramatic fragmentation

**Before:**
> "Speed. Quality. Cost. You can only pick two. That's it. That's the tradeoff."

**After:**
> "You get two of speed, quality, and cost."

Single sentence, no performative emphasis, no em dash.

### 5. Rhetorical setup

**Before:**
> "What if I told you that the best teams don't optimize for productivity? Here's what I mean: they optimize for learning. Think about it."

**After:**
> "The best teams optimize for learning, not productivity."

### 6. Rule of three

**Before:**
> "Good infrastructure is fast, reliable, and observable."

**After:**
> "Good infrastructure is reliable and easy to observe when it breaks."

Two items, and the second one earns its place.

### 7. False agency

**Before:**
> "Over the following quarter the culture shifted and quality became a shared concern."

**After:**
> "That quarter, two staff engineers started rejecting PRs without tests. Everyone else followed."

### 8. Narrator-from-a-distance

**Before:**
> "Nobody designs a migration this way. It happens gradually, through a thousand small decisions."

**After:**
> "You don't plan a migration like this. You defer one schema change, then another, and eighteen months later you own both code paths."

### 9. Vague declarative

**Before:**
> "The implications for reliability are significant."

**After:**
> "A single node failure took down checkout for 40 minutes."

### 10. Copulative avoidance

**Before:**
> "Redis serves as the caching layer and represents a critical dependency for session handling."

**After:**
> "Redis caches sessions. If it goes down, nobody can log in."

### 11. Summary paragraph

**Before:**
> "In conclusion, migrating to Cilium gave us better observability, simpler policy, and lower overhead. Overall, the effort was worth it."

**After:**
> (delete entirely; the piece already said this)

### 12. Meta-commentary

**Before:**
> "In this section, we'll walk through how the scheduler works. Let's dive in."

**After:**
> "The scheduler runs every 30 seconds."

### 13. Negative listing

**Before:**
> "This isn't a rewrite. It isn't a refactor. It's a rethink of how we model tenancy."

**After:**
> "We remodelled tenancy. The old code stays."

### 14. Em-dash spam + hedging

**Before:**
> "The result — arguably the most important part — is that latency dropped quite substantially."

**After:**
> "Latency dropped from 400ms to 90ms."

### 15. Superlative with no evidence

**Before:**
> "This is a game-changing, unprecedented improvement to developer experience."

**After:**
> "Local builds went from six minutes to fifty seconds."

---

## Technical docs and READMEs

### 16. Promotional README opener

**Before:**
> "Vogon is a powerful, flexible, and lightweight framework that empowers teams to seamlessly orchestrate their workflows at scale."

**After:**
> "Vogon runs scheduled workflows on Kubernetes. It handles retries and per-step timeouts."

### 17. Bulleted term-dash-explanation slop

**Before:**
> - **Fast** — Built for speed.
> - **Reliable** — Won't let you down.
> - **Scalable** — Grows with your needs.

**After:**
> "Handles about 5k jobs/minute on three replicas. Jobs survive pod restarts."

### 18. Instruction wrapped in prose

**Before:**
> "In order to get started, you'll first want to make sure that you have the CLI installed, after which you can proceed to authenticate."

**After:**
> "Install the CLI, then log in:
> ```
> mise install
> az login
> ```"

### 19. Hedged doc statement

**Before:**
> "This should generally work in most cases, though results may vary depending on your setup."

**After:**
> "Works on Linux and macOS. Windows needs WSL2."

---

## Commits, PRs, changelogs

### 20. Commit message slop

**Before:**
> "feat: comprehensively enhance the robust error handling capabilities of the authentication middleware"

**After:**
> "fix(auth): return 401 instead of 500 on expired token"

### 21. PR description slop

**Before:**
> "This PR introduces a series of improvements designed to enhance the overall reliability and maintainability of the ingestion pipeline. Key changes include refactoring, better error handling, and improved test coverage."

**After:**
> "Ingestion dropped events when Kafka rebalanced mid-batch. Now the consumer commits offsets after the batch writes, not before. Added a test that kills the broker mid-batch."

### 22. Changelog slop

**Before:**
> "Various improvements and bug fixes to enhance your experience."

**After:**
> "Fixed a crash when a dashboard had more than 50 panels. Search now matches on tags."

---

## Email and messages

### 23. Email throat-clearing

**Before:**
> "I hope this email finds you well. I wanted to reach out to touch base regarding the timeline for the migration. Please don't hesitate to let me know if you have any questions."

**After:**
> "Can we move the migration to the 14th? The DNS cutover needs a maintenance window and the 7th collides with the release."

### 24. Status update slop

**Before:**
> "Making great progress! The team has been working hard and we're excited about where things are heading."

**After:**
> "Three of five services migrated. Bifrost is blocked on the cert-manager upgrade, which lands Thursday."

### 25. Bad news dressed up

**Before:**
> "While we've made significant strides, we've encountered some unexpected challenges that have impacted our ability to deliver on the original timeline."

**After:**
> "We'll miss the date by two weeks. The Cilium upgrade broke egress policy and we're rewriting 40 policies by hand."

---

## Rhythm repair

### 26. Metronomic sentences

**Before:**
> "The service reads from Kafka. The parser validates the payload. The writer persists to Postgres. The metrics update after each batch."

**After:**
> "The service reads from Kafka and validates each payload before it writes to Postgres. Metrics update per batch."

Four same-length sentences became one long and one short.

### 27. Staccato drama

**Before:**
> "It worked. And it kept working. And nobody touched it for two years."

**After:**
> "It ran untouched for two years."

### 28. Every paragraph ending punchily

**Before:**
> "...and that's when we knew.
>
> ...and that changed everything.
>
> ...and it never happened again."

**After:**
> Let two of these three paragraphs end on an ordinary clause: a date, a number, a next step.
