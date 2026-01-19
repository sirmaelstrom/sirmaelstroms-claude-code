# WSL2 + Claude Code Setup Guide

Complete setup guide for running Claude Code in WSL2 with optimal performance and developer tools.

## Prerequisites

- Windows 11 with WSL2 installed
- Ubuntu 20.04+ distribution in WSL
- Internet connection for installs

---

## 1. WSL Configuration (.wslconfig)

**Location:** `%USERPROFILE%\.wslconfig` (Windows side, NOT WSL)

```ini
[wsl2]
memory=8GB          # Adjust to 50% of your RAM
processors=4        # Match your available CPU cores
swap=2GB
localhostForwarding=true
pageReporting=false
```

After creating this file, restart WSL:
```powershell
wsl --shutdown
```

**Performance Note:** By default, WSL2 can use up to 50% of total RAM and all available processor cores. The .wslconfig file lets you fine-tune these limits based on your workload.

---

## 2. Core Essentials (WSL - Ubuntu)

Run in WSL terminal:

```bash
sudo apt update
sudo apt install -y build-essential curl wget git ripgrep fd-find bat jq
```

### Additional Filesystem Optimizations

**Add mount options** for improved Windows drive performance:

```bash
# Create or edit /etc/wsl.conf
sudo tee /etc/wsl.conf > /dev/null <<EOF
[automount]
options = "metadata,noatime"
EOF
```

**Fine-tune kernel parameters** for better filesystem performance:

```bash
# Create kernel tuning config
sudo tee /etc/sysctl.d/99-wsl.conf > /dev/null <<EOF
fs.inotify.max_user_watches=524288
fs.file-max=2097152
EOF

# Apply changes
sudo sysctl --system
```

---

## 3. Node.js (if needed)

**Option A: NodeSource (Latest LTS)**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

**Option B: NVM (Recommended - Cleaner, per-user)**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
```

Verify:
```bash
node --version
npm --version
```

---

## 4. Optional Runtimes (choose as needed)

### .NET SDK
```bash
curl https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --version latest --install-dir ~/.dotnet
echo 'export PATH="$HOME/.dotnet:$PATH"' >> ~/.bashrc
source ~/.bashrc
dotnet --version
```

**Note:** Install .NET in WSL to access .NET projects from Claude Code. Works well even for projects on Windows filesystem (`/mnt/c/`), though keeping projects in WSL filesystem (`~/projects/`) provides better performance.

### C# Tooling (LSP for Claude context)
```bash
dotnet tool install -g OmniSharp
dotnet tool install -g dotnet-format
```

### Python 3.11+
```bash
sudo apt install -y python3.11 python3.11-venv python3-pip
```

### Go
```bash
curl -L https://go.dev/dl/go1.23.0.linux-amd64.tar.gz | sudo tar -C /usr/local -xz
echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

---

## 5. Linters

### .NET / C#

**Built-in Roslyn Analyzers** (no install, included in .NET SDK):
```bash
# Add to .csproj:
# <EnableNETAnalyzers>true</EnableNETAnalyzers>
```

**StyleCop (style enforcement):**
```bash
dotnet add package StyleCop.Analyzers
```

**Roslynator (190+ analyzers & refactorings):**
```bash
dotnet add package Roslynator.Analyzers
```

**CSharpier (formatter, Prettier-like):**
```bash
dotnet tool install -g csharpier
```

**SonarAnalyzer (security + quality):**
```bash
dotnet add package SonarAnalyzer.CSharp
```

**Run linting:**
```bash
dotnet format --verify-no-changes --severity info
dotnet build --analyze
```

### Python
```bash
pip install pylint flake8 black ruff --break-system-packages
```

### JavaScript/TypeScript
```bash
npm install -g eslint prettier
```

### Go
```bash
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

---

## 6. MCP Servers for Claude Code

### Installation Pattern

Each MCP server connects Claude Code to external tools/APIs/data. Claude Code's lazy-loading MCP Tool Search reduces context usage by up to 95% compared to loading all tools upfront.

```bash
# View connected servers
claude mcp list

# Add a server (example)
claude mcp add github -- npx -y @modelcontextprotocol/server-github
```

### Essential MCP Servers (Start with these)

**1. GitHub MCP** — Repository, PR, and issue management
```bash
claude mcp add github -- npx -y @modelcontextprotocol/server-github
```
Requires environment variable:
```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="<your-github-token>"
```
Allows Claude to read issues, manage PRs, trigger CI/CD, and analyze commits directly from the terminal.

**2. Filesystem MCP** — Granular file access for Claude
```bash
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem ~/projects
```
Provides secure local file operations: read, write, edit, search, and manage directories with granular permission controls.

**3. Brave Search MCP** — Web research during coding sessions
```bash
claude mcp add brave-search -- npx -y @modelcontextprotocol/server-brave-search
```
Enables web research for documentation lookup during development. Fallback for offline docs.

### High-Value Productivity MCP Servers

**Sequential Thinking** — Makes Claude's reasoning visible/editable for complex problems
```bash
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
```

**PostgreSQL** — Direct DB queries & schema introspection
```bash
claude mcp add postgresql -- npx -y @modelcontextprotocol/server-postgresql
```

**Puppeteer** — Browser automation and testing
```bash
claude mcp add puppeteer -- npx -y @modelcontextprotocol/server-puppeteer
```
Enables Claude to write and execute complex browser automation scripts for testing, scraping, or browser-based tools.

**Sentry** — Error tracking and performance monitoring
```bash
claude mcp add sentry -- npx -y @modelcontextprotocol/server-sentry
```
Transforms Claude into an intelligent error tracking assistant by connecting to Sentry projects.

**Zapier** — Cross-app workflow automation
```bash
claude mcp add zapier -- npx -y @modelcontextprotocol/server-zapier
```
Streamlines repetitive tasks like notifications or updates across 5000+ app integrations.

### MCP Selection Best Practices

**Choose 2-3 MCPs that match your primary tasks** rather than installing everything:
- Too many MCPs bloat context window startup
- Select based on task type (Puppeteer for web automation, PostgreSQL for database work)
- Prioritize servers with clear documentation and OAuth support
- Consider scalability for large projects

For more MCP servers, see [Top 10 MCP Servers for Claude Code](https://apidog.com/blog/top-10-mcp-servers-for-claude-code/) and [Best MCP Servers Guide](https://mcpcat.io/guides/best-mcp-servers-for-claude-code/).

---

## 7. Performance Tips

### Filesystem Performance (Critical)

**The Problem:** `/mnt/c/` (Windows filesystem) is ~6% of native WSL speed. File operations take 10-20x longer due to the 9P protocol overhead.

**Benchmark Data:**
- Linux filesystem (ext4): Full speed
- Windows filesystem via /mnt/c/: ~6% speed
- Cross-filesystem operations: Severe performance penalty

**Solutions:**

1. **Keep projects in WSL native filesystem** (~/home dir)
   ```bash
   cd ~/projects          # Fast (ext4)
   cd /mnt/c/Users/...    # Slow (9P protocol over NTFS)
   ```

2. **For .NET development:**
   - WSL + Claude Code works well for .NET, even with projects on `/mnt/c/`
   - For optimal performance: Keep .NET projects in `~/projects/` (WSL filesystem)
   - The filesystem overhead is often acceptable for typical development workflows
   - Native Windows Claude Code exists as an alternative, though user experience may vary

3. **Cross-OS Access:**
   - Edit WSL files from Windows via `\\wsl.localhost\<distro>\<path>`
   - Use VS Code with WSL Remote extension for seamless editing
   - Avoid frequent cross-filesystem operations

### Build Performance

**Disable antivirus scanning** on WSL directory if possible:
- Windows Defender → Settings → Exclusions
- Add `%USERPROFILE%\AppData\Local\Packages\CanonicalGroupLimited*`

**Additional optimizations:**
- Use `noatime` mount option (see section 2)
- Increase inotify watches for large projects (already configured in section 2)
- Consider SSD storage for WSL VHD location

For detailed performance benchmarking, see [WSL2 Performance Optimization](https://www.ceos3c.com/linux/wsl2-performance-optimization-speed-up-your-linux-experience/) and [WSL2 File System Management](https://www.ceos3c.com/linux/wsl2-file-system-management-optimize-storage-and-performance/).

---

## 8. Development Environment Recommendations

### Recommended: WSL + Claude Code
**Works well for .NET, polyglot, and Linux-native development.**

- Unified environment for all languages and tools
- Acceptable performance even for .NET projects on `/mnt/c/`
- Better performance when projects are in WSL filesystem (`~/projects/`)
- Full Linux toolchain available

### Alternative: Native Windows Claude Code
Native Windows Claude Code (v2.x, 2025+) is available but user experience may vary.

```powershell
# Windows PowerShell (as Admin) - if you want to try this option
Invoke-RestMethod -Uri https://gist.githubusercontent.com/bjornmage/f4b136150f6904b812c1ece49e49d12e/raw/claudecode_installer.ps1 | Invoke-Expression
```

**Personal observation:** WSL + Claude Code provides a better overall experience, even with the theoretical filesystem overhead.

---

## 9. Verification Checklist

After all installs, verify:

```bash
node --version      # v18+
npm --version       # v9+
git --version       # any
rg --version        # ripgrep
dotnet --version    # (if installed) v7+
python3 --version   # (if installed)
go version          # (if installed)

# Claude Code
claude --version
claude doctor       # System health check
claude mcp list     # Verify MCP servers
```

---

## 10. Path & Environment Hygiene

**Problem:** Windows PATH leaking into WSL causes issues and performance degradation.

**Solution:**
```bash
# Check for Windows paths in WSL
echo $PATH | grep -o '/mnt/c[^:]*' | head -5

# If found, add clean PATH to ~/.bashrc
echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.npm-global/bin:$HOME/.dotnet"' >> ~/.bashrc
source ~/.bashrc
```

Configure npm to avoid sudo issues:
```bash
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

---

## 11. Common Gotchas

| Issue | Fix |
|-------|-----|
| `dotnet` not found after install | Close/reopen WSL terminal or `source ~/.bashrc` |
| npm permissions errors | Configure `~/.npm-global` (see section 10) |
| WSL file operations slow | Move project to `~/projects` (native WSL FS) |
| Claude Code can't find git | `apt install -y git` |
| DNS fails behind proxy | Check `/etc/resolv.conf`, may need IT config |
| Antivirus slows builds | Disable Windows Defender scans on WSL directory |
| MCP servers not loading | Check `claude mcp list` and verify environment variables |
| Cross-filesystem sync issues | Use `\\wsl.localhost\` path or VS Code WSL Remote |

---

## 12. Quick Start Commands (One-Liner Reference)

```bash
# Full setup (core + Node + linters)
sudo apt update && sudo apt install -y build-essential curl wget git ripgrep fd-find bat jq && \
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && \
sudo apt install -y nodejs && \
pip install pylint flake8 ruff --break-system-packages

# Install all linters (.NET flavor)
dotnet add package StyleCop.Analyzers && \
dotnet add package Roslynator.Analyzers && \
dotnet add package SonarAnalyzer.CSharp && \
dotnet tool install -g csharpier

# Add essential MCP servers
export GITHUB_PERSONAL_ACCESS_TOKEN=your_token_here && \
claude mcp add github -- npx -y @modelcontextprotocol/server-github && \
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem ~/projects && \
claude mcp add brave-search -- npx -y @modelcontextprotocol/server-brave-search

# Test all tools
node -v && npm -v && git --version && dotnet --version && rg --version && claude --version
```

---

## 13. Resources

### Official Documentation
- [Claude Code Docs](https://code.claude.com/docs)
- [WSL Best Practices](https://learn.microsoft.com/en-us/windows/wsl/)
- [MCP Protocol Spec](https://modelcontextprotocol.io/)

### Performance & Optimization
- [WSL2 Performance Optimization Guide](https://www.ceos3c.com/linux/wsl2-performance-optimization-speed-up-your-linux-experience/)
- [WSL2 File System Management](https://www.ceos3c.com/linux/wsl2-file-system-management-optimize-storage-and-performance/)
- [Comparing WSL Versions](https://learn.microsoft.com/en-us/windows/wsl/compare-versions)

### MCP Servers
- [Top 10 Essential MCP Servers](https://apidog.com/blog/top-10-mcp-servers-for-claude-code/)
- [Best MCP Servers Guide](https://mcpcat.io/guides/best-mcp-servers-for-claude-code/)
- [The 10 Must-Have MCP Servers](https://roobia.medium.com/the-10-must-have-mcp-servers-for-claude-code-2025-developer-edition-43dc3c15c887)
- [Claude Code Productivity Tips](https://www.f22labs.com/blogs/10-claude-code-productivity-tips-for-every-developer/)

### .NET Specific
- [Roslyn Analyzers](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/overview)
- [CSharpier Formatter](https://csharpier.com/)

---

**Last Updated:** January 2026
**Tested On:** Windows 11 + WSL2 Ubuntu 22.04 + Claude Code v2.x
