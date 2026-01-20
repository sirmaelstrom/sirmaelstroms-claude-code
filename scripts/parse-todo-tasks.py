#!/usr/bin/env python3
"""Parse TODO.md files and count tasks by section for /sync-tasks command."""

import os
import re
import sys
from typing import Dict

# Compile regex pattern once for performance
# Only match tasks with NO indentation (true top-level)
CHECKBOX_PATTERN = re.compile(r'^- \[([ xX])\]')

# Section name constants
SECTION_ACTIVE = 'active'
SECTION_BLOCKED = 'blocked'
SECTION_IN_PROGRESS = 'in_progress'
SECTION_IDEAS = 'ideas'
SECTION_COMPLETED = 'completed'


def count_tasks(filename: str, max_size: int = 102400) -> Dict[str, int]:
    """Parse TODO.md and count tasks by section.

    Only counts top-level checkboxes (no indentation before dash).
    Nested checkboxes (any indentation) are ignored.
    Code blocks (fenced and indented) are skipped.

    Args:
        filename: Path to TODO.md file to parse
        max_size: Maximum file size in bytes (default: 100KB)

    Returns:
        Dictionary with integer counts for each section:
        - active: Unchecked tasks in Active sections
        - blocked: Unchecked tasks in Blocked sections
        - in_progress: Unchecked tasks in In Progress sections
        - ideas: Unchecked tasks in Ideas/Future sections
        - completed: Checked tasks in Completed sections

    Raises:
        FileNotFoundError: If file doesn't exist
        PermissionError: If file is not readable
        IsADirectoryError: If path is a directory
        UnicodeDecodeError: If file is not valid UTF-8
        ValueError: If file exceeds max_size
    """
    # Check file size before reading
    try:
        file_size = os.path.getsize(filename)
    except OSError as e:
        raise FileNotFoundError(f"Cannot access file: {e}") from e

    if file_size > max_size:
        raise ValueError(
            f"File too large ({file_size} bytes, limit {max_size} bytes)"
        )

    # Read file with explicit UTF-8 encoding
    with open(filename, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    results = {
        SECTION_ACTIVE: 0,
        SECTION_BLOCKED: 0,
        SECTION_IN_PROGRESS: 0,
        SECTION_IDEAS: 0,
        SECTION_COMPLETED: 0
    }

    current_section = None
    in_code_block = False

    for line in lines:
        # Expand tabs to 4 spaces for consistent indentation handling
        line = line.expandtabs(4)

        # Track code blocks (fenced: ``` or ~~~)
        if line.strip().startswith('```') or line.strip().startswith('~~~'):
            in_code_block = not in_code_block
            continue

        # Detect headings (level 2 only)
        if line.startswith('## ') and not in_code_block:
            heading = line[3:].strip().lower()

            # Map heading to section (case-insensitive, supports variants)
            if heading.startswith('active'):
                current_section = SECTION_ACTIVE
            elif heading.startswith('blocked'):
                current_section = SECTION_BLOCKED
            elif 'in progress' in heading:
                current_section = SECTION_IN_PROGRESS
            elif 'ideas' in heading or 'future' in heading:
                current_section = SECTION_IDEAS
            elif heading.startswith('completed'):
                current_section = SECTION_COMPLETED
            else:
                current_section = None
            continue

        # Count top-level checkboxes (no indentation)
        if current_section and not in_code_block:
            checkbox_match = CHECKBOX_PATTERN.match(line)
            if checkbox_match:
                checkbox = checkbox_match.group(1)

                # Count unchecked tasks in active sections
                if checkbox == ' ' and current_section in [
                    SECTION_ACTIVE, SECTION_BLOCKED,
                    SECTION_IN_PROGRESS, SECTION_IDEAS
                ]:
                    results[current_section] += 1
                # Count checked tasks in completed section
                elif checkbox in ['x', 'X'] and current_section == SECTION_COMPLETED:
                    results[current_section] += 1

    return results


def main() -> int:
    """Main entry point for command-line usage."""
    if len(sys.argv) != 2:
        print(
            f"Usage: {os.path.basename(sys.argv[0])} <file>",
            file=sys.stderr
        )
        return 1

    filename = sys.argv[1]

    try:
        results = count_tasks(filename)
    except FileNotFoundError:
        print(f"ERROR: File not found: {filename}", file=sys.stderr)
        return 1
    except PermissionError:
        print(f"ERROR: Permission denied: {filename}", file=sys.stderr)
        return 1
    except IsADirectoryError:
        print(f"ERROR: {filename} is a directory, not a file", file=sys.stderr)
        return 1
    except UnicodeDecodeError as e:
        print(
            f"ERROR: Invalid UTF-8 encoding in {filename}: {e}",
            file=sys.stderr
        )
        return 1
    except ValueError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"ERROR: Unexpected error: {e}", file=sys.stderr)
        return 2

    # Validate output format
    required_keys = [
        SECTION_ACTIVE, SECTION_BLOCKED, SECTION_IN_PROGRESS,
        SECTION_IDEAS, SECTION_COMPLETED
    ]
    if not all(key in results for key in required_keys):
        print("ERROR: Internal error - missing result keys", file=sys.stderr)
        return 2

    # Print results in pipe-separated format (stdout only)
    print(
        f"{results[SECTION_ACTIVE]}|"
        f"{results[SECTION_BLOCKED]}|"
        f"{results[SECTION_IN_PROGRESS]}|"
        f"{results[SECTION_IDEAS]}|"
        f"{results[SECTION_COMPLETED]}"
    )

    return 0


if __name__ == '__main__':
    sys.exit(main())
