# Proposal: cost-efficiency & portability actions from the 2026-07-04 autoresearch loop

Evidence: `docs/experiments/20260704-hypothesis-log.md` (27 experiments).
Per MAINTENANCE.md these four changes are approval-gated; nothing below is
applied. Self-serve items already applied in the same loop: receipt.sh
comment rot, 2 capability-map rows, anti-padding line in delegate-search.md.

## 1. Adopt the compressed pack 01 (−47.3% bytes, recall ↑)

**STATUS: APPROVED by user 2026-07-04 ("都處理") and APPLIED.** Live file =
5,867 B (−35.1%; provenance header + Scenario labels restored to keep
external references resolving). Validation before commit: n=5 haiku quiz on
the live file → 9, 8, 9, 10, 10 = **mean 9.2/10 strict** (≥9 threshold from
docs/decisions/20260704-experiment-methodology.md; original scored 7/10).
E27 drift sweep re-run: zero drift. Original backed up to
`backups/01_diagnostics.md.bak-20260704` (sha=0b65c29a48ae).

- **What**: replace `pack/01_diagnostics.md` (9,040 B) with the content of
  `docs/experiments/artifacts/pack01-compressed.md` (4,768 B), keeping the
  §-numbering and every mechanism/number identical (E27-style sweep re-run
  before commit; original backed up per hard rule).
- **Why**: E16/E17 — haiku scored 7/10 strict on the original but **10/10 on
  the compressed variant**; E25 ranks pack01 the #1 compression target
  (biggest file × 18 refs); saves ~1.1k tok per weak-model session. Density
  helps exactly the audience the pack targets.
- **Why gated**: pack01 is the canonical home of the three blockers
  (pack05 §1: mechanism-home edits need approval).
- **Risk/rollback**: content-equivalence is checkable (mechanism sweep +
  quiz); rollback = restore `pack/01_diagnostics.md.bak-<date>`.

## 2. Close the no-subagent fresh-context-verification hole (E15)

**STATUS: APPROVED by user 2026-07-04 ("批准 最差的情況是要使用 fresh context
進行驗證") and APPLIED — dispatch §6 (canonical clause), pack02 §6 (pointer),
judgment §2 (checklist note). Items 1/3/4 below remain pending.**

Three homes assume something can be spawned; on-prem no-subagent
environments have no defined way to satisfy "verification is never
self-verification":

- `rules/model-dispatch.md` §6 — add:
  > No-subagent environments: "fresh context" = a NEW session (or cleared
  > context) whose prompt contains ONLY the acceptance criteria, artifact
  > paths, and `scripts/receipt.sh` claims to re-check — never the author's
  > reasoning. The task file carries the handoff; same-session self-review
  > does not satisfy this section.
- `pack/02_orchestration.md` §6 — one pointer line to the above.
- `rules/judgment.md` §2 — extend the fresh-context checklist item with
  "(no-subagent env: fresh session per dispatch §6)".
- **Why gated**: report-contract/mechanism edit + judgment.md rubric touch.

## 3. Hooks: comment rot + shebang normalization (E11/E12)

**STATUS: APPROVED by user 2026-07-04 ("都處理") and APPLIED** — comment fix
in resume-sentinel.sh; `#!/usr/bin/env bash` in all 3 hooks + install.sh;
`bash -n` clean, hooks smoke-run exit 0, `install.sh --check` OK.

- `hooks/resume-sentinel.sh:3`: `.cursor/harness/01_diagnostics.md` →
  `pack/01_diagnostics.md` (comment-only; same rot already fixed self-serve
  in scripts/receipt.sh).
- `hooks/*.sh` + `install.sh`: `#!/bin/bash` → `#!/usr/bin/env bash`
  (matches scripts/, survives NixOS/BSD where /bin/bash may not exist).
- **Why gated**: hooks and install.sh are on the approval list, even for
  zero-behavior-change edits.

## 4. Anti-padding clause in the remaining templates + report contract (E22)

**STATUS: APPROVED by user 2026-07-04 ("都處理") and APPLIED** — clause added
to delegate-{review,refactor,implement}.md (delegate-research.md already had
an equivalent "Nothing else" line); report-contract sentence added to
`rules/model-dispatch.md` §5. All four proposal items are now closed.

- E22: a compliant CHEAP report was ~60% unrequested analysis — the
  contract caps dumps but not padding.
- Add the delegate-search.md anti-padding line (applied there self-serve) to
  `templates/delegate-{research,review,refactor,implement}.md`, and one
  sentence to `rules/model-dispatch.md` §5:
  > Reports contain the five sections and nothing else; unrequested analysis
  > is padding the commander pays for.
- **Why gated**: §5 is the report contract.

## Explicitly NOT proposed

- CLAUDE.md changes — E26 shows every section is router or hard rule; 26 B
  headroom; nothing droppable.
- Dedup between pack/ and rules/ — E06 refutes the premise (verbatim overlap
  ≤5.4%).
- agents/*.md frontmatter model names (E11) — Claude-Code-specific by
  design; other platforms ignore frontmatter (documented in the portability
  file's pipeline note). Accepted quirk.
