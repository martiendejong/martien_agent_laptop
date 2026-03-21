#!/usr/bin/env python3
"""Post failure comments to Hazina tasks without PRs and move them to TODO."""
import json
import requests

# Load config
with open('C:/scripts/_machine/clickup-config.json', 'r', encoding='utf-8-sig') as f:
    config = json.load(f)

api_key = config['api_key']
api_base = config['api_base']

headers = {
    'Authorization': api_key,
    'Content-Type': 'application/json'
}

# Tasks without PRs
tasks_without_prs = [
    {
        'id': '869cfzy8b',
        'name': 'Phase 2: NuGet Package Strategy',
        'comment': '''## CODE REVIEW - CRITICAL FAILURE

**Status:** FAILED - No PR Found

**Critical Issue:**
- Task is in REVIEW status but NO GitHub Pull Request was found
- This violates Pattern 116 (POST-IMPLEMENTATION VERIFICATION gate)
- Cannot review code that hasn't been committed/pushed

**Required Actions:**
1. Create feature branch for this work
2. Implement the NuGet package strategy
3. Push commits to GitHub
4. Create Pull Request
5. Add PR link to this task description (format: https://github.com/.../pull/###)
6. Move task back to REVIEW

**Note:** If this is a planning/documentation task without code changes, the task should be in a different status (not REVIEW) or the deliverables should be clarified.

Task moved back to TODO for implementation.'''
    },
    {
        'id': '869ceq3aj',
        'name': 'Local Agent Platform Milestone 1.1',
        'comment': '''## CODE REVIEW - CRITICAL FAILURE

**Status:** FAILED - No PR Found

**Critical Issue:**
- Task is in REVIEW status but NO GitHub Pull Request was found
- This violates Pattern 116 (POST-IMPLEMENTATION VERIFICATION gate)
- Cannot review code that hasn't been committed/pushed

**Required Actions:**
1. Create feature branch for this work
2. Implement the Local Agent Platform features (Frontend + Schema UI + Agent Runtime)
3. Push commits to GitHub
4. Create Pull Request
5. Add PR link to this task description (format: https://github.com/.../pull/###)
6. Move task back to REVIEW

Task moved back to TODO for implementation.'''
    },
    {
        'id': '869cabf59',
        'name': 'PartialJsonParser test coverage',
        'comment': '''## CODE REVIEW - CRITICAL FAILURE

**Status:** FAILED - No PR Found

**Critical Issue:**
- Task is in REVIEW status but NO GitHub Pull Request was found
- This violates Pattern 116 (POST-IMPLEMENTATION VERIFICATION gate)
- Cannot review code that hasn't been committed/pushed

**Required Actions:**
1. Create feature branch for this work
2. Add comprehensive unit tests for PartialJsonParser edge cases
3. Push commits to GitHub
4. Create Pull Request
5. Add PR link to this task description (format: https://github.com/.../pull/###)
6. Move task back to REVIEW

Task moved back to TODO for implementation.'''
    },
    {
        'id': '869cabf56',
        'name': 'Benchmark split/token counter',
        'comment': '''## CODE REVIEW - CRITICAL FAILURE

**Status:** FAILED - No PR Found

**Critical Issue:**
- Task is in REVIEW status but NO GitHub Pull Request was found
- This violates Pattern 116 (POST-IMPLEMENTATION VERIFICATION gate)
- Cannot review code that hasn't been committed/pushed

**Required Actions:**
1. Create feature branch for this work
2. Implement benchmarks for DocumentSplitter and TokenCounter
3. Push commits to GitHub
4. Create Pull Request
5. Add PR link to this task description (format: https://github.com/.../pull/###)
6. Move task back to REVIEW

Task moved back to TODO for implementation.'''
    },
    {
        'id': '869cabf3t',
        'name': 'Config parsing vs construction',
        'comment': '''## CODE REVIEW - CRITICAL FAILURE

**Status:** FAILED - No PR Found

**Critical Issue:**
- Task is in REVIEW status but NO GitHub Pull Request was found
- This violates Pattern 116 (POST-IMPLEMENTATION VERIFICATION gate)
- Cannot review code that hasn't been committed/pushed

**Required Actions:**
1. Create feature branch for this work
2. Separate config parsing from object construction
3. Push commits to GitHub
4. Create Pull Request
5. Add PR link to this task description (format: https://github.com/.../pull/###)
6. Move task back to REVIEW

Task moved back to TODO for implementation.'''
    },
    {
        'id': '869cabf3p',
        'name': 'Remove hardcoded paths + DI',
        'comment': '''## CODE REVIEW - CRITICAL FAILURE

**Status:** FAILED - No PR Found

**Critical Issue:**
- Task is in REVIEW status but NO GitHub Pull Request was found
- This violates Pattern 116 (POST-IMPLEMENTATION VERIFICATION gate)
- Cannot review code that hasn't been committed/pushed

**Required Actions:**
1. Create feature branch for this work
2. Inject IFileSystem/IClock and remove hardcoded paths
3. Push commits to GitHub
4. Create Pull Request
5. Add PR link to this task description (format: https://github.com/.../pull/###)
6. Move task back to REVIEW

Task moved back to TODO for implementation.'''
    },
    {
        'id': '869cabf3f',
        'name': 'JSON schema for config',
        'comment': '''## CODE REVIEW - CRITICAL FAILURE

**Status:** FAILED - No PR Found

**Critical Issue:**
- Task is in REVIEW status but NO GitHub Pull Request was found
- This violates Pattern 116 (POST-IMPLEMENTATION VERIFICATION gate)
- Cannot review code that hasn't been committed/pushed

**Required Actions:**
1. Create feature branch for this work
2. Generate JSON schemas for Stores/Agents/Flows
3. Push commits to GitHub
4. Create Pull Request
5. Add PR link to this task description (format: https://github.com/.../pull/###)
6. Move task back to REVIEW

Task moved back to TODO for implementation.'''
    },
    {
        'id': '869cabf3d',
        'name': 'Safety defaults',
        'comment': '''## CODE REVIEW - CRITICAL FAILURE

**Status:** FAILED - No PR Found

**Critical Issue:**
- Task is in REVIEW status but NO GitHub Pull Request was found
- This violates Pattern 116 (POST-IMPLEMENTATION VERIFICATION gate)
- Cannot review code that hasn't been committed/pushed

**Required Actions:**
1. Create feature branch for this work
2. Implement safety defaults (read-only stores, size/extension limits)
3. Push commits to GitHub
4. Create Pull Request
5. Add PR link to this task description (format: https://github.com/.../pull/###)
6. Move task back to REVIEW

Task moved back to TODO for implementation.'''
    },
]

print("=" * 80)
print("POSTING FAILURE COMMENTS TO HAZINA TASKS")
print("=" * 80)

for task in tasks_without_prs:
    print(f"\nTask: {task['id']} - {task['name']}")

    # Post comment
    try:
        comment_url = f"{api_base}/task/{task['id']}/comment"
        comment_payload = {
            'comment_text': task['comment']
        }
        response = requests.post(comment_url, headers=headers, json=comment_payload)
        response.raise_for_status()
        print("  [OK] Comment posted")
    except Exception as e:
        print(f"  [ERROR] Failed to post comment: {e}")
        continue

    # Move to TODO
    try:
        status_url = f"{api_base}/task/{task['id']}"
        status_payload = {
            'status': 'to do'
        }
        response = requests.put(status_url, headers=headers, json=status_payload)
        response.raise_for_status()
        print("  [OK] Moved to TODO")
    except Exception as e:
        print(f"  [ERROR] Failed to move to TODO: {e}")

print("\n" + "=" * 80)
print("COMPLETE")
print("=" * 80)
