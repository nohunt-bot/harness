---
description: Audit the harness — symlinks, MCP, reference rot, secrets, lessons, sync state — and report per the report contract
---

Run the dotfiles-claude harness health check. Execute every step; report evidence,
not impressions. The harness lives at `~/.claude/harness` (a symlink to the repo).

1. **Mechanical check**: run `bash ~/.claude/harness/install.sh --check`. It covers
   symlink integrity/fork drift, MCP registration, the CLAUDE.md 3 KB cap, and
   stale superseded files. Include its output verbatim.
2. **Reference rot**: grep `rules/`, `templates/`, `agents/`, `commands/` for
   referenced paths, agent names, and commands; verify each referenced thing
   exists (`ls` the path, check the agent/skill file). Rules may only reference
   things that exist — see `docs/DIAGNOSIS.md` focus-loss #1.
3. **Settings vs rules contradictions**: read `settings.json`; flag anything that
   contradicts a rule (DIAGNOSIS focus-loss #3). Permissions must contain no
   destructive allowlist entries (`rm -rf`, `kill`, force-push, resets).
4. **Secrets in tracked files**: `git -C ~/.claude/harness grep -inE 'bearer [a-z0-9]|key.*=.*[A-Za-z0-9]{16}|ghp_|sk-'` —
   review hits. References like `${OBSIDIAN_API_KEY}` are fine; literal values are
   an incident (stop and report).
5. **Lessons lifecycle**: is `LESSONS.md` over the compaction threshold (>30
   entries or ~200 lines)? Any lesson with "Rule change: none" recurring? If yes,
   compact/promote per `MAINTENANCE.md`.
6. **Tier-table blanks**: are the Codex/Hermes cells in
   `rules/model-dispatch.md` §2 still blank while `~/.codex` or `~/.hermes`
   exists and is in use? If the environment exists, fill per the self-serve rule
   (run its own model-listing command first).
7. **Sync state**: `git -C ~/.claude/harness fetch --quiet` then
   `git -C ~/.claude/harness status -sb` — report dirty/ahead/behind. Uncommitted
   harness edits are fork drift in progress: fold them into a commit or revert.

Report using the report contract in `rules/model-dispatch.md` §5: verdict line,
evidence per step (pass/fail + proof), references as `file:line`, open issues.
Fixes that are self-serve per `MAINTENANCE.md` ("What you may change without
asking"): apply, commit, and note the commit id. Anything else: write a proposal
to `docs/proposals/<date>-<slug>.md` and list it under open issues.
