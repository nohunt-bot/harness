#!/bin/bash
# Install the dotfiles-claude harness on this machine.
# Idempotent: safe to re-run. Existing files are backed up, never deleted.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$CLAUDE_DIR/backups/harness-install-$STAMP"

mkdir -p "$CLAUDE_DIR" "$CLAUDE_DIR/agents"

backup() { # backup <path> — move a real file/dir aside (symlinks are ours, skip)
  local p="$1"
  if [ -e "$p" ] && [ ! -L "$p" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$p" "$BACKUP_DIR/$(basename "$p")"
    echo "  backed up: $p -> $BACKUP_DIR/"
  elif [ -L "$p" ]; then
    rm "$p"
  fi
}

link() { # link <repo-relative-source> <target>
  backup "$2"
  ln -s "$REPO_DIR/$1" "$2"
  echo "  linked: $2 -> $REPO_DIR/$1"
}

echo "== dotfiles-claude install (repo: $REPO_DIR) =="

# 1. Harness root symlink — all routed paths resolve through this
link "" "$CLAUDE_DIR/harness"

# 2. Always-loaded router
link "CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# 3. Global settings (symlinked so edits sync back into the repo)
link "settings.json" "$CLAUDE_DIR/settings.json"

# 4. Agents (individual links; leaves machine-local agents untouched)
for a in "$REPO_DIR"/agents/*.md; do
  link "agents/$(basename "$a")" "$CLAUDE_DIR/agents/$(basename "$a")"
done

# 5. MCP config from template (copied, not linked — expanded at runtime by Claude Code)
backup "$CLAUDE_DIR/mcp.json"
cp "$REPO_DIR/mcp.json.template" "$CLAUDE_DIR/mcp.json"
echo "  wrote: $CLAUDE_DIR/mcp.json (env-var references, no secrets)"

# 6. Retire the old always-loaded rules tree if present (token leak — see docs/DIAGNOSIS.md)
if [ -d "$CLAUDE_DIR/rules" ] && [ ! -L "$CLAUDE_DIR/rules" ]; then
  backup "$CLAUDE_DIR/rules"
  echo "  retired old ~/.claude/rules (restore from backup if needed)"
fi

# 7. Codex compatibility: same router as AGENTS.md if ~/.codex exists
if [ -d "$HOME/.codex" ]; then
  link "CLAUDE.md" "$HOME/.codex/AGENTS.md"
fi

# 8. Checks
echo "== checks =="
if [ -z "${OBSIDIAN_API_KEY:-}" ]; then
  echo "  WARN: OBSIDIAN_API_KEY not set — obsidian MCP will fail."
  echo "        Put it in ~/.claude/secrets.env and 'source' that file from your shell rc."
fi
command -v playwright-mcp >/dev/null 2>&1 || \
  echo "  WARN: playwright-mcp not on PATH — playwright MCP will fail on this machine."
[ -d "$BACKUP_DIR" ] && echo "  backups in: $BACKUP_DIR"
echo "== done =="
