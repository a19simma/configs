# Lessons from fleet

Each line came from a defect or a failed gate in a real project. Load when writing async, process, systemd or test code.

## Async and processes
- A polling loop on external state needs a terminal condition for each ambiguous state and a deadline. After a kill request, treat the ambiguous state as ended.
- A future awaited inside `select!` must be cancel-safe and cheap to recreate. Run long polls in a spawned task and await a channel or `JoinHandle`.
- When capturing a child's output, bound the reader wait and abort the reader after the child exits. A detached descendant can hold the pipe open.
- Run destructive startup steps only after the process has won its single-instance guard (socket bind or lock).

## Sandboxing and config
- Run each sandbox directive against the real workload on a live host before the gate, one probe per directive. A fake service manager misses directive conflicts.
- When a config value selects a trusted principal, docs and install steps state the owner and non-writability the file needs, and the task lists it as an acceptance item.
- Before writing an encoder for another tool's file format, read that tool's parser or spec. Add a round-trip test through the real parser where cheap.
- Under a namespace quota, read the quota and LimitRange first and test the manifest against them.

## Tests
- Model every state the real service can report in a test double. Treat a recorded DEFER that the live canary exercises as blocking.
- Test an error path by injecting the error, never by racing the kernel.
- Test every pinned value with the shapes the default config produces, such as a relative path.
- For a both-or-neither field group, test all set, none set and each single field missing.
- Write one negative test per required-field check.

## Data
- Redact before truncating, and test an encoded secret that straddles the cap.
- Enforce an invariant in the type that relies on it, not only in the caller.
