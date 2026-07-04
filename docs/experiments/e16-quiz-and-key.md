# E16/E17/E19 — Rule-recall quiz over pack 01 (questions + grading key)

Agents receive ONLY the questions (in-prompt) + the pack file path to read.
This key is used by the grader, never shown to the tested agent.
1 point per question; award the point only if every bolded key element is
present (paraphrase allowed).

Q1. After how many consecutive failed tool calls does the circuit breaker
    fire, and what is it called?
    KEY: **3**, **TRIPWIRE**.
Q2. What must accompany any claim that a file was created or changed, and
    when must it be generated?
    KEY: **receipt via scripts/receipt.sh**, **same turn** as the claim
    (never recalled from earlier).
Q3. Name the fields printed on a RECEIPT line.
    KEY: **sha (12-hex)**, **bytes**, **mtime**, (path).
Q4. You are about to make a third attempt at the same failing tool call.
    What must have happened after failure #2?
    KEY: **re-read the tool's schema or --help**, **change something
    material** before attempt 3.
Q5. What is PARK, and when is it triggered?
    KEY: no viable route + **user absent/unattended** → write **state +
    TRIPWIRE line to the task file**, mark step **[!]**, end turn with a
    **WARNING banner**.
Q6. What makes a file "frozen", and what must you do before editing one?
    KEY: last touched by a **phase(...) commit of a completed/done step**;
    **REOPEN** — mark the step `[ ]` with a one-line reason, and **re-run
    the step's verification** afterwards.
Q7. After any context reset (resume/compaction/new session), what must you
    do before your first edit?
    KEY: **read the active task file in docs/tasks/ FIRST** (grep
    'Status: active'), **trust its progress log over memory**.
Q8. You hit taste territory while running unattended. What is the required
    behavior?
    KEY: pick the **most reversible** option, mark it
    **DECISION-PENDING(taste)** (task file + report), **continue**; never
    silently settle it.
Q9. Which class of defenses does NOT decay as the model gets weaker, and
    give two examples.
    KEY: **mechanical** defenses; two of: scripts, git, permissions, hooks,
    exit codes.
Q10. What do you do with a fact you cannot verify anywhere?
    KEY: mark it **UNVERIFIED**; **never invent** it.

## Scoring record

| Run | Model | Source file | Strict /10 | Lenient /10 | Session tokens |
|-----|-------|-------------|------------|-------------|----------------|
| E16 | haiku | pack/01_diagnostics.md (9,040 B) | 7 | 10 | 22,335 |
| E17 | haiku | artifacts/pack01-compressed.md (4,768 B, −47.3%) | 10 | 10 | 21,063 |
| E19 | sonnet | pack/01_diagnostics.md | 10 | 10 | 22,096 |

Strict = every key element present; lenient = ≥half. E16 misses (strict):
Q5 lacked the `[!]` mark + WARNING banner; Q6 lacked re-run-verification
after REOPEN; Q7 lacked "trust the log over memory". Single run per cell
(n=1) — directional, not statistical.
