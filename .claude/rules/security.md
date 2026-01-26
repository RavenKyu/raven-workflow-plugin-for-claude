---
description: Security rules for all code changes. Applied to prevent common vulnerabilities.
globs: "*.py"
---

# Security Rules

## Secrets

- NEVER hardcode secrets, API keys, passwords, or tokens in source code.
- Use environment variables or a secrets manager. Validate that required env vars exist at startup.
- NEVER commit `.env` files, credential files, or private keys. Verify `.gitignore` covers them.

## Input Validation

- Validate and sanitize ALL external input (user input, API responses, file contents, CLI arguments).
- Use parameterized queries for ALL database operations. NEVER use string formatting for SQL.
- Validate file paths to prevent path traversal attacks. Use `pathlib.Path.resolve()` and check against allowed directories.

## Command Execution

- NEVER pass unsanitized input to `subprocess`, `os.system`, or `eval`/`exec`.
- Use `subprocess.run()` with a list of arguments instead of shell=True.
- Prefer `shlex.quote()` if shell execution is unavoidable.

## Dependencies

- Pin dependency versions in `pyproject.toml` or `requirements.txt`.
- Prefer well-maintained, widely-used packages.

## Sensitive Data

- Never log secrets, tokens, passwords, or PII.
- Use constant-time comparison (`hmac.compare_digest`) for secret comparison.
- Ensure error messages do not expose internal system details to end users.

## When a Vulnerability is Found

1. Stop current work immediately.
2. Fix the vulnerability before proceeding.
3. If credentials were exposed, flag them for rotation.
4. Check for similar patterns elsewhere in the codebase.
