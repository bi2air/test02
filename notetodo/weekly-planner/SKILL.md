---
name: weekly-planner
description: Build and maintain a practical weekly execution plan aligned to personal OKRs, using live Jira status + OKR sources + decision register, with explicit achievability gates and multi-week continuity.
---

# Weekly Planner

## Purpose

Use this skill to turn aligned information into achievable weekly execution.

Primary outputs:
- `jira/OKR_2026Q2_planner.md` (current-week plan)
- `jira/WEEKEND_PLANNER.md` (weekend continuation)
- `jira/Q2_EXECUTION_PLAN.md` (multi-week runway)
- Optional: updates to `jira/INDEX.md` links and `jira/POSTCALL_DECISIONS.md`

## Required Inputs (pull every planning cycle)

1. Jira live status for active tickets (assigned tickets + explicit include list).
2. OKR source page and exact KR wording.
3. Local tracker context:
   - `jira/INDEX.md`
   - `jira/POSTCALL_DECISIONS.md`
   - key baseline tickets (for call-code context: e.g., `AGI-4695`).

## Core Distinction

- **O2 Strategy**: priority, scope boundaries, KPI definition, decision logic.
- **O4 Automation**: bot/check implementation, trigger process, operationalization.

Every planned item must map to O2, O4, or both.

## Achievability Gate (mandatory)

For each KR, always include this 6-field block:

- **Target this week**
- **Current baseline**
- **Required delta**
- **Owner**
- **Primary blocker**
- **Fallback if blocked**

If any field is missing, mark the KR as **not execution-ready** and add a prep task.

## Workflow

### Step 1: Pull and normalize resources

- Pull active Jira tickets and statuses.
- Pull exact KR text from OKR page.
- Pull latest decisions and overrides from `POSTCALL_DECISIONS.md`.
- Pull baseline references needed for current scope.

### Step 2: Map KR -> ticket ownership

- Map each KR to current tickets.
- Identify missing ownership ticket(s).
- Propose self-assign/new subtask when ownership is missing.

### Step 3: Build current-week plan

Write/update `jira/OKR_2026Q2_planner.md` with:

1. Personal KR section (exact wording).
2. O2 vs O4 split.
3. KR-to-ticket mapping table.
4. This-week execution plan (Mon-Fri).
5. Achievability gate per KR.
6. Friday measurable checkpoints.

### Step 4: Build weekend continuation

Write/update `jira/WEEKEND_PLANNER.md` with:

1. Saturday (O2-heavy) tasks.
2. Sunday (O4-heavy) tasks.
3. Monday-ready outputs tied to KR deltas.

### Step 5: Maintain Q2 runway

Write/update `jira/Q2_EXECUTION_PLAN.md` with week-by-week milestones until Q2 end:

- KR1 and KR2 phase progression
- expected measurable outputs per week
- carry-over risk and dependency handling

Then ensure weekly plan references Q2 plan milestones.

## Output Rules

- Use exact KR names/thresholds from source.
- Keep language professional and concise.
- Do not use private analogies in external-facing planner files.
- Separate strategy outcomes from automation artifacts clearly.
- Include measurable checkpoints every week.

## Quality Checks

Before finishing:

1. KR wording exactly matches source.
2. Every KR has achievability gate fields filled.
3. O2 and O4 sections both present and non-overlapping.
4. Missing ownership is explicitly flagged with self-assign action.
5. Weekly plan references Q2 execution milestones.
