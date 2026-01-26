---
description: Generate or update documentation — docstrings, README, or module docs.
argument-hint: "[file, module, or 'readme']"
allowed-tools: Read, Grep, Glob, Bash(python*), Bash(uv run*)
---

# Generate Documentation

Generate documentation for: $ARGUMENTS

## Behavior by Target

### If target is a Python file or module:
- Read all public classes, functions, and methods.
- Add or update Google-style docstrings.
- Include: summary, Args, Returns, Raises sections as appropriate.
- Do NOT add docstrings to private methods or trivial functions.
- Preserve existing docstrings if they are accurate; update if outdated.

### If target is "readme" or a specific README:
- Read the project structure, entry points, and key modules.
- Generate a README with:
  - Project title and one-line description
  - Installation instructions
  - Quick start / usage example
  - Project structure overview
  - Development setup (test, lint, format commands)

### If target is an API module:
- Document each endpoint or public interface.
- Include request/response examples where possible.

## Docstring Format (Google Style)

```python
def function_name(param1: str, param2: int = 0) -> bool:
    """One-line summary of what this function does.

    Longer description if needed, explaining behavior,
    assumptions, or important details.

    Args:
        param1: Description of param1.
        param2: Description of param2. Defaults to 0.

    Returns:
        Description of return value.

    Raises:
        ValueError: When param1 is empty.
    """
```

## Rules

- Match the existing documentation style in the project.
- Be accurate — read the code to understand actual behavior before writing docs.
- Keep docstrings concise. Don't restate type hints in prose.
- If `$ARGUMENTS` is empty, ask the user what to document.
