# macOS

First-class macOS support. **mise is the package manager — Homebrew is never
installed.**

## One-command setup

```bash
curl -fsSL https://raw.githubusercontent.com/a19simma/configs/master/scripts/bootstrap-macos.sh | bash
```

Requires Apple Silicon. See [Intel Macs](#intel-macs) below.

## How mise replaces Homebrew

mise's `brew:` and `brew-cask:` package managers install Homebrew formulae and
casks **without Homebrew present**. mise fetches metadata from the
formulae.brew.sh API, downloads bottles from ghcr.io, verifies checksums, and
does the same relocation, code-signing and linking work `brew` does when
pouring a bottle. Casks are downloaded, verified, and the `.app` moved into
`/Applications`. Everything lands in `/opt/homebrew`, the canonical prefix.

So there are only two tiers, both declared in `mise.macos.toml`:

| Tier | Where | What |
|---|---|---|
| `[tools]` | mise's native backends | versioned dev tools — gh, neovim, node, go, ripgrep, starship… |
| `[bootstrap.packages]` | `brew:` / `brew-cask:` | system-integrated formulae (stow, nushell, tmux) and GUI apps |

If a real Homebrew ever gets installed alongside, the two coexist: mise writes
brew-compatible `INSTALL_RECEIPT.json` files, so `brew list` and `brew upgrade`
see mise-poured kegs as their own, and vice versa.

## Why this file loads automatically

`.miserc.toml` sets `auto_env = true`. That makes mise treat the platform as a
config environment and load `mise.{os}.toml` — so `mise.macos.toml` merges on
top of the root `mise.toml` on macOS and is invisible on Linux and Windows.

**There is no `-f` flag.** `mise -f mise.macos.toml run <task>` does not work —
mise parses the filename as a task name. If `auto_env` ever misbehaves, the
explicit fallback is `MISE_ENV=macos mise run <task>`.

Check what's loaded with `mise config ls`.

## What replaces what

| Linux | macOS |
|---|---|
| i3 / sway | AeroSpace (`alt` is the mod key) |
| rofi / dmenu | Raycast (`cmd-space`) |
| apt / pacman | mise (`[tools]` + `[bootstrap.packages]`) |
| `.Xresources`, `xset r rate` | `[bootstrap.macos.*]` in mise.macos.toml |
| systemd units | launchd — see `mise bootstrap launchd` |

## Commands

```bash
mise bootstrap                          # reconcile everything to config
mise bootstrap plan                     # preview changes without applying
mise bootstrap status                   # installed vs declared
mise bootstrap macos defaults status    # system-preference drift
mise bootstrap macos defaults apply     # write them
mise run stow-deploy-macos              # symlink dotfiles
mise run doctor-macos                   # full health check
```

Edit `mise.macos.toml`, run `mise bootstrap`, done. No script to keep in sync.

## Differences from the Linux bootstrap

- **Login shell stays zsh.** `bootstrap-unix` runs `sudo chsh -s nu`; on macOS
  that's riskier because login and system scripts assume a POSIX `sh`. nu is
  registered in `/etc/shells` and launched by Alacritty instead. Override with
  `chsh -s "$(command -v nu)"` if you want it anyway.
- **No `setup-ssh-server`.** WSL/WezTerm latency workaround, installs via apt.
- **No `install-system-deps`.** apt/yum only.
- **VS Code path differs.** macOS uses
  `~/Library/Application Support/Code/User`, not `~/.config/Code`. The Linux
  `stow-deploy` would create a dead symlink here.
- **New stow packages:** `alacritty/` and `aerospace/`. The readme previously
  claimed an `alacritty/` package existed but the repo had none.

## Things macOS won't let a script do

Grant in **System Settings > Privacy & Security > Accessibility** after opening
each app once:

- **AeroSpace** — cannot move any window without it
- **Raycast** — needed for its window and app control features

Then free `cmd-space`: System Settings > Keyboard > Keyboard Shortcuts >
Spotlight, uncheck "Show Spotlight search", and set the hotkey inside Raycast.

Note that replacing an `.app` bundle resets its Accessibility grant. That's why
`[bootstrap.brew] adopt = true` is set — mise adopts an existing identical app
rather than swapping the bundle, so you don't re-grant permissions on every run.

## AeroSpace cheat sheet

`alt` is the mod key.

| Binding | Action |
|---|---|
| `alt-enter` | new Alacritty |
| `alt-h/j/k/l` | focus |
| `alt-shift-h/j/k/l` | move window |
| `alt-1..0` | switch workspace |
| `alt-shift-1..0` | move window to workspace |
| `alt-f` | fullscreen |
| `alt-slash` | toggle tile orientation |
| `alt-comma` | accordion (tabbed) layout |
| `alt-shift-space` | float / tile toggle |
| `alt-shift-q` | close window |
| `alt-r` | resize mode (`hjkl`, `esc` exits) |
| `alt-shift-;` | service mode (`esc` reloads config, `r` flattens tree) |

## Intel Macs

mise's `brew` manager is unavailable on Intel — it supports macOS arm64 and
Linux only. `scripts/bootstrap-macos.sh` refuses to run there. On Intel,
install Homebrew normally and use the root `Brewfile`.

## Deprecated files

`Caskfile` and `scripts/macos-defaults.sh` are superseded by
`[bootstrap.packages]` and `[bootstrap.macos.*]`. Both are stubs pointing at
the replacement; delete once the mise path is proven.

## Open items

- The Brewfile entry `brew "rtk"` is not a homebrew-core formula and its
  comment describes a proxy that intercepts command output for AI agents. It is
  not installed by the macOS path. Worth verifying where it came from.
- The AeroSpace bindings are stock i3 conventions — they haven't been
  reconciled with the `glaze-wm`/`komorebi` keybinds used on Windows.
- `nikitabobko/tap` (AeroSpace) is a third-party tap. mise supports these only
  when the tap publishes Homebrew API metadata. If `mise bootstrap` reports the
  cask unavailable, that's why — fall back to downloading AeroSpace's release
  directly or use a `ubi:`/`github:` tool entry.
