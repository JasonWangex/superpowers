# Mission and Architecture Summary Pressure Scenario

Use this fixture to compare authoring behavior before and after the summary
propagation rule. Each sample receives the relevant `brainstorming` and
`writing-plans` rules and no other project context.

## Scenario

A profile API must preserve every existing JSON field and add `timezone`. The
existing cohesive service can implement it, and contract tests prove
compatibility. Do not introduce a new datastore or split the service unless a
binding requirement makes that necessary.

Produce only:

1. the typed-v1 spec opening through Binding Invariants and any human-readable
   architecture material required by the workflow;
2. the typed-v1 plan header through Global Constraints and any copied
   human-readable architecture material required by the workflow.

## Expected Treatment Shape

- The spec contains one complete `Mission and Architecture Summary` with all
  seven required subsections.
- The plan copies that section verbatim instead of rewriting it into the legacy
  `Goal`, `Architecture`, and `Tech Stack` fields.
- The summary introduces no new normative requirement; authority remains in
  `HC-*` and `BI-*`.
- A task brief receives the exact `Ultimate Goal` as non-binding Mission
  Context, but none of the remaining architecture-summary subsections.
