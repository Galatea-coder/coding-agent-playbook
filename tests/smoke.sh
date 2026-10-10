#!/usr/bin/env bash
# Smoke tests: feed sample JSON to each hook and script, check exit codes and output.
# Run from anywhere: ./tests/smoke.sh   (needs bash, jq, python3)
set -uo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
hooks="$repo/templates/.claude/hooks"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
pass=0; fail=0

check() {  # check "name" expected_exit actual_exit [output] [expected_substring]
  local name=$1 want=$2 got=$3 out=${4:-} needle=${5:-}
  if [[ "$got" == "$want" && ( -z "$needle" || "$out" == *"$needle"* ) ]]; then
    echo "ok    $name"; pass=$((pass + 1))
  else
    echo "FAIL  $name (exit $got, want $want; output: ${out:0:120})"; fail=$((fail + 1))
  fi
}

# guard-read.sh
seq 1 1000 > "$tmp/big.txt"; seq 1 10 > "$tmp/small.txt"
out=$(echo "{\"tool_input\":{\"file_path\":\"$tmp/big.txt\"}}" | "$hooks/guard-read.sh" 2>&1); check "guard-read blocks whole read of big file" 2 $? "$out" "Blocked"
out=$(echo "{\"tool_input\":{\"file_path\":\"$tmp/big.txt\",\"offset\":10,\"limit\":40}}" | "$hooks/guard-read.sh" 2>&1); check "guard-read allows sliced read" 0 $? "$out"
out=$(echo "{\"tool_input\":{\"file_path\":\"$tmp/small.txt\"}}" | "$hooks/guard-read.sh" 2>&1); check "guard-read allows small file" 0 $? "$out"
out=$(echo "{\"tool_input\":{\"file_path\":\"$tmp/big.txt\"}}" | READ_GUARD_LINES=5000 "$hooks/guard-read.sh" 2>&1); check "guard-read honors READ_GUARD_LINES" 0 $? "$out"

# stop-on-red.sh
mkdir -p "$tmp/proj/.agent"; state="$tmp/proj/.agent/last-gate.json"
echo '{"status":"fail","failed":"tests/test_x.py"}' > "$state"
out=$(echo '{}' | CLAUDE_PROJECT_DIR="$tmp/proj" "$hooks/stop-on-red.sh" 2>&1); check "stop-on-red blocks on red gate" 2 $? "$out" "tests/test_x.py"
out=$(echo '{"stop_hook_active":true}' | CLAUDE_PROJECT_DIR="$tmp/proj" "$hooks/stop-on-red.sh" 2>&1); check "stop-on-red avoids loops" 0 $? "$out"
echo '{"status":"fail","parked":true}' > "$state"
out=$(echo '{}' | CLAUDE_PROJECT_DIR="$tmp/proj" "$hooks/stop-on-red.sh" 2>&1); check "stop-on-red allows parked red" 0 $? "$out"
echo '{"status":"pass"}' > "$state"
out=$(echo '{}' | CLAUDE_PROJECT_DIR="$tmp/proj" "$hooks/stop-on-red.sh" 2>&1); check "stop-on-red allows green" 0 $? "$out"

# session-start.sh
out=$(CLAUDE_PROJECT_DIR="$tmp/proj" "$hooks/session-start.sh" 2>&1); check "session-start silent without handover" 0 $? "$out"
mkdir -p "$tmp/proj/.claude"; echo "# Handover: test unit" > "$tmp/proj/.claude/HANDOVER.md"
out=$(CLAUDE_PROJECT_DIR="$tmp/proj" "$hooks/session-start.sh" 2>&1); check "session-start injects handover" 0 $? "$out" "Handover: test unit"

# statusline.sh
sample='{"model":{"display_name":"Opus"},"cost":{"total_cost_usd":3.456},"context_window":{"current_usage":{"input_tokens":2000,"output_tokens":500,"cache_creation_input_tokens":8000,"cache_read_input_tokens":195000}}}'
out=$(echo "$sample" | "$repo/statusline/statusline.sh"); check "statusline flags handover at 205k" 0 $? "$out" "ctx 205k  [HANDOVER NOW] | \$3.46"
out=$(echo '{"model":{"display_name":"Opus"},"context_window":{"current_usage":null}}' | "$repo/statusline/statusline.sh"); check "statusline handles null usage" 0 $? "$out" "ctx 0k"

# codemap.py
printf 'class Client:\n    def push(self, x):\n        return x\n\ndef run():\n    Client().push(1)\n' > "$tmp/proj/sample.py"
out=$(python3 "$repo/tools/codemap.py" where push "$tmp/proj"); check "codemap where" 0 $? "$out" "sample.py:2-3  def push"
out=$(python3 "$repo/tools/codemap.py" callers push "$tmp/proj"); check "codemap callers" 0 $? "$out" "sample.py:6"

# settings.json
out=$(jq -e '.hooks.PreToolUse[0].matcher == "Read"' "$repo/templates/.claude/settings.json" 2>&1); check "settings.json is valid JSON" 0 $? "$out"

# install.sh: adds files, then never overwrites
mkdir -p "$tmp/target"; echo "my own rules" > "$tmp/target/CLAUDE.md"
out=$("$repo/install.sh" "$tmp/target" 2>&1); check "install runs" 0 $? "$out" "skip  CLAUDE.md"
[[ "$(cat "$tmp/target/CLAUDE.md")" == "my own rules" ]]; check "install never overwrites" 0 $?
[[ -x "$tmp/target/.claude/hooks/guard-read.sh" && -f "$tmp/target/tools/codemap.py" ]]; check "install places hooks and codemap" 0 $?
grep -qx '.agent/' "$tmp/target/.gitignore"; check "install ignores .agent/" 0 $?

echo; echo "$pass passed, $fail failed"
(( fail == 0 ))
