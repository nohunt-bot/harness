#!/usr/bin/env python3
"""E24-E27: cost simulations over real harness file sizes.

Usage: python3 cost_sim.py [repo-root]
Costs are reported in bytes/~tokens (bytes/4), split by which context pays
them; dollar conversion depends on tier pricing and is deliberately left as a
parameter (R = TOP:CHEAP input-price ratio).
"""
import glob
import os
import re
import sys

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")


def read(p):
    with open(p, encoding="utf-8") as f:
        return f.read()


def rel(p):
    return os.path.relpath(p, ROOT)


MD = [p for pat in ("*.md", "rules/*.md", "pack/*.md", "templates/*.md",
                    "agents/*.md", "commands/*.md", "portability/*.md")
      for p in sorted(glob.glob(os.path.join(ROOT, pat)))]

# ---------------- E24 ----------------
print("== E24 simulated 10-phase long task: raw-dump vs delegate")
PHASES, TURNS, SUB_TURNS = 10, 6, 3
BASE = 4104                      # E02 resident overlay
ROUTED = 30500                   # E05 routed load, read once by commander
BULK = 8 * 4500                  # per-phase bulk read: 8 files x repo md mean
TPL = 1400                       # delegate template avg (E07)
REPORT = 1600                    # report-contract reply cap (~20 lines + hdr)

# commander input tokens: context is re-sent every turn (API billing model)
def commander_cost(per_phase_add):
    ctx, cost = BASE + ROUTED, 0
    for _ in range(PHASES):
        ctx += per_phase_add
        cost += ctx * TURNS
    return ctx, cost

ctx_x, cost_x = commander_cost(BULK)          # X: dumps land in commander
ctx_y, cost_y = commander_cost(TPL + REPORT)  # Y: only triple + report land
sub_cost = PHASES * (BULK + TPL) * SUB_TURNS  # Y: disposable subagent reads

print(f"  X raw-dump : final commander ctx {ctx_x:,} B (~{ctx_x//4:,} tok); "
      f"cumulative input {cost_x:,} B (~{cost_x//4:,} tok)")
print(f"  Y delegate : final commander ctx {ctx_y:,} B (~{ctx_y//4:,} tok); "
      f"cumulative input {cost_y:,} B (~{cost_y//4:,} tok)")
print(f"               + disposable subagent input {sub_cost:,} B "
      f"(~{sub_cost//4:,} tok) at CHEAP tier")
print(f"  commander savings: {(1 - cost_y / cost_x) * 100:.0f}%  | "
      f"same-tier total ratio Y/X: {(cost_y + sub_cost) / cost_x:.2f}")
print(f"  break-even TOP:CHEAP price ratio R where Y wins even if commander "
      f"were CHEAP too: R > {sub_cost / (cost_x - cost_y):.2f}")
tpl_total = PHASES * TPL
print(f"  template overhead: {tpl_total:,} B = "
      f"{tpl_total / (cost_x - cost_y) * 100:.1f}% of commander savings (H7)")

# ---------------- E25 ----------------
print("\n== E25 compression payoff: bytes x cross-repo references")
rows = []
for p in MD:
    name = os.path.basename(p)
    refs = 0
    for q in MD:
        if q == p:
            continue
        refs += read(q).count(name)
    size = os.path.getsize(p)
    rows.append((size * refs, size, refs, rel(p)))
for score, size, refs, name in sorted(rows, reverse=True)[:12]:
    print(f"  score={score:>7,}  {size:>6,} B x {refs:2d} refs  {name}")

# ---------------- E26 ----------------
print("\n== E26 CLAUDE.md 3072-byte budget by section")
text = read(os.path.join(ROOT, "CLAUDE.md"))
parts = re.split(r"(?m)^(## .*)$", text)
head = len(parts[0].encode())
print(f"  {head:>5} B  (preamble)")
for i in range(1, len(parts), 2):
    n = len((parts[i] + parts[i + 1]).encode())
    print(f"  {n:>5} B  {parts[i].strip()}")

# ---------------- E27 ----------------
print("\n== E27 mechanism-number drift sweep (every home, eyeball-diff)")
MECH = {
    "tripwire count": r"3 consecutive",
    "retry cap": r"[Tt]wo retry rounds",
    "CLAUDE.md byte cap": r"3\s?KB|3072",
    "LESSONS thresholds": r"30 entries",
    "receipt sha width": r"12-hex",
    "CHEAP strike": r"fails once|1 strike",
    "STANDARD strike": r"fails twice|2 strikes",
    "spot-check size": r"≥\s?2 cases|10%",
    "commander read limit": r"~?3 files|~?500 lines",
}
for label, rx in MECH.items():
    homes = []
    for p in MD:
        for ln, line in enumerate(read(p).splitlines(), 1):
            if re.search(rx, line):
                homes.append(f"{rel(p)}:{ln}")
    print(f"  {label}: {len(homes)} hits")
    for h in homes:
        print(f"      {h}")
