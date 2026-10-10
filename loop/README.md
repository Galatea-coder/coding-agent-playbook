# Loop engineering (Part 2, coming soon)

From prompting your agent to engineering its loop. Every decision point in the read, write, run,
inspect, revise loop gets a cheap typed judgment with a confidence score:

- route: does this question need the owner, the lead model, or a measurement?
- inspect: is this red run caused by the change, pre-existing, or the environment?
- done: is the unit actually done?

High confidence: the agent acts. Low confidence: the lead model reasons it through. Only money,
irreversible actions and the objective reach a human.

The worked example uses Jev (TypeSafe), a model built to return typed decisions with calibrated
confidence. Part 2 also covers alternatives. Templates will land here with the Part 2 article.
