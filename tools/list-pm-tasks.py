"""List Password Manager tasks"""
import requests
import json

api_key = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
list_id = "901216204895"

response = requests.get(
    f"https://api.clickup.com/api/v2/list/{list_id}/task",
    headers={"Authorization": api_key}
)

data = response.json()
tasks = data.get('tasks', [])

print(f'Password Manager Board: {len(tasks)} tasks')
print('='*80)

for i, task in enumerate(tasks[:25], 1):
    name = task['name'][:75]
    status = task['status']['status']
    task_id = task['id']
    print(f'{i}. [{status}] {name}')
    print(f'   ID: {task_id}')
    print()

# Check for CORS-related tasks
cors_tasks = [t for t in tasks if 'cors' in t['name'].lower() or 'extension' in t['name'].lower() and 'blocked' in t['name'].lower()]
ssl_tasks = [t for t in tasks if 'ssl' in t['name'].lower() or 'certificate' in t['name'].lower()]

print('\nCORS/Extension Issues:', len(cors_tasks))
print('SSL/Certificate Tasks:', len(ssl_tasks))
