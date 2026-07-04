# 01 — Diagnostics (COMPRESSED EXPERIMENT VARIANT — not a live rule file)

Experiment artifact for E17 (H5): pack/01_diagnostics.md compressed ~40%,
all mechanisms and numbers preserved. Canonical file: `pack/01_diagnostics.md`.
ADOPTED 2026-07-04 (proposal §1, n=5 validation mean 9.2/10): the live
pack/01_diagnostics.md now carries this content plus provenance header and
Scenario labels. This file stays as the frozen experiment record.

Audience: STANDARD-or-below models on long tasks. Precedence: `rules/`,
`MAINTENANCE.md`, `docs/DIAGNOSIS.md` win on conflict (conflict = bug: log in
LESSONS.md, fix the pack). The three §3 blockers are canonical HERE only.

## 1. Core finding

Prompt-space defenses decay exactly as the model decays; mechanical defenses
(scripts, git, permissions, hooks, exit codes) do not. Design test for every
harness change: prompt space or mechanical space? Prefer mechanical. On-prem
(no hooks) the only mechanical layer is scripts + git — §3 is plain bash + git.

## 2. Failure scenarios

1. **Tool-call collapse** — context growth loses tool schemas; the model
   pattern-matches params from stale examples; each error adds noise. Signs:
   same tool fails twice with different param guesses; errors pasted unread;
   unchanged retries. Blocker: TRIPWIRE §3.2 (counting, not self-awareness).
2. **Semantic drift** — compaction/restart discards mid-task context; the
   model re-derives plans from recollection and edits files done phases froze.
   Signs: re-checking things the progress log answers; edits no plan step
   names. Blockers: FREEZE §3.3 + resume ritual — after ANY context reset,
   read the active task file FIRST, trust its log over memory
   (`grep -l 'Status: active' docs/tasks/*.md` before the first edit).
3. **False completion** — the model narrates intended outcomes as done; weak
   models hallucinate success claims and read-backs alike. Signs: "I have
   written…" with no same-turn tool output; verification in future tense.
   Blocker: RECEIPT §3.1 (hashes are hard to hallucinate, cheap to re-check).

## 3. The three blockers (canonical)

### 3.1 RECEIPT
`bash ~/.claude/harness/scripts/receipt.sh <file> [...]` prints
`RECEIPT sha=<12-hex> bytes=<n> mtime=<ts> <path>` per file; exits non-zero on
missing/empty. Required: (a) every phase close — progress line carries the
receipts; (b) final report of any task claiming a file changed; (c) any
statement to the user that a file landed — receipt in the SAME turn, never
recalled from earlier. Claim without receipt = NOT DONE (hard rule).
Verifiers re-run receipt.sh; sha mismatch or MISSING = false completion —
report as an incident.

### 3.2 TRIPWIRE
Count 3 consecutive failed tool calls, or 3 failures of the same
call/subtask; tally lives in the task file (`TRIPWIRE n/3 <what>`), never in
memory. At 2 failures of the same call: re-read the schema/--help and change
something material before attempt 3. At 3: STOP the route; write a TRIPWIRE
line (3 attempts, exact errors, one-line hypothesis); change approach per
`rules/judgment.md` §4 or escalate (`02_orchestration.md` §4). Never attempt
#4 unchanged. Fail-soft: warn loudly, never hard-block. No route + user
absent = PARK: full state + TRIPWIRE to the task file, step marked `[!]`,
turn ends with a `WARNING:` banner. Parking is success; thrashing is failure.

### 3.3 PHASE-COMMIT FREEZE
Closing a plan step = one commit `phase(<task>): <step>`; uncommitted changes
= phase not closed. Files last touched by a done phase's `phase(` commit are
frozen (heuristic: `git log --oneline -1 -- <file>`; when unsure, treat every
file a done step names as frozen). Editing frozen files requires REOPEN
first: mark the step `[ ]` with one line of reason; re-run its verification
after. Ritual, not a block — but a phase diff touching files its step never
named is a scope violation (`rules/judgment.md` §5). Bonus: drift recovery =
`git revert`, not archaeology.

## 4. Top pain points → cuts

1. Raw dumps in the commander thread → delegate; findings to files;
   conclusions + `file:line` back; receipts replace pasted proof.
2. Prompt-only enforcement → the three blockers, all bash + git.
3. Wide MCP surface, complex schemas → prefer CLI/scripts; two-error schema
   re-read; batch-load schemas before first use.

## 5. Capability ceiling — taste

Decomposition + isolation + fresh-context verification reach near-TOP quality
only where correctness is checkable. They do NOT rescue taste (ambiguous
trade-offs, aesthetics, naming, architecture bets). In taste territory
(detection: `03_rubrics.md` §R4): do NOT decide — produce 2–3 genuinely
different options with one-line trade-offs + reversibility; user reachable →
ONE batched question; unattended → pick the most reversible, mark
`DECISION-PENDING(taste)` in task file + report, continue — never silently
settle it. Uncertain facts get checked; unfindable facts get `UNVERIFIED`,
never invented.
