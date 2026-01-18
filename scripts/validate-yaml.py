#!/usr/bin/env python3
import sys
import yaml
import json
from pathlib import Path

# Module-level constants
VALID_MODELS = ['claude-sonnet-4-5-20250929', 'claude-sonnet-4-5', 'sonnet']
VALID_COLORS = ['red', 'blue', 'green', 'yellow', 'orange', 'purple', 'cyan', 'teal', 'pink']

def extract_and_parse_frontmatter(file_path):
    """Extract and parse YAML frontmatter. Returns (frontmatter_dict, errors_list)."""
    errors = []

    with open(file_path, 'r') as f:
        content = f.read()

    if not content.startswith('---'):
        errors.append("Missing YAML frontmatter")
        return None, errors

    parts = content.split('---', 2)
    if len(parts) < 3:
        errors.append("Invalid YAML frontmatter structure")
        return None, errors

    try:
        frontmatter = yaml.safe_load(parts[1])
    except yaml.YAMLError as e:
        errors.append(f"YAML parse error: {e}")
        return None, errors

    return frontmatter, errors

def validate_command_yaml(file_path):
    """Validate YAML frontmatter in command file."""
    frontmatter, errors = extract_and_parse_frontmatter(file_path)
    if errors:
        return errors

    # Check required fields
    if 'description' not in frontmatter:
        errors.append("Missing required field: description")

    # Validate model if present
    if 'model' in frontmatter and frontmatter['model'] not in VALID_MODELS:
        errors.append(f"Invalid model: {frontmatter['model']}")

    return errors

def validate_agent_yaml(file_path):
    """Validate YAML frontmatter in agent file."""
    frontmatter, errors = extract_and_parse_frontmatter(file_path)
    if errors:
        return errors

    # Check required fields
    required_fields = ['name', 'description', 'model']
    for field in required_fields:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")

    # Validate model value
    if 'model' in frontmatter and frontmatter['model'] not in VALID_MODELS:
        errors.append(f"Invalid model: {frontmatter['model']}")

    # Validate color if present
    if 'color' in frontmatter and frontmatter['color'] not in VALID_COLORS:
        errors.append(f"Invalid color: {frontmatter['color']}")

    return errors

def main():
    # Validate commands
    commands_dir = Path('commands')
    command_results = {}

    for md_file in commands_dir.rglob('*.md'):
        errors = validate_command_yaml(md_file)
        command_results[str(md_file)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }

    # Validate agents
    agents_dir = Path('agents')
    agent_results = {}

    for md_file in agents_dir.rglob('*.md'):
        errors = validate_agent_yaml(md_file)
        agent_results[str(md_file)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }

    # Write results
    Path('validation-reports').mkdir(exist_ok=True)
    with open('validation-reports/commands-validation.json', 'w') as f:
        json.dump(command_results, f, indent=2)
    with open('validation-reports/agents-validation.json', 'w') as f:
        json.dump(agent_results, f, indent=2)

    # Print summary
    total_commands = len(command_results)
    valid_commands = sum(1 for r in command_results.values() if r['valid'])
    total_agents = len(agent_results)
    valid_agents = sum(1 for r in agent_results.values() if r['valid'])

    print(f"Commands validated: {valid_commands}/{total_commands} passed")
    print(f"Agents validated: {valid_agents}/{total_agents} passed")

    # Print errors
    all_valid = (valid_commands == total_commands and valid_agents == total_agents)
    if not all_valid:
        print("\nErrors found:")
        for file, result in {**command_results, **agent_results}.items():
            if not result['valid']:
                print(f"\n{file}:")
                for error in result['errors']:
                    print(f"  - {error}")
        sys.exit(1)

if __name__ == '__main__':
    main()
