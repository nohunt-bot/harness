# 01 — Diagnostics: How Weak-Model Sessions Fail Here, and the Blockers

Part of the weak-model pack (`pack/`). Written 2026-07-03 by Fable 5
(the last TOP-tier session on this harness) from a live audit. Audience: any
STANDARD-or-below model (Sonnet, Haiku, on-prem local models) running long tasks.

**Precedence**: for topics that also exist in `rules/`, `MAINTENANCE.md`, or
`docs/DIAGNOSIS.md`, those source files win on conflict — a conflict is a bug:
log it in `LESSONS.md` and fix the pack. The three **blockers** in §3 are NEW
mechanisms whose canonical spec lives HERE and nowhere else.
`docs/DIAGNOSIS.md` covers the pre-2026-07 setup's failures; this file covers
the model-degradation era that started after 2026-07-03.

## 1. The core finding: the enforcement pyramid is inverted

Almost every defense in this harness lives in *prompt space* — rules the model
must remember to follow. Prompt-space defenses decay at exactly the rate the
model decays: bigger context, weaker model → lower rule compliance, and that is
precisely when the rules are needed most. The only defenses that do NOT decay
with the model are **mechanical**: scripts, git, permissions, hooks, exit codes.

Design test for every future harness change: *"does this live in prompt space
or mechanical space?"* Prefer mechanical. A rule that cannot be checked by a
command will eventually be violated silently.

The main battlefield is the on-prem environment (no Claude Code binary, no
hooks — see `portability/base-system-prompt.md`). There, the ONLY mechanical
layer is scripts + git. Everything in §3 is therefore plain bash + git.

## 2. The three failure scenarios, reverse-engineered

### Scenario 1 — Tool-call collapse (wrong MCP params, consecutive errors)
- **Mechanism**: as context grows, the model loses tool schemas and starts
  pattern-matching parameters from stale examples. Each error dumps more noise
  into context, accelerating the decay. The model does not notice it is looping,
  because noticing is the capability that is degrading.
- **Early signs**: same tool fails twice with different parameter guesses;
  error text is pasted but not read; retries without changing anything.
- **Blocker**: TRIPWIRE protocol (§3.2) — hard counting, not self-awareness.

### Scenario 2 — Semantic drift (memory gone, edits completed code)
- **Mechanism**: compaction or session restart discards mid-task context. The
  model re-derives the plan from recollection, re-opens solved problems, and
  edits files that finished phases already froze.
- **Early signs**: "let me re-check how X works" on something the progress log
  already answers; edits touching files no current plan step names.
- **Blockers**: PHASE-COMMIT FREEZE (§3.3) + resume ritual — after ANY context
  reset ("continue", new session, post-compaction): read the active task file
  in `docs/tasks/` FIRST, trust its log over memory (`rules/long-tasks.md` §2).
  On Claude Code this is also injected by `hooks/resume-sentinel.sh`; on-prem
  the ritual is the only defense — run
  `grep -l 'Status: active' docs/tasks/*.md` before your first edit.

### Scenario 3 — False completion ("written" but no file landed)
- **Mechanism**: the model narrates the intended outcome instead of the tool
  result. Weak models hallucinate success claims exactly like any other token
  sequence; self-reported read-backs hallucinate the same way.
- **Early signs**: "I have written/updated…" with no tool output quoted in the
  same turn; verification described in future tense.
- **Blocker**: RECEIPT protocol (§3.1) — hashes are hard to hallucinate and
  cheap for a verifier to re-check.

## 3. The three blockers (canonical specs)

### 3.1 RECEIPT — no completion claim without a mechanical receipt
- Tool: `bash ~/.claude/harness/scripts/receipt.sh <file> [...]` (plain bash;
  on-prem use the cloned repo's `scripts/receipt.sh`). Prints
  `RECEIPT sha=<12-hex> bytes=<n> mtime=<ts> <path>` per file; exits non-zero
  on missing/empty files.
- **When required**: (a) every long-task phase close — the progress-log line
  includes receipts for files produced in that phase; (b) the final report of
  ANY task that claims a file was created or modified; (c) any standalone
  statement to the user that a file was created/changed — if you say it
  landed, receipt it in the same turn. Pure Q&A needs none.
- **Rules**: the receipt must be generated in the same turn as the claim —
  never recalled from earlier. A completion claim without a matching receipt is
  treated as NOT DONE (hard rule, `CLAUDE.md`). Verifiers re-run receipt.sh:
  sha mismatch or MISSING = false completion, report as an incident.

### 3.2 TRIPWIRE — circuit breaker at 3, fail-soft
- **Count**: 3 consecutive failed tool calls (any mix), OR 3 failures of the
  same call/subtask. In long tasks the tally lives in the task file's progress
  log as `TRIPWIRE n/3 <what failed>` lines — never in memory. Step-level
  `(retry: N)` marks stay reserved for failed step checks
  (`rules/long-tasks.md` §1).
- **At 2 failures of the same MCP/tool call**: before any third attempt,
  re-read the tool's schema or `--help`; change something material.
- **At 3**: STOP that route. Write a `TRIPWIRE` line (task file, or the report
  if no task file): the 3 attempts, exact error text, one-line hypothesis. Then
  route per `rules/judgment.md` §4 (change approach) or the ladder in
  `02_orchestration.md` §4. **Never attempt #4 unchanged.**
- **Fail-soft / unattended** (user decision 2026-07-03): tripwires warn loudly
  but never hard-block. If no alternative route exists and the user is absent:
  PARK — write full state + TRIPWIRE to the task file, set the step `[!]`, end
  the turn with a visible `WARNING:` banner. Parking is success; thrashing is
  the failure mode.

### 3.3 PHASE-COMMIT FREEZE — done code is frozen by git
- Closing a plan step in a long task = one commit:
  `phase(<task>): <step>` (`<task>` = the task-file slug). Uncommitted changes
  at phase close mean the phase is NOT closed.
- Files last touched by a `phase(...)` commit of a completed step are
  **frozen**. Before editing any file in a long task, if it belongs to a done
  phase (`git log --oneline -1 -- <file>` shows a `phase(` commit — a heuristic:
  a later non-phase commit can mask frozen status, so when unsure treat every
  file named by a done step as frozen), you must first REOPEN: mark that step `[ ]` again in the task file with one line of
  reason; the step's verification must be re-run afterwards. Fail-soft: this is
  a ritual, not a block — but a phase diff containing files its step never
  named is a scope violation (`rules/judgment.md` §5).
- Recovery bonus: drift becomes `git revert`, not archaeology.

## 4. Top-3 physical pain points in the current workflow (and the cut)

1. **Raw dumps in the commander thread** (biggest token leak; feeds Scenario
   2). Bulk reads/scans/research in the main conversation fill the window;
   compaction then deletes exactly the task memory a long task needs.
   → Cut: delegation rules (`02_orchestration.md` §1–2); findings go to files,
   conclusions + `file:line` come back; receipts replace pasted proof.
2. **Prompt-only enforcement** (feeds all three scenarios). Nothing counted
   errors, nothing froze done work, nothing checked claimed deliverables.
   → Cut: the three blockers in §3 — all runnable as plain bash + git on-prem.
3. **Wide MCP surface with complex schemas** (feeds Scenario 1). Registered
   surface exceeds the template (obsidian, playwright + account-level Gmail /
   Notion / Drive connectors); nested-parameter tools invite hallucinated args.
   → Cut: prefer CLI/scripts over MCP when both can do the job; apply §3.2's
   two-error schema re-read; batch-load tool schemas before first use instead
   of guessing.

## 5. Capability ceiling — where this harness cannot save a weak model

Decomposition + isolation + fresh-context verification gets a weak model near
TOP-tier quality ONLY where correctness is checkable: tests pass, file matches
spec, criteria enumerable. It does NOT rescue **taste**: ambiguous business
trade-offs, visual/UX aesthetics, naming that "reads well", architecture bets
under uncertainty. A weak model in taste territory produces confident mediocrity
that no checklist catches.

**Standard response when a task lands in taste territory** (detection checklist:
`03_rubrics.md` §R4):
1. Do NOT decide. Produce 2–3 genuinely different options, each with a
   one-line trade-off and a reversibility note.
2. If the user is reachable: batch the options into ONE question.
3. If unattended: pick the most reversible option, mark it
   `DECISION-PENDING(taste)` in the task file and the final report, and
   continue. Never silently upgrade a placeholder taste call into a settled
   decision — the marker survives until the user clears it.
4. Uncertain facts get checked (repo, docs, web); unfindable facts get marked
   `UNVERIFIED`, never invented.
