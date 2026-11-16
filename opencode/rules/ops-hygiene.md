# Ops hygiene

- **Deferred work**: whatever arms a deferred callback (timer, spawned task, listener) disarms it when its owner is destroyed; test destroy while one is pending and assert nothing fires. A handler attached to the end of a chain runs for every step before it: a step added after a state transition gets its own handler, and the guard covers the whole continuation, not the one step named.
- **Authority row lock**: a check-then-act inside a transaction takes `FOR SHARE` or `FOR UPDATE` on the authority row, not only on the rows it reads; define "needed" or "matching" before writing the query.
