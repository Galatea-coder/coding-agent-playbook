# Memory index. One fact, one home. Ways of working live in CLAUDE.md/RULES.md, not here.
<!-- Example only. Keep to about a dozen lines; each a dated fact and its consequence.
     Link a topic file only when there's more to say. Fix stale lines on contact. -->
- 2026-09-27 Rules: CLAUDE.md (index) + RULES.md (full text). Memory never restates them.
- 2026-09-30 Background shells start in $HOME. Every command starts with an absolute cd.
- 2026-10-02 The VM restarts between sessions. Long jobs must be resumable.
- 2026-10-03 The sandbox hides the GPU. Run GPU jobs unsandboxed; check availability in the same mode.
- 2026-10-04 The sandbox has its own network namespace. Never report a service down from a sandboxed probe.
- 2026-10-06 A sandbox denial mid-git-operation leaves partial state. Run history-rewriting git unsandboxed. [git-recovery](git-recovery.md)
- 2026-10-08 User-level "ask" rules beat project "allow" rules. Durable grants go in ~/.claude/settings.json.
- 2026-10-10 Before anything destructive on data: confirm a backup from today exists.
