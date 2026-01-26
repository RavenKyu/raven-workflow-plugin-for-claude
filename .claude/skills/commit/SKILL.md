---
name: commit
description: Generate a Conventional Commits message and create a git commit from staged or all changes.
disable-model-invocation: true
allowed-tools: Bash(git *)
---

# Commit with Conventional Commits

Generate a commit message and create a git commit following the Conventional Commits specification.

## Steps

1. Run `git status` and `git diff --staged` (or `git diff` if nothing staged) to understand changes
2. Run `git log --oneline -5` to see recent commit style
3. Analyze the changes and determine the appropriate type and scope

## Conventional Commits Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation only
- **style**: Formatting, missing semicolons (no code change)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding or correcting tests
- **build**: Changes to build system or dependencies
- **ci**: CI configuration changes
- **chore**: Other changes that don't modify src or test files

### Rules
- Description: imperative mood, lowercase, no period at end, max 72 chars
- Scope: the module, component, or area affected (optional but encouraged)
- Body: explain WHAT changed and WHY, not HOW (wrap at 72 chars)
- Breaking changes: add `!` after type/scope and `BREAKING CHANGE:` in footer

## Behavior

- If no files are staged, ask the user what to stage
- Show the generated commit message to the user before committing
- After commit, show `git log --oneline -1` to confirm
