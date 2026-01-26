---
description: Autonomous Ralph loop — automatically claim, implement, test, and close all ready Beads tasks.
allowed-tools: Read, Write, Edit, Bash(bd *), Bash(git *), Bash(pytest*), Bash(python*), Bash(uv *), Bash(ruff *)
---

# Ralph Loop — Autonomous Task Execution

Run an autonomous loop that processes all ready Beads tasks until completion.

**Argument**: `$ARGUMENTS` — optional flags (e.g., `--max-iterations 30`)

## Overview

Ralph Loop automates the Beads task workflow. It repeatedly:
1. Checks for ready tasks (`bd ready`)
2. Claims the next task
3. Implements, tests, and commits
4. Closes the task
5. Repeats until no tasks remain or the iteration limit is reached

## Parameters

Parse from `$ARGUMENTS`:
- `--max-iterations N` — Maximum number of task iterations (default: 20). Safety limit to prevent infinite loops.
- `--dry-run` — Show what would be done without actually executing.

## Steps

### 1. Pre-flight Check

- Verify `bd` is installed: `command -v bd`
- Verify we are in a git worktree (not main/master): `git rev-parse --abbrev-ref HEAD`
- Run `bd ready` to confirm there are tasks to process.
- Display the task queue to the user and ask for confirmation to start.

### 2. Task Loop

For each iteration (up to `--max-iterations`):

1. **Check queue**: Run `bd ready`. If no ready tasks, exit loop with success.

2. **Claim**: Pick the first ready task.
   - Run `bd update <id> --status in_progress`
   - Run `bd show <id>` to get full details.

3. **Implement**:
   - Read the task description and acceptance criteria.
   - Identify files to modify.
   - Implement changes following project coding style.

4. **Test**:
   - Run `uv run pytest -x -v` (or `pytest -x -v`).
   - If tests fail, attempt to fix (up to 3 retries per task).
   - If still failing after retries, mark the task as blocked and move on.

5. **Commit**:
   - Stage changed files (specific files, not `git add -A`).
   - Commit with Conventional Commits format, referencing the issue number.

6. **Close**:
   - Run `bd close <id>`.
   - Log: `[iteration/max] Completed: <task-title>`

### 3. Summary

After the loop ends, display:
- Total tasks processed
- Tasks completed successfully
- Tasks skipped/blocked (with reasons)
- Remaining ready tasks (if any)

## Completion Promise

The loop ends when ANY of these conditions are met:
- `bd ready` returns no tasks
- `--max-iterations` limit reached
- A critical error occurs (e.g., git conflict)

## Rules

- NEVER force push or modify git history.
- NEVER skip tests — all tests must pass before closing a task.
- One task at a time — close before claiming next.
- If a task is ambiguous or blocked, skip it and report.
- Commit messages must follow Conventional Commits and reference the issue number.
- If `--max-iterations` is reached, stop and report remaining tasks.
- Always show a final summary.
