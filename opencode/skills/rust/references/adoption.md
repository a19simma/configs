# Adoption Evidence

Method: workspace `Cargo.toml` read directly in each repo — never a blog post or a download count.

**Runtime deps, 14 repos:** ten tools/libraries (uv, ruff, zed, deno, rust-analyzer, turso, pixi, jj, oxc, polars) and four network services (qdrant, vector, linkerd2-proxy, datafusion).

**Dev-deps, 26 repos:** the fifteen tool/library repos above plus wasmtime, tokio, axum, sqlx and ripgrep, and eleven service/desktop repos — qdrant, vector, linkerd2-proxy, datafusion, apollo-router, loco, sea-orm, shuttle, tikv, gitbutler and spacedrive (the last two being the Tauri-shaped ones).

**Cohort bias, stated up front:** the runtime-dep set is heavy on CLI tools and compilers, so its web and desktop counts rest on four and two repos. The dev-dep set is better balanced at 15 tools to 11 services. Where the two cohorts disagree — `rstest` and `testcontainers` both being far more common in services — the split is reported rather than averaged away.

## Allowlisted entries

| Crate | Adoption | Read |
| --- | --- | --- |
| `serde` / `serde_json` | 13/14 | Effectively universal. Only linkerd2-proxy omits it. |
| `tracing` | 12/14 | Universal outside two repos that still use `log`. |
| `tokio` | 12/14 | Present even in tools that are not servers. |
| `clap` | 8/14 | Every repo shipping a CLI. Correctly scoped to the CLI profile. |
| `reqwest` | 7/14 | Standard outbound HTTP. oxc uses `ureq` (blocking, smaller). |
| `tonic` | 3/14 | But **3/4 of the service repos** — qdrant, vector, linkerd2-proxy. Strong within its niche, absent outside it, exactly as scoped. |
| `axum` | 2/14 in the survey | Undercounted by a tool-heavy cohort. Downloads tell the real story: 110.9M/90 days against `actix-web`'s 9.9M. Sole allowed web framework. |
| `rusqlite` | 2/14 | deno, turso. |
| `sqlx` | 1/14 | vector only, plus spacedrive on the desktop side. Thin, because most of the cohort are not database clients. |
| `tauri` | 2/2 desktop | gitbutler, spacedrive. No desktop repo in the main cohort, so this rests on a separate check. |
| `diesel` | 0/14 | Nothing in the cohort uses it. Consistent with it being permission-only. |

No allowlisted runtime crate is unused across the cohort except `diesel`, which is already gated.

## Banned crates with high adoption

The tension worth seeing plainly. These are on the "not allowed without permission" list and are more widely used than several allowlisted entries:

| Crate | Adoption | What it does that `std` does not |
| --- | --- | --- |
| `indexmap` | 12/14 | Deterministic iteration order — matters for reproducible output and stable snapshots. |
| `itertools` | 11/14 | `chunks`, `group_by`, `dedup_by`, `sorted` — each replaceable by a loop, all of them tedious. |
| `futures` | 10/14 | `Stream`, combinators. Unavoidable once async is in play. |
| `rayon` | 8/14 | Data parallelism via `par_iter`. |
| `parking_lot` | 8/14 | Faster, smaller mutexes; the gap to `std::sync` has narrowed. |
| `smallvec` | 8/14 | Inline storage on hot paths. |
| `dashmap` | 7/14 | Sharded concurrent map. |
| `bitflags` | 7/14 | Typed flag sets. |
| `bytes` | 7/14 | Refcounted byte buffers; `tokio`/`hyper` expose it anyway. |
| `once_cell` | 3/14 | Superseded by `std::sync::LazyLock` — the low count confirms migration. Stays banned. |

`indexmap`, `itertools` and `futures` each have higher adoption than `clap`, which is allowlisted. That does not make the ban wrong — this allowlist is deliberately stricter than the ecosystem norm — but it predicts where permission requests will come from. `futures` is the strongest case of the four: once `Stream` is in play there is no `std` equivalent, and it arrives transitively through `tokio` anyway.

The four crates that filled genuine `std` gaps — `rand`, `regex`, `uuid`, and a date/time crate — were moved to **Core — std gaps** and are now allowed outright.

---


Use this when a ban is challenged or a new crate is proposed. The rulings themselves live in `crates.md`.
