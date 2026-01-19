---
description: Commit changes, push to remote, and create PR
model: claude-sonnet-4-5
---

# Git Workflow: Commit, Push, and Create PR

Execute a complete git workflow: stage changes, commit with co-authorship attribution, push to remote, and create a pull request.

## Workflow Steps

Follow these steps in order:

### 1. Analyze Current State

Run these commands in parallel to understand the current state:
- `git status` - See all untracked files (NEVER use -uall flag)
- `git diff` - See both staged and unstaged changes
- Check if current branch tracks a remote branch and is up to date

### 2. Review Changes

Analyze all changes that will be committed:
- Review the diff output to understand what changed
- Identify the nature of changes (new feature, enhancement, bug fix, refactoring, tests, docs, etc.)
- Ensure no sensitive files are being committed (.env, credentials.json, secrets, etc.)
- If secrets are detected, warn the user and do NOT proceed unless explicitly requested

### 3. Stage Changes

Add relevant untracked and modified files to the staging area:
- Use `git add <files>` for specific files
- Only stage files that are part of the logical change
- Do NOT stage unrelated changes

### 4. Create Commit

Create a commit following these guidelines:

**Commit Message Format:**
- First line: Concise summary (50-72 chars) focusing on "why" not "what"
- Use imperative mood (e.g., "Add feature" not "Added feature")
- Optional body: Additional context if needed
- Must end with: `Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>`

**HEREDOC Format (REQUIRED):**
```bash
git commit -m "$(cat <<'EOF'
<commit message here>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

**Git Safety Protocol:**
- NEVER use `git commit --amend` unless explicitly requested
- NEVER use `--no-verify` to skip hooks
- NEVER use `--force` or `--force-with-lease` unless explicitly requested
- NEVER push --force to main/master (warn user if requested)
- ALWAYS create NEW commits by default

### 5. Push to Remote

Push the commit to the remote repository:
- Check if branch needs `-u` flag for first push
- Use `git push -u origin <branch-name>` if setting upstream
- Use `git push` if upstream already exists
- Verify push succeeded with `git status`

### 6. Create Pull Request

Create a PR using GitHub CLI:

**PR Format:**
```bash
gh pr create --title "<PR title>" --body "$(cat <<'EOF'
## Summary
- <bullet point 1>
- <bullet point 2>
- <bullet point 3>

## Test plan
- [ ] <test item 1>
- [ ] <test item 2>
- [ ] <test item 3>

## Discord Embed
```json
{
  "title": "<PR title>",
  "url": "<will be filled after creation>",
  "description": "<brief description>",
  "color": 5814783
}
```

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**PR Guidelines:**
- Title should match commit message or summarize all commits
- Summary: 1-3 bullet points explaining the changes
- Test plan: Checklist of items to verify the changes work
- Include Discord embed JSON for easy sharing
- Use HEREDOC format to ensure proper formatting

### 7. Return PR URL

After creating the PR, return the PR URL so the user can access it.

## Important Notes

- Run git status AFTER the commit completes to verify success
- If commit fails due to pre-commit hooks, fix the issue and create a NEW commit
- Do NOT read or explore code beyond git commands
- Do NOT push to remote unless creating the PR
- If there are no changes to commit, do not create an empty commit
- For multiple commits on the branch, analyze ALL commits for PR summary

## Error Handling

If any step fails:
1. Report the error clearly
2. Do NOT proceed to next steps
3. Suggest remediation if possible
4. Wait for user input before retrying
