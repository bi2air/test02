https://app.datadoghq.com/logs?query=service%3A%2Acapybara%2A%20%2A%3AFaxETavniVsiBJ8APpLZuA&agg_m=count&agg_m_source=base&agg_t=count&clustering_pattern_field_path=message&cols=host%2Cservice%2C%40event&messageDisplay=inline&refresh_mode=sliding&storage=hot&stream_sort=time%2Casc&viz=stream&from_ts=1774234406324&to_ts=1774839206324&live=true

---

## Stage 1 — group-code LLM (`evaluate_and_save` / `run_5rows.py`)

**Input (test set CSV):** path you pass as `csv_path` — must include at least `conversation_history` (and usually `label_group`, `label_call_code`, etc.). Example:

`output/testset_clean_20260327.csv`

**Output (stage-1 LLM run):** paths you set as `out_result_csv`, `out_metrics_json`, `out_group_accuracy_csv`. Example pattern:

- `output/result_groupcode_eval_<timestamp>.csv` — per row: `prompt_render` (plain text sent to the LLM), `llm_raw_response`, `reasoning`, `predict_groupcodes`, `predict_groupcode_top1`, `match`, …
- `output/result_groupcode_eval_metrics_<timestamp>.json`
- `output/result_groupcode_eval_group_accuracy_<timestamp>.csv`

**Command:** there is no single argparse entrypoint; run the small driver (edit paths inside the file first):

```bash
cd /home/binhnguyen2/postcall
python run_5rows.py
```

Optional — **build prompts only** (no LLM), from the same input CSV:

```bash
cd /home/binhnguyen2/postcall
python group_prompt_pipeline.py \
  --csv output/testset_clean_20260327.csv \
  --group-def-yaml yamlfiles/group_def_20260328.yaml \
  --template-yaml yamlfiles/group_callcode_template.yaml \
  --out output/testset_with_prompt_render.csv
```

---

## Stage 2 — call-code LLM (consumes stage-1 CSV)

**Input:** stage-1 result CSV, e.g. `output/result_groupcode_eval_20260327_1631.csv` (`conversation_history`, `predict_groupcodes`).

**Output:** `output/result_callcode_eval_<timestamp>.csv` (column `prompt_render_call_code` = full rendered `prompt_detect_call_code_v1` for v2).

```bash
cd /home/binhnguyen2/postcall
python run_stage2_from_group_eval.py \
  --input output/result_groupcode_eval_20260327_1631.csv \
  --v2-multi-group \
  --write-metrics
```\


# need to make workflow
- new call code definition -->
- given a tree that we are all agreen (Deposition call code)
- update the each stage 1, including covers, edge case, not include, few-shots

