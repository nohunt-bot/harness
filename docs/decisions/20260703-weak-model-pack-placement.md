# Decision: Weak-model defenses live in `pack/` as a pack with split canonical ownership

- Date: 2026-07-03
- Task: docs/tasks/20260703-weak-model-hardening.md
- Status: accepted

## Context
The user mandated six deliverable files at `.cursor/harness/01–06` to
externalize TOP-tier judgment before the environment drops to STANDARD-and-below
models permanently. But the harness constitution (MAINTENANCE.md prime
directive #2, one rule one home) forbids parallel rule systems, and most of the
requested content overlaps existing `rules/*.md` — duplication is the exact
disease documented in docs/DIAGNOSIS.md (token leak #1).

## Decision
`pack/` (repo root) is the weak-model operating pack — created at the mandated
`.cursor/harness/`, renamed to `pack/` the same day at the user's direction:
root visibility, tool-neutral name, and the "Pack NN" shorthand in CLAUDE.md
becomes self-describing. NEW mechanisms (tripwire
@3 fail-soft, receipt protocol, phase-commit freeze, per-tier strike rules,
pattern-to-script de-escalation, taste boundary) are canonical IN the pack;
pre-existing rules appear there only as distillations with explicit
"source file wins on conflict" headers. Source files gained one-line links into
the pack. Enforcement scripts are plain bash + git (`scripts/receipt.sh`,
phase commits) because the main battlefield (on-prem, user decision Q2) has no
hooks.

## Alternatives rejected
- Full parallel rule set inside the pack — guaranteed drift between two homes;
  recreates DIAGNOSIS.md failure #1.
- Keeping `.cursor/harness/` — hidden directory buries the on-prem PRIMARY
  rulebook, and the name implies Cursor-specific config while Cursor auto-loads
  only `.cursor/rules/*.mdc`; a name that lies invites wrong assumptions.
- Extend existing files only, no pack — violates the user's explicit deliverable
  paths, and gives the on-prem environment (which auto-loads nothing) no single
  entry document.
- Making the pack canonical for everything — would orphan `rules/*.md`, which
  agents/commands/README already reference; mass reference rewrite = rot risk.

## Consequences
- Weak models get one entry file (`01_diagnostics.md`) that routes everything.
- Drift between pack and sources is now a named bug with a check
  (`pack/05_maintenance.md` §3, wired into /harness-health step 2's
  reference-rot sweep).
- CLAUDE.md is at 3046/3072 bytes — minimal headroom; any future addition
  still requires an equal removal (by design).
- Revisit when: the on-prem toolchain is confirmed (if Cursor, add a
  `.cursor/rules/*.mdc` pointer — see 06_manifesto.md), or if a future model
  tier change makes the pack's thresholds wrong.
