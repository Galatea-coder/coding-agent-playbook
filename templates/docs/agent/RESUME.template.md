# Resume prompt (first message after /clear)

Six parts, under 1,200 characters. The SessionStart hook already injects .claude/HANDOVER.md; this sets the posture.

```
Resume <unit name>.
1. READ: .claude/HANDOVER.md, RULES.md R03 R07 (by number), <spec path>.
2. VERIFY STATE: branch <name> at <sha>, pushed; `./scripts/gate.sh` green. If anything differs, stop and tell me.
3. THIS STEP: <the moment-specific action, e.g. "finish the retry path in sync/client.py:140, the test is already written">.
4. ORDER: <next unit> -> <then> -> <then>. One unit in flight.
5. HARD GATES: full gate once before close-out; no destructive git; escalate only money / irreversible / objective.
6. GOTCHAS: <e.g. "test_sync_timeout is flaky under load; rerun once before investigating">.
Confirm items 2 and 3 in two lines, then start.
```
