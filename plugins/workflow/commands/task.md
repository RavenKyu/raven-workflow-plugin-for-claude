---
description: Work on beads tasks — claim, execute, and close tasks.
allowed-tools: Read, Write, Edit, Bash(bd *), Bash(git *), Bash(pytest*), Bash(python*), Bash(uv *)
---

# Beads Task Workflow

Manage and work on beads tasks in the current worktree.

**Argument**: `$ARGUMENTS` — optional task ID or subcommand (list, ready, create)

## Steps

### Show Ready Tasks (default: no argument or "ready")

1. Run `bd ready` to list tasks that are ready to work on.
2. If no ready tasks, run `bd list` to show all tasks.
3. Ask the user which task to work on.

### Claim and Work on Task (`$ARGUMENTS` is a task ID)

1. **Claim**:
   - Run `bd update <id> --status in_progress` to claim the task.
   - Run `bd show <id>` to display full task details.

2. **Understand**:
   - Read the task description and acceptance criteria.
   - Identify which files need to be modified.
   - Present a brief plan to the user.

3. **Execute**:
   - Implement the changes following project coding style.
   - Run tests: `uv run pytest -x -v` (or `pytest -x -v`).
   - Fix any test failures.

4. **Commit**:
   - Stage and commit changes using Conventional Commits format.
   - Reference the issue number in the commit message body.

5. **Close**:
   - Run `bd close <id>` to mark the task as done.
   - Show remaining tasks with `bd ready`.

### Create Tasks ("create")

- Ask the user for task title and description.
- Run `bd create "<title>"` to create the task.
- Optionally set dependencies with `bd update <id> --blocked-by <other-id>`.

### List All Tasks ("list")

- Run `bd list` to show all tasks with their statuses.

## Rules

- Always check `bd ready` before starting work to pick the right task.
- One task at a time. Close the current task before starting another.
- Run tests before closing a task.
- Commit changes with a reference to the issue number.
