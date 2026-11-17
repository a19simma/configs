#!/bin/sh
# Write the gh and fj logins where workmux sandboxes can read them.
#
# Runs as the workmux post_create hook, on the host, once per `workmux add`.
# workmux reads sandbox.env_passthrough in the pane's supervisor, which
# inherits the tmux server's env, so a token exported for one `workmux add`
# never reaches the container. A file does: workmux/config.yaml mounts these
# dirs read-only at /opt/host-gh and /opt/host-fj, and network-init.sh copies
# them into /tmp/.config/gh and /tmp/.local/share/forgejo-cli.
#
# gh: the account comes from $WM_GH_USER, else the first line of
# ${XDG_CONFIG_HOME:-~/.config}/wm-gh/user. Its token comes from the host
# keyring and stays out of the normal shell's env. Only that account goes in,
# so any other login in ~/.config/gh/hosts.yml never reaches a sandbox.
# config.yml carries `version: "1"` so gh skips the config migration that dies
# without a keyring.
#
# fj: the host's keys.json is copied unread. It holds a token for every host
# fj is logged in to.
#
# Never fails the hook: a missing account, login or keyring error keeps the
# previous files and warns.
set -u

umask 077
state="${XDG_STATE_HOME:-$HOME/.local/state}"

gh_login() {
    dir="$state/wm-gh"
    user="${WM_GH_USER:-}"
    if [ -z "$user" ]; then
        cfg="${XDG_CONFIG_HOME:-$HOME/.config}/wm-gh/user"
        [ -f "$cfg" ] && IFS= read -r user < "$cfg"
    fi
    if [ -z "$user" ]; then
        echo "wm-gh-token: no gh account, set WM_GH_USER or write it to ${XDG_CONFIG_HOME:-$HOME/.config}/wm-gh/user, sandbox keeps $dir as is" >&2
        return 0
    fi
    mkdir -p "$dir" && chmod 700 "$dir" || return 0
    if ! token=$(gh auth token -h github.com -u "$user" 2>/dev/null) || [ -z "$token" ]; then
        echo "wm-gh-token: no gh token for $user, sandbox keeps $dir as is" >&2
        return 0
    fi
    tmp=$(mktemp "$dir/hosts.yml.XXXXXX") || return 0
    printf 'github.com:\n    users:\n        %s:\n            oauth_token: %s\n    git_protocol: https\n    oauth_token: %s\n    user: %s\n' \
        "$user" "$token" "$token" "$user" > "$tmp"
    mv -f "$tmp" "$dir/hosts.yml"
    if [ ! -f "$dir/config.yml" ]; then
        printf 'version: "1"\ngit_protocol: https\nprompt: disabled\n' > "$dir/config.yml"
    fi
}

fj_login() {
    dir="$state/wm-fj"
    if [ "$(uname -s)" = Darwin ]; then
        src="$HOME/Library/Application Support/forgejo-cli.forgejo-cli/keys.json"
    else
        src="${XDG_DATA_HOME:-$HOME/.local/share}/forgejo-cli/keys.json"
    fi
    if [ ! -f "$src" ]; then
        echo "wm-gh-token: no fj login at $src, sandbox keeps $dir as is" >&2
        return 0
    fi
    mkdir -p "$dir" && chmod 700 "$dir" || return 0
    tmp=$(mktemp "$dir/keys.json.XXXXXX") || return 0
    if cp "$src" "$tmp"; then
        mv -f "$tmp" "$dir/keys.json"
    else
        rm -f "$tmp"
        echo "wm-gh-token: could not copy fj login, sandbox keeps $dir as is" >&2
    fi
}

gh_login
fj_login
exit 0
