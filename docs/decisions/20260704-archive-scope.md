# Decision: referenced rationale docs stay in place; only resolved proposals move to archive/

- Date: 2026-07-04
- Task: docs/tasks/20260704-slimming.md
- Status: accepted

## Context
The slimming instruction said "historical narrative goes to archive". LETTER.md
and docs/DIAGNOSIS.md are historical narrative — but 8+ live rules (including
approval-gated install.sh and hooks/sync-sentinel.sh) cite them as rationale,
and neither is ever auto-loaded, so moving them saves zero tokens.

## Decision
Archive scope = resolved proposals only (docs/proposals/ → archive/proposals/,
referrers updated). LETTER.md, DIAGNOSIS.md, docs/tasks/, docs/decisions/ stay
in place; archive/README.md documents the boundary.

## Alternatives rejected
- Move LETTER/DIAGNOSIS + leave stubs — touches gated files for zero load
  savings; stubs are their own clutter.
- Move docs/tasks/ done files — pack/05 §4 forbids it; they are never loaded.

## Consequences
- `docs/proposals/` now has a clean invariant (OPEN only), enforced by
  harness-health step 8b.
- Revisit when: a referenced rationale doc stops being cited by any live rule
  — then it moves to archive/ with the normal ref-update sweep.
