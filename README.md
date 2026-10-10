# Coding Agent Playbook

**Your coding agent isn't expensive. Your context is.**

Drop-in templates for running AI coding agents with less context, fewer tokens and better oversight. They come out of three months of building a real codebase almost entirely with coding agents, after I found that most of my usage was running with more than 150k tokens in context.

Built for Claude Code. The ideas port to AGENTS.md, Cursor and Codex (see [Portability](#portability)).

> Companion to the article *Your Coding Agent Isn't Expensive. Your Context Is.* <!-- add link -->

## Quick start

```bash
git clone https://github.com/<you>/coding-agent-playbook.git
./coding-agent-playbook/install.sh /path/to/your/repo --statusline
```

The installer **never overwrites** an existing file. It skips anything already there and tells you. It needs `bash`, `jq` and `python3`. Run `./tests/smoke.sh` to check the hooks on your machine.

Then:

1. Edit `CLAUDE.md`: project line, environment, commands. Keep it under ~150 lines.
2. Rename `scripts/gate.example.sh` to `scripts/gate.sh` and set your real checks.
3. Review `.claude/settings.json`: the allowlist, the deny list, and the auto-compact percentage for **your** window size.
4. Add the status line to `~/.claude/settings.json` (the installer prints the line).
5. Start a session and run `/context` once to see your fixed per-turn cost.

## What's inside

| File | What it does | Why |
| --- | --- | --- |
| `templates/CLAUDE.md` | Always-loaded rules: golden rules, **decision rules**, env, commands, a one-line **rule index** | Every line here is paid for on every session |
| `templates/RULES.md` | Full rule text, read one rule at a time by number | On-demand, not always-loaded. `@imports` don't save tokens; they load eagerly |
| `templates/docs/agent/HANDOVER.template.md` | Handover file with Highlight, **Owner** and **Context at close** lines | A handover beats auto-compaction: you choose what survives |
| `templates/docs/agent/RESUME.template.md` | Six-part resume prompt, under 1,200 characters | The new session starts warm and never has to ask |
| `templates/docs/agent/DISPATCH.md` | Brief for every subagent: task, scope, done-when, report cap | Subagents aren't free; unbounded reports are file dumps |
| `templates/docs/agent/DECISION-RULES.md` | Before/after examples of the CLAUDE.md decision rules, and how to check they work | Most agent questions it could answer itself; most rework comes from unresearched decisions |
| `templates/docs/agent/OVERSIGHT.md` | Owner's checkpoint review, session checklist, oversight mode | Oversee units of work, not keystrokes |
| `templates/.claude/agents/` | `scout` (haiku), `implementer` (sonnet), `verifier` (inherit) | Subagents inherit the lead's model unless you name one |
| `templates/.claude/hooks/guard-read.sh` | PreToolUse: blocks whole-file reads over 400 lines | Map, grep, then read a slice, enforced rather than requested |
| `templates/.claude/hooks/session-start.sh` | SessionStart: injects the latest handover (capped at 6 KB) | `/clear` without losing the thread |
| `templates/.claude/hooks/stop-on-red.sh` | Stop: refuses to end a turn on a red gate unless parked | No victory laps over failing tests |
| `templates/.claude/settings.json` | Hooks, allowlist, deny list, subagent model, auto-compact | Fewer approval prompts, fenced danger |
| `templates/scripts/gate.example.sh` | One gate command that records pass/fail for the Stop hook | Copy verification from the script, never from memory |
| `templates/memory/MEMORY.example.md` | Example memory index (not installed) | Memory holds machine facts and pointers, never a second rulebook |
| `tools/codemap.py` | `where` / `callers` lookup with line ranges (Python, `ast`) | A 56-line slice instead of a 2,000-line read |
| `statusline/statusline.sh` | `Opus \| ctx 205k [HANDOVER NOW] \| $3.46` | The agent can't feel its context fill. You need the gauge |

## The rules in twelve lines

1. Budget context size times turns, and keep the cache warm. One cold turn at 400k costs about as much as fifty warm turns at 100k.
2. Hand over at about 200k or a finished unit of work, then `/clear`. Put the gauge in your status line.
3. Map, grep, then read a slice. Enforce it with a hook. Never re-read after editing.
4. Tail foreground output; send background output to a log file and act on the completion notification.
5. Inline by default. Subagents only for parallel or large work, with an explicit model and a capped report.
6. Builders run targeted tests; the lead runs the full gate once.
7. Memory holds machine facts and pointers, never a second copy of the rules. Absolute dates; fix stale entries on contact.
8. Keep CLAUDE.md under about 150 lines with a rule index. Don't fake the split with `@imports`.
9. Copy verification steps from the gate; run the command you cite.
10. Budget your process. If half your commits are paperwork, the paperwork is the product.
11. Oversee units of work, not keystrokes: approve the plan, allowlist the safe, fence the dangerous, review at checkpoints, get pinged.
12. Escalate only money, irreversible actions and the objective, with a default. Recommend and proceed; one unit in flight.

## Compatibility notes

Checked against the Claude Code docs in October 2026. These surfaces change, so check before you rely on them:

- **Hook input fields.** Log one real input (`cat > /tmp/hook-input.json` as the hook command) and confirm `tool_input.file_path`, `offset` and `limit` match your version.
- **Permission-rule syntax** for Bash patterns has changed across versions. Check the current permissions docs.
- **`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`** is a percentage of your context window, and it can only lower the threshold. 25 suits a 1M window; on a 200k window it fires at 50k.
- **The deny list is a guardrail, not a security boundary.** A `Read` deny doesn't stop `cat` through the shell. Real protection comes from backups and the sandbox.
- **Install hooks that steer the agent yourself.** Don't have the agent write its own guardrails.

## Portability

| Idea | Claude Code | Elsewhere |
| --- | --- | --- |
| Always-loaded rules | `CLAUDE.md` | `AGENTS.md` (Codex and others), `.cursor/rules/` |
| On-demand rules | `RULES.md` read by number | The same: it's a file and grep |
| Handover | `HANDOVER.md` + SessionStart hook | `HANDOVER.md` + paste the resume prompt |
| Context gauge | Status line | Built-in meters, or hand over by turn count |
| Read discipline | PreToolUse hook | Approval rules, or a golden rule plus review |
| Model routing | `model:` in agent files | Per-agent or per-mode model settings |
| Oversight | Plan mode, allowlist, Stop/Notification hooks | Plan/ask modes, command allowlists, CI as the gate |

## Coming next

`loop/`: Part 2, loop engineering. A cheap typed judgment with a confidence score at each decision point of the agent's loop, so routine calls stop reaching you. Worked example: Jev (TypeSafe). It's also the other fix for oversight mode (see `templates/docs/agent/OVERSIGHT.md`).

## Licence

Code and config: [MIT](LICENSE). Written guidance: [CC BY 4.0](LICENSE-CONTENT.md).
