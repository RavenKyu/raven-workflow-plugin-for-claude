# workflow — Claude Code Plugin

Enforced **Spec → GitHub Issue → Git Worktree → Beads** development workflow with autonomous Ralph loop support.

## Installation

```bash
# From local directory
claude --plugin-dir ./plugin

# Or install from a registry (when published)
/plugin install workflow@<marketplace>
```

### Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) — for issue and PR management
- [jq](https://jqlang.github.io/jq/) — for hook JSON parsing
- [uv](https://docs.astral.sh/uv/) (`uvx`) — for running Serena MCP server
- [Beads](https://github.com/steveyegge/beads) (`bd`) — for task management (auto-installed via `/workflow:install`)

## Quick Start

```
/workflow:install                     # Set up project (dirs, beads, Serena MCP, gitignore)
/workflow:spec user-auth              # Write a feature spec
/workflow:create-issues specs/user-auth.md   # Create GitHub Epic + Tasks
/workflow:worktree 42                 # Create worktree for issue #42
/workflow:task                        # Manually work on tasks
/workflow:ralph                       # OR autonomous task execution
/workflow:pr                          # Create pull request
```

## Commands

| Command | Description |
|---------|-------------|
| `/workflow:install` | Initialize project for the workflow (dirs, beads, Serena MCP, rules) |
| `/workflow:spec <name>` | Create a structured feature specification |
| `/workflow:create-issues <spec>` | Create GitHub Epic + Task issues from a spec |
| `/workflow:worktree <issue-#>` | Create a git worktree linked to an issue |
| `/workflow:task [id]` | Claim and work on beads tasks (interactive) |
| `/workflow:ralph [--max-iterations N]` | Autonomous task loop (claim → code → test → close) |
| `/workflow:pr` | Create a pull request from the current branch |

## Workflow

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  /spec       │────▶│ /create-     │────▶│ /worktree   │
│  Write spec  │     │  issues      │     │ Create env  │
└─────────────┘     │ Epic + Tasks │     └──────┬──────┘
                    └──────────────┘            │
                                               ▼
                    ┌──────────────┐     ┌─────────────┐
                    │  /pr         │◀────│ /task or    │
                    │  Pull Request│     │ /ralph      │
                    └──────┬───────┘     │ Work tasks  │
                           │             └─────────────┘
                           ▼
                    ┌──────────────┐
                    │ merge-       │
                    │ worktree.sh  │
                    │ Cleanup      │
                    └──────────────┘
```

### Manual vs Autonomous

- **`/workflow:task`** — Interactive mode. You pick a task, implement it, and close it step by step.
- **`/workflow:ralph`** — Autonomous mode. Claude loops through all ready tasks automatically: claim → implement → test → commit → close → repeat.

## Ralph Loop

The Ralph loop (`/workflow:ralph`) provides autonomous task execution:

```bash
# Process all ready tasks (default max: 20 iterations)
/workflow:ralph

# Set a custom iteration limit
/workflow:ralph --max-iterations 30

# Preview what would be done
/workflow:ralph --dry-run
```

### How it works

1. **Pre-flight**: Verifies beads is installed, checks we're in a worktree (not main)
2. **Loop**: For each ready task:
   - Claims the task (`bd update <id> --status in_progress`)
   - Reads task details and acceptance criteria
   - Implements changes following project coding style
   - Runs tests (`uv run pytest -x -v`)
   - Commits with Conventional Commits format
   - Closes the task (`bd close <id>`)
3. **Exit**: When no more tasks are ready or max iterations reached
4. **Summary**: Reports completed, skipped, and remaining tasks

### Safety

- Maximum iteration limit prevents infinite loops
- Tests must pass before any task is closed
- Blocked/ambiguous tasks are skipped with a report
- Never force pushes or modifies git history

## MCP Server (Serena)

The `/workflow:install` command automatically configures [Serena](https://github.com/oraios/serena) as a project-level MCP server by creating or updating `.mcp.json`:

```json
{
  "mcpServers": {
    "serena": {
      "type": "stdio",
      "command": "uvx",
      "args": [
        "--from", "git+https://github.com/oraios/serena",
        "serena", "start-mcp-server",
        "--context=claude-code", "--project-from-cwd"
      ]
    }
  }
}
```

Serena provides semantic code intelligence: symbol search, reference finding, rename refactoring, and code overview — all through the MCP protocol.

- Skip MCP setup: `/workflow:install --skip-mcp`
- Requires `uvx` (part of [uv](https://docs.astral.sh/uv/))

## Hooks

The plugin includes a `PreToolUse` hook that blocks direct branch creation:

- `git checkout -b` → **BLOCKED**
- `git switch -c` → **BLOCKED**
- `git branch <new-name>` → **BLOCKED**

Use `/workflow:worktree <issue-number>` instead.

## Skills

The `workflow` skill auto-activates when you start working on a new feature. It guides you through the correct workflow order and enforces coding standards.

## Agents

The `task-worker` agent can be invoked to autonomously process a single beads task within a worktree.

## Project Structure

```
plugin/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── commands/
│   ├── spec.md               # /workflow:spec
│   ├── create-issues.md      # /workflow:create-issues
│   ├── worktree.md           # /workflow:worktree
│   ├── task.md               # /workflow:task
│   ├── ralph.md              # /workflow:ralph
│   ├── pr.md                 # /workflow:pr
│   └── install.md            # /workflow:install
├── skills/
│   └── workflow/
│       └── SKILL.md          # Workflow guide + integrated rules
├── agents/
│   └── task-worker.md        # Autonomous task processor
├── hooks/
│   └── hooks.json            # PreToolUse branch enforcement
├── scripts/
│   ├── create-worktree.sh    # Worktree creation
│   ├── merge-worktree.sh     # Merge + cleanup
│   ├── delete-worktree.sh    # Delete without merge
│   ├── setup-beads.sh        # Install beads
│   └── enforce-worktree.sh   # Hook: block direct branches
├── templates/
│   └── spec-template.md      # Feature spec template
└── README.md                 # This file
```

## Integration with Ralph Wiggum

This plugin can be used alongside the official `ralph-wiggum` plugin:

- **This plugin** provides the structured workflow (spec → issues → worktree → tasks)
- **`ralph-wiggum`** provides generic stop-hook-based Claude session looping

The `/workflow:ralph` command is specifically designed for Beads task queues, while the generic Ralph loop can be used for any repeating prompt.

## License

MIT
