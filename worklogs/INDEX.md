# Worklog Index — Binh Thanh Nguyen (2)

Master list of daily worklog pages, status per working day in the active window (2026-03-14 → 2026-05-04), and harvest plan for filling the gaps from other working folders.

## Tier 1 — weekly roll-ups (cherry-push strategy)

Push to Confluence only when there's a deliverable. Ranked by reviewer impact.

| Tier | Weekly page | Span | Status | Why push |
|---|---|---|---|---|
| 🌟 S | `weekly/Week-of-2026-04-24.md` | Apr 20-24 (+Apr 18 Sat appendix) | DRAFT — push-ready | **AGI-7771 closes 91%** + AGI-9466 SM-bot pilot + autoDebtor refactor + Phase-0 ship — flagship week |
| 🌟 S | `weekly/Week-of-2026-05-01.md` | Apr 27-May 1 (holiday week) | DRAFT — push-ready | Six-version pilot ladder + Kompato NNP first-hit + AGI-9144 Milestone 1 setup; sustained holiday-week effort |
| 💪 A | `weekly/Week-of-2026-04-17.md` | Apr 13-17 (+Apr 11 Sat appendix) | DRAFT — push-ready | AGI-8795 cache closure + AGI-8632 63.5% baseline + R4 testset + DCI-323 RCA closed + DCI-322 sampler shipped |
| 💪 A | `weekly/Week-of-2026-04-10.md` | Apr 6-10 | DRAFT — push-ready | Postcall v1 ship + AGI-6751 NA-code/DIM resolution + AGI-8795 cache kickoff + DCI-321 Tsel CSV4 33w/28w headline |
| 🤔 B | `weekly/Week-of-2026-03-27.md` | Mar 23-27 (+Sat Mar 28 appendix) | DRAFT — push pending sanitization | AGI-6751+AGI-7440 (Mar 23 already published) + AGI-8632 groupcode triple-run lead-up to v1 ship + DCI-328 worker6_v4 — DCI-328 detail kept light per pre-contract sensitivity |
| 🔒 C | `weekly/Week-of-2026-04-03.md` | Mar 30-Apr 3 | DRAFT — local-only | exp03 → exp04 → exp05c rename → `--whynot` → 5 Affirm classifier runs; sustained R&D without a closure metric (closure lands Apr 9-13 cache-experiment line) |
| 🔒 C | `weekly/Week-of-2026-03-20.md` | Mar 16-20 | DRAFT — local-only | DCI-328 MBF pre-contract: enrichment + reverse-mapping (Mon) → sample arrival + TS_Schema (Wed) → Telco Schema Matching Playbook v1+v2 (Thu) → 3-iteration coverage compounding +41% / +27% (Fri). **Customer-domain detail kept generic per sensitivity.** |

**Push order (when approved):** S-tier first (AGI-7771 close week, then Milestone 1 setup week), A-tier second (cache lineage + multi-flagship week), B-tier (Mar 27) only after MBF sanitization confirmation.

**Tier conventions:**
- 🌟 S — flagship deliverable, ready to push.
- 💪 A — strong deliverable, ready to push.
- 🤔 B — has deliverable, but needs sensitivity decision before push.
- 🔒 C — local-only, no Confluence push. Either sensitive (MBF) or no closure metric (R&D iteration).



## Status calendar

Working days = Mon–Fri **plus** any weekend/holiday with verifiable activity (per the policy: weekend/holiday commits attribute to the next working day's Appendix, but the effort still counts).

Legend: ✅ filled · 📝 stub ready (evidence collected, awaiting harvest) · ⚪ dark (no evidence — needs disposition) · 🇻🇳 holiday · 🛠 weekend/holiday with effort attributed to a Mon

| Date | Day | Status | Local file | Confluence (LR) | Evidence summary |
|---|---|---|---|---|---|
| 2026-03-16 | Mon | 📝 stub | `daily/2026-03-16.md` | — | **MBF coordination-log enrichment + reverse-mapping** — 3 Python scripts at 13:33 (`enrich_csv.py` 15.4 KB, `reverse_mapping.py` 5.9 KB, `reverse_mapping_v2.py` 20.2 KB) + legacy `mbf_csv4/mbf_cs_airflow_202208/.git` first git access at 14:29 |
| 2026-03-17 | Tue | ⚪ dark-disposition | `daily/2026-03-17.md` | — | **No mbf-folder evidence** — disposition note written 2026-05-04. Likely meetings / reading / non-keystroke effort between Mar 16 scripting and Mar 18 17:16 censored-sample arrival |
| 2026-03-18 | Wed | 📝 stub | `daily/2026-03-18.md` | — | **Censored MBF sample bundle arrives 17:16** (`fintech_sample_data_20260314_censored/`, 28 CSVs, 4 MB) + first `outputs/mbf_data_2026 - TS_Schema.csv` (11.3 KB) drops at 17:20 |
| 2026-03-19 | Thu | 📝 stub | `daily/2026-03-19.md` | — | **Telco Schema Matching Playbook v1+v2 authored** — `matching_schema_telco_playbook.md` (12.6 KB, 14:16) + `_v2.md` (20.7 KB, 15:27) + `schema_check01.ipynb` (12:13) + `ts_etl_mbf_schema.json` (78 KB, 11:08) + **first audit/gap/schema_mapping/unmapped_files run** at 15:57 |
| 2026-03-20 | Fri | 📝 stub | `daily/2026-03-20.md` | — | **3 pipeline iterations**: Run #2 (10:05, censored+new TS schema, +41% schema-mapping rows) + encrypted sample arrives 11:20 (`fintech_data_sample_encrypted_20260320/`, 28 CSVs, 8.5 MB) + Run #3 (11:33, encrypted, +27%) + **`DICTIONARY MBF_2.xlsx` (8.4 MB)** lands 12:57 |
| 2026-03-23 | Mon | ✅ filled | `daily/2026-03-23.md` | [5209162096](https://trustingsocial1.atlassian.net/wiki/spaces/LR/pages/5209162096) | AGI-6751 + AGI-7440 JIRA comments |
| 2026-03-24 | Tue | 📝 stub | `daily/2026-03-24.md` | — | **MBF schema-audit project bootstrap** (mbf/schema): PLAYBOOK_idata_clean_column_trace_v1.md (13:28) + tc_clean_column_airflow_map_v1.csv + dictionary v3 build (`build_mbf_dictionary_v3.py`, `mbf_dictionary_v3.xlsx`) + 28-file `fintech_data_sample_encrypted_20260320` ingestion |
| 2026-03-25 | Wed | 📝 stub | `daily/2026-03-25.md` | — | **MBF clean-data audit pipeline v1** (mbf/schema): `scripts/build_clean_data_audit.py` (12:04) + `clean_data_audit_20260325.csv` (65 KB, 14:26) + `sysconf_clean_paths_inventory.tsv` + `src/search_mbf_text.py` + `src/search_mbf_codebase.py` |
| 2026-03-26 | Thu | 📝 stub | `daily/2026-03-26.md` | — | **MBF audit 5-LLM bake-off** (mbf/schema): `gemini31/`, `opus46/`, `gpt54/`, `sonnet46/`, `opus46v2/` parallel runs + `evaluation_report.md` (18 KB) + `reflection.md` (16 KB) + `consitution.md` → `consitution_v2.md` + evening `worker6_v2/` + `worker6_v2_nb/` |
| 2026-03-27 | Fri | 📝 stub | `daily/2026-03-27.md` | — | **AGI-8632** — groupcode eval triple-run on zero `output/zz_202603/20260327/` (16:04, 16:31, base) + per-group accuracy + metrics JSON + `testset_clean_20260327.csv` (lead-up to Sat Mar 28 v1 ship). **+ DCI-328 (MBF):** `consitution_v3.md` (25 KB, 09:56) + `worker6_v4/` final ship |
| 2026-03-28 | Sat | 🛠 wknd | (→ Mar 30 appendix) | — | 2 commits — `v1 get group code working` · zero `output/zz_202603/20260328/` |
| 2026-03-30 | Mon | 📝 stub | `daily/2026-03-30.md` | — | **AGI-8632** — 6 commits, exp03 two-stage LLM rerank · zero: 21 dirs · Sat Mar 28 weekend Appendix (group-code v1) |
| 2026-03-31 | Tue | 📝 stub | `daily/2026-03-31.md` | — | **AGI-8632** — 2 commits, exp04 stage-code workflow · zero: 10 dirs · `docs/workflow/stage_definition_run_20260331.md` |
| 2026-04-01 | Wed | 📝 stub | `daily/2026-04-01.md` | — | **AGI-8632** — 2 commits, exp05c + `groupcode → stage code` rename · zero: 2 dirs |
| 2026-04-02 | Thu | 📝 stub | `daily/2026-04-02.md` | — | **AGI-8632** — 2 commits, `--whynot` argument (explainability for compliance review) · zero: 6 dirs |
| 2026-04-03 | Fri | 📝 stub | `daily/2026-04-03.md` | — | **zero: 15 dirs** — `affirm_20260403_*` (5 runs at 09:20, 11:15, 11:44, 14:57, 15:14) + `team-review/20260403_*` (5 batches at 16:27 → 17:17) |
| 2026-04-06 | Mon | 📝 stub | `daily/2026-04-06.md` | — | **AGI-8632** — 6 commits, postcall v1 + affirm v00 + prompt shorten · zero: 1189 dirs (heaviest weekday) |
| 2026-04-07 | Tue | 📝 stub | `daily/2026-04-07.md` | — | **AGI-8632** — zero: 657 dirs, 3 morning runs (`20260407_0911`, `_0925`, `_1007`) + postcall_debug bundles. **+ DCI-321 (Tsel CSV4 kickoff):** `tsel/csv_code/map.md` + `tks_csv2_3.drawio`. **+ DCI-328 (MBF):** `SAMPLE_MHTT-20260407T080725Z-3-001.zip` (782 KB, 15:07) |
| 2026-04-08 | Wed | 📝 stub | `daily/2026-04-08.md` | — | **DCI-321 / Tsel CSV4 audit** — full top-down DAG mapping (`csv4_pipeline_dag_map.md`+`.drawio`, `layer1_*`, `dag_airflow_detail_map.md`, `csv4_clean_data_audit_report.md`); **33w cold-start / 28w warm** headline; bundle ships Apr 23 09:51. **+ methodology skill ship 17:20:** `reverse-telco-codebase` (skill+reference+`verify_date_arithmetic.py`+13Q self-test) **and sister** `dag-reverse` (notebook-first). **+ MBF parallel (afternoon → 23:13):** `SAMPLE_MHTT/` extract + `audit_mhtt_schema.md` (27 KB) + `audit_mhtt_mapping.csv` + `dag_reverse_clean_data_depth.md` + `audit_mhtt_derivation_supplement.md` + `dag_reverse_102A02_tc_files_needed.md` |
| 2026-04-09 | Thu | ✅ filled · **stale** | `daily/2026-04-09.md` | [5209751757](https://trustingsocial1.atlassian.net/wiki/spaces/LR/pages/5209751757) | **AGI-6751** — NA-codes + DIM definition. **+ AGI-8795** — kpt cache + nturn=0,1 + openrouter A/B (cache-experiment kickoff). Zero: 2029 dirs (biggest day). **Confluence page predates AGI-8795 attribution — needs re-publish.** |
| 2026-04-10 | Fri | 📝 stub | `daily/2026-04-10.md` | — | **AGI-8795** (primary) — 9 commits, Anthropic SDK direct path + prompt-caching experiment script + 3 timestamped runs (15:15 / 17:10 / 17:59); local-first init + zero merge. **+ AGI-7771** (downstream) — A/B/C/D backtest inherits the cache work. |
| 2026-04-11 | Sat | 🛠 wknd · AGI-8795 | (→ Apr 13 appendix) | — | **AGI-8795** — 7-variant prompt-cache sweep at `output/experiments_20260411_155805/` (exp1_baseline, exp2_v1_reorder, exp3_v2_clean, **exp4_v1_no_vars** ← render-without-variable variant, exp5_v3_twophase, exp6_v3b_advisory, exp7_claude_sonnet) · zero: 1561 dirs |
| 2026-04-13 | Mon | 📝 stub | `daily/2026-04-13.md` | — | **AGI-8795** (primary) — cache-experiment closure (4 commits): `843139f finish cache experiment`. Winning variant pinned. **+ AGI-7771** (downstream) — A/B/C/D backtest runs on this variant; lands Apr 23 91% delivery within budget. **+ DCI-335** — DCI-side caching ticket. **+ DCI-323 kickoff** — `csv3_digitize_debug_kit/` scripts 1-4. Apr 11 Sat weekend Appendix. |
| 2026-04-14 | Tue | 📝 stub | `daily/2026-04-14.md` | — | **AGI-8632** ([C09] disposition audit) — compliance testset baseline 63.5% (HCH/NCV/DNC under bar; WCR label-issue) · **DCI-323** — recalibrate-brackets (5_) + ref/current CDF diagnostic (6_) + Apr 11 prod log capture |
| 2026-04-15 | Wed | 📝 stub | `daily/2026-04-15.md` | — | **AGI-8632** — R4 testset (120 rows) + Flask `/compliance` UI + 3-run consensus (Shell Splice) · **DCI-323** — `7_recalibrate_from_rawscore.py` (538L, final deliverable) + source fix in `csv3-prod/.../base.py` · **DCI-322** — 10k-SID stratified sampler spec (Tier 0/Tier 1 + EXACT/~99% score-fidelity) |
| 2026-04-16 | Thu | 📝 stub | `daily/2026-04-16.md` | — | **DCI-322** — 10k-SID stratified sampler stats run; 7h Spark trial (1k primaries → 51,787 hop1 → 41,859 active = 80.8% pass across 50 sid_groups); validated archive-fallback after Apr 13 disposal. *(prior "adversarial pipeline" memory ref belongs to Sat Apr 18 — corrected)* |
| 2026-04-17 | Fri | 📝 stub | `daily/2026-04-17.md` | — | 5 commits — adversarial registry/pilot setup (Phase-0 prep). **+ DCI-322 ship:** `sample_10k_sids.py` (706L) + `read_with_archive.py` (73L) + Apr 14–17 retrospective (`session_20260414_17_technical_reference.md`) |
| 2026-04-18 | Sat | 🛠 wknd | (→ Apr 20 appendix) | — | **17 commits + 2 memory** — Phase-0 adversarial pilot ship: registry v3/v4, debug v3/v4, HTML viewer, pilot results, PDCA report |
| 2026-04-19 | Sun | 🛠 wknd | (→ Apr 20 appendix) | — | memory: `project_postprocess_state_trap` (synthetic Post-IDV trap) |
| 2026-04-20 | Mon | 📝 stub | `daily/2026-04-20.md` | — | 4 commits + 6 memory — `autoDebtor → vpbPostCall` rename, canonical postcall paths, Datadog bracket, dd_utils cursor bug, Affirm↔MASTER mapping |
| 2026-04-21 | Tue | ✅ filled | `daily/2026-04-21.md` | [5208539615](https://trustingsocial1.atlassian.net/wiki/spaces/LR/pages/5208539615) | AGI-7771 ack + Route-A backtest pipeline |
| 2026-04-22 | Wed | ✅ filled | `daily/2026-04-22.md` | [5209849988](https://trustingsocial1.atlassian.net/wiki/spaces/LR/pages/5209849988) | DCI-321/322/328 + standardized reporting infra |
| 2026-04-23 | Thu | ✅ filled | `daily/2026-04-23.md` | [5209424254](https://trustingsocial1.atlassian.net/wiki/spaces/LR/pages/5209424254) | AGI-7771 91% delivery + 7 DCI sprint scope |
| 2026-04-24 | Fri | ✅ filled | `daily/2026-04-24.md` | [5209391389](https://trustingsocial1.atlassian.net/wiki/spaces/LR/pages/5209391389) | SM-bot pilot (18 convs) + real-transcript baseline (40.7%) |
| 2026-04-25 | Sat | 🛠 wknd | (→ Apr 27 appendix) | — | memory: `project_agi9466_score5_threshold` (91% classifier-match on score=5 review) · 420 output dirs (full QA sweep across 11 ACs) |
| 2026-04-26 | Sun | 🛠 wknd | (→ Apr 27 appendix) | — | `from_zero/agi9466_dashboard_20260426_2134.md` + `agi9466_debug_20260426_2134.csv` (Sun evening 21:34) |
| 2026-04-27 | Mon | 📝 stub | `daily/2026-04-27.md` | — | **AGI-9466** — dashboard v2 (per-AC pilot state) + compare vs Apr 26 v1 baseline + per-row debug at 17:52 · Apr 25-26 weekend appendix |
| 2026-04-28 | Tue | 📝 stub | `daily/2026-04-28.md` | — | **AGI-9466** — misclassify-by-phase v2 (09:37) + dashboard v3 (15:29) + `v3_rerunpc/` cross-validation (17:33) + `v3_merged/` final state (22:26) |
| 2026-04-29 | Wed | 📝 stub | `daily/2026-04-29.md` | — | **AGI-9466** — six-version pilot ladder v4_pilot → v5_pilot → v5b → v5_nturn → v6 → v7 in 10h (sets up May 1 Kompato NNP first-hit) |
| 2026-04-30 | Thu | 🛠 holiday | (→ May 4 appendix) | — | Reunification Day · `from_zero/NNP_L1_v2_20260430_2141/` + 24 sub-files (25 total) |
| 2026-05-01 | Fri | 🛠 holiday | (→ May 4 appendix) | — | Labour Day · memory: `project_kompato_nnp_first_hit_may01` · **71 timestamped files** + `v7_dev_e3dfee76/` (pinned build, 21:34) + `NNP_single_v8_20260501_214329/` (21:43) |
| 2026-05-02 | Sat | 🛠 wknd | (→ May 4 appendix) | — | `kompato_FDP_3styles/` (21:28), `kompato_FDP_synth_050_L1/`, `kompato_NNP_3rcas/` (14:55), `kompato_NNP_temps/` (20:37) — 2 timestamped files + 4 dirs |
| 2026-05-03 | Sun | 🛠 wknd | (→ May 4 appendix) | — | `kompato_pilot_L1/` (01:20 early Sun + 23:26 v2) |
| 2026-05-04 | Mon | ✅ filled | `daily/2026-05-04.md` | [5209161978](https://trustingsocial1.atlassian.net/wiki/spaces/LR/pages/5209161978) | AGI-9144 Milestone 1 (NORMAL 25/33, BASIC 22/33, both 33/33 found-in) + NNP/RTP boundary · `kompato_NNP_boundary/` (12:43) + `kompato_pilot_v3` (09:20), `_v3b` (09:31), `_v4_boundary` (12:27) · **needs Apr 30 / May 1 / May 2-3 appendix update** |

**Counts:** 7 filled · **26 stubs ready** (added Mar 16/18/19/20 from `mbf/` root rescue 2026-05-04, on top of Mar 24/25/26 `mbf/schema/` MBF bid-prep rescue) · **1 dark-with-disposition** (Mar 17 — disposition note written, no evidence to upgrade) · 2 holidays-with-effort · 8 weekends-with-effort

**MBF (Mobifone) bid-prep lineage — owned by [DCI-328](https://trustingsocial1.atlassian.net/browse/DCI-328) "[MBF] Data schema check up [pre-contract]"** (sub-task of [DCI-321](https://trustingsocial1.atlassian.net/browse/DCI-321) Telco Score Maintenance, ✅ Done, retrospectively filed Apr 22). A separate client engagement that ran in parallel with the postcall/Tsel/Affirm work, anchored first at `mbf/` root (Mar 16-23, the **schema-matching pipeline** phase) then at `mbf/schema/` (Mar 24+, the **schema-audit project** phase). Full timeline: Mar 16 (Coordination Log enrichment scripts `enrich_csv.py` + `reverse_mapping*.py`; legacy `mbf_csv4/mbf_cs_airflow_202208/` first read) → Mar 17 (dark, disposition only) → Mar 18 (censored sample arrives) → Mar 19 (`matching_schema_telco_playbook.md` v1+v2 + first 4-output pipeline run) → Mar 20 (3 pipeline iterations + encrypted sample + `DICTIONARY MBF_2.xlsx`) → Mar 22 evening (`dictionary_mbf2_screenshot_samples/` OCR + GPT-4o vision pipeline) → Mar 23 (6 pipeline iterations on the dictionary; AGI work parallel) → Mar 24 (project bootstrap at `mbf/schema/`, PLAYBOOK + dictionary v3) → Mar 25 (audit pipeline + first run) → Mar 26 (5-LLM bake-off + 2 constitutions + reflection + worker6_v2) → Mar 27 (consitution_v3 + worker6_v4 ship) → Apr 7 (MHTT sample bundle arrives) → Apr 8 (MHTT schema audit ships, 5 deliverable files).

**Zero server output volumes (per day, top 10):** Apr 9 (2029) · Apr 11 Sat (1561) · Apr 28 Tue (1381) · Apr 29 Wed (1243) · Apr 6 (1189) · Apr 7 (657) · Apr 26 Sun (534) · Apr 3 (15) · Mar 27 (1) · etc. — full counts via `ssh binhnguyen2@192.168.5.250 'find /media/sdb/working/llm_voice/explo/binh2/postcall/output -maxdepth 4 -type d | grep -oE "2026[01][0-9][0-3][0-9]" | sort | uniq -c'`.

**Render-with/without-variable work** is the **`exp4_v1_no_vars`** variant in the Apr 11 Sat cache sweep — the prompt variant where call codes ship without inline `{{var}} = value` substitutions. Plus `r3uLp_render_server*` directories on Apr 20 — render server v1/v2 work. Both are referenced in their respective stubs.

**Atlassian MCP status (2026-05-04):**
- ✅ `mcp__claude_ai_Atlassian__*` (SA `Scoring AI`) — Confluence LR write + DCI Jira read
- ❌ `mcp__atlassian__*` (personal, binh.nguyen2@) — disconnected; AGI Jira queries gated until reconnect

## Evidence sources (cross-check all four for every gap)

1. **JIRA** — comments authored by `62b03df39abb660ab1497155` (binh.nguyen2). Use `mcp__atlassian__*` (personal auth) for AGI; `mcp__claude_ai_Atlassian__*` (SA) for DCI/Confluence only.
2. **git log** — author email `binh.nguyen2@trustingsocial.com` OR `binh@nguyen2` (zero server). Repos scanned so far: `postcall`, `kai-code-disposition`, `agi_llm_deployment`, `convai-commons`. Other potential repos: `paco-agent`, `scoringai-agent-main`, `agi-sm-dsci-configs`, plus any local Sophia/CAI repos.
3. **Project memory** — `~/.claude/projects/-Users-binh-nguyen2-working-postcall/memory/project_*.md` (dated capture entries from prior sessions).
4. **`output/` timestamps** — `output/<exp_name>_YYYYMMDD_HHMMSS/` and nested. Aggregate to dates with `find … | grep -oE "2026[01][0-9][0-3][0-9]"`.

## Harvest plan per stub

Each stub at `daily/2026-MM-DD.md` is pre-filled with what's already in scope from the four sources above. To finish a stub:

1. **Open the stub file** — known evidence is in the `Known evidence` section.
2. **Visit the harvest folder** — the stub's `Harvest TODO` block lists other repos and patterns to scan.
3. **Drop new evidence** into the STAR skeleton (`Why` / `🛠 What I did` / `Result` / `Credits` / `Links`).
4. **Push to Confluence** — title `YYYY-MM-DD [BN2]`, parent folder `5209391331` in space LR (3883008707).

## Folders to harvest from when you visit

- `paco/` (paco-agent, paco/docs) — call-code QC technical reference, postcall reviewer notes, ticket-pull skill guide.
- `paco/scoringai-agent-main/` — likely has its own git history with date-tagged commits.
- `agi_llm_deployment/` — separate repo with Sophia/Affirm action commits. Filter strictly by your email; multiple "Binh" authors exist.
- `agi-sm-dsci-configs/` — yaml configs; `git log` per file for change dates.
- `convai-commons/` — shared library; few commits but real ones.
- Any **personal notebooks** (Jupyter `.ipynb`) — check first-cell timestamps and modified dates.
- **Slack / chat logs** (if exported) — message timestamps for non-coding work (planning, reviews, mentoring).

## Dark days — needs disposition (1 remaining after 2026-05-04 mbf-root rescue)

Down from 13 → 4 → **1** after the second-pass harvest of `mbf/` root (sibling to the already-harvested `mbf/schema/`). The mbf-root scan promoted Mar 16 (weak → stub) and Mar 18-20 (dark → stub) using filesystem mtimes — the entire MBF schema-matching pipeline phase (playbook v1+v2 + 3 pipeline iterations + sample arrivals + dictionary ingestion) is now sourced.

- **Mar 17 (Tue)** — only remaining dark day. Disposition note written at `daily/2026-03-17.md` (2026-05-04). Sits between Mar 16 scripting (13:33) and Mar 18 censored-sample arrival (17:16) — likely meetings / reading / non-keystroke effort. Cannot upgrade without Slack export, calendar, or a fifth source folder.

**Already-resolved (kept here for audit trail):**
- ~~Mar 16~~ — coordination-log enrichment + reverse-mapping (mbf-root rescue 2026-05-04).
- ~~Mar 18-20~~ — sample arrivals + playbook v1+v2 + 3 pipeline iterations + DICTIONARY MBF_2 (mbf-root rescue 2026-05-04).
- ~~Mar 24-27~~ — MBF schema-audit work, now stubbed (mbf/schema rescue).
- ~~Apr 3, 7, 8~~ — Apr 7 had `tsel/csv_code/` afternoon kickoff + MHTT zip arrival; Apr 8 had Tsel CSV4 audit + MHTT schema audit.
- ~~Apr 16~~ — DCI-322 10k-SID stratified sampler stats run.
- ~~Apr 28, 29~~ — postcall classifier iteration.

For Mar 17, decide: (a) keep the disposition note as the final state, or (b) check Slack export / Google Calendar / `agi_llm_deployment` / `vpb*` / `tsel*` for the missing trail.

## Pending Confluence work (when batch fires)

1. Push 12 new pages from completed stubs (`2026-03-30` through `2026-04-27` per the index).
2. Update `2026-05-04 [BN2]` (page id `5209161978`) — add `## Appendix — Holiday effort` section with Apr 30 + May 1 work.
3. Confirm Confluence sidebar order is descending (manual drag in UI).
