---
name: review
description: Review code for bugs, security issues, performance problems, and style. Use when the user asks to review code, a PR, or recent changes.
allowed-tools: Read, Grep, Glob, Bash(git diff*), Bash(git log*), Bash(git show*)
---

# Code Review

Review the code specified by $ARGUMENTS (file path, git diff, or recent changes).

## Review Checklist

For each issue found, categorize as **Critical**, **Important**, or **Suggestion**.

### 1. Correctness
- Logic errors, off-by-one mistakes, wrong variable usage
- Missing edge cases or error handling at system boundaries
- Incorrect assumptions about input data

### 2. Security
- SQL injection, command injection, path traversal
- Hardcoded secrets or credentials
- Unsafe deserialization, missing input validation on external data

### 3. Performance
- N+1 queries, unnecessary loops, missing indexes
- Large memory allocations, blocking calls in async code
- Missing caching where appropriate

### 4. Python Best Practices
- Proper use of context managers, generators, comprehensions
- Type hints on public interfaces
- Following PEP 8 naming conventions
- Appropriate exception handling (avoid bare except)

### 5. Design
- Single responsibility principle violations
- Overly complex functions (>30 lines warrants attention)
- Missing or misleading docstrings on public APIs

## Output Format

```
## Review Summary

**Files reviewed:** [list]
**Risk level:** Low / Medium / High

### Critical Issues
- [file:line] Description and suggested fix

### Important Issues
- [file:line] Description and suggested fix

### Suggestions
- [file:line] Description

### What looks good
- Brief positive observations
```
