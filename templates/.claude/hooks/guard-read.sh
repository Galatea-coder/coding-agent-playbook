#!/usr/bin/env bash
# PreToolUse hook (matcher: Read). Blocks whole-file reads of large text files.
# Reads that pass offset or limit are allowed. Threshold: READ_GUARD_LINES (default 400).
# Exit 2 blocks the call and sends stderr back to the agent so it can self-correct.
input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
limit=$(jq -r '.tool_input.limit // empty' <<<"$input")
offset=$(jq -r '.tool_input.offset // empty' <<<"$input")
max=${READ_GUARD_LINES:-400}

[[ -z "$file" || ! -f "$file" ]] && exit 0
[[ -n "$limit" || -n "$offset" ]] && exit 0
case "$file" in
  *.png|*.jpg|*.jpeg|*.gif|*.webp|*.pdf|*.ipynb) exit 0 ;;
esac

lines=$(wc -l < "$file" | tr -d ' ')
if (( lines > max )); then
  echo "Blocked: $file is $lines lines. Locate first (codemap or grep -n), then Read with offset/limit around the match." >&2
  exit 2
fi
exit 0
