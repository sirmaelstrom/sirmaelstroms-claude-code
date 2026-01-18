# Changelog

All notable changes to the Sirm Claude Toolbox will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-18

### Added

**Slash Commands (9):**
- `/commit-push-pr` - Full git workflow with commit, push, and PR creation
- `/build-test` - Build and test .NET solutions with error reporting
- `/new-project` - Scaffold new .NET projects with template selection
- `/add-package` - Search and add NuGet packages interactively
- `/code-explain` - Generate detailed code explanations
- `/docs-generate` - Generate comprehensive documentation
- `/lint` - Run appropriate linters and fix issues
- `/code-optimize` - Performance optimization analysis
- `/code-cleanup` - Code refactoring and cleanup

**Custom Agents (9):**

*Quality Agents:*
- `code-simplifier` - Reduce complexity and remove over-engineering
- `verify-app` - Systematic build and test verification
- `adversarial-reviewer` - Devil's advocate code review

*.NET Agents:*
- `dotnet-architect` - Clean Architecture and DDD guidance
- `dotnet-performance` - Performance optimization with measurement

*General Agents:*
- `tech-stack-researcher` - Technology evaluation and recommendations
- `deep-research-agent` - Comprehensive technical research
- `technical-writer` - Technical documentation creation
- `security-engineer` - Security analysis and hardening

**Automation:**
- PostToolUse hooks for automatic code formatting (C#, JS/TS, Python, Shell)
- Enhanced Discord webhook notifications with rich embeds
- Session context tracking (files modified, test results, commits)
- Color-coded status notifications (green/yellow/red)

**Infrastructure:**
- Tech-stack organized directory structure (dotnet, powershell, sql, git, general, quality)
- Settings template for easy project setup
- Comprehensive documentation (README, COMMANDS, AGENTS)
- Hook scripts for automation (format-code.sh, discord-embed.sh)

### Technical Details

**Tech Stack Focus:**
- .NET 8, C#, ASP.NET Core
- PowerShell scripting
- SQL Server
- Git workflows
- General web development (JS/TS, Python)

**Design Principles:**
- Evidence-driven over praise-driven
- Simplicity over complexity
- Framework-agnostic where possible
- Measurement-driven optimization
- Security-conscious by default

## [Unreleased]

### Planned Features

**PowerShell Commands:**
- Active Directory helpers
- Exchange Online management
- Azure automation scripts

**SQL Commands:**
- Schema migration tools
- Query optimization analysis
- Database documentation generation

**MCP Integrations:**
- Error log analysis
- Analytics integration
- GitHub action installation via slash command

**Enhanced Verification:**
- Background agent verification workflows
- UI testing integration
- Automated PR checks
