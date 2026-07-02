# Proposal: single-model degradation clause for the escalation ladder

Date: 2026-07-03
Status: awaiting user approval
Protected zone: escalation ladder in `rules/model-dispatch.md` §4
(MAINTENANCE.md "What requires the user's approval first").

## Reason

The company on-prem environment (see `docs/tasks/20260703-onprem-portability.md`)
cannot run Claude Code and will typically expose exactly one model. §4's
ladder assumes CHEAP/STANDARD/TOP all exist. §1 already covers no-subagent
environments, but nothing defines what "escalate" means when there is no
higher tier — an agent reading §4 there has no defined move after a failure,
which invites the exact failure mode the ladder exists to prevent (retrying
the same prompt indefinitely).

## Diff

Add one bullet to `rules/model-dispatch.md` §4, immediately before the
hard-cap bullet:

```diff
+- **Single-model environments** (every tier maps to the same model): the
+  ladder collapses to the retry cap. One retry with the full failure trail
+  in-prompt; a second failure on the same subtask counts as a TOP-tier
+  failure — stop retrying and apply `rules/judgment.md` §4 (change approach
+  or decompose further). "Escalate" never means a third run of the same
+  prompt.
```

## Cost

+6 lines in an on-demand file; no always-loaded growth. No behavior change in
any environment that has multiple tiers.
