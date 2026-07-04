#!/usr/bin/env python3
"""E01-E10: harness context-footprint measurements.

Usage: python3 footprint.py [repo-root]
Token estimate = bytes/4 (relative comparison only).
"""
import glob
import os
import subprocess
import sys

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")


def b(path):
    p = os.path.join(ROOT, path)
    return os.path.getsize(p) if os.path.isfile(p) else None


def tok(n):
    return f"~{n // 4}tok"


def sizes(pattern):
    out = []
    for p in sorted(glob.glob(os.path.join(ROOT, pattern))):
        n = os.path.getsize(p)
        out.append((os.path.relpath(p, ROOT), n))
    return out


def show(eid, title, rows, total=True):
    print(f"\n== {eid} {title}")
    t = 0
    for name, n in rows:
        t += n
        print(f"  {n:>7} B {tok(n):>10}  {name}")
    if total and len(rows) > 1:
        print(f"  {t:>7} B {tok(t):>10}  TOTAL")


# E01
n = b("CLAUDE.md")
print(f"== E01 CLAUDE.md always-loaded: {n} B {tok(n)} | budget 3072 B -> "
      f"{'WITHIN' if n <= 3072 else 'OVER'} ({n - 3072:+} B)")

# E02 always-loaded overlay
overlay = [("CLAUDE.md", n)]
mem = os.path.expanduser(
    "~/.claude/projects/-Users-ch-dotfiles-claude/memory/MEMORY.md")
if os.path.isfile(mem):
    overlay.append(("MEMORY.md index", os.path.getsize(mem)))
for hook in ("hooks/resume-sentinel.sh", "hooks/sync-sentinel.sh"):
    hp = os.path.join(ROOT, hook)
    env = dict(os.environ, CLAUDE_PROJECT_DIR=ROOT)
    r = subprocess.run(["bash", hp], capture_output=True, env=env, text=True)
    overlay.append((f"{hook} stdout (exit {r.returncode})",
                    len(r.stdout.encode())))
show("E02", "always-loaded overlay (session start)", overlay)

# E03/E04/E07/E09
show("E03", "rules/*.md", sizes("rules/*.md"))
show("E04", "pack/*.md", sizes("pack/*.md"))
show("E07", "templates/*.md (per-dispatch overhead)", sizes("templates/*.md"))
show("E09", "agents/*.md (orchestrator pipeline load)", sizes("agents/*.md"))

# E05 long-task routed load
routed = ["CLAUDE.md", "pack/01_diagnostics.md", "rules/long-tasks.md",
          "rules/model-dispatch.md", "rules/judgment.md",
          "templates/delegate-search.md"]
show("E05", "long-task session routed load", [(p, b(p)) for p in routed])

# E10 maintenance-time load
show("E10", "maintenance-time load",
     [(p, b(p)) for p in ("MAINTENANCE.md", "pack/05_maintenance.md",
                          "README.md")])

# E06 pack<->rules verbatim restatement (8-word shingles, lower bound)
def shingles(text, k=8):
    words = text.split()
    return {" ".join(words[i:i + k]) for i in range(len(words) - k + 1)}


def read(p):
    with open(p, encoding="utf-8") as f:
        return f.read()


src_files = (sorted(glob.glob(os.path.join(ROOT, "rules/*.md")))
             + [os.path.join(ROOT, p) for p in
                ("CLAUDE.md", "MAINTENANCE.md")]
             + sorted(glob.glob(os.path.join(ROOT, "templates/*.md"))))
src_corpus = set()
for p in src_files:
    src_corpus |= shingles(read(p))

print("\n== E06 pack->source verbatim 8-word-shingle overlap (lower bound "
      "of restatement)")
for p in sorted(glob.glob(os.path.join(ROOT, "pack/*.md"))):
    sh = shingles(read(p))
    ov = len(sh & src_corpus) / len(sh) * 100 if sh else 0
    print(f"  {ov:5.1f}%  {os.path.relpath(p, ROOT)} ({len(sh)} shingles)")

# secondary indicator: mechanism-keyword co-occurrence (how many homes
# discuss each mechanism at all)
kws = ["TRIPWIRE", "receipt", "freez", "escalat", "delegation triple",
       "report contract", "taste", "compact"]
all_files = src_files + sorted(glob.glob(os.path.join(ROOT, "pack/*.md")))
print("\n   mechanism keyword -> #files mentioning it "
      "(semantic-redundancy indicator)")
for kw in kws:
    hits = [os.path.relpath(p, ROOT) for p in all_files
            if kw.lower() in read(p).lower()]
    print(f"   {kw:>18}: {len(hits):2d} files")
