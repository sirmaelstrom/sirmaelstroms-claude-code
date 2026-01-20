---
model: claude-sonnet-4-5
description: Synchronize project TODO.md files with central TASKS.md for unified task tracking
---

# Task Synchronization Workflow

This command synchronizes task lists between project-local TODO.md files and the central TASKS.md file.

## Purpose

Maintain a hierarchical task management system:
- **GOALS.md** - Strategic objectives (quarters/months)
- **TASKS.md** - Tactical backlog (weeks, centralized priorities)
- **{project}/TODO.md** - Project-specific tasks (technical details)

## Configuration

The sync-tasks command uses the **current working directory** as the base:
- **Central TASKS.md**: `./TASKS.md` (in current working directory)
- **Project TODO.md files**: Searches recursively for `*/TODO.md` (excluding `.git`, `node_modules`, etc.)

### Discovery Rules
1. Start from current working directory
2. Search for all `TODO.md` files recursively (max depth 4)
3. Exclude common non-project directories:
   - `.git`, `.svn`, `.hg` (version control)
   - `node_modules`, `vendor`, `packages` (dependencies)
   - `bin`, `obj`, `build`, `dist`, `target` (build outputs)
   - `archive`, `.archive` (archived content)
4. Extract project name from parent directory of TODO.md

## Workflow Steps

### 1. Scan Projects
Read all TODO.md files found via discovery:
- Use Glob tool with pattern `**/TODO.md`
- Apply exclusion filters
- Read each project's TODO.md
- Extract project name from parent directory path (not absolute path)

### 2. Count Tasks by Status
For each project TODO.md, count tasks in each section:
- **Active** - `[ ]` checkboxes under "## Active" heading
- **Blocked** - `[ ]` checkboxes under "## Blocked" heading
- **In Progress** - `[ ]` checkboxes under "## In Progress" heading (if exists)
- **Ideas/Future** - `[ ]` checkboxes under "## Ideas / Future" heading
- **Completed** - `[x]` checkboxes under "## Completed" heading

### 3. Identify Changes
Compare current counts with "Project Task Summaries" section in TASKS.md:
- Highlight new tasks (count increased)
- Highlight completed tasks (completed count increased)
- Flag blockers that have been blocked >7 days (check TASKS.md history)
- Note any newly blocked tasks

### 4. Update Central TASKS.md
Update the "## Project Task Summaries (Auto-Synced by /sync-tasks)" section:

```markdown
### {project-name} ({total_active} tasks)
- {active_count} active, {blocked_count} blocked, {in_progress_count} in progress
- Last sync: YYYY-MM-DD
- Details: `{relative-path-to-TODO.md}`
```

**Note**: Paths are relative to the working directory where sync-tasks was invoked.

### 5. Generate Sync Report
Provide a concise summary:

```markdown
## Task Sync Report ({date})

### Updated Projects
- **{project-1}**: {total_active} tasks ({active} active, {blocked} blocked)
- **{project-2}**: {total_active} tasks ({active} active, {blocked} blocked)

### Changes Since Last Sync
- **New tasks**: {count} ({project} +{n}, {project} +{n})
- **Completed tasks**: {count} ({project} +{n}, {project} +{n})
- **Newly blocked**: {count}
  - [{project}] {task_summary}

### Blockers (>7 days)
- [{project}] {task_summary} (blocked since YYYY-MM-DD)

### Suggested Priorities for This Week
Based on analysis, consider adding to TASKS.md "This Week":
1. {task_suggestion} - {reason}
2. {task_suggestion} - {reason}
3. {task_suggestion} - {reason}
```

## Sync Rules

1. **TASKS.md is authoritative for priorities** (what to work on)
2. **Project TODO.md is authoritative for details** (how to do it)
3. **Never delete completed tasks** from project TODO.md (move to "Completed" section)
4. **Flag blockers >7 days** for user review
5. **Suggest promoting important tasks** from project TODO.md to TASKS.md "This Week"
6. **Update "Last updated" timestamp** in TASKS.md after sync

## Task Suggestions Logic

When suggesting priorities, consider:
- **Unblock dependencies** - Tasks that unblock other tasks get highest priority
- **Quick wins** - Tasks marked "easy" or "simple" in project TODO.md
- **Critical path** - Tasks required for other work to proceed
- **Stale work** - Projects with no recent activity
- **Balance** - Suggest tasks from different projects, not all from one

## Output Format

After syncing, output:
1. **Sync report** (markdown format above)
2. **Updated TASKS.md** (use Edit tool to update)
3. **Recommendations** for user action

## Special Considerations

- **New projects**: If a project TODO.md exists but isn't in TASKS.md summaries, add it
- **Deleted projects**: If TASKS.md references a project whose TODO.md no longer exists, flag for removal
- **Empty projects**: If TODO.md has 0 active tasks, note in report but keep in summaries
- **Malformed TODO.md**: If parsing fails, report error and skip that project

## Error Handling

If errors occur:
- Report which project TODO.md had issues
- Continue processing other projects
- Include errors in sync report
- Do not update TASKS.md if critical errors occurred

## Example Invocation

User runs from workspace root (where TASKS.md exists):
```bash
cd /path/to/workspace
/sync-tasks
```

Expected workflow:
1. Scan `**/TODO.md` recursively from current directory
2. Count tasks in each discovered project
3. Compare with TASKS.md current state (must exist in current directory)
4. Update TASKS.md summaries section
5. Generate and display sync report
6. Suggest priorities based on analysis

**Prerequisites**:
- TASKS.md file must exist in current working directory
- At least one TODO.md file must exist in subdirectories

**Error Handling**:
- If TASKS.md doesn't exist in current directory, report error and suggest creating it
- If no TODO.md files found, report warning and suggest creating project TODO.md files
- If TASKS.md exists but has no "Project Task Summaries" section, append it

## Integration with Other Workflows

This command is designed to be run:
- **Weekly** (every Monday) as part of planning ritual
- **After major task completion** to update central view
- **When starting new work** to see current priorities
- **Before standups/reviews** to prepare status update

## Remember

The goal is to maintain visibility across all projects while keeping detailed tasks close to code. This command bridges the gap between strategic planning (GOALS.md), tactical execution (TASKS.md), and technical details (project TODO.md).
