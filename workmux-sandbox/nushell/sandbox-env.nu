# nushell env for the workmux container sandbox. Mounted read-only at
# /opt/nushell, loaded by path:
#   nu --env-config /opt/nushell/sandbox-env.nu --config /opt/nushell/sandbox-config.nu
#
# Deliberately not ../../nushell/env.nu. That file branches to env-macos.nu,
# defines kubectl/fzf helpers for tools the image does not carry, and expects a
# host HOME. Here HOME is /tmp and the toolchain is only what
# mise.sandbox.toml bakes in.
#
# PATH is left alone: workmux injects
# /tmp/.workmux-shims/bin:/tmp/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
# and the mise shims are already in /usr/local/bin via MISE_SHIMS_DIR.

# Demote to the sandbox user. `workmux sandbox shell -e` is a docker exec and
# inherits the container's --user 0:0, so this file first runs as root.
# network-init.sh's setpriv tail only covers PID 1 and `sandbox shell` has no
# --user flag, so nu has to do it itself. nu's `exec` replaces the process, and
# wm-user re-runs nu with the same config as ${WM_TARGET_UID}.
#
# First thing in the file, and it must stay first. The zoxide and starship
# blocks below write into /tmp; run them as root and the generated files end up
# root-owned, at which point the `path exists` guards mean they are never
# regenerated for the user who actually needs them.
#
# wm-user sets WM_SANDBOX_USER, which is what stops the re-exec'd nu from
# demoting again when it re-parses this file. The WM_TARGET_UID check keeps a
# plain `nu` working in any context where workmux did not set up the
# environment.
if ($env.WM_SANDBOX_USER? | is-empty) and ($env.WM_TARGET_UID? | is-not-empty) {
    if (^id -u | str trim) == "0" {
        exec wm-user nu
    }
}

# zoxide's init script has to be sourced from a static path, and the mount is
# read-only, so generate it under HOME (/tmp, writable) on first start. env.nu
# runs before config.nu, so the file exists by the time config.nu is parsed.
#
# The empty fallback is not optional. `source` resolves at parse time, so an
# `if (path exists)` guard in config.nu does not save it: a missing file is a
# hard parse error that kills the whole config. Always leave something to
# source, even if zoxide is absent from the image.
if not ("/tmp/.zoxide.nu" | path exists) {
    if (which zoxide | is-not-empty) {
        zoxide init nushell | save -f /tmp/.zoxide.nu
    } else {
        "" | save -f /tmp/.zoxide.nu
    }
}

# Starship, same generate-then-source dance, and it cannot be pre-generated on
# the host: `starship init nu` bakes the absolute path of the starship binary
# into the script, and the host path
# (~/.local/share/mise/installs/starship/...) does not exist in the image.
#
# The fallback module is what runs when starship is missing. It has to define
# PROMPT_COMMAND itself, because config.nu `use`s this file unconditionally and
# an empty module would leave nu with no prompt at all.
# Point starship at the sandbox config before generating the init script.
# Starship reads STARSHIP_CONFIG at prompt render time, not at init time, so
# this has to be exported here in env.nu rather than baked into /tmp/.starship.nu.
#
# Without it starship uses its defaults, whose `rust` module runs
# `rustup component list`. Every pane in the container shares
# RUSTUP_HOME=/opt/rust/rustup, rustup locks it, and the losing panes block in
# futex_wait_queue with no prompt ever rendering.
if ("/opt/nushell/starship.toml" | path exists) {
    $env.STARSHIP_CONFIG = "/opt/nushell/starship.toml"
}

if not ("/tmp/.starship.nu" | path exists) {
    if (which starship | is-not-empty) {
        starship init nu | save -f /tmp/.starship.nu
    } else {
        'export-env { $env.PROMPT_COMMAND = {|| $"(pwd)" } }' | save -f /tmp/.starship.nu
    }
}
