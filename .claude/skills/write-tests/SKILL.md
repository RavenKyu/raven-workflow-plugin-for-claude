---
name: write-tests
description: Write pytest tests for the specified code. Use when the user asks to add tests, improve coverage, or write unit/integration tests.
argument-hint: "[file or function to test]"
allowed-tools: Read, Grep, Glob, Bash(python*), Bash(pytest*), Bash(uv run*)
---

# Write Tests

Write comprehensive pytest tests for $ARGUMENTS.

## Process

1. **Read the target code** to understand its behavior, inputs, outputs, and edge cases
2. **Find existing tests** by searching for `test_` files in the project to understand patterns and conventions
3. **Identify test location** following the project's existing test structure
4. **Write tests** following the guidelines below
5. **Run the tests** to verify they pass

## Test Writing Guidelines

### Structure
- Use `pytest` style (functions, not unittest classes) unless the project uses classes
- Group related tests in classes prefixed with `Test` when there are many tests for one unit
- Use descriptive names: `test_<function>_<scenario>_<expected>` (e.g. `test_parse_config_missing_key_raises_error`)

### Coverage Strategy
- **Happy path**: Normal expected inputs and outputs
- **Edge cases**: Empty inputs, None, boundary values, large inputs
- **Error cases**: Invalid inputs, missing dependencies, permission errors
- **Type variations**: Different valid input types if applicable

### Best Practices
- Use `pytest.raises` for expected exceptions
- Use `pytest.mark.parametrize` to reduce repetitive tests
- Prefer real objects over mocks; mock only external services and I/O
- Each test should be independent and not rely on test execution order
- Use fixtures for shared setup; place in `conftest.py` if shared across files
- Keep tests focused: one assertion concept per test (multiple asserts are fine if testing one behavior)

### What NOT to do
- Don't test private methods directly; test through public interface
- Don't test framework/library behavior
- Don't write trivial tests (e.g. testing that a constant equals itself)
- Don't over-mock; it makes tests brittle and meaningless

## Output

- Place test files following the project's convention (e.g. `tests/test_<module>.py`)
- Run `pytest <test_file> -v` to verify all tests pass
- Report coverage if `pytest-cov` is available
