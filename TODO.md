# Sirmaelstroms Claude Code - Tasks

## Active (v1.1 Roadmap)

### PowerShell & SQL Commands
- [ ] Create `/ps-ad-helper` command for Active Directory operations
- [ ] Create `/ps-exchange-helper` command for Exchange management
- [ ] Create `/sql-migrate` command for SQL Server migration assistance
- [ ] Create `/sql-optimize` command for query optimization
- [ ] Create `/sql-docs` command for database documentation generation

### Hook Enhancements
- [ ] Implement PostToolUse hook for automatic code formatting
  - [ ] Support dotnet format
  - [ ] Support prettier (JS/TS)
  - [ ] Support black (Python)
  - [ ] Support shfmt (shell scripts)
- [ ] Create PostBuild hook with Discord status notification
- [ ] Create PostTest hook with test result details
- [ ] Create PreCommit validation hook

## Active (v1.2 Roadmap)

### MCP Integrations
- [ ] Build error log analysis MCP server
- [ ] Add analytics integration MCP server
- [ ] Create `/install-github-action` command for PR review automation

## Ideas / Future

- [ ] Create project-specific slash commands as needed
- [ ] ASCII art/banner agent for console/CLI applications (low priority)
- [ ] Add inline bash to commands for pre-computed context (git status, etc.)
- [ ] Expand agent library based on usage patterns
- [ ] Create agent for code migration (WebForms → Minimal APIs)

## Completed (v1.0)

- [x] Create plugin manifest (`.claude-plugin/plugin.json`)
- [x] Build slash commands library (9 commands)
  - [x] Git: `/commit-push-pr`
  - [x] .NET: `/build-test`, `/new-project`, `/add-package`
  - [x] General: `/code-explain`, `/docs-generate`, `/lint`, `/code-optimize`, `/code-cleanup`
- [x] Build custom agents library (9 agents)
  - [x] Quality: `code-simplifier`, `verify-app`, `adversarial-reviewer`
  - [x] .NET: `dotnet-architect`, `dotnet-performance`
  - [x] General: `tech-stack-researcher`, `deep-research-agent`, `technical-writer`, `security-engineer`
- [x] Register all commands and agents in plugin manifest
- [x] Configure Discord/Slack webhook notifications
- [x] Release v1.0.0
- [x] Publish to GitHub for plugin marketplace
- [x] Add `/sync-tasks` command for task synchronization (2026-01-19)
