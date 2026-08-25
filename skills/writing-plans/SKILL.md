---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

### Development Boundary

Unless the human's current request is explicitly a separate production release
or publication task, an implementation plan ends after code, automated
verification, and any explicitly authorized non-production test-environment
acceptance. Production deployment, production data or configuration changes,
live traffic/feature/ad enablement, app-store submission, and production rollout
monitoring or rollback execution never become numbered development tasks.

If the spec includes that release work, preserve it only as one line:
`Production release: outside this plan; requires a separate user request.` Do
not expand it into steps, commands, a runbook, or a task. A later explicit
release request is a separate task; this boundary does not authorize it.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate. When drawing task boundaries: fold setup,
configuration, scaffolding, and documentation steps into the task whose
deliverable needs them; split only where a reviewer could meaningfully
reject one task while approving its neighbor. Each task ends with an
independently testable deliverable.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

<!-- Legacy/untyped only; typed-v1 replaces these three fields with the
verbatim Mission and Architecture Summary from its spec. -->
**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Spec:** [path to the spec/design doc this plan implements — the plan
argues from the spec, so the spec travels with it; executors read both]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

---
```

### typed-v1 Header Extension

When the referenced spec declares `Authority Model: typed-v1`, add this line
after `**Spec:**`:

```markdown
**Authority Model:** typed-v1
```

For typed-v1, replace the legacy `Goal`, `Architecture`, and `Tech Stack`
fields with the complete `## Mission and Architecture Summary — Non-normative`
section copied verbatim from the spec. Copy its heading, note, and all seven
subsections without rewriting, shortening, or normalizing them. Place it after
the Authority Model and before Global Constraints. The summary is context, not
authority: it does not generate tasks or review findings, and any conflict is
resolved in favor of approved `HC-*` and `BI-*`.

In `Global Constraints`, copy the exact approved `HC-*` and `BI-*` text. Also
include the spec's `NG-*`, `DE-*`, and the standard Deviation Policy so
`task-brief` can select the items relevant to each task. Do not copy every
design paragraph or `DD-*` item into Global Constraints.

For an untyped or legacy spec, omit the authority-model line and keep the
existing v6.3 full-spec behavior: the plan argues from the whole spec and every
spec requirement remains binding.

## Task Structure

````markdown
### Task N: [Component Name]

<!-- Required for typed-v1 plans; omit for legacy plans. -->
**Contract Coverage:** HC-1, BI-1
**Enables Evidence:** DE-1
**Forbidden Scope:** NG-1
**Design Defaults:** DD-1 — [recommended design summary]; replaceable under the deviation policy.

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

### typed-v1 Plan Compilation

For typed-v1, map every `HC-*`, `BI-*`, and `DE-*` item to at least one task,
except production-release evidence excluded by the Development Boundary above.
`DD-*` guides the proposed implementation but remains replaceable. `INFO-*` and `NG-*` never generate a task; cite relevant `NG-*` under `Forbidden Scope`
instead. An infrastructure or enabling task cites the contract items and done
evidence it enables—it does not create authority for itself.

Each typed task must contain all four authority fields shown above. Copy the
relevant IDs, and include a short `DD-*` summary or `None`; do not paste the
whole spec. The implementation steps describe a good default, but must not
claim that literal adherence to a `DD-*` is required.

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Authority coverage and development boundary:** For typed-v1, map every
`HC-*`, `BI-*`, and `DE-*` to a task except production-release evidence, and
confirm no task exists only for `DD-*`, `INFO-*`, or `NG-*`. Confirm the plan
contains no production release task unless the current request is explicitly a
separate release task.
Confirm the Mission and Architecture Summary is an exact verbatim copy of the
spec section, not a second summary written for the plan.
For an untyped legacy spec, keep the existing full-spec check: every spec
section and requirement must map to a task, subject to the same Development
Boundary. List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move
on. If you find a non-release spec requirement with no task, add the task.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
