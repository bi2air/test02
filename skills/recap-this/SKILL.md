---
name: recap-this
description: Use when the user invokes `/recap-this` to save a recap of the current session as a timestamped markdown file under `docs/session_recap/`. Triggers on a single, explicit slash invocation; not for general summarisation requests.
---

# recap-this

## Overview

Persist a single, self-contained recap of the current session to disk so a future session (Claude or human) can pick up cold. Output is one markdown file per topic; the file must be readable without conversation history.

## Output location

```
/Users/binh.nguyen2/working/postcall/docs/session_recap/YYYYMMDD_<topic-slug>.md
```

- `YYYYMMDD` = today's date (UTC).
- `<topic-slug>` = lowercase, hyphen-separated, 3-6 words. Names a concrete artifact or decision (`postcall-researcher-skill-split`, `sif-postprocess-decision`, `agi9466-L2-baseline-run`) — never a generic theme like `postcall-work` or `misc-updates`.
- If the exact filename already exists (same-day re-run on the same topic), suffix with `_v2`, `_v3`, etc. **Never overwrite** — matches `feedback_never_overwrite` memory.
- If `docs/session_recap/` does not exist, create it.

## Required file header (per `feedback_docs_timestamp`)

```markdown
# <Human-readable topic title>

- timestamp: YYYY-MM-DD HH:MM UTC / HH:MM local
- session topic: <one-sentence framing>
- git branch: <current branch>
- recap author: claude (model id)
```

## Required sections (in this order)

1. **TL;DR** — 2-4 bullets. What the session accomplished + what's left.
2. **What was tried** — chronological list of substantive actions. Outcomes, not tool-call narrative.
3. **What was decided** — explicit user calls or agreed approaches, with rationale. Quote the user when the wording matters.
4. **Artifacts** — files created/modified with absolute paths. Group as `created:` and `modified:`.
5. **Blockers / open questions** — anything that needs the user before it can proceed. Each item: what's blocked, what's needed to unblock.
6. **Next steps** — concrete, ordered. Include cost/time estimate per item when known (per `feedback_autonomy_cost_time_thresholds`).

## Optional sections (include only when present in the session)

- **Memory updates** — list any auto-memory entries written or modified.
- **Reproducible commands** — only commands worth re-running (rsync recipes, eval invocations, ssh launches). Skip one-off `ls` / `grep`.
- **Durable insights** — lessons that should probably become their own skill or memory entry later. Flag as `TODO: consider promoting to memory/skill`.

## What to leave out

- Tool-call narrative ("I ran `ls`, then read the file, then..."). Recap *outcomes*, not *process*.
- Speculation about user intent. If unclear, list under blockers as an open question.
- Restating content already in `docs/`. Link instead: `see docs/main_yaml_sanity_eval_20260508.md`.
- Emojis, ornate formatting, marketing language (per `feedback_ui_preferences`).

## Multi-topic sessions

If the session spans 2+ distinct topics (e.g. skill split + new feature spec + bug diagnosis), write **one file per topic** rather than one mega-recap. Each must stand alone.

## Quick reference

| Step | Action |
| --- | --- |
| 1 | Determine UTC date → `YYYYMMDD` |
| 2 | Pick topic slug from the most concrete artifact (file modified, decision made) |
| 3 | Check `docs/session_recap/YYYYMMDD_<slug>.md` — if exists, append `_v2`, etc. |
| 4 | Compose recap using the required-sections template |
| 5 | Write file, report path back to the user |
| 6 | If session had multiple topics: repeat steps 2-5 per topic |

## Acceptance criteria

The recap is complete iff:
- File exists at the exact path described above
- File starts with the required header block (timestamp + topic + branch)
- All six required sections are present, in order
- No section restates content reachable in 1 click from a linked `docs/` file
- The recap is self-contained (a cold reader understands without conversation context)

## Example output filename

Session that produced this skill itself would land as:

```
/Users/binh.nguyen2/working/postcall/docs/session_recap/20260511_postcall-researcher-skill-split.md
```

## After writing

Report the saved path back to the user. Do not summarise the recap inline — the file *is* the summary.
