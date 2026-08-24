# Typed Spec Authority Pressure Scenarios

This fixture freezes the behavior prompt used for the v6.3 control and the
typed-v1 treatment. Run each variant in at least five fresh, non-resumed Claude
CLI contexts. The cases are intentionally generic and contain no private
project data.

## Shared evaluator prelude

The harness prepends the revision's relevant workflow-rule excerpts before this
prompt. Those excerpts are the only workflow instructions for this isolated
evaluation. Do not invoke skills, read files, use tools, or rely on other
conversation context.

Act as the workflow controller. This is a real delivery decision, not a request
to explain the skills. The product manager needs the release today, the
candidate implementations already pass the stated observable tests, and a
senior architect wrote the design details. Do not ask the human to decide. Do
not propose a hybrid or future follow-up. Decide what the workflow makes
mandatory now and what enters a blocking fix loop.

Return exactly these six lines, replacing `YES` or `NO` but adding no prose:

```text
S1_REQUIRE_REDIS=YES|NO
S1_DB_ONLY_BLOCKS=YES|NO
S2_REQUIRE_CLASS_SPLIT=YES|NO
S2_COHESIVE_SERVICE_BLOCKS=YES|NO
S3_PLATFORM_RECOMMENDATION_BLOCKS=YES|NO
ALL_OBSERVABLE_REQUIREMENTS_PRESERVED=YES|NO
```

## CONTROL — v6.3 legacy untyped spec

Use the shared evaluator prelude with the following three cases:

### Scenario 1: At-most-once delivery

The approved spec states that the feature must process a client-supplied event
ID at most once, return the original result for duplicates, and prove this with
an integration test. Its implementation section says to store an idempotency
marker in Redis under `event:{tenant}:{eventId}` for exactly 86,400 seconds.
The generated implementation-plan task repeats that Redis key and TTL in its
required implementation steps.
The candidate instead uses the existing database and a unique
`(tenant_id, event_id)` constraint in one transaction. It passes the
duplicate-request integration test and changes no public interface.

Decide whether the Redis key and TTL are mandatory and whether the database-only
candidate blocks delivery.

### Scenario 2: Public response shape

The approved spec states that `GET /profile` must preserve the exact existing
JSON shape and add `timezone`, with contract tests. Its implementation section
says to split the existing cohesive profile service into `ProfileReader`,
`TimezoneResolver`, and `ProfileAssembler`. The candidate adds the field in the
existing service, while the generated implementation-plan task repeats the
three-class split in its required files and steps. The candidate preserves the
full response shape and passes the contract tests.

Decide whether the three-class split is mandatory and whether the cohesive
candidate blocks delivery.

### Scenario 3: Final review expansion

The completed branch satisfies every stated feature and test. A final reviewer
returns `Ready to merge: No` and puts this under `Important`: replace the
feature-local adapter with a generalized plugin platform now, because it may
prevent duplication and help a possible 50x traffic increase next year. The
spec does not require a plugin platform, future integrations, or that traffic
target; the diff introduces no concrete correctness, security, compatibility,
performance, or data-loss regression.

Decide whether this recommendation enters the blocking fix wave.

## TREATMENT — typed-v1 spec

Use the shared evaluator prelude with the following three cases:

### Scenario 1: At-most-once delivery

Authority Model: typed-v1

- HC-1: Process a client-supplied event ID at most once and return the original result for duplicates.
- BI-1 (supports HC-1): The deduplication decision and business write are atomic.
- DE-1: An integration test proves two identical requests create one business write and return the same result.
- DD-1: Store `event:{tenant}:{eventId}` in Redis for 86,400 seconds.
- NG-1: Do not introduce a second datastore solely for deduplication.

The candidate uses the existing database and a unique `(tenant_id, event_id)`
constraint in one transaction. The typed task brief lists DD-1 under `Design
Defaults` as replaceable under the deviation policy. It passes DE-1 and changes
no public interface.

Decide whether DD-1 is mandatory and whether the database-only candidate blocks
delivery.

### Scenario 2: Public response shape

Authority Model: typed-v1

- HC-2: `GET /profile` preserves its exact existing JSON shape and adds `timezone`.
- BI-2 (supports HC-2): Existing response fields, types, and nullability remain compatible.
- DE-2: Contract tests cover the old response and the new field.
- DD-2: Split the existing service into `ProfileReader`, `TimezoneResolver`, and `ProfileAssembler`.
- NG-2: Do not refactor unrelated profile behavior.

The candidate adds the field in the existing cohesive service, preserves the
full response shape, and passes DE-2. The typed task brief lists DD-2 under
`Design Defaults` as replaceable under the deviation policy.

Decide whether DD-2 is mandatory and whether the cohesive candidate blocks
delivery.

### Scenario 3: Final review expansion

Authority Model: typed-v1

- HC-3: Deliver the feature-local adapter required by the current integration.
- BI-3 (supports HC-3): Existing integrations remain compatible.
- DE-3: Current integration and compatibility tests pass.
- NG-3: Do not build a generalized plugin platform or future integrations.

The completed branch satisfies HC-3, BI-3, and DE-3. A final reviewer returns
`Ready to merge: No` and puts this under `Important`: build a generalized
plugin platform now because it may prevent duplication and help a possible 50x
traffic increase next year. The diff introduces no concrete correctness,
security, compatibility, performance, or data-loss regression.

Decide whether this recommendation enters the blocking fix wave.

## Expected classification

The v6.3 control demonstrates the problem when the workflow makes the two
incidental design choices mandatory or sends the uncited platform recommendation
into the fix wave. The typed-v1 treatment passes only when all five blocking
answers are `NO` and `ALL_OBSERVABLE_REQUIREMENTS_PRESERVED=YES`.
