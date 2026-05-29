# Codex Plan Update — May 18 (post-MUST-HAVE additions)

Companion to `2026-05-18_crawl_sample-codex-plan.md`. Captures the patches needed
because Codex's plan was written before the user added the MUST-HAVE field list
and the 4-tier rerun-as-grade ladder.

## Trigger — what changed in the source doc

`2026-05-18_crawl_sample.md` gained two new sections after Codex's plan was
written:

1. **MUST-HAVE per-sample fields for manual review** — 11 fields, of which 5
   (`RCA`, `call_direction`, `render_prompt`, `final_callcode`, `reasoning`) are
   not emitted by the current `monitor_sample.py` or judge output.
2. **4-tier sample-quality ladder** based on postcall rerun behavior — promotes
   rerun from binary gate to a grading axis with values
   `tier_1` (ingests cleanly) → `tier_2` (rerun returns a closely-defined code)
   → `tier_3` (list_call_codes count matches L1/L2/L3 expectation)
   → `tier_4` (rerun returns the exact desired code).

Codex's plan acknowledges rerun as a "compatibility gate" only. It does not
treat rerun behavior as a quality signal, and it does not preserve the live
classifier's full output (`final_callcode`, `list_call_codes`, `reasoning`) for
cross-check against the judge's `accepted_label`.

## Concrete patches required

### Patch 1 — `monitor_sample.py` emits 5 new columns

| column | source | notes |
|---|---|---|
| `RCA` | `result.extracted_info.rca` (or `dict_variable.rca`) | reviewer-readable root-cause text; tiny |
| `call_direction` | `conversation_caching.call_direction` or inferred from `usecase_id` (Affirm-outbound for now) | constant per tenant flow today; load-bearing once we add inbound flows |
| `render_prompt` | the full rendered classifier prompt for this cid | gzipped sidecar (`render_prompts/<cid>.txt.gz`), NOT inline — Sheets truncates and firewall scans plain text |
| `final_callcode` | live classifier's post-postprocess emission | the production code that prod actually emitted; compare against judge `accepted_label` |
| `reasoning` | `result.reasoning` or `result.extracted_info.reasoning` | the live classifier's own reasoning trace |

### Patch 2 — New stage `run_rerun_grader.py`

Slots between `run_monitor_major_vote.py` and `run_monitor_signal_review.py`.

Inputs:
- judge output (`accepted_label`)
- `final_callcode` + `list_call_codes` from `final_postcall_rerun_output.csv`
  (already produced by the existing rerun stage)

Outputs per cid:
- `rerun_grade` ∈ {`tier_1`, `tier_2`, `tier_3`, `tier_4`}
- `persona_rerun_cross_check` ∈ {`match`, `semantic_neighbor`, `count_only`, `mismatch`}

Decision rules:
- `tier_4` = `final_callcode == accepted_label`
- `tier_3` = `len(list_call_codes)` matches expected (L1=1, L2=2, L3≥3) AND
  `accepted_label ∈ list_call_codes`
- `tier_2` = `accepted_label ∈ semantic_neighbors(final_callcode)` per the
  call-flow tree (002-tree.md) — e.g. HUP/NKP/NLM neighbors, IDV/IDF/NVR
  neighbors
- `tier_1` = rerun ingested cleanly (this is the existing Codex gate)

### Patch 3 — Persona prompts gain runtime-markup awareness

3-sentence addition to every persona's system prompt:

```
Distinguish HUMAN speech from RUNTIME MARKUP:
- `<SILENCE_5s>` is bot-side pacing, NOT a human action.
- `[company_name: Affirm]` etc are TTS synthesis hints, NOT spoken text.
- Anchor your evidence and code decisions to actual user/agent utterances only.
```

### Patch 4 — Updated canonical-sample contract

Previously (Codex's plan):
> A sample is canonical only when: monitor reconstruction complete, persona 3/3,
> judge accepts, signal review agrees, rerun CSV valid + rerun result compatible.

Updated:
> A sample is canonical only when ALL of:
> 1. monitor reconstruction complete (existing)
> 2. persona 3-vote = 3/3 (existing)
> 3. judge accepts the winning argument (existing)
> 4. signal review agrees the transcript has usable evidence (existing)
> 5. **`rerun_grade == tier_4`** (NEW — replaces "rerun compatible")
> 6. **`persona_rerun_cross_check == match`** (NEW — judge label and live
>    classifier final code are the same)
>
> Boundary = persona 3/3 + rerun_grade ∈ {tier_2, tier_3} OR persona 2/3 +
> rerun_grade == tier_4.
>
> Challenging = persona 2/3 + rerun_grade < tier_4 OR persona 1/3 + judge
> approves.

### Patch 5 — Schema for the per-sample review row

The single canonical sample row now has these columns (reviewer-grade, not just
pipeline-grade):

```
conversation_id            (existing)
tenant                     (existing — explicit for multi-tenant)
call_direction             NEW
predicted_callcode         (= prod's live label, existing)
RCA                        NEW
evidence_of_intent         (existing, from judge.evidence_span)
transcript_indexed         (existing — explicit "from turn 0" invariant)
render_prompt              NEW — gzipped sidecar reference
list_call_codes            (existing, from rerun)
final_callcode             NEW — live classifier's post-postprocess emission
reasoning                  NEW — live classifier's reasoning trace
persona_accepted_label     (existing, judge.accepted_label)
persona_agreement_count    (existing)
persona_dissent_analysis   (existing)
rerun_grade                NEW — tier_1..tier_4
persona_rerun_cross_check  NEW — match/semantic_neighbor/count_only/mismatch
sample_status              (existing — canonical/boundary/challenging/reject)
complexity_grade           (existing — L1/L2/L3 derived)
```

## What stays unchanged

- 5-persona model with legitimate professional priors
- 3-panel composition (default / compliance-sensitive / operational)
- Two-question split (correctness vote ≠ usability review)
- Codex-headless adaptations (compile gate, env-var-toggled launcher)
- `MAJOR_PANEL=compliance|default|operational` switching

## Filing order for these patches

1. monitor_sample.py columns first (cheap, unblocks everything else)
2. Persona-prompt runtime-markup patch (3-sentence edit, no code change)
3. `run_rerun_grader.py` as a new stage
4. Update the canonical-sample contract doc
5. Update the per-sample review row schema doc
