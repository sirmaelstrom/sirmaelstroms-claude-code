# Learnings & Observations

Personal insights and lessons learned while building and using this Claude Code plugin collection.

## Table of Contents

1. [Building with AI: Patterns Over Tools](#building-with-ai-patterns-over-tools) - Universal principles for AI-collaborative development
2. [Permission Management Strategy](#permission-management-strategy) - Critical operational knowledge
3. [Token Efficiency & Scale](#token-efficiency--scale) - Real-world usage economics
4. [Notification Hooks & Debug Infrastructure](#notification-hooks--debug-infrastructure) - Infrastructure thinking in practice
5. [WSL Performance on Home Setup](#wsl-performance-on-home-setup) - Environment optimization
6. [MCP Server Strategy](#mcp-server-strategy) - Tooling selection criteria
7. [Toolkit Development Insights](#toolkit-development-insights) - Parallel development patterns
8. [Superpowers Plugin Workflow](#superpowers-plugin-workflow) - Specific tool integration
9. [Future Exploration](#future-exploration) - Areas to expand
10. [Resources](#resources) - References and links

---

## Building with AI: Patterns Over Tools

### Weekend Iteration Cycle (January 2026)

Spent the weekend iterating between multiple projects with Claude:
- Refining base settings and permission configurations
- Building this Claude Code toolkit
- Creating a game mod project (Schedule I)
- Logging learnings in real-time
- Reading/watching AI development content

This parallel development revealed patterns that transcend specific tools or implementations.

### Four Core Principles

Derived from observing successful AI builders and validating against actual weekend work.

#### 1. Architecture is Portable, Tools Are Not

**Theory:** The underlying system architecture (capture, sort, process) remains stable across wildly different tool stacks. Focus on learning patterns, not memorizing tools.

**Observed in Practice:**
- Discord/Slack notification system: Architecture (event → capture → format → deliver) works identically whether targeting Discord webhooks or Slack APIs
- Permission management: Pattern of "observe → analyze → pre-approve" applies whether using hook debug logs, permission suggestions, or manual tracking
- Toolkit structure: Commands/agents/hooks architecture borrowed from community examples, but implementation uses bash/jq/curl instead of their Node.js/TypeScript

**Validation:** Successfully implemented community patterns (from GitHub repositories) using completely different tech stack. The architecture translated; the tools didn't.

**Implication:** When evaluating new approaches, extract the architectural pattern first. Ask "what's the underlying structure?" not "what tools do they use?"

#### 2. Principles-Based Guidance Scales Better Than Rules

**Theory:** Providing principles ("use TDD," "don't swallow errors") allows AI to apply judgment. Rigid rules limit flexibility in unanticipated contexts.

**Observed in Practice:**
- `CLAUDE.md` principle: "Evidence-driven, not praise-driven" → Claude adjusts communication style contextually
- Tool usage guideline: "Use Edit for modifications, Bash for operations" → Claude chooses appropriately based on file type and operation
- Permission pre-approvals: Wildcard patterns (`Bash(dotnet:*)`) vs. specific commands → wildcards scale better as new scenarios emerge

**Counter-Example:**
- Overly specific permission rules (line 118-133 in old settings) became maintenance burden
- Required constant updates for each new git command variant

**Meta-Pattern Observed:** Used principles to guide Claude in building this toolkit. "Maintain architectural consistency," "follow security best practices," "document decisions" resulted in coherent system without prescriptive rules for every scenario.

**Implication:** When writing documentation or configuring systems, favor principles that scale over rules that constrain. Let AI (or future humans) apply judgment.

#### 3. If the Agent Builds It, the Agent Can Maintain It

**Theory:** When AI constructs infrastructure, it maintains context and can self-correct indefinitely. Human builders lose context over time.

**Observed in Practice:**
- Claude built notification hooks → Claude debugged permission issues → Claude added Slack support → Claude refactored for security
- Full conversation context meant no "what was I thinking?" moments
- Documentation written during implementation, not after
- Bug fixes leveraged build context (Claude: "I see in the earlier implementation at line X...")

**Practical Application:**
- When starting new project, involve Claude from design phase, not just implementation
- Keep conversation artifacts (`/transcript`) for complex builds
- Let Claude refactor its own code rather than manually editing

**Weekend Validation:**
- Game mod setup: Claude set up project structure → Claude debugged build issues → Claude added new features
- No "rediscovering" why something was built a certain way
- Maintenance became "continue the conversation" not "reverse engineer then fix"

**Implication:** Default to AI-involved construction for any system you'll need to maintain. The upfront conversation cost pays dividends in reduced context-switching later.

#### 4. Your System Can Be Infrastructure, Not Just a Tool

**Theory:** Higher-level thinking: Is this solving a problem (tool) or enabling others to build (infrastructure)?

**Observed in Practice:**
- Hook debug log: Started as debugging tool → Became infrastructure for permission analysis → Others could build analyzers on top
- Permission settings structure: Not just "my settings" → Template/pattern for other projects → Infrastructure for consistent permission management
- Toolkit itself: Not just "my scripts" → Published as reference architecture → Infrastructure for community pattern library

**Shift in Thinking:**
- Tool: "Notification hook that pings Discord when Claude stops"
- Infrastructure: "Event system with structured logging that other tools can consume"

**Result:** Debug log analysis enabled permission hierarchy troubleshooting. The infrastructure approach (structured logging) made new use cases possible without redesign.

**Weekend Example:**
- Game mod project: Built as infrastructure (modding framework) not tool (specific feature implementation)
- Others can extend the mod using the established patterns
- Architecture enables, doesn't constrain

**Implication:** When designing systems, ask: "What could someone build on top of this?" Infrastructure thinking leads to compounding advantages.

### The New Building Pattern: Community + AI Collaboration

**Pattern Observed Across Weekend Work:**

1. **Hit obstacle** (e.g., permission hierarchy trap)
2. **Check community patterns** (GitHub repos, Discord discussions, documentation)
3. **Identify architectural solution** (consolidate to global settings)
4. **Collaborate with Claude to implement** in specific context
5. **Document the pattern** for future reference
6. **Contribute back** (this toolkit, learnings documentation)

**Why This Works:**
- Community provides pattern library → "Someone solved this before"
- AI provides implementation muscle → "Do it in my specific context"
- Bridges gap between "understanding someone else's solution" and "having it work in my setup"

**Validation:**
- Discord notification hooks: Community pattern → Claude implementation → Documented for others
- Permission management: Others' approaches → Adapted to my setup → Added learnings back
- Toolkit architecture: Borrowed structure → Implemented with my tech stack → Shared result

**Implication:** The fastest path forward isn't pure research or pure building—it's pattern recognition from community plus AI-powered implementation.

### Meta-Pattern: Use Patterns to Build Your Patterns

**Observed:** Used AI collaboration to build AI tooling that follows these same principles.

**Example:**
- Superpowers agents → Built this toolkit
- This toolkit → Will build future projects
- Pattern compounds: better patterns → better tools → better patterns

**Development Velocity:**
- Weekend 1: Manual exploration, slow iteration
- Weekend 2 (this one): Toolkit exists, 10x faster
- Expected Weekend 3: Toolkit refined, even faster

**Key Insight:** Investment in pattern-based infrastructure pays exponential dividends. Each iteration makes the next iteration faster.

### Practical Takeaways

From weekend work and pattern analysis:

1. **Architecture First, Tools Second**
   - When learning new approaches, extract patterns before implementation details
   - Ask "what's the structure?" not "what's the syntax?"

2. **Write Principles, Not Rules**
   - Documentation should guide, not constrain
   - Enable AI (and humans) to apply judgment

3. **Involve AI in Construction**
   - Don't use AI as "code executor" for plans you made alone
   - Collaborative design → better context → easier maintenance

4. **Think Infrastructure**
   - Build systems that enable building, not just solve problems
   - Structured outputs > single-purpose scripts

5. **Community + AI = Velocity**
   - Pattern recognition (community) + implementation power (AI) = fastest path
   - Contribute back to compound the advantage

### Measurement

Will track over coming weeks:
- Time to implement new features with toolkit vs. without
- Number of permission stops (decreasing as patterns stabilize)
- Token efficiency (principle-based guidance vs. prescriptive instructions)
- Pattern reuse frequency (how often do learned patterns apply to new problems?)

---

## Permission Management Strategy

### Evolution

**Phase 1: Reactive**
- Approve permissions as prompted
- No pattern recognition
- Repeated approvals for same operations

**Phase 2: Observational**
- Hook debug log shows permission request patterns
- Identified frequently requested tools
- Noticed permission suggestion patterns

**Phase 3: Proactive**
- Pre-approved common operations in settings.local.json
- Targeted rules for specific paths/commands
- Balance between convenience and security

### Current Pre-Approved Patterns

**Read Operations:**
```json
{
  "toolRules": [
    {"toolName": "Read", "ruleContent": "~/projects/**", "behavior": "allow"},
    {"toolName": "Glob", "ruleContent": "~/projects/**", "behavior": "allow"},
    {"toolName": "Grep", "ruleContent": "~/projects/**", "behavior": "allow"}
  ]
}
```

**Build/Test Commands:**
```json
{
  "toolRules": [
    {"toolName": "Bash", "ruleContent": "dotnet build*", "behavior": "allow"},
    {"toolName": "Bash", "ruleContent": "dotnet test*", "behavior": "allow"},
    {"toolName": "Bash", "ruleContent": "npm test*", "behavior": "allow"}
  ]
}
```

### Lesson Learned

The debug log transformed permission management from guesswork to data-driven decisions. Analyzing the log reveals:
- Which permissions to pre-approve
- Where to add directory-level grants
- When to use session-scoped vs. permanent rules

**Quick analysis commands:**
```bash
# Recent permission requests
grep -n "EVENT_TYPE: PermissionRequest" ~/.cache/claude_hook_debug.log | tail -20

# Permission requests with timestamps
awk '/^=== [0-9]{4}.*Z ===$/ {ts=$2} /EVENT_TYPE: PermissionRequest/ {print NR": "ts}' ~/.cache/claude_hook_debug.log | tail -20
```

### Permission Hierarchy Trap

**Problem Discovered:** January 2026

Experienced repeated permission stops despite having comprehensive pre-approved rules configured. Investigation revealed a settings hierarchy issue.

**Settings File Priority:**
```
~/.claude/settings.json (global)
  └─ /path/to/parent/.claude/settings.local.json (parent)
       └─ /path/to/project/.claude/settings.local.json (project)
```

**The Trap:** Project-specific `settings.local.json` files **replace** (not merge with) parent settings.

Working in `~/projects/github/sirmaelstroms-claude-code/` with project-specific settings meant:
- Lost access to 120+ comprehensive permissions defined in parent directory
- Only 16 project-specific permissions active
- Constant permission prompts for basic operations (echo, grep, sed, jq)

**Root Cause:**
- Global settings: 25 permissions
- Parent settings (`~/projects/.claude/settings.local.json`): 131 permissions
- Project settings: Only project-specific overrides

When Claude Code loads project settings, it doesn't inherit from parent—it replaces.

**Solution: Consolidate to Global**

1. **Merged comprehensive permissions to global** (`~/.claude/settings.json`):
   - All common operations (git, dotnet, npm, docker, file operations)
   - Read permissions for all home directories
   - Task agent pre-approvals
   - 137 total permissions

2. **Reduced project settings to truly unique rules**:
   - sirmaelstroms-claude-code: 7 project-specific git commands
   - schedule-i-mod: 2 project-specific build scripts

3. **Removed intermediate parent settings** to eliminate confusion

**Result:** Projects now inherit comprehensive global permissions and add only project-unique rules.

**Key Insight:** Settings hierarchy is replacement-based, not merge-based. Keep base permissions global, project settings minimal.

**Verification:**
```bash
# Count permissions in each layer
jq '.permissions.allow | length' ~/.claude/settings.json
jq '.permissions.allow | length' /path/to/project/.claude/settings.local.json
```

---

## Token Efficiency & Scale

### Weekend Development Sprint (January 17-19, 2026)

Sustained intensive development across ~62 hours (Saturday 6PM through Monday morning):

**Consumption (Max 5x Plan):**
- 30% of all models weekly allowance
- 45% of Sonnet-only weekly allowance
- 2 sessions hit 90%+ of single-session limit

**Workload:**
- ~24+ hours of actual development time with active Claude attention
- Two major projects: game mod + sirmaelstroms-claude-code
- Multiple intensive refactoring sessions
- Environment tuning to enable more autonomous agent work
- Parallel development, debugging, and documentation
- Real-time problem solving and architecture decisions

**Context:**
- Session limit hits occurred during intensive refactoring/review cycles
- Continuous iteration: build → test → refine → document
- Not just code generation—design collaboration, debugging, learning synthesis
- Heavy use of agents with increasing autonomy as environment stabilized

**Insights:**
- Token usage correlates with collaboration intensity, not just code volume
- Refactoring/review sessions (understanding existing code + making changes) consume more tokens than greenfield development
- Environment setup investment (permissions, settings, agents) pays off in reduced friction
- Agent autonomy reduces token cost once patterns are established
- Still significant headroom (55% Sonnet, 70% overall) even during marathon sessions

### Key Takeaway

Superpowers' agent-based workflow is remarkably token-efficient compared to direct chat. The revision workflow adds a critical review layer that catches issues early and improves plan quality before implementation.

---

## Notification Hooks & Debug Infrastructure

### Initial Implementation

**Goal:** Structured notifications when Claude Code stops and waits for input.

**First Attempt:**
- Created Discord webhook hook
- Sent rich embeds with session context (files modified, test results, commits)
- **Problem:** Inconsistent triggering — worked sometimes, failed other times

### Refinement Journey

**Iteration 1: Consistency Improvements**
- Added debug logging to `~/.cache/claude_hook_debug.log`
- Tracked all hook events (Stop, SessionStart, SessionEnd, PermissionRequest)
- Identified timing issues and race conditions

**Iteration 2: Expanded Scope**
- Logging session state changes revealed broader use cases
- Added notifications for all four hook event types
- Color-coded status: Green (SessionStart/End), Blue (Stop), Orange (PermissionRequest)

**Iteration 3: Unified Platform Support**
- Realized need for both Discord and Slack notifications
- Refactored to unified script supporting both platforms simultaneously
- Added platform toggles: `NOTIFY_DISCORD`, `NOTIFY_SLACK`

### Unexpected Benefits

The logging infrastructure built for debugging hooks led to:

1. **Permission Pattern Analysis**
   - Easier identification of blocking permission prompts
   - Data-driven decisions for pre-approval rules
   - Targeted vs. broad permission grants

2. **Session Insights**
   - Track operations per session (reads, edits, writes)
   - Monitor agent usage patterns
   - Identify performance bottlenecks

### Hook Configuration Evolution

**Initial (.claude/settings.json):**
```json
{
  "hooks": {
    "Stop": "~/.claude/scripts/discord-notify.sh"
  }
}
```

**Current (.claude/settings.json):**
```json
{
  "hooks": {
    "Stop": "~/.claude/hooks/claude-notify.sh Stop",
    "SessionStart": "~/.claude/hooks/claude-notify.sh SessionStart",
    "SessionEnd": "~/.claude/hooks/claude-notify.sh SessionEnd",
    "PermissionRequest": "~/.claude/hooks/claude-notify.sh PermissionRequest"
  }
}
```

**Environment Variables:**
```bash
export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
export NOTIFY_DISCORD=true  # Default: true if webhook set
export NOTIFY_SLACK=true    # Default: true if webhook set
```

### Lesson Learned

What started as "neat when it works" became a robust observability layer. Debug infrastructure pays dividends beyond the original problem.

### Current Limitation: Windows Terminal Tab Identification

**Problem:** Windows Terminal doesn't expose tab names or identifiers to the running shell session, limiting notification context.

**Impact:**
- Notifications can't identify which terminal tab/session triggered them
- Multitasking across multiple Claude Code sessions becomes harder to track
- Manual correlation required between notification and active session

**Potential Workarounds:**
- Use different working directories per session (visible in notification)
- Set custom environment variables per tab (e.g., `export SESSION_NAME="project-alpha"`)
- Use tmux/screen with named sessions inside Windows Terminal

**Ideal Solution:** Windows Terminal API to expose tab metadata to shell environment would enable session-specific notification identifiers.

---

## WSL Performance on Home Setup

### Performance Comparison

**Home Setup:** "Crazy faster" than expected
- Windows 11 + WSL2 + properly configured filesystem
- Projects in WSL native filesystem (`~/projects/`)
- Following optimization best practices from [WSL2 Performance Guide](https://www.ceos3c.com/linux/wsl2-performance-optimization-speed-up-your-linux-experience/)

### Critical Configuration

**.wslconfig (50% RAM allocation):**
```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
pageReporting=false
```

**Filesystem optimizations:**
- Projects in WSL filesystem, not `/mnt/c/`
- `noatime` mount option
- Antivirus exclusions on WSL directory
- Increased inotify watches

### The 94% Problem

Accessing Windows filesystem from WSL (`/mnt/c/`) operates at **~6% of native speed**:
- 9P protocol overhead
- Cross-filesystem translation
- NTFS → ext4 semantics mapping

**Solution:** Keep active projects in `~/projects/` (WSL native filesystem).

### Performance Impact

Operations that were painfully slow elsewhere (npm install, dotnet restore, ripgrep searches) run at expected speeds in properly configured WSL.

**Key Insight:** Location matters more than hardware. A mid-range setup with proper configuration outperforms high-end hardware with projects on `/mnt/c/`.

### .NET Development in WSL

Despite benchmark data showing `/mnt/c/` operates at ~6% of native speed, real-world .NET development experience in WSL has been positive:

**Actual Experience:**
- `dotnet build`, `dotnet restore`, `dotnet test` perform acceptably on `/mnt/c/` projects
- Filesystem overhead is noticeable in benchmarks but not disruptive in practice
- WSL + Claude Code provides better overall experience than native Windows Claude Code

**Native Windows Claude Code:**
- Theoretically eliminates filesystem overhead
- Personal experience: "very bad" user experience
- Not recommended despite performance advantages on paper

**Takeaway:** Measured performance ≠ developer experience. WSL + Claude Code works well for .NET development, even with cross-filesystem access.

---

## MCP Server Strategy

### Selection Criteria

After research and experimentation:

**Start with 3 essential servers:**
1. **GitHub** - Repository operations
2. **Filesystem** - Granular file access
3. **Brave Search** - Documentation lookup

**Add productivity servers as needed:**
- Sequential Thinking - Complex problem solving
- PostgreSQL - Database operations
- Sentry - Error tracking

### Key Insight

**Don't install everything.**
- Too many MCPs slow Claude Code startup
- Context window bloat reduces effectiveness
- Choose 2-3 servers matching primary development tasks

See [Top 10 MCP Servers](https://apidog.com/blog/top-10-mcp-servers-for-claude-code/) for comprehensive comparisons.

---

## Toolkit Development Insights

### Parallel Development

Working on two related projects simultaneously (plans + toolkit) using Superpowers revealed:

1. **Context Switching Benefits**
   - Fresh perspective when moving between projects
   - Pattern recognition across different codebases
   - Cross-pollination of ideas

2. **Consistency Challenges**
   - Maintaining consistent patterns across projects
   - Ensuring documentation stays in sync
   - Managing shared scripts and configurations

3. **Efficiency Gains**
   - Common problems solved once, applied to both
   - Shared tooling reduces duplication
   - Faster iteration through pattern reuse

### Consumption Model Differences

**Claude Desktop vs. Claude Code:**
- Different token consumption patterns observed
- CLI appears more token-efficient for iterative work
- Desktop better for exploratory planning sessions

**Hypothesis:** CLI's focused, task-oriented nature vs. Desktop's conversational style affects token usage patterns.

---

## Superpowers Plugin Workflow

The [Superpowers plugin](https://github.com/superpowered-ai/superpowers-for-claude-code) has proven exceptionally valuable in the development workflow.

### Workflow Pattern

1. **Initial Planning** — Created implementation plans using Claude Desktop
2. **Refinement** — Ran plans through Superpowers for review and revision workflow
3. **Parallel Work** — Simultaneously revised personal Claude Code toolkit using Superpowers
4. **Result** — High-quality output with minimal token usage

---

## Future Exploration

### Areas to Explore

1. **Hook Expansion**
   - PostBuild notifications with build status
   - PostTest with detailed test results
   - PreCommit validation hooks

2. **MCP Development**
   - Custom error log analysis server
   - Project-specific context servers
   - Integration with internal tools

3. **Performance Profiling**
   - Systematic measurement of hook overhead
   - MCP server impact on response time
   - Token usage patterns across different workflows

4. **Documentation Evolution**
   - Record patterns that work well
   - Document anti-patterns to avoid
   - Build knowledge base from session logs

### Measurement Focus

Future learnings should be measurement-driven:
- Token usage per workflow type
- Time saved vs. manual approaches
- Error rates before/after tooling improvements

---

## Resources

### Community
- [Superpowers for Claude Code](https://github.com/superpowered-ai/superpowers-for-claude-code)
- [Claude Code Discord](https://discord.gg/claude-code)

### Performance
- [WSL2 Performance Optimization](https://www.ceos3c.com/linux/wsl2-performance-optimization-speed-up-your-linux-experience/)
- [WSL2 File System Management](https://www.ceos3c.com/linux/wsl2-file-system-management-optimize-storage-and-performance/)

### MCP Ecosystem
- [Best MCP Servers for Claude Code](https://mcpcat.io/guides/best-mcp-servers-for-claude-code/)
- [The 10 Must-Have MCP Servers](https://roobia.medium.com/the-10-must-have-mcp-servers-for-claude-code-2025-developer-edition-43dc3c15c887)
- [Claude Code Productivity Tips](https://www.f22labs.com/blogs/10-claude-code-productivity-tips-for-every-developer/)

### AI Building Patterns
- [They Ignored My Tool Stack and Built Something Better](https://natesnewsletter.substack.com/p/50-people-ignored-my-tool-recommendations) - Four principles for successful AI builders
- [Video: The 4 Patterns That Work](https://www.youtube.com/watch?v=_gPODg6br5w) - Community + AI collaboration patterns

---

**Last Updated:** January 19, 2026
**Context:** Personal observations from toolkit development and daily Claude Code usage
