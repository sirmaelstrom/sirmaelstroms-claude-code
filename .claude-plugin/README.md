# sirmaelstroms-claude-code

Custom .NET/C#/PowerShell-focused Claude Code plugin with specialized commands, agents, and automation hooks.

## Installation

Install directly from GitHub via Claude Code's plugin system:

```bash
# In Claude Code CLI
/plugin marketplace add sirmaelstrom/sirmaelstroms-claude-code
/plugin install sirmaelstroms-claude-code@sirmaelstrom/sirmaelstroms-claude-code
```

Restart Claude Code to load the plugin.

## What's Included

**9 Slash Commands:**
- `/build-test` - .NET build and test with error reporting
- `/new-project` - Interactive .NET project scaffolding
- `/add-package` - NuGet package management
- `/commit-push-pr` - Automated commit, push, and PR creation
- `/code-cleanup` - Code cleanup and refactoring
- `/code-explain` - Code explanation generation
- `/code-optimize` - Performance optimization analysis
- `/docs-generate` - Documentation generation
- `/lint` - Linting and code quality checks

**9 Specialized Agents:**
- `adversarial-reviewer` - Devil's advocate code review
- `code-simplifier` - Complexity reduction
- `verify-app` - Build and test verification
- `dotnet-architect` - Clean Architecture guidance
- `dotnet-performance` - Performance optimization
- `deep-research-agent` - Comprehensive technical research
- `security-engineer` - Security analysis and hardening
- `tech-stack-researcher` - Technology evaluation
- `technical-writer` - Technical documentation

## Tech Stack Focus

- **.NET 8 / C#** - Primary development stack
- **ASP.NET Core** - Web development (Minimal APIs, MVC)
- **PowerShell** - Scripting and automation
- **SQL Server** - Database work
- **Git** - Version control workflows
- **General** - Python, JavaScript/TypeScript, Shell

## Optional: Webhook Notifications

The plugin includes webhook notification hooks for Discord and Slack, but these require manual setup:

1. Clone the repository temporarily to access hook scripts
2. Copy hooks to `~/.claude/hooks/`
3. Configure webhook URLs in systemd user environment
4. Add hooks to `~/.claude/settings.json`

See the [main README](../README.md) for detailed webhook setup instructions.

**Dependencies for webhooks:**
- `jq` - JSON processor
- `python3` - Session tracking

## Quick Start

After installation:

```bash
# Verify installation
/plugin

# Try a command
/build-test path/to/solution.sln

# Agents activate automatically based on context
```

## Full Documentation

- **[Main README](../README.md)** - Complete documentation
- **[QUICKSTART.md](../QUICKSTART.md)** - Quick start guide
- **[ARCHITECTURE.md](../ARCHITECTURE.md)** - Technical architecture
- **[COMMANDS.md](./COMMANDS.md)** - Command reference
- **[AGENTS.md](./AGENTS.md)** - Agent reference

## Author

sirmaelstrom

## License

MIT License - Copyright (c) 2026 sirmaelstrom
