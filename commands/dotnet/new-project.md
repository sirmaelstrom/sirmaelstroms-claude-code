---
description: Scaffold new .NET project with template selection
argument-hint: [template-name] [project-name]
model: claude-sonnet-4-5-20250929
allowed-tools: Bash(dotnet new:*), Bash(dotnet sln:*)
---

# .NET New Project Scaffolding

Create a new .NET project from a template with interactive or direct template selection.

**Arguments**: $ARGUMENTS

## Instructions

### If arguments are provided:
- $1 = template name (console, web, classlib, webapi, etc.)
- $2 = project name

### If no arguments are provided:

1. **List templates**:
   - Run `dotnet new list` to show available templates
   - Display common templates: console, classlib, web, webapi, mvc, blazor, xunit, nunit, mstest

2. **Get user input**:
   - Ask which template to use
   - Ask for project name
   - Ask for output path (default: current directory)

3. **Create project**:
   - Run `dotnet new <template> -n <name> -o <path>`
   - Report creation success with absolute path to created project

4. **Solution integration** (ask user):
   - Ask if they want to create a new solution or add to existing
   - If new solution: Run `dotnet new sln -n <name>` in parent directory
   - If existing: Ask for solution path
   - Run `dotnet sln add <project-path>` to add project to solution
   - If neither: skip solution step

5. **Summary**:
   - Report created project path
   - Report solution path (if created/modified)
   - List next steps (restore, build, run)

**Note**: Use absolute paths in all output.
