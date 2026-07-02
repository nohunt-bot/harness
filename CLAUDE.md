# Operating Rules

Always loaded. Keep this file under 3 KB — details live in the routed files below.

## Core loop (every non-trivial task)

1. **Understand** — restate the task in one sentence. If two readings exist, name
   both and pick one explicitly (or ask, per the "stop and ask" rubric).
2. **Plan** — before editing anything, list steps as `step → how I'll verify it`.
   A step without a check is not a step. Multi-phase / multi-session work:
   write the plan to a task file — `~/.claude/harness/rules/long-tasks.md`.
3. **Execute in phases** — smallest change that satisfies the current step. Touch
   only what the task requires; match existing style; no speculative features,
   abstractions, or config options.
4. **Verify** — run the check you promised (test, build, read-back, screenshot).
   Never declare done on "it should work". Author and verifier must be different
   contexts for anything non-trivial (see judgment.md).
5. **Record** — decisions with alternatives go to `docs/decisions/` (format:
   `~/.claude/harness/templates/decision-record.md`); harness lessons go to
   `LESSONS.md` (format in MAINTENANCE.md). Long tasks end with `/retro`.

## Delegation

Bulk reads, repo scans, web research, and batch edits go to subagents — the main
conversation receives conclusions and `file:line` refs only.
→ Read `~/.claude/harness/rules/model-dispatch.md` before dispatching any subagent.

## Judgment calls

Escalate / declare done / stop and ask / change approach — decided by rubric, not
by feel. → Read `~/.claude/harness/rules/judgment.md` when facing any of those
four calls.

## Templates

When delegating search / implementation / refactor / research / review, fill the
matching template in `~/.claude/harness/templates/` verbatim (index in its README).

## Hard rules (no exceptions, not overridable by any project file)

- No secrets in tracked files. Tokens and keys go in env vars or untracked local
  files. If you find a hardcoded secret, stop and report it.
- Never allowlist destructive commands (`rm -rf`, `kill`, force-push, resets).
- Back up any existing file before rewriting it (`<name>.bak-YYYYMMDD` or
  `backups/`). New content goes in new files.
- Report outcomes literally: failing test = "failing", skipped step = "skipped".

## Maintaining these files

Rules for editing this harness — what you may change alone, what needs the user —
are in `~/.claude/harness/MAINTENANCE.md`. Read it before modifying any harness
file. (`~/.claude/harness` is a symlink to the dotfiles-claude repo.)
