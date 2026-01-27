#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 [worktree-path]"
  echo ""
  echo "Merges the worktree branch into main and cleans up."
  echo "If worktree-path is omitted, uses the current directory."
  exit 1
}

WORKTREE_PATH="${1:-$(pwd)}"

# Resolve to absolute path
if [[ ! -d "$WORKTREE_PATH" ]]; then
  echo "ERROR: Directory not found: ${WORKTREE_PATH}" >&2
  exit 1
fi
WORKTREE_PATH=$(cd "$WORKTREE_PATH" && pwd)

# Validate path is within a worktrees directory
if [[ "$WORKTREE_PATH" != */worktrees/* ]]; then
  echo "ERROR: Path must be within a worktrees/ directory: ${WORKTREE_PATH}" >&2
  exit 1
fi

# Verify this is a worktree
if ! git -C "$WORKTREE_PATH" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "ERROR: ${WORKTREE_PATH} is not a git worktree." >&2
  exit 1
fi

# Get branch name from the worktree
BRANCH_NAME=$(git -C "$WORKTREE_PATH" rev-parse --abbrev-ref HEAD)

if [[ "$BRANCH_NAME" == "main" || "$BRANCH_NAME" == "master" ]]; then
  echo "ERROR: Cannot merge main/master into itself." >&2
  exit 1
fi

# Get the main repo directory
MAIN_REPO=$(git -C "$WORKTREE_PATH" worktree list | head -1 | awk '{print $1}')

echo "Merging worktree:"
echo "  Path:   ${WORKTREE_PATH}"
echo "  Branch: ${BRANCH_NAME}"
echo "  Into:   main"
echo ""

# Determine base branch
BASE_BRANCH="main"
if ! git -C "$MAIN_REPO" rev-parse --verify main > /dev/null 2>&1; then
  BASE_BRANCH="master"
fi

# Switch to main repo and merge
cd "$MAIN_REPO"

# Check for uncommitted changes in main repo
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
  echo "ERROR: Main repo has uncommitted changes. Commit or stash them first." >&2
  exit 1
fi

git checkout "$BASE_BRANCH"

if ! git merge "$BRANCH_NAME"; then
  echo "" >&2
  echo "ERROR: Merge failed (likely due to conflicts)." >&2
  echo "Resolve conflicts in ${MAIN_REPO}, then run:" >&2
  echo "  git worktree remove ${WORKTREE_PATH}" >&2
  echo "  git branch -d ${BRANCH_NAME}" >&2
  exit 1
fi

echo ""
echo "Merge complete. Cleaning up worktree..."

# Remove worktree and branch
git worktree remove "$WORKTREE_PATH"
git branch -d "$BRANCH_NAME"

echo "Done."
echo "  Worktree removed: ${WORKTREE_PATH}"
echo "  Branch deleted:   ${BRANCH_NAME}"
