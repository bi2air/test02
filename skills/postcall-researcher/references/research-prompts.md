# Research Prompts

Read this only when the user asks for broad industry research, call-code taxonomy discovery, or exploratory framing before a MECE review.

## External starting point

- Reddit thread: `https://www.reddit.com/r/ClaudeAI/comments/1ok9v3d/i_tested_30_community_claude_skills_for_a_week/`
- Treat the thread as messy inspiration, not as authoritative evidence. If it is needed, browse it directly and extract only useful patterns.

## Task 1: Industry framing

Research how telephone debt-collection postcall analysis is typically done, especially whether other systems use postcall classification. The end goal is still call-code classification after calls, but the work should borrow useful standard practice rather than merely preserving the current taxonomy.

## Task 2: Coverage review

Check whether the current call-code set covers the observed data. Clarify each code, identify situations that fall between categories, and recommend a new code only when the gap is meaningful. If the gap is minor or can be solved by a better definition, prefer upgrading the existing code.

## Task 3: Change impact

Assess how well the current call-code system works and whether it should change. Any new or revised code should be MECE enough to apply across debt-collection calls, not only a single client or one narrow example.

Prioritize changes on two axes:

- Pipeline breakage: high-priority failures that block the call from proceeding or imply other call handling is impossible.
- Business objective: high-value payment or next-action signals that the bot failed to capture or route.
- Compliance risk: cases where continued calling or discussing details creates regulatory concern, especially when the listener indicates they are not the customer.
