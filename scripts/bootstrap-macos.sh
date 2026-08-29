#!/usr/bin/env bash
#
# Bootstrap a fresh macOS machine.
#
#   curl -fsSL https://raw.githubusercontent.com/a19simma/configs/master/scripts/bootstrap-macos.sh | bash
#
# This script is deliberately thin. Its only jobs are the three things that
# cannot be declared in config: install mise, clone the repo, and hand over.
# Everything after that lives in mise.macos.toml as declarative config.
#
# Homebrew is NOT installed. mise pours brew formulae and casks itself into
# /opt/homebrew. Requires Apple Silicon — mise's brew manager is unavailable on
# Intel Macs.
#
set -euo pipefail

REPO="a19simma/configs"
REPO_DIR="${CONFIGS_DIR:-$HOME/repos/configs}"

log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

[ "$(uname -s)" = "Darwin" ] || { echo "macOS only."; exit 1; }
if [ "$(uname -m)" != "arm64" ]; then
  warn "Intel Mac detected. mise's brew package manager does not support Intel."
  warn "Install Homebrew manually and use the Brewfile instead of this script."
  exit 1
fi

# --- 1. Xcode command line tools --------------------------------------------
# Needed for git, and for any brew formula mise has to build from source.
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode command line tools (a GUI dialog will appear)"
  xcode-select --install
  until xcode-select -p >/dev/null 2>&1; do sleep 10; done
fi

# --- 2. mise ----------------------------------------------------------------
if ! command -v mise >/dev/null 2>&1; then
  log "Installing mise"
  curl -fsSL https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"

# --- 3. Clone the repo ------------------------------------------------------
if [ -d "$REPO_DIR/.git" ]; then
  log "Repo present at $REPO_DIR — pulling"
  git -C "$REPO_DIR" pull --ff-only || warn "pull failed; continuing"
else
  log "Cloning $REPO -> $REPO_DIR"
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "https://github.com/$REPO" "$REPO_DIR"
fi
cd "$REPO_DIR"

# mise refuses to run config it hasn't been told to trust.
mise trust --yes .

# --- 4. Hand over to mise ---------------------------------------------------
# mise.macos.toml loads automatically here: .miserc.toml sets auto_env = true,
# which makes mise treat the platform as a config environment.
log "Confirming macOS config is loaded"
mise config ls

log "Preview of what will change"
mise bootstrap plan || true

log "Running bootstrap"
mise run bootstrap-macos

cat <<'EOF'

✅ Bootstrap complete.

MANUAL STEPS — macOS will not let a script do these:

  1. Grant Accessibility to AeroSpace and Raycast.
     System Settings > Privacy & Security > Accessibility
     Open each app once first so it appears in the list. Neither can move a
     window without this.

  2. Free Cmd+Space for Raycast:
     System Settings > Keyboard > Keyboard Shortcuts > Spotlight
     Uncheck "Show Spotlight search", then set the hotkey inside Raycast.

  3. Enable "Start at login" from AeroSpace's menu bar icon.

  4. Log out and back in — key repeat and Dock settings need it.

Day-to-day:
    mise run doctor-macos     # health check + package/defaults drift
    mise bootstrap status     # what's installed vs declared
    mise bootstrap            # reconcile after editing mise.macos.toml
    mise upgrade              # update tools
EOF
