#!/usr/bin/env python3
"""
Update clickup-config.json with newly discovered lists
"""
import json
from pathlib import Path
import sys
import io

# Force UTF-8 output
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# Load scanned structure
structure_path = Path(r"C:\scripts\_machine\clickup-full-structure.json")
with open(structure_path, 'r', encoding='utf-8') as f:
    full_structure = json.load(f)

# Load current config
config_path = Path(r"C:\scripts\_machine\clickup-config.json")
with open(config_path, 'r', encoding='utf-8-sig') as f:
    config = json.load(f)

print("Updating ClickUp config with newly discovered lists...")
print("=" * 80)

# Focus on GigsHub Workspace > Team Tasks (this is where most projects are)
gigshub_id = '9012956001'
team_tasks_id = '90124247049'

if gigshub_id in full_structure and team_tasks_id in full_structure[gigshub_id]['spaces']:
    space_data = full_structure[gigshub_id]['spaces'][team_tasks_id]

    print(f"\nProcessing Team Tasks space...")

    # Update projects section
    if 'projects' not in config:
        config['projects'] = {}

    # Process Internal Projects folder
    for folder_id, folder_data in space_data['folders'].items():
        folder_name = folder_data['name']

        if folder_name == 'Internal Projects':
            print(f"\n  Folder: {folder_name}")

            for list_id, list_data in folder_data['lists'].items():
                list_name = list_data['name']
                task_count = list_data.get('task_count', 0)
                statuses = list_data.get('statuses', [])

                print(f"    - {list_name} (ID: {list_id}, Tasks: {task_count})")

                # Map list names to project keys
                project_key_map = {
                    'Brand Designer': 'client-manager',
                    'Hazina Framework': 'hazina',
                    'Real Estate Agency AI': 'bliek',
                    'Codehub': 'codehub',
                    'SEO God': 'seo-god',
                    'Whatsapp Bridge': 'whatsapp-bridge',
                    'Translation Manager WP plugin': 'simple-translation-manager',
                    'DataDrivenAI': 'datadrivenai',
                    'Password Manager': 'password-manager',
                    'Hazina Terminal Orchestration Service': 'hazina-orchestration',
                    'Visual Studio Bridge': 'vs-bridge',
                }

                if list_name in project_key_map:
                    project_key = project_key_map[list_name]

                    # Update or create project entry
                    if project_key not in config['projects']:
                        config['projects'][project_key] = {
                            'name': list_name,
                            'list_id': list_id,
                            'repos': []
                        }
                        print(f"      -> ADDED new project: {project_key}")
                    else:
                        # Update existing
                        config['projects'][project_key]['list_id'] = list_id
                        config['projects'][project_key]['name'] = list_name
                        print(f"      -> UPDATED existing project: {project_key}")

                    # Add statuses if present
                    if statuses:
                        config['projects'][project_key]['statuses'] = statuses

        elif folder_name == 'Client Projects':
            print(f"\n  Folder: {folder_name}")

            for list_id, list_data in folder_data['lists'].items():
                list_name = list_data['name']
                task_count = list_data.get('task_count', 0)
                statuses = list_data.get('statuses', [])

                print(f"    - {list_name} (ID: {list_id}, Tasks: {task_count})")

                # Map client projects
                project_key_map = {
                    'Art Revisionist Project': 'art-revisionist',
                    'Bugatti Insights': 'bugatti-insights',
                }

                if list_name in project_key_map:
                    project_key = project_key_map[list_name]

                    if project_key not in config['projects']:
                        config['projects'][project_key] = {
                            'name': list_name,
                            'list_id': list_id,
                            'repos': []
                        }
                        print(f"      -> ADDED new project: {project_key}")
                    else:
                        config['projects'][project_key]['list_id'] = list_id
                        config['projects'][project_key]['name'] = list_name
                        print(f"      -> UPDATED existing project: {project_key}")

                    if statuses:
                        config['projects'][project_key]['statuses'] = statuses

        elif folder_name == 'Client Websites':
            print(f"\n  Folder: {folder_name}")

            for list_id, list_data in folder_data['lists'].items():
                list_name = list_data['name']
                task_count = list_data.get('task_count', 0)
                print(f"    - {list_name} (ID: {list_id}, Tasks: {task_count})")

        elif folder_name == 'Internal Websites':
            print(f"\n  Folder: {folder_name}")

            for list_id, list_data in folder_data['lists'].items():
                list_name = list_data['name']
                task_count = list_data.get('task_count', 0)
                print(f"    - {list_name} (ID: {list_id}, Tasks: {task_count})")

        elif folder_name == 'Management':
            print(f"\n  Folder: {folder_name}")

            for list_id, list_data in folder_data['lists'].items():
                list_name = list_data['name']
                task_count = list_data.get('task_count', 0)
                print(f"    - {list_name} (ID: {list_id}, Tasks: {task_count})")

# Update last_updated timestamp
from datetime import datetime
config['last_updated'] = datetime.now().strftime('%Y-%m-%d')

# Save updated config
with open(config_path, 'w', encoding='utf-8') as f:
    json.dump(config, f, indent=4, ensure_ascii=False)

print("\n" + "=" * 80)
print(f"Config updated successfully: {config_path}")
print(f"\nTotal projects in config: {len(config['projects'])}")
