# OKR2 Signal Dataset Plan - 2026-05-13

## Decision

Build the next dataset as a **signal-first source pool**, not as a larger AGI-9466 synthetic sweep.

AGI-9466 remains useful, but only as a controlled generator for below-floor and boundary cases after production evidence is exhausted. The core dataset should be derived from production conversations, decomposed into evidence-backed signal paths, then promoted into balanced eval, production holdout, fixture, flip-audit, and synthetic-top-up artifacts.

## Why this is the right move

Yesterday's work already crossed the biggest accounting hurdle:

- `data/inputs/sanity_v2/source_pool_ledger_20260512.csv` accounts for all 47,153 production conversations.
- `docs/local_yaml_alignment_correction_20260512.md` shows 36,617 conversations match a current local prompt plus call-code-description pair, mostly `en_collin_kompato_payment_dtmf/main.yaml`.
- `docs/source_pool_ledger_summary_20260512.md` separates eligible production rows, flip-disagreement rows, postprocess fixture rows, system-rule rows, no-action rows, and below-floor rare rows.
- `input/testset_main_yaml_v2_20260511_v4_dtmf_aligned.csv` already proves a 624-row DTMF-aligned balanced sample is possible.

The remaining gap is not "more rows." The remaining gap is **signal structure**:

- A conversation can contain multiple relevant signals, while the final call code records only one winner.
- Later intent can override earlier intent, but earlier high-value signals still matter for training, QA, and Auto-QC.
- Compliance and legal signals must outrank reporting convenience.
- Some codes are prompt/LLM-emitted; others are postprocess or system-rule outputs and need fixture tests.
- AGI-9466 zero-shot seeds produce clean target behavior, but they do not automatically cover production ambiguity, multi-signal turns, ASR noise, or postprocess behavior.

## Brainstorming Pass

### Option A - Major voter first

Run 3-5 strong LLMs over every transcript and ask a reviewer to choose final evidence and call codes.

Pros:
- Fast conceptual path to multi-signal labels.
- Good for difficult boundary rows and flip-disagreement rows.

Cons:
- Too expensive and noisy for 47k row membership.
- Lets LLMs define ground truth before deterministic accounting.
- Can hide YAML/version drift and postprocess/system layers.

Use only after deterministic routing, for low-confidence rows, synthetic acceptance, and rerun mismatch triage.

### Option B - AGI-9466 generation first

Expand AC seeds and generate L1/L2 conversations until every code has enough examples.

Pros:
- Directly attacks rare-code coverage.
- AC seed format is strong for explicit intent, must-say, must-not-say, and distinct-from boundaries.

Cons:
- Repeats known AGI-9466 limits: structural HTT/ECH, warm-transfer mock gaps, priority rerank artifacts, score-4 quality cliff, and synthetic examples that are cleaner than production.
- Does not solve production label confidence or Auto-QC.

Use after production rows are exhausted, with stricter acceptance gates.

### Option C - Production final label only

Use `label_v0_last` as ground truth and sample to quotas.

Pros:
- Deterministic and cheap.
- Already close to usable for DTMF-aligned rows.

Cons:
- Throws away minor but important signals.
- Treats first/final flips as ordinary labels instead of Auto-QC signal.
- Cannot explain why two codes were reasonable in the same call.

Use as the baseline label, not the final signal truth.

### Chosen option - Tree-signal hybrid

Use production ledger rows as the source of truth for row existence and YAML lineage; then build a **signal tree per conversation** that records evidence spans and candidate codes. Use major voters only on low-confidence or high-value rows. Use AGI-9466 only to fill uncovered signal paths.

## Signal Data Model

The dataset unit should be `conversation_signal`, not only `conversation`.

Minimum fields:

| Field | Purpose |
|---|---|
| `conversation_id` | Join back to source ledger and rerun packet |
| `signal_id` | Stable per-conversation signal identifier |
| `tenant_normalized` | Keep Kompato, inferred Kompato, Affirm, Mariner visible |
| `local_yaml_match_path` | Exact YAML/prompt lineage for rerun |
| `source_route` | `prod_exact`, `prod_historical`, `fixture`, `flip_audit`, `synthetic_ac_seed` |
| `tree_path` | Root to trunk to leaf, e.g. `phone_holder/customer/payment_interest/partial_settlement` |
| `call_code_candidates` | All defensible codes for this signal |
| `primary_code` | The code this dataset row trains/evaluates |
| `neighbor_codes` | Codes this row should distinguish from |
| `evidence_turn_start` / `evidence_turn_end` | Span supporting the signal |
| `assistant_inquiry` | The assistant question or prompt that made the user response meaningful |
| `user_evidence` | Minimal user utterance evidence, not full transcript duplication |
| `signal_explicitness` | `explicit`, `implicit_high_value`, `implicit_low_value` |
| `signal_level` | L1 happy path, L2 confusing/cooperative, L3 adversarial/noisy |
| `temporal_rank` | Later signal can override earlier signal |
| `risk_priority` | compliance, legal, payment, transfer, ops, no-action |
| `label_confidence` | high, medium, low, quarantine |
| `adjudication_source` | prod label, deterministic rule, major voter, human, AC reviewer |

This preserves the user's tree idea: root determines who/what is on the phone, trunks represent major conversation phases, leaves represent specific outcomes or action codes.

## Tree Skeleton

Start with these top-level trunks and refine from real data:

1. Phone contact state: `NKP`, `HUP`, `NLM`, `LM`, `ECH`.
2. Identity and party relation: `IDV`, `IDF`, `WRN`, `TPC`, `HUA`, `NVR`, `RCR`, `LGB`.
3. Compliance/legal protection: `DNC`, `CDS`, `WCR`, `ATY`, `BKP`, `DSA`, `CPR`, `FRA`, `DIS`.
4. Engagement and willingness: `PPA`, `RTP`, `NNP`, `CAB`, `NCV`, `HCH`.
5. Payment/settlement outcome: `PAY`, `PIF`, `SIF`, `PSIF`, `PPIF`, `FDP`, `DCP`, `TPM`.
6. Transfer/human escalation: `TSR`, `TLM`, `EPT`, `HTT`, `FTP`, `WFR`, promise transfer variants.
7. Administrative/special handling: `LGH`, `PRS`, `CSM`, and other rare operational codes.

Do not force these trunks to be mutually exclusive at conversation level. Enforce MECE at the sibling-decision level inside one trunk.

## Small-Scale Hypothesis Test

Use this plan as an experiment first, not as a full-scale build.

### Hypothesis

Signal-tree labeling will produce a more useful dataset than final-label-only sampling because it captures explicit high-value signals, neighbor boundaries, and label-risk cases that the single production call code hides.

### Null hypothesis

The signal-tree layer does not add enough value over the existing production final label. If the small test cannot produce clearer evidence spans, better boundary labels, or useful Auto-QC queues, then scale-up should stop and the work should fall back to ordinary balanced sampling plus fixtures.

### Experiment slice

Build a 40-row experiment from already-accounted source rows:

| Slice | Rows | Purpose |
|---|---:|---|
| High-trust anchors | 10 | Sanity check that simple rows stay simple |
| Compliance/legal | 10 | Test whether explicit high-risk signals are easy to span-label |
| Flip-disagreement | 8 | Test whether first-vs-final mismatch is useful Auto-QC signal |
| Below-floor real production | 6 | Test whether rare rows are usable before synthetic top-up |
| Postprocess/system fixture | 6 | Test whether fixture routing stays separate from prompt eval |

Use exact current local YAML matches first, especially the `payment_dtmf/main.yaml` group. If a needed rare row is not available in exact-current YAML, mark it as `prod_historical_yaml_recovery` instead of silently mixing versions.

### What to build

Create these experiment artifacts:

- `docs/plan/signal_schema_v0_20260513.md`
- `data/inputs/sanity_v2/signal_experiment_40_manifest_20260513.csv`
- `data/inputs/sanity_v2/signal_experiment_40_annotations_20260513.jsonl`
- `docs/signal_experiment_40_report_20260513.md`

Each annotated signal row must include:

- assistant inquiry span;
- user evidence span;
- tree path;
- primary code;
- neighbor codes;
- explicitness level;
- temporal rank;
- risk priority;
- adjudication source;
- why final production label is sufficient or insufficient.

### Measurements

The experiment passes only if it clears these gates:

| Metric | Pass gate |
|---|---:|
| Source reconciliation | 40/40 rows join back to `source_pool_ledger_20260512.csv` |
| Version/routing clarity | 40/40 rows have explicit source route and YAML/prompt/CCD status |
| Evidence quality | >= 34/40 rows have a clear assistant/user evidence span |
| Signal lift | >= 8/40 rows contain a useful secondary or higher-value signal not represented by final label alone |
| Auto-QC lift | >= 50% of flip rows produce an actionable disagreement reason |
| Fixture separation | 6/6 fixture rows are excluded from prompt-only eval |
| Reviewer usability | 30-row spot review can validate the annotation without opening raw JSONL |

### Experiment decision

After the 40-row test, choose one:

1. **Scale**: gates pass; implement `signal_pool_v0` for 150-300 rows.
2. **Revise**: signal schema is useful but evidence extraction is weak; tighten schema and rerun another 40-row test.
3. **Fallback**: signal layer does not add value; use final-label balanced sampling plus separate fixture and flip-audit sets.

No 750-row dataset build should start until this experiment passes.

## Execution Plan

### Phase 0 - Run the 40-row hypothesis test

Deliverables:
- `docs/plan/signal_schema_v0_20260513.md`
- `data/inputs/sanity_v2/signal_experiment_40_manifest_20260513.csv`
- `data/inputs/sanity_v2/signal_experiment_40_annotations_20260513.jsonl`
- `docs/signal_experiment_40_report_20260513.md`

Tasks:
1. Select 40 rows from the ledger using the experiment slice above.
2. Annotate them manually or with a cheap extractor plus human review.
3. Run major voter only on the 8 flip-disagreement rows and any rare row with ambiguous evidence.
4. Score the experiment against the pass gates.
5. Decide scale, revise, or fallback.

Gate:
- The experiment report must make a concrete go/no-go decision. Do not continue to Phase 1 on narrative confidence alone.

### Phase 1 - Lock the signal schema and source routes

Deliverables:
- `docs/plan/signal_schema_v0_20260513.md`
- `data/inputs/sanity_v2/signal_route_manifest_20260513.csv`

Tasks:
1. Promote `source_pool_local_yaml_alignment_20260512.csv` as the alignment source of truth.
2. Define source routes:
   - `prod_exact_current_yaml`
   - `prod_historical_yaml_recovery`
   - `postprocess_fixture`
   - `system_rule_fixture`
   - `flip_disagreement_audit`
   - `below_floor_prod_real`
   - `synthetic_ac_seed`
3. Select the first working pool from exact DTMF matches:
   - eligible balanced/holdout rows from the 36,526 `payment_dtmf/main.yaml` group;
   - exclude flip rows from high-confidence eval;
   - route fixture/system codes separately.
4. Keep Affirm as a separate smaller lane, not the primary volume lane.

Gate:
- Every selected row has `conversation_id`, `label_v0_last`, tenant, prompt hash, CCD hash, local YAML path, and required rerun inputs.

### Phase 2 - Build `signal_pool_v0` from production rows

Deliverables:
- `data/inputs/sanity_v2/signal_pool_v0_20260513.jsonl`
- `docs/signal_pool_v0_report_20260513.md`

Tasks:
1. Start with 150-300 exact-DTMF conversations stratified by code, tenant, confidence band, and call direction.
2. For each conversation, extract turn pairs:
   - assistant inquiry;
   - user response;
   - current classifier `list_call_codes`;
   - final production label;
   - first/final flip state;
   - postprocess/system indicators.
3. Convert each turn pair into zero or more candidate signals.
4. Assign `tree_path`, `primary_code`, `neighbor_codes`, evidence span, explicitness, temporal rank, and risk priority.
5. Mark rows where final label is plausible but not exhaustive.

Gate:
- A reviewer can inspect 30 random `conversation_signal` rows and understand why the signal exists without reading the whole raw JSONL.

### Phase 3 - Add major-voter adjudication only where it pays

Deliverables:
- `data/inputs/sanity_v2/major_voter_queue_v0_20260513.csv`
- `data/inputs/sanity_v2/major_voter_results_v0_20260514.jsonl`

Use major voters for:
- 2,141 first-vs-final flip rows.
- Compliance rows with cross-category disagreement.
- Rare below-floor rows where one production label may hide a higher-value signal.
- Synthetic AC-seed outputs before promotion.
- Rerun mismatches after the smoke run.

Do not use major voters for:
- deciding whether a production row exists;
- ordinary high-trust HUP/NLM/WRN/IDV rows;
- postprocess-only fixture truth.

Voter design:
1. Three diverse strong classifiers produce `{evidence, reasoning, call_code_candidates, primary_code, confidence}`.
2. One strong reviewer adjudicates to `{accepted_signals, rejected_signals, evidence_spans, tie_breakers}`.
3. The reviewer must cite assistant inquiry + user response pair, not just summarize the whole call.
4. Disagreements are saved as Auto-QC signal, not hidden.

Model resource task:
- Query LLM Hub on zero with `models.list()`.
- Store availability and intended role in `data/inputs/sanity_v2/llm_model_inventory_20260513.json`.
- Pick models by role: one best-reasoning reviewer, two diverse high-quality voters, and one cheaper extractor for bulk signal proposals.

Gate:
- Major-voter accepted labels must show consensus or explicit reviewer override. No silent single-model labels.

### Phase 4 - Build dataset artifacts from the signal pool

Deliverables:
- `input/testset_main_yaml_v3_signal_balanced_20260514.csv`
- `input/testset_main_yaml_v3_production_holdout_20260514.csv`
- `input/testset_main_yaml_v3_postprocess_fixtures_20260514.csv`
- `data/inputs/sanity_v2/flip_disagreement_audit_v1_20260514.csv`

Dataset split:
1. Balanced eval: per-code quality, quota controlled.
2. Production holdout: production-weighted real-world rate.
3. Fixture set: postprocess/system behavior (`PAY`, `PIF`, `WFR`, `FTP`, `NKP`, promise postprocess variants).
4. Flip audit: KR2 Auto-QC training/evaluation source.
5. Synthetic supplement: only below-floor or structurally absent signals.

Quota proposal:
- Compliance: floor 20, stretch 30 per code.
- Operational: floor 15, stretch 20 per code.
- Minimum OKR health gate: at least 10 per in-scope call code.
- Target v3 balanced size: 750-900 rows, depending on how many fixture and synthetic rows are kept separate.

Gate:
- Balanced eval, production holdout, fixture set, and flip audit are reported separately. No blended "accuracy" number.

### Phase 5 - Use AGI-9466 as controlled zero-shot top-up

Deliverables:
- `docs/plan/agi9466_signal_seed_topup_20260514.md`
- `docs/plan/agi9466_ac_seeds_signal_topup.yaml`
- `output/agi9466_signal_topup_<ts>/`

Use AGI-9466 for:
- production-absent or below-floor codes such as `CSM`, `PRS`, `LGH`, `NCV`, `CDS`, `RCR`, `RTP`, `FDP`, `TPM` after real rows are exhausted;
- boundary pairs where production examples are too noisy;
- L1 and L2 examples only for positive eval rows.

Rules:
1. Convert each seed into signal grammar:
   - `primary_behavior`;
   - `must_say_or_imply`;
   - `must_not_say`;
   - `distinct_from`;
   - `neighbor_codes`;
   - `evidence_span_expectation`;
   - `tree_path`.
2. Acceptance threshold should be reviewer score 5 for promoted eval rows.
3. Score 4 can go to training/audit, not the gold eval set.
4. L3 remains adversarial, not positive coverage.
5. HTT/ECH need harness work before they count as solved:
   - HTT requires API fault injection.
   - ECH requires scripted-persona or IVR-screening injection.
6. Warm-transfer/payment postprocess outcomes must be fixture-tested or explicitly mocked, not treated as pure prompt examples.

Gate:
- A synthetic row can enter balanced eval only if:
  - reviewer score is 5;
  - target signal is explicit in user evidence;
  - forbidden neighbor codes are absent or correctly excluded;
  - classifier includes the target in `list_call_codes`;
  - any postprocess dependency is represented in `dict_variable`.

### Phase 6 - Convert signals into KR2 Auto-QC

Deliverables:
- `data/inputs/sanity_v2/auto_qc_signal_rules_v0_20260514.csv`
- `docs/auto_qc_signal_plan_20260514.md`

Auto-QC v0 signals:
1. First-vs-final label flip.
2. Cross-category flip, especially compliance to non-compliance.
3. YAML/prompt/CCD drift.
4. Signal tree conflict: high-value explicit compliance signal present but final code is lower-risk ops.
5. Rerun mismatch between production label and current YAML.
6. Major-voter disagreement after deterministic route is known.
7. Postprocess expected-but-missing `dict_variable` evidence.

Gate:
- KR2 should count bugs avoided or surfaced by deterministic signals, not just LLM explanations.

## Immediate Work Plan

### Today afternoon

1. Write `docs/plan/signal_schema_v0_20260513.md`.
2. Produce `signal_experiment_40_manifest_20260513.csv`:
   - 10 high-trust anchors;
   - 10 compliance/legal;
   - 8 flip-disagreement;
   - 6 below-floor real production;
   - 6 postprocess/system fixture.
3. Annotate the 40 rows into `signal_experiment_40_annotations_20260513.jsonl`.
4. Run major voter only on the flip/ambiguous subset.
5. Write `docs/signal_experiment_40_report_20260513.md` with pass/fail metrics.

### Tomorrow morning

1. If the 40-row experiment passes, implement the first signal-pool builder from the ledger + rerun packet.
2. Generate `signal_pool_v0` for 150-300 rows.
3. Run major-voter adjudication on only the low-confidence queue.
4. Build the first `v3_signal_balanced` candidate from signal rows.
5. If the experiment fails, revise schema or fall back before writing any large dataset.

### Tomorrow afternoon

1. Run a 50-row deterministic smoke rerun from `v3_signal_balanced`.
2. Compare production label, signal primary code, rerun output, and list-call-code candidates.
3. Route mismatches into:
   - prompt/definition issue;
   - postprocess fixture issue;
   - label confidence issue;
   - signal annotation issue;
   - synthetic/harness issue.
4. Decide whether to scale to the 624-row DTMF base or fix schema/routing first.

## Stop Conditions

Stop before scaling if any of these happen:

- selected rows do not reconcile back to the source ledger;
- selected rows mix YAML/prompt/CCD versions without a route label;
- more than 1% of selected rows lack rerun inputs;
- major voter is being used to decide source membership;
- synthetic rows are used before real below-floor rows are exhausted;
- fixture/system codes are mixed into prompt-only eval;
- the 40-row hypothesis test fails its gates and no revision pass is run;
- smoke rerun match rate is below 90% after two contract iterations;
- reviewer cannot cite exact assistant/user evidence spans.

## Pitch Summary

The plan worth following is:

1. production ledger first;
2. signal tree second;
3. major voters only for ambiguity;
4. AGI-9466 only for controlled top-up;
5. separate balanced eval, holdout, fixtures, flip audit, and synthetic rows;
6. use the same signal machinery for KR2 Auto-QC.

This gets over the AGI-9466 pipeline limit by not asking AGI-9466 to be the dataset. It becomes one source in a governed signal dataset whose primary ground is production evidence.
