# Daily Worklog

Generate a daily worklog sourced from JIRA tickets, with a per-ticket evidence-cited STAR block. Output is always a local markdown copy and optionally a Confluence page under the LR space's "Daily work log" folder.

## Audience: company AI-agent reviewer

The worklog is **read by an automated AI reviewer first**, a human reviewer second. Three implications shape every decision below:

1. **Every claim must be locally verifiable.** The reviewer can't run code, open `.pkl` artifacts, or read your laptop's git log. So every claim cites a JIRA comment timestamp, a file path inside the repo, a git commit hash, or a `memory/*.md` entry. The reviewer reads the cite to confirm; you don't get credit for unverifiable narrative.
2. **The "What I did" section is the load-bearing element.** Reviewers skim. If your contribution is buried in paragraph three of a wall of context, the reviewer scores it as low-effort. Wrap the action in a blockquote callout (`> ### 🛠 What I did`) so it visually dominates the page.
3. **Jargon must be defined inline.** Project-internal terms like `NORMAL` / `BASIC` (AGI-9466 classifier paths), `L1` / `L2` / `L3` (persona registers), `RCA` (Root Cause Analysis = persona's reason for non-payment), `CDS` / `CAD` / `VCD` / `RTP` (call-code abbreviations), `pre-IDV` vs `post-IDV` (compliance tier boundary) — define on first use. The reviewer doesn't have your team context.
4. **Prefer human-friendly time phrasing.** In external-facing prose, avoid machine-like exact timestamps (`HH:mm:ss +TZ`) unless strictly required to disambiguate. Prefer `that day`, `this morning`, `this afternoon`, or date-only phrasing.

## Arguments

`$ARGUMENTS` — Optional, space-separated tokens in any order:

- **date**: `YYYY-MM-DD` format (e.g. `2026-04-20`). Defaults to today.
- **mode**: optional. `publish` (default) or `local-only`.
- **confluence_parent**: Required when `mode=publish`. Confluence parent page URL or numeric page ID to publish under.

Examples:
- `/daily-worklog 12345678` — today, publish under page ID 12345678
- `/daily-worklog 2026-04-21 12345678` — specific date, publish under page ID 12345678
- `/daily-worklog 2026-04-21 https://trustingsocial1.atlassian.net/wiki/spaces/TEAM/pages/12345678` — specific date, custom parent by URL

## Constants

- **JIRA Cloud ID**: `a910bdbc-73bc-4d3e-9e16-f65df6bd9add`
- **JIRA Project**: `AGI`
- **My account**: look up via `mcp__atlassian__atlassianUserInfo`
- **Output directory**: `worklogs/daily/`
- **Workspace root**: current repo root (for local timestamp diff checks)

---

## Step 1: Resolve Target Date, Mode, and Confluence Parent

Parse `$ARGUMENTS` tokens:

1. **Date** — any token matching `YYYY-MM-DD` → `TARGET_DATE`. If absent, use today's date.
2. **Mode** — token `local-only` or `publish` (default = `publish`) → `RUN_MODE`.
3. **Confluence parent** — any remaining token:
   - If it looks like a URL, extract the numeric page ID from the `.../pages/<ID>` path segment → `CONFLUENCE_PARENT_ID`
   - If it is a plain number → `CONFLUENCE_PARENT_ID`
   - If `RUN_MODE = publish` and parent absent → **stop and ask the user to provide a Confluence parent page URL or ID before continuing**

Set:
- `TARGET_DATE` = e.g. `2026-04-21`
- `TARGET_DATE_DISPLAY` = e.g. `Monday, 21 Apr 2026`
- `OUTPUT_FILE` = `worklogs/daily/YYYY-MM-DD.md`
- `RUN_MODE` = `publish` or `local-only`
- `CONFLUENCE_PARENT_ID` = resolved above (required only for publish mode)

---

## Step 2: Fetch JIRA Tickets

Search both boards in parallel:

**AGI Agents board:**
```
project = AGI
AND assignee in (<account_ids>)
AND updatedDate >= "YYYY-MM-DD"
AND updatedDate < "YYYY-MM-DD+1"
ORDER BY status ASC
```

**DS - Credit Insight board (DCI):**
```
project = DCI
AND assignee in (<account_ids>)
AND updatedDate >= "YYYY-MM-DD"
AND updatedDate < "YYYY-MM-DD+1"
ORDER BY status ASC
```

**Contribution sweep (required).** Also run:
```
project in (AGI, DCI)
AND updatedDate >= "YYYY-MM-DD"
AND updatedDate < "YYYY-MM-DD+1"
AND (assignee = currentUser() OR reporter = currentUser() OR commenter = currentUser() OR watcher = currentUser())
ORDER BY updated DESC
```
Use this to capture work you contributed to even if not assigned (for example: investigation support, QA evidence, PR/review support on another owner's ticket).

**Render mode.** Merge AGI + DCI + contribution-sweep results into a **single unified Tickets table** (Step 5 format), deduplicated by ticket key. If neither query returns tickets, write "No JIRA activity on this date." and skip the Details section.

**Milestone capture (required).** Treat these as top-priority contributions and surface them explicitly:
- PR opened for review / review-ready (`green`)
- PR merged to target branch (`dev`/`main`)
- Major deliverable shipped (e.g., AC coverage completed, key analysis completed)
- Cross-ticket impactful support with concrete artifact/evidence

**Retrospective backfill mode (optional).** If the user asks to backfill historical dates from a "seed ticket" (e.g. AGI-7771), derive the date list from the seed's history:
1. Pull the seed's comment list with `mcp__atlassian__getJiraIssue` and filter to comments authored by `currentUser()` — each unique date is a backfill candidate.
2. Optionally pull a wider JQL covering all tickets where the user was involved in the same time window — the union gives a complete contribution calendar:
   ```
   project in (AGI, DCI) AND (assignee = currentUser() OR reporter = currentUser() OR commenter = currentUser() OR watcher = currentUser()) AND updatedDate >= "<lower-bound>" ORDER BY updated DESC
   ```
3. For each unique date in the calendar, run the standard Step 2 → Step 5 → Step 7 flow. Title format `YYYY-MM-DD [BN2]` works as-is for backfill (date-first sort puts them in the right place).

---

## Step 3: Fetch Ticket Details

For each ticket, call `mcp__atlassian__getJiraIssue` with `responseContentFormat: "markdown"` and `fields`:
`["summary","status","priority","issuetype","description","comment","subtasks","issuelinks","parent","created","updated","assignee","reporter"]`.

Use these for rendering:
- `summary`, `status.name`, `status.statusCategory.key`, `priority.name`, `issuetype.name`
- `assignee.displayName`, `reporter.displayName`, `created`, `updated`
- `parent.key` + `parent.fields.summary` + `parent.fields.status.name` (epic / story-parent)
- `subtasks[].{key,fields.summary,fields.status.name}`
- `issuelinks[].{type.inward|outward,inwardIssue|outwardIssue.{key,fields.summary,fields.status.name}}`
- `description` — extract Context, User Story, and Acceptance Criteria sections if structured that way
- `comment.comments[]` — render full chronological timeline, not just the latest
  - **Skip pure noise:** treat a comment as "noise" if its body is only `@`-mentions or empty after stripping. For the daily-worklog Notes column, fall back to the most recent substantive comment (or `—` if none). For the Details / Activity Timeline (see Step 5), still emit the noise comments as a single line ("`@user` ping") so the routing is visible without dominating the table.

---

## Step 4: Group by Status

**Match by `status.statusCategory.key`** (stable across custom workflows), not `status.name` (which can be anything like `Ready4Test`, `In QA`, etc.):

| `statusCategory.key` | Display |
|---|---|
| `new` (To Do / Open / Backlog) | 🔲 To Do |
| `indeterminate` (In Progress / In Review / Ready4Test / etc.) | 🔵 In Progress |
| `done` (Done / Closed / Resolved) | ✅ Done |

For "Blocked" specifically (which lives under `indeterminate` in Jira), check `status.name` matching `/blocked|on hold/i` and override to ⚠️ Blocked. Keep the literal `status.name` next to the emoji in the Status column so the original workflow term is visible (e.g. "🔵 Ready4Test").

---

## Step 4.5: Build Delta Since Last Snapshot

Before writing today's content, compute a baseline and only keep net-new progress:

1. Resolve `PREV_SNAPSHOT_FILE`:
   - Prefer same-day file `worklogs/daily/YYYY-MM-DD.md` if it already exists (rerun case).
   - Else use the latest prior `worklogs/daily/*.md` by date.
2. Resolve `SNAPSHOT_TS`:
   - If `PREV_SNAPSHOT_FILE` contains footer `<sub>Updated: ...</sub>` or legacy `<sub>Generated at: ...</sub>`, parse that timestamp.
   - Else fallback to OS file timestamp: prefer `mtime`, fallback `ctime`.
3. Build three diffs:
   - **Jira diff**: keep ticket/comment/status updates with timestamps `> SNAPSHOT_TS`.
   - **Local workspace diff**: collect files in workspace touched `> SNAPSHOT_TS` (focus on work artifacts only; skip caches/build artifacts).
   - **Worklog snapshot diff**: compare previous snapshot content vs current candidate content and remove repeated unchanged narrative.
4. Reporting rule:
   - Include only newly completed work since `SNAPSHOT_TS`.
   - Include ongoing/TODO items only when there is a new meaningful change (status change, new blocker, new plan, new evidence).
   - If nothing changed, write a short "No net-new progress since last snapshot" section.

This delta gate is mandatory for reruns and recommended for first run of the day when a previous-day snapshot exists.

---

## Step 5: Render Markdown — Compact STAR with "What I did" callout

### Page-level structure

```markdown
# {DAY_OF_WEEK}, {DD MMM YYYY} (Binh Thanh Nguyen (2))

## Major Milestones

- {only if present; 1-4 bullets max. Ship/merge/review-ready items first}

## Tickets

| # | Ticket | Status | Headline |
|---|--------|--------|----------|
| 1 | [{KEY}](url) — {short summary} | {emoji} {status.name} | {action-verb-led, what *I* did, with the headline metric or outcome if available} |
| 2 | … | … | … |

---

## Delta Since Last Snapshot

- Baseline snapshot: `{PREV_SNAPSHOT_FILE or "none"}`
- Baseline timestamp: `{SNAPSHOT_TS or "n/a"}`
- Jira net-new updates: `{count and ticket keys}`
- Local workspace net-new artifacts: `{key files changed since baseline}`
- Ongoing/TODO updates kept: `{tickets with real status/blocker/plan changes only}`

---

## {KEY} · {short summary}

**Why.** {1-2 sentences. The issue + why it matters + any project-jargon defined inline. Skip if the ticket body covers it and there's no jargon to define.}

> ### 🛠 What I did
> {1 paragraph or bullet list — *exactly what I personally did*. Cite file paths, sha256s, line counts, commands, comment timestamps, commit hashes. Bold the key deliverables. This is the load-bearing section — invest content here, trim elsewhere.}

**Result.** {Metric-led one-liner ("**91% exact match (10/11 after dedup)**") or close date. Frame in positive terms — "isolated to a ranking-priority finding" beats "still failed". If the result has multiple parts, bullet them.}

**Credits.** {Drop the section entirely unless someone made real effort or added value. Format when present: `Person A (role) — what they did. Person B (role) — what they did.` See "Credits boundary" below.}

**Links.**
- `path/to/file.md` — {1 line: what's in this artifact, why it matters here}
- AGI-XXXX — {1 line: relationship to this work}
- `memory/project_X.md` — {1 line: what's captured + when}

---
(repeat per substantive ticket / workstream)

**Tools.** {Optional one-line: tool used + the cite-able artifact it produced. Omit if no specific cite.}

<sub>Updated: {YYYY/MM/DD HH:mm} (GMT+07)</sub>
```

### Within-day ticket ordering

Order STAR blocks so the **flagship contribution lands first**:

1. **Closures + milestones first** — anything that hit Done today, hit a metric, or shipped a deliverable.
2. **Active in-progress work next** — substantive contributions that aren't yet closed.
3. **Sprint planning / scoping last** — tickets created today as scope buckets (e.g. DCI-321/322/328 created on Apr 22).
4. **Admin / maintenance at the bottom** — status-only updates, ticket triage. Often these don't deserve a STAR block at all; collapse to a "DCI activity today" bullet list.

The Tickets table at the top should follow the same order, so the reviewer sees the headline first in both the table and the Detail section.

### Credits boundary

Credits is a **due-recognition** section, not an attendance list. Apply this filter:

| Contribution type | Credit? |
|---|---|
| Defined a spec, shipped a fix, validated UAT, authored seeds, made a same-day decision that unblocked progress | ✅ Yes — name them with their specific contribution |
| Cc'd on a comment, watched the ticket, was the formal assignee but didn't act today | ❌ No |
| Story owner / Product Owner role-only mention with no action | ❌ No |
| Reviewed in passing, no specific feedback or change | ❌ No |

If after filtering nobody remains, **drop the entire `**Credits.**` line**. Don't pad with "Hai Trung — story owner" when story-owner role didn't make a move that day.

### Links section — bulleted with descriptions

The reviewer can't open files on your laptop. Every linked artifact gets a **1-line description** explaining what it is and why it's referenced here. Example:

```markdown
**Links.**
- `testing/inputs/testset_agi7771_v1.csv` — frozen 17-row golden testset (sha256 `d55a5796`) used by the AGI-7771 backtest.
- `docs/AGI-7771_PIPELINE_A-D.md` — 4-stage pipeline spec (211 lines, producer/consumer per stage).
- AGI-9466 — sister ticket; reuses the same A/B/C/D harness for 11-AC eval.
- `memory/project_route_a_backtest.md` — Apr 21 capture of the harness pattern + tc_id collision fix.
```

Avoid the dot-separated single-line form (`A · B · C`) — fine for `**Tools.**` (one cite), bad for Links (where each artifact needs a meaning).

### Timestamp style

- Default to human-friendly time language in narrative and delta sections:
  - good: `updated that day`, `updated this morning`, `updated this afternoon`
  - avoid: `updated at 2026-05-06 09:31 +07`
- Keep exact times only when two events on the same day would otherwise be ambiguous.
- Footer format is concise and human-readable: `Updated: YYYY/MM/DD HH:mm (GMT+07)`.

### Sizing heuristics

| Day shape | Length |
|---|---|
| Single ticket, comment-only contribution | One STAR block, ~30-50 lines |
| Multi-ticket (3+) substantive work | STAR per substantive ticket, ~30-60 lines each; compact bullet list for low-touch tickets |
| Headline engineering output (testset, harness, infrastructure) | One STAR scoped to *the output*, not per ticket; created tickets just sit in the Tickets table |
| Closed/Done today | Result section names the close date and the headline metric in **bold** |
| Heavy multi-workstream day (rare) | STAR per workstream — can run 100-150 lines total; each workstream ~30-50 lines |

User feedback ratio (Apr 24 retrospective): "not too short, content and context both matter" — when in doubt, **expand the Why with jargon definitions and the Links with descriptions**, not the What I did. The action block stays tight; the surrounding context can breathe.

## Confidentiality Guardrail

- Treat local skills/agents/prompts/configs under user home (for example `~/.codex/skills`, local agent internals, private helper prompts) as private local assets.
- Do NOT include those paths or internal asset details in Jira comments, PR descriptions, Confluence pages, or other external-facing outputs.
- Exception: disclose only when the ticket/task explicitly requires building, updating, or reviewing a skill/agent asset itself.

### Anti-patterns

- **Unsourced narrative.** "Claude Code drove the pipeline scaffolding" without a `docs/X.md` or commit cite is filler. Either cite or cut.
- **Subagent storytelling.** "Subagent 1 dispatched X, Subagent 2 dispatched Y" — unverifiable without transcripts. Replace with concrete cite-able output: "Claude Code drafted `<file>`."
- **Speculative milestone alignment.** "Feeds into the broader strategy of X" without a JIRA link or file is filler. Cite or cut.
- **Generic "Working notes" sections.** STAR + Tools is the structure. If content doesn't fit, it doesn't belong.
- **Implicit credit absorption.** "We ran the classifier" hides who did what. Specifics: "Ran `backtest_from_xlsx.py` on the zero server; Lien validated the result."
- **Blockquote-then-paragraph collapse.** Always emit a blank line after a `>` blockquote before any bold-prefixed paragraph (Confluence's markdown→storage converter merges them otherwise, breaking visual hierarchy).
- **Filler Credits.** If everyone listed is admin-role only, the section makes the page look performative. Drop it.

---

## Step 6: Save Local Output

Write the rendered markdown to `worklogs/daily/YYYY-MM-DD.md`.

Create the directory if it doesn't exist:
```bash
mkdir -p worklogs/daily
```

**If the local Write/Edit is blocked by a project PreToolUse security hook on a verbatim quote from a ticket** (e.g. `security_reminder_hook.py` flags certain Python serialization keywords or other denylisted terms), paraphrase the offending word in **both** the local file and the Confluence body so they stay identical. Don't bypass the hook with `--no-verify` or env overrides. Keep semantics, drop the trigger token (e.g. swap a binary-serialization keyword for `binary serialization` / `.pkl artifact`).

---

## Step 7: Sync to Confluence (Publish Mode Only)

If `RUN_MODE = local-only`, skip this step and do not call Confluence APIs.

Publish the worklog as a child page under the **Daily work log** folder.

**Constants:**
- Confluence Cloud ID: `trustingsocial1.atlassian.net`
- Space ID: `3883008707` (DS Credit Insight / LR space — numeric ID required by API)
- Parent ID: `CONFLUENCE_PARENT_ID` (resolved in Step 1; required — no default). **May be a page OR a folder ID.** The v2 API accepts folder IDs as `parentId`; the create response returns `"parentType": "folder"`. If the user gave a `/wiki/spaces/<KEY>/folder/<ID>` URL, use `<ID>` as-is; do not resolve it to a sub-page.
- Page title: **`YYYY-MM-DD [BN2]`** (date-first for sort order, `[BN2]` PIC tag for namespace).
  - **Why this format:** the LR space is shared with teammates (e.g. Thanh Vo, who keeps his own worklogs at bare `YYYY-MM-DD`). The `[BN2]` tag namespaces yours so title searches don't collide and `updateConfluencePage` always hits the right page. Date-first means the title sorts chronologically in any list view.
  - The H1 inside the body is `# {DayOfWeek}, {DD MMM YYYY} (Binh Thanh Nguyen (2))` — drop the "Daily Worklog —" prefix; it's redundant with the parent folder name.

**MCP routing — try personal auth first, fall back to service account:**

| Tool prefix | Auth | When to use |
|---|---|---|
| `mcp__atlassian__*` | Personal account (binh.nguyen2@trustingsocial.com) | Default. Required for AGI project access. |
| `mcp__claude_ai_Atlassian__*` | Service account (`712020:baad002c-…`) | Fallback. Has write access on the LR Confluence space; doesn't have AGI JIRA access. |

If personal auth's `mcp__atlassian__*` is unavailable mid-batch (the namespace can disconnect — happened Apr 24), fail over to `mcp__claude_ai_Atlassian__*` for Confluence-only operations. The page's `createdBy`/owner stays on the personal account; the SA shows up only as `authorId` on the version row, which is acceptable.

**Logic:**
1. Search for an existing same-day page using `searchConfluenceUsingCql`. **Do NOT use `parent = <CONFLUENCE_PARENT_ID>` in CQL** — CQL's `parent` predicate only matches page parents and silently returns 0 hits when the parent is a folder. Use this instead:
   ```
   title = "YYYY-MM-DD [BN2]" AND space = "LR" AND type = page
   ```
2. If a result is returned → `updateConfluencePage` with the new content (pass the matched page's `id` and the same title to keep it stable).
3. If no result → `createConfluencePage` with `spaceId = "3883008707"`, `parentId = "<CONFLUENCE_PARENT_ID>"`, and the namespaced title.

**Content format:** Pass the rendered markdown body as `body` with `contentFormat: "markdown"`. The MCP converts to Confluence storage format server-side; do not pre-render to HTML/ADF unless you specifically need a feature markdown can't express. The `> ### 🛠 What I did` blockquote-callout renders as a left-bar shaded box in Confluence — that's the visual anchor.

**Page ordering in the folder sidebar — manual.** The MCP's `updateConfluencePage` doesn't expose a `position` parameter, and there's no separate move/reorder tool. After the first publish, ask the user to drag-drop pages in the Confluence UI sidebar into **descending order (most recent date at the top)**:
```
2026-05-04 [BN2]   ← top
2026-04-24 [BN2]
2026-04-23 [BN2]
…
2026-03-23 [BN2]   ← bottom
```
Confluence persists the manual order across future page additions; new pages may need a one-time drag to the top.

**After publishing**, print:
```
Confluence page synced: https://trustingsocial1.atlassian.net/wiki/spaces/LR/pages/<id>/YYYY-MM-DD+BN2
```

**Atlassian deprecation note:** The HTTP+SSE MCP endpoint `mcp.atlassian.com/v1/sse` retires **30 June 2026**. Future MCP config should point at the Streamable HTTP endpoint `mcp.atlassian.com/v1/mcp`.

---

## Final Summary

```
✅ Local file:       worklogs/daily/YYYY-MM-DD.md
✅ Confluence page:  https://trustingsocial1.atlassian.net/wiki/... (publish mode only)
📊 AGI: X tickets (Y Done · Z In Progress · W To Do)
📊 DCI: X tickets (Y Done · Z In Progress · W To Do)
```
