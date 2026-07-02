#!/bin/bash
# Install the dotfiles-claude harness on this machine.
# Idempotent: safe to re-run. Existing files are backed up, never deleted.
#
# Usage:
#   ./install.sh          install/repair symlinks + MCP registration
#   ./install.sh --check  verify only (no changes); exit 1 on any drift
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$CLAUDE_DIR/backups/harness-install-$STAMP"
MODE="${1:-install}"

# Every symlink this repo owns, as "repo-relative-source|absolute-link" pairs.
# --check and install both derive from this list — keep it the single source.
expected_links() {
  echo "|$CLAUDE_DIR/harness"
  echo "CLAUDE.md|$CLAUDE_DIR/CLAUDE.md"
  echo "settings.json|$CLAUDE_DIR/settings.json"
  for f in "$REPO_DIR"/agents/*.md; do
    [ -e "$f" ] || continue; echo "agents/$(basename "$f")|$CLAUDE_DIR/agents/$(basename "$f")"
  done
  for f in "$REPO_DIR"/scripts/*.sh; do
    [ -e "$f" ] || continue; echo "scripts/$(basename "$f")|$CLAUDE_DIR/scripts/$(basename "$f")"
  done
  for f in "$REPO_DIR"/commands/*.md; do
    [ -e "$f" ] || continue; echo "commands/$(basename "$f")|$CLAUDE_DIR/commands/$(basename "$f")"
  done
  for d in "$REPO_DIR"/skills/*/; do
    d="${d%/}"; [ -d "$d" ] || continue; echo "skills/$(basename "$d")|$CLAUDE_DIR/skills/$(basename "$d")"
  done
}

# ── verify-only mode ─────────────────────────────────────────────────────────
if [ "$MODE" = "--check" ]; then
  fail=0
  while IFS='|' read -r src link; do
    want="$REPO_DIR/$src"
    if [ ! -L "$link" ]; then
      echo "DRIFT: $link is not a symlink (fork? see LETTER.md)"; fail=1
    elif [ "$(readlink "$link")" != "$want" ] && [ "$(readlink "$link")" != "${want%/}/" ]; then
      echo "DRIFT: $link -> $(readlink "$link") (expected $want)"; fail=1
    elif [ ! -e "$link" ]; then
      echo "DANGLING: $link"; fail=1
    fi
  done < <(expected_links)

  size=$(wc -c < "$REPO_DIR/CLAUDE.md" | tr -d ' ')
  if [ "$size" -ge 3072 ]; then echo "FAIL: CLAUDE.md is ${size}B (cap 3072)"; fail=1; fi

  if command -v claude >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    for name in $(jq -r '.mcpServers | keys[]' "$REPO_DIR/mcp.json.template"); do
      claude mcp get "$name" >/dev/null 2>&1 || { echo "MISSING: MCP server '$name' not registered (run ./install.sh)"; fail=1; }
    done
  fi

  # Files Claude Code never reads, or that this harness superseded — must be gone.
  for stale in "$CLAUDE_DIR/mcp.json" "$CLAUDE_DIR/security-scan.sh"; do
    [ -e "$stale" ] && { echo "STALE: $stale should not exist"; fail=1; }
  done

  if [ "$fail" -eq 0 ]; then echo "check: OK"; else echo "check: FAILED"; fi
  exit "$fail"
fi

# ── install mode ─────────────────────────────────────────────────────────────
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
mkdir -p "$CLAUDE_DIR" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/scripts" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/skills"

# 1. Symlinks — harness root, router, settings, then per-file links for
#    agents/scripts/commands and per-directory links for skills.
#    Individual links leave machine-local files in the same dirs untouched.
while IFS='|' read -r src linkpath; do
  link "$src" "$linkpath"
done < <(expected_links)

# 2. MCP servers — registered via the claude CLI into ~/.claude.json.
#    A plain file at ~/.claude/mcp.json is NEVER read by Claude Code; that was
#    the old bug (see LESSONS.md 2026-07-03). mcp.json.template stays the
#    cross-machine source of truth; values use ${ENV_VAR} references.
if command -v claude >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  for name in $(jq -r '.mcpServers | keys[]' "$REPO_DIR/mcp.json.template"); do
    if claude mcp get "$name" >/dev/null 2>&1; then
      echo "  mcp: $name already registered"
    else
      claude mcp add-json "$name" "$(jq -c --arg n "$name" '.mcpServers[$n]' "$REPO_DIR/mcp.json.template")" --scope user >/dev/null
      echo "  mcp: registered $name (user scope, ~/.claude.json)"
    fi
  done
else
  echo "  WARN: claude CLI or jq missing — MCP registration skipped; re-run install.sh after installing them."
fi

# 3. Retire files this harness superseded (backed up, never deleted):
#    - old always-loaded rules tree (token leak — docs/DIAGNOSIS.md #1)
#    - pre-harness security-scan.sh copy at ~/.claude root (fork drift)
#    - ~/.claude/mcp.json (dead config — never read by Claude Code)
for stale in "$CLAUDE_DIR/rules" "$CLAUDE_DIR/security-scan.sh" "$CLAUDE_DIR/mcp.json"; do
  if [ -e "$stale" ] && [ ! -L "$stale" ]; then
    backup "$stale"
    echo "  retired: $stale (restore from backup if needed)"
  fi
done

# 4. Codex compatibility: same router as AGENTS.md if ~/.codex exists.
#    (Installed Codex later? Just re-run this script.)
if [ -d "$HOME/.codex" ]; then
  link "CLAUDE.md" "$HOME/.codex/AGENTS.md"
fi

# 5. Environment checks
echo "== checks =="
command -v jq >/dev/null 2>&1 || \
  echo "  WARN: jq missing — REQUIRED by hooks/security-scan.sh (brew install jq)."
if [ -z "${OBSIDIAN_API_KEY:-}" ]; then
  echo "  WARN: OBSIDIAN_API_KEY not set — obsidian MCP will fail."
  echo "        Put it in ~/.claude/secrets.env and source that file from ~/.zshenv"
  echo "        (not .zshrc — non-interactive shells must see it too)."
fi
command -v playwright-mcp >/dev/null 2>&1 || \
  echo "  WARN: playwright-mcp not on PATH — playwright MCP will fail on this machine."
[ -d "$BACKUP_DIR" ] && echo "  backups in: $BACKUP_DIR"
echo "== done =="
echo "verify anytime: ./install.sh --check"
