# dotfiles-claude

Portable agent harness: rules, delegation templates, judgment rubrics, agents,
commands, skills, and config for Claude Code — synced across machines via this
git repo (`origin`: github.com/nohunt-bot/harness, private). Codex reads the
same router via an `AGENTS.md` link; Hermes is **not yet wired** (see
Cross-agent status).

Built 2026-07-03 from an audit of the previous setup; the failure modes it fixes
are documented in [docs/DIAGNOSIS.md](docs/DIAGNOSIS.md).

## Install on a new machine

```bash
# 1. Clone OUTSIDE any cloud-synced folder. iCloud/Dropbox corrupt git repos —
#    on a Mac with "Desktop & Documents" syncing, ~/Documents is iCloud. Use ~/.
git clone git@github.com:nohunt-bot/harness.git ~/dotfiles-claude

# 2. Install (idempotent; existing files are backed up, never deleted)
cd ~/dotfiles-claude && ./install.sh

# 3. Secrets — untracked env file, loaded from ~/.zshenv
#    (.zshenv, NOT .zshrc: hooks and non-interactive shells must see it too)
printf 'export OBSIDIAN_API_KEY="..."\n' > ~/.claude/secrets.env
chmod 600 ~/.claude/secrets.env
echo '[ -f ~/.claude/secrets.env ] && source ~/.claude/secrets.env' >> ~/.zshenv

# 4. Dependencies: jq (required by hooks), @playwright/mcp (optional),
#    pip-audit (optional — enables the pip vulnerability warning in
#    hooks/security-scan.sh; without it the hook logs SKIP and allows):
#    brew install jq && npm i -g @playwright/mcp && brew install pip-audit

# 5. Verify
./install.sh --check
```

GUI-launched apps (Claude Desktop) don't read `~/.zshenv`. This machine's
`~/.zshenv` additionally pushes `OBSIDIAN_API_KEY` into launchd
(`launchctl setenv`) so GUI apps inherit it after the first terminal of a login
session — copy that block when a new machine uses the desktop app.

## Daily workflow across machines

- Harness edits happen **only in this repo**. The `~/.claude` files are
  symlinks, so "editing the live config" already edits the repo — commit and
  push the same day (`MAINTENANCE.md` prime directive #5).
- [hooks/sync-sentinel.sh](hooks/sync-sentinel.sh) runs at session start and
  warns when the repo is dirty, unpushed, or behind the last-fetched origin.
  Silent when clean; offline-safe (no network calls).
- `./install.sh --check` fails on fork drift — a real file where a symlink
  should be means someone hot-fixed `~/.claude` directly. Fold the change back
  into the repo, then re-run `./install.sh`.
- Run `/harness-health` monthly, or after any environment change (new machine,
  renamed models, added/removed agents).

## Layout

| Path | What | Always loaded? |
|------|------|----------------|
| `CLAUDE.md` | Router: core loop + hard rules (< 3 KB) | yes — keep it small |
| `rules/model-dispatch.md` | Tiers, delegation triple, escalation, report contract | on demand |
| `rules/judgment.md` | Rubrics: escalate / done / ask / change-course / quality floor | on demand |
| `rules/long-tasks.md` | Long-task loop: task files, phase gates, iteration, retro | on demand |
| `templates/` | Fill-in delegation prompts + decision-record format | on demand |
| `agents/` | orchestrator → implementer(s) → code-judge worktree pipeline | registered |
| `scripts/verify.sh` | Verification gate the orchestrator runs per worktree | on demand |
| `scripts/worktree.sh` | Portable Enter/Exit worktree (plain git) for non-Claude-Code envs | on demand |
| `portability/base-system-prompt.md` | System-prompt floor + wiring checklist for non-Claude-Code envs | other envs only |
| `commands/` | `/harness-health`, `/retro` + the eight `/product-*` commands | registered |
| `skills/product-playbook` | 0→1 product-planning skill (drives `/product-*`) | registered |
| `hooks/security-scan.sh` | PreToolUse gate on installs/clones | via settings |
| `hooks/sync-sentinel.sh` | SessionStart drift warning (dirty/unpushed/behind) | via settings |
| `mcp.json.template` | MCP source of truth — `install.sh` registers it via the CLI | at install |
| `MAINTENANCE.md` | Who may edit what; lessons lifecycle; health check | on demand |
| `LESSONS.md` | Incident log → rule changes | on demand |
| `LETTER.md` | Context for future sessions | read once |
| `docs/DIAGNOSIS.md` | Why every rule exists | reference |

## MCP servers

Registered by `install.sh` via `claude mcp add-json --scope user`, which writes
`~/.claude.json`. **A plain file at `~/.claude/mcp.json` is never read by
Claude Code** — that was the old bug (LESSONS.md 2026-07-03).
[mcp.json.template](mcp.json.template) is the cross-machine source of truth;
values stay `${ENV_VAR}` references, expanded by Claude Code at connect time.

- `obsidian` — `http://127.0.0.1:27123/mcp/`, loopback non-TLS. The HTTPS port
  (27124) serves a self-signed cert that Claude Code rejects; enable
  "Non-encrypted (HTTP) Server" in Obsidian's Local REST API plugin.
- `playwright` — needs `playwright-mcp` on PATH (`npm i -g @playwright/mcp`).

Verify with `claude mcp list` — registration alone is not evidence.

## Plugins & skills

Global (`settings.json`) carries only cross-cutting plugins: `code-review`,
`frontend-design`, `gopls-lsp`. Domain plugins are enabled per project — the
8 pm-skills plugins were removed from user scope on 2026-07-03 (they parked
~100 skill descriptions in every session; DIAGNOSIS token leak #2).

To use pm-skills in a project, add to that project's `.claude/settings.json`
(the marketplace is already known globally):

```json
{
  "enabledPlugins": {
    "pm-execution@pm-skills": true,
    "pm-product-discovery@pm-skills": true
  }
}
```

Enable only the plugins that project actually uses, not all eight.

## Permissions posture

`settings.json` ships a narrow read-only allowlist (git status/log/diff/show/
branch, ls, rg, grep, wc, readlink) and a deny list on secret material
(`secrets.env`, `.env*`, SSH keys, `*.pem`, Hermes credentials). Destructive
commands are never allowlisted — every use is prompted (hard rule, CLAUDE.md).
One-off approvals must not be promoted into the allowlist.

## Cross-agent status

| Agent | Status |
|-------|--------|
| Claude Code | Fully wired: symlinks, hooks, MCP, permissions. |
| Codex | Router linked to `~/.codex/AGENTS.md` when `~/.codex` exists — re-run `./install.sh` after installing Codex. Tier cells in `rules/model-dispatch.md` §2: fill after verifying with the env's own model list. |
| Hermes | **Not yet wired.** `~/.hermes/config.yaml` has its own instruction/skills mechanism; wiring means exposing `CLAUDE.md` through it and filling the Hermes tier cells. Until then, harness rules do not bind Hermes — don't assume they do. |
| On-prem / other frameworks | Wire per [portability/base-system-prompt.md](portability/base-system-prompt.md): inject that file + `CLAUDE.md` as the system prompt, map tools/permissions, fill a tier column. `verify.sh` and `worktree.sh` run anywhere with bash + git. |

## Secrets

No secrets are tracked here. Real values live in `~/.claude/secrets.env`
(untracked, `chmod 600`), sourced from `~/.zshenv`. Treat any credential that
ever appeared in a tracked file or a chat transcript as exposed — rotate it.

Never commit: session state (`history.jsonl`, `projects/`, `sessions/`),
`settings.local.json`, backups, or anything matching `.gitignore`. If a file in
this repo starts accumulating runtime data, that's a design error (LETTER.md).
