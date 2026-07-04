# Lessons

Append-only incident log. Format and lifecycle rules: see `MAINTENANCE.md`.
Compact when > 30 entries or ~200 lines.

## 2026-07-03 — Rules referencing nonexistent agents poisoned the whole rule set
- What happened: previous harness instructed every session to use 10 agents
  (planner, tdd-guide, code-reviewer…) that were never installed.
- Root cause: rules were copied from a template repo without checking them against
  the actual environment; no reference-verification step existed.
- Rule change: applied — MAINTENANCE.md prime directive #3 (no dead references) and
  health-check step 2.

## 2026-07-03 — Duplicate always-loaded content burned ~15–20k tokens/session
- What happened: `rules/zh/` (verbatim translation of `rules/common/`) and both
  originals were injected into every session.
- Root cause: no budget for always-loaded content; adding felt free.
- Rule change: applied — CLAUDE.md < 3 KB cap + MAINTENANCE.md prime directive #1.

## 2026-07-03 — MCP config written to a path Claude Code never reads
- What happened: `~/.claude/mcp.json` sat there for months; `claude mcp list`
  showed neither server. The obsidian URL (TLS port 27124, self-signed cert) had
  never been exercised and didn't work either.
- Root cause: config "verified" by reading the file back, never by the consuming
  tool's own listing command — verification theater on the harness itself.
- Rule change: applied — install.sh registers servers via `claude mcp add-json`
  and `--check` verifies with `claude mcp get`; README documents the real config
  path (`~/.claude.json`).

## 2026-07-03 — Predicted fork drift materialized (stale security-scan.sh)
- What happened: the pre-harness `~/.claude/security-scan.sh` (old, buggier copy)
  sat beside the repo-owned hook; LETTER.md had predicted exactly this mode.
- Root cause: install.sh retired only `~/.claude/rules`, not other superseded
  files, and no mechanical drift check existed.
- Rule change: applied — install.sh retires superseded files (rules/,
  security-scan.sh, mcp.json) and `install.sh --check` fails on stale files and
  non-symlink drift; hooks/sync-sentinel.sh warns each session start.

## 2026-07-04 — Verdict-line counts drift from the itemized list (twice, two tiers)
- What happened: two search reports had correct itemized path:line tables but
  wrong file counts in the verdict line (opus: "9 files" vs 8 listed; haiku:
  "6 files" vs 7 listed) — E21 and the E22 rerun, same day.
- Root cause: the verdict line is composed from memory after the table is
  built; nothing forces a recount against the table.
- Rule change: applied — delegate-search.md acceptance criterion 5 (recount
  the table before sending). Commanders: trust the table, re-count the verdict.

## 2026-07-04 — Rename rot survived in script comments the rot sweep never covered
- What happened: the 2026-07-03 `.cursor/harness/` → `pack/` rename was
  grep-verified, yet `scripts/receipt.sh:3` and `hooks/resume-sentinel.sh:3`
  still pointed at the dead path a day later (found by experiment E11).
- Root cause: reference-rot sweeps (harness-health step 2) were scoped to the
  .md rule directories; comments in `scripts/` and `hooks/` were never in scope.
- Rule change: applied — harness-health step 2 now includes `scripts/*.sh` and
  `hooks/*.sh` comments; receipt.sh fixed same-day (commit c488c97), the hook
  comment fix is gated → docs/proposals/20260704-cost-efficiency-actions.md §3.

## 2026-07-03 — Pack distillation restated canonical numbers and drifted same-day
- What happened: the new weak-model pack restated the single-model retry clause
  and the receipt scope with different arithmetic than their canonical homes;
  caught pre-commit by the fresh-context adversarial review.
- Root cause: distillation had no numeric-drift check at write time — the
  one-home rule compared topics, not numbers.
- Rule change: applied — /harness-health step 2 now sweeps `pack/`
  and compares mechanism numbers across homes; drift rule clarified in
  `pack/05_maintenance.md` §3.
