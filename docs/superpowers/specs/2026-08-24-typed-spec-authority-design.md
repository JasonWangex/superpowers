# Typed Spec Authority — Design

Date: 2026-08-24
Status: Human Contract and Binding Invariants approved by Jason on 2026-08-24
Branch: `feature/typed-spec-authority`
Authority Model: typed-v1

## Human Contract — APPROVED

### Outcome

Superpowers preserves human-approved product semantics as the delivery
authority while keeping AI-authored internal design replaceable.

### Must Have

- HC-1: New typed specs distinguish normative product authority from
  replaceable design guidance.
- HC-2: Each execution and review endpoint receives the normative authority
  relevant to its task.
- HC-3: A review finding blocks delivery only when it cites normative
  authority, missing acceptance evidence, or a concrete regression introduced
  by the diff.
- HC-4: Existing untyped specs preserve v6.3 behavior until deliberately
  migrated.
- HC-5: The fork keeps a clean upstream mirror and isolates custom behavior on
  a mergeable branch.

### Non-goals

- NG-1: Removing TDD, verification, task review, or final review.
- NG-2: Letting implementers disregard public interfaces, security boundaries,
  migrations, compatibility constraints, or product semantics.
- NG-3: Rewriting historical specs automatically.
- NG-4: Changing Codex model routing or subagent selection.
- NG-5: Adding a third-party dependency or a separate contract document for
  every feature.
- NG-6: Publishing an upstream PR without separate human approval and public,
  non-confidential eval evidence.

### Done Evidence

- DE-1: A v6.3 control promotes an incidental implementation detail to
  required work in the selected pressure scenarios.
- DE-2: At least five fresh-context treatment samples per scenario preserve
  every normative item while allowing a smaller conforming implementation.
- DE-3: Deterministic helper tests prove task briefs carry the relevant typed
  authority.
- DE-4: Legacy untyped scenarios and the existing repository test suite keep
  their current behavior.

## Binding Invariants

- BI-1 (supports HC-1): Only a human-approved `HC-*` or `BI-*` item is
  normative in a `typed-v1` spec.
- BI-2 (supports HC-2): Normative authority travels by artifact, not by assumed
  conversation memory.
- BI-3 (supports HC-3): Literal divergence from a Design Default is not itself
  a review finding.
- BI-4 (supports HC-4): Untyped specs retain legacy binding semantics.
- BI-5 (supports HC-5): `main` remains a clean mirror of released upstream
  `main`; conflicts are resolved on the customization branch.
- BI-6 (supports NG-6): Public fork commits and any future PR contain no
  confidential project names, source, or private session artifacts.

## Problem

Superpowers currently gives an AI-authored design spec undifferentiated
authority:

1. `brainstorming` writes the design spec.
2. `writing-plans` treats every spec requirement as something a task must
   implement.
3. `subagent-driven-development` calls the spec the binding authority.
4. task and final reviewers treat divergence from the spec as a potential
   implementation failure.

That chain correctly prevents accidental under-delivery, but it also promotes
incidental design details into requirements. A spec may state an observable
product invariant and one possible implementation in the same paragraph. The
current workflow can require both even when a smaller implementation satisfies
the product need.

A compact human-approved contract alone does not solve this. It bounds the
feature, but the remaining spec can still freeze internal design choices and
send them through the plan and review loops as mandatory work.

## Authority Type Definitions

Typed authority is opt-in. A new typed spec declares:

```markdown
Authority Model: typed-v1
```

An untyped spec keeps the legacy rule that the spec is binding.

### 1. Human Contract (`HC-*`)

The Human Contract is the short section the human actually approves. It
contains:

- one outcome;
- must-have product behavior;
- explicit non-goals;
- observable done evidence.

Only the human can approve or change this layer. AI-authored additions do not
become authoritative merely because they appear elsewhere in the spec.

### 2. Binding Invariants (`BI-*`)

Binding Invariants contain constraints that an implementation must preserve,
such as:

- externally observable behavior;
- public API or persisted-data compatibility;
- security, privacy, legal, and data-integrity boundaries;
- irreversible migration constraints;
- exact product semantics needed to satisfy a Human Contract item.

Each invariant cites at least one `HC-*` item. Promoting an internal design
choice to this layer requires human approval.

### 3. Design Defaults (`DD-*`)

Design Defaults record the recommended implementation: component boundaries,
storage choices, internal APIs, algorithms, file layout, names, and library
choices.

They are strong defaults, not requirements. An implementer may replace a
default with a smaller reversible design when the replacement satisfies all
`HC-*` and `BI-*` items. The deviation is recorded with its reason and
evidence; it is not a review failure merely because it differs from the spec.

### 4. Informative Material (`INFO-*`)

Examples, sketches, alternatives, future ideas, and explanatory notes are
non-normative. They do not generate plan tasks or review findings.

### Default Classification

Within a `typed-v1` spec, prose that is not explicitly labeled `HC-*` or
`BI-*` is non-binding. A section may label a chosen design `DD-*`; unlabeled
explanation is informative.

This default prevents AI-authored detail from silently acquiring authority.

## Spec Shape

A typed architectural spec begins with a human-readable integration layer,
followed by the compact authority structure:

```markdown
Authority Model: typed-v1

## Mission and Architecture Summary — Non-normative

> Human-readable context only. This section does not create authority;
> normative requirements remain in HC/BI.

### Ultimate Goal
[the task's end state and why it matters]

### Current Problem
[the present gap or failure]

### End-to-End Flow
[the user/system flow from input to observable outcome]

### Technical Architecture
[major components, boundaries, and data flow]

### Key Technology Choices
[selected technologies and why they fit]

### Scope and Trade-offs
[what is deliberately included, excluded, and accepted]

### Definition of Success
[how the result will be recognized]

## Human Contract — APPROVED

### Outcome
[one sentence]

### Must Have
- HC-1: [observable product behavior]

### Non-goals
- NG-1: [explicit exclusion]

### Done Evidence
- DE-1: [binary, observable evidence for HC-1]

## Binding Invariants
- BI-1 (supports HC-1): [constraint]

## Design Defaults
- DD-1: [recommended reversible implementation]

## Informative Notes
- INFO-1: [example, alternative, or future idea]
```

The summary is the readable answer to “what are we building, how does it fit
together, and what result are we pursuing?” It integrates the scattered typed
items without replacing them. Every claim must trace to the approved contract,
binding invariants, or explicitly labeled non-normative design material; the
summary cannot create a requirement that is absent from `HC-*` or `BI-*`.

The Human Contract and Binding Invariants are normative. The rest of the spec
is a design proposal and decision record.

## Plan Compilation

For a `typed-v1` spec, `writing-plans` changes its coverage rule:

- copy the complete `Mission and Architecture Summary` verbatim into the plan,
  replacing the legacy short `Goal`, `Architecture`, and `Tech Stack` header;
- every `HC-*`, `BI-*`, and `DE-*` item maps to at least one task;
- `DD-*` items guide the proposed task implementation but are not mandatory;
- `INFO-*` and `NG-*` items never create work;
- every task names its contract coverage and forbidden scope;
- an enabling task names the contract items it enables rather than claiming
  independent infrastructure value.

Each task contains:

```markdown
**Contract Coverage:** HC-1, BI-1
**Enables Evidence:** DE-1
**Forbidden Scope:** NG-1
**Design Defaults:** DD-1 (replaceable under the deviation policy)
```

The plan's `Global Constraints` section contains the normative `HC-*` and
`BI-*` text, not every design detail from the spec.

## Execution Propagation

The current task-brief helper extracts only a task body. For typed plans it
must prepend a compact authority prelude containing:

- the authority model;
- the Human Contract path or spec path;
- only the exact `Ultimate Goal`, labeled non-binding Mission Context;
- the task's normative `HC-*` and `BI-*` text;
- relevant non-goals and done evidence;
- the deviation policy for `DD-*` items.

The same generated brief remains the implementer's source of requirements and
the task reviewer's scope. The implementer prompt receives an explicit
authority field rather than relying on scene-setting prose.

The other six summary sections deliberately stop at the plan. Passing the full
architecture narrative to every task would give implementation agents more
non-binding detail to elaborate and could recreate the scope-expansion failure
this authority model is intended to prevent.

## Deviation Policy

An implementer classifies a proposed deviation before acting:

| Deviation | Action |
|---|---|
| Changes `HC-*`, `BI-*`, public compatibility, security, or irreversible data behavior | Stop for human approval |
| Replaces `DD-*` with a smaller reversible implementation while preserving all normative items | Implement and record a ruling with evidence |
| Omits or changes `INFO-*` | No ruling required |
| Adds behavior covered by `NG-*` or not traceable to any `HC-*` | Do not implement |

The controller records allowed design-default deviations in the plan ledger.
It does not convert them into new requirements.

## Review Semantics

### Task Review

Rename the normative verdict from `Spec Compliance` to `Contract and
Invariant Compliance` for typed plans. A blocking finding must identify one
of:

- violated `HC-*` or `BI-*`;
- missing `DE-*` evidence;
- behavior forbidden by `NG-*`;
- a concrete correctness, security, compatibility, or data-loss regression
  introduced by the task diff.

Changing a `DD-*` implementation is not a finding when the replacement is
smaller or equally scoped and the normative evidence passes. Improvements
that are not required by the authority model are advisory.

### Final Review

The final reviewer receives the typed plan and authority prelude. Before
assigning Critical or Important severity, it must pass the same blocker
eligibility test. Architecture, scalability, documentation, or hardening
suggestions without a normative or diff-caused impact remain advisory and do
not enter the fix wave.

## Backward Compatibility

- Untyped specs and plans keep v6.3 behavior.
- `typed-v1` is selected only by an explicit header.
- Typed plans created before the summary extension remain executable and do
  not invent an `Ultimate Goal`; newly authored plans carry the summary, and a
  present-but-empty `Ultimate Goal` fails closed.
- A legacy spec may be migrated only by creating and approving its Human
  Contract and Binding Invariants; no automatic relabeling occurs.
- Existing plan/task helpers accept both formats.

This makes the fork adoptable incrementally and limits merge conflicts with
future upstream changes.

## Implementation Surface

The first implementation is one cohesive behavior change touching:

- `skills/brainstorming/SKILL.md` — typed spec output and approval boundary;
- `skills/writing-plans/SKILL.md` — normative coverage and task authority
  fields;
- `skills/subagent-driven-development/SKILL.md` — authority hierarchy,
  deviations, and review routing;
- `skills/subagent-driven-development/scripts/task-brief` — typed authority
  prelude;
- implementer, task-reviewer, re-review, and final-review prompt templates —
  typed inputs and blocker eligibility;
- deterministic helper tests and behavioral eval scenarios.

No new runtime dependency is introduced.

## Evaluation Strategy

Skill behavior changes follow `writing-skills` RED-GREEN-REFACTOR:

1. Preserve the current v6.3 skill text as the no-guidance control.
2. Use fresh-context pressure scenarios where a spec combines a binding
   outcome with an incidental implementation detail.
3. Run at least five samples per wording variant and manually inspect every
   result.
4. Verify that the control promotes the incidental detail to required work.
5. Verify that the treatment preserves the outcome while allowing a smaller
   implementation.
6. Run legacy untyped scenarios to prove backward compatibility.

Representative scenarios:

- At-most-once delivery is binding; an exact Redis key and TTL are a design
  default. A database uniqueness constraint that satisfies the invariant must
  not fail review.
- A public response shape is binding; a suggested class split is a design
  default. Keeping the existing cohesive service must not create extra tasks.
- A final reviewer recommends a generalized platform. Without a cited
  contract/invariant or diff-caused regression, the recommendation must not
  enter the fix wave.

## Fork and Upstream Strategy

The fork keeps `main` as a clean mirror of released upstream `main`.
Custom behavior lives on `feature/typed-spec-authority` until validated and
approved.

For each stable upstream release:

```bash
git fetch upstream --tags
git switch main
git merge --ff-only upstream/main
git push origin main
git switch feature/typed-spec-authority
git merge main
git push origin feature/typed-spec-authority
```

Conflicts are resolved only on the feature branch. An upstream PR, if later
approved, is rebased onto `upstream/dev` and follows the repository's eval,
disclosure, and human-diff-review requirements.

## Implementation Checkpoints

This checklist summarizes the design and does not add normative authority
beyond the `HC-*` and `BI-*` items above.

- A human approves only the compact Human Contract and explicitly binding
  invariants.
- AI-authored internal detail cannot become binding without a typed marker.
- Plans create required work only from normative items.
- Every task brief carries its relevant normative authority.
- Implementers may choose smaller reversible designs without failing literal
  spec compliance.
- Review blockers cite normative authority or a concrete diff-caused
  regression.
- Untyped specs preserve existing v6.3 semantics.
- The fork can merge future released upstream `main` without modifying the
  clean mirror branch.
