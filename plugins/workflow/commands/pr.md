---
description: Create a pull request with a well-structured description from the current branch.
allowed-tools: Bash(git *), Bash(gh *)
---

# Create Pull Request

Create a pull request for the current branch.

## Steps

1. **Gather context**:
   - Run `git status` to check for uncommitted changes.
   - Run `git log --oneline main..HEAD` (or master) to see all commits on this branch.
   - Run `git diff main...HEAD --stat` to see files changed.
   - Check remote tracking with `git branch -vv`.

2. **Prepare**:
   - If there are uncommitted changes, ask the user whether to commit first.
   - If the branch has not been pushed, push with `git push -u origin $(git branch --show-current)`.

3. **Draft PR**:
   - Analyze ALL commits on the branch (not just the latest).
   - Write a clear title following Conventional Commits style.
   - Write a structured body.

4. **Create**:
   - Use `gh pr create` with the drafted title and body.
   - Show the PR URL when done.

## PR Body Format

```markdown
## Summary
- [Bullet points describing what changed and why]

## Changes
- [List of key changes by area/file]

## Test Plan
- [ ] [How to verify each change]

Generated with [Claude Code](https://claude.com/claude-code)
```
