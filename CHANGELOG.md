# Changelog

All notable changes to sirmaelstroms-claude-code will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-19

Initial public release.

### Added

**Commands (9):**
- `/commit-push-pr` - Full git workflow with PR creation
- `/build-test` - .NET solution build and test
- `/new-project` - .NET project scaffolding
- `/add-package` - NuGet package search and installation
- `/code-explain` - Code explanation generation
- `/docs-generate` - Documentation generation
- `/lint` - Linter execution and fixes
- `/code-optimize` - Performance optimization analysis
- `/code-cleanup` - Code refactoring and cleanup

**Agents (9):**
- `code-simplifier` - Complexity reduction
- `verify-app` - Build and test verification
- `adversarial-reviewer` - Devil's advocate code review
- `dotnet-architect` - Clean Architecture guidance
- `dotnet-performance` - Performance optimization
- `tech-stack-researcher` - Technology evaluation
- `deep-research-agent` - Comprehensive research
- `technical-writer` - Technical documentation
- `security-engineer` - Security analysis

**Hooks:**
- Unified notification system (Discord + Slack support)
- Four event types: Stop, SessionStart, SessionEnd, PermissionRequest
- Session tracking with per-project directories
- Automatic cleanup of old sessions (30-day default)

**Documentation:**
- Complete WSL2 setup guide
- Architecture documentation with multi-agent examples
- Quickstart guide
- Installation validation guide

### Security
- JSON command injection prevention in webhook notifications using `jq`
- Python command injection prevention in session tracker
- Git output sanitization with null-terminated output
- Input validation with allowlists for operation types and agent names

### Dependencies
- **jq** (JSON processor) - Required for webhook notifications
- **Python 3** - Required for session tracking hooks
- **bash** - Required for hook scripts

### Known Limitations
- Session tracking operations counters and agents list remain at 0/empty
  - Claude Code provides only 4 hook events (no per-tool hooks)
  - Duration, project name, files modified, and last commit tracked via git
  - Future: When Claude Code adds per-tool hooks, full tracking will activate

[1.0.0]: https://github.com/sirmaelstrom/sirmaelstroms-claude-code/releases/tag/v1.0.0
