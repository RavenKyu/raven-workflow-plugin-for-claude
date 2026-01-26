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
WORKTREE_PATH=$(cd "$WORKTREE_PATH" && pwd)

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
git checkout "$BASE_BRANCH"
git merge "$BRANCH_NAME"

echo ""
echo "Merge complete. Cleaning up worktree..."

# Remove worktree and branch
git worktree remove "$WORKTREE_PATH"
git branch -d "$BRANCH_NAME"

echo "Done."
echo "  Worktree removed: ${WORKTREE_PATH}"
echo "  Branch deleted:   ${BRANCH_NAME}"
