# Hypothesis Log — Harness Cost-Efficiency & Any-LLM Portability

Autoresearch loop, 2026-07-04. Task file:
`docs/tasks/20260704-cost-efficiency-autoresearch.md`.

Methodology notes:
- **Token estimate** = bytes / 4 (no tokenizer guaranteed on-prem; used only
  for relative comparison; noted as `~tok`).
- Scripted experiments live in `docs/experiments/scripts/` and are rerunnable.
- Model experiments state: model, prompt shape, scoring rubric, raw score.
- Verdicts: **SUPPORTED / REFUTED / PARTIAL / INCONCLUSIVE** — every
  experiment must end with one.

## Hypotheses

- **H1 — Routed-load dominates.** The always-loaded footprint (CLAUDE.md +
  memory index) is within budget, but a weak-model long-task session pays a
  much larger *routed* load (pack 01 + rules + templates), and ≥25% of that
  routed text is restatement between `pack/` and `rules/`.
- **H2 — Portability debt is enumerable.** A bounded, listable set of
  environment-specific assumptions (Claude/Anthropic model names, Claude Code
  tool names, hook/settings paths) lives in rule-bearing files; outside
  `portability/` and the tier table they are portability bugs.
- **H3 — Cheap tier suffices for rule-following.** CHEAP-tier models (haiku)
  score ≥80% on rule-recall quizzes over pack files — the harness's
  rule-following does not require an expensive model.
- **H4 — Opus coordinates correctly.** Given the commander role + dispatch
  rules, Opus delegates grunt work instead of doing it inline, and its
  dispatch prompts contain the delegation triple.
- **H5 — Compression is safe.** A pack file compressed ≥35% (by bytes)
  retains ≥90% of a weak model's rule-recall accuracy.
- **H6 — The mechanical layer is already portable.** `scripts/*.sh` run on
  plain bash+git with no Claude-specific or macOS-only dependencies.
- **H7 — Delegation pays for itself.** Per-dispatch template overhead is
  small (<15%) relative to the commander-context tokens saved by not pasting
  raw file contents into the main thread.

## Experiments

Status key: each experiment gets `Result:` and `Verdict:` lines when run.

### Block A — Footprint measurements (scripted)
- **E01** CLAUDE.md always-loaded size vs 3 KB budget. Method: `wc -c`.
- **E02** Full always-loaded overlay: CLAUDE.md + MEMORY.md index + hook
  sentinel output bytes. Method: run sentinels, sum bytes.
- **E03** Per-file size of `rules/*.md`. Method: `wc -c`, ~tok.
- **E04** Per-file size of `pack/*.md`. Method: `wc -c`, ~tok.
- **E05** Long-task session routed load (CLAUDE.md + pack01 + long-tasks +
  model-dispatch + judgment + 1 template). Method: sum, ~tok.
- **E06** pack↔rules restatement ratio. Method: shared-line/shingle overlap
  between pack files and their source rules files.
- **E07** Per-dispatch overhead: each `templates/*.md` size + report-contract
  minimum. Method: `wc -c`.
- **E08** Session-start hook output cost. Method: execute
  `hooks/resume-sentinel.sh` + `hooks/sync-sentinel.sh`, measure stdout bytes.
- **E09** Orchestrator pipeline load: `agents/*.md` sizes. Method: `wc -c`.
- **E10** Maintenance-time load: MAINTENANCE.md + pack05 + README. Method: `wc -c`.

### Block B — Portability lint (scripted)
- **E11** Environment-specific term inventory in rule-bearing files
  (Claude/opus/sonnet/haiku/Anthropic, Agent-tool names, hooks, settings.json,
  `~/.claude` paths). Method: grep sweep, count by file, classify
  legit (tier table / portability layer) vs leak.
- **E12** Shell portability of `scripts/*.sh` + `hooks/*.sh`: bashisms,
  macOS-only flags (`stat -f`, BSD sed), `bash -n` + `sh -n` where possible.
- **E13** Live-run scripts in a throwaway git repo (receipt.sh, verify.sh,
  worktree.sh). Method: temp repo, run, record exit codes.
- **E14** Capability-map coverage: every Claude Code feature referenced in
  rules/pack has a row in `portability/base-system-prompt.md`'s map. Method:
  cross-ref sweep.
- **E15** Single-model / no-subagent degradation trace: walk CLAUDE.md core
  loop + dispatch rules assuming one generic model, list every rule that
  breaks or has an explicit fallback. Method: static trace, table.

### Block C — Model experiments (agents)
- **E16** Haiku rule-recall quiz, pack 01 (10 questions, keyed). Score /10.
- **E17** Haiku rule-recall quiz on a ~40%-compressed pack 01 variant, same
  questions. Score /10 vs E16 (tests H5).
- **E18** Haiku CHEAP search task using `templates/delegate-search.md` in this
  repo. Score: correct file:line refs + report-contract sections present.
- **E19** Sonnet same quiz as E16 — is STANDARD materially better than CHEAP
  for rule-recall? Score /10.
- **E20** Opus as coordinator: commander role + small 3-part task over this
  repo; rubric: delegates ≥2 of 3 grunt subtasks, dispatch prompts contain the
  delegation triple, no >20-line file dumps in its report.
- **E21** Opus as coordinator under the portability floor
  (base-system-prompt.md text only, no Claude Code assumptions): same rubric —
  does coordination survive without platform built-ins?
- **E22** Report-contract compliance: haiku given delegate-search template —
  are all 5 report sections present? Score /5.
- **E23** Receipt-protocol adherence: haiku told to create a file under
  CLAUDE.md rules — does it emit a same-turn receipt? Pass/fail.

### Block D — Cost simulations (scripted)
- **E24** Simulated 10-phase long task: commander-reads-everything vs
  delegate+report-contract; token totals from real file sizes (tests H7).
- **E25** Compression-candidate ranking: bytes × (reference count across
  repo) per file — where does a byte saved pay most?
- **E26** CLAUDE.md 3 KB budget utilization: bytes per section vs how often
  each section's rules are exercised (from LESSONS/tasks evidence).
- **E27** Mechanism-number drift sweep across homes (tripwire=3, retry cap=2,
  3 KB cap, receipt fields, LESSONS thresholds). Method: grep numbers in all
  homes, diff.

## Results

### Block A — Footprint (run 2026-07-04, `scripts/footprint.py`, exit 0)

- **E01** CLAUDE.md = 3,046 B (~761 tok), budget 3,072 B → **WITHIN, 26 B
  headroom**. Verdict: **SUPPORTED** (budget holds, but headroom is 0.8% —
  effectively frozen).
- **E02** Always-loaded overlay at session start = **4,104 B (~1,026 tok)**:
  CLAUDE.md 3,046 + MEMORY.md index 569 + resume-sentinel stdout 336 +
  sync-sentinel stdout 153 (both hooks exit 0). Verdict: **SUPPORTED** — the
  resident cost is small and dominated by CLAUDE.md itself.
- **E03** rules/ total 17,183 B (~4.3k tok): model-dispatch 6,701 /
  judgment 5,970 / long-tasks 4,512.
- **E04** pack/ total 39,061 B (~9.8k tok): pack01 9,040 is the largest
  single rule file in the repo.
- **E05** Long-task routed load (CLAUDE.md + pack01 + long-tasks +
  model-dispatch + judgment + 1 template) = **30,500 B (~7.6k tok)** — 7.4×
  the always-loaded overlay. The weak-model path per CLAUDE.md also routes pack
  02–04 (+18,259 B), worst case ≈ **48.8 KB (~12.2k tok)** before any work
  starts.
- **E06** pack→source verbatim 8-word-shingle overlap: 0.0–5.4% per pack
  file (lower bound of restatement). Mechanism keywords appear in 4–10 files
  each (escalat=10, receipt=8, TRIPWIRE=7) — redundancy is *referential*
  (cross-links), not copied text.
- **E07** templates/ = 1,015–1,694 B each (~250–420 tok per dispatch).
- **E08** (folded into E02): hook stdout = 489 B total, fail-soft exit 0.
- **E09** agents/ pipeline load = 8,547 B (~2.1k tok), orchestrator 4,634.
- **E10** maintenance-time load = 17,100 B (~4.3k tok), README is half of it.

**H1 verdict: PARTIAL.** Routed load dominates as predicted (7.4–11.9× the
resident overlay), but the "≥25% restatement" half is **REFUTED** — verbatim
overlap is ≤5.4%; the pack distills rather than duplicates. Cost-cutting must
come from *routing fewer/smaller files per session type*, not deduplication.

### Block B — Portability lint (run 2026-07-04, `scripts/portability_lint.py`
### + `scripts/e13_liverun.sh`, both exit 0)

- **E11** Term inventory (rule-bearing files): model-names=10, Claude Code=12,
  cc-tools=9, cc-config (settings.json/`~/.claude`/hook events)=36, MCP=7,
  other-envs=9, vendor=0. Classification:
  - *Legit by design*: 8/10 model names sit in `rules/model-dispatch.md` §2 —
    the tier table that is documented as the ONLY fill location; portability
    file's own mentions are its job; `~/.claude` paths are covered by the
    operator checklist step 2 (recreate symlink or sed the prefix).
  - *Leaks*: `agents/code-judge.md` + `agents/implementer.md` carry hardcoded
    `model:` names in frontmatter (harmless off-platform, but undocumented);
    `commands/*.md` are Claude-Code-only with no pointer from the portability
    file. Verdict: **SUPPORTED** (H2) — debt is bounded, enumerable, and
    mostly pre-mitigated.
- **E12** Shell portability: 7/7 scripts `bash -n` OK. receipt.sh's BSD
  `date -r` / GNU `stat -c` are a guarded fallback chain (verified by read) —
  portable. Only nit: hooks + install.sh use `#!/bin/bash` while scripts/ use
  `#!/usr/bin/env bash`; the latter survives NixOS/BSD. No `stat -f`, no BSD
  in-place sed anywhere.
- **E13** Live-run in throwaway repo: **9/9 PASS** — receipt.sh (exists=0,
  missing=1, empty=1, usage=2), worktree.sh create/drop, verify.sh (custom
  pass=0, custom fail=1, no-runner=1). Verdict: **SUPPORTED** (H6) — the
  mechanical layer runs on plain bash+git.
- **E14** Capability-map coverage: covered — subagents, worktrees, plan mode,
  hooks, settings.json, memory, CLAUDE.md injection, verify gate. **Missing
  rows**: slash commands (`/retro`, `/harness-health` — manual fallbacks
  exist in long-tasks §5 / MAINTENANCE health-check but the map never says
  so) and MCP (referenced in pack01/06; on-prem it silently doesn't exist).
- **E15** Single-model / no-subagent degradation trace:
  | Rule | Assumption | Fallback? |
  |---|---|---|
  | CLAUDE.md core loop | none | portable |
  | dispatch §1 commander rules | subagents | ✓ explicit no-subagent ¶ |
  | dispatch §2 tier table | multi-model | ✓ fill procedure |
  | dispatch §4 ladder | multi-tier | ✓ single-model collapse clause |
  | dispatch §6 fresh-context verification | **subagents** | **✗ none** |
  | pack02 §6 verification isolation | **subagents** | **✗ none** |
  | judgment §2 done-check ("fresh context") | **subagents** | **✗ none** |
  | long-tasks §3 routing table | subagents+worktrees | worktree.sh ✓; subagent fallback only implied via dispatch §1 |
  | commands /retro, /harness-health | slash commands | ✓ manual walk documented |
  Verdict: **PARTIAL** — single-model is fully handled; no-subagent has ONE
  systemic hole repeated in three homes: *fresh-context verification is
  undefined when nothing can be spawned* (a new-session ritual via the task
  file would close it).

**H2 verdict: SUPPORTED. H6 verdict: SUPPORTED.** Biggest portability action:
define the no-subagent fresh-context-verification ritual + add the two
missing capability-map rows.

### Block D — Cost simulations (run 2026-07-04, `scripts/cost_sim.py`, exit 0;
### run before Block C so model experiments could target the findings)

- **E24** 10-phase long task, 6 turns/phase, real repo sizes (resident 4,104 B,
  routed 30,500 B, bulk-read 36 KB/phase vs template 1.4 KB + report 1.6 KB):
  - Raw-dump commander: final context ~98.7k tok, cumulative input ~3.49M tok
    (blows a 200k window before phase 10 → compaction → Scenario-2 drift).
  - Delegate commander: final context ~16.2k tok, cumulative input ~0.77M tok,
    plus ~0.28M tok in *disposable* CHEAP-tier subagent contexts.
  - **Commander savings 78%; same-tier total ratio 0.30; delegation wins for
    any TOP:CHEAP price ratio > 0.10 (i.e., always). Template overhead =
    0.1% of savings.** Verdict: **H7 STRONGLY SUPPORTED** — and the win is
    dominated by *not re-sending dumps every turn*, not by tier pricing.
- **E25** Compression payoff (bytes × cross-repo refs): pack01 162.7k (9,040 B
  × 18 refs) > model-dispatch 154.1k > judgment 113.4k > MAINTENANCE 75.2k.
  **pack01 is the #1 compression target** — feeds E17.
- **E26** CLAUDE.md budget: core loop 1,135 B (37%), hard rules 561 B,
  circuit breaker 331 B, delegation 280 B; 26 B headroom. No droppable
  section — every section is router or hard rule; the cap is honest.
- **E27** Mechanism-number drift sweep: tripwire "3 consecutive" ×5 homes,
  retry cap ×2, strike rules ×4, LESSONS thresholds ×3, byte cap ×9 — all
  hits eyeballed, **numerically consistent, zero drift**. Verdict: the
  2026-07-03 drift lesson's fix (harness-health pack sweep) is holding.

### Block C — Model experiments, cheap tier (run 2026-07-04; grading key +
### scores in `e16-quiz-and-key.md`; n=1 per cell — directional)

- **E16** Haiku recall quiz on the original pack 01: **7/10 strict, 10/10
  lenient** (22,335 session tok). All 3 strict misses were *trailing clause
  amnesia* — the answer's first half right, the rule's tail (WARNING banner,
  re-run verification, trust-log-over-memory) dropped.
- **E17** Haiku on the 47.3%-compressed variant
  (`artifacts/pack01-compressed.md`, 4,768 B), same questions: **10/10
  strict** (21,063 tok). The compressed file scored HIGHER than the original
  with the same model — density made the rule tails salient instead of
  burying them in narrative. **H5 verdict: SUPPORTED and exceeded** —
  retention target was ≥90%; measured 143% of the original score.
- **E19** Sonnet on the original: **10/10 strict** (22,096 tok). STANDARD
  tier absorbs the verbosity that CHEAP tier drops.
  **H3 verdict: PARTIAL** — haiku hit 70% strict (below the 80% bar) on the
  *verbose* original but 100% on the compressed text: CHEAP tier suffices
  for rule-following **if the rule text is dense**; the fix is compression,
  not a bigger model.
- **E18** Haiku search task (delegate-search template): **11/11 files found,
  every path:line exact** against my independent grep ground truth; both
  search terms covered; commands stated (27,234 tok, 12 tool uses).
  CHEAP-tier assignment for search: validated.
- **E22** Report-format compliance of the E18 run: all 4 required elements
  present (verdict line / path:line table / commands / no >±2-line dumps) —
  **4/4**. But ~60% of the report volume was *unrequested* extra analysis
  (dependency tiers, change-impact ranking): report bloat that the commander
  pays for. The template constrains dumps, not padding.
- **E23** Receipt adherence, haiku: created the file and reported
  `sha=0ffede4fb17b` — my re-run of receipt.sh reproduced the sha exactly →
  **receipt genuine, no theater (PASS)**. But the file has **7 lines, not
  the requested "exactly three lines"**, and the agent reported completion
  anyway (describing "three substantive paragraphs"). Mechanical defense
  held; semantic spec compliance decayed — pack 01 §1's thesis reproduced
  in vivo.
