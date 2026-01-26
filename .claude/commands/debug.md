---
description: Systematically debug an error, failure, or unexpected behavior.
argument-hint: "[error message, symptom, or failing test]"
allowed-tools: Read, Grep, Glob, Bash(python*), Bash(pytest*), Bash(uv run*), Bash(git log*), Bash(git diff*)
---

# Debug

Systematically debug: $ARGUMENTS

## Process

### 1. Gather Information
- Read the full error message, stack trace, or symptom description.
- Identify the exact file, line, and function where the error occurs.
- Check recent changes with `git log --oneline -10` and `git diff` if it might be a regression.

### 2. Form Hypotheses
- List at least 3 possible causes, ordered by likelihood.
- For each hypothesis, describe what evidence would confirm or rule it out.

### 3. Test Hypotheses
- Start with the most likely cause.
- Read the relevant code. Trace the data flow.
- Check inputs, outputs, types, and state at each step.
- If needed, suggest adding temporary debug output (print/logging).

### 4. Identify Root Cause
- Confirm the root cause with evidence (not just correlation).
- Explain the chain of events: what triggered the error.

### 5. Fix
- Apply the minimal fix.
- Verify the fix resolves the issue.
- Ensure existing tests still pass.

## Output Format

```
## Symptom
[What was observed]

## Investigation
1. [Hypothesis → Evidence → Result]
2. ...

## Root Cause
[One paragraph explanation]

## Fix Applied
[What was changed]

## Verification
[Test results]
```
