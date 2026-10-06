#!/bin/sh
# Wait for the worktree's Lima sandbox VM, then exec into it.
#
# The Lima counterpart to wm-sandbox-shell.sh. A separate script rather than a
# flag on that one because the two resolve completely different things: that
# one waits on a per-WORKTREE container, this one waits on a per-PROJECT VM.
#
# Why not `workmux sandbox shell -e` here:
#
#   1. `sandbox shell` takes no --config. Its handler calls
#      `Config::load(None)` (src/command/sandbox.rs), so it always reads the
#      GLOBAL config. With `backend: container` there, a Lima-backed worktree's
#      agent2/box panes ask for a CONTAINER and workmux dutifully starts one --
#      a second sandbox, with a different filesystem and toolchain, alongside
#      the VM the agent window is using.
#   2. Even reading the right config would not help. run_shell_lima() starts
#      with `if exec { bail!(...) }`: "The --exec flag is only supported with
#      the container backend."
#
# So the panes have to talk to Lima directly. limactl it is.
#
# Called from a workmux config by absolute path: workmux runs pane commands
# through tmux's default-shell, which is nushell, and this is POSIX.
#
#   wm-lima-shell.sh nu
#   wm-lima-shell.sh claude --tools ...
#   wm-lima-shell.sh --name        # print the VM name and exit
set -eu

TIMEOUT_SECONDS=900   # VM creation pulls a ~600MB image and provisions.
POLL_INTERVAL=1

# workmux names project-isolated VMs wm-<project>-<hash>, where <project> is
# the name of the MAIN repo, not the worktree. `git rev-parse --git-common-dir`
# resolves to the main checkout's .git even from inside a linked worktree,
# which is exactly the indirection needed here -- --show-toplevel would return
# the worktree and yield `wm-next-*`, matching nothing.
common_git=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
    echo "wm-lima-shell: not inside a git worktree: $PWD" >&2
    exit 1
}
project=$(basename "$(dirname "$common_git")")
prefix="wm-${project}-"

# Only a Running VM is usable. A VM mid-creation is listed but not yet
# reachable, so match on status rather than presence.
#
# A space, not a tab: limactl renders the Go template literally and does not
# interpret escapes, so '{{.Name}}\t{{.Status}}' prints the two characters
# backslash-t and awk sees one field, never two.
vm_name() {
    limactl list --format '{{.Name}} {{.Status}}' 2>/dev/null \
        | awk -v p="^${prefix}" '$2 == "Running" && $1 ~ p { print $1; exit }'
}

attempts=$(awk "BEGIN { print int(${TIMEOUT_SECONDS} / ${POLL_INTERVAL}) }")
i=0
while [ -z "$(vm_name)" ]; do
    i=$((i + 1))
    if [ "$i" -ge "$attempts" ]; then
        echo "wm-lima-shell: no Running VM matching '${prefix}*' after ${TIMEOUT_SECONDS}s" >&2
        echo "wm-lima-shell: is the agent window up? check 'limactl list'" >&2
        exit 1
    fi
    sleep "$POLL_INTERVAL"
done

vm=$(vm_name)

if [ "${1:-}" = "--name" ]; then
    echo "$vm"
    exit 0
fi

# --workdir keeps the pane in the same directory it started in. Lima mounts
# host paths at their host locations, so $PWD is valid inside the guest.
#
# PATH is set here rather than left to the login shell. The provision script
# appends mise activation to ~/.bashrc, but Debian's ~/.bashrc returns early
# when not interactive:
#
#     case $- in *i*) ;; *) return;; esac
#
# `bash -lc` is a login shell but NOT an interactive one, so that guard fires
# and mise never activates. Probing a freshly provisioned VM with `bash -lc`
# reported kubectl, helm, k3d, node and the rest as MISSING while
# `mise ls --installed` listed all 19 -- they were installed the whole time,
# just unreachable.
#
# The shims directory is used rather than `mise activate`, since it needs no
# shell hook and works in any shell.
shims='$HOME/.local/share/mise/shims'

quoted=""
for arg in "$@"; do
    quoted="$quoted '$(printf '%s' "$arg" | sed "s/'/'\\\\''/g")'"
done

exec limactl shell --workdir "$PWD" "$vm" -- \
    bash -lc "export PATH=\"${shims}:\$HOME/.local/bin:\$PATH\"; exec $quoted"
