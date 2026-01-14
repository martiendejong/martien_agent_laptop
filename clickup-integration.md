# ClickUp Integration

**Created:** 2026-01-14
**Status:** Active

---

## Overview

Claude Agent can synchronize with ClickUp to:
- Pull tasks from ClickUp lists
- Update task status when work is completed
- Create tasks when issues are discovered
- Track work in progress

---

## Configuration

**Config file:** `C:\scripts\_machine\clickup-config.json`

### Repository → ClickUp Mapping

| Repository | Workspace | List | List ID |
|------------|-----------|------|---------|
| client-manager | Furniture Website | Vera AI | 901506248257 |
| hazina | Furniture Website | Vera AI | 901506248257 |

---

## Workspaces Summary

### 1. Martien de Jong's Workspace (Personal)
- **ID:** 9015747737
- **Role:** Owner
- **Usage:** Personal/household tasks, tax admin

### 2. Furniture Website (Company)
- **ID:** 9015748488
- **Role:** Admin
- **Usage:** client-manager/hazina development tasks
- **Key List:** Vera AI (901506248257) - 31 tasks

### 3. GigsHub Workspace
- **ID:** 9012956001
- **Role:** Member
- **Usage:** GigsHub project

---

## Vera AI Task Statuses (client-manager/hazina)

| Status | Color | Meaning |
|--------|-------|---------|
| prullenbak | grey | Trash/archived |
| ooit | yellow | Someday/maybe |
| backlog | grey | Backlog - not prioritized |
| bugs | purple | Bug reports |
| volgende 30u | grey | Next 30 hours |
| blocked | red | Blocked |
| testen | grey | In testing |

---

## API Usage

### Authentication
```powershell
$headers = @{Authorization = "pk_74525428_TXT8V1QUA13N7SCRM0UUM6WNQO2I2NML"}
```

### Common Endpoints

**Get tasks from Vera AI list:**
```powershell
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/901506248257/task?archived=false" -Headers $headers
```

**Update task status:**
```powershell
Invoke-RestMethod -Method PUT -Uri "https://api.clickup.com/api/v2/task/{task_id}" -Headers $headers -Body (@{status="testen"} | ConvertTo-Json) -ContentType "application/json"
```

**Create task:**
```powershell
$body = @{name="Task name"; description="Details"; status="backlog"} | ConvertTo-Json
Invoke-RestMethod -Method POST -Uri "https://api.clickup.com/api/v2/list/901506248257/task" -Headers $headers -Body $body -ContentType "application/json"
```

---

## Workflow Integration

### Starting Work on a Task

1. **Pull tasks from ClickUp:**
   ```
   clickup-sync.ps1 -Action list
   ```

2. **Agent picks task and updates status:**
   ```
   clickup-sync.ps1 -Action update -TaskId "86c45buz7" -Status "in progress"
   ```

3. **When PR created, update to "testen":**
   ```
   clickup-sync.ps1 -Action update -TaskId "86c45buz7" -Status "testen" -Comment "PR #149 created"
   ```

### Agent Autonomy

Claude Agent can autonomously:
- Check for high-priority tasks at session start
- Update task status when PRs are created
- Add comments with PR links
- Create new tasks when bugs are discovered

---

## Current Open Tasks (as of 2026-01-14)

**In "testen" (testing):** 13 tasks
- Vera stop button
- Image generation from content hooks
- Loading icons
- Emoticons for content hooks
- Password requirements display
- BigQuery admin-only access
- Facebook connection bug
- Chat overflow issue
- Role-specific prompts
- Query mechanism improvements

**In "backlog":** 6 tasks
- Backend team input
- Photoshoot briefing generation
- Search crawler research
- Inhakers feature
- Task queue for generation
- Huisstijl in project settings

**Blocked:** 2 tasks
- Google Ads
- Password forgotten email

---

## Tools

- **clickup-sync.ps1** - Main sync tool (see `C:\scripts\tools\`)
- **clickup-config.json** - Configuration (see `C:\scripts\_machine\`)

---

## Security

- API key stored in `_machine/clickup-config.json` (not committed to git)
- `.gitignore` should exclude `_machine/*.json` with secrets

---

**Maintained by:** Claude Agent
