#!/usr/bin/env bash
# Stop hook: refuse to end the turn while the last gate run is red and not parked.
# The gate writes .agent/last-gate.json, e.g. {"status":"fail","failed":"tests/test_x.py::test_y"}.
input=$(cat)
[[ $(jq -r '.stop_hook_active // false' <<<"$input") == "true" ]] && exit 0   # avoid loops
state="${CLAUDE_PROJECT_DIR:-.}/.agent/last-gate.json"
[[ -f "$state" ]] || exit 0
status=$(jq -r '.status // "unknown"' "$state")
parked=$(jq -r '.parked // false' "$state")
if [[ "$status" == "fail" && "$parked" != "true" ]]; then
  echo "Last gate run failed: $(jq -r '.failed // "see .agent/logs/gate.log"' "$state"). Fix it, or park it: note it under Gotchas in .claude/HANDOVER.md and set \"parked\": true in .agent/last-gate.json." >&2
  exit 2
fi
exit 0
