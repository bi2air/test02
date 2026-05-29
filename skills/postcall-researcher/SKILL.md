---
name: postcall-researcher
description: Research, design, and iterate on the call-code taxonomy for post-call disposition in US debt-collection. Covers MECE review, adding/retiring codes, and closed-loop evaluation of call_code_descriptions against bot-grounded conversations. Use when the user asks to (a) audit existing codes for overlap/gaps, (b) propose or draft new codes, (c) optimize definitions to hit accuracy targets, or (d) produce a reproducible evaluation report.
---

# Mission

Maintain a **MECE** (mutually exclusive, collectively exhaustive) call-code taxonomy that captures the essence of each collection call for downstream planning (next-best-action, compliance flagging, reporting). Two invariants drive every decision:

1. **Compliance > reporting fidelity.** Regulatory risk is uncapped; reporting-quality loss is bounded.
2. **Definitions are code.** They live in YAML, get evaluated against a fixed conversation set, and iterate via a closed measurement loop. No opinions without numbers.

---

# Skill weakness — read this BEFORE trusting anything below

This skill was authored Apr 2026 and has accumulated stale facts faster than corrections. Treat it as **partly authoritative, partly outdated** until the durable-vs-volatile split refactor lands. The mismatch has been flagged multiple times across sessions; reading any section literally without verifying paths will waste time on dead pipelines.

## What is still trustworthy (durable, ~12-month half-life)

- The **Mission** invariants above: MECE, compliance > reporting, definitions-as-code.
- The **Tier A vs Tier B** separation and accuracy targets (≥95% / ≥90%).
- The **Hard rules** below (never-overwrite, LLM routing through LLM Hub / zero, conda env, dead-Google-stop, mandatory debug CSV, `negotiation_from_script` for synth Post-IDV).
- The **closed-loop methodology** shape (edit → eval → diagnose → one-code-at-a-time → 3-iter stop).
- The **compliance cheat sheet** appendix at the bottom.

## What was known-stale (historical record — these claims have been removed from the body of this file as of 2026-05-11)

The table below documents the stale facts that prompted the split. The active equivalents now live in `references/current-state-20260511.md`. Kept here as an audit trail.

| Where (pre-split) | Stale claim | Reality (as of 2026-05-11) |
| --- | --- | --- |
| Source-of-truth note + Quick references | `yamlfiles/affirm_code_defs.yaml` is the source of definitions | Source moved to `agi-sm-dsci-configs/scripts/en_collin_kompato_affirm/main.yaml`. Confirm with git before trusting either. |
| Canonical paths #4-#6 + Mode 2 command | Eval entrypoint + base-case catalog + `test_call_code_definitions.py` under `src/vpbPostCall/src/adversarial/` | Whole `src/vpbPostCall/` tree is dead and slated for git removal. Active batch runner is `run_postcall_batch.py` (on zero). |
| Mode 3 entire block | `run_simulation.py` / `generate_synthetic_rca.py` / `evaluate_simulation.py` flow | Replaced by `src/kompato/debtor/agi9466_chat_arena.py` (per-state caching, 0% truncation). Pin: `paco-agi9466-v2 @ d43bc8e`. |
| Mode 3 footer | `PIPELINE_CONV_GENERATION.md` is canonical | Dead-end. Confirmed multiple times across sessions. |
| Quick references | "10K token target for affirm_code_defs.yaml" | Resolved via a separate BASIC prompt at `docs/plan/call_code_descriptions_basic.yaml` (May 4), spliced into `main_basic.yaml`. |
| Quick references | `README.md` / `TRIGGER_TEST.md` / `.claude/plans/` paths | All under the deprecated tree. Current planning lives under `docs/plan/` and `docs/`. |

## Architectural fact missing from this skill

**Two-layer classification.** Some codes are decided post-LLM by `postprocess_conditions` on `dict_variable` signals (DTMF success, `payment_results`, `transfer_result`). These codes — currently `PAY`, `PIF`, `WFR`, `FTP`, plus the system-rule `NKP` — **cannot be fixed via Mode 2 prompt iteration**. They need fixture-row testing with patched `dict_variable` (helpers: `src/postcall/fake_dtmf_complete.py`, `src/postcall/fake_human_response.py`).

Open architectural question on `SIF`, `EPT`, `HTT`, `TLM`: same root cause (require post-transfer signals), currently sit as LLM-emit, consistently bleed to their pre-transfer cousins (`PSIF`, `IDV`). Two paths under discussion: (a) add prompt-level promote-rules keyed on `dict_variable`, (b) move into `postprocess_conditions`.

## Verify-before-use protocol

Before running any pipeline command this skill names:

1. `test -f <path>` on every named file. If missing → halt.
2. If a path is missing, **ask the user for the current equivalent**. Do not substitute a plausibly-related path (rule #4 below applied to file paths, not just URLs).
3. Cross-check the latest doc under `docs/` (e.g. `docs/main_yaml_*` for current sanity-eval state, `docs/plan/AGI9466_HANDOFF.md` for synth-pipeline state).

## Refactor applied 2026-05-11

This file has been split into two layers by half-life:

- **`SKILL.md` (this file) — 12-month durable assets.** Mission, tier separation, hard rules, methodology, cheat sheet, durable infra (zero server, LLM Hub, conda envs).
- **`references/current-state-YYYYMMDD.md` — ~30-day volatile assets.** Active pipeline scripts, testset paths, accuracy state, LLM-emit-vs-postprocess code split, known stuck ACs, zero workdir, AC-seed queue.

The Mode 2 / Mode 3 / Quick-references sections below now describe *methodology* only; concrete commands and entrypoints live in the current-state doc. Always read the latest dated current-state file before running any pipeline command. If a named path is missing on disk, halt and ask — do not substitute.

This "Skill weakness" section is preserved as a historical breadcrumb. Once you've internalized the structure, you can skim it.

---

# Code tiers (HARD separation — never merge across tiers)

## Tier A — Compliance (regulatory risk, target ≥95%)

`ATY, BKP, CDS, DIS, DNC, FRA, HCH, NCV, WCR, WRN, DSA, CPR`

A miss creates legal exposure (TCPA, FDCPA, state collection law, bar complaint, contract penalty). Treat these as non-negotiable:
- Keep full edge-case text and few-shots even under token pressure.
- Never merge with operational codes (e.g. don't collapse HCH into a generic "customer distress" bucket).
- Always broken out as a separate line item in every eval report — a 92% global with 85% compliance is a **failing** run, not a passing one.

## Tier B — Operational (UX / reporting quality, target ≥90%)

Split by call phase; the same lexical pattern can mean different things before vs after right-party contact:

- **Pre-RPC gatekeeping:** `NLM, LM, HUP, NVR, IDF, IDV, HUA, LGB, RCR, WRN, TPC, INC`
- **Post-RPC engagement:** `PPA, PPIF, PSIF, RTP, CAB, NCV (ops slice), HCH (ops slice), DIS (ops slice)`
- **Terminal / administrative:** `TSR, PRS, LGH, CSM`

A miss here dilutes reporting but carries no legal liability. These are where token budget gets cut first when compression is required.

> **Source of truth for definitions:** `references/callcode.txt` in this skill's folder (durable reference), plus the active classifier YAML named in `references/current-state-*.md`. The skill file never inlines definitions — descriptions evolve; inlining creates drift.

---

# Hard rules (pinned — violate and results are not reproducible)

1. **Never overwrite outputs.** Every run writes to a fresh dir suffixed `_b`, `_v2`, or a UTC timestamp. If the target dir exists, stop and ask for a new suffix.
2. **LLM routing.** Always route through LLM Hub or zero (`192.168.5.250`). **Never** use `.env.26.personal` or any user-specific key. See `feedback_llm_routing` memory.
3. **Conda env.** Local scripts run under `conda activate dev` (has pandas/gspread/pyyaml). Install new packages only under `conda activate web`.
4. **Dead Google link = STOP.** If a referenced Doc/Sheet URL is not accessible, halt and report. Do not substitute a plausibly-related sheet.
5. **Per-case debug CSV is mandatory.** Every pipeline/eval run must emit a CSV with columns: `case_id, code_target, hypothesis, steering, transcript, llm_calls_json, predicted, verdict, notes`. Missing any column = run is not reproducible.
6. **Synthetic Post-IDV conversations require `list_current_state=[negotiation_from_script]`.** Without it, the postprocess remapper corrupts labels (TSR→PTSR, NCV→PNCV, IDV→HUA). See `project_postprocess_state_trap`.
7. **Canonical paths (do not guess).** Specific paths have a ~30-day half-life — read `references/current-state-YYYYMMDD.md` (latest dated file) for the active set: rerun entry, production main.yaml, classifier YAML, synth generator, base-case catalog, eval CSV, batch runner. If any path the current-state doc names is missing on disk, halt and ask — do not substitute.
8. **Two-layer classification.** Some codes are decided post-LLM by `postprocess_conditions` on `dict_variable` signals (DTMF, payment_results, transfer_result). Editing `call_code_descriptions` will not fix them. The current LLM-emit vs postprocess-only vs system-rule assignment lives in `references/current-state-*.md`.

---

# Reproducible operating loop

The skill has **three entry modes**. Pick one based on the user's ask; don't silently switch modes mid-run.

## Mode 1 — Taxonomy review (MECE audit, no LLM)

Use when the user asks "do we have the right codes?" / "audit these".

1. `Read references/callcode.txt` and the active classifier YAML (path in `references/current-state-*.md`). Diff them — a mismatch between the two is already a finding.
2. For each code, record: (a) tier (A/B), (b) pre/post-RPC slot if Tier B, (c) one-sentence trigger, (d) two disambiguation tie-breakers against its nearest neighbors.
3. Build a pairwise overlap matrix for codes in the same slot (e.g., IDF vs HUA vs NVR; HCH vs NCV vs DIS). Flag any pair where triggers are not lexically distinguishable.
4. Output a report (markdown) with: tier-grouped table, overlap matrix, and a prioritized list of `{action: add|retire|clarify, code, rationale}`. **No code changes yet** — this mode ends at the report.

Deliverable: `docs/mece_audit_YYYYMMDD.md`.

## Mode 2 — Definition iteration (closed loop, LLM-in-the-loop)

Use when the user asks to hit an accuracy target or fix a failing code. This is the bread-and-butter mode.

```
┌─────────────────────────────────────────────────┐
│ 1. Edit call_code_descriptions in YAML          │
│    (only touch codes below target; don't drift; │
│     check current-state for LLM-emit vs         │
│     postprocess-only — Mode 2 cannot fix the    │
│     latter)                                     │
└────────────────────┬────────────────────────────┘
                     ▼
┌─────────────────────────────────────────────────┐
│ 2. Run eval                                     │
│    conda activate dev                           │
│    Entrypoint + flags: see current-state doc    │
│    Output dir: fresh suffix (rule #1)            │
└────────────────────┬────────────────────────────┘
                     ▼
┌─────────────────────────────────────────────────┐
│ 3. Read output summary                          │
│    Check: (a) global ≥90%                       │
│           (b) compliance subset ≥95% (MANDATORY)│
│           (c) per-code pass/fail                │
│           (d) confusion matrix top-3            │
└────────────────────┬────────────────────────────┘
                     ▼
┌─────────────────────────────────────────────────┐
│ 4. For each failing code: read misclassified    │
│    transcripts; diagnose (ambiguous def?        │
│    missing pattern? neighbor conflict?          │
│    post-transfer signal → wrong layer, exit     │
│    Mode 2); edit ONE code at a time; re-run     │
│    with code-subset filter to verify no         │
│    regression elsewhere.                        │
└────────────────────┬────────────────────────────┘
                     ▼
           Loop until both targets met.
```

**Stopping conditions:**
- (a) both targets green — ship;
- (b) 3 iterations on the same code with no gain — stop and escalate with diagnostics, do not grind;
- (c) failing code identified as postprocess-dependent — exit Mode 2 and switch to fixture-row testing (helpers in current-state doc).

Deliverables per run (fresh dir per rule #1):
- `summary.md` — global + compliance accuracy, per-code table, confusion matrix top-3
- `per_case.csv` — the mandatory debug CSV (rule #5)
- `definitions_used.yaml` — a copy of the exact YAML evaluated

## Mode 3 — Bot-grounded conversation generation

Use when eval coverage is thin (a code has <5 conversations, or conversations feel stale). Produces new test inputs but does **not** modify definitions.

1. Check the active base-case catalog (name in current-state doc) for the code's `target_state`. If present and reachable, use the active bot-simulation entrypoint. If deep in the bot flow, drop to synthetic and set `list_current_state=[negotiation_from_script]` (rule #6).
2. Write outputs to a fresh `data/outputs/sim_YYYYMMDD_<codes>/` directory (rule #1).
3. Run the active evaluation script against the new sim JSON to produce a labeled evalset slice.
4. Append to the master evalset **only after** human or 3-run-consensus labeling confirms the target label.

Concrete script names + pin live in `references/current-state-*.md`. Chat-arena pipelines have moved between subpackages multiple times — do not rely on names cached in memory.

---

# What the skill does NOT do

- Does not touch the production `main.yaml` in `agi-sm-dsci-configs/`. Merging tuned definitions into production is a separate human-reviewed step on branch `bn2-paco`.
- Does not create new codes without a MECE audit (Mode 1) first. "We need a new code for X" → audit first, then add.
- Does not evaluate against live production traffic. All eval runs against the fixed base-case evalset and sim-JSON artifacts.
- Does not delete or rename existing codes without explicit user confirmation — historical reports reference them.

---

# Quick references

- **Domain context:** US debt collection, phone-first, resold low-recovery accounts. Inputs to classification are call transcripts (minimum: bot greeting).
- **Code definitions (durable reference):** `references/callcode.txt`
- **Active paths / scripts / accuracy state / known stuck ACs (volatile, ~30-day half-life):** `references/current-state-YYYYMMDD.md` — read the latest dated file before any pipeline command.
- **Research framing prompts:** `references/research-prompts.md` — read only when the user asks for broad industry research, call-code taxonomy discovery, or exploratory framing before a MECE review.
- **Eval reports (timestamped, audit trail):** `docs/main_yaml_sanity_eval_*.md`, `docs/report/*`.
- **Token check (cheap):** `wc -c <yaml>` then `/4` for a rough token estimate.
- **Related memory:** `feedback_compliance_vs_ops_split`, `project_postprocess_state_trap`, `feedback_never_overwrite`, `feedback_llm_routing`, `feedback_conda_envs`, `feedback_docs_timestamp`.

---

# Appendix: compliance code triggers (cheat sheet)

Abbreviated — full edge cases live in the YAML. Use this table for quick neighbor-disambiguation during Mode 1 audits.

| Code | Trigger (one sentence) | Nearest neighbor | Tie-breaker |
|------|------------------------|------------------|-------------|
| DNC  | "Stop calling this number" | CDS | DNC = phone-only; CDS = ALL contact |
| CDS  | "Stop all contact" formal cease-and-desist | DNC | See above |
| WCR  | "Written communication only" | DNC | WCR preserves mail; DNC preserves mail too but is phone-specific |
| ATY  | "Talk to my lawyer" | DSA | ATY = individual attorney; DSA = debt-relief program/firm |
| BKP  | "I filed bankruptcy" w/ case details | DIS | BKP is a legal status with stay; DIS is a dispute |
| DIS  | "I don't owe this / amount is wrong" | FRA | DIS = amount/validity challenge; FRA = identity theft |
| FRA  | "This account isn't mine, identity theft" | DIS | See above |
| HCH  | Financial hardship (unemployment, medical, etc.) | RTP | HCH = can't pay due to circumstances; RTP = won't pay after multiple offers |
| NCV  | "Can't talk now, call back" (not engaging) | CAB | NCV = not convenient, no time set; CAB = specific callback time confirmed |
| WRN  | "Wrong number, not me" | TPC | WRN = no connection; TPC = knows the target, provides new contact |
| DSA  | Third-party debt relief firm involved | ATY | DSA = program/firm; ATY = legal representation |
| CPR  | Formal complaint about collection practice | HCH | CPR = complaint filed; HCH = hardship statement |
