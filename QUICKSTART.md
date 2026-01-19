# Quick Start Guide

Get started with sirmaelstroms-claude-code in 2 minutes.

## Installation

### Option 1: GitHub Plugin (Recommended)

```bash
# Install dependencies (optional, only needed for webhook notifications)
sudo apt-get install -y jq python3  # Debian/Ubuntu
# or
brew install jq python3              # macOS

# In Claude Code, add marketplace
/plugin marketplace add sirmaelstrom/sirmaelstroms-claude-code

# Install plugin
/plugin install sirmaelstroms-claude-code@sirmaelstrom/sirmaelstroms-claude-code
```

### Option 2: Development Mode

```bash
# Clone the repository
git clone https://github.com/sirmaelstrom/sirmaelstroms-claude-code.git
cd sirmaelstroms-claude-code

# Install dependencies (optional, only needed for webhook notifications)
sudo apt-get install -y jq python3  # Debian/Ubuntu
# or
brew install jq python3              # macOS

# Run installer (creates symlinks for live editing)
./install-local.sh
```

## Verify Installation

### GitHub Plugin Installation
```bash
# Check plugin status
/plugin

# Verify in Installed tab
# Should show: sirmaelstroms-claude-code
```

### Development Installation
```bash
# Check symlinks (old whole-directory method)
ls -la ~/.claude/commands ~/.claude/agents

# Should show symlinks to repository
```

## First Steps

**1. Restart Claude Code** to load new commands and agents

**2. Try a slash command:**
```
/build-test
```

**3. Available commands:**
- `/commit-push-pr` - Full git workflow
- `/build-test` - .NET build and test
- `/new-project` - Scaffold .NET project
- `/add-package` - Add NuGet package
- `/code-explain` - Explain code structure
- `/docs-generate` - Generate documentation
- `/lint` - Run linters
- `/code-optimize` - Performance optimization
- `/code-cleanup` - Code refactoring

**4. Agents activate automatically:**
- Type "simplify this code" → `code-simplifier` activates
- Type "verify the build" → `verify-app` activates
- Architecture questions → `dotnet-architect` activates

## Webhook Notifications (Optional)

Set up rich session notifications for Discord and/or Slack:

```bash
# Create systemd user environment file (persists across reboots)
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/claude-webhooks.conf << 'EOF'
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_URL
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR_WEBHOOK_URL
EOF

# SECURITY: Set secure file permissions (read-only for owner)
chmod 600 ~/.config/environment.d/claude-webhooks.conf

# Import to current session (makes them available immediately)
systemctl --user import-environment DISCORD_WEBHOOK_URL SLACK_WEBHOOK_URL

# Restart Claude Code for hooks to inherit the new environment
```

**Security Note**: Webhook URLs grant full access to post messages in Discord/Slack channels. Protect these URLs:
- Keep file permissions restrictive (600 - owner read/write only)
- Never commit webhook URLs to git repositories
- Rotate webhook URLs if they are exposed
- Consider using a dedicated notification channel with limited permissions

**Important**: Hooks run in Claude Code's process environment, not your shell environment. Setting variables in `~/.bashrc` or `~/.profile` won't work because Claude Code doesn't source those files. Use systemd user environment as shown above.

**Troubleshooting**:
- If notifications don't work, check the debug log: `tail -50 ~/.cache/claude_hook_debug.log | grep -A 5 "HOOK ENVIRONMENT DEBUG"`
- Verify environment: `systemctl --user show-environment | grep WEBHOOK`
- Ensure jq is installed: `jq --version`

You'll receive notifications for four event types:
- **Session Started** - New Claude Code session begins
- **Waiting** - Claude stops and is ready for your input
- **Session Ended** - Claude Code session closes
- **Awaiting Permission** - Claude needs permission for a tool

Each notification includes:
- Session duration
- Operations performed (edits, reads, etc.)
- Agents used
- Files changed
- Commits made

**Example Discord Notifications:**

![Discord webhook notification examples](docs/Discord-Hook-Examples.jpg)

**Example Slack Notifications:**

![Slack webhook notification examples](docs/Slack-Hook-Examples.jpg)

## Customization

### GitHub Plugin Installation
Plugin updates are managed through Claude Code:
```bash
# Check for updates
/plugin update sirmaelstroms-claude-code

# Auto-update can be enabled per marketplace
```

### Development Installation
Since installation uses symlinks, you can edit files in the repo and changes apply immediately:

```bash
# Edit a command
vim commands/dotnet/build-test.md

# Changes are live immediately (no reinstall needed)
```

## Uninstall

### GitHub Plugin Installation
```bash
# Uninstall via Claude Code
/plugin uninstall sirmaelstroms-claude-code

# Or use UI
/plugin  # Navigate to Installed tab → Remove
```

### Development Installation
```bash
# Remove symlinks
rm -f ~/.claude/commands ~/.claude/agents

# Remove hooks (if you want)
# WARNING: Only remove hooks if no other plugins use them
rm -f ~/.claude/hooks/claude-notify.sh
rm -f ~/.claude/hooks/init-session.sh
```

## Next Steps

- Read [COMMANDS.md](./.claude-plugin/COMMANDS.md) for detailed command reference
- Read [AGENTS.md](./.claude-plugin/AGENTS.md) for agent triggers and behaviors
- Check [README.md](./README.md) for roadmap and contributing
