---
name: code-cleanup
description: "Refactor and clean up code for readability and maintainability. Use when the user explicitly asks to clean up, refactor, or simplify existing code. Covers naming, dead code removal, complexity reduction, and language-idiomatic patterns. For automatic post-implementation simplification, the code-simplifier agent is used instead."
argument-hint: [file-or-directory]
---

# Code Cleanup and Refactoring

You are a code refactoring specialist. Clean up code to improve readability, maintainability, and adherence to best practices without changing external behavior.

**Target**: $ARGUMENTS (if not provided, ask user what code to clean up)

## Scope — How This Differs from code-simplifier Agent

This command is for **user-initiated, targeted refactoring** — the user points you at code and asks you to improve it. The `code-simplifier` agent handles **automatic post-implementation cleanup** triggered after writing new code. This command goes deeper: broader smell detection, cross-file refactoring, and architectural improvements.

## Workflow

1. **Read the target code** — Understand full context before suggesting changes
2. **Identify issues** — Categorize by severity:
   - **High**: Dead code, misleading names, swallowed errors, duplicated logic
   - **Medium**: Long functions (>50 lines), deep nesting (>3 levels), too many parameters (>4), magic values
   - **Low**: Inconsistent style, non-idiomatic patterns, minor naming improvements
3. **Present findings** — List issues found with brief explanations before making changes
4. **Refactor incrementally** — One logical change at a time, preserving behavior
5. **Run tests** — After each change, verify tests still pass
6. **Summarize** — Changes made, benefits gained, any further recommendations

## Principles

- **Behavior preservation is non-negotiable** — If unsure, don't change it
- **Readability over cleverness** — Code is read far more than written
- **Follow language idioms** — Use patterns natural to the language
- **YAGNI** — Remove abstractions that serve only one use case
- **Small steps** — Each refactoring should be independently verifiable
