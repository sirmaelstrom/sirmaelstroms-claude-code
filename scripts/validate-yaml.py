#!/usr/bin/env python3
import sys
import yaml
import json
from pathlib import Path

def validate_command_yaml(file_path):
    """Validate YAML frontmatter in command file."""
    errors = []

    with open(file_path, 'r') as f:
        content = f.read()

    # Check for YAML frontmatter
    if not content.startswith('---'):
        errors.append(f"Missing YAML frontmatter")
        return errors

    # Extract frontmatter
    parts = content.split('---', 2)
    if len(parts) < 3:
        errors.append(f"Invalid YAML frontmatter structure")
        return errors

    # Parse YAML
    try:
        frontmatter = yaml.safe_load(parts[1])
    except yaml.YAMLError as e:
        errors.append(f"YAML parse error: {e}")
        return errors

    # Validate required fields
    required_fields = ['description']
    for field in required_fields:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    # Validate optional fields
    if 'model' in frontmatter:
        valid_models = ['claude-sonnet-4-5-20250929', 'claude-sonnet-4-5', 'sonnet']
        if frontmatter['model'] not in valid_models:
            errors.append(f"Invalid model: {frontmatter['model']}")

    return errors

def main():
    commands_dir = Path('commands')
    results = {}

    for md_file in commands_dir.rglob('*.md'):
        errors = validate_command_yaml(md_file)
        results[str(md_file)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }

    # Write results
    Path('validation-reports').mkdir(exist_ok=True)
    with open('validation-reports/commands-validation.json', 'w') as f:
        json.dump(results, f, indent=2)

    # Print summary
    total = len(results)
    valid = sum(1 for r in results.values() if r['valid'])
    print(f"Commands validated: {valid}/{total} passed")

    if valid < total:
        print("\nErrors found:")
        for file, result in results.items():
            if not result['valid']:
                print(f"\n{file}:")
                for error in result['errors']:
                    print(f"  - {error}")
        sys.exit(1)

if __name__ == '__main__':
    main()
