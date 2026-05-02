#!/usr/bin/env python3
"""Validate required fields in JSON plugin manifest files."""

import sys
import json
from pathlib import Path


def validate_json_required_fields(file_path: Path, required_fields: list[str]) -> list[str]:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        return [f"JSON parse error: {e}"]

    return [f"Missing required field: {field}" for field in required_fields if field not in data]


def main() -> None:
    results = {}

    targets = {
        '.claude-plugin/plugin.json': ['name', 'version', 'description', 'author'],
        '.claude-plugin/marketplace.json': ['plugins'],
    }

    for path_str, required_fields in targets.items():
        path = Path(path_str)
        if path.exists():
            errors = validate_json_required_fields(path, required_fields)
        else:
            errors = ['File does not exist']
        results[path_str] = {'valid': len(errors) == 0, 'errors': errors}

    Path('validation-reports').mkdir(exist_ok=True)
    with open('validation-reports/json-validation.json', 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2)

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
