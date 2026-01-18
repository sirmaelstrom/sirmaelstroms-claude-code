# sirm-claude-toolbox

Custom .NET/C#/PowerShell-focused Claude Code toolbox with specialized commands, agents, and automation hooks.

## Tech Stack Focus

- **.NET 8** - Primary framework (build, test, run, restore, format)
- **C#** - Primary language
- **ASP.NET** - WebForms (legacy), Minimal APIs, MVC
- **PowerShell** - Scripting and automation
- **SQL Server** - Database development
- **Git** - Version control with pre-approved read/write operations
- **Docker** - Container operations (read-only)

## Installation

### From Marketplace (Future)

```bash
claude plugin install sirm-claude-toolbox
```

### Local Installation

1. Copy the plugin to your Claude Code configuration:
   ```bash
   cp -r /path/to/sirm-claude-toolbox ~/.claude/
   ```

2. Copy the settings template:
   ```bash
   cp ~/.claude/settings.template.json ~/.claude/settings.local.json
   ```

3. Configure Discord webhook (optional):
   ```bash
   export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
   ```
   Add to `~/.bashrc` or `~/.zshrc` to persist across sessions.

## Quick Start

### Slash Commands

Try these commands to see the toolbox in action:

```bash
# Build and test a .NET solution
/build-test path/to/solution.sln

# Create a new .NET project
/new-project

# Add a NuGet package to a project
/add-package Newtonsoft.Json

# Commit, push, and create a pull request
/commit-push-pr

# Generate documentation for code
/docs-generate

# Code cleanup and optimization
/code-cleanup
```

### Auto-Activated Agents

Agents activate automatically based on context:

- **adversarial-reviewer** - Security reviews, architectural changes, production deployments
- **code-simplifier** - Code refactoring, complexity reduction
- **verify-app** - Application verification and testing
- **dotnet-architect** - .NET architecture and design decisions
- **dotnet-performance** - .NET performance optimization
- **deep-research-agent** - Multi-file codebase analysis
- **security-engineer** - Security audits and vulnerability assessments
- **tech-stack-researcher** - Technology evaluation and research
- **technical-writer** - Documentation and technical writing

### Discord Notifications

Stop hook sends rich embeds to Discord when Claude is ready for input:

- Session duration tracking
- Files modified count
- Recent commit messages
- Test results (if available)
- Color-coded status (green/yellow/red)

## Directory Structure

```
~/.claude/
├── settings.template.json    # Pre-approved permissions and hooks
├── settings.local.json        # Your local configuration (git-ignored)
├── commands/                  # Slash commands organized by tech stack
│   ├── dotnet/
│   │   ├── build-test.md      # Build and test .NET solutions
│   │   ├── new-project.md     # Create new .NET projects
│   │   └── add-package.md     # Add NuGet packages
│   ├── git/
│   │   └── commit-push-pr.md  # Git workflow automation
│   ├── general/
│   │   ├── code-cleanup.md    # Code cleanup
│   │   ├── code-explain.md    # Code explanation
│   │   ├── code-optimize.md   # Code optimization
│   │   ├── docs-generate.md   # Documentation generation
│   │   └── lint.md            # Linting
│   ├── powershell/            # PowerShell commands (planned)
│   └── sql/                   # SQL commands (planned)
├── agents/                    # Context-aware agents
│   ├── dotnet/
│   │   ├── dotnet-architect.md      # .NET architecture
│   │   └── dotnet-performance.md    # .NET performance
│   ├── quality/
│   │   ├── adversarial-reviewer.md  # Security/architectural review
│   │   ├── code-simplifier.md       # Code simplification
│   │   └── verify-app.md            # Application verification
│   └── general/
│       ├── deep-research-agent.md   # Codebase research
│       ├── security-engineer.md     # Security audits
│       ├── tech-stack-researcher.md # Tech evaluation
│       └── technical-writer.md      # Documentation
└── scripts/
    └── discord-notify.sh      # Discord webhook integration
```

## Features

### Slash Commands

**Git Workflow**
- `/commit-push-pr` - Automated commit, push, and PR creation

**Dotnet Development**
- `/build-test` - Build and test with error reporting
- `/new-project` - Interactive .NET project scaffolding
- `/add-package` - NuGet package management

**Code Quality**
- `/code-cleanup` - Code cleanup and formatting
- `/code-explain` - Code explanation and documentation
- `/code-optimize` - Performance optimization
- `/docs-generate` - Documentation generation
- `/lint` - Linting and code quality checks

### Custom Agents

**Quality Assurance**
- **adversarial-reviewer** - Devil's advocate analysis, security review, failure mode identification
- **code-simplifier** - Complexity reduction, refactoring suggestions
- **verify-app** - Application verification, testing, quality checks

**Dotnet Specialists**
- **dotnet-architect** - Architecture design, pattern recommendations
- **dotnet-performance** - Performance optimization, profiling, bottleneck analysis

**General Purpose**
- **deep-research-agent** - Multi-file codebase analysis, architectural research
- **security-engineer** - Security audits, vulnerability assessments, threat modeling
- **tech-stack-researcher** - Technology evaluation, comparison, research
- **technical-writer** - Documentation, technical writing, README generation

### Automation Hooks

**PostToolUse Hooks** - Automatic code formatting after Edit/Write:
- **.cs/.csproj/.sln** - `dotnet format` (solution/project scope)
- **.js/.jsx/.ts/.tsx/.json** - `prettier`
- **.py** - `black` or `autopep8`
- **.sh** - `shfmt`

**Stop Hooks** - Discord notifications when Claude is ready:
- Session duration tracking
- Git status (modified files, recent commits)
- Test results (if available)
- Color-coded embeds (green/yellow/red)

## Configuration

### Settings Template

The `settings.template.json` provides:

1. **Pre-approved Permissions**
   - .NET commands (build, test, run, restore, clean, format, tool)
   - Git operations (status, log, diff, branch, add, commit, push)
   - GitHub CLI (gh)
   - Node/npm, Rust/Cargo, Go
   - Docker (read-only)
   - File system operations
   - System info commands

2. **Hook Configuration**
   - Stop hook: Discord notifications
   - PostToolUse hooks: Automatic code formatting

### Discord Webhook Setup

1. Create a Discord webhook in your server:
   - Server Settings → Integrations → Webhooks → New Webhook
   - Copy the webhook URL

2. Set the environment variable:
   ```bash
   export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
   ```

3. Add to shell profile for persistence:
   ```bash
   echo 'export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. Test the integration:
   ```bash
   ~/.claude/scripts/discord-notify.sh
   ```

### Discord Notification Features

- **Rich Embeds** - Formatted notifications with metadata
- **Session Context**
  - Project name (from current directory)
  - Session duration (minutes and seconds)
  - Files modified count (from git status)
  - Recent commit message (last 5 minutes)
  - Test results (if `/tmp/claude_last_test.log` exists)
- **Color Coding**
  - Green (5763719) - No changes or tests passing
  - Yellow (16776960) - Files modified
  - Red (15548997) - Test failures
- **Timestamp** - UTC timestamp for each notification

## Customization

### Adding New Commands

1. Create a markdown file in the appropriate category:
   ```bash
   touch ~/.claude/commands/dotnet/my-command.md
   ```

2. Add frontmatter and instructions:
   ```markdown
   ---
   description: Short description of the command
   argument-hint: [optional-args]
   model: claude-sonnet-4-5-20250929
   allowed-tools: Bash(dotnet:*), Read, Write
   ---

   # My Command

   Command implementation instructions...
   ```

3. Test the command:
   ```bash
   /my-command
   ```

### Adding New Agents

1. Create a markdown file in the appropriate category:
   ```bash
   touch ~/.claude/agents/dotnet/my-agent.md
   ```

2. Define agent behavior:
   ```markdown
   ---
   name: my-agent
   description: Agent description
   model: sonnet
   color: blue
   ---

   # My Agent

   ## Triggers
   - When to activate this agent

   ## Behavioral Mindset
   How the agent should think and approach problems

   ## Focus Areas
   - Key areas of expertise

   ## Key Actions
   1. What the agent should do

   ## Outputs
   - Expected deliverables
   ```

3. Test agent activation based on triggers.

### Adding New Hooks

1. Create a shell script in `~/.claude/hooks/` or `~/.claude/scripts/`:
   ```bash
   touch ~/.claude/hooks/my-hook.sh
   chmod +x ~/.claude/hooks/my-hook.sh
   ```

2. Add hook to `settings.local.json`:
   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Edit",
           "hooks": [
             {
               "type": "command",
               "command": "~/.claude/hooks/my-hook.sh {{file_path}}"
             }
           ]
         }
       ]
     }
   }
   ```

3. Test hook by triggering the matched tool (e.g., Edit).

### Modifying Permissions

Edit `settings.local.json` to add or remove pre-approved commands:

```json
{
  "permissions": {
    "allow": [
      "Bash(your-command:*)",
      "Bash(*:/specific/path/*)"
    ]
  }
}
```

Pattern syntax:
- `Bash(command:*)` - Approve all invocations of `command`
- `Bash(*:/path/*)` - Approve all bash commands in `/path/`
- `WebFetch(domain:example.com)` - Approve fetching from `example.com`

## Version

Current version: 0.1.0

## Author

sirmaelstrom

## Tags

dotnet, csharp, powershell, sql, quality
