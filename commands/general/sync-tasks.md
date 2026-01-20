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

### CRITICAL SECURITY VALIDATION

**Execute these checks BEFORE processing any files. If any check fails, STOP immediately.**

### Pre-Execution Validation

**Execute validation script to check TASKS.md and discover/validate TODO.md files:**

1. **REQUIRED: Use Glob tool** (NOT bash find) to locate validate-tasks.sh:
   - Pattern: `~/.claude/plugins/**/sirmaelstroms-claude-code/scripts/validate-tasks.sh`
   - This handles both marketplace and local installations
   - If Glob returns no matches, report error: "validate-tasks.sh not found in plugin installation"
   - **Why Glob**: Already permitted globally, avoids permission prompts from bash find

2. Execute the validation script with the path from Glob:
   - Run: `<script_path> --working-dir "."` using Bash tool
   - Capture both output (JSON) and exit code

3. Parse the JSON output from validation script:
   - Extract `status` field (success/validation_failed/critical_error)
   - Extract validated TODO.md file paths from `todo_files.files[].path` where status="valid"
   - Extract any errors from `errors[]` array
   - Extract any warnings from `warnings[]` array

4. Handle validation results based on exit code:
   - **Exit code 2 (critical error)**: Display errors from JSON, abort sync operation
   - **Exit code 1 (warnings)**: Display warnings, continue with only validated files
   - **Exit code 0 (success)**: Proceed with all validated TODO.md files

5. Report validation results:
   - Display count of validated TODO.md files
   - List any files that were rejected (from warnings/errors)

**Validation script details:**
- Script location: `scripts/validate-tasks.sh` in plugin installation
- Checks TASKS.md (exists, not symlink, writable, in current directory)
- Discovers TODO.md files recursively (max depth 4, excluding common non-project directories)
- Validates each TODO.md (not symlink, within workspace, size limits)
- **Resource Limits:**
  - Max TODO.md files: 100
  - Max file size: 100KB per file
  - Max total size: 5MB across all files
- **Exit Codes:**
  - 0: All validation passed
  - 1: Some files rejected (warnings), proceed with validated subset
  - 2: Critical error (TASKS.md issues), must abort
- **Output:** JSON with validation results, errors, warnings, and validated file list

### 1. Scan Projects
Read all TODO.md files from the validated list:
- Use `$VALIDATED_TODO_FILES` array from validation script output
- Files have already been discovered and security-validated (symlinks rejected, size limits enforced, workspace boundaries checked)
- Read each validated TODO.md using Read tool
- Extract project name from parent directory path (not absolute path)

### 2. Count Tasks by Status

**Parsing Rules (EXPLICIT - prevent ambiguity):**

1. **Heading Detection**:
   - Match headings case-insensitive: `## Active`, `## active`, `## ACTIVE` all valid
   - Exact text match required (after case normalization)
   - Valid headings: `Active`, `Blocked`, `In Progress`, `Ideas / Future`, `Completed`
   - Ignore headings nested under other headings (only level 2 headings `##`)

2. **Checkbox Detection**:
   - Must start line with pattern: `^- \[[ xX]\]` (no indentation before dash)
   - Unchecked: `[ ]` (space between brackets)
   - Checked: `[x]` or `[X]` (lowercase or uppercase X)
   - **Top-level definition**: Checkboxes with NO indentation (column 0)
   - **Nested items** (any indentation): IGNORE, do not count
   - Rationale: Sub-tasks are indented (typically 2 spaces) to indicate hierarchy

3. **Code Block Handling**:
   - Ignore checkboxes inside fenced code blocks (lines between ``` or ~~~, with optional language)
   - Ignore checkboxes inside indented code blocks (lines with 4+ space prefix)
   - Track code block state while parsing to skip checkbox counting
   - Inline code (single backticks) does NOT affect checkbox counting

4. **Edge Cases**:
   - If heading missing: Treat as 0 tasks for that section
   - If TODO.md empty: Report 0 tasks for all sections
   - If malformed checkboxes (e.g., `[  ]`, `[]`): Skip those lines
   - If nested checkboxes: Count only first level under heading

**For each project TODO.md, count tasks in each section:**
- **Active** - `[ ]` checkboxes under "## Active" heading
- **Blocked** - `[ ]` checkboxes under "## Blocked" heading
- **In Progress** - `[ ]` checkboxes under "## In Progress" heading (if exists)
- **Ideas/Future** - `[ ]` checkboxes under "## Ideas / Future" heading
- **Completed** - `[x]` or `[X]` checkboxes under "## Completed" heading

**Input Sanitization**:
- **Project name extraction**:
  1. Compute relative path from workspace root: `${todo_file#$workspace_root/}`
  2. Extract first directory component: `${relative_path%%/*}`
  3. Sanitize: Remove path separators, control chars, limit to 100 chars
  4. Validate: Must match `^[a-zA-Z0-9_.-]+$` (alphanumeric, underscore, dash, dot only)
  5. If invalid: Use `project_$(sha256sum <<< "$todo_file" | head -c 8)` as fallback
- Task descriptions: Not included in counts (only checkbox presence matters)
- Example: `/workspace/my-app/src/TODO.md` → relative `my-app/src/TODO.md` → project `my-app`

**Implementation:**

Use the provided parsing script for consistent task counting:

1. **REQUIRED: Use Glob tool** (NOT bash find) to locate parse-todo-tasks.py:
   - Pattern: `~/.claude/plugins/**/sirmaelstroms-claude-code/scripts/parse-todo-tasks.py`
   - This handles both marketplace and local installations
   - If Glob returns no matches, report error: "parse-todo-tasks.py not found in plugin installation"
   - **Why Glob**: Already permitted globally, avoids permission prompts from bash find

2. For each validated TODO.md file from step 1:
   - Run: `python3 <parse_script_path> <todo_file_path>` using Bash tool
   - Parse the pipe-separated output: `active|blocked|in_progress|ideas|completed`
   - Store counts for this project

**Benefits**:
- Consistent parsing logic across all invocations
- Pre-tested implementation (handles edge cases, code blocks, nested checkboxes)
- Clear separation of concerns (parsing vs. orchestration)

### 3. Identify Changes
Compare current counts with "Project Task Summaries" section in TASKS.md:
- Highlight new tasks (count increased)
- Highlight completed tasks (completed count increased)
- Flag blockers that have been blocked >7 days (check TASKS.md history)
- Note any newly blocked tasks

### 4. Update Central TASKS.md

**CRITICAL: Perform security validation BEFORE writing (see Pre-Execution Validation above)**

**Section Update Logic:**

1. **Locate target section**:
   - Search for EXACT heading: `## Project Task Summaries (Auto-Synced by /sync-tasks)`
   - **Validation**: Heading must appear EXACTLY ONCE in TASKS.md
   - If multiple occurrences: Report error "TASKS.md is malformed (duplicate sections)" and ABORT
   - If zero occurrences: Append to END of TASKS.md:
     ```markdown

     ---

     ## Project Task Summaries (Auto-Synced by /sync-tasks)
     <!-- DO NOT EDIT MANUALLY - Updated by /sync-tasks command -->

     ```

2. **Replace section content**:
   - If section exists: Replace from heading to next `##` heading (or EOF if last section)
   - Use Edit tool with precise old_string/new_string to avoid corruption
   - Preserve all content BEFORE and AFTER this section exactly
   - **Safety**: If section boundaries unclear, report error and abort

3. **Section format**:
```markdown
## Project Task Summaries (Auto-Synced by /sync-tasks)
<!-- DO NOT EDIT MANUALLY - Updated by /sync-tasks command -->

### {project-name} ({total_active} tasks)
- {active_count} active, {blocked_count} blocked, {in_progress_count} in progress
- Last sync: YYYY-MM-DD HH:MM:SS
- Details: `{relative-path-to-TODO.md}`

### {project-2-name} ({total_active} tasks)
- {active_count} active, {blocked_count} blocked, {in_progress_count} in progress
- Last sync: YYYY-MM-DD HH:MM:SS
- Details: `{relative-path-to-TODO.md}`
```

4. **Update "Last updated" timestamp** at top of TASKS.md after successful sync

**Note**: Paths are relative to the working directory where sync-tasks was invoked.

**Safety**: If Edit tool fails (file changed during sync), report error and do NOT retry automatically.

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

**Fail-Secure Behavior:**

**Critical Errors (STOP immediately, do NOT update TASKS.md):**
- TASKS.md does not exist in current directory
- TASKS.md is a symlink
- TASKS.md is not writable
- More than 100 TODO.md files discovered (resource limit)
- Total file size exceeds 5MB

**Non-Critical Errors (Skip file, continue processing):**
- Individual TODO.md is symlink
- Individual TODO.md outside workspace
- Individual TODO.md >100KB
- Individual TODO.md parsing fails
- Individual TODO.md has permission errors

**Error Reporting:**
```
Sync completed with warnings:
- Files processed: 12
- Files skipped: 3
  - example-project/TODO.md: Symlink detected (security)
  - archived/old-project/TODO.md: Outside workspace (security)
  - large-project/TODO.md: >100KB (too large)
```

**Concurrency Warning:**
This command is NOT safe for concurrent execution:
- Do not edit TASKS.md or TODO.md files while sync is running
- Do not run multiple instances of /sync-tasks simultaneously
- If TASKS.md is modified during sync, changes may be overwritten
- For safety, review TASKS.md in git diff after sync

If Edit tool fails due to file changes, report error and suggest manual review.

## Known Security Limitations

**TOCTOU (Time-of-Check-Time-of-Use) Race Conditions**:
- File state can change between validation and processing (inherent shell limitation)
- **Impact**: Symlink could be created after symlink check passes
- **Mitigation**: Multiple validation points reduce window, but cannot eliminate race
- **Recommendation**: Do not run sync-tasks on untrusted or actively modified directories

**Cross-Platform Compatibility**:
- `stat` command syntax differs (macOS: `-f %z`, Linux: `-c %s`)
- `realpath` may not be available on all systems (requires coreutils)
- **Fallback**: Script detects platform and uses appropriate commands
- **Limitation**: Obscure platforms may have compatibility issues

**Concurrent Execution Safety**:
- No file locking mechanism implemented
- **Impact**: Simultaneous runs or file edits can cause corruption
- **Mitigation**: Single-user tool design, warns against concurrent use
- **Recommendation**: Review git diff after sync, avoid editing files during sync

**Symbolic Link Timing Attacks**:
- Sub-second timing attacks could theoretically bypass checks
- **Impact**: Requires precise timing and rapid file manipulation
- **Mitigation**: Multiple validation points make timing extremely difficult
- **Recommendation**: Low risk in practice, document for completeness

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
