#!/usr/bin/env bash
# Deterministic contract tests for typed-v1 skill and prompt propagation.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FAILURES=0

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

require_literal() {
    local file="$1"
    local text="$2"
    local name="$3"
    if grep -Fq -- "$text" "$REPO_ROOT/$file"; then
        pass "$name"
    else
        fail "$name"
        echo "    missing from $file: $text"
    fi
}

require_regex() {
    local file="$1"
    local pattern="$2"
    local name="$3"
    if grep -Eqi -- "$pattern" "$REPO_ROOT/$file"; then
        pass "$name"
    else
        fail "$name"
        echo "    missing pattern from $file: $pattern"
    fi
}

require_regex_flat() {
    local file="$1"
    local pattern="$2"
    local name="$3"
    if tr '\n' ' ' < "$REPO_ROOT/$file" | grep -Eqi -- "$pattern"; then
        pass "$name"
    else
        fail "$name"
        echo "    missing flattened pattern from $file: $pattern"
    fi
}

main() {
    echo "=== Test: typed spec authority content ==="

    local brainstorming="skills/brainstorming/SKILL.md"
    local spec_reviewer="skills/brainstorming/spec-document-reviewer-prompt.md"
    local writing_plans="skills/writing-plans/SKILL.md"
    local plan_reviewer="skills/writing-plans/plan-document-reviewer-prompt.md"
    local executing_plans="skills/executing-plans/SKILL.md"
    local sdd="skills/subagent-driven-development/SKILL.md"
    local implementer="skills/subagent-driven-development/implementer-prompt.md"
    local task_reviewer="skills/subagent-driven-development/task-reviewer-prompt.md"
    local rereviewer="skills/subagent-driven-development/re-review-prompt.md"
    local final_reviewer="skills/requesting-code-review/code-reviewer.md"
    local requesting_review="skills/requesting-code-review/SKILL.md"

    require_literal "$brainstorming" "Authority Model: typed-v1" \
        "brainstorming emits the typed-v1 marker"
    require_literal "$brainstorming" "## Human Contract — APPROVED" \
        "brainstorming defines the approved Human Contract"
    require_regex "$brainstorming" 'HC-\*.*BI-\*.*normative|normative.*HC-\*.*BI-\*' \
        "brainstorming limits normative authority to HC and BI items"
    require_regex "$brainstorming" 'DD-\*.*replaceable|replaceable.*DD-\*' \
        "brainstorming marks Design Defaults replaceable"
    require_regex "$brainstorming" 'INFO-\*.*non-(binding|normative)|non-(binding|normative).*INFO-\*' \
        "brainstorming marks informative material non-binding"
    require_regex "$brainstorming" 'review.*Human Contract.*Binding Invariants|Human Contract.*Binding Invariants.*review' \
        "brainstorming human gate covers only contract and invariants"

    require_literal "$spec_reviewer" "Authority Model: typed-v1" \
        "spec reviewer detects typed-v1"
    require_regex "$spec_reviewer" 'only.*HC-\*.*BI-\*.*normative|normative.*only.*HC-\*.*BI-\*' \
        "spec reviewer enforces the normative boundary"
    require_regex "$spec_reviewer" 'DD-\*.*(advisory|non-blocking|replaceable)' \
        "spec reviewer does not promote Design Defaults"

    require_literal "$writing_plans" "**Authority Model:** typed-v1" \
        "writing-plans emits the typed plan marker"
    require_literal "$writing_plans" "**Contract Coverage:**" \
        "writing-plans task template carries contract coverage"
    require_literal "$writing_plans" "**Enables Evidence:**" \
        "writing-plans task template carries evidence"
    require_literal "$writing_plans" "**Forbidden Scope:**" \
        "writing-plans task template carries forbidden scope"
    require_literal "$writing_plans" "**Design Defaults:**" \
        "writing-plans task template carries replaceable defaults"
    require_regex "$writing_plans" 'HC-\*.*BI-\*.*DE-\*.*map|map.*HC-\*.*BI-\*.*DE-\*' \
        "typed plan coverage maps HC, BI, and DE items"
    require_regex "$writing_plans" 'INFO-\*.*NG-\*.*(never|do not).*task|(never|do not).*task.*INFO-\*.*NG-\*' \
        "typed plan excludes INFO and NG from generated work"
    require_regex "$writing_plans" '(untyped|legacy).*(existing|v6\.3|full-spec|every spec)|(existing|v6\.3|full-spec|every spec).*(untyped|legacy)' \
        "writing-plans preserves legacy full-spec behavior"

    require_literal "$plan_reviewer" "Authority Model: typed-v1" \
        "plan reviewer detects typed-v1"
    require_regex "$plan_reviewer" 'HC-\*.*BI-\*.*DE-\*.*coverage|coverage.*HC-\*.*BI-\*.*DE-\*' \
        "plan reviewer checks typed normative coverage"
    require_regex "$plan_reviewer" 'DD-\*.*(not.*missing|not.*require|replaceable|advisory)' \
        "plan reviewer does not require Design Defaults literally"

    require_literal "$executing_plans" "**Authority Model:** typed-v1" \
        "executing-plans detects the typed authority model"
    require_literal "$executing_plans" "task-brief" \
        "executing-plans compiles a typed authority brief"
    require_regex_flat "$executing_plans" '(task brief|authority prelude).*(execution authority|source of requirements)|(execution authority|source of requirements).*(task brief|authority prelude)' \
        "executing-plans makes the typed brief the execution authority"
    require_regex_flat "$executing_plans" 'DD-\*.*smaller.*reversible.*(allowed|implement)|smaller.*reversible.*DD-\*' \
        "executing-plans permits smaller reversible Design Default deviations"
    require_regex_flat "$executing_plans" 'HC-\*.*BI-\*.*DE-\*.*NG-\*.*diff-caused|diff-caused.*HC-\*.*BI-\*.*DE-\*.*NG-\*' \
        "executing-plans defines typed blocker eligibility"
    require_regex "$executing_plans" '(untyped|legacy).*follow each step exactly|follow each step exactly.*(untyped|legacy)' \
        "executing-plans preserves legacy exact-step behavior"

    require_literal "$sdd" "**Authority Model:** typed-v1" \
        "SDD detects the typed authority model"
    require_regex_flat "$sdd" '(task brief|authority prelude).*(binding authority|source of requirements)|(binding authority|source of requirements).*(task brief|authority prelude)' \
        "SDD makes the typed brief the execution authority"
    require_regex_flat "$sdd" 'Contract and[[:space:]]+Invariant Compliance' \
        "SDD names the typed review verdict"
    require_regex_flat "$sdd" 'DD-\*.*smaller.*reversible.*(allowed|implement)|smaller.*reversible.*DD-\*' \
        "SDD permits smaller reversible Design Default deviations"
    require_regex "$sdd" '(untyped|legacy).*spec.*binding authority|spec.*binding authority.*(untyped|legacy)' \
        "SDD preserves legacy binding-spec behavior"
    require_regex_flat "$sdd" 'HC-\*.*BI-\*.*DE-\*.*NG-\*.*diff-caused|diff-caused.*HC-\*.*BI-\*.*DE-\*.*NG-\*' \
        "SDD defines typed blocker eligibility"

    require_literal "$implementer" "[AUTHORITY_MODEL]" \
        "implementer receives an explicit authority model"
    require_regex_flat "$implementer" 'DD-\*.*smaller.*reversible|smaller.*reversible.*DD-\*' \
        "implementer may choose a smaller Design Default replacement"
    require_regex "$implementer" 'NG-\*.*(do not implement|forbidden)|forbidden.*NG-\*' \
        "implementer refuses forbidden scope"
    require_regex "$implementer" '(untyped|legacy).*everything.*task|everything.*task.*(untyped|legacy)' \
        "implementer keeps legacy exact-task behavior"

    require_literal "$task_reviewer" "[AUTHORITY_MODEL]" \
        "task reviewer receives an explicit authority model"
    require_literal "$task_reviewer" "Contract and Invariant Compliance" \
        "task reviewer emits the typed verdict"
    require_regex_flat "$task_reviewer" 'DD-\*.*(not a finding|non-blocking|advisory)' \
        "task reviewer does not block on Design Default divergence"
    require_regex_flat "$task_reviewer" 'HC-\*.*BI-\*.*DE-\*.*NG-\*.*diff-caused|diff-caused.*HC-\*.*BI-\*.*DE-\*.*NG-\*' \
        "task reviewer gates blockers on typed authority"

    require_literal "$rereviewer" "[AUTHORITY_MODEL]" \
        "re-reviewer receives an explicit authority model"
    require_regex "$rereviewer" 'typed-v1.*(eligible|eligibility).*blocking|blocking.*(eligible|eligibility).*typed-v1' \
        "re-reviewer rechecks typed blocker eligibility"

    require_literal "$final_reviewer" "[AUTHORITY_MODEL]" \
        "final reviewer receives an explicit authority model"
    require_literal "$final_reviewer" "[AUTHORITY_PRELUDE]" \
        "final reviewer receives typed authority text"
    require_regex "$final_reviewer" 'DD-\*.*(not a finding|non-blocking|advisory)' \
        "final reviewer does not block on Design Default divergence"
    require_regex_flat "$final_reviewer" 'HC-\*.*BI-\*.*DE-\*.*NG-\*.*diff-caused|diff-caused.*HC-\*.*BI-\*.*DE-\*.*NG-\*' \
        "final reviewer gates blockers on typed authority"

    require_literal "$requesting_review" "{AUTHORITY_MODEL}" \
        "requesting-code-review fills the authority model"
    require_literal "$requesting_review" "{AUTHORITY_PRELUDE}" \
        "requesting-code-review fills the authority artifact"
    require_regex_flat "$requesting_review" 'typed-v1.*(blocker eligibility|HC-\*.*BI-\*)' \
        "requesting-code-review filters typed findings"
    require_regex "$requesting_review" '(legacy|untyped).*(existing|v6\.3|full.*review)' \
        "requesting-code-review preserves legacy review behavior"

    echo ""
    if [[ "$FAILURES" -ne 0 ]]; then
        echo "FAILED: $FAILURES assertion(s)."
        exit 1
    fi
    echo "PASS"
}

main "$@"
