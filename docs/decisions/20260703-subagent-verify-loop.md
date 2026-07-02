# Decision: Verification loop closes inside the implementer; orchestrator gets one re-dispatch round

- Date: 2026-07-03
- Task: harness evaluation against the user's orchestrator closed-loop spec
- Status: accepted

## Context
The pipeline dropped any worktree that failed the gate — a typo-level failure
discarded a whole implementation, and nothing re-planned after failure. The
user's orchestrator spec (2026-07-03) requires per-subtask verify-fix loops and
failure re-dispatch. Retry counts lived only in conversation context, so the
two-round cap of `model-dispatch.md` §4 did not survive compaction — violating
the harness's own "anything not written to a file is lost" principle.

## Decision
1. The implementer runs the verify command itself in a fix loop (cap: 2 fix
   rounds); the orchestrator still runs the gate independently before any merge
   (verify-not-self preserved: self-run tests are a development loop, the gate
   is acceptance).
2. On gate failure the orchestrator does exactly one escalated re-dispatch with
   the full failure trail, then stops and reports per `judgment.md` §4.
3. Plan-step status (`[ ]/[~]/[x]/[!]`) and `(retry: N)` counters are persisted
   in the task file (`rules/long-tasks.md`), making the §4 cap enforceable from
   the file rather than memory.
4. `verify.sh` accepts an optional custom verify command, so the pipeline also
   works in repos verified by lint/build/scripts instead of a detected test
   runner.

## Alternatives rejected
- `plan.json` central state machine (user's original spec) — already rejected
  by `20260703-task-state-in-project-files.md`; the markdown task file gains
  status/retry marks instead of a parallel JSON store.
- Keep the drop-on-fail pipeline — wastes whole implementations on mechanical
  failures; no closed loop, which was the point of the spec.
- Raise the retry cap from 2 to 3 (user's spec) — the 2-round cap plus tier
  escalation comes from this machine's failure history; same-tier third retries
  historically produce a third different wrong answer.

## Consequences
- Implementer reports now include verification status and fix rounds spent.
- Orchestrator failure reports carry both trails (original + re-dispatch).
- Revisit when: the pipeline has been exercised on a real task end-to-end — as
  of 2026-07-03 it has never run outside review.
