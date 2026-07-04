#!/usr/bin/env bash
# E13: live-run the mechanical layer (receipt.sh, worktree.sh, verify.sh)
# in a throwaway git repo. Usage: e13_liverun.sh <harness-repo> <tmp-dir>
set -uo pipefail
HARNESS="${1:?harness repo path}"
TMP="${2:?tmp dir}"

R="$TMP/e13-repo"
rm -rf "$R" "$TMP/.e13-repo-worktrees"
mkdir -p "$R"
git -C "$R" init -q -b main
echo hello > "$R/a.txt"
git -C "$R" -c user.email=e@x -c user.name=e13 add -A
git -C "$R" -c user.email=e@x -c user.name=e13 commit -qm init

run() { # run <label> <expected-exit> <cmd...>
  local label="$1" want="$2"; shift 2
  "$@" >/dev/null 2>&1
  local got=$?
  [ "$got" -eq "$want" ] && echo "  PASS ($got=$want) $label" \
                         || echo "  FAIL (got $got want $want) $label"
}

echo "== E13 live-run in $R"
run "receipt.sh existing file"      0 bash "$HARNESS/scripts/receipt.sh" "$R/a.txt"
run "receipt.sh missing file"       1 bash "$HARNESS/scripts/receipt.sh" "$R/nope.txt"
: > "$R/empty.txt"
run "receipt.sh empty file"         1 bash "$HARNESS/scripts/receipt.sh" "$R/empty.txt"
run "receipt.sh no args (usage)"    2 bash "$HARNESS/scripts/receipt.sh"

WT=$(bash "$HARNESS/scripts/worktree.sh" create "$R" e13/branch 2>/dev/null | sed -n 's/^WORKTREE=//p')
[ -n "$WT" ] && [ -d "$WT" ] && echo "  PASS worktree.sh create -> $WT" \
             || echo "  FAIL worktree.sh create"
run "verify.sh custom cmd pass"     0 bash "$HARNESS/scripts/verify.sh" "$WT" "true"
run "verify.sh custom cmd fail"     1 bash "$HARNESS/scripts/verify.sh" "$WT" "false"
run "verify.sh no runner detected"  1 bash "$HARNESS/scripts/verify.sh" "$WT"
run "worktree.sh drop (+branch)"    0 bash "$HARNESS/scripts/worktree.sh" drop "$R" "$WT" e13/branch

rm -rf "$R" "$TMP/.e13-repo-worktrees"
echo "== E13 done"
