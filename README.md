# Sirmaelstroms Claude Code

A custom .NET/C#/PowerShell-focused Claude Code plugin collection with slash commands, custom agents, and automation hooks.

## Overview

This plugin extends [Claude Code](https://claude.ai/code) with specialized tools for .NET development, PowerShell scripting, SQL Server work, and general software engineering workflows. It includes 9 slash commands, 9 custom agents, and automation hooks for code formatting and Discord notifications.

## Requirements

- **Claude Code** - CLI tool from Anthropic
- **Operating System** - Linux, macOS, or Windows with WSL2
- **Shell** - bash (required for hook scripts)

**Optional dependencies** (only needed for webhook notifications):
- **jq** - JSON processor for webhook formatting
- **Python 3** - Required for session tracking hooks

## Tech Stack Focus

- **.NET 8 / C#** - Primary development stack
- **ASP.NET Core** - Web development (Minimal APIs, MVC)
- **PowerShell** - Scripting and automation
- **SQL Server** - Database work
- **Git** - Version control workflows
- **General** - Python, JavaScript/TypeScript, Shell

## How It Works

This plugin provides two types of capabilities:

**Commands (Slash Commands / Skills)**
- User-invoked via `/command-name` syntax (e.g., `/build-test`, `/commit-push-pr`)
- Claude invokes internally using the `Skill` tool
- Provide step-by-step workflows for common tasks
- Defined in `commands/` directory as markdown files

**Agents (Specialized Subagents)**
- Auto-activate based on context or explicitly invoked
- Claude invokes using `Task` tool with `subagent_type` parameter
- Provide deep expertise in specific domains (architecture, security, performance)
- Defined in `agents/` directory as markdown files
- Examples: `security-engineer`, `dotnet-architect`, `code-simplifier`

See [ARCHITECTURE.md](ARCHITECTURE.md) for technical details.

## Installation

### GitHub Plugin Installation (Recommended)

Install directly from GitHub via Claude Code's plugin system:

1. **Add marketplace and install plugin:**
   ```bash
   # In Claude Code CLI
   /plugin marketplace add sirmaelstrom/sirmaelstroms-claude-code
   /plugin install sirmaelstroms-claude-code@sirmaelstrom/sirmaelstroms-claude-code
   ```

2. **Restart Claude Code** to load the plugin

3. **Verify installation:**
   ```bash
   /plugin
   # Should show sirmaelstroms-claude-code in installed plugins
   ```

**What's included:**
- ✅ 9 slash commands (`/build-test`, `/commit-push-pr`, `/code-explain`, etc.)
- ✅ 9 specialized agents (dotnet-architect, security-engineer, etc.)
- ✅ Auto-updates via `/plugin update`

**Not included** (optional manual setup):
- ❌ Discord/Slack webhook notifications (see below)

### Optional: Webhook Notifications

Discord/Slack notifications require manual setup since they need system environment variables:

1. **Install dependencies:**
   ```bash
   # Required: jq (JSON processor)
   sudo apt-get install -y jq  # Debian/Ubuntu
   brew install jq              # macOS
   ```

2. **Copy notification hooks:**
   ```bash
   # Clone repo temporarily
   cd /tmp
   git clone https://github.com/sirmaelstrom/sirmaelstroms-claude-code.git

   # Copy hooks to your Claude directory
   cp sirmaelstroms-claude-code/scripts/claude-notify.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/claude-notify.sh
   ```

3. **Configure webhook URLs:**
   ```bash
   # Create systemd user environment file (persists across reboots)
   mkdir -p ~/.config/environment.d
   cat > ~/.config/environment.d/claude-webhooks.conf << 'EOF'
   DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_URL
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR_WEBHOOK_URL
   EOF

   # SECURITY: Set secure file permissions (read-only for owner)
   chmod 600 ~/.config/environment.d/claude-webhooks.conf

   # Import to current session
   systemctl --user import-environment DISCORD_WEBHOOK_URL SLACK_WEBHOOK_URL
   ```

   **Security Note**: Webhook URLs grant full access to post messages in Discord/Slack channels:
   - Keep file permissions restrictive (600 - owner read/write only)
   - Never commit webhook URLs to git repositories
   - Rotate webhook URLs if they are exposed
   - Consider using a dedicated notification channel with limited permissions

4. **Add hooks to settings** - See [QUICKSTART.md](QUICKSTART.md) for `~/.claude/settings.json` configuration

**Important**: Hooks run in Claude Code's process environment, not your shell. Environment variables must be set in systemd user environment, not `~/.bashrc` or `~/.profile`.

### Local Development Installation

For plugin development or customization:

```bash
# Clone and install locally
cd ~/projects
git clone https://github.com/sirmaelstrom/sirmaelstroms-claude-code.git
cd sirmaelstroms-claude-code
./install-local.sh
```

This creates symlinks from `~/.claude/commands` and `~/.claude/agents` to the repository, allowing live editing.

## Quick Start

After installation, restart Claude Code and try these commands:

```bash
# Check installed plugins
/plugin

# Try a .NET command
/build-test path/to/solution.sln

# Create a git commit and PR
/commit-push-pr

# Explain code structure
/code-explain
```

**Agents activate automatically** based on context:
- Mention "simplify" → `code-simplifier` activates
- Mention "security audit" → `security-engineer` activates
- Architecture questions → `dotnet-architect` activates
- Before PR creation → `verify-app` activates

See [QUICKSTART.md](QUICKSTART.md) for webhook setup and detailed usage.

### Additional Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Configuration details and next steps
- **[WSL Setup Guide](docs/WSL-Setup.md)** - Complete WSL2 + Claude Code setup
- **[Learnings & Observations](docs/Learnings.md)** - Development insights and patterns

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

The plugin includes 9 specialized agents that auto-activate based on context or explicit invocation. **Agents can run in parallel** for comprehensive multi-perspective analysis.

**Quality Agents:**
- 🟡 `code-simplifier` - Reduce complexity after implementation
- 🟢 `verify-app` - Systematic build and test verification
- 🔴 `adversarial-reviewer` - Devil's advocate code review

**.NET Agents:**
- 🟣 `dotnet-architect` - Clean Architecture and DDD guidance
- 🟠 `dotnet-performance` - Performance optimization with measurements

**General Agents:**
- 🔵 `tech-stack-researcher` - Technology evaluation
- 🔷 `deep-research-agent` - Comprehensive technical research
- 💚 `technical-writer` - Technical documentation
- 🔴 `security-engineer` - Security analysis and hardening

**Multi-Agent Execution:**

Agents work in parallel when tasks require diverse expertise:

![Multi-agent parallel execution](docs/Multi-SubAgent-Example.jpg)
*Example: Security audit + architecture review + code simplification running simultaneously*

### Automation Hooks

**Unified Notifications (Discord & Slack):**
- Rich embeds with color-coded status
- Session context (files modified, test results, commits)
- Supports both platforms simultaneously or individually
- Four event types: Stop, SessionStart, SessionEnd, PermissionRequest
- Platform toggles via environment variables (`NOTIFY_DISCORD`, `NOTIFY_SLACK`)
- Debug logging for permission pattern analysis

**Example Notifications:**

Discord notifications show rich embeds with session context:

![Discord webhook notification examples](docs/Discord-Hook-Examples.jpg)

Slack notifications provide the same information in Slack's format:

![Slack webhook notification examples](docs/Slack-Hook-Examples.jpg)

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
sirmaelstroms-claude-code/
├── commands/
│   ├── dotnet/         # .NET-specific commands
│   ├── git/            # Git workflow commands
│   └── general/        # Framework-agnostic commands
├── agents/
│   ├── dotnet/         # .NET-specific agents
│   ├── quality/        # Code quality agents
│   └── general/        # General-purpose agents
├── docs/
│   ├── WSL-Setup.md    # WSL2 + Claude Code setup guide
│   └── Learnings.md    # Personal observations and insights
├── .claude/
│   └── hooks/          # Hook scripts (manual setup for GitHub installs)
├── .claude-plugin/
│   ├── plugin.json     # Plugin manifest
│   └── marketplace.json # Marketplace metadata
├── scripts/
│   ├── claude-notify.sh # Unified Discord/Slack notification hook
│   ├── validate-yaml.py # Command/agent YAML validation
│   └── validate-json.py # Plugin metadata validation
├── validation-reports/  # Validation results (JSON)
├── ARCHITECTURE.md     # Technical architecture details
├── QUICKSTART.md       # Quick start guide
└── README.md           # This file
```

## Design Principles

- **Evidence-driven over praise-driven** - Focus on facts and test results
- **Simplicity over complexity** - Avoid over-engineering
- **Framework-agnostic where possible** - General tools work across stacks
- **Measurement-driven optimization** - Profile before optimizing
- **Security-conscious by default** - Zero-trust mindset

## Contributing

This is a personal plugin collection, but suggestions and improvements are welcome:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

## Roadmap

**v1.1 - PowerShell & SQL:**
- PowerShell AD/Exchange helper commands
- SQL Server migration and optimization tools
- Database documentation generation

**v1.2 - MCP Integrations:**
- Error log analysis MCP server
- Analytics integration
- GitHub action installation via slash command

**v1.3 - Enhanced Hooks:**
- PostToolUse automatic code formatting (dotnet format, prettier, black, shfmt)
- PostBuild hook with Discord status
- PostTest hook with test details
- PreCommit validation hook

## License

MIT License - Copyright (c) 2026 sirmaelstrom

## Author

Created by **sirmaelstrom**.

## Acknowledgments

- Inspired by [edmunds-claude-code](https://github.com/edmund-io/edmunds-claude-code)
- Development workflow powered by [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent
- Built for [Claude Code](https://claude.ai/code) by Anthropic
