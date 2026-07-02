# Task: Externalize Fable-5 judgment into a weak-model defense pack (.cursor/harness/) + mechanical enforcement

Status: done (2026-07-03)

## Acceptance criteria
1. `.cursor/harness/01–06` exist, each with complete content (no stubs), English,
   declaring source-of-truth precedence vs existing rules/ files.
2. New mechanisms (circuit breaker @3, receipt protocol, phase-commit freeze,
   taste boundary) each have exactly ONE canonical home; no rule restated in two homes.
3. `CLAUDE.md` rewritten ≤ 3072 bytes, backed up to `CLAUDE.md.bak` first; routes
   to the pack; no dead references.
4. `scripts/receipt.sh` exists, `bash -n` clean, run once for real (dogfood).
5. `hooks/resume-sentinel.sh` + settings.json SessionStart `resume|compact` entry
   (fail-soft, exit 0 always); settings.json backed up first.
6. Fresh-context adversarial reviewer finds no unresolved conflicts/dead paths.
7. Every deliverable claim in the final report carries a receipt.

## Plan
- [x] Task file created (this file) → receipt
- [x] A: `.cursor/harness/01_diagnostics.md` → receipt + reviewer
- [x] C: `.cursor/harness/02_orchestration.md` → receipt + reviewer
- [x] D: `.cursor/harness/03_rubrics.md` → receipt + reviewer
- [x] E: `.cursor/harness/04_templates.md` → receipt + reviewer
- [x] F: `.cursor/harness/05_maintenance.md` → receipt + reviewer
- [x] G: `.cursor/harness/06_manifesto.md` → receipt + reviewer
- [x] scripts/receipt.sh → bash -n + live run
- [x] hooks/resume-sentinel.sh + settings.json entry → bash -n + json valid (jq)
- [x] B: CLAUDE.md.bak backup → rewrite → wc -c ≤ 3072
- [x] Cross-links: README.md, rules/model-dispatch.md, rules/long-tasks.md, portability/base-system-prompt.md → grep-verify paths
- [x] Decision record: pack placement → file exists
- [x] Adversarial review (fresh subagent) → findings fixed
- [x] Read-back + receipts on all deliverables → final report

## Decisions
- Pack = weak-model operating layer; NEW mechanisms canonical in pack; existing
  rules distilled with "source wins on conflict" headers → docs/decisions/20260703-weak-model-pack-placement.md
- User parameters: tripwire=3 consecutive failures; fail-soft only; main
  battlefield = on-prem (scripts+git, not hooks); phase-commit freeze; receipts
  per Fable-5 discretion (long-task phases + any file-deliverable claim).

## Progress log
- 2026-07-03 | plan | task file created before first edit (long-tasks.md §1)
- 2026-07-03 | pack 01–06 written | receipts: 01 sha=9da1247d3860 b=8651 · 02 sha=8f637316c7a5 b=5901 · 03 sha=3354e82694c1 b=6531 · 04 sha=85f52d920003 b=6204 · 05 sha=4cd92a29d2c1 b=4569 · 06 sha=109a9f21b043 b=5907
- 2026-07-03 | scripts | receipt.sh + resume-sentinel.sh: bash -n OK; live run OK (missing-file exit 1; sentinel detected this task file, exit 0)
- 2026-07-03 | CLAUDE.md | backed up to CLAUDE.md.bak (sha=0487628c88d9); rewritten, wc -c = 3069 ≤ 3072
- 2026-07-03 | settings.json | backed up (backups/settings.json.bak-20260703); resume|compact SessionStart entry added; jq valid
- 2026-07-03 | cross-links | README ×3, model-dispatch §4, long-tasks §2, portability step 7; decision record written
- 2026-07-03 | adversarial review | fresh-context subagent: accept-with-fixes — 2 blockers (single-model retry arithmetic 2-vs-3 attempts; receipt scope narrower than CLAUDE.md), 9 should-fix, 8 nits; all receipts sha-verified (no theater)
- 2026-07-03 | fixes | all blockers + should-fixes + 6/8 nits applied (nit 18 CLAUDE.md.bak name = user-specified, accepted; nit "matcher regex unobserved live" = documented in 06 unfinished business). install.sh re-run: --check OK. CLAUDE.md 3057 ≤ 3072. Lesson appended (numeric drift). Retro step 3 (ritual audit) + harness-health step 2 (pack sweep) wired
- 2026-07-03 | final verify | receipts on all 22 deliverables exit 0; stale-ref sweep clean; git status = intended set only; backups gitignored
- 2026-07-03 | rename | `.cursor/harness/` → `pack/` (user decision: root visibility, tool-neutral name). All rule-bearing refs rewritten via sed + grep-verified; only intentional remnants: this file's history lines, decision-record Context, 06_manifesto Cursor-scenario note. Plan/criteria lines above kept as history — paths now read as `pack/`

## Open questions
- (none — user answered Q1–Q5 in conversation)
