---
name: refactor
description: Refactor code to improve readability, maintainability, and design without changing behavior. Use when the user asks to clean up, simplify, or restructure code.
argument-hint: "[file or function to refactor]"
allowed-tools: Read, Grep, Glob, Bash(python*), Bash(pytest*), Bash(git diff*), Bash(uv run*)
---

# Refactor Code

Refactor $ARGUMENTS to improve code quality without changing external behavior.

## Process

1. **Understand the code**: Read the target and its references/callers
2. **Run existing tests**: Ensure all tests pass before making changes
3. **Identify improvements**: Analyze using the checklist below
4. **Apply changes incrementally**: One refactoring at a time
5. **Verify after each change**: Run tests to confirm behavior is preserved

## Refactoring Checklist

### Readability
- Rename unclear variables and functions to reveal intent
- Replace magic numbers/strings with named constants
- Simplify nested conditionals (early returns, guard clauses)
- Break long functions into smaller, focused functions

### Python-Specific
- Replace manual loops with comprehensions where clearer
- Use `pathlib` instead of `os.path` for path operations
- Use f-strings instead of `.format()` or `%` formatting
- Use `dataclasses` or `NamedTuple` instead of raw dicts for structured data
- Use `contextlib.contextmanager` for resource management patterns
- Replace `type()` checks with `isinstance()`

### Design
- Extract duplicated code into shared functions
- Separate concerns (I/O from logic, config from behavior)
- Reduce function arguments (>4 args suggests a need for grouping)
- Replace boolean flags with separate, clearly-named functions

### Cleanup
- Remove dead code (unused imports, unreachable branches, commented-out code)
- Remove unnecessary comments that just restate the code
- Ensure consistent error handling patterns

## Rules

- **Never change behavior**: Refactoring must be behavior-preserving
- **Keep changes focused**: Don't mix refactoring with feature work
- **Verify continuously**: Tests must pass after every change
- Show a summary of changes made when finished
