---
description: Testing standards for Python projects using pytest.
globs: "**/test_*.py,**/tests/**"
---

# Testing Standards

## Framework

- Use `pytest` for all tests. Do NOT use `unittest` style unless the project already uses it.
- Run tests with `uv run pytest` or `pytest`.

## Test Structure

- Place tests in `tests/` directory mirroring the source structure.
- Name test files `test_<module>.py`.
- Name test functions `test_<function>_<scenario>_<expected>`.
- Group related tests in `Test`-prefixed classes when there are many tests for one unit.

## What to Test

- **Happy path**: Expected inputs produce correct outputs.
- **Edge cases**: Empty, None, boundary values, large inputs.
- **Error cases**: Invalid inputs raise appropriate exceptions.
- Do NOT test private methods directly. Test through the public interface.
- Do NOT test framework or library behavior.

## Best Practices

- Use `pytest.raises` for expected exceptions.
- Use `pytest.mark.parametrize` to reduce repetitive tests.
- Prefer real objects over mocks. Mock only external services and I/O.
- Each test must be independent. No reliance on execution order.
- Use fixtures for shared setup. Place shared fixtures in `conftest.py`.
- One assertion concept per test (multiple asserts for one behavior are fine).

## Before Submitting

- ALL existing tests must pass before and after changes.
- New code should include tests for its public interface.
- Run `pytest -x -v` to verify. Use `--cov` when coverage reporting is available.
