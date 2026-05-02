#!/usr/bin/env python3
"""Validate YAML frontmatter in command and agent markdown files."""
import sys
import yaml
import json
from pathlib import Path

# Module-level constants
VALID_MODELS = ['sonnet', 'opus', 'haiku']
VALID_COLORS = ['red', 'blue', 'green', 'yellow', 'orange', 'purple', 'cyan', 'teal', 'pink']


def extract_and_parse_frontmatter(file_path: Path) -> tuple[dict[str, object] | None, list[str]]:
    errors: list[str] = []

    with open(file_path, 'r', encoding='utf-8') as f:
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


def missing_fields(frontmatter: dict[str, object], required: list[str]) -> list[str]:
    return [f"Missing required field: {field}" for field in required if field not in frontmatter]


def validate_command_yaml(file_path: Path) -> list[str]:
    frontmatter, errors = extract_and_parse_frontmatter(file_path)
    if errors or frontmatter is None:
        return errors

    errors += missing_fields(frontmatter, ['description'])
    if 'model' in frontmatter and frontmatter['model'] not in VALID_MODELS:
        errors.append(f"Invalid model: {frontmatter['model']}")

    return errors


def validate_agent_yaml(file_path: Path) -> list[str]:
    frontmatter, errors = extract_and_parse_frontmatter(file_path)
    if errors or frontmatter is None:
        return errors

    errors += missing_fields(frontmatter, ['name', 'description', 'model'])
    if 'model' in frontmatter and frontmatter['model'] not in VALID_MODELS:
        errors.append(f"Invalid model: {frontmatter['model']}")
    if 'color' in frontmatter and frontmatter['color'] not in VALID_COLORS:
        errors.append(f"Invalid color: {frontmatter['color']}")

    return errors


def main() -> None:
    commands_dir = Path('commands')
    command_results = {}

    for md_file in commands_dir.rglob('*.md'):
        errors = validate_command_yaml(md_file)
        command_results[str(md_file)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }

    agents_dir = Path('agents')
    agent_results = {}

    for md_file in agents_dir.rglob('*.md'):
        errors = validate_agent_yaml(md_file)
        agent_results[str(md_file)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }

    Path('validation-reports').mkdir(exist_ok=True)
    with open('validation-reports/commands-validation.json', 'w', encoding='utf-8') as f:
        json.dump(command_results, f, indent=2)
    with open('validation-reports/agents-validation.json', 'w', encoding='utf-8') as f:
        json.dump(agent_results, f, indent=2)

    total_commands = len(command_results)
    valid_commands = sum(1 for r in command_results.values() if r['valid'])
    total_agents = len(agent_results)
    valid_agents = sum(1 for r in agent_results.values() if r['valid'])

    print(f"Commands validated: {valid_commands}/{total_commands} passed")
    print(f"Agents validated: {valid_agents}/{total_agents} passed")

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
