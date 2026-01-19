---
description: Build and test .NET solution/project with error reporting
argument-hint: [path-to-sln-or-csproj]
model: claude-sonnet-4-5-20250929
allowed-tools: Bash(dotnet build:*), Bash(dotnet test:*)
---

# .NET Build and Test

Execute `dotnet build` followed by `dotnet test` on the specified solution or project.

**Target**: $ARGUMENTS (if not provided, use current directory)

## Instructions

1. **Build phase**:
   - Run `dotnet build` on the target
   - Parse build output for errors and warnings
   - Report any build errors with:
     - File paths (absolute)
     - Line numbers
     - Error codes
     - Error messages
   - If build fails, stop and report errors; do not proceed to testing

2. **Test phase** (only if build succeeds):
   - Run `dotnet test` on the target
   - Report test results including:
     - Total tests run
     - Passed count
     - Failed count
     - Skipped count
   - For any test failures, report:
     - Test name
     - Failure message
     - Stack trace (if available)

3. **Summary**:
   - Provide concise summary of build and test results
   - Include exit codes
   - Report total duration if available

**Note**: If no target is specified, attempt to find a .sln or .csproj file in the current directory.
