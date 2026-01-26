---
name: workflow
description: Guides the full development workflow — Spec, GitHub Issues, Worktree, Beads tasks, Ralph loop. Auto-triggers when the user starts new feature development or asks about the workflow process.
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Bash(gh *), Bash(git *), Bash(bd *)
---

# Development Workflow Guide

This skill guides the full Spec → Issue → Worktree → Beads workflow, including autonomous task execution via Ralph loop.

## When to Activate

Trigger this skill when the user:
- Wants to start a new feature or task
- Asks "how do I start working on X?"
- Mentions creating a branch, issue, or spec
- Seems to be starting development without following the workflow

## Workflow Overview

```
1. /workflow:spec <feature>          → specs/<feature>.md
2. /workflow:create-issues <spec>    → GitHub Epic + Task issues
3. /workflow:worktree <issue-#>      → ../worktrees/<#>-<desc> + branch
4. /workflow:task                    → beads claim → code → test → close
5. /workflow:ralph                   → autonomous loop for all tasks
6. /workflow:pr                      → Pull Request
7. merge-worktree.sh                 → Merge + cleanup
```

## Step-by-Step Guidance

### Step 1: Spec
- Ask: "What feature are you building?"
- Guide: Run `/workflow:spec <feature-name>` to create a structured spec.
- The spec captures requirements, acceptance criteria, and scope.

### Step 2: GitHub Issues
- After spec is written, guide: Run `/workflow:create-issues specs/<feature>.md`.
- This creates an Epic issue and Task issues on GitHub.
- Milestones and labels are created automatically.

### Step 3: Worktree
- After issues are created, guide: Run `/workflow:worktree <issue-number>`.
- This creates an isolated worktree at `../worktrees/<number>-<desc>/`.
- IMPORTANT: Never create branches directly. Always use worktrees.

### Step 4: Beads Tasks (Manual)
- Inside the worktree, guide: Run `/workflow:task` to see ready tasks.
- Work through tasks one at a time: claim → implement → test → close.

### Step 5: Ralph Loop (Autonomous)
- Alternatively, run `/workflow:ralph` to autonomously process all tasks.
- Ralph claims, implements, tests, commits, and closes each task in a loop.
- Use `--max-iterations N` for safety.

### Step 6: Pull Request
- When all tasks are done, guide: Run `/workflow:pr` to create a PR.

### Step 7: Merge and Cleanup
- After PR is merged, run the merge-worktree script to clean up.

## Enforcement Rules

These rules are enforced by this workflow and MUST be followed:

### Git Workflow
- Direct branch creation is blocked by the `enforce-worktree.sh` hook.
- ALL commits must follow Conventional Commits format: `<type>(<scope>): <description>`
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
- Commit descriptions: imperative mood, lowercase, no period, max 72 chars.
- NEVER force push to main/master.
- NEVER commit `.env`, credentials, or secret files.
- Stage specific files by name. Avoid `git add -A` or `git add .`.

### Worktree Rules
- NEVER create git branches directly. Always use `/workflow:worktree <issue-number>`.
- Worktree path: `../worktrees/<issue-number>-<description>`
- Branch naming: `feat/<issue-number>-<description>`
- Every worktree must be linked to a GitHub issue.

### Development Workflow
- Specs must exist before issues. Issues must exist before worktrees.
- If the user tries to skip steps, remind them of the workflow order.
- Use Beads (`bd`) for granular task tracking within a worktree.
- Run tests before closing any task.

### Coding Style (Python)
- Use `ruff` for formatting and linting.
- Follow PEP 8 naming conventions.
- Add type hints to all public function signatures.
- Keep functions under 30 lines.
- Use early returns and guard clauses.
- NEVER use bare `except:`. Always catch specific exceptions.
- Use `pathlib.Path` instead of `os.path`.

### Testing Standards
- Use `pytest` for all tests.
- Test file naming: `test_<module>.py`.
- Test happy path, edge cases, and error cases.
- ALL tests must pass before and after changes.

### Security
- NEVER hardcode secrets in source code.
- Validate and sanitize ALL external input.
- Use parameterized queries for database operations.
- NEVER pass unsanitized input to `subprocess` or `eval`/`exec`.
