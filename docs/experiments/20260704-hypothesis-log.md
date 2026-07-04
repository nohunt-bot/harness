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

(appended per experiment as they run)
