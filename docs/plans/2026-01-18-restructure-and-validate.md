# Toolbox Restructure and Validation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform scattered, potentially broken plugin into clean, validated, public-ready structure matching edmunds' organizational pattern with enhanced Discord notifications.

**Architecture:** Git repo as single source of truth, symlink-based global installation, parallel validation and fixing via subagents, enhanced session context tracking for Discord webhooks.

**Tech Stack:** Bash, YAML, JSON, Python (for validation), git worktrees

---

## Phase 1: Validation (Parallel Agents)

### Task 1A: Validate Command YAML Files

**Files:**
- Read: `commands/dotnet/*.md`, `commands/git/*.md`, `commands/general/*.md`
- Create: `validation-reports/commands-validation.json`

**Step 1: Create validation script**

Create: `scripts/validate-yaml.py`

```python
#!/usr/bin/env python3
import sys
import yaml
import json
from pathlib import Path

def validate_command_yaml(file_path):
    """Validate YAML frontmatter in command file."""
    errors = []

    with open(file_path, 'r') as f:
        content = f.read()

    # Check for YAML frontmatter
    if not content.startswith('---'):
        errors.append(f"Missing YAML frontmatter")
        return errors

    # Extract frontmatter
    parts = content.split('---', 2)
    if len(parts) < 3:
        errors.append(f"Invalid YAML frontmatter structure")
        return errors

    # Parse YAML
    try:
        frontmatter = yaml.safe_load(parts[1])
    except yaml.YAMLError as e:
        errors.append(f"YAML parse error: {e}")
        return errors

    # Validate required fields
    required_fields = ['description']
    for field in required_fields:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    # Validate optional fields
    if 'model' in frontmatter:
        valid_models = ['claude-sonnet-4-5-20250929', 'claude-sonnet-4-5', 'sonnet']
        if frontmatter['model'] not in valid_models:
            errors.append(f"Invalid model: {frontmatter['model']}")

    return errors

def main():
    commands_dir = Path('commands')
    results = {}

    for md_file in commands_dir.rglob('*.md'):
        errors = validate_command_yaml(md_file)
        results[str(md_file)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }

    # Write results
    Path('validation-reports').mkdir(exist_ok=True)
    with open('validation-reports/commands-validation.json', 'w') as f:
        json.dump(results, f, indent=2)

    # Print summary
    total = len(results)
    valid = sum(1 for r in results.values() if r['valid'])
    print(f"Commands validated: {valid}/{total} passed")

    if valid < total:
        print("\nErrors found:")
        for file, result in results.items():
            if not result['valid']:
                print(f"\n{file}:")
                for error in result['errors']:
                    print(f"  - {error}")
        sys.exit(1)

if __name__ == '__main__':
    main()
```

**Step 2: Make script executable**

Run: `chmod +x scripts/validate-yaml.py`

**Step 3: Run validation**

Run: `python3 scripts/validate-yaml.py`
Expected: Report of all command files with any YAML errors

**Step 4: Commit validation script**

```bash
git add scripts/validate-yaml.py validation-reports/
git commit -m "Add command YAML validation script

- Validates frontmatter structure
- Checks required fields
- Reports errors per file

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 1B: Validate Agent YAML Files

**Files:**
- Read: `agents/dotnet/*.md`, `agents/quality/*.md`, `agents/general/*.md`
- Create: `validation-reports/agents-validation.json`
- Modify: `scripts/validate-yaml.py`

**Step 1: Add agent validation function**

Add to `scripts/validate-yaml.py`:

```python
def validate_agent_yaml(file_path):
    """Validate YAML frontmatter in agent file."""
    errors = []

    with open(file_path, 'r') as f:
        content = f.read()

    # Check for YAML frontmatter
    if not content.startswith('---'):
        errors.append(f"Missing YAML frontmatter")
        return errors

    # Extract frontmatter
    parts = content.split('---', 2)
    if len(parts) < 3:
        errors.append(f"Invalid YAML frontmatter structure")
        return errors

    # Parse YAML
    try:
        frontmatter = yaml.safe_load(parts[1])
    except yaml.YAMLError as e:
        errors.append(f"YAML parse error: {e}")
        return errors

    # Validate required fields
    required_fields = ['name', 'description', 'model']
    for field in required_fields:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    # Validate color field
    if 'color' in frontmatter:
        valid_colors = ['red', 'blue', 'green', 'yellow', 'orange', 'purple', 'cyan', 'teal', 'pink']
        if frontmatter['color'] not in valid_colors:
            errors.append(f"Invalid color: {frontmatter['color']}")

    return errors
```

**Step 2: Add agent validation to main**

Modify `main()` in `scripts/validate-yaml.py`:

```python
def main():
    # Validate commands
    commands_dir = Path('commands')
    command_results = {}

    for md_file in commands_dir.rglob('*.md'):
        errors = validate_command_yaml(md_file)
        command_results[str(md_file)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }

    # Validate agents
    agents_dir = Path('agents')
    agent_results = {}

    for md_file in agents_dir.rglob('*.md'):
        errors = validate_agent_yaml(md_file)
        agent_results[str(md_file)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }

    # Write results
    Path('validation-reports').mkdir(exist_ok=True)
    with open('validation-reports/commands-validation.json', 'w') as f:
        json.dump(command_results, f, indent=2)
    with open('validation-reports/agents-validation.json', 'w') as f:
        json.dump(agent_results, f, indent=2)

    # Print summary
    total_commands = len(command_results)
    valid_commands = sum(1 for r in command_results.values() if r['valid'])
    total_agents = len(agent_results)
    valid_agents = sum(1 for r in agent_results.values() if r['valid'])

    print(f"Commands validated: {valid_commands}/{total_commands} passed")
    print(f"Agents validated: {valid_agents}/{total_agents} passed")

    # Print errors
    all_valid = (valid_commands == total_commands and valid_agents == total_agents)
    if not all_valid:
        print("\nErrors found:")
        for file, result in {**command_results, **agent_results}.items():
            if not result['valid']:
                print(f"\n{file}:")
                for error in result['errors']:
                    print(f"  - {error}")
        sys.exit(1)

if __name__ == '__main__':
    main()
```

**Step 3: Run validation**

Run: `python3 scripts/validate-yaml.py`
Expected: Report showing any agent YAML errors

**Step 4: Commit agent validation**

```bash
git add scripts/validate-yaml.py validation-reports/
git commit -m "Add agent YAML validation

- Validates name, description, model fields
- Checks color values
- Combined reporting with commands

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 1C: Validate JSON Files

**Files:**
- Read: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`
- Create: `validation-reports/json-validation.json`
- Create: `scripts/validate-json.py`

**Step 1: Create JSON validation script**

Create: `scripts/validate-json.py`

```python
#!/usr/bin/env python3
import sys
import json
from pathlib import Path

def validate_plugin_json(file_path):
    """Validate plugin.json structure."""
    errors = []

    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        errors.append(f"JSON parse error: {e}")
        return errors

    # Required fields
    required_fields = ['name', 'version', 'description', 'author', 'commands', 'agents']
    for field in required_fields:
        if field not in data:
            errors.append(f"Missing required field: {field}")

    # Validate commands
    if 'commands' in data:
        for i, cmd in enumerate(data['commands']):
            if 'name' not in cmd:
                errors.append(f"Command {i}: missing name")
            if 'path' not in cmd:
                errors.append(f"Command {i}: missing path")
            elif not Path(cmd['path']).exists():
                errors.append(f"Command {i}: path does not exist: {cmd['path']}")
            if 'description' not in cmd:
                errors.append(f"Command {i}: missing description")

    # Validate agents
    if 'agents' in data:
        for i, agent in enumerate(data['agents']):
            if 'name' not in agent:
                errors.append(f"Agent {i}: missing name")
            if 'path' not in agent:
                errors.append(f"Agent {i}: missing path")
            elif not Path(agent['path']).exists():
                errors.append(f"Agent {i}: path does not exist: {agent['path']}")
            if 'description' not in agent:
                errors.append(f"Agent {i}: missing description")

    return errors

def validate_marketplace_json(file_path):
    """Validate marketplace.json structure."""
    errors = []

    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        errors.append(f"JSON parse error: {e}")
        return errors

    # Required fields
    required_fields = ['marketplaceName', 'plugins']
    for field in required_fields:
        if field not in data:
            errors.append(f"Missing required field: {field}")

    return errors

def main():
    results = {}

    # Validate plugin.json
    plugin_json = Path('.claude-plugin/plugin.json')
    if plugin_json.exists():
        errors = validate_plugin_json(plugin_json)
        results[str(plugin_json)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }
    else:
        results[str(plugin_json)] = {
            'valid': False,
            'errors': ['File does not exist']
        }

    # Validate marketplace.json
    marketplace_json = Path('.claude-plugin/marketplace.json')
    if marketplace_json.exists():
        errors = validate_marketplace_json(marketplace_json)
        results[str(marketplace_json)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }
    else:
        results[str(marketplace_json)] = {
            'valid': False,
            'errors': ['File does not exist']
        }

    # Write results
    Path('validation-reports').mkdir(exist_ok=True)
    with open('validation-reports/json-validation.json', 'w') as f:
        json.dump(results, f, indent=2)

    # Print summary
    total = len(results)
    valid = sum(1 for r in results.values() if r['valid'])
    print(f"JSON files validated: {valid}/{total} passed")

    if valid < total:
        print("\nErrors found:")
        for file, result in results.items():
            if not result['valid']:
                print(f"\n{file}:")
                for error in result['errors']:
                    print(f"  - {error}")
        sys.exit(1)

if __name__ == '__main__':
    main()
```

**Step 2: Make script executable and run**

Run: `chmod +x scripts/validate-json.py && python3 scripts/validate-json.py`
Expected: Report of JSON validation errors

**Step 3: Commit JSON validation**

```bash
git add scripts/validate-json.py validation-reports/
git commit -m "Add JSON validation script

- Validates plugin.json schema
- Validates marketplace.json schema
- Checks file path references

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Phase 2: Fix Errors

### Task 2A: Fix YAML/JSON Errors

**Files:**
- Modify: All files with errors from validation reports

**Step 1: Review validation reports**

Run: `cat validation-reports/*.json | python3 -m json.tool`
Expected: See all validation errors

**Step 2: Fix each error systematically**

For each error in reports:
- Open the file
- Fix the specific error
- Re-run validation: `python3 scripts/validate-yaml.py && python3 scripts/validate-json.py`

**Step 3: Commit fixes**

```bash
git add commands/ agents/ .claude-plugin/
git commit -m "Fix YAML and JSON validation errors

- Corrected frontmatter syntax
- Added missing required fields
- Fixed path references

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 2B: Restructure Hooks Directory

**Files:**
- Move: `.claude-plugin/hooks/*` → `.claude/hooks/`
- Modify: `.claude-plugin/plugin.json`

**Step 1: Check current hook location**

Run: `find .claude-plugin/ -name "*.sh" 2>/dev/null`
Expected: List of hook scripts if any exist

**Step 2: Move hooks to .claude/hooks/**

Run:
```bash
mkdir -p .claude/hooks
if [ -d .claude-plugin/hooks ]; then
  mv .claude-plugin/hooks/* .claude/hooks/
  rmdir .claude-plugin/hooks
fi
```

**Step 3: Ensure hooks are executable**

Run: `chmod +x .claude/hooks/*.sh`

**Step 4: Update plugin.json if it references hooks**

Check `.claude-plugin/plugin.json` for any hook path references and update them to point to `.claude/hooks/`

**Step 5: Commit restructure**

```bash
git add .claude/hooks/ .claude-plugin/
git commit -m "Restructure: move hooks to .claude/hooks/

Matches edmunds-claude-code pattern
- Hooks now in .claude/hooks/
- Scripts remain executable

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 2C: Rewrite Install Script for Symlinks

**Files:**
- Modify: `install.sh`

**Step 1: Backup current install.sh**

Run: `cp install.sh install.sh.backup`

**Step 2: Write new symlink-based installer**

Modify: `install.sh`

```bash
#!/bin/bash
set -e

echo "Installing sirmaelstroms-claude-code..."

# Get absolute path to repo
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure we're in a git repo
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Error: Must run from git repository root"
    exit 1
fi

# Check if already installed
if [ -L ~/.claude/commands ] || [ -L ~/.claude/agents ]; then
    echo "Existing installation detected."
    read -p "Remove and reinstall? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f ~/.claude/commands ~/.claude/agents
        echo "Removed existing symlinks"
    else
        echo "Installation cancelled"
        exit 0
    fi
fi

# Create .claude directory if needed
mkdir -p ~/.claude

# Symlink commands and agents
echo "Creating symlinks..."
ln -sf "$REPO_DIR/.claude/commands" ~/.claude/commands
ln -sf "$REPO_DIR/.claude/agents" ~/.claude/agents

# Copy hooks (scripts need to be executable and may be customized)
echo "Installing hooks..."
mkdir -p ~/.claude/hooks
cp -r "$REPO_DIR/.claude/hooks/"* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# Copy plugin metadata
echo "Installing plugin metadata..."
mkdir -p ~/.claude-plugin
cp "$REPO_DIR/.claude-plugin/plugin.json" ~/.claude-plugin/
cp "$REPO_DIR/.claude-plugin/marketplace.json" ~/.claude-plugin/ 2>/dev/null || true

echo ""
echo "✓ Installation complete!"
echo ""
echo "Installed:"
echo "  Commands: ~/.claude/commands -> $REPO_DIR/.claude/commands"
echo "  Agents: ~/.claude/agents -> $REPO_DIR/.claude/agents"
echo "  Hooks: ~/.claude/hooks/ (copied)"
echo ""
echo "See QUICKSTART.md for next steps"
```

**Step 3: Test install script syntax**

Run: `bash -n install.sh`
Expected: No syntax errors

**Step 4: Commit new installer**

```bash
git add install.sh
git commit -m "Rewrite installer for symlink-based installation

- Symlinks commands and agents (single source of truth)
- Copies hooks (executable, customizable)
- Checks for existing installation
- Provides clear feedback

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Phase 3: Discord Hook Enhancement

### Task 3A: Implement Session State Tracking

**Files:**
- Create: `.claude/hooks/session-tracker.sh`
- Modify: `.claude/hooks/discord-notify.sh`

**Step 1: Create session tracking helper**

Create: `.claude/hooks/session-tracker.sh`

```bash
#!/bin/bash
# Session state tracking for Discord notifications

SESSION_FILE="/tmp/claude_session_$$.json"

# Initialize session
init_session() {
    cat > "$SESSION_FILE" <<EOF
{
  "start_time": $(date +%s),
  "project": "$(basename "$(pwd)")",
  "operations": {
    "read": 0,
    "edit": 0,
    "write": 0,
    "bash": 0
  },
  "agents": [],
  "tests": null,
  "builds": null,
  "commits": []
}
EOF
}

# Track operation
track_operation() {
    local op_type="$1"

    if [ ! -f "$SESSION_FILE" ]; then
        init_session
    fi

    # Increment operation counter
    python3 -c "
import json, sys
with open('$SESSION_FILE', 'r') as f:
    data = json.load(f)
data['operations']['$op_type'] = data['operations'].get('$op_type', 0) + 1
with open('$SESSION_FILE', 'w') as f:
    json.dump(data, f)
"
}

# Track agent usage
track_agent() {
    local agent_name="$1"

    if [ ! -f "$SESSION_FILE" ]; then
        init_session
    fi

    python3 -c "
import json
with open('$SESSION_FILE', 'r') as f:
    data = json.load(f)
if '$agent_name' not in data['agents']:
    data['agents'].append('$agent_name')
with open('$SESSION_FILE', 'w') as f:
    json.dump(data, f)
"
}

# Export functions
export -f init_session track_operation track_agent
```

**Step 2: Make executable**

Run: `chmod +x .claude/hooks/session-tracker.sh`

**Step 3: Commit session tracker**

```bash
git add .claude/hooks/session-tracker.sh
git commit -m "Add session state tracking for Discord hooks

- Track operations (read, edit, write, bash)
- Track agent activations
- JSON-based session state

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 3B: Enhance Discord Notification

**Files:**
- Modify: `.claude/hooks/discord-notify.sh`

**Step 1: Read current discord-notify.sh**

Run: `cat .claude/hooks/discord-notify.sh | head -50`
Expected: See current implementation

**Step 2: Enhance with session context**

Modify `.claude/hooks/discord-notify.sh` to add session state reading:

```bash
#!/bin/bash

# Session state file
SESSION_FILE="/tmp/claude_session_$$.json"

# Read session state if available
if [ -f "$SESSION_FILE" ]; then
    SESSION_DATA=$(cat "$SESSION_FILE")
    START_TIME=$(echo "$SESSION_DATA" | python3 -c "import json, sys; print(json.load(sys.stdin).get('start_time', 0))")
    OPERATIONS=$(echo "$SESSION_DATA" | python3 -c "import json, sys; ops=json.load(sys.stdin)['operations']; print(f\"{ops['edit']} edits, {ops['read']} reads\")")
    AGENTS=$(echo "$SESSION_DATA" | python3 -c "import json, sys; print(', '.join(json.load(sys.stdin).get('agents', [])))")

    # Calculate duration
    if [ "$START_TIME" -gt 0 ]; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        DURATION_STR="$((DURATION / 60))m $((DURATION % 60))s"
    else
        DURATION_STR="Unknown"
    fi
else
    OPERATIONS="No data"
    AGENTS="None"
    DURATION_STR="Unknown"
fi

# Get project context
PROJECT=$(basename "$(pwd)")
FILES_CHANGED=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
LAST_COMMIT=$(git log -1 --oneline 2>/dev/null | cut -c 1-50)

# Determine color based on state
if [ "$FILES_CHANGED" -eq 0 ]; then
    COLOR=5763719  # Green - no changes
else
    COLOR=16776960  # Yellow - changes pending
fi

# Build embed
WEBHOOK_URL="${DISCORD_WEBHOOK_URL}"

curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "embeds": [{
    "title": "🤖 Claude Code Session Complete",
    "description": "Project: **$PROJECT**",
    "color": $COLOR,
    "fields": [
      {"name": "⏱️ Duration", "value": "$DURATION_STR", "inline": true},
      {"name": "🔧 Operations", "value": "$OPERATIONS", "inline": true},
      {"name": "📁 Files Modified", "value": "$FILES_CHANGED file(s)", "inline": true},
      {"name": "🤖 Agents", "value": "${AGENTS:-None}", "inline": false},
      {"name": "📝 Last Commit", "value": "${LAST_COMMIT:-No commits}", "inline": false}
    ],
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "footer": {"text": "Ready for next task"}
  }]
}
EOF

# Clean up session file
rm -f "$SESSION_FILE"
```

**Step 3: Test Discord notification format**

Run: `bash -n .claude/hooks/discord-notify.sh`
Expected: No syntax errors

**Step 4: Commit enhanced notification**

```bash
git add .claude/hooks/discord-notify.sh
git commit -m "Enhance Discord notifications with session context

- Session duration tracking
- Operation counts (edits, reads)
- Agent activations
- Files changed count
- Rich embed formatting

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Phase 4: Cleanup Duplicates

### Task 4A: Remove Project-Level .claude Directory

**Files:**
- Delete: `/home/sirm/projects/.claude/`

**Step 1: Verify we're working in worktree**

Run: `pwd`
Expected: Path contains `.config/superpowers/worktrees`

**Step 2: Remove project-level .claude**

Run: `rm -rf /home/sirm/projects/.claude`

**Step 3: Verify removal**

Run: `ls /home/sirm/projects/.claude 2>&1`
Expected: "No such file or directory"

---

### Task 4B: Clear Home .claude Directories

**Files:**
- Clear: `~/.claude/commands/`, `~/.claude/agents/`
- Keep: `~/.claude/hooks/`, `~/.claude/scripts/`

**Step 1: Backup hooks and scripts**

Run: `tar -czf ~/claude-hooks-backup.tar.gz ~/.claude/hooks ~/.claude/scripts`

**Step 2: Remove commands and agents**

Run: `rm -rf ~/.claude/commands ~/.claude/agents`

**Step 3: Clear plugin metadata**

Run: `rm -rf ~/.claude-plugin`

**Step 4: Verify cleanup**

Run: `ls -la ~/.claude/`
Expected: Only hooks/ and scripts/ remain

---

## Phase 5: Fresh Installation & Testing

### Task 5A: Run Fresh Install

**Files:**
- Execute: `install.sh` from worktree

**Step 1: Change to worktree directory**

Run: `cd ~/.config/superpowers/worktrees/sirm-claude-toolbox/restructure-and-validate`

**Step 2: Run installer**

Run: `./install.sh`
Expected: Symlinks created, hooks copied, success message

**Step 3: Verify symlinks**

Run: `ls -la ~/.claude/ | grep -E "(commands|agents)"`
Expected: Both show as symlinks pointing to worktree

**Step 4: Verify commands exist**

Run: `ls ~/.claude/commands/dotnet/`
Expected: build-test.md, new-project.md, add-package.md

**Step 5: Verify agents exist**

Run: `ls ~/.claude/agents/quality/`
Expected: code-simplifier.md, verify-app.md, adversarial-reviewer.md

---

### Task 5B: Test Command Loading

**Files:**
- Test: Commands load in Claude Code

**Step 1: Check command file syntax**

Run: `head -20 ~/.claude/commands/dotnet/build-test.md`
Expected: Valid YAML frontmatter visible

**Step 2: Verify plugin.json references**

Run: `python3 -c "import json; print('\n'.join([c['name'] for c in json.load(open('~/.claude-plugin/plugin.json'))['commands']]))"`
Expected: List of all command names

**Step 3: Manual verification**

Note: Restart Claude Code and verify `/build-test` command appears in autocomplete

---

## Phase 6: Repository Rename & Documentation

### Task 6A: Create QUICKSTART.md

**Files:**
- Create: `QUICKSTART.md`

**Step 1: Write QUICKSTART.md**

Create: `QUICKSTART.md`

```markdown
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
```

**Step 2: Commit QUICKSTART**

```bash
git add QUICKSTART.md
git commit -m "Add quick start guide

- 2-minute installation steps
- First command examples
- Discord setup instructions
- Customization guide

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 6B: Update README with Roadmap

**Files:**
- Modify: `README.md`

**Step 1: Read current README**

Run: `cat README.md | head -100`

**Step 2: Add Future Work section to README**

Add to `README.md` before the Author section:

```markdown
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
- PostBuild hook with Discord status
- PostTest hook with test details
- PreCommit validation hook

**v2.0 - Marketplace:**
- Publish to official Claude Code marketplace
- One-command installation
- Automatic updates
```

**Step 3: Commit README updates**

```bash
git add README.md
git commit -m "Add roadmap to README

Future work:
- PowerShell/SQL tools
- MCP integrations
- Enhanced hooks
- Marketplace publication

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 6C: Remove Unnecessary Files

**Files:**
- Delete: `CHANGELOG.md`, `LICENSE`, `install.sh.backup`

**Step 1: Remove files**

Run: `git rm CHANGELOG.md LICENSE 2>/dev/null; rm install.sh.backup 2>/dev/null; true`

**Step 2: Commit cleanup**

```bash
git add -A
git commit -m "Remove unnecessary files

- Removed CHANGELOG.md (git history is source)
- Removed LICENSE (not needed presently)
- Removed install script backup

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 6D: Rename Repository

**Files:**
- Rename: GitHub repository `sirm-claude-toolbox` → `sirmaelstroms-claude-code`
- Modify: `.claude-plugin/plugin.json`

**Step 1: Update plugin.json name**

Modify `.claude-plugin/plugin.json`:

```json
{
  "name": "sirmaelstroms-claude-code",
  ...
}
```

**Step 2: Commit name change**

```bash
git add .claude-plugin/plugin.json
git commit -m "Update plugin name to sirmaelstroms-claude-code

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Step 3: Rename GitHub repository**

Run: `gh repo rename sirmaelstroms-claude-code`
Expected: Repository renamed successfully

**Step 4: Update git remote**

Run: `git remote set-url origin https://github.com/sirmaelstrom/sirmaelstroms-claude-code.git`

**Step 5: Verify remote**

Run: `git remote -v`
Expected: Shows new repository name

---

### Task 6E: Push All Changes

**Files:**
- Push: All commits to GitHub

**Step 1: Push to renamed repository**

Run: `git push -u origin restructure-and-validate`
Expected: Branch pushed to GitHub

**Step 2: Verify on GitHub**

Run: `gh pr view --web || echo "Ready to create PR"`
Expected: Ready to create PR or opens browser

---

## Phase 7: Final Verification

### Task 7A: Verify Installation Works

**Step 1: Test fresh clone and install**

Run in new terminal:
```bash
cd /tmp
git clone https://github.com/sirmaelstrom/sirmaelstroms-claude-code.git test-install
cd test-install
./install.sh
```

Expected: Installation succeeds

**Step 2: Check symlinks created**

Run: `ls -la ~/.claude/ | grep -E "(commands|agents)"`
Expected: Symlinks point to /tmp/test-install

**Step 3: Cleanup test installation**

Run: `rm -rf /tmp/test-install`

---

### Task 7B: Create Pull Request

**Step 1: Create PR**

Run:
```bash
gh pr create \
  --title "Restructure and validate toolbox" \
  --body "$(cat <<'EOF'
## Summary
- Validated all YAML/JSON syntax
- Fixed validation errors
- Restructured to match edmunds pattern
- Implemented symlink-based installation
- Enhanced Discord notifications with session context
- Renamed repository to sirmaelstroms-claude-code

## Validation
- ✓ All command YAML validated
- ✓ All agent YAML validated
- ✓ plugin.json and marketplace.json validated
- ✓ Fresh installation tested
- ✓ Symlinks working correctly

## Test Plan
- [x] Run validation scripts
- [x] Fix all errors
- [x] Test fresh installation
- [x] Verify symlinks created
- [x] Verify commands/agents load
- [x] Test Discord notification enhancement

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Expected: PR created successfully

**Step 2: Get PR URL**

Run: `gh pr view --web`
Expected: Opens PR in browser

---

## Success Criteria

- [ ] All YAML/JSON files validated and error-free
- [ ] Repository structure matches edmunds pattern
- [ ] Install script uses symlinks (not copies)
- [ ] Commands load correctly in Claude Code
- [ ] Agents activate based on triggers
- [ ] Discord notifications include session context
- [ ] Repository renamed to sirmaelstroms-claude-code
- [ ] QUICKSTART.md created
- [ ] README includes roadmap
- [ ] Fresh installation tested and working
- [ ] Pull request created for review
