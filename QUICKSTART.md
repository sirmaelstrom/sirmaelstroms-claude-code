# Quick Start Guide

Get started with sirmaelstroms-claude-code in 2 minutes.

## Installation

```bash
# Clone the repository
git clone https://github.com/sirmaelstrom/sirmaelstroms-claude-code.git
cd sirmaelstroms-claude-code

# Run installer (creates symlinks to ~/.claude/)
./install.sh
```

## Verify Installation

```bash
# Check symlinks
ls -la ~/.claude/ | grep -E "(commands|agents)"

# Should show:
# commands -> /path/to/sirmaelstroms-claude-code/.claude/commands
# agents -> /path/to/sirmaelstroms-claude-code/.claude/agents
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

## Discord Notifications (Optional)

Set up rich session notifications:

```bash
# Set webhook URL
export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK"

# Add to ~/.bashrc to persist
echo 'export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK"' >> ~/.bashrc
```

When you stop Claude Code, you'll get notifications with:
- Session duration
- Operations performed
- Agents used
- Files changed
- Commits made

## Customization

Since installation uses symlinks, you can edit files in the repo and changes apply immediately:

```bash
# Edit a command
vim .claude/commands/dotnet/build-test.md

# Changes are live immediately (no reinstall needed)
```

## Uninstall

```bash
# Remove symlinks
rm ~/.claude/commands ~/.claude/agents

# Remove hooks (if you want)
rm -rf ~/.claude/hooks

# Remove plugin metadata
rm -rf ~/.claude-plugin
```

## Next Steps

- Read [COMMANDS.md](./.claude-plugin/COMMANDS.md) for detailed command reference
- Read [AGENTS.md](./.claude-plugin/AGENTS.md) for agent triggers and behaviors
- Check [README.md](./README.md) for roadmap and contributing
