---
name: pair-programming
description: "Human-agent pair programming workflow with triage, planning, optional grill-me, and an implementation loop of user code → review → tests."
---

# Pair Programming

A structured human-agent pair programming workflow. The agent acts as the
organizer, reviewer, and test-writer while the human writes the functional
implementation. Use this when the user wants to collaboratively implement
a feature, fix a bug, or make a change with the agent in a supporting role.

## When to Use

- The user says "let's pair program" or "let's work on X together"
- The user wants to do the implementation while the agent handles planning, review, and testing
- The user says "I'll write the code, you handle the plan/review/tests"
- Any task where the human writes code and the agent provides structured support around it

Do **not** use this skill when:
- The user wants the agent to implement everything autonomously
- The task is a quick one-off question or exploration
- The change is tiny (single-line fix, typo, config tweak) — just handle it directly

## Procedure

### Phase 1: Triage & Plan

The goal of this phase is to define a clear, scoped plan with enumerated steps
that the user and agent agree on.

1. **Ask what the user wants to work on.**
   - Keep it open: "What are we working on today?"
   - Let the user describe the task in their own words.

2. **Clarify scope and approach.**
   - Ask targeted clarifying questions about the task boundaries, expected
     behavior, edge cases, and potential risks.
   - Explore the codebase using `ctx_search`, `git log`, `read`, and `grep`
     to understand relevant files, existing patterns, and history.
   - Document any constraints, non-goals, or design decisions that emerge.

3. **Write the implementation plan.**
   - Create `plan.md` at the project root with enumerated steps.
   - Ensure `plan.md` is listed in `.gitignore` (append to `.gitignore` if
     not already there) — this is a working document, not committed.
   - Each step should be an actionable unit — something the user can implement
     in one sitting (usually 10-50 lines of functional change).
   - Use this format:

     ```markdown
     # Implementation Plan: <Title>

     ## Context
     <brief summary of what this is and why>

     ## Steps
     1. **Step 1: <short description>**
        - Details: what needs to change, which files, what approach
        - Acceptance: how we'll know it's done

     2. **Step 2: <short description>**
        - ...

     ## Non-goals
     - <things explicitly out of scope>
     ```

4. **Present the plan to the user.**
   - Summarize the approach and each step at a high level.
   - Ask: "Does this plan look good? Any changes?"
   - Iterate on the plan based on user feedback until it's approved.

### Phase 2: Optional Grill-me

If the user says "grill me", "stress-test this plan", or similar:

1. Invoke the **grill-me** skill by reading and following its procedure.
2. Go through the plan decisions one at a time, exploring the codebase
   and using design questioning.
3. Optionally refine `plan.md` based on what emerges.

### Phase 3: Implementation Loop

For each step in `plan.md`, in order:

#### Step A — User implements functional changes

1. Inform the user which step to work on:
   > "Step N: <title>. Here's what needs to change: <details>. I'll wait for
   > you to implement it — just say 'done' when you're ready for review."

2. Include enough context so the user knows exactly what to change:
   - Which files to modify
   - What the change should accomplish
   - Any relevant patterns or conventions

3. **Wait for the user to signal completion.** The user says "done" or "next".
   Do not proceed until the user explicitly signals they are finished.

#### Step B — Review the changes

1. **Ensure the diff is captured.** Run `git diff` (or equivalent) to see what
   the user changed. If the project isn't under version control, use
   `ctx_execute` with `diff` or similar.

2. **Invoke the reviewer subagent.**

   ```typescript
   subagent({
     agent: "reviewer",
     task: `Review the following changes for correctness, regressions, edge cases, and code quality. Do NOT edit any files — report findings only.

   Diff:
   ${diff}

   Focus on:
   - Correctness: does the logic handle all cases?
   - Edge cases: are there unhandled boundary conditions?
   - Code quality: does it follow project conventions?
   - Risks: any regressions or breaking changes?

   Report specific file:line references and severity for each finding.`,
     context: "fresh"
   })
   ```

3. **Synthesize the reviewer's findings.** Do NOT present raw reviewer output.
   Instead:
   - Group findings by severity (blockers, suggestions, nits)
   - Add your own assessment of what's worth acting on now vs. deferring
   - Present the synthesized summary to the user concisely

4. **Let the user decide.**
   - Ask: "Any of these review points you want to address before we move on?"
   - If the user fixes something, capture the new diff and optionally
     re-review if the changes are significant.
   - Otherwise, proceed to tests.

#### Step C — Write tests

1. **Invoke the test-writer subagent.**

   ```typescript
   subagent({
     agent: "pair-programming-test-writer",
     task: `Write tests for the following changes and run them to verify they pass.

   The changes were made for: <step N description>

   Changed files:
   <list of changed files from git diff>

   Diff:
   ${diff}

   Auto-detect the project's test framework from <package.json, go.mod, Cargo.toml, etc.>
   and follow existing test conventions in the project.

   Requirements:
   - Write tests that cover the new/changed functionality
   - Match existing test style and conventions in the project
   - Run the tests and confirm they pass
   - Report which tests were written, the test command used, and the result`,
     context: "fresh"
   })
   ```

2. **Report test results to the user.**
   - Which tests were written (file paths)
   - The test command that was run
   - Whether tests passed or failed
   - If tests failed: summarize the failures

#### Step D — Advance the loop

1. Mark the step as completed in `plan.md` (append `✅ Step N complete` after
   the step description, or add a completion log at the bottom of the file).

2. Ask the user:
   > "Step N complete. Continue to step N+1 (<description>)?"

3. If yes: go to Step A for the next step.
4. If no (or all steps done): proceed to completion.

### Completion

When all steps are done (or the user stops early):

1. **Summarize what was accomplished.**
   - What was implemented
   - Review findings and what was addressed
   - Test coverage added
   - Any known limitations or deferred items

2. **Clean up.** Optionally remove `plan.md` or archive it depending on
   project convention.

## Pitfalls

- **Do not race the user.** Wait for the explicit "done" signal before
  proceeding to review. Do not start reviewing or testing while the user
  is still coding.
- **Do not edit the user's functional code.** The user owns the
  implementation. You can review it and suggest fixes, but the user makes
  the changes. Your role is organize, review, and write tests.
- **Do not present raw subagent output.** Always synthesize review findings
  into a clear, structured summary. Raw output is too verbose and noisy.
- **Do not skip the triage phase.** Jumping straight into coding without a
  plan leads to scope creep and confusion. Take the time to write plan.md.
- **Do not let the review step block indefinitely.** If the reviewer flags
  minor nits and the user doesn't want to address them, accept that and
  move on. Not every finding must be fixed.
- **Do not start tests before review is resolved.** Tests should validate
  the final state of the implementation. If the user makes changes after
  review, capture the updated diff before writing tests.
- **Do not modify plan.md without telling the user.** If the plan needs
  to change mid-loop (e.g., a step is larger than expected), discuss it
  with the user first.
- **Auto-detecting test frameworks is best-effort.** If detection fails,
  ask the user what test framework and command to use rather than guessing
  wrong.
- **Keep steps small.** If a step feels like it will take more than 30
  minutes of coding, split it. Small steps keep the review focused and
  the loop tight.

## Verification

1. `plan.md` exists at the project root with clear enumerated steps.
2. User approved the plan before implementation started.
3. Each implementation step was preceded by clear instructions to the user.
4. Review step used a fresh-context reviewer with "do not edit" constraint.
5. Reviewer findings were synthesized (not raw) before presenting to user.
6. Test-writer subagent wrote tests and ran them successfully.
7. Each step was explicitly signed off before advancing to the next.

