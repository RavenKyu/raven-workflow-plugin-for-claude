#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--yes] <worktree-path>"
  echo ""
  echo "Deletes a worktree and its branch WITHOUT merging."
  echo ""
  echo "Options:"
  echo "  --yes, -y    Skip confirmation prompt"
  exit 1
}

SKIP_CONFIRM=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y)
      SKIP_CONFIRM=true
      shift
      ;;
    -*)
      echo "ERROR: Unknown option: $1" >&2
      usage
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 1 ]]; then
  usage
fi

WORKTREE_PATH="$1"

# Resolve to absolute path
WORKTREE_PATH=$(cd "$WORKTREE_PATH" && pwd)

# Verify this is a worktree
if ! git -C "$WORKTREE_PATH" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "ERROR: ${WORKTREE_PATH} is not a git worktree." >&2
  exit 1
fi

# Get branch name
BRANCH_NAME=$(git -C "$WORKTREE_PATH" rev-parse --abbrev-ref HEAD)

if [[ "$BRANCH_NAME" == "main" || "$BRANCH_NAME" == "master" ]]; then
  echo "ERROR: Cannot delete main/master worktree." >&2
  exit 1
fi

# Get the main repo directory
MAIN_REPO=$(git -C "$WORKTREE_PATH" worktree list | head -1 | awk '{print $1}')

echo "Deleting worktree (NO merge):"
echo "  Path:   ${WORKTREE_PATH}"
echo "  Branch: ${BRANCH_NAME}"
echo ""

if [[ "$SKIP_CONFIRM" != true ]]; then
  read -p "Are you sure? (y/N) " -n 1 -r
  echo ""

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
  fi
fi

cd "$MAIN_REPO"
git worktree remove --force "$WORKTREE_PATH"
git branch -D "$BRANCH_NAME"

echo "Done."
echo "  Worktree removed: ${WORKTREE_PATH}"
echo "  Branch deleted:   ${BRANCH_NAME}"
