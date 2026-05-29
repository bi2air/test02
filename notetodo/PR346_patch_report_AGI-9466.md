# PR346 Review Update (AGI-9466)

## Objective
Keep PR review informative and concise, aligned to AGI-9466 and the Apr-17 master CSV update, while keeping diffs limited to `postcall` scope.

## What We Updated
1. Prompt cleanup in `main.yaml`
- Clearer, shorter instructions.
- Explicit stage guidance for `Phone Number / Pre-IDV / Post-IDV`.
- Mini-Miranda and `negotiation_from_script` cues for Post-IDV.
- Simplified reflection gate condition in `prompt_detect_call_code` by removing:
  - `and not var_def_not_render and show_reflection_variable_section`

2. Boundary corrections in `main.yaml`
- Priority ordering note aligned to rule (higher priority near list end).
- `INC` vs `DEC` clarified (alive-incapacitated vs deceased).
- `TSR/PTSR/WFR/PWFR` stage and transfer-outcome boundaries tightened.
- `IDF` constrained to verification-failure (not wrong-party).
- `DIS` vs `PPA` clarified as opposite planes.
- `FTP` condition made safer with explicit defaults for missing values.

3. New AGI-9466 Apr-17 scope absorbed
- Added new MASTER codes in `call_code_descriptions`:
  - `TPM` (Third-Party Message)
  - `FDP` (Future Dated Payment)
  - `TLM` (Transfer Loan Modification)
- Wording kept in MASTER-code terms only (no Affirm mapping labels in classifier text).
- Removed cross-mapping wording that can confuse classifier-facing definitions (example: `Affirm PDJ` reference).

## Delta from Apr-17 CSV
`Kompato - Call Disposition Reference - Call Codes_apr17_1153.csv` adds:
- `TPM -> PLM`
- `FDP -> HPP`
- `TLM -> TLM`

No other row-level changes detected versus Apr-16 CSV.

## Branch and Diff Hygiene (Latest)
- `paco-agi9466` was rebuilt on top of `origin/affirm/AGI-9466`.
- Only `postcall` content was re-applied and kept.
- Verified non-`postcall` section of `scripts/en_collin_kompato_affirm/main.yaml` is identical to `origin/affirm/AGI-9466`.
- Current branch head:
  - `6483c95` `AGI-9466: keep only postcall updates on affirm baseline`
  - `bf1592e` `AGI-9466: simplify postcall reflection gate in prompt template`

## Test/QA Assets
Golden cases and write-up are maintained in `notetodo` (not inside `en_collin_kompato_affirm`):
- `notetodo/golden_cases.yaml`
- `notetodo/PR346_patch_report_AGI-9466.md`

Coverage includes original AGI-9466 high-risk set plus new Apr-17 codes and boundary pairs.

## Recommended PR Comment (short)
- Scope aligned to AGI-9466 and Apr-17 CSV.
- Prompt and boundary rules were tightened for stage-aware classification.
- Prompt reflection gate was simplified for stable rendering behavior.
- Added three new MASTER-code definitions (`TPM`, `FDP`, `TLM`) with clear tie-break logic.
- Diff hygiene enforced: non-`postcall` content preserved from `affirm/AGI-9466`; only `postcall` template/definitions/postprocess changed.
- Golden boundary pack prepared in `notetodo` for runner integration and regression checks.
