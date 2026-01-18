# Sirm Claude Toolbox

A custom .NET/C#/PowerShell-focused Claude Code plugin with slash commands, custom agents, and automation hooks.

## Overview

This plugin extends [Claude Code](https://claude.ai/code) with specialized tools for .NET development, PowerShell scripting, SQL Server work, and general software engineering workflows. It includes 9 slash commands, 9 custom agents, and automation hooks for code formatting and Discord notifications.

## Tech Stack Focus

- **.NET 8 / C#** - Primary development stack
- **ASP.NET Core** - Web development (Minimal APIs, MVC)
- **PowerShell** - Scripting and automation
- **SQL Server** - Database work
- **Git** - Version control workflows
- **General** - Python, JavaScript/TypeScript, Shell

## Installation

### Option 1: Manual Installation (Current)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sirmaelstrom/sirm-claude-toolbox.git ~/.claude-plugins/sirm-claude-toolbox
   ```

2. **Copy commands and agents to your home directory:**
   ```bash
   cp -r ~/.claude-plugins/sirm-claude-toolbox/commands ~/.claude/
   cp -r ~/.claude-plugins/sirm-claude-toolbox/agents ~/.claude/
   ```

3. **Copy hook scripts:**
   ```bash
   cp ~/.claude-plugins/sirm-claude-toolbox/.claude-plugin/hooks/* ~/.claude/hooks/
   chmod +x ~/.claude/hooks/*.sh
   ```

4. **Configure permissions** (add to `~/.claude/settings.json` or project `.claude/settings.local.json`):
   ```json
   {
     "permissions": {
       "allow": [
         "Bash(dotnet format:*)",
         "Bash(git add:*)",
         "Bash(git commit:*)",
         "Bash(git push:*)"
       ]
     },
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Edit",
           "hooks": [{"type": "command", "command": "~/.claude/hooks/format-code.sh {{file_path}}"}]
         },
         {
           "matcher": "Write",
           "hooks": [{"type": "command", "command": "~/.claude/hooks/format-code.sh {{file_path}}"}]
         }
       ]
     }
   }
   ```

5. **Optional: Set up Discord notifications:**
   ```bash
   export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
   # Add to ~/.bashrc to persist
   ```

### Option 2: Marketplace Installation (Future)

Once published to a Claude Code marketplace, installation will be simplified to:
```bash
claude plugin install sirm-claude-toolbox
```

## Features

### Slash Commands (9)

**Git Workflow:**
- `/commit-push-pr` - Full git workflow: commit, push, create PR with summary and test plan

**.NET Development:**
- `/build-test` - Build and test .NET solutions with error reporting
- `/new-project` - Scaffold new .NET projects with template selection
- `/add-package` - Search and add NuGet packages interactively

**Code Quality:**
- `/code-explain` - Generate detailed code explanations
- `/docs-generate` - Generate comprehensive documentation
- `/lint` - Run appropriate linters and fix issues
- `/code-optimize` - Performance optimization analysis
- `/code-cleanup` - Code refactoring and cleanup

### Custom Agents (9)

**Quality Agents:**
- `code-simplifier` (yellow) - Reduce complexity after implementation
- `verify-app` (green) - Systematic build and test verification
- `adversarial-reviewer` (red) - Devil's advocate code review

**.NET Agents:**
- `dotnet-architect` (purple) - Clean Architecture and DDD guidance
- `dotnet-performance` (orange) - Performance optimization with measurements

**General Agents:**
- `tech-stack-researcher` (blue) - Technology evaluation
- `deep-research-agent` (cyan) - Comprehensive technical research
- `technical-writer` (teal) - Technical documentation
- `security-engineer` (red) - Security analysis and hardening

### Automation Hooks

**PostToolUse Formatting:**
- Auto-formats C# files with `dotnet format`
- Auto-formats JS/TS/JSON with `prettier`
- Auto-formats Python with `black` or `autopep8`
- Auto-formats Shell scripts with `shfmt`

**Discord Notifications:**
- Rich embeds with color-coded status
- Session context (files modified, test results, commits)
- Automatic notifications when Claude stops

## Usage Examples

```bash
# Build and test a .NET solution
/build-test path/to/solution.sln

# Create a PR with full workflow
/commit-push-pr

# Scaffold a new .NET web API
/new-project

# Explain complex code
/code-explain

# Optimize performance
/code-optimize
```

Agents activate automatically based on context:
- `code-simplifier` triggers after feature implementation
- `verify-app` triggers before PR creation or when testing needed
- `dotnet-architect` triggers during architecture discussions
- `security-engineer` triggers for security-critical code

## Project Structure

```
sirm-claude-toolbox/
├── commands/
│   ├── dotnet/         # .NET-specific commands
│   ├── git/            # Git workflow commands
│   ├── general/        # Framework-agnostic commands
│   ├── powershell/     # PowerShell commands (future)
│   └── sql/            # SQL Server commands (future)
├── agents/
│   ├── dotnet/         # .NET-specific agents
│   ├── quality/        # Code quality agents
│   └── general/        # General-purpose agents
├── .claude-plugin/
│   ├── plugin.json     # Plugin manifest
│   ├── marketplace.json # Marketplace metadata
│   ├── README.md       # Plugin documentation
│   ├── COMMANDS.md     # Command reference
│   └── AGENTS.md       # Agent reference
├── CHANGELOG.md        # Version history
├── LICENSE             # MIT License
└── README.md           # This file
```

## Design Principles

- **Evidence-driven over praise-driven** - Focus on facts and test results
- **Simplicity over complexity** - Avoid over-engineering
- **Framework-agnostic where possible** - General tools work across stacks
- **Measurement-driven optimization** - Profile before optimizing
- **Security-conscious by default** - Zero-trust mindset

## Contributing

This is a personal toolbox, but suggestions and improvements are welcome:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

## Roadmap

**v1.1 - PowerShell & SQL:**
- PowerShell AD/Exchange helpers
- SQL migration and optimization tools
- Database documentation generation

**v1.2 - MCP Integrations:**
- Error log analysis MCP server
- Analytics integration
- GitHub action installation via slash command

**v2.0 - Marketplace:**
- Publish to official Claude Code marketplace
- One-command installation
- Automatic updates

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**sirmaelstrom**

- Personal workspace: `/home/sirm/projects/`
- Tech focus: .NET, C#, PowerShell, SQL Server
- Environment: WSL (Ubuntu) on Windows 11 with JetBrains Rider

## Acknowledgments

- Inspired by [edmunds-claude-code](https://github.com/edmund-io/edmunds-claude-code)
- Built for [Claude Code](https://claude.ai/code) by Anthropic
