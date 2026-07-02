# Decision: portability via a prompt+script layer over rewriting the harness for one target

- Date: 2026-07-03
- Task: docs/tasks/20260703-onprem-portability.md
- Status: accepted

## Context

The company on-prem environment cannot install the Claude Code binary, ruling
out gateway reuse (ANTHROPIC_BASE_URL → internal model), which would have
reused the harness unchanged. Several capabilities lived only in platform
tools (EnterWorktree/ExitWorktree, built-in system prompt, settings.json
permissions), invisible to any other framework.

## Decision

Add a portable layer instead of forking or restructuring: a base system
prompt (`portability/base-system-prompt.md`) supplying the agentic floor
Claude Code normally injects, a plain-git worktree script
(`scripts/worktree.sh`), and an abstract Enter/Exit mapping in
`agents/orchestrator.md` (tool if present, script otherwise).

## Alternatives rejected

- Extend `CLAUDE.md` with the floor rules — protected zone, and it would grow
  the always-loaded footprint for every environment to serve one.
- Replace EnterWorktree/ExitWorktree with the script outright — changes
  proven Claude Code behavior to serve an environment that isn't live yet.
- Fork a stripped harness repo for the company env — guarantees rule drift;
  DIAGNOSIS exists because divergent copies rot.

## Consequences

- Any bash+git environment can run the full orchestrator → implementer →
  verify pipeline; Claude Code behavior is unchanged.
- The single-model escalation gap needs a §4 clause
  (docs/proposals/20260703-single-model-escalation.md, awaiting approval).
- Revisit when: the company framework is actually wired — fill its tier
  column in model-dispatch §2 and test the hooks mapping on-site.
