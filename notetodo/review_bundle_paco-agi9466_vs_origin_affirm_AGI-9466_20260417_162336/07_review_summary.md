# Reviewer-Friendly Postcall PR Summary

- Base: `origin/affirm/AGI-9466`
- Head: `paco-agi9466`
- Repo: `/Users/binh.nguyen2/working/postcall/agi-sm-dsci-configs`
- Generated: `20260417_162336`

## Quick Signals
- Changed files count: 1
- Non-postcall identical in `scripts/en_collin_kompato_affirm/main.yaml`: YES
- Postcall diff hunks: 9

## Files in This Bundle
1. `01_full_diff_stat.txt` — branch-level diff stat
2. `02_changed_files.txt` — changed file list
3. `03_mainyaml_diff.patch` — full diff for `scripts/en_collin_kompato_affirm/main.yaml`
4. `06_postcall_only_diff.patch` — reviewer-focused postcall-only diff

## Review Guidance
- Primary review file: `06_postcall_only_diff.patch`
- Confirm scope policy:
  - Only `postcall` template/definitions/postprocess should change.
  - If `Non-postcall identical` is `NO`, stop and re-check merge method.
- Keep reviewer notes concise:
  - Jira links
  - source-of-truth CSV/doc versions
  - what changed
  - risk and remaining tasks
