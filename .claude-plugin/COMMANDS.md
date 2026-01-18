# Claude Plugin Commands

This document lists all available slash commands for the Claude plugin.

## Git Commands

### `/commit-push-pr`

**Description**: Execute a complete git workflow: stage changes, commit with co-authorship attribution, push to remote, and create a pull request.

**Usage**:
```bash
/commit-push-pr
```

**Expected Behavior**:
1. Analyzes current git state (status, diff, branch tracking)
2. Reviews changes and identifies nature (feature, bug fix, refactoring, etc.)
3. Stages relevant files for commit
4. Creates commit with co-authorship: `Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>`
5. Pushes to remote (with `-u` flag if needed)
6. Creates pull request with summary, test plan, and Discord embed JSON
7. Returns PR URL

**Notes**:
- Will not commit files that likely contain secrets (.env, credentials.json, etc.)
- Uses HEREDOC format for commit messages and PR body
- Follows Git Safety Protocol (never --amend unless requested, never force push to main/master)
- If commit fails due to pre-commit hook, fixes issue and creates NEW commit

---

## .NET Commands

### `/build-test`

**Description**: Build and test .NET solution/project with error reporting.

**Argument Hint**: `[path-to-sln-or-csproj]`

**Usage**:
```bash
/build-test
/build-test /path/to/solution.sln
/build-test /path/to/project.csproj
```

**Expected Behavior**:
1. Runs `dotnet build` on target (or current directory if no path provided)
2. Reports build errors with file paths, line numbers, error codes, and messages
3. If build succeeds, runs `dotnet test` on target
4. Reports test results (total, passed, failed, skipped)
5. For failures, reports test name, failure message, and stack trace
6. Provides concise summary with exit codes and duration

**Notes**:
- If build fails, stops and reports errors without proceeding to tests
- Uses absolute file paths in all output

---

### `/new-project`

**Description**: Scaffold new .NET project with template selection.

**Argument Hint**: `[template-name] [project-name]`

**Usage**:
```bash
/new-project
/new-project console MyApp
/new-project webapi MyApi
```

**Expected Behavior**:
1. If arguments provided: creates project directly with specified template and name
2. If no arguments: lists available templates and prompts for selection
3. Asks for project name and output path (default: current directory)
4. Creates project using `dotnet new <template> -n <name> -o <path>`
5. Optionally creates or adds to solution file
6. Reports created project path and next steps (restore, build, run)

**Common Templates**: console, classlib, web, webapi, mvc, blazor, xunit, nunit, mstest

**Notes**:
- All output paths are absolute

---

### `/add-package`

**Description**: Search and add NuGet packages to .NET project.

**Argument Hint**: `[package-name] [version]`

**Usage**:
```bash
/add-package
/add-package Newtonsoft.Json
/add-package Newtonsoft.Json 13.0.3
```

**Expected Behavior**:
1. If full arguments: installs package directly
2. If only package name: searches nuget.org, shows description, download count, and versions
3. Prompts for project path (auto-selects if only one .csproj in directory)
4. Prompts for version selection (latest stable default, latest preview, or specific version)
5. Runs `dotnet add <project> package <package-name> [--version <version>]`
6. Verifies installation with `dotnet list <project> package`
7. Reports installed package, version, and target project path

**Notes**:
- Uses web search to find packages on nuget.org
- Displays package popularity and version history

---

## General Commands

### `/code-explain`

**Description**: Generate detailed explanations of code structure, logic, and patterns.

**Usage**:
```bash
/code-explain
```

**Expected Behavior**:
1. Analyzes code complexity (cyclomatic complexity, nesting depth)
2. Identifies programming language, paradigm, and patterns
3. Generates Mermaid diagrams (flow, class, sequence, component)
4. Provides three explanation levels:
   - High-level overview (30 seconds)
   - Step-by-step breakdown (5 minutes)
   - Deep dive (15 minutes)
5. Identifies design patterns and anti-patterns
6. Highlights best practices and improvement opportunities
7. Recommends learning resources

**Output Includes**:
- Complexity assessment
- Visual diagrams
- Component breakdown
- Execution flow walkthrough
- Pattern recognition
- Common pitfalls and best practices

---

### `/docs-generate`

**Description**: Generate comprehensive documentation for code, APIs, and projects.

**Usage**:
```bash
/docs-generate
```

**Expected Behavior**:
Generates appropriate documentation based on context:
- **Inline comments**: XML docs (C#), docstrings (Python), JSDoc (JavaScript), comment-based help (PowerShell)
- **API documentation**: Endpoint specs with request/response examples, authentication, error codes
- **Component/class docs**: Properties, methods, usage examples, notes
- **README files**: Project overview, features, installation, usage, configuration

**Documentation Standards**:
- Includes real examples with realistic scenarios
- Documents the "why" and "when," not just the "what"
- Provides error handling documentation
- Includes troubleshooting guidance

---

### `/lint`

**Description**: Run appropriate linters and fix code quality issues.

**Usage**:
```bash
/lint
```

**Expected Behavior**:
1. Detects language/framework from project files
2. Runs appropriate linters:
   - C#/.NET: `dotnet build` with analyzers, `dotnet format`
   - Python: pylint, flake8, ruff, mypy, black, isort
   - JavaScript/TypeScript: ESLint, TypeScript compiler, Prettier
   - PowerShell: PSScriptAnalyzer
   - SQL: SQLFluff
3. Categorizes issues by type (error, warning, info) and auto-fixability
4. Provides fixes with explanations
5. Reports auto-fixable issues with command to fix

**Priority Framework**:
- **High**: Type errors, security vulnerabilities, runtime errors
- **Medium**: Missing type annotations, code smells, unused code
- **Low**: Formatting inconsistencies, comment style

**Notes**:
- Suggests linter configuration if not already set up
- Recommends pre-commit hooks and CI/CD integration

---

### `/code-optimize`

**Description**: Analyze and optimize code for performance, memory, and efficiency.

**Usage**:
```bash
/code-optimize
```

**Expected Behavior**:
1. Profiles code to identify bottlenecks (requires measurement first)
2. Analyzes hot paths (loops, frequently called methods, database queries)
3. Provides language-specific optimizations:
   - C#: Span<T>, async/await, LINQ alternatives, StringBuilder, ValueTask
   - Python: List comprehensions, generators, cached lookups
   - JavaScript: Debouncing, memoization, lazy loading
   - SQL: Indexes, batching, query optimization
4. Provides before/after benchmarks
5. Discusses trade-offs (speed vs. memory vs. maintainability)

**Philosophy**:
- Measure first, optimize second
- Focus on actual bottlenecks
- Maintain readability
- Benchmark improvements

**Notes**:
- Recommends profiling tools (BenchmarkDotNet, dotnet-trace, Chrome DevTools, etc.)
- Only optimizes code proven to be bottlenecks

---

### `/code-cleanup`

**Description**: Refactor and clean up code for better readability and maintainability.

**Usage**:
```bash
/code-cleanup
```

**Expected Behavior**:
1. Identifies code smells:
   - Naming issues (unclear, inconsistent)
   - Function design issues (too long, too many parameters)
   - DRY violations (duplicated code)
   - Complexity issues (nested conditionals, complex boolean expressions)
   - Dead code (unused methods, commented code)
   - Error handling issues (empty catch blocks, swallowing exceptions)
   - Magic numbers and strings
2. Applies appropriate refactorings:
   - Extract method
   - Introduce parameter object
   - Replace nested conditionals with guard clauses
   - Replace conditional with polymorphism
   - Remove dead code
   - Replace magic numbers with named constants
3. Uses language-specific modern patterns:
   - C#: Null-conditional operators, auto-properties, object initializers, string interpolation
   - Python: List comprehensions, context managers, tuple unpacking, enumerate
   - JavaScript/TypeScript: Arrow functions, spread operators, optional chaining, async/await
   - PowerShell: Named parameters, full cmdlet names, explicit output

**Principles**:
- Don't change behavior
- Make small, incremental changes
- Keep tests green
- Improve readability first

**Notes**:
- Provides before/after comparisons
- Explains why each refactoring improves the code

---

## Command Notes

**Model**: Most commands use `claude-sonnet-4-5` or `claude-sonnet-4-5-20250929`

**Allowed Tools**: Some commands restrict tool access for security (e.g., `/build-test` only allows dotnet build/test commands)

**Argument Hints**: Commands show expected arguments in square brackets when invoked

**Safety**: Commands follow safety protocols (git never force pushes to main, never skip hooks unless requested)
