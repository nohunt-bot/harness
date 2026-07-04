# Decision: cheap directional experiments over statistical instrumentation for harness autoresearch

- Date: 2026-07-04
- Task: docs/tasks/20260704-cost-efficiency-autoresearch.md
- Status: accepted

## Context
The autoresearch loop needed ≥25 experiments measuring token cost and model
behavior, on a plan where agent spawns are the expensive path and on-prem
targets may have no tokenizer at all. Precision per experiment competed
directly with the number of experiments affordable.

## Decision
Token counts = bytes/4 estimates; model experiments n=1 per cell; grading by
the commander with mechanical checks (independent grep ground truth built
before dispatch, receipt.sh sha re-runs) wherever possible. Findings labeled
"directional, not statistical" in the log.

## Alternatives rejected
- Real tokenizer counts — adds a dependency the on-prem story can't assume;
  relative comparisons (the only use here) are insensitive to the constant.
- n≥5 repeated model runs per cell — 5× agent cost for confidence the
  decisions didn't need; every accepted action also has a non-statistical
  rationale (rot is rot; a 9/9 live-run pass is binary).
- Fresh-judge grading of quiz answers — an extra agent per grade; the key
  was written before dispatch, making grading mechanical enough.

## Consequences
- 27 experiments fit in one session; the log is rerunnable from
  `docs/experiments/scripts/`.
- The E16/E17 compression result (7/10 → 10/10) rests on single runs —
  treated as strong-direction, not proof; the proposal says so.
- Revisit when: a gated proposal (e.g. adopting compressed pack 01) is
  challenged — then rerun the deciding experiment at n≥5 before applying.
