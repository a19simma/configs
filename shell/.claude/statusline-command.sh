#!/usr/bin/env bash
set -uo pipefail

input=$(cat)
settings="$HOME/.claude/settings.json"

num() {
  local re="\"$2\"[[:space:]]*:[[:space:]]*([0-9]+)"
  [[ $1 =~ $re ]] && echo "${BASH_REMATCH[1]}"
}

limit=$(num "$input" context_window_size)
[ "${limit:-0}" -gt 0 ] 2>/dev/null || limit=200000

if [ -f "$settings" ]; then
  compact=$(num "$(cat "$settings")" autoCompactWindow)
  [ "${compact:-0}" -gt 0 ] 2>/dev/null && [ "$compact" -lt "$limit" ] && limit=$compact
fi

used=$(num "$input" total_input_tokens)
used=${used:-0}
pct=$(( limit > 0 ? used * 100 / limit : 0 ))

if   [ "$pct" -ge 90 ]; then color='\033[31m'
elif [ "$pct" -ge 70 ]; then color='\033[33m'
else                        color='\033[32m'
fi

printf "${color}%d.%dk/%d.%dk %d%%\033[0m\n" \
  $(( used / 1000 )) $(( used % 1000 / 100 )) \
  $(( limit / 1000 )) $(( limit % 1000 / 100 )) \
  "$pct"
