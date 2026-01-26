---
description: Write a feature specification using the structured template.
allowed-tools: Read, Write, Glob
---

# Write Feature Specification

Create a structured specification document for a new feature.

**Argument**: `$ARGUMENTS` — the feature name (e.g., `user-auth`, `payment-flow`)

## Steps

1. **Read the template**:
   - Read the spec template from the plugin's templates directory.
   - The template is located at `${CLAUDE_PLUGIN_ROOT}/templates/spec-template.md`.

2. **Gather requirements interactively**:
   - Ask the user about each section of the spec:
     - **Overview**: What is this feature? One paragraph summary.
     - **Background**: Why is it needed? What is the current state?
     - **Functional Requirements**: What must the system do? List as FR-001, FR-002, etc.
     - **Non-Functional Requirements**: Performance, security, scalability constraints? List as NFR-001, etc.
     - **Acceptance Criteria**: How do we verify it works? List as AC-001, etc.
     - **Out of Scope**: What is explicitly NOT included?
     - **Technical Notes**: Implementation hints, constraints, dependencies.
   - For each section, propose content based on the discussion and confirm with the user.

3. **Write the spec**:
   - Generate the spec file at `specs/$ARGUMENTS.md`.
   - Replace `<Feature Name>` with a human-readable title derived from the argument.
   - Fill in all sections with the gathered information.

4. **Confirm**:
   - Show the user the path to the created spec.
   - Suggest next step: `/workflow:create-issues specs/$ARGUMENTS.md`

## Rules

- Feature name argument is required. If not provided, ask the user.
- Use kebab-case for the filename (e.g., `user-auth.md`).
- All FR/NFR/AC items must have unique IDs.
- Do NOT skip any section. If not applicable, write "N/A" with a brief reason.
