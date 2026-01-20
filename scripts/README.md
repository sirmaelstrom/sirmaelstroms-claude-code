# Claude Code Scripts

Utility scripts for Claude Code hooks and automation.

## Notification Scripts

### `claude-notify.sh` (Recommended)

Unified notification script that supports both Discord and Slack webhooks.

**Features:**
- Sends to Discord, Slack, or both simultaneously
- Full lifecycle notifications (SessionStart, Stop, SessionEnd, PermissionRequest)
- Rich formatting with color coding
- Session tracking with duration, operations, and file changes
- Debug logging to `~/.cache/claude_hook_debug.log`

**Setup:**

1. Set webhook URL(s):
   ```bash
   # For Discord
   export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
   echo 'export DISCORD_WEBHOOK_URL="..."' >> ~/.bashrc

   # For Slack
   export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
   echo 'export SLACK_WEBHOOK_URL="..."' >> ~/.bashrc

   # Or both (messages sent to both platforms)
   ```

2. Install to hooks directory:
   ```bash
   cp scripts/claude-notify.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/claude-notify.sh
   ```

3. Configure in `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "~/.claude/hooks/claude-notify.sh SessionStart"
             }
           ]
         }
       ],
       "Stop": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "~/.claude/hooks/claude-notify.sh Stop"
             }
           ]
         }
       ],
       "SessionEnd": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "~/.claude/hooks/claude-notify.sh SessionEnd"
             }
           ]
         }
       ],
       "PermissionRequest": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "~/.claude/hooks/claude-notify.sh PermissionRequest"
             }
           ]
         }
       ]
     }
   }
   ```

**Testing:**

```bash
# Test Discord only
echo '{"source":"startup"}' | DISCORD_WEBHOOK_URL="..." bash ~/.claude/hooks/claude-notify.sh SessionStart

# Test Slack only
echo '{"source":"startup"}' | SLACK_WEBHOOK_URL="..." bash ~/.claude/hooks/claude-notify.sh SessionStart

# Test both
echo '{"source":"startup"}' | \
  DISCORD_WEBHOOK_URL="..." \
  SLACK_WEBHOOK_URL="..." \
  bash ~/.claude/hooks/claude-notify.sh SessionStart
```

Expected output:
- Discord: Rich embed with color, fields, and timestamp
- Slack: Attachment with color bar and formatted fields

**Notification Types:**

- **SessionStart** 🚀 - Green (startup), Blue (resume), Yellow (clear), Orange (compact)
- **Stop** ⏸️ - Blue (idle, no changes), Yellow (idle with pending changes)
- **PermissionRequest** 🔐 - Orange (waiting for user)
- **SessionEnd** 🏁 - Green (normal exit), Red (unexpected exit)

Each includes:
- Project name
- Session duration
- Operations performed
- Files changed
- Last commit

## Task Management Scripts

### `parse-todo-tasks.py`

Parses TODO.md files and counts tasks by section for the `/sync-tasks` command.

**Usage:**
```bash
python3 scripts/parse-todo-tasks.py path/to/TODO.md
```

**Output format:**
```
active|blocked|in_progress|ideas|completed
```

**Example:**
```bash
$ python3 scripts/parse-todo-tasks.py github/my-project/TODO.md
2|0|1|5|12
```

This means:
- 2 active tasks
- 0 blocked tasks
- 1 in progress task
- 5 ideas/future tasks
- 12 completed tasks

**Features:**
- Counts only top-level checkboxes (no nested items)
- Handles code blocks (fenced and indented)
- Supports multiple section variants (e.g., "## Active (v1.1)" counts as Active)
- Case-insensitive section matching

**Used by:** `/sync-tasks` command

## Validation Scripts

### `validate-json.py`

Validates JSON files for syntax errors.

### `validate-yaml.py`

Validates YAML files for syntax errors.

## Debug Logging

All notification scripts log to `~/.cache/claude_hook_debug.log`:

```bash
# Watch hooks in real-time
tail -f ~/.cache/claude_hook_debug.log

# Check recent notifications
tail -30 ~/.cache/claude_hook_debug.log

# Find specific event types
grep "EVENT_TYPE: Stop" ~/.cache/claude_hook_debug.log
```

Log format:
```
=== 2026-01-18T23:41:53Z ===
EVENT_TYPE: SessionStart
HOOK_INPUT: {"source":"startup","cwd":"/home/username/projects"}
EXIT_REASON: unknown
SESSION_SOURCE: unknown
START_TIME: 1768777966
DURATION: 29m 7s
Sending Discord notification
Sending Slack notification
```

## Troubleshooting

**No notifications:**
- Check webhook URL: `echo $DISCORD_WEBHOOK_URL` or `echo $SLACK_WEBHOOK_URL`
- Check script is executable: `ls -la ~/.claude/hooks/claude-notify.sh`
- Check debug log: `tail ~/.cache/claude_hook_debug.log`

**Only Discord or Slack works:**
- Verify both environment variables are set
- Test each individually with explicit env vars

**Wrong event data:**
- Check hook configuration in `~/.claude/settings.json`
- Verify session tracking file: `cat ~/.cache/claude_session_latest.json`

## Security

**Never commit webhook URLs to git:**
- Use environment variables
- Add to `.bashrc` or `.zshrc`
- Keep `.env` files in `.gitignore`

Webhook URLs are secrets - treat them like passwords.
