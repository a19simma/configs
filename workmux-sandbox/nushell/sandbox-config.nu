# nushell config for the workmux container sandbox. See sandbox-env.nu for why
# this is separate from ../../nushell/config.nu.
#
# No atuin: its history DB is host-only and deliberately not shared into the
# sandbox. mise needs no activation because its shims are on PATH. No `claude`
# alias on purpose, the host one carries --dangerously-skip-permissions and the
# agent's flags belong in workmux/config.yaml's `agents:` block instead.

$env.config.show_banner = false
$env.config.edit_mode = "vi"

# Starship owns the prompt. sandbox-env.nu guarantees this file exists and is a
# valid module, so the `use` is unguarded; see the comment there.
use /tmp/.starship.nu

# Starship's init sets PROMPT_INDICATOR to "", so reuse it as the sandbox
# marker: a container shell should never be mistakable for a host one. Set
# after the `use`, or export-env overwrites it. uname -s is still the durable
# check, this is only a reminder.
$env.PROMPT_INDICATOR = $"(ansi red_bold)[sandbox](ansi reset) "

# sandbox-env.nu guarantees this file exists, empty at worst. Unguarded because
# `source` is parse-time; see the comment there.
source /tmp/.zoxide.nu

alias ll = ls -la
alias gs = git status
alias gd = git diff
