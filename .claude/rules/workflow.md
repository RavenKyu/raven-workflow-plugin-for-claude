---
description: Development workflow enforcement — Spec, Issues, Worktree, Beads.
---

# Development Workflow Rules

IMPORTANT: All feature development MUST follow this workflow:

```
Spec → GitHub Issues → Git Worktree → Beads Tasks → PR → Merge
```

## Worktree Rules

IMPORTANT: NEVER create git branches directly. Always use git worktrees via `/worktree <issue-number>`.

- Worktree path: `../worktrees/<issue-number>-<description>`
- Branch naming: `feat/<issue-number>-<description>`
- Every worktree must be linked to a GitHub issue.
- Direct `git checkout -b`, `git switch -c`, and `git branch <name>` are blocked by hooks.

## Spec-First Rule

IMPORTANT: Before creating GitHub issues, a spec must exist in `specs/`.

- Use `/spec <feature>` to create a structured spec.
- Specs must include: Functional Requirements, Non-Functional Requirements, Acceptance Criteria.
- Do NOT start coding without a spec and corresponding issues.

## Issue Tracking

- Every feature needs a GitHub Epic issue with linked Task issues.
- Use `/create-issues <spec-file>` to create issues from a spec.
- All commits must reference the issue number.

## Task Management

- Use Beads (`bd`) for granular task tracking within a worktree.
- Claim a task before starting: `bd update <id> --status in_progress`.
- Close tasks after completion: `bd close <id>`.
- Run tests before closing any task.

## Workflow Commands

| Command | Purpose |
|---------|---------|
| `/spec <name>` | Create a feature spec |
| `/create-issues <spec>` | Create GitHub issues from spec |
| `/worktree <issue-#>` | Create a worktree for an issue |
| `/task` | Work on beads tasks |
| `/pr` | Create a pull request |
