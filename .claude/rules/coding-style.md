---
description: Python coding style and conventions. Applied to all Python code changes.
globs: "*.py"
---

# Python Coding Style

## Formatting

- Use `ruff` for formatting and linting. Do NOT manually fix style issues that ruff handles.
- Maximum line length: 88 characters (ruff default).
- Use trailing commas in multi-line collections and function signatures.

## Naming

- Follow PEP 8: `snake_case` for functions/variables, `PascalCase` for classes, `UPPER_SNAKE_CASE` for constants.
- Name variables and functions to reveal intent. Avoid single-letter names except in comprehensions and short lambdas.

## Type Hints

- Add type hints to all public function signatures (parameters and return types).
- Use `from __future__ import annotations` for modern annotation syntax.
- Prefer `X | None` over `Optional[X]`.

## Imports

- Group imports: stdlib, third-party, local. Separate each group with a blank line.
- Prefer explicit imports over wildcard imports.
- Use `from __future__ import annotations` as the first import when using modern type syntax.

## Functions and Classes

- Keep functions under 30 lines. Extract helper functions if longer.
- Use early returns and guard clauses to reduce nesting.
- Prefer comprehensions over manual loops when they improve readability.
- Use `dataclasses` or `NamedTuple` for structured data instead of raw dicts.
- Use `pathlib.Path` instead of `os.path` for file path operations.

## Error Handling

- NEVER use bare `except:`. Always catch specific exceptions.
- Use context managers (`with`) for resource management.
- Raise exceptions with descriptive messages at system boundaries.
- Let internal errors propagate naturally; don't catch and re-raise without adding value.

## Docstrings

- Add docstrings to public modules, classes, and functions.
- Use Google style docstrings.
- Do NOT add docstrings to private methods or obvious one-liners.
