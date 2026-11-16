#!/usr/bin/env bash
set -euo pipefail

pueue_json=$(pueue status --json)

job_state() {
  jq -r --arg id "$1" '.tasks[$id].status // {} | keys[0] // "missing"' <<<"$pueue_json"
}

pr_summary() {
  local repo_path=$1 branch=$2 pr runs
  [[ $branch == "(detached)" || -z $branch ]] && { echo "-"; return; }
  pr=$(cd "$repo_path" && timeout 20 gh pr list --head "$branch" --state all --limit 1 --json number,state,isDraft \
    --jq '.[0] | if . == null then "" else "#\(.number) \(.state | ascii_downcase)\(if .isDraft then " draft" else "" end)" end' 2>/dev/null || true)
  [[ -z $pr ]] && { echo "no PR"; return; }
  runs=$(cd "$repo_path" && timeout 20 gh run list --branch "$branch" --limit 40 --json headSha,status,conclusion \
    --jq '[.[] | select(.conclusion != "skipped")] | (.[0].headSha // "") as $head | [.[] | select(.headSha == $head) | (if .conclusion == "" then .status else .conclusion end)] | group_by(.) | map("\(length) \(.[0])") | join(", ")' 2>/dev/null || true)
  echo "$pr ci: ${runs:-none}"
}

workmux status --all --json --git | jq -c '.agents[]' | while read -r agent; do
  pane=$(jq -r '.pane_id' <<<"$agent")
  worktree=$(jq -r '.worktree' <<<"$agent")
  project=$(jq -r '.project' <<<"$agent")
  status=$(jq -r '.status' <<<"$agent")
  elapsed=$(jq -r '.elapsed_secs' <<<"$agent")
  branch=$(jq -r '.branch' <<<"$agent")
  repo_path=$(jq -r '.project_path' <<<"$agent")

  if ! tmux display -p -t "$pane" '#{pane_id}' >/dev/null 2>&1; then
    printf '%s\t%s/%s\tgone\n' "$pane" "$project" "$worktree"
    continue
  fi

  screen=$(tmux capture-pane -p -t "$pane")
  waits=""
  while read -r id; do
    [[ -z $id ]] && continue
    state=$(job_state "$id")
    waits+=" job $id=$state"
    [[ $state == Done ]] && waits+="(STALE POLL)"
  done < <(grep -E '^\s+◯ ' <<<"$screen" | grep -o -i -E '(job|task) [0-9]+' | grep -o -E '[0-9]+' | sort -u)

  box=$(awk '{ line[NR] = $0 } /^─/ { prev = cur; cur = NR } END { for (i = prev + 1; i < cur; i++) print line[i] }' <<<"$screen" \
    | sed -e 's/^❯//' | tr -s '[:space:]' ' ' | sed -e 's/^ //' -e 's/ $//' | cut -c1-60)
  grep -q '[[:alnum:]]' <<<"$box" && waits+=" unsent: \"$box\""

  printf '%s\t%s/%s\t%s %dm\t%s\t%s\n' "$pane" "$project" "$worktree" "$status" $((elapsed / 60)) \
    "$(pr_summary "$repo_path" "$branch")" "${waits# }"
done
