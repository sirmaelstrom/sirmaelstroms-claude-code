#!/usr/bin/env python3
import sys
import json
from pathlib import Path

def validate_plugin_json(file_path):
    """Validate plugin.json structure."""
    errors = []

    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        errors.append(f"JSON parse error: {e}")
        return errors

    # Required fields
    required_fields = ['name', 'version', 'description', 'author', 'commands', 'agents']
    for field in required_fields:
        if field not in data:
            errors.append(f"Missing required field: {field}")

    # Validate commands
    if 'commands' in data:
        for i, cmd in enumerate(data['commands']):
            if 'name' not in cmd:
                errors.append(f"Command {i}: missing name")
            if 'path' not in cmd:
                errors.append(f"Command {i}: missing path")
            elif not Path(cmd['path']).exists():
                errors.append(f"Command {i}: path does not exist: {cmd['path']}")
            if 'description' not in cmd:
                errors.append(f"Command {i}: missing description")

    # Validate agents
    if 'agents' in data:
        for i, agent in enumerate(data['agents']):
            if 'name' not in agent:
                errors.append(f"Agent {i}: missing name")
            if 'path' not in agent:
                errors.append(f"Agent {i}: missing path")
            elif not Path(agent['path']).exists():
                errors.append(f"Agent {i}: path does not exist: {agent['path']}")
            if 'description' not in agent:
                errors.append(f"Agent {i}: missing description")

    return errors

def validate_marketplace_json(file_path):
    """Validate marketplace.json structure."""
    errors = []

    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        errors.append(f"JSON parse error: {e}")
        return errors

    # Required fields
    required_fields = ['marketplaceName', 'plugins']
    for field in required_fields:
        if field not in data:
            errors.append(f"Missing required field: {field}")

    return errors

def main():
    results = {}

    # Validate plugin.json
    plugin_json = Path('.claude-plugin/plugin.json')
    if plugin_json.exists():
        errors = validate_plugin_json(plugin_json)
        results[str(plugin_json)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }
    else:
        results[str(plugin_json)] = {
            'valid': False,
            'errors': ['File does not exist']
        }

    # Validate marketplace.json
    marketplace_json = Path('.claude-plugin/marketplace.json')
    if marketplace_json.exists():
        errors = validate_marketplace_json(marketplace_json)
        results[str(marketplace_json)] = {
            'valid': len(errors) == 0,
            'errors': errors
        }
    else:
        results[str(marketplace_json)] = {
            'valid': False,
            'errors': ['File does not exist']
        }

    # Write results
    Path('validation-reports').mkdir(exist_ok=True)
    with open('validation-reports/json-validation.json', 'w') as f:
        json.dump(results, f, indent=2)

    # Print summary
    total = len(results)
    valid = sum(1 for r in results.values() if r['valid'])
    print(f"JSON files validated: {valid}/{total} passed")

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
