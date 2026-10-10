# <Project name>

<One sentence: what this codebase does and who uses it.>

## Golden rules
1. Locate before you read: `python tools/codemap.py where|callers <name>`, then `grep -n`, then Read with offset/limit. Never read a whole file over ~400 lines (a hook enforces this).
2. Never re-read a file you just edited to verify it. The edit result is the confirmation.
3. Inline by default. Delegate only parallel or large work (> ~6 files) to the agents in .claude/agents/. Every dispatch uses the brief in docs/agent/DISPATCH.md.
4. Context: you cannot measure your own context. At every clean stopping point, offer once: "Clean stopping point. Hand over, or take the next task?" Never stop mid-task because you feel low on context.
5. Verification: targeted tests while building; the full gate (`./scripts/gate.sh`) once, at the end of a unit of work. Copy commands from the script, never from memory.
6. Decisions: follow the decision rules below.
7. Output: summarize tool results in 1-3 lines. Don't echo code back or restate the task.

## Decision rules
1. Method and implementation choices are yours. Decide, state it in one line ("Using X because Y"), continue.
2. Escalate only: money, irreversible actions (deletes, migrations, pushes to main, anything external), or the goal itself.
   Format: DECISION NEEDED: <what> | Options: <A / B> | My default: <A, because ...>
   Then wait for my answer on that item, and keep working on anything that doesn't depend on it.
3. One recommendation, never a menu. No lists of 3+ options unless I ask for them.
4. Ask me only for facts you can't look up (dates, terms, preferences), never for numbers you can compute from them.
5. Before naming a root cause, choosing a design, or setting a number: gather evidence for AND against your first guess. Cite the command or file.
6. Decisions made earlier this session are settled. Reopen one only with new evidence, and say what it is.
7. One unit of work in flight. Anything else you notice: one line in the backlog, then back to the unit.

## Environment
- <Language/runtime + version>, <package manager>, <OS quirks>
- Start every shell command with an absolute `cd`.
- Background jobs: `<cmd> > .agent/logs/<name>.log 2>&1` via the harness's background mode, then act on the completion notification. Never poll; never pipe a background job into tail.
- Liveness check: compare the log's modification time with `date` in the same call. Silence from ps/pgrep is not evidence of death.

## Commands
- Map:        `python tools/codemap.py where <Name>` / `callers <name>`
- Test (one): `<pytest path/to/test_x.py -q 2>&1 | tail -20>`
- Lint:       `<ruff check path>`
- Full gate:  `./scripts/gate.sh`

## Rule index
Full text in RULES.md. Read one rule by number: `grep -n -A 15 '^## R07' RULES.md`
- R01 Irreversible actions need my sign-off
- R02 New dependencies: justify in one line, prefer stdlib
- R03 Every bug fix lands with a failing-then-passing test
- R04 Public API changes update docs/api.md in the same change
- R05 Long-lived docs: every entry starts with a greppable ID
- R06 Dates are absolute (YYYY-MM-DD)
- R07 Process budget: a new rule must retire an old one
- <R08 ...>

## Handover
When I say "hand over": bring the unit to green, run the gate once, write .claude/HANDOVER.md from docs/agent/HANDOVER.template.md (under 60 lines, resume prompt included), commit and push, then stop.
