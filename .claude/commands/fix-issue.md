---
description: Analyze a GitHub issue or bug report and implement a fix.
argument-hint: "[issue number, URL, or bug description]"
allowed-tools: Read, Grep, Glob, Bash(git *), Bash(gh *), Bash(python*), Bash(pytest*), Bash(uv run*)
---

# Fix Issue

Analyze and fix: $ARGUMENTS

## Process

### 1. Understand the Issue
- If a GitHub issue number or URL is given, read it with `gh issue view`.
- Identify: what is the expected behavior? What is the actual behavior?
- Determine the scope: which files/modules are likely involved?

### 2. Reproduce
- Find or write a minimal reproduction case.
- Run it to confirm the bug exists.

### 3. Locate Root Cause
- Trace the code path from the symptom to the root cause.
- Read relevant source code and tests.
- Check git blame/log if the bug might be a regression.

### 4. Implement Fix
- Make the minimal change that fixes the issue.
- Do NOT refactor unrelated code.
- Add or update tests that cover the fixed behavior.

### 5. Verify
- Run the new test to confirm it passes.
- Run the full test suite to ensure no regressions.
- Show `git diff` of the changes.

## Output

When done, provide:
- **Root cause**: One sentence explaining why the bug occurred.
- **Fix**: What was changed and why.
- **Tests**: What tests were added or updated.
- **Verification**: Test results confirming the fix.
