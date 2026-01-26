---
description: Initialize a project for the workflow plugin — create directories, install beads, configure Serena MCP, and set up rules.
allowed-tools: Read, Write, Bash(*), Glob
---

# Install Workflow Plugin into Project

Set up the current project to use the full Spec → Issue → Worktree → Beads workflow.

**Argument**: `$ARGUMENTS` — optional flags (e.g., `--with-rules`, `--skip-beads`, `--skip-mcp`)

## Steps

### 1. Create Required Directories

- Create `specs/` directory for feature specifications.
- Ensure `.claude/` directory exists.

### 2. Install Beads (unless `--skip-beads`)

- Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-beads.sh"` to install and initialize Beads.
- If beads is already installed, skip.

### 3. Configure Serena MCP (unless `--skip-mcp`)

Set up the Serena code intelligence MCP server for the project.

1. **Check prerequisites**:
   - Verify `uvx` is available: `command -v uvx`
   - If not, inform the user to install `uv` first: `curl -LsSf https://astral.sh/uv/install.sh | sh`

2. **Check existing configuration**:
   - Check if `.mcp.json` already exists in the project root.
   - If it exists, check if `serena` is already configured.
   - If Serena is already configured, skip.

3. **Create or update `.mcp.json`**:
   - If `.mcp.json` does not exist, create it with Serena configuration:
     ```json
     {
       "mcpServers": {
         "serena": {
           "type": "stdio",
           "command": "uvx",
           "args": [
             "--from",
             "git+https://github.com/oraios/serena",
             "serena",
             "start-mcp-server",
             "--context=claude-code",
             "--project-from-cwd"
           ],
           "env": {}
         }
       }
     }
     ```
   - If `.mcp.json` exists but Serena is not configured, add the `serena` entry to the existing `mcpServers` object using `jq`:
     ```bash
     jq '.mcpServers.serena = {
       "type": "stdio",
       "command": "uvx",
       "args": ["--from", "git+https://github.com/oraios/serena", "serena", "start-mcp-server", "--context=claude-code", "--project-from-cwd"],
       "env": {}
     }' .mcp.json > .mcp.json.tmp && mv .mcp.json.tmp .mcp.json
     ```

4. **Verify**: Confirm `.mcp.json` was written correctly by reading it back.

### 4. Copy Rules (if `--with-rules`)

Copy coding rules to the project's `.claude/rules/` directory:

- `coding-style.md` — Python coding style
- `git-workflow.md` — Git and worktree conventions
- `workflow.md` — Development workflow rules
- `testing.md` — Testing standards
- `security.md` — Security rules

These rules are embedded in the plugin's skill, but copying them ensures they are always applied as project-level rules.

Ask the user which rules to copy (all or select).

### 5. Update .gitignore

Add the following patterns to `.gitignore` if not already present:

```
# Worktrees
../worktrees/

# Beads
.beads/
```

### 6. Summary

Display:
- Directories created
- Beads installation status
- Serena MCP configuration status
- Rules copied (if applicable)
- Next step suggestion: `/workflow:spec <feature-name>` to start your first feature.

## Rules

- Do NOT overwrite existing files without asking the user.
- If `specs/` already exists, skip creation.
- If `.claude/rules/` already has rules, ask before overwriting.
- If `.mcp.json` already has Serena configured, skip MCP setup.
- Always verify `jq` is available before modifying JSON: `command -v jq`.
