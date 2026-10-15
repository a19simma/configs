---
name: bump
description: Inventory dependency, chart and image versions, research upgrades, and plan the upgrade paths.
disable-model-invocation: true
---

Read-only. Change no files.

## 1. Inventory

Scan the current directory tree for every pinned version. Cover every ecosystem present:

- Packages: `package.json` and lockfiles, `Cargo.toml`, `go.mod`, `pyproject.toml`, `requirements*.txt`, `*.csproj`
- Runtimes and toolchains: `engines`, `rust-toolchain.toml`, `.tool-versions`, `mise.toml`
- Helm: `Chart.yaml` dependencies, `values.yaml` image tags, `helmfile`, Argo or Flux `HelmRelease`
- Containers: `Dockerfile` `FROM`, compose, Kubernetes `image:`
- CI: GitHub Actions `uses:`

Table: **Name | Kind | Current | Where (path:line)**. Resolve ranges to the locked version.

Done when every manifest found by the scan is a row or explicitly skipped with a reason.

## 2. Research

Pick the majors: runtimes, frameworks, charts, base images, and anything whose update crosses a major. Group the minor and patch leaves into one row each.

Fifteen or fewer majors: dispatch one `researcher` per subject in a single message.

More than fifteen: stop and ask the user to pick one, with a recommendation:
- **Top 15**: the most important by blast radius, ranked runtimes, then frameworks, then charts and base images, then the rest. List the 15 and what you left out.
- **Slices of 15**: split by that same ranking. Each slice runs steps 2 to 4 in turn, and the next slice starts after the user confirms.

Brief each researcher with the name, the current version, and this ask:
- Latest stable release, excluding pre-releases.
- Every release between current and latest, with the breaking changes of each.
- The upgrade path: required intermediate versions, migration steps, deprecated APIs in use.
- A source link and verbatim quote for every claim. Mark anything unverified.

Done when every major in scope has a report or is marked unresearched.

## 3. Upgrade table

Table: **Name | Current | Latest stable | Path | Breaking changes | Source**.

Carry each researcher's links and quotes through intact. Label every source by kind. Repeat unverified items as unverified.

## 4. Cross-dependencies

Check every pair of upgrades for conflicts. Cover:

- Runtime floors: a package's new minimum Node, Rust, Go, or Python against the runtime row.
- Peer and shared dependencies: two upgrades that need incompatible ranges of a third.
- Chart and image: chart `appVersion` against the image tag, and chart requirements against the Kubernetes version.
- Base images: a base-image bump against the toolchain or glibc baked into it.
- Ordering: an upgrade that must land before or after another.

Table: **Upgrade A | Upgrade B | Conflict | Required order**. Then give the safe sequence.

Done when every pair sharing a runtime, a dependency, or an image is checked.

## 5. Hand off

Ask the user to run `/handoff` to capture the plan and `/to-tickets` to spawn one ticket per upgrade in the safe sequence. Run neither yourself.

Leave every change in the working tree. Stage, commit, and push nothing.
