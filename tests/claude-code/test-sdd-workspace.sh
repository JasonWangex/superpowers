#!/usr/bin/env bash
# Tests for the SDD workspace: scripts/sdd-workspace resolves a self-ignoring,
# PER-PLAN working-tree directory for SDD artifacts, and the SDD scripts write
# into their plan's directory.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SDD_SCRIPTS="$REPO_ROOT/skills/subagent-driven-development/scripts"

FAILURES=0
TEST_ROOT=""

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}

main() {
    echo "=== Test: sdd-workspace ==="

    TEST_ROOT="$(mktemp -d)"
    trap cleanup EXIT

    # Resolve repo to its physical path so string comparisons match the
    # helper's output (git rev-parse --show-toplevel resolves symlinks; on
    # macOS mktemp lives under /var -> /private/var).
    git init -q -b main "$TEST_ROOT/repo"
    local repo
    repo="$(cd "$TEST_ROOT/repo" && git rev-parse --show-toplevel)"

    cat > "$repo/plan-a.md" <<'PLAN'
# Plan A

## Task 1: First thing

Do the first thing.
PLAN
    cat > "$repo/plan-b.md" <<'PLAN'
# Plan B

## Task 1: Other thing

Do the other thing.
PLAN
    cat > "$repo/typed-plan.md" <<'PLAN'
# Typed Plan

**Spec:** `docs/superpowers/specs/example.md`
**Authority Model:** typed-v1

## Global Constraints

### Human Contract
- HC-1: Preserve the public response.
- HC-2: Unrelated contract item.

### Binding Invariants
- BI-1 (supports HC-1): Existing response fields remain compatible.
- BI-2 (supports HC-2): Unrelated invariant.

### Non-goals
- NG-1: Do not refactor unrelated behavior.
- NG-2: Unrelated non-goal.

### Done Evidence
- DE-1: Contract tests pass.
- DE-2: Unrelated evidence.

### Deviation Policy
- Replacing a DD-* item with a smaller reversible implementation is allowed when all relevant HC-* and BI-* items still pass; record the reason and evidence.

---

### Task 1: Add the response field

**Contract Coverage:** HC-1, BI-1
**Enables Evidence:** DE-1
**Forbidden Scope:** NG-1
**Design Defaults:** DD-1 — split the service into three classes; replaceable under the deviation policy.

Add the response field with the smallest conforming change.
PLAN
    cat > "$repo/typed-plan-missing-field.md" <<'PLAN'
# Invalid Typed Plan

**Spec:** `docs/superpowers/specs/example.md`
**Authority Model:** typed-v1

## Global Constraints

- HC-1: Preserve the public response.
- BI-1 (supports HC-1): Existing response fields remain compatible.
- DE-1: Contract tests pass.

### Deviation Policy
- Replacing a DD-* item with a smaller reversible implementation is allowed.

---

### Task 1: Invalid typed task

**Contract Coverage:** HC-1, BI-1
**Enables Evidence:** DE-1
**Design Defaults:** None.

This task omits Forbidden Scope.
PLAN
    cat > "$repo/typed-plan-empty-spec.md" <<'PLAN'
# Invalid Typed Plan

**Spec:**
`docs/superpowers/specs/example.md`
**Authority Model:** typed-v1

## Global Constraints
- HC-1: Preserve the public response.
- BI-1 (supports HC-1): Existing response fields remain compatible.
- DE-1: Contract tests pass.

### Deviation Policy
- Replacing a DD-* item with a smaller reversible implementation is allowed.

---

### Task 1: Invalid typed task

**Contract Coverage:** HC-1, BI-1
**Enables Evidence:** DE-1
**Forbidden Scope:** None.
**Design Defaults:** None.
PLAN

    write_typed_plan_fixture() {
        local path="$1"
        local contract="$2"
        local evidence="$3"
        local forbidden="$4"
        local defaults="$5"
        cat > "$path" <<PLAN
# Typed Field Validation Fixture

**Spec:** \`docs/superpowers/specs/example.md\`
**Authority Model:** typed-v1

## Global Constraints
- HC-1: Preserve the public response.
- BI-1 (supports HC-1): Existing response fields remain compatible.
- NG-1: Do not refactor unrelated behavior.
- DE-1: Contract tests pass.

### Deviation Policy
- Replacing a DD-* item with a smaller reversible implementation is allowed.

---

### Task 1: Validate field namespaces

**Contract Coverage:** ${contract}
**Enables Evidence:** ${evidence}
**Forbidden Scope:** ${forbidden}
**Design Defaults:** ${defaults}
PLAN
    }

    write_typed_plan_fixture "$repo/typed-invalid-contract.md" "NG-1" "DE-1" "NG-1" "DD-1 — optional structure."
    write_typed_plan_fixture "$repo/typed-invalid-evidence.md" "HC-1, BI-1" "HC-1" "NG-1" "DD-1 — optional structure."
    write_typed_plan_fixture "$repo/typed-invalid-forbidden.md" "HC-1, BI-1" "DE-1" "BI-1" "DD-1 — optional structure."
    write_typed_plan_fixture "$repo/typed-invalid-defaults.md" "HC-1, BI-1" "DE-1" "NG-1" "DE-1"
    write_typed_plan_fixture "$repo/typed-empty-contract.md" "" "DE-1" "NG-1" "DD-1 — optional structure."
    write_typed_plan_fixture "$repo/typed-empty-evidence.md" "HC-1, BI-1" "" "NG-1" "DD-1 — optional structure."
    write_typed_plan_fixture "$repo/typed-empty-forbidden.md" "HC-1, BI-1" "DE-1" "" "DD-1 — optional structure."
    write_typed_plan_fixture "$repo/typed-empty-defaults.md" "HC-1, BI-1" "DE-1" "NG-1" ""
    write_typed_plan_fixture "$repo/typed-none-optionals.md" "HC-1, BI-1" "None." "None." "None."

    # --- argument validation ---
    local rc=0
    (cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "sdd-workspace without a plan errors with exit 2"
    else
        fail "sdd-workspace without a plan errors with exit 2"
        echo "    exit: $rc"
    fi

    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" no-such-plan.md >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "sdd-workspace with a missing plan file errors with exit 2"
    else
        fail "sdd-workspace with a missing plan file errors with exit 2"
        echo "    exit: $rc"
    fi

    # --- per-plan resolution ---
    local dir_a dir_b
    dir_a="$(cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" plan-a.md)"
    dir_b="$(cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" plan-b.md)"

    if [[ "$dir_a" == "$repo/.superpowers/sdd/plan-a" ]]; then
        pass "prints <repo-root>/.superpowers/sdd/<plan-basename>"
    else
        fail "prints <repo-root>/.superpowers/sdd/<plan-basename>"
        echo "    got: $dir_a"
    fi

    if [[ "$dir_a" != "$dir_b" && -d "$dir_a" && -d "$dir_b" ]]; then
        pass "two plans resolve to two distinct directories"
    else
        fail "two plans resolve to two distinct directories"
        echo "    a: $dir_a"
        echo "    b: $dir_b"
    fi

    if [[ -f "$repo/.superpowers/sdd/.gitignore" && "$(cat "$repo/.superpowers/sdd/.gitignore")" == "*" ]]; then
        pass "self-ignoring .gitignore created at .superpowers/sdd/ with '*'"
    else
        fail "self-ignoring .gitignore created at .superpowers/sdd/ with '*'"
    fi

    printf 'x\n' > "$dir_a/artifact.md"
    local status
    status="$(cd "$repo" && git status --porcelain)"
    # plan-a.md/plan-b.md are intentionally untracked fixture files; only the
    # workspace must be invisible.
    if [[ "$status" != *".superpowers"* ]]; then
        pass "workspace invisible to git status"
    else
        fail "workspace invisible to git status"
        echo "    status: $status"
    fi

    ( cd "$repo" && git add -A )
    local staged
    staged="$(cd "$repo" && git diff --cached --name-only)"
    if [[ "$staged" != *".superpowers"* ]]; then
        pass "git add -A does not stage the workspace"
    else
        fail "git add -A does not stage the workspace"
        echo "    staged: $staged"
    fi

    # --- task-brief lands in its plan's directory ---
    local brief_out brief_path
    brief_out="$(cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-a.md 1)"
    brief_path="$(printf '%s\n' "$brief_out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
    if [[ "$brief_path" == "$repo/.superpowers/sdd/plan-a/task-1-brief.md" ]]; then
        pass "task-brief writes its brief under the plan's workspace"
    else
        fail "task-brief writes its brief under the plan's workspace"
        echo "    got: $brief_path"
    fi

    local legacy_expected legacy_actual
    legacy_expected=$'## Task 1: First thing\n\nDo the first thing.'
    legacy_actual="$(cat "$brief_path")"
    if [[ "$legacy_actual" == "$legacy_expected" ]]; then
        pass "untyped task-brief output remains byte-for-byte task-only"
    else
        fail "untyped task-brief output remains byte-for-byte task-only"
        echo "    got: $legacy_actual"
    fi

    # --- typed task-brief carries only the task's authority ---
    local typed_out typed_path typed_content
    typed_out="$(cd "$repo" && "$SDD_SCRIPTS/task-brief" typed-plan.md 1)"
    typed_path="$(printf '%s\n' "$typed_out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
    typed_content="$(cat "$typed_path")"

    local required_text
    for required_text in \
        "# Authority Prelude" \
        "**Authority Model:** typed-v1" \
        '**Spec:** `docs/superpowers/specs/example.md`' \
        "HC-1: Preserve the public response." \
        "BI-1 (supports HC-1): Existing response fields remain compatible." \
        "NG-1: Do not refactor unrelated behavior." \
        "DE-1: Contract tests pass." \
        "DD-1 — split the service into three classes; replaceable under the deviation policy." \
        "Replacing a DD-* item with a smaller reversible implementation is allowed" \
        "### Task 1: Add the response field"; do
        if [[ "$typed_content" == *"$required_text"* ]]; then
            pass "typed task-brief contains: $required_text"
        else
            fail "typed task-brief contains: $required_text"
        fi
    done

    local unrelated_text
    for unrelated_text in "HC-2:" "BI-2" "NG-2:" "DE-2:"; do
        if [[ "$typed_content" != *"$unrelated_text"* ]]; then
            pass "typed task-brief excludes unrelated authority: $unrelated_text"
        else
            fail "typed task-brief excludes unrelated authority: $unrelated_text"
        fi
    done

    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/task-brief" typed-plan-missing-field.md 1 >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 4 ]]; then
        pass "typed task missing an authority field errors with exit 4"
    else
        fail "typed task missing an authority field errors with exit 4"
        echo "    exit: $rc"
    fi

    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/task-brief" typed-plan-empty-spec.md 1 >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 4 ]]; then
        pass "typed plan with an empty inline spec path errors with exit 4"
    else
        fail "typed plan with an empty inline spec path errors with exit 4"
        echo "    exit: $rc"
    fi

    local invalid_typed_plan
    for invalid_typed_plan in \
        typed-invalid-contract.md \
        typed-invalid-evidence.md \
        typed-invalid-forbidden.md \
        typed-invalid-defaults.md \
        typed-empty-contract.md \
        typed-empty-evidence.md \
        typed-empty-forbidden.md \
        typed-empty-defaults.md; do
        rc=0
        (cd "$repo" && "$SDD_SCRIPTS/task-brief" "$invalid_typed_plan" 1 >/dev/null 2>&1) || rc=$?
        if [[ "$rc" -eq 4 ]]; then
            pass "typed task rejects invalid authority field: $invalid_typed_plan"
        else
            fail "typed task rejects invalid authority field: $invalid_typed_plan"
            echo "    exit: $rc"
        fi
    done

    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/task-brief" typed-none-optionals.md 1 >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 0 ]]; then
        pass "typed task accepts explicit None for optional authority fields"
    else
        fail "typed task accepts explicit None for optional authority fields"
        echo "    exit: $rc"
    fi

    # A failed regeneration must invalidate a prior successful brief so no
    # caller can accidentally execute stale authority.
    local reused_brief="$TEST_ROOT/reused-brief.md"
    (cd "$repo" && "$SDD_SCRIPTS/task-brief" typed-plan.md 1 "$reused_brief" >/dev/null)
    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/task-brief" typed-invalid-contract.md 1 "$reused_brief" >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 4 && -e "$reused_brief" && ! -s "$reused_brief" ]]; then
        pass "failed typed regeneration invalidates a stale brief"
    else
        fail "failed typed regeneration invalidates a stale brief"
        echo "    exit: $rc; bytes: $(wc -c < "$reused_brief" 2>/dev/null || printf '?')"
    fi

    (cd "$repo" && "$SDD_SCRIPTS/task-brief" typed-plan.md 1 "$reused_brief" >/dev/null)
    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-a.md 99 "$reused_brief" >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 3 && -e "$reused_brief" && ! -s "$reused_brief" ]]; then
        pass "missing legacy task invalidates a stale brief"
    else
        fail "missing legacy task invalidates a stale brief"
        echo "    exit: $rc; bytes: $(wc -c < "$reused_brief" 2>/dev/null || printf '?')"
    fi

    (cd "$repo" && "$SDD_SCRIPTS/task-brief" typed-plan.md 1 "$reused_brief" >/dev/null)
    mv "$repo/typed-plan.md" "$repo/typed-plan.saved"
    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/task-brief" typed-plan.md 1 "$reused_brief" >/dev/null 2>&1) || rc=$?
    mv "$repo/typed-plan.saved" "$repo/typed-plan.md"
    if [[ "$rc" -eq 2 && -e "$reused_brief" && ! -s "$reused_brief" ]]; then
        pass "missing plan invalidates an explicit stale brief"
    else
        fail "missing plan invalidates an explicit stale brief"
        echo "    exit: $rc; bytes: $(wc -c < "$reused_brief" 2>/dev/null || printf '?')"
    fi

    local missing_default_out missing_default_path
    missing_default_out="$(cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-b.md 1)"
    missing_default_path="$(printf '%s\n' "$missing_default_out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
    mv "$repo/plan-b.md" "$repo/plan-b.saved"
    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-b.md 1 >/dev/null 2>&1) || rc=$?
    mv "$repo/plan-b.saved" "$repo/plan-b.md"
    if [[ "$rc" -eq 2 && -e "$missing_default_path" && ! -s "$missing_default_path" ]]; then
        pass "missing plan invalidates its default stale brief"
    else
        fail "missing plan invalidates its default stale brief"
        echo "    exit: $rc; bytes: $(wc -c < "$missing_default_path" 2>/dev/null || printf '?')"
    fi

    # --- review-package takes the plan first and lands in its directory ---
    local git_id=(-c user.email=t@example.com -c user.name=t -c commit.gpgsign=false)
    ( cd "$repo" \
        && git "${git_id[@]}" commit -qm c1 \
        && printf 'y\n' > f && git add f \
        && git "${git_id[@]}" commit -qm c2 )
    local rp_out rp_path
    rp_out="$(cd "$repo" && "$SDD_SCRIPTS/review-package" plan-a.md HEAD~1 HEAD)"
    rp_path="$(printf '%s\n' "$rp_out" | sed -n 's/^wrote \(.*\): [0-9].*$/\1/p')"
    case "$rp_path" in
        "$repo/.superpowers/sdd/plan-a/review-"*.diff)
            pass "review-package writes its diff under the plan's workspace" ;;
        *)
            fail "review-package writes its diff under the plan's workspace"
            echo "    got: $rp_path"
            ;;
    esac

    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/review-package" HEAD~1 HEAD >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "review-package without a plan errors with exit 2"
    else
        fail "review-package without a plan errors with exit 2"
        echo "    exit: $rc"
    fi

    local rp_explicit
    rp_explicit="$(cd "$repo" && "$SDD_SCRIPTS/review-package" plan-a.md HEAD~1 HEAD "$TEST_ROOT/explicit.diff")"
    if [[ -s "$TEST_ROOT/explicit.diff" && "$rp_explicit" == *"$TEST_ROOT/explicit.diff"* ]]; then
        pass "review-package honors an explicit OUTFILE"
    else
        fail "review-package honors an explicit OUTFILE"
        echo "    got: $rp_explicit"
    fi

    # --- Worktree isolation: a linked worktree resolves its own workspace ---
    local wt="$TEST_ROOT/wt"
    ( cd "$repo" && git worktree add -q "$wt" -b wt-feature )
    local wt_root wt_dir
    wt_root="$(cd "$wt" && git rev-parse --show-toplevel)"
    wt_dir="$(cd "$wt" && "$SDD_SCRIPTS/sdd-workspace" plan-a.md)"
    if [[ "$wt_dir" == "$wt_root/.superpowers/sdd/plan-a" && "$wt_dir" != "$dir_a" ]]; then
        pass "linked worktree resolves its own distinct workspace"
    else
        fail "linked worktree resolves its own distinct workspace"
        echo "    main: $dir_a"
        echo "    wt:   $wt_dir"
    fi

    printf 'y\n' > "$wt_dir/artifact.md"
    local wt_status
    wt_status="$(cd "$wt" && git status --porcelain)"
    if [[ "$wt_status" != *".superpowers"* ]]; then
        pass "worktree workspace invisible to git status"
    else
        fail "worktree workspace invisible to git status"
        echo "    status: $wt_status"
    fi

    echo ""
    if [[ "$FAILURES" -ne 0 ]]; then
        echo "FAILED: $FAILURES assertion(s)."
        exit 1
    fi
    echo "PASS"
}

main "$@"
