#!/usr/bin/env python3
"""
Move refined tasks to TODO status
"""
import json
import requests
from pathlib import Path
import sys
import io

# Force UTF-8 output
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# Load config
config_path = Path(r"C:\scripts\_machine\clickup-config.json")
with open(config_path, 'r', encoding='utf-8-sig') as f:
    config = json.load(f)

API_KEY = config['api_key']
API_BASE = config['api_base']
headers = {
    'Authorization': API_KEY,
    'Content-Type': 'application/json'
}

# Password Manager list ID
list_id = '901216204895'

print("Moving refined tasks to TODO...")
print("=" * 80)

# Get tasks in 'refined' status
resp = requests.get(
    f"{API_BASE}/list/{list_id}/task",
    headers=headers,
    params={
        'archived': 'false',
        'subtasks': 'false',
        'statuses[]': 'refined'
    }
)
resp.raise_for_status()
tasks = resp.json()['tasks']

print(f"\nFound {len(tasks)} task(s) in 'refined' status")

for task in tasks:
    task_id = task['id']
    task_name = task['name']

    print(f"\n  Moving: {task_name}")
    print(f"  ID: {task_id}")

    # Update task status to 'todo'
    update_resp = requests.put(
        f"{API_BASE}/task/{task_id}",
        headers=headers,
        json={'status': 'todo'}
    )
    update_resp.raise_for_status()

    print(f"  -> Moved to TODO")

print("\n" + "=" * 80)
print(f"Complete! Moved {len(tasks)} task(s) to TODO")
