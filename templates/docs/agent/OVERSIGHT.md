# Oversight checklists

## Owner's checkpoint review (2 minutes per unit)
- [ ] Handover Owner line: decisions needed? anything decided for me I disagree with?
- [ ] Diff: size matches the plan? files touched outside declared scope?
- [ ] Gate: green, run once, at the end? test count went up, not down?
- [ ] Claims: one cited number or command re-run myself
- [ ] Context at close: under ~200k? if not, why (reading, subagents, polling)?
- [ ] Same correction made twice this week? -> rule, hook or allowlist entry (and retire one)

## Session checklist
```
START   cwd + memory loaded (or follow the pointer) -> resume prompt -> codemap before any survey grep
DURING  slices not files | batch independent calls | background long jobs, act on the notification
        targeted tests | decide and log; file findings, don't chase them | one unit in flight
~200k   unit to green -> gate once -> handover + resume prompt -> file decisions/backlog
        -> commit, push, CI green -> /clear (never drift into auto-compaction)
```

## Oversight mode in six moves
1. Approve the plan (plan mode), not every step.
2. Allowlist the safe, deny the dangerous, fence auto-approval with backups.
3. Escalation contract: money, irreversible actions, the objective. Always with a default.
4. Review at checkpoints (above), not in the transcript.
5. Interrupt early: watch the first five minutes of a unit, then step back.
6. Get pinged (Notification hook) so you return while the cache is warm.
