# Harness Diagnosis — 2026-07-03

Audit of the previous setup (`~/.claude` on this Mac). Every rule in this repo exists
to fix something on this list. When editing the harness, check your change against
this file first: do not reintroduce a listed failure mode.

## Top 3 token leaks

### 1. Duplicated and oversized always-loaded rules (~45 KB per session)
`~/.claude/rules/` injected `common/` + `web/` + `zh/` into every session. `zh/` was a
verbatim Chinese translation of `common/` — the same content loaded twice. Cost:
roughly 15–20k tokens burned before the first user message, shrinking the window
available for long tasks and diluting instruction-following.

**Fix (applied in this repo):** one slim always-loaded file (`CLAUDE.md`, < 3 KB) that
routes to on-demand files. Everything else is loaded only when its trigger fires.
Hard budget: always-loaded instruction content stays under 10 KB total. Before adding
a rule, delete or merge an old one.

### 2. Plugin skill sprawl (60+ skill descriptions resident in every session)
Eleven plugins (8× pm-skills, code-review, frontend-design, gopls) each register
skills whose descriptions sit in context permanently, even in sessions that never do
PM work.

**Fix:** keep only cross-cutting plugins enabled globally (`code-review`). Enable
domain plugins (pm-skills) per project in that project's `.claude/settings.json`, not
in the user-level settings.

**Applied 2026-07-03:** the 8 pm-skills plugins were removed from user-level
`settings.json`; the per-project enable pattern is documented in the README.

### 3. Commander doing grunt work in the main conversation
Bulk file reads, repo scans, and web research executed in the main thread fill the
window with raw dumps; auto-compaction then discards exactly the details long tasks
need.

**Fix:** delegation rules in [rules/model-dispatch.md](../rules/model-dispatch.md) —
bulk reading/scanning/research goes to subagents; only conclusions and `file:line`
references return to the main conversation.

## Top 3 focus-loss causes

### 1. Rules referencing tools that do not exist
`rules/common/agents.md` and friends instructed every session to use `planner`,
`tdd-guide`, `code-reviewer`, `security-reviewer`, and 6 more agents — none were
installed (only `orchestrator`, `implementer`, `code-judge` existed). The model
either wasted turns trying or learned to ignore rules wholesale. Unverifiable
instructions poison the credible ones.

**Fix:** rules may only reference agents, skills, and commands that exist in this
repo or ship with Claude Code. `MAINTENANCE.md` requires re-checking references
whenever agents change.

### 2. No plan or verification gates in long tasks
Nothing forced "plan → execute → verify" phases, so long tasks drifted: no acceptance
criteria stated up front, no check at the end, completion asserted by the same
context that wrote the code.

**Fix:** delegation triple (goal / acceptance criteria / report format) is mandatory
for every dispatched task — see [rules/model-dispatch.md](../rules/model-dispatch.md).
Verification is done by a fresh-context agent, never by the author
("verify-not-self").

### 3. Self-contradicting configuration
`settings.json` had `skipDangerousModePermissionPrompt: true` while the loaded
security rules said the opposite; `common/` and language rules overlapped with subtle
conflicts. Contradictions teach the model that rules are negotiable.

**Fix:** single source of truth. One rule lives in exactly one file; other files link
to it instead of restating it. Settings must never contradict a rule — if they do,
fixing that is a user-approval change (see `MAINTENANCE.md`).

## Top 3 error-prone spots

### 1. Standing permission for destructive commands
Project allowlist contained `Bash(rm -rf \\ *)`, `kill`, and dozens of one-off
historical commands promoted to permanent permissions, plus
`skipDangerousModePermissionPrompt` globally.

**Fix:** allowlists contain only stable, narrow, read-mostly patterns. Destructive
commands (`rm -rf`, `kill`, `git push --force`, resets) are never allowlisted; each
use is prompted. One-off approvals must not be persisted.

### 2. Secrets hardcoded in config that is about to be git-synced
The Obsidian MCP bearer token sat in plaintext in `~/.claude/mcp.json`. Syncing that
file across devices via git = credential leak.

**Fix:** `mcp.json.template` in this repo uses `${OBSIDIAN_API_KEY}`-style env
references. Real values live in an untracked local file (`~/.claude/secrets.env`,
gitignored pattern) loaded by the shell. `install.sh` verifies required vars exist.

### 3. Verification theater
The security-scan hook's npm-audit branch only fired when `--prefix` was present
(i.e., almost never), and there were no post-edit format/lint/test hooks at all —
so "checked" mostly meant "logged". Meanwhile agents graded their own work.

**Fix:** hooks must be tested with a real trigger before being trusted (see
`MAINTENANCE.md`); acceptance checks run real commands (tests, builds, read-backs)
by a fresh-context verifier, per [rules/judgment.md](../rules/judgment.md).
