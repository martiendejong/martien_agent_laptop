#!/usr/bin/env python3
"""Post code review comment for PR #249 with build errors."""
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

task_id = '869cabf4y'

comment = '''## CODE REVIEW - CHANGES REQUESTED

**PR:** #249 - Transactional Multi-File Updates
**Branch:** feature/transactional-updates-869cabf4y
**Status:** Build failed after merging develop

### Build Error

```
C:\\Projects\\hazina-worktrees\\pr-249-transactional\\src\\Core\\LLMs\\Hazina.LLMs.Classes\\ToolSets\\ToolSetManager.cs(16,27): error CS0246: The type or namespace name 'IToolProviderRegistry' could not be found (are you missing a using directive or an assembly reference?)
```

### Issue Analysis

The `IToolProviderRegistry` type is missing after merging with develop. This appears to be a merge conflict or missing dependency that wasn't caught before the merge.

### Required Actions

1. **Fix the build error**: Add missing using directive or reference for `IToolProviderRegistry`
2. **Verify solution builds**: Ensure all projects compile without errors
3. **Re-test**: Run unit tests to ensure transaction functionality works
4. **Update PR**: Push fixes to the branch

### Verification Checklist

- [ ] Build succeeds (0 errors)
- [ ] All 17 transaction tests pass
- [ ] No new warnings introduced
- [ ] Documentation matches implementation

**Task moved back to TODO for fixes.**'''

print("Posting review comment to task 869cabf4y...")

try:
    comment_url = f"{api_base}/task/{task_id}/comment"
    comment_payload = {
        'comment_text': comment
    }
    response = requests.post(comment_url, headers=headers, json=comment_payload)
    response.raise_for_status()
    print("[OK] Comment posted")
except Exception as e:
    print(f"[ERROR] Failed to post comment: {e}")
    exit(1)

# Move to TODO
try:
    status_url = f"{api_base}/task/{task_id}"
    status_payload = {
        'status': 'TODO'
    }
    response = requests.put(status_url, headers=headers, json=status_payload)
    response.raise_for_status()
    print("[OK] Moved to TODO")
except Exception as e:
    print(f"[ERROR] Failed to move to TODO: {e}")
    exit(1)

print("\nReview complete!")
