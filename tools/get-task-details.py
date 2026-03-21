#!/usr/bin/env python3
"""Get task details for specific task IDs."""
import json
import requests
import sys

# Load config
with open('C:/scripts/_machine/clickup-config.json', 'r', encoding='utf-8-sig') as f:
    config = json.load(f)

api_key = config['api_key']
api_base = config['api_base']

headers = {
    'Authorization': api_key,
    'Content-Type': 'application/json'
}

task_ids = [
    '869cabf3d',  # Safety defaults
    '869cabf3f',  # JSON schema for config
    '869cabf3p',  # Remove hardcoded paths + DI
    '869cabf3t',  # Config parsing vs construction
    '869cabf56',  # Benchmark split/token counter
    '869cabf59',  # PartialJsonParser test coverage
    '869ceq3aj',  # Local Agent Platform
    '869cfzy8b',  # Phase 2: NuGet Package Strategy
]

for task_id in task_ids:
    print(f"\n{'=' * 80}")
    print(f"Task ID: {task_id}")
    print('=' * 80)

    try:
        url = f"{api_base}/task/{task_id}"
        response = requests.get(url, headers=headers)
        response.raise_for_status()

        task = response.json()
        print(f"Name: {task['name']}")
        print(f"Status: {task['status']['status']}")

        description = task.get('description', '').strip()
        if description:
            print(f"\nDescription ({len(description)} chars):")
            # Print first 500 chars
            if len(description) > 500:
                print(description[:500] + "...")
            else:
                print(description)
        else:
            print("\nNo description")

    except Exception as e:
        print(f"Error: {e}")
