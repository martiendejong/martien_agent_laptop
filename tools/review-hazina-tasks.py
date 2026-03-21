#!/usr/bin/env python3
"""
Comprehensive review of all Hazina framework tasks in review status.
"""
import json
import requests
import subprocess
import sys
import os
from pathlib import Path

# Task IDs to review
TASK_IDS = [
    '869cg9e97',  # All projects needs to use the same .net version
    '869cfzy8e',  # Phase 4: Standardize .NET Versions
    '869cfzy8d',  # Phase 3: Consolidation
    '869cfzy8b',  # Phase 2: NuGet Package Strategy
    '869cfzy8a',  # Phase 1: Audit & Document
    '869ceq3aj',  # Local Agent Platform Milestone 1.1
    '869cabf59',  # PartialJsonParser test coverage
    '869cabf56',  # Benchmark split/token counter
    '869cabf3t',  # Config parsing vs construction
    '869cabf3p',  # Remove hardcoded paths + DI
    '869cabf3f',  # JSON schema for config
    '869cabf3d',  # Safety defaults
    '869cjgt43',  # Update SemanticKernel.Connectors.OpenAI
    '869cabf4y',  # Transactional multi-file updates
]

# Load config
config_path = Path('C:/scripts/_machine/clickup-config.json')
with open(config_path, 'r', encoding='utf-8-sig') as f:
    config = json.load(f)

api_key = config['api_key']
api_base = config['api_base']

headers = {
    'Authorization': api_key,
    'Content-Type': 'application/json'
}

def get_task_details(task_id):
    """Fetch task details from ClickUp API."""
    url = f"{api_base}/task/{task_id}"
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def extract_pr_from_description(description):
    """Extract GitHub PR URL from task description."""
    if not description:
        return None

    # Look for GitHub PR URLs
    import re
    pr_pattern = r'https://github\.com/[^/]+/[^/]+/pull/\d+'
    matches = re.findall(pr_pattern, description)
    return matches[0] if matches else None

def get_branch_from_pr(pr_url):
    """Extract branch name from PR using gh CLI."""
    try:
        result = subprocess.run(
            ['gh', 'pr', 'view', pr_url, '--json', 'headRefName', '-q', '.headRefName'],
            capture_output=True,
            text=True,
            cwd='C:/Projects/hazina'
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except Exception as e:
        print(f"Error getting branch from PR: {e}")
    return None

def main():
    print("=" * 80)
    print("HAZINA FRAMEWORK - TASK REVIEW SESSION")
    print("=" * 80)
    print(f"\nReviewing {len(TASK_IDS)} tasks...\n")

    results = []

    for task_id in TASK_IDS:
        print(f"\n{'=' * 80}")
        print(f"Task ID: {task_id}")
        print('=' * 80)

        try:
            task = get_task_details(task_id)
            task_name = task['name']
            description = task.get('description', '')

            print(f"Name: {task_name}")
            print(f"Status: {task['status']['status']}")
            print(f"URL: {task['url']}")

            # CRITICAL GATE #1: Check for PR
            pr_url = extract_pr_from_description(description)

            if not pr_url:
                print("\n[X] CRITICAL FAILURE: No PR found in task description")
                results.append({
                    'task_id': task_id,
                    'task_name': task_name,
                    'status': 'FAILED',
                    'reason': 'NO_PR',
                    'action': 'Move to TODO with failure comment'
                })
                continue

            print(f"[OK] PR Found: {pr_url}")

            # Get branch name
            branch = get_branch_from_pr(pr_url)
            if not branch:
                print(f"[WARN] Could not determine branch name from PR")
                results.append({
                    'task_id': task_id,
                    'task_name': task_name,
                    'status': 'FAILED',
                    'reason': 'NO_BRANCH',
                    'action': 'Manual investigation needed'
                })
                continue

            print(f"[OK] Branch: {branch}")

            results.append({
                'task_id': task_id,
                'task_name': task_name,
                'pr_url': pr_url,
                'branch': branch,
                'status': 'READY_FOR_REVIEW',
                'action': 'Proceed with code review'
            })

        except Exception as e:
            print(f"\n[X] Error processing task: {e}")
            results.append({
                'task_id': task_id,
                'task_name': 'ERROR',
                'status': 'ERROR',
                'reason': str(e),
                'action': 'Manual investigation needed'
            })

    # Summary
    print("\n" + "=" * 80)
    print("REVIEW SUMMARY")
    print("=" * 80)

    ready_count = sum(1 for r in results if r['status'] == 'READY_FOR_REVIEW')
    failed_count = sum(1 for r in results if r['status'] == 'FAILED')
    error_count = sum(1 for r in results if r['status'] == 'ERROR')

    print(f"\nTotal tasks: {len(results)}")
    print(f"Ready for review: {ready_count}")
    print(f"Failed (no PR): {failed_count}")
    print(f"Errors: {error_count}")

    print("\n" + "=" * 80)
    print("DETAILED RESULTS")
    print("=" * 80)

    for result in results:
        print(f"\n{result['task_id']}: {result.get('task_name', 'N/A')}")
        print(f"  Status: {result['status']}")
        if result['status'] == 'READY_FOR_REVIEW':
            print(f"  PR: {result['pr_url']}")
            print(f"  Branch: {result['branch']}")
        print(f"  Action: {result['action']}")

    # Output JSON
    output_file = Path('C:/scripts/tools/_temp_hazina_review_results.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2)

    print(f"\n[OK] Results saved to: {output_file}")

if __name__ == '__main__':
    main()
