#!/usr/bin/env python3
import re
import sys

def count_tasks(filename):
    """Parse TODO.md and count tasks by section.
    
    Only counts top-level checkboxes (lines starting with ^- [ ] or ^- [xX]).
    Nested checkboxes (with indentation) are ignored.
    """
    
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    results = {
        'active': 0,
        'blocked': 0,
        'in_progress': 0,
        'ideas': 0,
        'completed': 0
    }
    
    current_section = None
    in_code_block = False
    
    for line in lines:
        # Track code blocks
        if line.strip().startswith('```') or line.strip().startswith('~~~'):
            in_code_block = not in_code_block
            continue
        
        # Detect headings (level 2 only)
        if line.startswith('## ') and not in_code_block:
            heading = line[3:].strip().lower()
            
            # Map heading to section
            if heading.startswith('active'):
                current_section = 'active'
            elif heading.startswith('blocked'):
                current_section = 'blocked'
            elif 'in progress' in heading:
                current_section = 'in_progress'
            elif 'ideas' in heading or 'future' in heading:
                current_section = 'ideas'
            elif heading.startswith('completed'):
                current_section = 'completed'
            else:
                current_section = None
            continue
        
        # Count ONLY top-level checkboxes (no leading whitespace before dash)
        # Pattern: ^- [ ] or ^- [xX] (no spaces before dash)
        if current_section and not in_code_block:
            # Top-level checkbox: starts with dash at column 0
            if line.startswith('- ['):
                checkbox_match = re.match(r'^- \[([ xX])\]', line)
                if checkbox_match:
                    checkbox = checkbox_match.group(1)
                    
                    if checkbox == ' ' and current_section in ['active', 'blocked', 'in_progress', 'ideas']:
                        results[current_section] += 1
                    elif checkbox in ['x', 'X'] and current_section == 'completed':
                        results[current_section] += 1
    
    return results

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: parse_todo.py <file>")
        sys.exit(1)
    
    results = count_tasks(sys.argv[1])
    
    # Print results in pipe-separated format
    print(f"{results['active']}|{results['blocked']}|{results['in_progress']}|{results['ideas']}|{results['completed']}")
