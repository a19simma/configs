#!/bin/sh
# Write the malmDone gh token where workmux sandboxes can read it.
#
# Runs as the workmux post_create hook, on the host, once per `workmux add`.
# workmux reads sandbox.env_passthrough in the pane's supervisor, which
# inherits the tmux server's env, so a token exported for one `workmux add`
# never reaches the container. A file does: workmux/config.yaml mounts this
# dir read-only at /opt/host-gh, and network-init.sh copies it into
# /tmp/.config/gh.
#
# The token comes from the host keyring and stays out of the normal shell's
# env. Only malmDone goes in, so the a19simma token in ~/.config/gh/hosts.yml
# never reaches a sandbox. config.yml carries `version: "1"` so gh skips the
# config migration that dies without a keyring.
#
# Never fails the hook: a keyring error keeps the previous file and warns.
set -eu

dir="${XDG_STATE_HOME:-$HOME/.local/state}/wm-gh"
umask 077
mkdir -p "$dir"
chmod 700 "$dir"

if ! token=$(gh auth token -h github.com -u malmDone 2>/dev/null) || [ -z "$token" ]; then
    echo "wm-gh-token: no gh token for malmDone, sandbox keeps $dir as is" >&2
    exit 0
fi

tmp=$(mktemp "$dir/hosts.yml.XXXXXX")
printf 'github.com:\n    users:\n        malmDone:\n            oauth_token: %s\n    git_protocol: https\n    oauth_token: %s\n    user: malmDone\n' \
    "$token" "$token" > "$tmp"
mv -f "$tmp" "$dir/hosts.yml"

if [ ! -f "$dir/config.yml" ]; then
    printf 'version: "1"\ngit_protocol: https\nprompt: disabled\n' > "$dir/config.yml"
fi
