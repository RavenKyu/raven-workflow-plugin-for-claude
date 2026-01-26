---
description: Explain how code works in detail — a file, function, module, or architecture.
argument-hint: "[file path, function name, or concept]"
allowed-tools: Read, Grep, Glob
---

# Explain Code

Explain $ARGUMENTS in clear, structured detail.

## Process

1. **Read the target**: Identify the code or concept to explain.
2. **Trace the flow**: Follow the execution path, data flow, or dependency chain.
3. **Find callers/callees**: Understand how this code connects to the rest of the system.
4. **Explain incrementally**: Start with the high-level purpose, then drill into details.

## Guidelines

- Start with a one-sentence summary of WHAT it does and WHY it exists.
- Explain the main logic flow step by step.
- Highlight non-obvious parts: clever tricks, workarounds, edge case handling.
- Note any potential issues, tech debt, or areas of concern.
- Use simple language. Avoid restating code as prose — explain the reasoning behind it.
- If explaining architecture, describe the key components and how they interact.

## Output Format

```
## Summary
[One paragraph: what it does and why]

## How It Works
1. [Step-by-step explanation of the main flow]
2. ...

## Key Details
- [Non-obvious behavior, edge cases, important assumptions]

## Dependencies
- [What this code depends on and what depends on it]

## Notes
- [Tech debt, potential improvements, or things to watch out for]
```
