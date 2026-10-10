#!/usr/bin/env bash
# SessionStart hook: inject the latest handover so a fresh session starts warm.
# Whatever this prints is added to the new session's context. Capped at 6 KB.
f="${CLAUDE_PROJECT_DIR:-.}/.claude/HANDOVER.md"
[[ -f "$f" ]] || exit 0
echo "=== Latest handover (modified $(date -r "$f" '+%Y-%m-%d %H:%M')) ==="
head -c 6000 "$f"
