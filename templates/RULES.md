# Rules (full text)

Read one rule at a time by number, never this whole file:
`grep -n -A 15 '^## R03' RULES.md`

Each rule keeps its number forever. Retired rules keep their heading with "RETIRED <date>: <reason>" so old references still resolve.

## R01 Irreversible actions need my sign-off
**Why:** <the incident that created this rule, one line, dated>.
**Do:** before deletes, migrations, force-pushes, pushes to main, or anything leaving the machine, state the action, its blast radius and your recommended default, then wait.
**Don't:** batch an irreversible step inside a larger "routine" change.

## R02 New dependencies
**Why:** <date>: <dependency that caused a problem>.
**Do:** justify any new dependency in one line; prefer the standard library.
**Don't:** add a dependency to save fewer than ~30 lines of code.

## R03 Every bug fix lands with a failing-then-passing test
**Why:** <the incident that created this rule, one line, dated>.
**Do:** write the test first, show it failing, then fix. Name it test_<bug-id>_<behavior>.
**Don't:** fix first and add a passing test after; it proves nothing.
**Check:** `./scripts/gate.sh` includes the test-count delta in its summary.

## R04 Public API changes update docs in the same change
**Do:** any change to a public signature or response shape updates docs/api.md in the same commit.

## R05 Long-lived documents are grepped, not read
**Do:** every entry in a decision log, backlog or changelog starts with a stable ID (D-123, B-45).
**Don't:** open these files whole; `grep -n 'D-123'`.

## R06 Absolute dates only
**Do:** write YYYY-MM-DD. "Next week" means nothing a month later.

## R07 Process budget
**Why:** <date>: half the month's commits touched no code.
**Do:** cap active rules at <25>. Adding one means retiring or merging one; note both in the change.
**Don't:** add a checker for a rule that has fired fewer than <3> times.
