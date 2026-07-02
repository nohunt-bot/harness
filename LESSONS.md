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
