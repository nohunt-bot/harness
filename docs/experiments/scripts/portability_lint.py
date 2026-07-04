#!/usr/bin/env python3
"""E11/E12/E14: portability lint over rule-bearing files and scripts.

Usage: python3 portability_lint.py [repo-root]
E11 - environment-specific term inventory (counts; classification is manual)
E12 - shell portability: bash -n, sh -n where sensible, macOS/GNU-only flags
E14 - capability-map coverage cross-ref
"""
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")

RULE_FILES = sorted(
    glob.glob(os.path.join(ROOT, p)) for p in (
        "CLAUDE.md", "MAINTENANCE.md", "rules/*.md", "pack/*.md",
        "templates/*.md", "agents/*.md", "commands/*.md",
        "portability/*.md"))
RULE_FILES = [p for group in RULE_FILES for p in group]

TERMS = {
    "model-names": r"\b(opus|sonnet|haiku|fable)\b",
    "vendor": r"\b[Aa]nthropic\b",
    "claude-code": r"Claude Code",
    "claude-other": r"\bClaude\b(?! Code)",
    "cc-tools": r"\b(EnterWorktree|ExitWorktree|Agent tool|plan-approval|Plan mode|plan mode)\b",
    "cc-config": r"(settings\.json|~/\.claude|SessionStart|PreToolUse)",
    "mcp": r"\bMCP\b|mcp\.json",
    "other-envs": r"\b(Codex|Hermes|Cursor)\b",
}

print("== E11 environment-specific term inventory (rule-bearing files)")
grand = {k: 0 for k in TERMS}
for p in RULE_FILES:
    with open(p, encoding="utf-8") as f:
        text = f.read()
    counts = {k: len(re.findall(rx, text)) for k, rx in TERMS.items()}
    if any(counts.values()):
        rel = os.path.relpath(p, ROOT)
        pretty = " ".join(f"{k}={v}" for k, v in counts.items() if v)
        print(f"  {rel}: {pretty}")
        for k, v in counts.items():
            grand[k] += v
print("  TOTALS: " + " ".join(f"{k}={v}" for k, v in grand.items()))

print("\n== E12 shell portability (scripts/*.sh hooks/*.sh install.sh)")
SH_PATTERNS = {
    "macOS-only stat -f": r"stat -f",
    "BSD in-place sed": r"sed -i ''",
    "BSD date -r (check fallback)": r"date -r ",
    "GNU-only stat -c (check fallback)": r"stat -c ",
    "readlink -f (GNU; macOS>=12.3 ok)": r"readlink -f",
}
shs = (sorted(glob.glob(os.path.join(ROOT, "scripts/*.sh")))
       + sorted(glob.glob(os.path.join(ROOT, "hooks/*.sh")))
       + [os.path.join(ROOT, "install.sh")])
for p in shs:
    rel = os.path.relpath(p, ROOT)
    syn = subprocess.run(["bash", "-n", p], capture_output=True)
    with open(p, encoding="utf-8") as f:
        text = f.read()
    shebang = text.splitlines()[0] if text else "?"
    flags = [name for name, rx in SH_PATTERNS.items() if re.search(rx, text)]
    print(f"  {rel}: bash-n={'OK' if syn.returncode == 0 else 'FAIL'} "
          f"shebang='{shebang}'"
          + (f" flags: {', '.join(flags)}" if flags else " flags: none"))

print("\n== E14 capability-map coverage "
      "(feature referenced in rules/pack -> row in portability map?)")
port = open(os.path.join(ROOT, "portability/base-system-prompt.md"),
            encoding="utf-8").read()
FEATURES = ["Agent tool", "EnterWorktree", "plan-approval", "hook",
            "settings.json", "MCP", "/retro", "/harness-health",
            "subagent", "worktree", "memory"]
core = [p for p in RULE_FILES if "/portability/" not in p]
for feat in FEATURES:
    users = [os.path.relpath(p, ROOT) for p in core
             if feat.lower() in open(p, encoding="utf-8").read().lower()]
    covered = feat.lower() in port.lower()
    if users:
        print(f"  {feat:>16}: referenced in {len(users):2d} files | "
              f"portability map mentions it: {'YES' if covered else 'NO'}")
