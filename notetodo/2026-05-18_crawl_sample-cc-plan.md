# CC / Opus Plan — Real Datadog Sample Collection for Call Codes

Parallel to `2026-05-18_crawl_sample-codex-plan.md`. Defines the Claude Code +
Opus subagent role in the sample-collection pipeline, given:

- Codex's 5-persona panel + judge is the **primary correctness engine**.
- The MUST-HAVE fields and 4-tier rerun ladder from
  `2026-05-18_crawl_sample.md` define the per-sample contract.
- Opus 4.7 has a distinct label policy (multi-label hedge, cross-family) and a
  daily quota that limits primary-engine use at full scale.

## Positioning

CC subagents do NOT duplicate Codex's persona panel. They are a **cross-family
verifier** that runs in parallel to Codex and contributes a structurally
orthogonal opinion. Three roles:

1. **Multi-label challenger** — Opus's natural tendency to emit multiple codes
   per cid surfaces over-convergence in Codex's 3/3 votes. If the panel says
   3/3 PPIF and Opus says `{PPIF, ATY}`, that's a real signal worth
   investigating, not just hedging.
2. **Adversarial verifier on contested cids** — for any cid where Codex's
   panel = 2/3 OR rerun_grade < tier_4, an Opus subagent runs an adversarial
   prompt ("prune over-hedges, drop weak codes") on the panel's emitted set.
3. **Tree-grounded phase-alignment check** — Opus subagents already encode the
   002-tree.md phase-flow rules in the analytic prompt (see
   `src/intent_extract_v3/prompt.py`); reuse that on the same samples to flag
   180-flip cases the panel might miss.

### Operating principles (adopted from Codex's May 18 validation recap)

- **Traces are part of the deliverable, not just the final label.** Codex's
  pipeline preserves 9 LLM calls per cid (3 voters + judge + 5 signal-reviewers)
  with full reasoning each; the disagreement record is itself the artifact.
  CC subagent outputs should match this — preserve the analytic Pass-1 + the
  adversarial Pass-2 traces in full, not just the final code.
- **Boundary samples are first-class, not flags.** Codex's recap surfaced PPIF
  as L2 boundary (panel preferred FDP because the promise was future-dated) —
  not as "wrong" but as "this is the sibling-code edge case worth keeping".
  CC's contribution should preserve these boundary-shape pools, not collapse
  them into a single "divergence" category.
- **Headless tokens are a resource for forensic disagreement, not throughput.**
  Volume isn't the win — depth-per-cid is. Reserve CC for the contested subset
  where another lens contributes signal.

## What this is NOT

- NOT a competing pipeline. Codex's panel is the truth-decider.
- NOT a primary bulk extractor at scale — Opus quota hits around ~180 cids
  before requiring a daily reset. Use for the ~25-30% contested subset.
- NOT a replacement for the rerun-grader. Rerun behavior is its own oracle.

## Pipeline shape (where CC subagents slot in)

Output namespace convention (adopted from Codex): all stages write under
`output/affirm_signal_pilot_<RUN_ID>/` in sibling subdirectories so a single
aggregator can join them.

```
output/affirm_signal_pilot_<RUN_ID>/
├── intent_sample.csv.gz                       ← monitor_sample.py
├── postcall_rerun_input.csv                   ← prepare_postcall_rerun.py
├── postcall_rerun_input.manifest.json
│
├── codex_major_vote_default_3x_judge/         ← run_monitor_major_vote.py
│   ├── results.csv         ← per-cid: accepted_label, agreement_count,
│   │                         judge_accepts, sample_status,
│   │                         complexity_grade, evidence_span, dissent_analysis
│   └── summary.json
│
├── codex_signal_review_1pc_5x/                ← run_monitor_signal_review.py
│   ├── results.csv         ← per-cid: usable_count, usable_arguments,
│   │                         sample_signal_status
│   └── summary.json
│
├── postcall_rerun_dry_run/                    ← (blocked locally — see Open items)
│   └── rerun_grader_results.csv ← per-cid: rerun_grade ∈ tier_1..tier_4,
│                                  final_callcode, list_call_codes
│
└── cc_cross_family_verifier/                  ← NEW — this plan
    ├── pass1_analytic/<cid>.json   ← Opus subagent analytic extract
    │                                  (same schema as src/intent_extract_v3
    │                                   prompt.OUTPUT_SCHEMA)
    ├── pass2_adversarial/<cid>.json ← Opus subagent adversarial verifier
    │                                  (only for contested cids)
    ├── results.csv                  ← per-cid: opus_codes, opus_confidence,
    │                                  cross_family_status ∈
    │                                  {confirmed, hedge_added, dissent,
    │                                   adversarial_rescued, no_signal}
    └── summary.json
```

Cross-family-cross-check decision logic (final stage, joins all four results.csv
files on conversation_id):

```
                            panel_label == opus_label?
                                       │
            yes (codes match)          no
                  │                    │
        rerun_grade?                rerun_grade?
        │           │               │           │
      tier_4    tier_2/3         tier_4    tier_1/2/3
        │           │               │           │
   CANONICAL   BOUNDARY          BOUNDARY    CHALLENGING
   L1          L2                L2          L3
                                            (taxonomy review
                                             material)
```

## Implementation

### CC analytic-extractor subagent (Pass 1)

Already implemented as `src/intent_extract_v3/{prompt,sample,hydrate}.py` +
hand-batched dispatch.

What this run already produced (May 18 PM session):

- 180 / 405 Affirm cids hit before Opus quota cap
- Schema: `predicted_codes[]` with code + confidence + phase_alignment +
  evidence_qa_pair + evidence_turn_indices + transcript_evidence + ...
- Multi-label tendency: ~25-30% of cids emit ≥2 codes (the "hedge")

Use these 180 directly. They are the Opus-side cross-family signal for
~44% of the sample. No need to grind through the remaining 225 with
hand-dispatch.

### CC adversarial-verifier subagent (Pass 2)

Already implemented as `src/intent_extract_v3/arbitrate.py` (originally fed by
Codex's r1 triage queue, but trivially re-targetable to consume the persona
panel's 2/3 set).

Promotion plan: have Pass 2 consume from Codex's `run_monitor_major_vote.py`
output. Concrete bridge:

```python
# In dispatch_cc.py — Pass 2 input selection
import pandas as pd

vote = pd.read_csv(
    f"{RUN_DIR}/codex_major_vote_default_3x_judge/results.csv"
)
review = pd.read_csv(
    f"{RUN_DIR}/codex_signal_review_1pc_5x/results.csv"
)
# Optional once rerun-grader exists:
# rerun = pd.read_csv(f"{RUN_DIR}/postcall_rerun_dry_run/rerun_grader_results.csv")

contested = vote[
    (vote["agreement_count"] < 3) |
    (vote["judge_accepts_argument"] == False) |
    (vote["sample_status"].isin(["boundary", "challenging"]))
].merge(
    review[review["usable_count"] < 4][["conversation_id"]],
    on="conversation_id",
    how="outer",  # union: either flagged OR low-signal triggers Pass 2
)

# contested["conversation_id"] is the Pass 2 queue
```

Schema for the per-cid Pass 2 input the adversarial verifier consumes
(`pass2_adversarial/<cid>.json`):

```json
{
  "conversation_id": "...",
  "prod_master": "...",
  "panel": {
    "accepted_label": "FDP",
    "agreement_count": 2,
    "voters": [
      {"persona": "taxonomy_auditor", "label": "FDP", "argument": "..."},
      {"persona": "linguist", "label": "FDP", "argument": "..."},
      {"persona": "qa_analyst", "label": "PPIF", "argument": "..."}
    ],
    "judge_accepts": true,
    "dissent_analysis": "..."
  },
  "signal_review": {
    "usable_count": 3,
    "usable_arguments": ["..."]
  },
  "rerun": {
    "final_callcode": "FDP",
    "list_call_codes": ["FDP", "PPIF"],
    "rerun_grade": "tier_3"
  },
  "transcript_indexed": "...",
  "render_prompt_gz_path": "..."
}
```

Opus is told: "Adjudicate. Panel said FDP 2/3 with PPIF dissent; rerun emitted
both. Either confirm FDP (cross-family agreement), pick PPIF (overruling the
panel + rerun), or emit both (the genuine boundary case). Reasoning is the
deliverable, not just the verdict."

### Quota / dispatch strategy

Opus 4.7 has a daily session quota. Three lessons from May 18 PM:

1. **Don't bulk-dispatch >200 Opus subagents per day** — quota cap hits and the
   remaining batch errors out silently per-call.
2. **Reserve Opus for the ~25-30% contested subset** identified by Codex's
   panel + rerun-grader. For Affirm 405 that's ~100-120 cids/day — well under
   quota.
3. **Run Codex's full 405-cid pipeline FIRST** (free via Codex sub), then
   trigger Opus only on the contested subset. This is the right order even if
   Opus quota is unlimited, because routing Opus to the cids where it adds
   marginal signal is more useful than blanketing.

### Headless dispatcher (preferred, not yet implemented)

The May 18 PM session hand-typed 6 batches × 30 Agent dispatches before quota.
This is too operator-heavy. Next iteration:

- Write `src/intent_extract_v3/dispatch_cc.py` that uses LLM Hub's Anthropic
  endpoint OR the SDK directly (NOT `claude -p` which blocks on API auth).
- Same prompt content as the current Agent-tool dispatch, same per-cid I/O
  contract (read `inputs/<cid>.txt`, write `extracts/<cid>.json`).
- 8-way asyncio parallel, idempotent (skip cids already done).
- Estimated wall for 100 contested cids at concurrency=8: ~3-4 minutes.

This makes the CC verifier role programmatic and quota-aware.

### Launcher conventions (matching Codex)

Codex's `scripts/ll_affirm_signal_pipeline.sh` already establishes the patterns
the CC stage should match:

- **`RUN_ID=<timestamp>`** — env var that scopes the output namespace.
  CC dispatcher MUST honor the same `RUN_ID` so its outputs land under
  `output/affirm_signal_pilot_<RUN_ID>/cc_cross_family_verifier/`. Without
  this, joining across stages requires manual path-fixing.
- **`COMPILE_ONLY=1`** — fast gate that runs `py_compile` on all pipeline
  files and exits. CC plan should add `dispatch_cc.py` and `aggregate_cc.py`
  to this list once they exist.
- **`--smoke` mode** for the CC dispatcher — read one cid, do one Opus call
  end-to-end, validate JSON schema, then exit. Bounds wall + quota burn
  before any bulk run.
- **Toggle env vars** matching Codex's pattern:
  `RUN_CC_PASS1=1` (analytic), `RUN_CC_PASS2=1` (adversarial),
  `CC_TARGET=contested|all|smoke`. Default to contested.

Once the launcher is unified, a full run looks like:

```bash
RUN_ID=20260519_full_unsandboxed_<HHMM> \
RUN_MAJOR_VOTE=1 RUN_CODEX=1 \
RUN_CC_PASS1=1 RUN_CC_PASS2=1 \
RUN_POSTCALL_DRY=1 \
scripts/ll_affirm_signal_pipeline.sh
```

## What CC subagents add on top of Codex's panel

Two genuinely orthogonal signals:

### 1. Cross-family disagreement is informative

When Codex's gpt-5.5 panel votes 3/3 for X and Opus subagent emits `{X, Y}` or
`{Y}`:
- Both models converge on X but Opus sees additional evidence for Y → real
  multi-label signal, escalate for canonical = boundary review
- Opus disagrees outright (no X in its set) → cross-family dissent, high-value
  for taxonomy review

When both agree (3/3 panel = X, Opus = `{X}` single): canonical confirmed by
two model families. Stronger than persona-vote alone.

### 2. Tree-phase-alignment as a structural check

Opus subagents already get the call-flow tree (`kai-code-disposition/tree/002-tree.md`)
in the system prompt with the four phase-gating rules. If a panel-emitted code
violates phase alignment (e.g., panel says PPIF but transcript shows IDV never
passed), the Opus check surfaces it as `phase_alignment=misaligned` with
confidence ≤ 0.20. This is a check Codex's plan acknowledges in principle but
doesn't enforce as a hard structural constraint.

## What CC subagents DON'T do

- No professional-priors persona simulation (compliance / ops / taxonomy /
  linguist / QA). That's Codex's panel's job.
- No "decide truth" — only "verify under a different lens".
- No bulk extraction at 400+/day scale. Quota-limited.

## Open items

1. Build `dispatch_cc.py` as the programmatic replacement for hand-typed
   Agent-tool batches. Reads the cid list, fans out, idempotent. Honors
   `RUN_ID`, `--smoke`, `CC_TARGET` toggles per the launcher conventions.
2. Build `aggregate_cc.py` that joins the four `results.csv` files (Codex
   major-vote, Codex signal-review, rerun-grader, CC cross-family-verifier)
   into one `final_canonical_decisions.csv` per the cross-family decision
   logic. One row per cid.
3. Decide whether the 180/405 already-dispatched extracts are the
   first cross-family pass or whether they get re-run once Codex's pipeline
   has filtered to the contested subset. Probably re-run only the contested
   cids, keep the 180 as cheap audit material.
4. **BLOCKED — rerun grader requires the postcall dry-run to work locally.**
   Codex's May 18 validation surfaced the root cause: `src/postcall/rerun.py`
   asserts hardcoded `/media/sdb/working/llm_voice/explo/binh2/kompato/.env.demo`
   during import. Two unblock paths:
   - (a) Patch `src/postcall/rerun.py` to accept a configurable dotenv path
     (30-60 min, per Codex's estimate). Cleanest fix.
   - (b) Run rerun on zero server where the hardcoded path exists. Lossier:
     adds rsync round-trip and an SSH dependency to the canonical-decision
     critical path.
   Until either is in place, the cross-family decision logic falls back to:
   `panel agreement` × `cc verdict` — without the `rerun_grade` axis. That
   still produces a defensible canonical/boundary/challenging triage; it just
   loses the live-classifier oracle.
5. Codex's recap noted that nested `codex exec` calls require unsandboxed
   execution (cannot initialize `~/.codex` app-server transport in the
   sandbox). CC subagents have the same constraint when they dispatch via
   the Agent tool from within a tool-sandboxed conversation. Document this
   in the launcher: any stage that fans out LLM calls must be run
   `dangerouslyDisableSandbox` or outside the surrounding tool sandbox.
6. PPIF vs FDP taxonomy edge surfaced by Codex's 3-row validation needs a
   product/taxonomy decision before either pipeline can grade
   "future-dated full-balance commit" canonically. Until decided, both
   pipelines should keep these as L2 boundary material with the full panel
   + CC trace preserved for human review.

## How this aligns with the user's MUST-HAVE list

CC subagents already emit most of the MUST-HAVE fields:

| field | source |
|---|---|
| conversation_id | in extract |
| tenant | implicit (sampler scope = Affirm) |
| predicted_callcode | not directly; would inherit from sample.csv |
| RCA | NOT emitted; would need monitor_sample.py update first |
| call_direction | NOT emitted; would need monitor_sample.py update first |
| evidence_of_intent | `evidence_qa_pair` |
| transcript | `transcript_evidence` (sliced from beginning) |
| render_prompt | NOT preserved per cid; needs new output |
| list_call_codes | `predicted_codes[].code` |
| final_callcode | NOT distinct from `predicted_codes[0]` — needs separate live-classifier field |
| reasoning | `evidence_summary` + `code_trigger` + `notes` |

So 7/11 MUST-HAVE fields exist; 4 (`RCA`, `call_direction`, `render_prompt`,
`final_callcode`) require monitor_sample.py to emit them upstream. The CC
output flows them through without needing changes to the CC prompts.

## What I learned from Codex's May 18 validation recap

(Reading `docs/session_recap/20260518_codex-headless-monitor-validation.md`.)

1. **Codex's pipeline preserves much richer per-cid traces than my Pass-1+Pass-2.**
   Per cid: 3 voter traces + judge reasoning + 5 signal-review traces = 9 LLM
   calls with full reasoning. My current CC output is 2 calls (analytic +
   adversarial when triggered) with one-line `evidence_summary` strings.
   Implication: even when CC's role is "cross-family verifier", the *traces
   are part of the deliverable* — the cross_family_status flag alone isn't
   enough; the Opus reasoning chain for both confirm and dissent cases needs
   to land in the final review row.
2. **The PPIF case is the concrete test for this entire architecture.**
   Codex's 3-row validation produced exactly one boundary: PPIF labeled in
   prod, panel voted 2/3 FDP (judge accepted) because the promise was
   future-dated. This is precisely where cross-family signal matters: if
   Opus (different family) also reads FDP, the case for FDP is much
   stronger than gpt-only 2/3. If Opus reads PPIF, we have a genuine
   cross-family disagreement worth taxonomy review. Either way, the answer
   isn't "wrong" — it's L2 boundary with full provenance.
3. **The 3-row scale of Codex's validation is too small to verify the
   contested-subset heuristic.** My earlier 405-cid Codex r1 + 111
   arbitrations gave better statistical signal (37% had divergence/partial
   patterns) but used a different pipeline. The right experiment now: run
   Codex's validated panel on a ~30-50 cid scaled pilot, log the contested
   rate, and only then dispatch CC on that subset. If contested rate is
   ~30%, my "100-150 cids per day Opus" budget is correct; if it's >50%,
   CC becomes the bottleneck again.
4. **Codex flagged its own quota as "a resource for forensic disagreement,
   not throughput".** I should adopt the same framing for Opus quota
   verbatim — and update my dispatcher's job description: emit the
   disagreement record, not just decide a label.
5. **Sandbox / nested-exec / dotenv-path are all real environment blockers.**
   Codex's recap lists three: sandboxed `codex exec` fails to initialize,
   postcall dotenv is hardcoded to zero, and the dry-run gate can't fire
   locally. My CC plan inherits #1 (subagent dispatch needs unsandboxed
   shell) and #2 (rerun grader can't run locally) until they're fixed.
   Putting these in Open items above makes them visible instead of
   surfacing on first run.
