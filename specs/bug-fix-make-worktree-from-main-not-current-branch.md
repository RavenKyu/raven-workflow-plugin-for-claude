# Bug Fix: Worktree Should Branch from Main, Not Current Branch

## Overview

The `create-worktree.sh` script silently falls back to `HEAD` (current branch) when `git fetch origin main` fails, causing new worktrees to be based on the wrong branch instead of the latest `origin/main`. This fix makes the script fail fast with a clear error when fetch fails, ensuring worktrees are always based on the correct main branch.

## Background

The current implementation (lines 77-98 in `create-worktree.sh`) attempts to fetch `origin/main` or `origin/master`, then verify the ref exists with `git rev-parse`. However:

1. The fetch command suppresses all errors: `git fetch origin main 2>/dev/null || ... || true`
2. If fetch fails silently (network issues, auth problems, etc.), the `origin/main` ref is not updated
3. The `git rev-parse --verify origin/main` check fails because the ref doesn't exist locally
4. The script falls back to `HEAD`, creating the worktree from the current branch

Users see the warning "Remote has no main/master branch. Using local HEAD." but this is misleading — the remote *does* have main, the fetch just failed.

## Functional Requirements

- [ ] FR-001: When a remote exists, the script MUST successfully fetch `origin/main` or `origin/master` before creating a worktree, or fail with an error.
- [ ] FR-002: If `git fetch` fails, the script MUST exit with a non-zero status and display a clear error message explaining the failure.
- [ ] FR-003: The error message MUST suggest troubleshooting steps (e.g., check network, verify authentication, run `git fetch` manually).
- [ ] FR-004: When no remote exists (`HAS_REMOTE=false`), the script MUST continue to use local `main`, `master`, or `HEAD` as fallback (existing behavior preserved).

## Non-Functional Requirements

- [ ] NFR-001: The fix must not break existing workflows where remotes are unavailable (local-only repos).
- [ ] NFR-002: The error message must be actionable and help users diagnose the issue quickly.

## Acceptance Criteria

- [ ] AC-001: Given a repo with remote `origin/main`, when `git fetch` succeeds, the worktree is created from `origin/main`.
- [ ] AC-002: Given a repo with remote `origin/main`, when `git fetch` fails (simulate with invalid remote URL), the script exits with error and displays a message mentioning "fetch failed".
- [ ] AC-003: Given a repo with no remote configured, when running the script with a description, the worktree is created from local `main` or `HEAD` without error (existing behavior).
- [ ] AC-004: The script's exit code is non-zero when fetch fails.

## Out of Scope

- Automatic retry logic for transient network failures — users should fix the underlying issue.
- Changes to the worktree directory structure or naming conventions.
- Changes to how the script handles the no-remote case.

## Technical Notes

**Root cause location**: Lines 77-98 in `.claude/scripts/create-worktree.sh`

**Proposed fix approach**:
1. Remove `2>/dev/null` and `|| true` from the fetch command to allow errors to propagate.
2. Add explicit error handling: check fetch exit code and fail with a descriptive message.
3. Alternatively, capture fetch output and check for success before proceeding.

**Example fix pattern**:
```bash
if [[ "$HAS_REMOTE" == true ]]; then
  if ! git fetch origin main 2>&1 && ! git fetch origin master 2>&1; then
    echo "ERROR: Failed to fetch from remote. Check network and authentication." >&2
    echo "Try running 'git fetch origin' manually to diagnose." >&2
    exit 1
  fi
  # ... rest of logic
fi
```

**Testing approach**:
- Test with valid remote (should succeed)
- Test with invalid/unreachable remote URL (should fail with clear error)
- Test with no remote configured (should fall back to local main/HEAD)
