#!/bin/bash
# Hook: PreToolUse (Bash)
# Blocks direct branch creation. Forces use of git worktree via /worktree command.
#
# Input: JSON on stdin with tool_input.command
# Exit 0: allow, Exit 2: block

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# No command to check
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Detect new branch creation commands
if echo "$COMMAND" | grep -qE 'git\s+checkout\s+-b|git\s+switch\s+-c'; then
  echo "BLOCKED: Direct branch creation is not allowed." >&2
  echo "Use /worktree <issue-number> to create a worktree-based branch." >&2
  exit 2
fi

# Detect git branch <new-name> (but allow flags like -d, -D, --list, -v, -a, -r, --show-current)
if echo "$COMMAND" | grep -qE 'git\s+branch\s+[^-]'; then
  # Allow: git branch -d, git branch -D, git branch --delete, git branch --list, etc.
  if echo "$COMMAND" | grep -qE 'git\s+branch\s+(-d|-D|--delete|--list|-v|-vv|-a|-r|--show-current|--merged|--no-merged|--contains|--sort)'; then
    exit 0
  fi
  echo "BLOCKED: Direct branch creation is not allowed." >&2
  echo "Use /worktree <issue-number> to create a worktree-based branch." >&2
  exit 2
fi

exit 0
