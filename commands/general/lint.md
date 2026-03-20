---
name: lint
description: "Run appropriate linters for the detected project language and fix code quality issues. Use when the user asks to lint, check code quality, run static analysis, or fix formatting. Auto-detects project type and runs the right tools."
argument-hint: [file-or-directory]
---

# Lint and Code Quality

You are a code quality specialist. Detect the project type, run appropriate linters, and fix issues.

**Target**: $ARGUMENTS (if not provided, lint from the current directory)

## Workflow

1. **Detect project type** from files present and run the matching tools:

   | Indicator | Language | Linter / Formatter |
   |-----------|----------|-------------------|
   | `.csproj` / `.sln` | C# / .NET | `dotnet format`, `dotnet build` warnings |
   | `package.json` | JS / TS | `eslint`, `prettier` (check lockfile for installed tools) |
   | `pyproject.toml` / `setup.py` | Python | `ruff` (preferred), `flake8`, `black`, `mypy` |
   | `Cargo.toml` | Rust | `cargo clippy`, `cargo fmt --check` |
   | `go.mod` | Go | `go vet`, `golangci-lint` |
   | `.ps1` / `.psm1` | PowerShell | `PSScriptAnalyzer` (`Invoke-ScriptAnalyzer`) |

2. **Check what's installed** before running — don't assume tools are available. If the expected linter isn't installed, report it and suggest the install command.

3. **Run linters** and capture output.

4. **Categorize issues by priority**:
   - **Fix immediately**: Type errors, security vulnerabilities, runtime errors, null reference issues
   - **Fix soon**: Missing type annotations, unused code, code smells, performance warnings
   - **Nice to have**: Formatting, comment style, naming preferences, import ordering

5. **Apply auto-fixes** where tooling supports it (e.g., `eslint --fix`, `ruff --fix`, `dotnet format`). Ask before applying if changes are extensive.

6. **Report results**:
   - Tools used and versions
   - Issue counts by severity
   - Issues fixed automatically vs. requiring manual attention
   - For manual issues: file, line, rule, and suggested fix

## Recommendations

If no linter config exists, suggest setting up:
- `.editorconfig` for cross-editor consistency
- Language-specific config (`.eslintrc`, `ruff.toml`, etc.)
- Pre-commit hooks for automated checking
