---
name: mise-bump
description: List every pinned mise tool version in this repo and bump them to the latest available. Use when the user asks to check, list, or update mise tool versions in the configs repo.
---

# mise-bump

Audit and bump the mise pins in this repo. Four config files hold pins, and only
two of them are ever an *active* mise config, so `mise outdated` alone never
sees the whole picture.

## The four files

| File | Scope | Active when |
| --- | --- | --- |
| `mise.toml` | repo-only tools and all the `[tasks.*]` | cwd is this repo |
| `mise.macos.toml` | macOS-only additions to the above | cwd is this repo, on macOS |
| `mise/config.toml` | the stowed global config (`~/.config/mise/config.toml`) | always |
| `workmux-sandbox/mise.sandbox.toml` | baked into the sandbox Docker image | never, it is read by the image build |

`mise/config.toml` deliberately mirrors a subset of `mise.toml`: a pin that
exists only in `mise.toml` leaves PATH the moment you leave this repo. When
bumping, keep the duplicated entries at the same version in both files.
`mise.sandbox.toml` duplicates a further subset for Linux.

## Step 1: list

```nu
mise outdated --bump
```

`--bump` is required. Without it mise compares inside the range already pinned,
so a `20` pin never reports 22.x. That covers `mise.toml`,
`mise.macos.toml` and `mise/config.toml`.

For the sandbox file, which mise does not load, resolve each pin by hand:

```nu
open workmux-sandbox/mise.sandbox.toml
| get tools
| transpose tool pinned
| where ($it.pinned | describe) == "string"
| insert latest {|r| mise latest $r.tool }
| where pinned != latest
```

Report the table. Do not bump anything yet.

## Step 2: bump

Active configs:

```nu
mise upgrade --bump --dry-run   # read the plan first
mise upgrade --bump
```

`--bump` rewrites the pin in the file and keeps its precision, so `"1.2.3"`
becomes `"4.5.6"` and `"1"` becomes `"4"`.

The sandbox file gets edited by hand from the step 1 table. Two rules there:

- `"github:nushell/nushell"` and friends stay exact. An unpinned `latest` means
  a rebuild can silently change the language version under the agent.
- After editing it, the image is stale. Rebuild with
  `mise run workmux-sandbox-image`, then recycle any running sandbox
  (`workmux close <name>` then `workmux open -c <name>`).

## What not to touch

- `brew:` and `brew-cask:` entries. Homebrew has no version selection, mise
  reports them as `latest` and bumping is meaningless.
- Anything pinned with a comment naming a reason (an MSRV floor, a known
  regression). Report it as held and leave the pin.
- `python`, `node` and `go` major versions if a project in `~/repos` pins the
  same major. Bumping the global out from under a repo breaks its lockfile.

## Git

Leave every change in the working tree. Do not stage, commit, or push. Print
the diff and say what would be committed.
