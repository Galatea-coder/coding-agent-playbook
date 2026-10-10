#!/usr/bin/env bash
# Example gate. Rename to scripts/gate.sh and edit the checks below.
# Runs every check, logs to .agent/logs/gate.log, and records the result in
# .agent/last-gate.json for the Stop hook (stop-on-red.sh).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
mkdir -p .agent/logs
log=.agent/logs/gate.log
: > "$log"
failed=""

run() {
  local name=$1; shift
  echo "== $name: $*" >> "$log"
  if ! "$@" >> "$log" 2>&1; then
    failed="${failed:+$failed, }$name"
  fi
}

# ---- checks: edit these ----
run lint  ruff check .
run tests pytest -q
# ----------------------------

now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
if [[ -z "$failed" ]]; then
  printf '{"status":"pass","at":"%s"}\n' "$now" > .agent/last-gate.json
  echo "GATE PASS"
else
  printf '{"status":"fail","failed":"%s","at":"%s"}\n' "$failed" "$now" > .agent/last-gate.json
  echo "GATE FAIL: $failed (full log: $log)"
  tail -20 "$log"
  exit 1
fi
