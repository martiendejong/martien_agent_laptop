#!/usr/bin/env python3
"""
Scan complete ClickUp workspace structure and update config
"""
import json
import requests
from pathlib import Path
import sys
import io

# Force UTF-8 output
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# Load current config
config_path = Path(r"C:\scripts\_machine\clickup-config.json")
with open(config_path, 'r', encoding='utf-8-sig') as f:
    config = json.load(f)

API_KEY = config['api_key']
API_BASE = config['api_base']
headers = {
    'Authorization': API_KEY,
    'Content-Type': 'application/json'
}

def get_teams():
    """Get all teams/workspaces"""
    resp = requests.get(f"{API_BASE}/team", headers=headers)
    resp.raise_for_status()
    return resp.json()['teams']

def get_spaces(team_id):
    """Get all spaces in a team"""
    resp = requests.get(f"{API_BASE}/team/{team_id}/space", headers=headers)
    resp.raise_for_status()
    return resp.json()['spaces']

def get_folders(space_id):
    """Get all folders in a space"""
    resp = requests.get(f"{API_BASE}/space/{space_id}/folder", headers=headers)
    resp.raise_for_status()
    return resp.json()['folders']

def get_folderless_lists(space_id):
    """Get lists that aren't in folders"""
    resp = requests.get(f"{API_BASE}/space/{space_id}/list", headers=headers)
    resp.raise_for_status()
    return resp.json()['lists']

def get_lists_in_folder(folder_id):
    """Get all lists in a folder"""
    resp = requests.get(f"{API_BASE}/folder/{folder_id}/list", headers=headers)
    resp.raise_for_status()
    return resp.json()['lists']

def get_list_statuses(list_id):
    """Get statuses for a list"""
    resp = requests.get(f"{API_BASE}/list/{list_id}", headers=headers)
    resp.raise_for_status()
    list_data = resp.json()
    statuses = [s['status'] for s in list_data.get('statuses', [])]
    return statuses

print("Scanning ClickUp workspace structure...")
print("=" * 80)

teams = get_teams()
full_structure = {}

for team in teams:
    team_id = team['id']
    team_name = team['name']
    print(f"\nWORKSPACE: {team_name} (ID: {team_id})")

    full_structure[team_id] = {
        'name': team_name,
        'spaces': {}
    }

    spaces = get_spaces(team_id)

    for space in spaces:
        space_id = space['id']
        space_name = space['name']
        print(f"  SPACE: {space_name} (ID: {space_id})")

        full_structure[team_id]['spaces'][space_id] = {
            'name': space_name,
            'folders': {},
            'lists': {}
        }

        # Get folders
        try:
            folders = get_folders(space_id)
            for folder in folders:
                folder_id = folder['id']
                folder_name = folder['name']
                print(f"    FOLDER: {folder_name} (ID: {folder_id})")

                full_structure[team_id]['spaces'][space_id]['folders'][folder_id] = {
                    'name': folder_name,
                    'lists': {}
                }

                # Get lists in folder
                lists = get_lists_in_folder(folder_id)
                for list_item in lists:
                    list_id = list_item['id']
                    list_name = list_item['name']
                    task_count = list_item.get('task_count', 0)

                    print(f"      LIST: {list_name} (ID: {list_id}, Tasks: {task_count})")

                    # Get statuses
                    try:
                        statuses = get_list_statuses(list_id)
                        print(f"         Statuses: {', '.join(statuses)}")

                        full_structure[team_id]['spaces'][space_id]['folders'][folder_id]['lists'][list_id] = {
                            'name': list_name,
                            'task_count': task_count,
                            'statuses': statuses
                        }
                    except Exception as e:
                        print(f"         WARNING: Could not fetch statuses: {e}")
                        full_structure[team_id]['spaces'][space_id]['folders'][folder_id]['lists'][list_id] = {
                            'name': list_name,
                            'task_count': task_count
                        }
        except Exception as e:
            print(f"    WARNING: No folders or error: {e}")

        # Get folderless lists
        try:
            folderless_lists = get_folderless_lists(space_id)
            for list_item in folderless_lists:
                list_id = list_item['id']
                list_name = list_item['name']
                task_count = list_item.get('task_count', 0)

                print(f"    LIST (no folder): {list_name} (ID: {list_id}, Tasks: {task_count})")

                # Get statuses
                try:
                    statuses = get_list_statuses(list_id)
                    print(f"       Statuses: {', '.join(statuses)}")

                    full_structure[team_id]['spaces'][space_id]['lists'][list_id] = {
                        'name': list_name,
                        'task_count': task_count,
                        'statuses': statuses
                    }
                except Exception as e:
                    print(f"       WARNING: Could not fetch statuses: {e}")
                    full_structure[team_id]['spaces'][space_id]['lists'][list_id] = {
                        'name': list_name,
                        'task_count': task_count
                    }
        except Exception as e:
            print(f"    WARNING: No folderless lists or error: {e}")

print("\n" + "=" * 80)
print("SCAN COMPLETE!")

# Save full structure
output_path = Path(r"C:\scripts\_machine\clickup-full-structure.json")
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(full_structure, f, indent=2, ensure_ascii=False)

print(f"\nFull structure saved to: {output_path}")
print("\nSummary:")
for team_id, team_data in full_structure.items():
    print(f"  - {team_data['name']}: {len(team_data['spaces'])} spaces")
    for space_id, space_data in team_data['spaces'].items():
        folder_count = len(space_data['folders'])
        list_count = len(space_data['lists'])
        total_lists = list_count + sum(len(f['lists']) for f in space_data['folders'].values())
        print(f"    - {space_data['name']}: {folder_count} folders, {total_lists} lists")
