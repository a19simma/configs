#!/bin/sh
# sesh picker. Bound to prefix+t in tmux.conf via `display-popup -E`, which
# gives fzf a real TTY. Keep it POSIX sh: nushell is the login shell and cannot
# run this.
#
# --with-shell is required for the same reason. fzf shells out to $SHELL for
# every --bind execute/reload, and nushell does not take `-c 'cmd'` the way fzf
# expects, so every binding would silently do nothing.
#
# `sesh list --icons` prefixes each line with an icon plus a space, so the
# session name is field 2 onward. Anything consuming a name needs {2..}, never
# {} -- `sesh preview` and `tmux kill-session` both exit 0 on an unmatched name
# and simply do nothing, so getting this wrong fails silently.
sesh connect "$(
  sesh list --icons | fzf \
    --with-shell 'sh -c' \
    --no-sort --ansi \
    --border-label ' sesh ' \
    --prompt '⚡  ' \
    --header '  ^a all  ^t tmux  ^g configs  ^z zoxide  ^d kill' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
    --bind 'ctrl-z:change-prompt(📁  )+reload(sesh list -z --icons)' \
    --bind 'ctrl-d:execute-silent(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
    --preview-window 'right:55%' \
    --preview 'sesh preview {2..}'
)"
