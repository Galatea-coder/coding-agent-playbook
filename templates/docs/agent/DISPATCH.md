# Dispatch brief

Paste this into every subagent delegation, filled in. Inline is the default: delegate only work that is truly parallel or too large for one context (more than ~6 files).

```
TASK: <one sentence, outcome not activity>
SPEC: <absolute path to the spec file, if any>
SCOPE: <files/dirs you may change>. Read-only elsewhere.
DONE WHEN: <observable result, e.g. "tests/test_retry.py passes, no other test changes">
DON'T: git stash/checkout/reset/clean; push; read other agents' output files; widen scope.
MODEL: <haiku for search | sonnet for build | inherit for adversarial review>
REPORT (max 15 lines): outcome | files changed | commands run + result | assumptions | open questions.
```

After it reports: treat the report as unverified. Re-run one command it cites and check that any path it names exists before repeating it. To follow up, continue the same agent rather than spawning a new one.
