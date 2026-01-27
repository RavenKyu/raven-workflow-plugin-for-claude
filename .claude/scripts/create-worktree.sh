#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 <issue-number> [description]"
  echo ""
  echo "Creates a git worktree for the given GitHub issue."
  echo "If description is omitted, it is derived from the issue title."
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

ISSUE_NUMBER="$1"
DESCRIPTION="${2:-}"

# Validate issue number is a positive integer
if ! [[ "$ISSUE_NUMBER" =~ ^[1-9][0-9]*$ ]]; then
  echo "ERROR: Issue number must be a positive integer, got: ${ISSUE_NUMBER}" >&2
  exit 1
fi

# Detect GitHub and remote availability
HAS_GITHUB=true
if ! gh repo view --json name > /dev/null 2>&1; then
  HAS_GITHUB=false
fi

HAS_REMOTE=true
if ! git remote get-url origin > /dev/null 2>&1; then
  HAS_REMOTE=false
fi

# Verify issue exists (skip if no GitHub repo)
if [[ "$HAS_GITHUB" == true ]]; then
  if ! gh issue view "$ISSUE_NUMBER" --json title -q '.title' > /dev/null 2>&1; then
    echo "ERROR: GitHub issue #${ISSUE_NUMBER} not found." >&2
    echo "Create the issue first with: /create-issues <spec-file>" >&2
    exit 1
  fi
else
  echo "WARNING: GitHub repo not available. Skipping issue verification." >&2
fi

# Derive description from issue title if not provided
if [[ -z "$DESCRIPTION" ]]; then
  if [[ "$HAS_GITHUB" == true ]]; then
    ISSUE_TITLE=$(gh issue view "$ISSUE_NUMBER" --json title -q '.title')
    DESCRIPTION=$(echo "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
    # Fallback if title has no ASCII characters (e.g. Korean/CJK titles)
    if [[ -z "$DESCRIPTION" ]]; then
      DESCRIPTION="task"
    fi
  else
    echo "ERROR: Description is required when GitHub repo is not available." >&2
    echo "Usage: $0 <issue-number> <description>" >&2
    exit 1
  fi
fi

WORKTREE_DIR="../worktrees/${ISSUE_NUMBER}-${DESCRIPTION}"
BRANCH_NAME="feat/${ISSUE_NUMBER}-${DESCRIPTION}"

# Ensure worktrees parent directory exists
mkdir -p ../worktrees

# Check if worktree already exists
if git worktree list | grep -q "${ISSUE_NUMBER}-${DESCRIPTION}"; then
  echo "Worktree already exists for issue #${ISSUE_NUMBER}."
  echo "Path: $(git worktree list | grep "${ISSUE_NUMBER}-${DESCRIPTION}" | awk '{print $1}')"
  exit 0
fi

# Determine start point for new branch
if [[ "$HAS_REMOTE" == true ]]; then
  # Fetch latest from remote
  git fetch origin main 2>/dev/null || git fetch origin master 2>/dev/null || true

  if git rev-parse --verify origin/main > /dev/null 2>&1; then
    START_POINT="origin/main"
  elif git rev-parse --verify origin/master > /dev/null 2>&1; then
    START_POINT="origin/master"
  else
    echo "WARNING: Remote has no main/master branch. Using local HEAD." >&2
    START_POINT="HEAD"
  fi
else
  # No remote — use local main, master, or HEAD
  if git rev-parse --verify main > /dev/null 2>&1; then
    START_POINT="main"
  elif git rev-parse --verify master > /dev/null 2>&1; then
    START_POINT="master"
  else
    START_POINT="HEAD"
  fi
fi

# Create worktree
if ! git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" "$START_POINT"; then
  # Clean up partially created directory on failure
  if [[ -d "$WORKTREE_DIR" ]]; then
    rm -rf "$WORKTREE_DIR"
  fi
  echo "ERROR: Failed to create worktree. Check if branch '${BRANCH_NAME}' already exists." >&2
  exit 1
fi

echo "Worktree created successfully."
echo "  Path:   $(cd "$WORKTREE_DIR" && pwd)"
echo "  Branch: ${BRANCH_NAME}"
echo "  Issue:  #${ISSUE_NUMBER}"

# Initialize beads if available
if command -v bd > /dev/null 2>&1; then
  (
    cd "$WORKTREE_DIR"
    if [[ ! -d ".beads" ]]; then
      bd init
      echo "  Beads:  initialized"
    else
      echo "  Beads:  already initialized"
    fi
  )
else
  echo "  Beads:  not installed (run setup-beads.sh to install)"
fi
