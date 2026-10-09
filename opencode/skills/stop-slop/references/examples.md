# Before/After Examples

Local expansion of the upstream file. Read during the check pass.

Each pair shows one dominant tell. Real slop stacks several. Fix them in the order structure,
lexicon, concreteness, rhythm.

Numbers and names in the After lines stand for facts the writer already has. In a real rewrite,
take them from the source or ask. Pairs marked (humanizer) come from blader/humanizer v3.1.0, MIT.

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

## Staging and inflation

### 29. Clipped contrast tail (humanizer)

**Before:**
> "The options come from the selected item, no guessing."

**After:**
> "The options come from the selected item without forcing the user to guess."

### 30. Repeated closer (humanizer)

**Before:**
> "Caching cuts repeat work.
>
> That is the real win.
>
> Retries hide brief outages.
>
> That is the real win."

**After:**
> "Caching cuts repeat work.
>
> Retries hide brief outages."

### 31. Deep-sounding saying (humanizer)

**Before:**
> "Symmetry is the language of trust. Efficiency becomes a trap when teams forget the human layer."

**After:**
> "Symmetric layouts often feel more predictable to users. Teams can over-optimize workflows and miss how people use them."

### 32. Arguing with no one (humanizer)

**Before:**
> "Session tokens are rotated every 24 hours. A tempting approach would be to rotate them by restarting the auth service on a cron job, but that would drop every active session. Rotation happens in place, and clients refresh transparently."

**After:**
> "Session tokens are rotated every 24 hours, in place, and clients refresh transparently."

### 33. -ing rider

**Before:**
> "The worker now retries failed writes, ensuring data integrity and reflecting our commitment to reliability."

**After:**
> "The worker now retries failed writes up to three times."

### 34. Vague connection, source silent

**Before:**
> "The outage was linked to the cert-manager upgrade."

**After:**
> "The outage started ten minutes after the cert-manager upgrade. The cause is not confirmed."

The source gave timing, not cause, so the After states the timing and no more.

### 35. Borrowed authority

**Before:**
> "Industry experts agree that Rust is the future of systems programming."

**After:**
> "The Linux kernel has accepted Rust code since 6.1."

Or cut the sentence if the piece has no source to name.

### 36. Stacked qualifiers (humanizer)

**Before:**
> "It could potentially possibly be argued that the policy might have some effect on outcomes."

**After:**
> "The policy may affect outcomes."

### 37. Inflated send-off

**Before:**
> "With v2 shipped, the future looks bright for the project. Exciting times lie ahead as we continue our journey."

**After:**
> (Cut the paragraph. End on the last concrete fact.)

## Leftovers and wrong reader

### 38. Chat residue

**Before:**
> "Great question! Here is a summary of the change. The cache now expires after ten minutes. I hope this helps! Let me know if you'd like more detail."

**After:**
> "The cache now expires after ten minutes."

### 39. Knowledge gap filled with a guess

**Before:**
> "Documentation for this flag is limited, but it likely controls the retry budget."

**After:**
> "The docs don't describe `--budget`."

### 40. Heading echo (humanizer)

**Before:**
> "## Performance
>
> Speed matters.
>
> When users hit a slow page, they leave."

**After:**
> "## Performance
>
> When users hit a slow page, they leave."

### 41. Code comment about history (humanizer)

**Before:**
> "This function was added to replace the previous approach of iterating through all items, which caused O(n²) performance."

**After:**
> "This function uses a hash map for O(1) lookups, avoiding the O(n²) cost of naive iteration."

### 42. Method narration (humanizer)

**Before:**
> "The figures below are drawn from each vendor's published pricing; anything we could not confirm is flagged rather than guessed."

**After:**
> "Prices are each vendor's published rate. Two vendors publish nothing; call them."

### 43. Reply that rebuilds the context (humanizer)

**Before:**
> "Yeah, you're right, this works around the issue rather than fixing it. The real fix is in `MergeService`: when we move a child under a new parent, it should update `pipeline_id` along with `parent_id`. We can backfill the bad rows from the audit log with `Change.where(field: "pipeline_id", source: "merge")`. I checked QA: 123 past merges, only 6 rows wrong now, so the cleanup is small.
>
> Since `MergeService` is shared and not specific to this account, I'd rather open a separate ticket than widen this PR. The fallback here is fine to keep until then."

**After:**
> "Agreed, this is a workaround. Fixing it properly in `MergeService` would widen this ticket well past its scope: it is shared code, so it means checking the merge flow for every account, plus a backfill for the rows that are already wrong.
>
> I'd rather keep this PR account specific and open a separate ticket for the `MergeService` fix and the backfill. Let me know if that works."

The reviewer knows the bug. The After leads with the decision and keeps the one fact they lack: the fix touches shared code.

## Formatting

### 44. Decorative heading

**Before:**
> "## 🚀 Getting Started With Vogon"

**After:**
> "## Install Vogon"

### 45. Hyphenated pairs after the noun (humanizer)

**Before:**
> "The report is high-quality, the process is well-documented, and the plan is long-term."

**After:**
> "The report is high quality, the process is well documented, and the plan is long term."

## Full passages

Real slop stacks a dozen tells. These show the whole rewrite at once. Both come from the
humanizer README (MIT). The Before text keeps its dashes and emoji as quoted source.

### 46. Product announcement (humanizer)

**Before:**
> I'm thrilled to announce that shared drafts are finally here! 🚀 For months, our own team was drowning in files named final_v7.docx — and we knew there had to be a better way. Now two people can edit the same doc at once, with every change appearing live for both of them. It's not just a feature; it's a whole new way to collaborate. Comments stay anchored to the exact sentence they reference, even as the text around them evolves. And the best part? It's available today on every plan, completely free. Let that sink in.

**After:**
> Shared drafts are out today. For months our own team passed around files named final_v7.docx, so we built a way for two people to edit the same doc at once, with each person's changes showing up live for the other. Comments stay pinned to the sentence they're about, even when the text around them changes. It's free on every plan.

### 47. Travel post (humanizer)

**Before:**
> I recently spent five unforgettable days in Lisbon last October, and let me tell you — this city completely stole my heart. From the moment I checked into my charming hotel perched high in the historic Alfama district, I knew I was somewhere truly special.
>
> Yes, the famous hills are challenging — with countless stairs between my hotel and everything else, my legs certainly felt it! — but every climb rewards you with breathtaking, panoramic views that make it all worthwhile.
>
> No trip would be complete without riding the iconic Tram 28, a roughly forty-minute journey shared with plenty of fellow travelers eager to capture the magic. And the food? Simply divine. While the pastéis de nata at Pastéis de Belém are a beloved national treasure, my absolute favorite came from a hidden gem in Graça, still warm from the oven.
>
> But what truly makes Lisbon special isn't just the sights — it's the feeling. Wander just a block or two above the main squares and you'll discover a quieter, more authentic side of the city, inviting you to slow down and savor every moment.
>
> Of course, the must-see São Jorge Castle offers stunning views over the rooftops below. The queues can be long, but the experience is absolutely worth it for any history buff or curious traveler.
>
> Would I go back? Absolutely — next time in spring, and with better shoes! Lisbon isn't just a place to visit; it's a place to fall in love with, again and again. ✨

**After:**
> I spent five days in Lisbon last October. My hotel was up in Alfama, with a lot of stairs between it and everything else, and my legs felt every one of them. The views from the top were worth the climb.
>
> Everyone tells you to ride Tram 28, so I did. The trip took about forty minutes, and most of the car was other tourists taking pictures out the windows. The custard tarts at Pastéis de Belém are the famous ones, but my favorite came from a place in Graça, still warm from the oven.
>
> The part of Lisbon I liked best starts a block or two above the main squares, where the streets go quiet and nobody is in a hurry. São Jorge Castle has good views over the rooftops and a long queue to get them.
>
> I'd go back, in spring next time, and with better shoes.

The After keeps the writer's voice and opinions. Removing tells is half the job; the result still
sounds like a person.
