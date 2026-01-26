---
description: Create and manage git worktrees for issue-based development.
allowed-tools: Bash(*)
---

# Git Worktree Management

Create or manage a git worktree linked to a GitHub issue.

**Argument**: `$ARGUMENTS` — issue number, or subcommand (list, remove)

## Steps

### Create Worktree (default: `$ARGUMENTS` is an issue number)

1. **Validate**:
   - Parse the issue number from `$ARGUMENTS`.
   - If no argument provided, show usage and list open issues with `gh issue list`.

2. **Create**:
   - Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/create-worktree.sh" <issue-number>`.
   - The script will:
     - Verify the issue exists
     - Create `../worktrees/<number>-<description>/`
     - Create branch `feat/<number>-<description>`
     - Initialize beads if available

3. **Post-create**:
   - Display the worktree path and branch name.
   - If beads is available, suggest: `/workflow:task` to start working on tasks.
   - If beads is NOT available, suggest running `bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-beads.sh"`.

### List Worktrees (`$ARGUMENTS` = "list")

- Run `git worktree list` and display formatted output.

### Remove Worktree (`$ARGUMENTS` = "remove <path>")

- Ask the user: merge first or delete without merging?
- If merge: run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/merge-worktree.sh" <path>`.
- If delete: run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/delete-worktree.sh" <path>`.

## Rules

- ALWAYS use this command instead of manually creating branches.
- Every worktree must be linked to a GitHub issue.
- Worktree path convention: `../worktrees/<issue-number>-<description>`
- Branch naming convention: `feat/<issue-number>-<description>`
