# Typed Spec Authority Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make typed specs preserve human-approved outcomes and invariants as
delivery authority without turning replaceable AI design choices into required
work.

**Architecture:** Keep legacy specs on the existing v6.3 path. For an explicit
`typed-v1` header, compile authority IDs into each plan task, have `task-brief`
prepend the matching authority text, and make implementer/reviewer prompts gate
only on that authority, evidence, forbidden scope, and diff-caused regressions.

**Tech Stack:** Markdown skills and prompt templates, Bash, POSIX `awk`, existing
Claude Code test helpers; no new dependency.

**Spec:** `docs/superpowers/specs/2026-08-24-typed-spec-authority-design.md`

**Authority Model:** typed-v1

## Global Constraints

### Human Contract

- HC-1: New typed specs distinguish normative product authority from replaceable design guidance.
- HC-2: Each execution and review endpoint receives the normative authority relevant to its task.
- HC-3: A review finding blocks delivery only when it cites normative authority, missing acceptance evidence, or a concrete regression introduced by the diff.
- HC-4: Existing untyped specs preserve v6.3 behavior until deliberately migrated.
- HC-5: The fork keeps a clean upstream mirror and isolates custom behavior on a mergeable branch.

### Binding Invariants

- BI-1 (supports HC-1): Only a human-approved `HC-*` or `BI-*` item is normative in a `typed-v1` spec.
- BI-2 (supports HC-2): Normative authority travels by artifact, not by assumed conversation memory.
- BI-3 (supports HC-3): Literal divergence from a Design Default is not itself a review finding.
- BI-4 (supports HC-4): Untyped specs retain legacy binding semantics.
- BI-5 (supports HC-5): `main` remains a clean mirror of released upstream `main`; conflicts are resolved on the customization branch.
- BI-6 (supports NG-6): Public fork commits and any future PR contain no confidential project names, source, or private session artifacts.

### Non-goals

- NG-1: Removing TDD, verification, task review, or final review.
- NG-2: Letting implementers disregard public interfaces, security boundaries, migrations, compatibility constraints, or product semantics.
- NG-3: Rewriting historical specs automatically.
- NG-4: Changing Codex model routing or subagent selection.
- NG-5: Adding a third-party dependency or a separate contract document for every feature.
- NG-6: Publishing an upstream PR without separate human approval and public, non-confidential eval evidence.

### Done Evidence

- DE-1: A v6.3 control promotes an incidental implementation detail to required work in the selected pressure scenarios.
- DE-2: At least five fresh-context treatment samples per scenario preserve every normative item while allowing a smaller conforming implementation.
- DE-3: Deterministic helper tests prove task briefs carry the relevant typed authority.
- DE-4: Legacy untyped scenarios and the existing repository test suite keep their current behavior.

### Deviation Policy

- Changing `HC-*`, `BI-*`, public compatibility, security, or irreversible data behavior requires human approval.
- Replacing a `DD-*` item with a smaller reversible implementation is allowed when all relevant `HC-*` and `BI-*` items still pass; record the reason and evidence.
- Omitting or changing `INFO-*` needs no ruling.
- Behavior forbidden by `NG-*`, or untraceable to an `HC-*`, must not be implemented.

---

### Task 1: Lock the Helper Contract With Failing Tests

**Contract Coverage:** HC-2, HC-4, BI-2, BI-4
**Enables Evidence:** DE-3, DE-4
**Forbidden Scope:** NG-3, NG-5
**Design Defaults:** DD-1 — extend the existing `task-brief` Bash helper rather than adding a parser dependency; replaceable under the deviation policy.

**Files:**
- Modify: `tests/claude-code/test-sdd-workspace.sh`
- Modify: `skills/subagent-driven-development/scripts/task-brief`

**Interfaces:**
- Consumes: existing `task-brief PLAN_FILE TASK_NUMBER [OUTFILE]` CLI.
- Produces: the same CLI, with a typed authority prelude only when the plan declares `**Authority Model:** typed-v1`.

- [ ] **Step 1: Add typed and legacy fixtures to the existing helper test**

  Add assertions that a typed brief contains its spec path, matching `HC-*`,
  `BI-*`, `NG-*`, `DE-*`, task design-default text, and deviation policy; does
  not contain unrelated IDs; and errors when a required task authority field
  is absent. Preserve the existing assertion that an untyped brief is exactly
  the task body.

- [ ] **Step 2: Run the focused test and verify RED**

  Run: `bash tests/claude-code/test-sdd-workspace.sh`

  Expected: FAIL because v6.3 `task-brief` only extracts the task body and does
  not validate or prepend typed authority.

- [ ] **Step 3: Implement the minimal typed prelude**

  Extend `task-brief` so it first extracts the task exactly as today. For a
  typed plan only, validate `Contract Coverage`, `Enables Evidence`, `Forbidden
  Scope`, and `Design Defaults`; collect referenced IDs; copy only matching
  authority lines from the pre-task header; and prepend the declared model,
  spec path, grouped authority, task design default, and deviation policy.
  Leave the legacy output byte-for-byte unchanged.

- [ ] **Step 4: Run focused and shell-lint tests and verify GREEN**

  Run: `bash tests/claude-code/test-sdd-workspace.sh`

  Expected: PASS.

  Run: `bash tests/shell-lint/test-lint-shell.sh`

  Expected: PASS.

- [ ] **Step 5: Commit**

  ```bash
  git add tests/claude-code/test-sdd-workspace.sh skills/subagent-driven-development/scripts/task-brief
  git commit -m "feat: carry typed authority in task briefs"
  ```

### Task 2: Compile Typed Authority During Spec and Plan Authoring

**Contract Coverage:** HC-1, HC-4, BI-1, BI-4
**Enables Evidence:** DE-4
**Forbidden Scope:** NG-1, NG-3, NG-5
**Design Defaults:** DD-2 — teach the existing `brainstorming` and `writing-plans` skills the typed-v1 shape; replaceable under the deviation policy.

**Files:**
- Modify: `skills/brainstorming/SKILL.md`
- Modify: `skills/brainstorming/spec-document-reviewer-prompt.md`
- Modify: `skills/writing-plans/SKILL.md`
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md`
- Create: `tests/claude-code/test-typed-spec-authority-content.sh`
- Modify: `tests/claude-code/run-skill-tests.sh`

**Interfaces:**
- Consumes: approved brainstorming outcome and an optional legacy spec.
- Produces: typed-v1 specs and plans whose tasks carry the four authority fields; legacy authoring remains supported.

- [ ] **Step 1: Add failing content-contract assertions**

  Create a deterministic test that requires the authoring skills and reviewer
  templates to define the typed header, normative `HC-*`/`BI-*` boundary,
  non-binding `DD-*`/`INFO-*` rule, typed task fields, authority-only coverage
  review, and legacy fallback. Register it in the fast skill test list.

- [ ] **Step 2: Run the focused test and verify RED**

  Run: `bash tests/claude-code/test-typed-spec-authority-content.sh`

  Expected: FAIL because v6.3 does not define typed authority.

- [ ] **Step 3: Add the minimum authoring rules**

  Make new brainstorming specs use the compact typed shape and put the human
  review gate on `Human Contract` plus `Binding Invariants`. Make plan creation
  copy exact normative text into `Global Constraints`, map only `HC-*`, `BI-*`,
  and `DE-*` to tasks, and treat `DD-*` as replaceable while `INFO-*` and
  `NG-*` cannot generate work. Preserve the current full-spec rule for untyped
  specs.

- [ ] **Step 4: Run the focused test and verify GREEN**

  Run: `bash tests/claude-code/test-typed-spec-authority-content.sh`

  Expected: PASS.

- [ ] **Step 5: Commit**

  ```bash
  git add skills/brainstorming/SKILL.md skills/brainstorming/spec-document-reviewer-prompt.md skills/writing-plans/SKILL.md skills/writing-plans/plan-document-reviewer-prompt.md tests/claude-code/test-typed-spec-authority-content.sh tests/claude-code/run-skill-tests.sh
  git commit -m "feat: compile typed authority into plans"
  ```

### Task 3: Route Typed Authority Through Implementation and Review

**Contract Coverage:** HC-2, HC-3, BI-2, BI-3
**Enables Evidence:** DE-2, DE-3
**Forbidden Scope:** NG-1, NG-2, NG-4
**Design Defaults:** DD-3 — keep the current two-stage and final review flow, changing only typed authority and blocker eligibility; replaceable under the deviation policy.

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md`
- Modify: `skills/subagent-driven-development/implementer-prompt.md`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md`
- Modify: `skills/subagent-driven-development/re-review-prompt.md`
- Modify: `skills/requesting-code-review/SKILL.md`
- Modify: `skills/requesting-code-review/code-reviewer.md`
- Modify: `tests/claude-code/test-typed-spec-authority-content.sh`

**Interfaces:**
- Consumes: generated typed task brief and review package.
- Produces: typed implementer, task-review, re-review, and final-review decisions whose blockers cite authority/evidence/forbidden scope or a concrete diff-caused regression.

- [ ] **Step 1: Extend the content test with execution and review assertions**

  Require explicit typed/legacy branching, Design Default deviation handling,
  the `Contract and Invariant Compliance` verdict, the blocker eligibility
  list, and advisory-only treatment for non-authoritative improvements.

- [ ] **Step 2: Run the focused test and verify RED**

  Run: `bash tests/claude-code/test-typed-spec-authority-content.sh`

  Expected: FAIL on the v6.3 binding-spec and broad-review wording.

- [ ] **Step 3: Implement the execution and review semantics**

  For typed plans, make the generated brief the artifact authority; allow
  smaller reversible `DD-*` substitutions with a ledgered ruling; prohibit
  uncited scope; and gate task/final fix loops using the design's blocker
  eligibility test. Keep the existing spec-compliance behavior for untyped
  plans and keep model selection unchanged.

- [ ] **Step 4: Run the deterministic regression tests**

  Run: `bash tests/claude-code/test-typed-spec-authority-content.sh`

  Expected: PASS.

  Run: `bash tests/claude-code/test-sdd-workspace.sh`

  Expected: PASS.

  Run: `bash tests/shell-lint/test-lint-shell.sh`

  Expected: PASS.

- [ ] **Step 5: Commit**

  ```bash
  git add skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/implementer-prompt.md skills/subagent-driven-development/task-reviewer-prompt.md skills/subagent-driven-development/re-review-prompt.md skills/requesting-code-review/code-reviewer.md tests/claude-code/test-typed-spec-authority-content.sh
  git commit -m "feat: gate typed reviews on human authority"
  ```

### Task 4: Prove Behavior Under Pressure and Preserve Legacy Behavior

**Contract Coverage:** HC-1, HC-2, HC-3, HC-4, BI-1, BI-2, BI-3, BI-4, BI-6
**Enables Evidence:** DE-1, DE-2, DE-4
**Forbidden Scope:** NG-2, NG-3, NG-4, NG-6
**Design Defaults:** DD-4 — use five fresh Claude CLI contexts containing all three public pressure scenarios per variant; replaceable under the deviation policy.

**Files:**
- Create: `tests/claude-code/typed-spec-authority-pressure.md`
- Create: `docs/superpowers/evals/2026-08-24-typed-spec-authority.md`
- Modify: `tests/claude-code/README.md`

**Interfaces:**
- Consumes: frozen public pressure prompt and the v6.3 control / typed-v1 treatment skill snapshots.
- Produces: manual sample-by-sample classification for all three scenarios, plus commands and revision IDs sufficient to reproduce the evidence.

- [ ] **Step 1: Freeze the public pressure prompt before changing skill behavior**

  Cover: Redis key/TTL versus database uniqueness, suggested class split versus
  an existing cohesive service, and a generalized-platform final-review
  recommendation. Force the worker to classify required work and blocking
  findings without asking the human to decide.

- [ ] **Step 2: Run and record the v6.3 control**

  Run five fresh Claude CLI contexts against the pre-change skill snapshot.
  Record exact model/CLI, revision, raw output paths, and whether each scenario
  promoted the incidental design into required work or a blocking finding.

- [ ] **Step 3: Run and record the typed-v1 treatment**

  Run the identical prompt in five fresh contexts against the changed skill
  snapshot. Manually verify every sample preserves all normative items and
  accepts the smaller conforming implementation or keeps the generalized
  platform recommendation advisory.

- [ ] **Step 4: Run repository regression and public-content checks**

  Run: `bash tests/claude-code/run-skill-tests.sh`

  Expected: all fast tests PASS.

  Run: `bash tests/shell-lint/test-lint-shell.sh`

  Expected: PASS.

  Inspect the branch diff for private project names, paths, credentials,
  session IDs, or unpublished source. Expected: none.

- [ ] **Step 5: Commit**

  ```bash
  git add tests/claude-code/typed-spec-authority-pressure.md tests/claude-code/README.md docs/superpowers/evals/2026-08-24-typed-spec-authority.md
  git commit -m "test: document typed authority behavior evidence"
  ```
