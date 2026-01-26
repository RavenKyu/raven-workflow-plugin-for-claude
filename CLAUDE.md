# Project

This is a Claude Code configuration repository containing reusable skills, rules, commands, and agents for Python development workflows.

## Tech Stack

- Language: Python 3.11+
- Package manager: uv (fallback: pip)
- Test framework: pytest
- Linter/Formatter: ruff

## Key Commands

- `uv run pytest` — Run tests
- `uv run pytest --cov` — Run tests with coverage
- `uv run ruff check .` — Lint
- `uv run ruff format .` — Format

## Project Structure

```
.claude/
  skills/       — Reusable skill definitions (SKILL.md)
  rules/        — Always-applied coding rules
  commands/     — Custom slash commands
  agents/       — Subagent definitions
  scripts/      — Workflow shell scripts
  hooks/        — Pre-tool-use enforcement hooks
  templates/    — Spec and issue templates
  settings.json — Hook configuration
specs/          — Feature specification documents
```

## Rules

IMPORTANT: Always follow the rules in `.claude/rules/`. They cover coding style, security, testing, and git workflow.

## Workflow

IMPORTANT: All feature development follows this enforced workflow:

```
1. /spec <feature>        → Write spec in specs/<feature>.md
2. /create-issues <spec>  → Create GitHub Epic + Task issues
3. /worktree <issue-#>    → Create worktree at ../worktrees/<#>-<desc>
4. /task                  → Claim and work on beads tasks
5. /pr                    → Create pull request
6. merge-worktree.sh      → Merge branch + cleanup worktree
```

### Coding Workflow (within a task)
1. Read and understand the target code before making changes
2. Run existing tests before and after modifications
3. Keep changes minimal and focused on the task
4. Use Conventional Commits for all git commits

### Conventions
- **Worktree path**: `../worktrees/<issue-number>-<description>`
- **Branch naming**: `feat/<issue-number>-<description>`
- **Direct branch creation is blocked** — always use `/worktree`
- **Beads** (`bd`) is used for granular task tracking within worktrees
