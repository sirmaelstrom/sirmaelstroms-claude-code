---
description: Search and add NuGet packages to .NET project
argument-hint: "[package-name] [version]"
model: claude-sonnet-4-5-20250929
allowed-tools: Bash(dotnet add package:*), Bash(dotnet list package:*), WebSearch
---

# .NET NuGet Package Addition

Search for and add NuGet packages to a .NET project with version selection.

**Arguments**: $ARGUMENTS

## Instructions

### If full arguments provided:
- $1 = package name
- $2 = version (optional)
- Skip search, proceed directly to installation

### If only package name provided or no arguments:

1. **Search for package**:
   - If no package name: ask user for package name
   - Use web search to find package on nuget.org
   - Show package description and download count
   - List available versions (latest stable, latest preview, recent versions)

2. **Get project path**:
   - Ask which project to add the package to (provide .csproj path)
   - If only one .csproj in current directory, use that by default (ask for confirmation)

3. **Version selection**:
   - If version not specified in arguments, ask user:
     - Use latest stable (default)
     - Use latest preview
     - Specify exact version
   - Show selected version before proceeding

4. **Install package**:
   - Run `dotnet add <project> package <package-name>` (for latest)
   - Or `dotnet add <project> package <package-name> --version <version>` (for specific)
   - Report installation progress

5. **Verify installation**:
   - Run `dotnet list <project> package` to confirm package was added
   - Show the installed package and version

6. **Summary**:
   - Report package name and version installed
   - Report target project path (absolute)
   - Note if restore is needed (usually automatic)

**Examples**:
- `/add-package` - Interactive mode, will prompt for all inputs
- `/add-package Newtonsoft.Json` - Search and select version interactively
- `/add-package Newtonsoft.Json 13.0.3` - Install specific version directly

**Note**: Use absolute paths for project files in all output.
