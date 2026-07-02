# dotfiles-claude

Portable agent harness: rules, delegation templates, judgment rubrics, agents, and
config for Claude Code — reusable across machines, and readable by other agent CLIs
(Codex via `AGENTS.md` link; Hermes can point its system-prompt include at
`CLAUDE.md`).

Built 2026-07-03 from an audit of the previous setup; the failure modes it fixes
are documented in [docs/DIAGNOSIS.md](docs/DIAGNOSIS.md).

## Install on a new machine

```bash
git clone <this-repo> ~/Documents/dotfiles-claude
cd ~/Documents/dotfiles-claude && ./install.sh
# then create ~/.claude/secrets.env with the required env vars (see below)
```

`install.sh` is idempotent; existing files are backed up to
`~/.claude/backups/harness-install-<timestamp>/`, never deleted.

## Layout

| Path | What | Always loaded? |
|------|------|----------------|
| `CLAUDE.md` | Router: core loop + hard rules (< 3 KB) | yes — keep it small |
| `rules/model-dispatch.md` | Tiers, delegation triple, escalation, report contract | on demand |
| `rules/judgment.md` | Rubrics: escalate / done / ask / change-course / quality floor | on demand |
| `templates/` | Fill-in delegation prompts (search/implement/refactor/research/review) | on demand |
| `agents/` | orchestrator → implementer(s) → code-judge worktree pipeline | registered |
| `hooks/security-scan.sh` | PreToolUse gate on installs/clones | via settings |
| `MAINTENANCE.md` | Who may edit what; lessons lifecycle; health check | on demand |
| `LESSONS.md` | Incident log → rule changes | on demand |
| `LETTER.md` | Context for future sessions | read once |
| `docs/DIAGNOSIS.md` | Why every rule exists | reference |

## Secrets

No secrets are tracked here — `mcp.json.template` uses `${VAR}` references that
Claude Code expands at runtime. Keep real values in `~/.claude/secrets.env`
(untracked) and source it from your shell rc:

```bash
# ~/.claude/secrets.env
export OBSIDIAN_API_KEY="..."
```

Never commit: session state (`history.jsonl`, `projects/`, `sessions/`),
`settings.local.json`, or anything matching `.gitignore`.

## Trimming candidates

The 8 pm-skills plugins are enabled globally in `settings.json` for convenience.
If session context feels crowded, move them to per-project
`.claude/settings.json` files instead (see DIAGNOSIS token leak #2).
