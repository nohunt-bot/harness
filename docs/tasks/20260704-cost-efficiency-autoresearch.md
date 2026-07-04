# Task: Autoresearch loop — improve harness cost-efficiency + any-LLM portability (≥25 experiments, Opus-coordinator test)

Status: active (2026-07-04)

## Acceptance criteria
1. A hypothesis log exists (`docs/experiments/20260704-hypothesis-log.md`) with
   explicit hypotheses, ≥25 numbered experiments, each with method + result +
   verdict — no experiment left "planned".
2. At least one experiment runs Opus as the coordinator/commander role and
   scores its dispatch-rule compliance.
3. Cost-efficiency findings are quantified (token/byte numbers, not vibes) and
   converted into: applied self-serve changes (with receipts) and/or proposals
   in `docs/proposals/` for approval-gated changes (per MAINTENANCE.md).
4. Portability findings ("take this project anywhere with any LLM") are
   quantified: an inventory of environment-specific assumptions in rule-bearing
   files, plus verified-portable status for `scripts/*.sh`.
5. Every file-deliverable claim carries a same-turn receipt
   (`scripts/receipt.sh`).
6. Task ends with /retro: decision records for real alternatives, LESSONS if
   the harness misled, Status: done.

## Plan
- [x] P1: task file + hypothesis log skeleton (H1–H7, E01–E27 defined) → receipts on both files
- [x] P2: footprint measurements E01–E10 (always-loaded, routed, dispatch overhead) → measurement script exits 0; results + verdicts appended to log
- [x] P3: portability lint E11–E15 (env-specific term inventory, script portability, capability-map coverage) → script exits 0; results appended
- [ ] P4: cost simulations E24–E27 (delegate-vs-dump, compression ranking, budget utilization, drift sweep) → results appended
- [ ] P5: model experiments, cheap tier E16–E19 + E22–E23 (haiku/sonnet rule-recall, template compliance) → agent reports logged with scores
- [ ] P6: Opus-coordinator experiments E20–E21 → agent reports logged with compliance scores
- [ ] P7: synthesis — apply self-serve improvements, write proposals for gated ones → receipts + grep-verified references
- [ ] P8: retro — decision records, LESSONS, Status: done

## Progress log
- 2026-07-04 | plan | task file created before first edit (long-tasks.md §1)
- 2026-07-04 | P1 | task file sha=b13bf5d4eead b=2576 · hypothesis log sha=464ca6b88cf0 b=6009 — H1–H7, E01–E27 defined
- 2026-07-04 | P2 | footprint.py exit 0; E01–E10 logged. footprint.py sha=afd168573649 b=3882 · log sha=9bfdfff3cfa6 b=7918. H1=PARTIAL (routed load 7.4–11.9× resident; verbatim dup ≤5.4%)
- 2026-07-04 | P3 | portability_lint.py + e13_liverun.sh exit 0; E11–E15 logged. lint sha=b85d136a6dde b=3536 · e13 sha=9c3bb212ad5e b=1759 · log sha=1bcfcc20b7b5 b=11093. H2=SUPPORTED, H6=SUPPORTED (E13 9/9 PASS); systemic gap: no-subagent fresh-context verification undefined in 3 homes

## Decisions
- Token counts approximated as bytes/4 (no tokenizer guaranteed on-prem);
  fine for relative comparisons, methodology stated in the log.
- Agent-based experiments budgeted lean: haiku for recall/compliance tests,
  opus only for the coordinator tests the user explicitly asked for.

## Open questions
- (none yet — batching for the final report)
