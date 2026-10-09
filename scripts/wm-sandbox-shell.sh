#!/bin/sh
# Wait for the worktree's sandbox container, then exec into it.
#
# workmux starts every window of a session at once. Only the `agent` window
# creates the container (sandbox.target: agent); the `agent2` and `box` windows
# run `workmux sandbox shell -e`, which execs into an existing container and
# fails outright if there is not one yet. Losing that race drops both panes to
# a host shell that looks almost identical to the sandboxed one, so the failure
# is easy to miss.
#
# Called from workmux/config.yaml by name, from ~/.local/bin where
# `mise run stow-deploy` links it. workmux runs pane commands through tmux's
# default-shell, which is nushell, and this is POSIX.
#
#   wm-sandbox-shell.sh nu
#   wm-sandbox-shell.sh wm-user claude --tools ...
#   wm-sandbox-shell.sh --name        # print the container name and exit
#
# There is no stable container name to wait on. workmux names containers
# wm-<worktree>-<pid> with no configurable prefix, and sets no labels
# (`docker inspect --format '{{json .Config.Labels}}'` is `{}`), so the name
# prefix is the only handle. `workmux config reference` documents runtime,
# memory, cpus, oci_runtime, cap_add, security_opt and excluded_files under
# `container:` and nothing for naming. Docker cannot add a label to a running
# container either, so this cannot be fixed after the fact from here.
set -eu

TIMEOUT_SECONDS=60
POLL_INTERVAL=0.5

# worktree_naming is `basename` in workmux/config.yaml, and pane commands start
# in the worktree root, so the directory name is the container's name segment.
worktree=$(basename "$PWD")
prefix="wm-${worktree}-"

container_name() {
    docker ps --format '{{.Names}}' 2>/dev/null | grep "^${prefix}" | head -1
}

lima_vm() {
    project=$(basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")")
    limactl list --format '{{.Name}} {{.Status}}' 2>/dev/null \
        | awk -v p="^wm-${project}-" '$2 == "Running" && $1 ~ p { print $1; exit }'
}

# Two iterations per second, hence the doubling.
attempts=$(awk "BEGIN { print int(${TIMEOUT_SECONDS} / ${POLL_INTERVAL}) }")
i=0
while [ -z "$(container_name)" ]; do
    if [ -n "$(lima_vm)" ]; then
        [ "${1:-}" = "wm-user" ] && shift
        exec "$(dirname "$0")/wm-lima-shell.sh" "$@"
    fi
    i=$((i + 1))
    if [ "$i" -ge "$attempts" ]; then
        echo "wm-sandbox-shell: no container matching '${prefix}*' after ${TIMEOUT_SECONDS}s" >&2
        echo "wm-sandbox-shell: is the agent window up? check 'docker ps | grep wm-'" >&2
        exit 1
    fi
    sleep "$POLL_INTERVAL"
done

if [ "${1:-}" = "--name" ]; then
    container_name
    exit 0
fi

exec workmux sandbox shell -e -- "$@"
