# Codex Plan: Real Datadog Sample Collection For Call Codes

Durable bridge: `docs/resource/20260514_codex_major_voter_runbook.md` now
contains the May 18 monitor-sample addendum that wires this plan into the
original Codex major-voter setup.

## Objective

Collect real Affirm call-code samples from Datadog-derived monitor data.

The goal is not only to find calls with a production label. A useful sample must
be:

- traceable to real Datadog `StartPostCallAnalysis` / `EndPostCallAnalysis`
  events;
- grounded in transcript evidence;
- judged against the call-code definitions and edge cases;
- graded by complexity (`L1`, `L2`, `L3`);
- compatible with the postcall rerun input contract.

The production `latest` postcall label is the candidate label. It is not the
whole truth by itself.

## Why Sampling Is Hard

The real Datadog population is biased toward short calls, non-pickup, voicemail,
automation, and low-turn conversations. Naive sampling will overproduce easy
operational shapes (`HUP`, `NLM`) and underproduce clean examples for rarer
codes.

Transcripts also contain runtime artifacts:

- `<SILENCE_5s>` is a bot/runtime marker, not the same as a human semantic
  statement.
- bracketed placeholders such as `[company_name: Affirm]` are synthesis/runtime
  markup.
- ASR text can be fragmented, duplicated, or missing punctuation.

Reviewers must separate human evidence from runtime markup.

## Persona Model

Personas are controlled reviewer lenses, not random retries.

Each persona has a legitimate professional prior:

- `compliance_officer`: regulatory risk; prefer broader compliance labels under
  ambiguity.
- `collections_agent`: customer outcome; avoid over-labeling operational calls as
  compliance unless the right is clearly invoked.
- `linguist`: literal speech act, scope, hedging, and channel wording.
- `taxonomy_auditor`: definition and edge-case coverage.
- `qa_analyst`: production convention and common scorecard shapes.

The dissent source matters. A compliance dissent means regulatory risk. A
linguist dissent means wording/scope ambiguity. A taxonomy dissent means the
definition or edge case may not support the label.

## Correctness Vote

Use a 3-persona Codex major-vote panel for label correctness.

Default panel:

- `taxonomy_auditor`
- `linguist`
- `qa_analyst`

Compliance-sensitive panel:

- `compliance_officer`
- `taxonomy_auditor`
- `linguist`

Operational/payment panel:

- `collections_agent`
- `taxonomy_auditor`
- `qa_analyst`

Agreement interpretation:

- `3/3`: canonical label candidate.
- `2/3`: boundary label; keep it, but judge the arguments.
- `1/3`: challenging label; usually `L3` or taxonomy-review material.
- unsupported arguments: reject.

## Judge Layer

After the 3 voters, run a judge over the transcript and voter arguments.

The judge does not merely count votes. It checks whether the winning argument is
definition-grounded, transcript-grounded, and able to rule out the strongest
competing labels.

Judge outputs:

- `accepted_label`
- `agreement_count`
- `judge_accepts_argument`
- `sample_status`: `canonical`, `boundary`, `challenging`, `reject`
- `complexity_grade`: `L1`, `L2`, `L3`, `reject`
- `evidence_span`
- `dissent_analysis`

## Complexity Grades

`L1`: single intent, straightforward and clear. One assistant/user pair is often
enough. Expected vote shape is usually `3/3`.

`L2`: one dominant intent. Minor or subtle secondary intents exist, but the
target intent should overrule them. Expected vote shape is `3/3` or strong `2/3`
with judge approval.

`L3`: competing intents, ambiguous phase, noisy ASR, postprocess conflict, or a
near coin flip. Expected vote shape can be `2/3` or `1/3`. These are not bad
samples; they are challenging samples.

## Sample Usability Review

After correctness, run target-code signal review.

This asks a different question: does the transcript provide a good reusable
sample for the accepted or target label?

Rules:

- `3/3` usable plus judge-accepted correctness: good canonical sample.
- `2/3` usable: boundary sample.
- `1/3` usable: challenging sample if the arguments are plausible.
- weak transcript evidence: reject as a canonical sample even if production
  emitted the label.

The current 5-persona signal-review pilot showed this distinction:

- `ATY`: accepted, `5/5` usable, strong signal.
- `WRN`: accepted, `5/5` usable, strong signal.
- `PPIF`: production label exists and transcript has payment-promise signal, but
  `0/5` usable because the evidence was weak and possibly contradicted by the
  live-agent transfer exception.

## Postcall Rerun Gate

Postcall rerun is a compatibility and reproducibility gate. It is not the only
truth gate.

The rerun contract needs:

- `conversation_id`
- `conversation_history`
- `raw_call_assignment`
- `dict_variable`
- `list_current_state`
- `recipient_details`
- `label_v0` / `label_call_code`

The monitor sample builder now emits the raw fields needed to create this CSV.
`src/intent_extract/prepare_postcall_rerun.py` converts
`intent_sample.csv.gz` into `postcall_rerun_input.csv`.

Dry-run validation command:

```bash
conda run -n dev python src/run/postcall_batch.py \
  --input-csv output/<run>/postcall_rerun_input.csv \
  --out-dir output/<run>/postcall_rerun_dry_run \
  --dry-run \
  --no-redis \
  --accuracy-label-col label_v0
```

On this local machine, direct dry-run currently blocks on
`src/postcall/rerun.py` loading the hardcoded dotenv path
`/media/sdb/working/llm_voice/explo/binh2/kompato/.env.demo`. The CSV prep layer
is wired; actual rerun validation should run in the environment where that
postcall dotenv / agent-server path is available, or after making the dotenv path
configurable.

## Executable Pipeline

Compile gate:

```bash
python3 -m py_compile \
  src/intent_extract/monitor_sample.py \
  src/intent_extract/prepare_postcall_rerun.py \
  testing/codex/run_monitor_major_vote.py \
  testing/codex/run_monitor_signal_review.py
```

Launcher:

```bash
scripts/ll_affirm_signal_pipeline.sh
```

Common variants:

```bash
# Build sample and postcall-rerun input only.
RUN_CODEX=0 scripts/ll_affirm_signal_pipeline.sh

# Run 3-persona correctness vote plus judge, but skip signal review.
RUN_MAJOR_VOTE=1 RUN_CODEX=0 scripts/ll_affirm_signal_pipeline.sh

# Use compliance-sensitive correctness panel.
RUN_MAJOR_VOTE=1 MAJOR_PANEL=compliance RUN_CODEX=0 scripts/ll_affirm_signal_pipeline.sh

# Try postcall dry-run validator after building rerun CSV.
RUN_POSTCALL_DRY=1 RUN_CODEX=0 scripts/ll_affirm_signal_pipeline.sh
```

## Current Implemented Files

- `src/intent_extract/monitor_sample.py`: builds Datadog-backed monitor sample.
- `src/intent_extract/prepare_postcall_rerun.py`: creates postcall rerun CSV.
- `testing/codex/run_monitor_major_vote.py`: 3-persona correctness vote plus
  judge.
- `testing/codex/run_monitor_signal_review.py`: target-code sample usability
  review.
- `scripts/ll_affirm_signal_pipeline.sh`: local launcher.

## Final Sample Decision Contract

A sample is canonical only when:

1. monitor reconstruction is complete;
2. 3-persona correctness vote is `3/3`;
3. judge accepts the argument;
4. signal review agrees the transcript has usable evidence;
5. postcall rerun CSV is valid and rerun result is compatible.

Boundary and challenging samples are preserved, not discarded. They are useful
for L2/L3 evaluation and taxonomy stress testing.
