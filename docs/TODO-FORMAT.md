# TODO.md Format Specification

This document defines the standard format for project TODO.md files used with the `/sync-tasks` command.

## Purpose

TODO.md files provide project-specific task tracking that integrates with the central TASKS.md file through automated synchronization. The format is designed to be:
- Human-readable and editable
- Machine-parseable for automation
- Git-friendly for version control
- Compatible with standard markdown renderers

## File Location

Each project should have a `TODO.md` file in its root directory:
```
project-root/
├── TODO.md          ← Task tracking
├── README.md        ← Project overview
└── src/             ← Source code
```

## Required Sections

Every TODO.md must include these three sections:

### 1. Active
Tasks currently being worked on or ready to start.
```markdown
## Active

- [ ] Top-level task 1
- [ ] Top-level task 2
  - [ ] Nested subtask 2.1
  - [ ] Nested subtask 2.2
```

### 2. Ideas / Future
Tasks planned for the future or brainstorming ideas.
```markdown
## Ideas / Future

- [ ] Future enhancement 1
- [ ] Future enhancement 2
```

### 3. Completed
Finished tasks (keep recent history, archive old items).
```markdown
## Completed

- [x] Completed task 1 (2026-01-19)
- [x] Completed task 2 (2026-01-18)
```

## Optional Sections

### Blocked
Tasks that cannot progress due to dependencies or blockers.
```markdown
## Blocked

- [ ] Blocked task - waiting for API access
```

### In Progress
Tasks actively being worked on right now (useful for team coordination).
```markdown
## In Progress

- [ ] Currently implementing feature X
```

## Checkbox Format

### Top-Level Tasks
Top-level tasks must start at column 0 (no indentation):
```markdown
- [ ] Unchecked task
- [x] Completed task
- [X] Completed task (uppercase X also valid)
```

**Pattern:** `^- \[([ xX])\]`

### Nested Subtasks
Nested subtasks use 2-space indentation (standard markdown):
```markdown
- [ ] Parent task
  - [ ] Subtask 1
  - [ ] Subtask 2
    - [ ] Sub-subtask (4 spaces)
```

**Important:** Only top-level tasks (0 indentation) are counted by `/sync-tasks`. Nested tasks are for human organization and not included in automated counts.

### Invalid Formats
These checkbox formats are NOT valid:
```markdown
- [] Missing space inside brackets
- [  ] Two spaces inside brackets
- [y] Invalid checkbox character
-[ ] Missing space after dash
```

## Indentation Rules

1. **Use spaces, not tabs** - Ensures consistent rendering across editors
2. **Top-level tasks:** 0 spaces before dash
3. **First-level nesting:** 2 spaces before dash
4. **Second-level nesting:** 4 spaces before dash
5. **Pattern:** Each nesting level adds 2 spaces

## Line Endings

- **Preferred:** LF (Unix-style `\n`)
- **Acceptable:** CRLF (Windows-style `\r\n`)
- **Reason:** Git can normalize line endings, but LF is preferred for cross-platform compatibility

## Code Blocks

Checkboxes inside code blocks are ignored by the parser:

````markdown
## Active

- [ ] Real task (counted)

```markdown
- [ ] Example checkbox in code block (NOT counted)
```
````

## Section Headers

- **Level 2 headings only:** `## Section Name`
- **Case-insensitive:** `## Active`, `## active`, `## ACTIVE` all valid
- **Exact match required:** Header text must match expected sections

## Example Complete File

```markdown
# Project Name - Tasks

## Active

- [ ] Implement user authentication
  - [ ] Design login form
  - [ ] Add password validation
  - [ ] Implement session management
- [ ] Add dark mode toggle

## Blocked

- [ ] Deploy to production - waiting for server access

## Ideas / Future

- [ ] Add real-time notifications
- [ ] Implement user profiles
- [ ] Add search functionality

## Completed

- [x] Setup project structure (2026-01-19)
- [x] Configure build pipeline (2026-01-18)
- [x] Create initial documentation (2026-01-17)
```

## Validation

Validate your TODO.md file format:

```bash
# From sirmaelstroms-claude-code plugin directory
./scripts/validate-todo-format.sh /path/to/TODO.md
```

The validator checks:
1. Required sections present
2. Checkbox format correctness
3. Indentation consistency
4. Line ending style
5. Section hierarchy

## Best Practices

### Task Granularity
- **Top-level:** Logical units of work (features, bugs, refactoring)
- **Nested:** Implementation steps, subtasks, technical details
- **Keep nested tasks under 5 items** - If more, consider splitting the parent task

### Completion Tracking
- Move completed tasks to "Completed" section, don't delete them
- Add completion date in parentheses: `(2026-01-19)`
- Archive tasks older than 2 weeks to keep file manageable

### Blocked Tasks
- Clearly state the blocker: "waiting for X", "blocked by issue #123"
- Add date when task became blocked for tracking

### Sync with TASKS.md
- Run `/sync-tasks` weekly to update central TASKS.md
- Promote important tasks from TODO.md to TASKS.md "This Week" section manually
- TASKS.md is authoritative for **priorities**, TODO.md is authoritative for **details**

## Integration with /sync-tasks

The `/sync-tasks` command:
1. Discovers all `*/TODO.md` files in workspace
2. Counts top-level checkboxes in each section
3. Updates central TASKS.md with summary
4. Reports changes and suggests priorities

**Counted:**
- Active: `[ ]` checkboxes (unchecked) at column 0
- Blocked: `[ ]` checkboxes at column 0
- In Progress: `[ ]` checkboxes at column 0
- Ideas/Future: `[ ]` checkboxes at column 0
- Completed: `[x]` or `[X]` checkboxes at column 0

**Not counted:**
- Nested checkboxes (2+ space indentation)
- Checkboxes in code blocks
- Malformed checkboxes

## Troubleshooting

### "Section 'Active' MISSING" error
Add the required section:
```markdown
## Active

- [ ] First task
```

### Tasks not being counted
- Verify checkbox format: `- [ ]` with space after dash and inside brackets
- Check indentation: Must be at column 0 (no leading spaces)
- Run validator to identify issues

### Nested tasks counted as top-level
- Ensure nested tasks have 2+ spaces before the dash
- Top-level must have zero spaces before dash

### Sync showing wrong counts
- Verify you're using Python parser: `/scripts/parse-todo-tasks.py`
- Check for malformed checkboxes with validator
- Ensure file is valid UTF-8 encoding

## Format Version

**Version:** 1.0
**Last Updated:** 2026-01-20
**Compatible with:** `/sync-tasks` command v1.0.1+
