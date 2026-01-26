---
description: Git workflow and commit conventions.
---

# Git Workflow

## Conventional Commits

ALL commit messages MUST follow the Conventional Commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation only
- **style**: Formatting (no code logic change)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding or correcting tests
- **build**: Build system or dependency changes
- **ci**: CI configuration changes
- **chore**: Other changes that don't modify src or test files

### Rules
- Description: imperative mood, lowercase, no period, max 72 characters.
- Scope: module or area affected (optional but encouraged).
- Body: explain WHAT and WHY, not HOW. Wrap at 72 characters.
- Breaking changes: add `!` after type/scope and `BREAKING CHANGE:` in footer.

## Workflow

1. Check `git status` and `git diff` before committing.
2. Stage specific files by name. Avoid `git add -A` or `git add .`.
3. NEVER commit `.env`, credentials, or secret files.
4. NEVER force push to main/master.
5. NEVER amend commits unless explicitly asked.
6. Create a NEW commit after pre-commit hook failures (do not amend).

## Branching

- Branch from main/master for new work.
- Use descriptive branch names: `feat/<issue-number>-<description>`.

## Worktrees

IMPORTANT: NEVER create branches directly. Always use git worktrees via `/worktree <issue-number>`.

- Worktree path: `../worktrees/<issue-number>-<description>`
- Branch naming: `feat/<issue-number>-<description>`
- Every worktree must be linked to a GitHub issue.
- Direct `git checkout -b`, `git switch -c`, and `git branch <name>` commands are blocked by hooks.
- To merge and clean up: `.claude/scripts/merge-worktree.sh`
- To delete without merging: `.claude/scripts/delete-worktree.sh`
