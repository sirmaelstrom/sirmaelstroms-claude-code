# Toolbox Restructure and Validation Design

**Date:** 2026-01-18
**Status:** Approved
**Goal:** Transform scattered, potentially broken plugin into clean, validated, public-ready structure

## Problem Statement

Current state has multiple issues:
- Files duplicated across 3 locations (~/.claude/, /projects/.claude/, git repo)
- Potential YAML syntax errors preventing commands from loading
- Copy-based installation creates divergence from source
- Doesn't match edmunds' clean organizational pattern
- Discord hook works but could provide richer session context
- Repository name doesn't match author branding

## Design Principles

- **Single source of truth:** Git repo is authoritative
- **Symlink installation:** Changes in repo apply immediately
- **Global tools only:** No project-specific installation logic
- **Validation first:** Fix syntax before restructuring
- **Parallel execution:** Use multiple agents for efficiency
- **Simple and focused:** Remove unnecessary files (CHANGELOG, LICENSE)

## Target Repository Structure

```
sirmaelstroms-claude-code/
├── .claude/
│   ├── commands/
│   │   ├── dotnet/        # .NET commands
│   │   ├── git/           # Git workflow
│   │   └── general/       # Framework-agnostic
│   ├── agents/
│   │   ├── dotnet/        # .NET agents
│   │   ├── quality/       # Code quality
│   │   └── general/       # General purpose
│   └── hooks/             # Automation scripts
│       ├── format-code.sh
│       ├── discord-embed.sh
│       └── discord-notify.sh
├── .claude-plugin/
│   ├── plugin.json        # Plugin manifest
│   ├── marketplace.json   # Marketplace metadata
│   ├── README.md          # Plugin documentation
│   ├── COMMANDS.md        # Command reference
│   └── AGENTS.md          # Agent reference
├── install.sh             # Symlink-based installer
├── QUICKSTART.md          # Quick start guide
└── README.md              # GitHub README with roadmap
```

## Installation Model

**Symlink-based global installation:**
- `~/.claude/commands` → symlink to repo `.claude/commands`
- `~/.claude/agents` → symlink to repo `.claude/agents`
- `~/.claude/hooks` → copy (scripts need to be executable, may be customized)

**Benefits:**
- Edit in repo, changes apply immediately
- No divergence between source and installation
- Git tracks all changes
- Simple uninstall (remove symlinks)

## Implementation Plan

### Phase 1: Validation (Parallel)

**Agent 1: Command Validation**
- Validate YAML frontmatter in all command files
- Check required fields: description, model
- Verify paths in plugin.json match actual files
- Report any syntax errors

**Agent 2: Agent Validation**
- Validate YAML frontmatter in all agent files
- Check required fields: name, description, model, color
- Verify paths in plugin.json match actual files
- Report any syntax errors

**Agent 3: JSON Validation**
- Validate plugin.json schema
- Validate marketplace.json schema
- Check all path references exist
- Ensure version consistency

### Phase 2: Fix Errors (Parallel)

**Agent 1: YAML/JSON Fixes**
- Correct any syntax errors found in Phase 1
- Ensure consistent formatting
- Update any incorrect path references

**Agent 2: Repository Restructure**
- Move hooks from `.claude-plugin/hooks/` to `.claude/hooks/`
- Update plugin.json paths
- Remove CHANGELOG.md and LICENSE
- Create QUICKSTART.md template

**Agent 3: Install Script Rewrite**
- Rewrite install.sh for symlink-based installation
- Add validation checks (git repo location, existing symlinks)
- Add uninstall functionality
- Handle existing installations gracefully

### Phase 3: Discord Hook Enhancement (Parallel)

**Agent 1: Session State Tracking**
- Create session state tracking mechanism
- Use `/tmp/claude_session_$PID.json` for state
- Track: duration, tool usage, agent activations, test results, commits
- Graceful degradation if tracking fails

**Agent 2: Enhanced Discord Notification**
- Update discord-notify.sh to read session state
- Generate rich embed with all available context
- Color-code by session outcome (green=success, yellow=changes, red=errors)
- Include: duration, operations, agents used, test results, commits

### Phase 4: Cleanup

**Sequential execution:**
- Remove `/projects/.claude/` directory (no longer needed)
- Clear `~/.claude/commands/` and `~/.claude/agents/`
- Backup `~/.claude/hooks/` (has customizations)
- Remove `~/.claude-plugin/` (will reinstall fresh)

### Phase 5: Fresh Installation & Testing

**Sequential execution:**
- Run new install.sh from git repo
- Verify symlinks created correctly
- Test command: `/build-test`
- Test agent activation
- Trigger Discord notification
- Verify rich context in embed

### Phase 6: Repository Rename & Documentation

**Sequential execution:**
- Rename GitHub repo: `sirm-claude-toolbox` → `sirmaelstroms-claude-code`
- Update plugin.json name field
- Update all documentation references
- Create QUICKSTART.md with:
  - One-command installation
  - First steps
  - Testing the installation
  - Available commands overview
- Update README.md with future work roadmap
- Commit and push all changes

## Discord Hook Enhancement Details

### Session State Schema

```json
{
  "start_time": 1234567890,
  "end_time": 1234567900,
  "project": "sirmaelstroms-claude-code",
  "operations": {
    "read": 8,
    "edit": 15,
    "write": 3,
    "bash": 12
  },
  "agents": ["code-simplifier", "verify-app"],
  "tests": {
    "passed": 45,
    "failed": 0,
    "total": 45
  },
  "builds": {
    "status": "success",
    "errors": 0,
    "warnings": 2
  },
  "commits": [
    {
      "hash": "abc123f",
      "message": "Fix validation errors"
    }
  ]
}
```

### Enhanced Embed Format

```json
{
  "embeds": [{
    "title": "🤖 Claude Code Session Complete",
    "description": "Project: **sirmaelstroms-claude-code**",
    "color": 5763719,
    "fields": [
      {"name": "⏱️ Duration", "value": "12m 34s", "inline": true},
      {"name": "🔧 Operations", "value": "15 edits, 8 reads", "inline": true},
      {"name": "🤖 Agents", "value": "code-simplifier, verify-app", "inline": false},
      {"name": "✅ Tests", "value": "45 passed, 0 failed", "inline": true},
      {"name": "🏗️ Build", "value": "✓ Success (2 warnings)", "inline": true},
      {"name": "📝 Commits", "value": "`abc123f` Fix validation", "inline": false}
    ],
    "timestamp": "2026-01-18T07:30:00Z",
    "footer": {"text": "Ready for next task"}
  }]
}
```

## Success Criteria

- [ ] All YAML/JSON files validated and error-free
- [ ] Repository matches edmunds' organizational pattern
- [ ] Install script uses symlinks (not copies)
- [ ] Commands load correctly in Claude Code
- [ ] Agents activate based on triggers
- [ ] Discord notifications include rich session context
- [ ] Repository renamed to sirmaelstroms-claude-code
- [ ] QUICKSTART.md created with clear instructions
- [ ] No duplicate installations (single source of truth)
- [ ] All changes committed to git

## Future Enhancements

These will be tracked in README.md roadmap:
- PowerShell AD/Exchange helper commands
- SQL Server migration and optimization tools
- MCP server integrations (error logs, analytics)
- Marketplace publication for one-command installation
- Project-specific tooling package (separate from this)
