#!/usr/bin/env bash
# Install the playbook templates into an existing repo. Never overwrites a file.
# Usage: ./install.sh /path/to/your/repo [--statusline]
#   --statusline  also copies statusline.sh to ~/.claude/ (you add one line to your user settings)
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
target=${1:-}
[[ -n "$target" && -d "$target" ]] || { echo "usage: $0 /path/to/your/repo [--statusline]" >&2; exit 1; }
target=$(cd "$target" && pwd)
statusline=false
[[ "${2:-}" == "--statusline" ]] && statusline=true

added=0; skipped=0
copy() {
  local src=$1 dst=$2
  if [[ -e "$dst" ]]; then
    echo "skip  ${dst#"$target"/} (exists, left untouched)"
    skipped=$((skipped + 1))
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "add   ${dst#"$target"/}"
    added=$((added + 1))
  fi
}

while IFS= read -r -d '' f; do
  rel=${f#"$here"/templates/}
  [[ "$rel" == memory/* ]] && continue   # memory is an example, not a repo file
  copy "$f" "$target/$rel"
done < <(find "$here/templates" -type f -print0 | sort -z)

copy "$here/tools/codemap.py" "$target/tools/codemap.py"
chmod +x "$target"/.claude/hooks/*.sh "$target/scripts/gate.example.sh" "$target/tools/codemap.py" 2>/dev/null || true

if ! grep -qx '.agent/' "$target/.gitignore" 2>/dev/null; then
  echo '.agent/' >> "$target/.gitignore"
  echo "add   .agent/ to .gitignore"
fi

if $statusline; then
  mkdir -p "$HOME/.claude"
  if [[ -e "$HOME/.claude/statusline.sh" ]]; then
    echo "skip  ~/.claude/statusline.sh (exists)"
  else
    cp "$here/statusline/statusline.sh" "$HOME/.claude/statusline.sh"
    chmod +x "$HOME/.claude/statusline.sh"
    echo "add   ~/.claude/statusline.sh"
  fi
fi

command -v jq >/dev/null || echo "WARNING: jq is not installed; the hooks and status line need it."

cat <<EOF

Done: $added added, $skipped skipped.
Next:
  1. Edit CLAUDE.md: project line, environment, commands. Keep it under ~150 lines.
  2. Rename scripts/gate.example.sh to scripts/gate.sh and set your real checks.
  3. Review .claude/settings.json: allowlist, deny list, autocompact % for YOUR window size.
  4. Start a session and run /context once to see your fixed per-turn cost.
EOF
$statusline && echo '  5. Add to ~/.claude/settings.json: { "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" } }'
exit 0
