---
description: Create GitHub issues (Epic + Tasks) from a spec file.
allowed-tools: Read, Glob, Bash(gh *)
---

# Create GitHub Issues from Spec

Parse a spec file and create a structured set of GitHub issues.

**Argument**: `$ARGUMENTS` — path to the spec file (e.g., `specs/user-auth.md`)

## Steps

1. **Read the spec**:
   - Read the spec file at the given path.
   - If the file doesn't exist, list available specs in `specs/` and ask the user to choose.
   - Parse out: title, overview, functional requirements, non-functional requirements, acceptance criteria.

2. **Plan issues**:
   - Create an **Epic issue** that contains the full overview and links to all task issues.
   - For each functional requirement (FR-xxx), create a **Task issue**.
   - For significant non-functional requirements, create additional Task issues.
   - Present the planned issues to the user for review before creating them.

3. **Create milestone** (if needed):
   - Check if a milestone matching the feature name exists: `gh api repos/:owner/:repo/milestones`.
   - If not, create one: `gh api repos/:owner/:repo/milestones -f title="<feature-name>"`.

4. **Create Epic issue**:
   - Use `gh issue create` with:
     - Title: `[Epic] <Feature Name>`
     - Body: Overview + checklist of all task issues (to be updated with issue numbers)
     - Labels: `epic` (create label if it doesn't exist)
     - Milestone: the feature milestone

5. **Create Task issues**:
   - For each task, use `gh issue create` with:
     - Title: `<FR/NFR description>`
     - Body: Detailed requirement + acceptance criteria + reference to Epic issue
     - Labels: `task`
     - Milestone: the feature milestone

6. **Update Epic**:
   - Edit the Epic issue body to include actual task issue numbers with checkboxes.
   - Use `gh issue edit <epic-number> --body "..."`.

7. **Summary**:
   - Display all created issues with their numbers and URLs.
   - Suggest next step: `/workflow:worktree <epic-issue-number>`

## Rules

- Spec file argument is required. If not provided, list available specs and ask.
- Always confirm the issue plan with the user before creating.
- Create labels (`epic`, `task`) if they don't exist: `gh label create <name>`.
- All task issues must reference the Epic issue number in their body.
