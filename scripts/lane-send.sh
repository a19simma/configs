#!/usr/bin/env bash
set -euo pipefail

pane=${1:?usage: lane-send.sh <%pane_id> <file>}
file=${2:?usage: lane-send.sh <%pane_id> <file>}
max_tries=4

input_box() {
  tmux capture-pane -p -t "$pane" | awk '
    { line[NR] = $0 }
    /^─/ { prev = cur; cur = NR }
    END { for (i = prev + 1; i < cur; i++) print line[i] }'
}

box_is_empty() {
  ! input_box | sed -e 's/^❯//' | grep -q '[[:alnum:][:punct:]]'
}

if ! box_is_empty; then
  echo "lane-send: input box in $pane already holds text; refusing to paste over it" >&2
  exit 2
fi

tmux load-buffer -b lane-send "$file"
tmux paste-buffer -d -b lane-send -t "$pane"
sleep 1

for ((try = 1; try <= max_tries; try++)); do
  tmux send-keys -t "$pane" Enter
  sleep 3
  if box_is_empty; then
    echo "lane-send: submitted to $pane after $try Enter(s)"
    exit 0
  fi
done

echo "lane-send: text still in $pane input after $max_tries Enters" >&2
exit 1
