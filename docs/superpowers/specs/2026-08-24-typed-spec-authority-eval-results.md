# Typed Spec Authority Behavior Evidence

Date: 2026-08-24

## Claim Under Test

For a typed-v1 plan, `gpt-5.6-sol` at xhigh should preserve the approved
observable contract while refusing to turn replaceable implementation details
or uncited architecture advice into blocking work. Untyped plans must retain
v6.3 behavior.

## Harness

- Model: `gpt-5.6-sol`
- Reasoning effort: `xhigh`
- CLI: `codex-cli 0.149.0-alpha.4.1`
- Isolation: `codex exec --ephemeral --ignore-user-config --ignore-rules`
- Sandbox: read-only
- Context: one fresh process per sample; no resumed sessions
- Scenario fixture: `tests/claude-code/typed-spec-authority-pressure.md`
- Fixture SHA-256:
  `9d251feae23302b37d0580aec95be2f741911a160ed508abe4081f58fbde0b78`

The harness prepended the behavior-relevant excerpts from `writing-plans`,
`subagent-driven-development`, the task reviewer, and the final reviewer, then
appended either CONTROL or TREATMENT from the frozen fixture. The Codex runtime
still loaded the global `using-superpowers` bootstrap and Codex tool reference
in every sample despite the isolated prompt's no-skill instruction. Because it
did so in all variants, this is a controlled harness constant, but it is noted
here rather than hidden.

## Revisions

- v6.3 control rules:
  `901b99b47f35f29564ff1ba621d8e3ad9134994a`
- typed-v1 treatment rules:
  `fb475c9911d949daa6a2750789fdc1911219f28a`

The control excerpt used the pre-change ranges from those four rule files. The
treatment and post-change legacy runs used the typed-v1 ranges at `fb475c9`.
Every sample received all three scenarios in one fresh context.

## Exact Classifications

`Y/Y` means the design detail was required and the smaller candidate blocked.
`N/N` means the detail was not required and the candidate did not block.

### v6.3 Control, Before the Change

| Sample | Redis / DB-only | Class split / cohesive service | Platform recommendation blocks | Observable requirements preserved |
|---:|---|---|---|---|
| 1 | Y/Y | Y/Y | No | Yes |
| 2 | Y/Y | Y/Y | No | Yes |
| 3 | Y/Y | Y/Y | Yes | Yes |
| 4 | Y/Y | Y/Y | No | Yes |
| 5 | Y/Y | Y/Y | No | Yes |

Result: both incidental implementation designs became mandatory in 5/5 fresh
samples. The speculative final-review expansion blocked in 1/5.

### typed-v1 Treatment, After the Change

| Sample | Redis / DB-only | Class split / cohesive service | Platform recommendation blocks | Observable requirements preserved |
|---:|---|---|---|---|
| 1 | N/N | N/N | No | Yes |
| 2 | N/N | N/N | No | Yes |
| 3 | N/N | N/N | No | Yes |
| 4 | N/N | N/N | No | Yes |
| 5 | N/N | N/N | No | Yes |

Result: 5/5 samples accepted both smaller conforming implementations, kept the
platform suggestion advisory, and preserved every observable requirement.

### Legacy Control, After the Change

| Sample | Redis / DB-only | Class split / cohesive service | Platform recommendation blocks | Observable requirements preserved |
|---:|---|---|---|---|
| 1 | Y/Y | Y/Y | Yes | Yes |
| 2 | Y/Y | Y/Y | No | Yes |
| 3 | Y/Y | Y/Y | No | Yes |
| 4 | Y/Y | Y/Y | No | Yes |
| 5 | Y/Y | Y/Y | No | Yes |

Result: post-change untyped behavior matched the v6.3 control on the two
spec-detail traps (5/5) and retained the same 1/5 platform-block distribution.

## Mission and Architecture Summary Extension — 2026-08-25

### Claim Under Test

The readable integration layer should change authoring and propagation without
creating a second source of authority:

1. the spec writes one complete seven-part Mission and Architecture Summary;
2. the plan copies that whole section verbatim instead of rewriting the legacy
   `Goal`, `Architecture`, and `Tech Stack` fields; and
3. task execution receives only the exact `Ultimate Goal` as non-binding
   context, not the architecture narrative.

### Harness and Revisions

- Model: `gpt-5.6-sol`
- Reasoning effort: `xhigh`
- CLI: `codex-cli 0.149.0-alpha.4.1`
- Isolation: one fresh Codex process per sample; no resumed sessions
- Samples: five control and five treatment outputs, manually inspected
- Scenario fixture:
  `tests/claude-code/mission-architecture-summary-pressure.md`
- Fixture SHA-256:
  `3fd283b35e66439d6bad2f3d4415b611a36dc36171a24bb0805b696ebe2a15ac`
- Control rules: `5e331fac89eb6a15585f09976bd34bd8d3b30391`
- Treatment rules: `823d0c931bd7c7aa8e6ca1325e9b17fbed6d1a14`

Each sample received the behavior-relevant excerpts from `brainstorming` and
`writing-plans`, followed by the same profile-timezone scenario. The model had
to produce only the typed spec opening and typed plan header, keeping the
comparison focused on document shape rather than implementation quality.

### Exact Classifications

| Variant | Complete seven-part spec summary | Verbatim full summary in plan | Typed plan omits legacy short header | Summary stays non-normative |
|---|---:|---:|---:|---:|
| Pre-extension control | 0/5 | 0/5 | 0/5 | N/A |
| Summary treatment | 5/5 | 5/5 | 5/5 | 5/5 |

All five control samples went directly from the authority marker into typed
ID lists and then wrote the plan's one-line Goal plus short Architecture and
Tech Stack fields. All five treatment samples emitted all seven summary
subsections in the spec, copied the same section into the plan without
rewriting it, omitted the typed plan's legacy short header, and kept authority
in `HC-*` and `BI-*`.

Task propagation is tested mechanically rather than inferred from prose. The
task-brief regression test proves the exact `Ultimate Goal` is present while
sentences from each of the other six summary sections are absent. It also
proves pre-extension typed plans still run without an invented goal and a
present-but-incomplete seven-part summary fails closed. A summary sentence that
cites an authority ID is also excluded; authority lines are compiled only from
the plan's Global Constraints section.

## Mechanical Evidence

`tests/claude-code/test-sdd-workspace.sh` proves that typed task briefs:

- carry the explicit authority model and spec path;
- carry only the exact non-binding `Ultimate Goal` from a present Mission and
  Architecture Summary, excluding its remaining architecture detail;
- include only the task's referenced `HC-*`, `BI-*`, `NG-*`, and `DE-*`;
- carry its `DD-*` text and deviation policy;
- reject missing, empty, cross-namespace, or nonexistent authority references;
- invalidate a previous brief after any failed regeneration, including a
  missing plan;
- leave legacy task-only output unchanged; and
- keep typed plans authored before the summary extension executable.

`tests/claude-code/test-typed-spec-authority-content.sh` checks all authoring,
execution, task-review, re-review, and final-review endpoints for the typed
authority and blocker contracts. It also requires both supported execution
routes to stop when the source spec is unreachable or its Human Contract is
not marked APPROVED.

## Interpretation and Limit

This is direct behavioral evidence for the selected failure modes on the
target model, not proof that every future spec will avoid over-engineering.
The change removes the demonstrated causal path: AI design detail no longer
becomes binding unless a human approves it as `HC-*` or `BI-*`, and reviewers
cannot send uncited advice into a typed-v1 fix loop. Badly written Human
Contracts can still authorize too much, so the compact approval gate remains
necessary.

## Repository Regression Status

Passed on the treatment worktree:

- `bash tests/claude-code/test-sdd-workspace.sh`
- `bash tests/claude-code/test-typed-spec-authority-content.sh`
- `bash tests/shell-lint/test-lint-shell.sh`
- `TZ=UTC bash tests/codex/test-package-codex-plugin.sh`
- `bash tests/codex/test-marketplace-manifest.sh`
- `bash tests/codex-plugin-sync/test-sync-to-codex-plugin.sh`

Two environment-dependent observations are kept separate from product results:

- `test-subagent-driven-development.sh` could not start its first model prompt
  because the local Claude CLI OAuth token returned HTTP 401 expired-token;
  repository assertions before and after that test passed.
- The package test's ZIP timestamp assertion passes under `TZ=UTC` and fails
  under `TZ=Asia/Shanghai` with `00:00` versus `08:00`. The package script and
  test are unchanged from upstream, and the exact eight-hour delta reproduces
  independently of this branch.
