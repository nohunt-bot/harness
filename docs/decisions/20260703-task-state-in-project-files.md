# Decision: Task state lives in project files, not conversation or central store

- Date: 2026-07-03
- Task: harness completeness audit (user goal: stable closed-loop long tasks)
- Status: accepted

## Context
The harness had plan/verify/record rules but no mechanism for a plan to survive
context compaction or a session restart — the exact failure DIAGNOSIS.md
focus-loss #2 describes. Multi-round iteration needs task state that outlives
the context window.

## Decision
Long-task state is a markdown file at `docs/tasks/<YYYYMMDD>-<slug>.md` inside
the target project, with a fixed five-section skeleton (criteria / plan /
progress log / decisions / open questions). Protocol: `rules/long-tasks.md`.

## Alternatives rejected
- Keep plans in conversation only — dies at compaction; the failure being fixed.
- Central store in `~/.claude` or this repo — rules and runtime state must not
  mix (LETTER.md #2); state wouldn't ride the project's own git history.
- Environment task-list tools as the only record — not portable across
  Claude Code / Codex / Hermes, not reviewable or diffable in git.

## Consequences
- Projects accumulate `docs/tasks/` files; `/retro` closes them
  (`Status: done`) so they read as history, not litter.
- Task state syncs across machines through the project's repo, for free.
- Revisit when: Claude Code ships durable cross-session task state natively.
