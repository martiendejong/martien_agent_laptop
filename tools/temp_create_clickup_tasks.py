import json, os, requests, sys, time

# Load API key
config_path = os.path.join("C:", os.sep, "scripts", "_machine", "clickup-config.json")
with open(config_path, "r") as f:
    config = json.load(f)

API_KEY = config["api_key"]
LIST_ID = "901216187878"
ASSIGNEE_ID = 74525428
BASE_URL = "https://api.clickup.com/api/v2"
HEADERS = {"Authorization": API_KEY, "Content-Type": "application/json"}

# Load task definitions from JSON data file
tasks_path = os.path.join("C:", os.sep, "scripts", "tools", "_temp_tasks_data.json")
with open(tasks_path, "r", encoding="utf-8") as f:
    tasks = json.load(f)

def create_task(task_data, index, total):
    payload = {
        "name": task_data["name"],
        "description": task_data["description"],
        "assignees": [ASSIGNEE_ID],
        "tags": task_data["tags"],
        "status": "backlog",
        "priority": task_data["priority"],
    }
    url = f"{BASE_URL}/list/{LIST_ID}/task"
    try:
        response = requests.post(url, headers=HEADERS, json=payload, timeout=30)
        response.raise_for_status()
        result = response.json()
        task_id = result.get("id", "UNKNOWN")
        tname = task_data["name"]
        print(f"[{index:2d}/{total}] CREATED: {tname}")
        print(f"         Task ID: {task_id}")
        print(f"         Status:  {response.status_code}")
        print()
        return task_id
    except requests.exceptions.HTTPError as e:
        tname = task_data["name"]
        print(f"[{index:2d}/{total}] FAILED:  {tname}")
        print(f"         Error:   {e}")
        try:
            print(f"         Response: {response.text[:500]}")
        except Exception:
            pass
        print()
        return None
    except Exception as e:
        tname = task_data["name"]
        print(f"[{index:2d}/{total}] ERROR:   {tname}")
        print(f"         Error:   {e}")
        print()
        return None

def main():
    total = len(tasks)
    print("=" * 70)
    print(f"Creating {total} DataDrivenAI Refinement Agent tasks on ClickUp")
    print(f"List ID: {LIST_ID} | Assignee: {ASSIGNEE_ID}")
    print("=" * 70)
    print()
    created = []
    failed = []
    for i, task in enumerate(tasks, 1):
        task_id = create_task(task, i, total)
        if task_id:
            created.append((task["name"], task_id))
        else:
            failed.append(task["name"])
        if i < total:
            time.sleep(0.5)
    print("=" * 70)
    print(f"SUMMARY: {len(created)} created, {len(failed)} failed")
    print("=" * 70)
    if created:
        print()
        print("Created tasks:")
        for name, tid in created:
            print(f"  - {tid}: {name}")
    if failed:
        print()
        print("Failed tasks:")
        for name in failed:
            print(f"  - {name}")
    print()
    return 0 if not failed else 1

if __name__ == "__main__":
    sys.exit(main())
