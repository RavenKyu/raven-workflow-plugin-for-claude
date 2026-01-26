#!/bin/bash
set -euo pipefail

echo "Setting up Beads task manager..."

# Check if bd is already installed
if command -v bd > /dev/null 2>&1; then
  echo "Beads (bd) is already installed: $(which bd)"
else
  echo "Beads (bd) not found. Installing..."

  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: try Homebrew first
    if command -v brew > /dev/null 2>&1; then
      echo "Installing via Homebrew..."
      brew install steveyegge/beads/bd
    else
      echo "ERROR: Homebrew not found. Install Homebrew first or install beads manually." >&2
      echo "  https://github.com/steveyegge/beads" >&2
      exit 1
    fi
  elif command -v npm > /dev/null 2>&1; then
    echo "Installing via npm..."
    npm install -g beads-cli
  else
    echo "ERROR: No supported package manager found (brew, npm)." >&2
    echo "Install beads manually: https://github.com/steveyegge/beads" >&2
    exit 1
  fi

  # Verify installation
  if ! command -v bd > /dev/null 2>&1; then
    echo "ERROR: Installation failed. bd command not found." >&2
    exit 1
  fi

  echo "Beads installed successfully: $(which bd)"
fi

# Initialize beads in current directory if not already done
if [[ -d ".beads" ]]; then
  echo "Beads already initialized in current directory."
else
  bd init
  echo "Beads initialized in current directory."
fi

echo ""
echo "Setup complete. Available commands:"
echo "  bd create <title>    — Create a new task"
echo "  bd ready             — List ready tasks"
echo "  bd update <id> --status in_progress — Start a task"
echo "  bd close <id>        — Close a task"
echo "  bd list              — List all tasks"
