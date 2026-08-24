---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that Superpowers works much better with access to subagents (Claude Code, Codex CLI, Codex App, Copilot CLI, and Gemini CLI all qualify; see the per-platform tool refs in `../using-superpowers/references/`). If subagents are available, use superpowers:subagent-driven-development instead of this skill.

## The Process

### Step 1: Load and Review Plan
1. Ensure an isolated workspace: use superpowers:using-git-worktrees to create one or verify the existing one
2. Read plan file
3. Detect the authority model:
   - If the header contains `**Authority Model:** typed-v1`, use the typed-v1 path below
   - Otherwise use the legacy/untyped path
4. Review critically - identify any questions or concerns about the plan
5. If concerns: Raise them with your human partner before starting
6. If no concerns: Create todos for the plan items and proceed

### Authority Models

**typed-v1:** Resolve and read the plan's `**Spec:**` file, then verify that its Human Contract is marked `APPROVED`. If the spec is missing or unreachable, or the Human Contract is not approved, stop and fail closed before executing any task. Before each task, run the sibling `../subagent-driven-development/scripts/task-brief PLAN_FILE TASK_NUMBER` script (resolved from this skill's directory), then read the generated brief. The task brief's Authority Prelude is the source of requirements and execution authority for that task.

- `HC-*` and `BI-*` are normative requirements.
- `DE-*` is required evidence; `NG-*` is forbidden scope.
- `DD-*` is a replaceable design default. Implementing a smaller reversible alternative to a `DD-*` item is allowed when all relevant `HC-*` and `BI-*` items still pass; record the reason and evidence in the task report.
- A blocking issue must cite violated `HC-*`, `BI-*`, `DE-*`, or `NG-*` authority, or identify a diff-caused correctness, security, compatibility, or data-loss defect. Divergence from `DD-*` alone is advisory.
- Stop and ask before changing `HC-*` or `BI-*`, or before expanding public API, security-sensitive, irreversible, or destructive behavior beyond the brief.

**Legacy/untyped:** The existing v6.3 behavior is unchanged: the plan and referenced spec remain binding, and follow each step exactly.

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. For typed-v1, generate and read that task's brief, follow its normative authority plus the plan's process and verification steps, and treat implementation-shape instructions covered by `DD-*` as replaceable defaults
3. For legacy/untyped plans, follow each step exactly (plan has bite-sized steps)
4. Run verifications as specified
5. Mark as completed

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent
