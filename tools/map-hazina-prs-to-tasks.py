#!/usr/bin/env python3
"""
Map Hazina PRs to ClickUp tasks by analyzing PR titles and branch names.
"""
import subprocess
import re
import json

# Task IDs we're looking for
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

def get_all_prs():
    """Get all open PRs from Hazina repo."""
    result = subprocess.run(
        ['gh', 'pr', 'list', '--limit', '100', '--json', 'number,title,headRefName,url', '--color', 'never'],
        capture_output=True,
        text=True,
        cwd='C:/Projects/hazina',
        env={**subprocess.os.environ, 'NO_COLOR': '1'}
    )
    if result.returncode == 0:
        return json.loads(result.stdout)
    return []

def extract_task_id(text):
    """Extract task ID from text (PR title or branch name)."""
    # Look for patterns like 869cabf59, 869cfzy8e, etc.
    pattern = r'869[a-z0-9]{5,6}'
    matches = re.findall(pattern, text.lower())
    return matches

def main():
    print("=" * 80)
    print("MAPPING HAZINA PRs TO CLICKUP TASKS")
    print("=" * 80)

    prs = get_all_prs()
    print(f"\nFound {len(prs)} open PRs")

    # Create mapping
    task_to_pr = {}

    for pr in prs:
        # Check both title and branch name for task IDs
        title_ids = extract_task_id(pr['title'])
        branch_ids = extract_task_id(pr['headRefName'])
        all_ids = set(title_ids + branch_ids)

        for task_id in all_ids:
            if task_id in TASK_IDS:
                if task_id not in task_to_pr:
                    task_to_pr[task_id] = []
                task_to_pr[task_id].append({
                    'pr_number': pr['number'],
                    'pr_url': pr['url'],
                    'pr_title': pr['title'],
                    'branch': pr['headRefName']
                })

    print("\n" + "=" * 80)
    print("TASK TO PR MAPPING")
    print("=" * 80)

    for task_id in TASK_IDS:
        print(f"\nTask: {task_id}")
        if task_id in task_to_pr:
            for pr_info in task_to_pr[task_id]:
                print(f"  PR #{pr_info['pr_number']}: {pr_info['pr_title']}")
                print(f"  URL: {pr_info['pr_url']}")
                print(f"  Branch: {pr_info['branch']}")
        else:
            print(f"  NO PR FOUND")

    # Special handling for tasks without explicit IDs
    print("\n" + "=" * 80)
    print("MANUAL MAPPING NEEDED")
    print("=" * 80)

    unmapped = [tid for tid in TASK_IDS if tid not in task_to_pr]
    print(f"\nTasks without PR match: {len(unmapped)}")

    for task_id in unmapped:
        print(f"  - {task_id}")

    # Check for PRs that might be related by keyword
    print("\n" + "=" * 80)
    print("POTENTIAL MATCHES BY KEYWORD")
    print("=" * 80)

    keywords = {
        '869cg9e97': ['net version', 'dotnet version', 'standardize'],
        '869cfzy8e': ['phase 4', 'standardize', 'net version'],
        '869cfzy8b': ['phase 2', 'nuget', 'package'],
        '869cfzy8a': ['phase 1', 'audit', 'document'],
        '869ceq3aj': ['milestone 1.1', 'local agent', 'frontend'],
        '869cabf59': ['partialjsonparser', 'test coverage'],
        '869cabf56': ['benchmark', 'split', 'token'],
        '869cabf3t': ['config parsing', 'construction'],
        '869cabf3p': ['hardcoded paths', 'dependency injection', 'DI'],
        '869cabf3f': ['json schema', 'config'],
        '869cabf3d': ['safety defaults'],
    }

    for task_id in unmapped:
        if task_id in keywords:
            print(f"\nTask {task_id}:")
            task_keywords = keywords[task_id]
            for pr in prs:
                title_lower = pr['title'].lower()
                branch_lower = pr['headRefName'].lower()
                if any(kw.lower() in title_lower or kw.lower() in branch_lower for kw in task_keywords):
                    print(f"  POSSIBLE: PR #{pr['number']}: {pr['title']}")
                    print(f"    URL: {pr['url']}")
                    print(f"    Branch: {pr['headRefName']}")

    # Save results
    output = {
        'mapped': task_to_pr,
        'unmapped': unmapped
    }

    with open('C:/scripts/tools/_temp_hazina_pr_mapping.json', 'w') as f:
        json.dump(output, f, indent=2)

    print("\n" + "=" * 80)
    print(f"Results saved to: C:/scripts/tools/_temp_hazina_pr_mapping.json")
    print("=" * 80)

if __name__ == '__main__':
    main()
