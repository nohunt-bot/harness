# Task: Close the verification loop — implementer self-verify, orchestrator re-dispatch, retry state in files, custom verify commands

Status: done (2026-07-03)

## Acceptance criteria

- implementer.md contains a verify-fix loop (cap: 2 fix rounds) and states the
  orchestrator gate remains the independent acceptance check.
- orchestrator.md has a failure loop: exactly one escalated re-dispatch with the
  full failure trail, reachable from both normal and complex paths.
- long-tasks.md plan notation carries per-step status and retry counts; the
  dispatch §4 cap is enforced from the file, not conversation memory.
- verify.sh accepts an optional custom verify command; exit 0 on pass, non-zero
  on fail — proven by real runs of both cases.
- No dead references introduced (every path/agent named in edited files exists).
- install.sh --check passes after the edits; CLAUDE.md untouched.
- Decision record written; all changes committed and pushed.

## Plan

- [x] Edit agents/implementer.md: add fix loop -> read-back + reference check
- [x] Edit agents/orchestrator.md: add failure loop + custom verify pass-through -> read-back + reference check
- [x] Edit rules/long-tasks.md: status/retry notation, routing row update -> read-back
- [x] Edit scripts/verify.sh: optional custom command -> run pass case (exit 0) and fail case (exit ≠0) in scratchpad
- [x] Cross-reference sweep (README, model-dispatch) -> grep for stale claims about the old behavior
- [x] Decision record in docs/decisions/ -> file exists, follows template
- [x] Fresh-context verifier checks criteria against actual file contents -> verifier report (retry: 1 — first verdict FIX-FIRST, fixes applied, re-check APPROVE)
- [x] install.sh --check + commit + push -> exit 0, git status clean, ahead 0 (commit follows this write; post-push git status is the evidence)

## Progress log

- 2026-07-03 | plan | task file created before first edit
- 2026-07-03 | implement | 4 files edited (agents/implementer.md, agents/orchestrator.md, rules/long-tasks.md, scripts/verify.sh)
- 2026-07-03 | verify | verify.sh: bash -n OK; custom-pass exit 0, custom-fail exit 1, no-runner exit 1 (scratchpad run)
- 2026-07-03 | verify | cross-ref grep: no stale "do not run tests" claims; remaining pipeline mentions still accurate
- 2026-07-03 | record | docs/decisions/20260703-subagent-verify-loop.md written
- 2026-07-03 | verify | fresh-context verifier: FIX-FIRST (1 should-fix, 2 nits) -> all 3 fixed -> re-check APPROVE; verify.sh retested (pass 0 / fail 1 / exit-code 3 propagated)
- 2026-07-03 | retro | done-check + quality floor passed; secrets grep: 1 false positive ("task-id" contains "sk-"); install.sh --check OK; closing at Status: done

## Decisions

- Verify loop closes inside implementer; gate stays with orchestrator → docs/decisions/20260703-subagent-verify-loop.md

## Open questions

- none
