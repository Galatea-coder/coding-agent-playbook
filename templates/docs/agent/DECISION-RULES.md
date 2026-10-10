# Decision rules: what good looks like

The rules themselves live in CLAUDE.md ("Decision rules"). This page is for you, the owner:
what the rules should change, and how to tell whether they're working.

Most questions a coding agent asks, it could answer itself. Each one stalls the session, risks a
cold cache if you're slow to reply, and spends your attention. Most rework comes from the opposite:
decisions made too fast, without evidence.

## Before and after

| Instead of the agent doing this | It now does this |
| --- | --- |
| "Should I use approach A or B?" | "Using A: it matches the existing retry logic in sync/client.py. Say 'B' to switch." |
| A survey of five options with pros and cons | One recommendation and one line of why |
| "What's the renewal date?" | "What's the contract start date and term?" Then it computes the renewal date itself. |
| "The bug is in the cache layer" after one look | "Two pieces of evidence point to the cache, one against (it reproduces with the cache off). Checking the serializer first." |
| Reopening "should we switch databases?" mid-session | Treats it as settled unless something new turns up, and names it if it does |
| Fixing three unrelated things it noticed along the way | Three one-line backlog entries, then back to the unit |
| Dropping a table because you didn't reply | "DECISION NEEDED: drop legacy_orders (irreversible). My default: archive, then drop." It waits on that item and carries on with other work. |

Note the last row: method choices proceed on the agent's default; money and irreversible
decisions never proceed on silence.

## Check it's working

- **Count questions per unit of work.** More than one or two that aren't real escalations means the
  rules aren't biting. Add the offending question to RULES.md as a "don't" example, with the line
  the agent should have written instead.
- **Watch for the opposite failure.** If you find decisions you'd have wanted a say in, they're
  probably goal-level. Name that category explicitly in decision rule 2; don't loosen everything.
- **Escalations should take seconds to answer.** If you can't reply with one word ("yes", "B"),
  the agent didn't do its homework. Send it back for evidence and a default.

Decision rules are the agent's side of the escalation contract in OVERSIGHT.md: oversight mode is
how you stop being the bottleneck; decision rules are how the agent stops making you one.
