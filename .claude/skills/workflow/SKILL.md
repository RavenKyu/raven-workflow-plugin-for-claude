---
name: workflow
description: Guides the full development workflow — Spec, GitHub Issues, Worktree, Beads tasks. Auto-triggers when the user starts new feature development or asks about the workflow process.
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Bash(gh *), Bash(git *), Bash(bd *)
---

# Development Workflow Guide

This skill guides the full Spec → Issue → Worktree → Beads workflow.

## When to Activate

Trigger this skill when the user:
- Wants to start a new feature or task
- Asks "how do I start working on X?"
- Mentions creating a branch, issue, or spec
- Seems to be starting development without following the workflow

## Workflow Overview

```
1. /spec <feature>        → specs/<feature>.md
2. /create-issues <spec>  → GitHub Epic + Task issues
3. /worktree <issue-#>    → ../worktrees/<#>-<desc> + branch
4. /task                  → beads claim → code → test → close
5. /pr                    → Pull Request
6. merge-worktree.sh      → Merge + cleanup
```

## Step-by-Step Guidance

### Step 1: Spec
- Ask: "What feature are you building?"
- Guide: Run `/spec <feature-name>` to create a structured spec.
- The spec captures requirements, acceptance criteria, and scope.

### Step 2: GitHub Issues
- After spec is written, guide: Run `/create-issues specs/<feature>.md`.
- This creates an Epic issue and Task issues on GitHub.
- Milestones and labels are created automatically.

### Step 3: Worktree
- After issues are created, guide: Run `/worktree <issue-number>`.
- This creates an isolated worktree at `../worktrees/<number>-<desc>/`.
- IMPORTANT: Never create branches directly. Always use worktrees.

### Step 4: Beads Tasks
- Inside the worktree, guide: Run `/task` to see ready tasks.
- Work through tasks one at a time: claim → implement → test → close.

### Step 5: Pull Request
- When all tasks are done, guide: Run `/pr` to create a PR.

### Step 6: Merge and Cleanup
- After PR is merged, run `.claude/scripts/merge-worktree.sh` to clean up.

## Enforcement

- Direct branch creation is blocked by the `enforce-worktree.sh` hook.
- If the user tries to skip steps, remind them of the workflow order.
- Specs must exist before issues. Issues must exist before worktrees.
