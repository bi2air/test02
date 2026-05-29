# postcall-researcher — current state (2026-05-11)

- timestamp: 2026-05-11 (local) — author: split from SKILL.md per session 2026-05-11
- half-life: ~30 days. Re-date this file whenever active paths, accuracy targets, or pipeline scripts shift.
- companion to: `../SKILL.md` (durable: principles, tiers, hard rules, methodology, cheat sheet)

## Verify-first preamble (run BEFORE any pipeline command)

```bash
# Confirm these still exist locally — if any fail, halt and ask the user.
test -f agi-sm-dsci-configs/scripts/en_collin_kompato_affirm/main.yaml \
  && echo "OK: production main.yaml" \
  || echo "MISSING: production main.yaml — halt"
test -f src/postcall/rerun.py && echo "OK: rerun.py"  || echo "MISSING: rerun.py"
test -f src/kompato/debtor/agi9466_chat_arena.py \
  && echo "OK: chat-arena" \
  || echo "MISSING: chat-arena"
ls input/testset_main_yaml_v1*.csv && echo "OK: testsets" || echo "MISSING: testsets"
```

If any path is missing → halt and ask the user for the current equivalent. Do not substitute a plausibly-related path.

---

## Active pipeline (as of 2026-05-11)

| Layer | Active | Deprecated / dead |
| --- | --- | --- |
| Classifier entrypoint (local rerun) | `src/postcall/rerun.py` (CSV mode; `--bracket-json` mode is WIP on the current branch) | — |
| Classifier batch runner (zero) | `run_postcall_batch.py` (lives on zero, push via rsync) | — |
| Production prompt source | `agi-sm-dsci-configs/scripts/en_collin_kompato_affirm/main.yaml` | `yamlfiles/affirm_code_defs.yaml` |
| Compact prompt variant | `docs/plan/call_code_descriptions_basic.yaml` (May 4) → spliced into `main_basic.yaml` | — |
| Synth conversation generator | `src/kompato/debtor/agi9466_chat_arena.py` (per-state caching, 0% truncation) | `src/vpbPostCall/src/adversarial/*` (entire tree — slated for git removal) |
| Synth pin | `paco-agi9466-v2 @ d43bc8e` | — |
| Postprocess fixture helpers | `src/postcall/fake_dtmf_complete.py`, `src/postcall/fake_human_response.py` | — |
| Eval reports | `docs/main_yaml_sanity_eval_*.md`, `docs/report/*` | `experiment_accuracy*.md` at repo root (deleted) |

> Anything under `src/vpbPostCall/` is read-only / archival. Do not extend it; do not cite it as canonical even if it still has files matching old grep patterns.

---

## Active testsets

| Testset CSV | Rows | Notes |
| --- | --- | --- |
| `input/testset_main_yaml_v1.csv` | 124 | 40 codes at k=3, 3 under-sampled (LGH n=2, PRS n=1, WFR n=1), 6 absent (NKP, CSM, FTP, PAY, SIF, PIF) |
| `input/testset_main_yaml_v1b.csv` | 127 | v1 + 3 SIF L1 rows (all misclassified PSIF — known limitation, not a regression) |
| `input/testset_agi7771_v1.csv` | 17 | C&D backtest, sha256 `d55a5796` |
| `input/vpbPostCall/synthetic_rca_100.csv` | 100 | Affirm-outbound RCAs, seed=42 — pair with AGI-9466 AC seeds via `src/kompato/debtor/run_ac_with_rca.py` |

---

## Current accuracy state (May 8 v1 baseline)

| Segment | Accuracy | Target | Status |
| --- | --- | --- | --- |
| Overall | 86/124 = 69.4% | — | — |
| **Compliance (Tier A)** | 29/36 = **80.6%** | ≥95% | **FAIL** — WRN/DNC/HCH/NCV/WCR are the bleeders |
| Ops (Tier B) | 57/88 = 64.8% | ≥90% | FAIL |
| Real-prod (apr9) | 66/88 = 75.0% | — | — |
| Synth (smbot_full) | 18/32 = 56.2% | — | Synth ~2× harder than real-prod — expected |

**Top operational confusions (n≥2)**: INC→DEC, CAB→HCH, EPT→IDV, HTT→IDV, TLM→IDV, PPA→HCH.

---

## Two-layer classification (architectural)

| Layer | How decided | Eval method |
| --- | --- | --- |
| **LLM-emit** | Classifier reads `call_code_descriptions` and picks from transcript content | Mode 2 (definition iteration) |
| **Postprocess-only** | Remapped from LLM output by `postprocess_conditions` on `dict_variable` signals (DTMF, payment_results, transfer_result) | Fixture rows with patched `dict_variable` — **NOT** Mode 2 |
| **System-rule** | Set by dialer / silence-detection from call-duration / no-transcript signals | Not LLM-evaluable |

**Layer assignments (May 8):**

- Postprocess-only: `PAY`, `PIF`, `WFR`, `FTP`
- System-rule: `NKP`
- LLM-emit but post-transfer-signal-dependent (currently bleed to pre-transfer cousins): `SIF` (→PSIF), `EPT` (→IDV), `HTT` (→IDV), `TLM` (→IDV)
- All others: pure LLM-emit

**Open architectural decision (SIF/EPT/HTT/TLM)**: pick before scaling synth.

- (a) Add prompt-level promote-rules keyed on `dict_variable.payment_results.posted` / `settlement_completed` / `transfer_result`.
- (b) Move into `postprocess_conditions` like PAY/PIF (cleaner — matches actual signal source).

---

## Known stuck ACs (L1 paco-agi9466-v2 @ d43bc8e)

| AC | Code | Exact match | Reason | Status |
| --- | --- | --- | --- | --- |
| AC-001 | NNP | 100% NORMAL exact, but L2/L3 generation fails | LLM can't sustain pure no-justification decline; volunteers dispute/hardship | Documented LLM limitation |
| AC-003 | GVT | 0% exact (100% found_in) | TSR catch-all drift — rep-routing language wins singleton pick | Cleanest TSR-drift signal |
| AC-005 | DCP | 0% NORMAL / 33% BASIC exact | TSR-drift + BASIC IDV over-inclusive | — |
| AC-007 | EPT-BASIC | 0% exact | BASIC IDV scope spans post-IDV negotiation outcome | Cleanest BASIC IDV-scope signal |
| AC-011 | TLM-NORMAL | 67% exact | TSR-drift via `exc_cb` terminal state | — |

100% `found_in` across all 11 ACs in both NORMAL and BASIC — the gap is *which code wins* in the singleton pick, not whether the right code is reachable.

---

## Active AC seeds awaiting review (drafted 2026-05-08)

For the 3 missing LLM-emit codes (LGH/PRS/CSM). Full YAML in `docs/main_yaml_remaining_codes_plan_20260508.md`.

- **AC-016 LGH** (Legal Guardian Handling — POA / court-appointed guardian)
- **AC-017 PRS** (In Prison — current-tense incarceration)
- **AC-018 CSM** (SCRA Active Military)

Next step on approval: chat-arena gen for these 3 codes × 3 RCAs L1 → v1c testset (~130 rows) → re-run sanity batch (~$1.50, ~50 min total).

---

## Zero server execution (durable host, current paths)

- Host: `192.168.5.250` (zero) — durable
- Account: `binhnguyen2`
- Workdir: `/media/sdb/working/llm_voice/explo/binh2/postcall` — current location, may move
- Python venv: `/media/sdb/working/llm_voice/explo/binh2/dirvenv/py310/bin/python` — current
- LLM backend env: `POSTCALL_LLM_BACKEND=llm_hub VAR_DEF_NOT_RENDER=1`
- No GitHub auth on zero — push configs/testsets/batch-runner via `rsync` before runs:

```bash
rsync -avz input/testset_main_yaml_v1.csv \
  binhnguyen2@192.168.5.250:/media/sdb/working/llm_voice/explo/binh2/postcall/input/
rsync -avz agi-sm-dsci-configs/scripts/en_collin_kompato_affirm/main.yaml \
  binhnguyen2@192.168.5.250:/media/sdb/working/llm_voice/explo/binh2/postcall/yamlfiles/main.yaml
```

---

## Datadog bracket pattern (for diagnostic reruns)

Anchor on `@event:(StartPostCallAnalysis OR EndPostCallAnalysis)` for a `call_id`. Pull all events in the bracket from `service:*capybara*`. Recover `dict_variable` + `list_current_state` from `StartPostCallAnalysis`. Recover `conversation_history` + `prompt_detect_call_code` from `PromptDetectCallCode` events.

Replay via `src/postcall/rerun.py --bracket-json <path>` (WIP on current branch, +463 lines).

`dd_utils` has a known pagination bug (reads `links.next` URL before `meta.page.after` cursor) — patched in `testing/scripts/pull_datadog.py` sync path. Use that for high-volume calls.

---

## Mode 2 concrete command (current, May 2026)

For the durable methodology see `../SKILL.md` § Reproducible operating loop. The current command line:

```bash
# Local (small / quick):
conda activate dev
python src/postcall/rerun.py \
  --input-csv input/testset_main_yaml_v1.csv \
  --postcall-yaml agi-sm-dsci-configs/scripts/en_collin_kompato_affirm/main.yaml \
  --out-dir output/deftest_$(date +%Y%m%d)_<tag>

# Zero (full batch, recommended for ≥50 rows):
ssh binhnguyen2@192.168.5.250
cd /media/sdb/working/llm_voice/explo/binh2/postcall
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate /media/sdb/working/llm_voice/explo/binh2/dirvenv/py310
export POSTCALL_LLM_BACKEND=llm_hub VAR_DEF_NOT_RENDER=1
nohup python3 run_postcall_batch.py \
  --input-csv input/testset_main_yaml_v1.csv \
  --postcall-yaml yamlfiles/main.yaml \
  --concurrency 8 --no-redis \
  --out-dir output/main_yaml_v1_full \
  --template prompt_detect_call_code --var-def-not-render \
  > output/main_yaml_v1_full.log 2>&1 &
```

Then `rsync -avz binhnguyen2@192.168.5.250:.../output/main_yaml_v1_full output/from_zero/` to pull results.

---

## When to re-date this file

Bump to a new dated copy (e.g. `current-state-20260601.md`) when ANY of:

- A pipeline script moves or is replaced (e.g. `agi9466_chat_arena.py` → next-gen)
- A new testset becomes the canonical baseline
- An architectural fact changes (a code shifts from LLM-emit to postprocess-only, or vice versa)
- Accuracy targets or actuals shift materially (>5pp)
- A blocker is resolved (e.g. SIF promote-rule decision lands)

Keep prior dated versions — they're an audit trail of decisions and pipeline state at known points in time.
