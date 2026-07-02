# To Future Sessions

Written 2026-07-03 by the session that built this harness, after auditing the
machine it was born on. Three things the user didn't ask about but that matter most
here, then how this system will most likely rot and how to stop it.

## Three things nobody asked

### 1. The real risk on this machine is secret sprawl across three agent systems
This Mac runs Claude Code, Hermes (`~/.hermes`), and potentially Codex — each with
its own config, permissions, and credentials. `~/.hermes/.env` is ~23 KB of
plaintext env vars; `auth.json` sits beside it; the Obsidian bearer token lived in
`~/.claude/mcp.json` for months and has passed through chat transcripts (including
the session that wrote this file). **Tell the user to rotate the Obsidian token**,
and treat any credential that ever appeared in a config file as exposed. When any
future task says "sync/backup my configs", the first step is a secrets sweep, not
an rsync.

### 2. Session state directories are more sensitive than the configs
`~/.claude/history.jsonl`, `projects/`, `sessions/`, `~/.hermes/state.db` (95 MB)
contain full conversation and task history — credentials, private plans, everything
the user ever pasted. They must never enter this repo or any cloud sync. The
`.gitignore` here assumes the repo only ever contains *rules*, not *state*. Keep it
that way: if a file in this repo starts accumulating runtime data, that's a design
error.

### 3. This harness only works if it is exercised, not just installed
The old setup failed not for lack of rules but because nothing enforced them: hooks
that never fired, agents that didn't exist, verification nobody ran. The single
highest-value habit for any future session: **when you dispatch, actually fill the
template; when you finish, actually run the verifier.** One real fresh-context
review is worth more than every checklist in `rules/`. If you're skipping the
templates because "this task is simple", fine — but then you also don't get to
claim harness-verified quality in your report.

## How this system will most likely degrade — and the countermeasures

**Most likely: accretion.** Every future session will be tempted to add "just one
more rule" to CLAUDE.md after an incident, and one more permission after a prompt.
Six months of that recreates exactly what `docs/DIAGNOSIS.md` describes: a 45 KB
context tax, contradictions, and an allowlist with `rm -rf` in it. The
countermeasures are already installed — the 3 KB cap, one-in-one-out, the lessons
lifecycle, the compaction threshold — but they only work if treated as hard rules.
When you feel the urge to append, that is the moment to delete instead.

**Second: fork drift.** Someone hot-fixes `~/.claude` directly on one device
instead of editing this repo, and three months later the devices disagree and
nobody knows which rule is real. Prevention: `~/.claude` files that this repo owns
are symlinks (see `install.sh`); if you find a real file where a symlink should be,
that's a fork — diff it, fold the changes back into the repo, re-link.

**Third: silent reference rot.** Models get renamed, agents get deleted, a plugin
disappears — and the rules keep referencing them, which is precisely the disease
this repo was built to cure. Prevention exists (`MAINTENANCE.md` health check) but
has no trigger. Run it monthly or whenever anything in the environment changes.
If the user sets up a scheduled task for it, the loop closes; suggest that when
the moment fits.

Trust the rubrics over your instincts on escalation and doneness — they were
written from this machine's actual failure history, not from theory.
