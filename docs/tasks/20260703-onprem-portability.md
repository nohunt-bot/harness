# Task: Make the harness portable to an on-prem environment without Claude Code
Status: done (2026-07-03)

Context: the company environment cannot install the Claude Code binary
(user, 2026-07-03), so gateway reuse (path A) is out. Capabilities that
currently live in platform tools must move into repo scripts and prompt files.

## Acceptance criteria
1. `scripts/worktree.sh` creates and drops worktrees via plain git — exercised
   for real (create + drop on a repo, exit 0, `git worktree list` clean after),
   so the orchestrator pipeline no longer requires EnterWorktree/ExitWorktree.
2. `agents/orchestrator.md` runs in both worlds: uses the tools where they
   exist, falls back to the script elsewhere. No dead references.
3. `portability/base-system-prompt.md` exists and passes the reader test cold:
   an operator wiring an on-prem framework can act on it alone; every
   referenced path exists.
4. Protected change (single-model clause for `model-dispatch.md` §4) is a
   proposal in `docs/proposals/`, NOT applied.
5. Agent frontmatter tightened: code-judge read-only tools + TOP model,
   implementer no Agent tool + STANDARD model.
6. `./install.sh --check` exits 0 after all changes.
7. Fresh-context TOP-tier reviewer (templates/delegate-review.md) returns
   APPROVE on criteria 1–6.

## Plan
- [x] scripts/worktree.sh -> smoke test: create + drop on this repo, worktree list clean, branch deleted
- [x] orchestrator.md worktree-ops abstraction -> grep: every Enter/Exit mention covered; referenced paths exist
- [x] portability/base-system-prompt.md -> ls every referenced path; reviewer reader-test
- [x] agents frontmatter (code-judge, implementer) -> frontmatter fields verified against Claude Code agent spec by reviewer
- [x] docs/proposals/20260703-single-model-escalation.md (applied; now archive/proposals/) -> read-back matches MAINTENANCE proposal format (diff + reason)
- [x] README layout + cross-agent tables -> read-back
- [x] ./install.sh && ./install.sh --check -> exit 0
- [x] fresh-context review (TOP tier) -> APPROVE; findings fixed at author tier
- [~] commit + push; retro walk; Status: done

## Progress log
- 2026-07-03 | plan | task file created from approved direction (user picked non-Claude-Code path)
- 2026-07-03 | worktree.sh | smoke test pass: create -> WORKTREE path + branch existed; drop -> `git worktree list` single entry, branch deleted; exit 0
- 2026-07-03 | orchestrator.md | grep EnterWorktree/ExitWorktree -> only lines 20,23 (the mapping section); all steps reworded to abstract Enter/Exit
- 2026-07-03 | frontmatter | code-judge: tools Read,Glob,Grep + model opus; implementer: tools without Agent + model sonnet. Orchestrator left unrestricted — its failure loop must write docs/tasks/ retry counters (needs Edit/Write), restricting would break long-tasks integration
- 2026-07-03 | install | ./install.sh ran (worktree.sh auto-linked via scripts/*.sh glob); ./install.sh --check exit 0
- 2026-07-03 | refs | ls check on every path referenced by new files: all OK
- 2026-07-03 | review | fresh-context TOP-tier reviewer: APPROVE, all 6 criteria pass on its own runs (worktree.sh success+failure modes on a throwaway repo; frontmatter fields checked against official sub-agents doc; rules/ diff empty; secrets grep clean). 3 nits: slash-collision note added to worktree.sh header; drop-order nit = no change needed; task-file [~] pre-declaration fixed
- 2026-07-03 | closeout | decision record docs/decisions/20260703-portability-prompt-script-layer.md; lessons: none (no harness-misled incident); committed + pushed

## Decisions
- Worktree ops become an abstraction in orchestrator.md (tool if present, script otherwise) rather than replacing the tools outright — keeps Claude Code behavior unchanged. (minor, no record needed)
- Orchestrator tools NOT restricted (deviation from audit item 5): failure loop writes retry counters to docs/tasks/ files, which requires Edit/Write. (minor)

## Open questions
- (none — batched none)
