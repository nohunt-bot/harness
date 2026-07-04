#!/usr/bin/env bash
# SessionStart sentinel — warn when the harness repo has drifted from origin.
# Offline-safe: no network calls; "behind" compares against the last-fetched
# origin state. Silent when everything is clean. Never blocks (always exit 0).
set -uo pipefail

HARNESS_DIR="$(cd "$HOME/.claude/harness" 2>/dev/null && pwd -P)" || exit 0
git -C "$HARNESS_DIR" rev-parse --git-dir >/dev/null 2>&1 || exit 0

dirty=$(git -C "$HARNESS_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
ahead=$(git -C "$HARNESS_DIR" rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
behind=$(git -C "$HARNESS_DIR" rev-list --count HEAD..@{u} 2>/dev/null || echo 0)

msgs=""
[ "$dirty" != "0" ] && msgs="$dirty uncommitted change(s)"
[ "$ahead" != "0" ] && msgs="${msgs:+$msgs; }$ahead commit(s) not pushed"
[ "$behind" != "0" ] && msgs="${msgs:+$msgs; }$behind commit(s) behind last-fetched origin — consider git pull"

if [ -n "$msgs" ]; then
  echo "[harness-sync] $HARNESS_DIR: $msgs (fold fixes back into the repo — see LETTER.md 'fork drift')"
fi
exit 0
