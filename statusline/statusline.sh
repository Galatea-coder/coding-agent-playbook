#!/usr/bin/env bash
# Status line: model | context in k tokens + handover flag | session cost.
# Install: copy to ~/.claude/statusline.sh and add to ~/.claude/settings.json:
#   { "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }
# Thresholds: HANDOVER_WARN_K (default 150), HANDOVER_AT_K (default 200).
input=$(cat)
model=$(jq -r '.model.display_name // "?"' <<<"$input")
ctx=$(jq -r '.context_window.current_usage
  | if . == null then 0
    else (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens) end' <<<"$input")
cost=$(jq -r '.cost.total_cost_usd // 0' <<<"$input")
k=$(( ctx / 1000 ))
flag=""
(( k >= ${HANDOVER_WARN_K:-150} )) && flag="  [plan handover]"
(( k >= ${HANDOVER_AT_K:-200} )) && flag="  [HANDOVER NOW]"
printf '%s | ctx %sk%s | $%.2f\n' "$model" "$k" "$flag" "$cost"
