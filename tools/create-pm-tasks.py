"""Create tasks for remaining Password Manager work"""
import requests
import json

api_key = "pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI"
list_id = "901216204895"
assignee_id = 74525428

# Task 1: Verify CORS fix works
task1 = {
    "name": "[TESTING] Verify Browser Extension CORS Fix - Projects and Credentials Load",
    "description": """## What Was Fixed
The backend CORS policy was blocking browser extension API calls. Updated Program.cs to allow:
- chrome-extension:// origins
- moz-extension:// origins
- safari-web-extension:// origins
- https://vault.prospergenics.com

Backend redeployed with CORS fix.

## What to Test
1. Reload extension (chrome://extensions → reload button)
2. Login with test account (final2@test.com or info@martiendejong.nl)
3. Verify Dashboard shows:
   - ✓ 1 project: "websites"
   - ✓ 1 credential: "Prospergenics Vault"
4. Check browser console for errors (should be none)

## Expected Result
Extension should now load data without CORS errors.

## Files Changed
- E:/projects/passwordmanager/backend/PasswordManager.API/Program.cs (lines 59-69)
- Deployed to vault.prospergenics.com

## Database State
- 2 users exist
- 1 project: "websites"
- 1 credential: "Prospergenics Vault" for info@martiendejong.nl
""",
    "status": "testing",
    "priority": 1,
    "assignees": [assignee_id]
}

# Task 2: Verify auth persistence
task2 = {
    "name": "[TESTING] Verify Extension Authentication Persists Between Sessions",
    "description": """## What Was Fixed
CORS was blocking authentication checks, making it appear like auth wasn't persisting.

Now that CORS is fixed, authentication should work properly:
- Token stored in chrome.storage.local
- Token expiry checked on every request
- CHECK_AUTH message validates stored token

## What to Test
1. Login to extension
2. Close extension popup
3. Reopen extension popup
4. **Expected:** Should still be logged in (no login screen)
5. Close browser completely
6. Reopen browser
7. Open extension
8. **Expected:** Should still be logged in (unless token expired)

## Token Details
- Stored in: chrome.storage.local.jwt_token
- Expiry: chrome.storage.local.token_expiry
- Cleared when: Logout OR token expires

## Files Involved
- E:/projects/passwordmanager/extension/src/background/storageManager.ts
- E:/projects/passwordmanager/extension/src/background/apiClient.ts
- E:/projects/passwordmanager/extension/src/background/messageHandler.ts (CHECK_AUTH)
""",
    "status": "testing",
    "priority": 1,
    "assignees": [assignee_id]
}

# Task 3: SSL Certificate (optional)
task3 = {
    "name": "[BACKLOG] Install SSL Certificate for vault.prospergenics.com",
    "description": """## Current State
- Browser shows certificate warning when accessing https://vault.prospergenics.com
- Self-signed or no valid certificate installed
- Application works but users see security warning

## Options
1. **Let's Encrypt (Free)** - Automated certificate via win-acme or Certify The Web
2. **Commercial Certificate** - Purchase from provider like DigiCert, Sectigo
3. **Accept Self-Signed** - Keep current state (poor UX)

## Implementation (Let's Encrypt)
```powershell
# Install win-acme
cd C:/tools
wget https://github.com/win-acme/win-acme/releases/latest/download/win-acme.zip
Expand-Archive win-acme.zip
cd win-acme
./wacs.exe

# Follow prompts:
# - Select IIS binding
# - Choose vault.prospergenics.com
# - Auto-renews via scheduled task
```

## Impact
- Priority: LOW (application works without it)
- User Experience: Removes browser warning
- Security: Enables proper HTTPS

## Server Details
- Server: 85.215.217.154
- Site: vault.prospergenics.com
- IIS binding: HTTPS port 443
- Credentials: administrator / SpaceElevator1tam!
""",
    "status": "backlog",
    "priority": 3,
    "assignees": [assignee_id]
}

# Create tasks
print('Creating Password Manager tasks...')
print('='*80)

for i, task_data in enumerate([task1, task2, task3], 1):
    response = requests.post(
        f"https://api.clickup.com/api/v2/list/{list_id}/task",
        headers={
            "Authorization": api_key,
            "Content-Type": "application/json"
        },
        json=task_data
    )

    if response.status_code == 200:
        task = response.json()
        print(f'{i}. OK Created: {task_data["name"][:70]}')
        print(f'   ID: {task["id"]}')
        print(f'   Status: {task_data["status"]}')
        print(f'   URL: {task["url"]}')
        print()
    else:
        print(f'{i}. FAIL: {task_data["name"][:70]}')
        print(f'   Error: {response.status_code} - {response.text[:200]}')
        print()

print('='*80)
print('Tasks created in Password Manager board')
print('Board: https://app.clickup.com/9012956001/v/b/li/901216204895')
