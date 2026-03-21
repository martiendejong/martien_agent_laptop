#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Find all tasks in review status across all ClickUp boards.
"""
import json
import requests
import sys
import io

# Force UTF-8 output
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# Load config
with open('C:/scripts/_machine/clickup-config.json', 'r', encoding='utf-8-sig') as f:
    config = json.load(f)

api_key = config['api_key']
api_base = config['api_base']

headers = {
    'Authorization': api_key,
    'Content-Type': 'application/json'
}

# Define boards to scan
boards = [
    {'name': 'Brand Designer', 'list_id': '901214097647', 'project': 'client-manager'},
    {'name': 'Art Revisionist', 'list_id': '901211612245', 'project': 'art-revisionist'},
    {'name': 'Hazina Framework', 'list_id': '901215559249', 'project': 'hazina'},
    {'name': 'DataDrivenAI', 'list_id': '901216187878', 'project': 'datadrivenai'},
    {'name': 'SEO God', 'list_id': '901215927087', 'project': 'seo-god'},
    {'name': 'STM Plugin', 'list_id': '901216036563', 'project': 'simple-translation-manager'},
    {'name': 'Personality Test', 'list_id': '901216266641', 'project': 'personalitytest'},
]

all_review_tasks = []

print(f"\nScanning {len(boards)} boards for tasks in review status...\n")

for board in boards:
    print(f"Scanning: {board['name']}...", end=' ', flush=True)

    try:
        url = f"{api_base}/list/{board['list_id']}/task?archived=false&include_closed=false"
        response = requests.get(url, headers=headers)
        response.raise_for_status()

        data = response.json()
        tasks = data.get('tasks', [])

        # Filter for review status (case-insensitive)
        review_tasks = [t for t in tasks if 'review' in t.get('status', {}).get('status', '').lower()]

        if review_tasks:
            print(f"✓ Found {len(review_tasks)} task(s) in review")
            for task in review_tasks:
                all_review_tasks.append({
                    'board_name': board['name'],
                    'project': board['project'],
                    'task_id': task['id'],
                    'task_name': task['name'],
                    'status': task['status']['status'],
                    'url': task['url']
                })
        else:
            print(f"- No tasks in review")

    except Exception as e:
        print(f"✗ Error: {e}")

print("\n" + "=" * 80)
print(f"SUMMARY: Found {len(all_review_tasks)} total task(s) in review status")
print("=" * 80 + "\n")

if all_review_tasks:
    for task in all_review_tasks:
        print(f"[{task['board_name']}] {task['task_name']}")
        print(f"  ID: {task['task_id']}")
        print(f"  Status: {task['status']}")
        print(f"  URL: {task['url']}")
        print()

    # Output as JSON for programmatic use
    print("\n" + "=" * 80)
    print("JSON OUTPUT:")
    print("=" * 80)
    print(json.dumps(all_review_tasks, indent=2))
else:
    print("No tasks in review status found across all boards.")
    sys.exit(0)
