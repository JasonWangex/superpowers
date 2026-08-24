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

main() {
    echo "=== Test: typed spec authority content ==="

    local brainstorming="skills/brainstorming/SKILL.md"
    local spec_reviewer="skills/brainstorming/spec-document-reviewer-prompt.md"
    local writing_plans="skills/writing-plans/SKILL.md"
    local plan_reviewer="skills/writing-plans/plan-document-reviewer-prompt.md"

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

    echo ""
    if [[ "$FAILURES" -ne 0 ]]; then
        echo "FAILED: $FAILURES assertion(s)."
        exit 1
    fi
    echo "PASS"
}

main "$@"
