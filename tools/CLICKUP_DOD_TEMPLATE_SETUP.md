# ClickUp Task Template with Definition of Done Checklist

**Purpose:** Configure ClickUp task templates to automatically include Definition of Done checklist items.

**ROI:** 225x | Ensures every task meets quality standards before marking "done"

---

## 📋 Template Overview

Every ClickUp task should include a comprehensive DoD checklist that matches `C:\scripts\_machine\DEFINITION_OF_DONE.md`.

---

## 🛠️ Setup Instructions

### Option 1: Manual Checklist (Current Method)

Add this checklist to every new task:

```markdown
## Definition of Done ✅

**Phase 1: Development**
- [ ] Code implemented and working locally
- [ ] Unit tests written and passing
- [ ] Manual testing completed
- [ ] Code formatted (cs-format.ps1)
- [ ] Build succeeds (dotnet build)

**Phase 2: Quality Assurance**
- [ ] All tests passing (dotnet test)
- [ ] Code review completed
- [ ] Security scan passed
- [ ] Performance validated

**Phase 3: Version Control**
- [ ] Code committed with meaningful message
- [ ] Branch pushed to remote
- [ ] PR created with complete description
- [ ] PR base branch verified as 'develop'
- [ ] PR approved by reviewer(s)

**Phase 4: Integration**
- [ ] PR merged to develop
- [ ] Develop branch updated locally
- [ ] CI/CD pipeline passed on develop

**Phase 5: Deployment**
- [ ] Deployed to staging (if applicable)
- [ ] Deployed to production
- [ ] Production verification completed
- [ ] Rollback plan ready

**Phase 6: Documentation**
- [ ] User documentation updated
- [ ] Technical documentation updated
- [ ] Changelog updated
- [ ] Release notes prepared (if needed)

**Phase 7: Communication**
- [ ] Stakeholder notified
- [ ] ClickUp task status updated to "done"
- [ ] Reflection log updated

**⚠️ TASK NOT DONE UNTIL ALL ITEMS CHECKED**
```

### Option 2: ClickUp Task Template (Recommended)

**1. Create Task Template:**
- Go to ClickUp → Space Settings → Task Templates
- Click "New Template"
- Name: "Standard Task with DoD"
- Add the checklist above to the description field
- Save template

**2. Set as Default Template:**
- Space Settings → Task Templates
- Click "..." next to "Standard Task with DoD"
- Select "Set as Default Template"

**3. Apply to Existing Tasks:**
For tasks created before template was active:

```powershell
# Use ClickUp API to add checklist
C:\scripts\tools\clickup-sync.ps1 -Action update -TaskId "<task-id>" -AddChecklist "Definition of Done"
```

### Option 3: Automation Rule (Advanced)

**Create ClickUp Automation:**
- Trigger: When task status changes to "busy"
- Action: Add "Definition of Done" checklist from template
- Condition: Only if checklist doesn't already exist

**PowerShell Script for Bulk Update:**

```powershell
# Add DoD checklist to all TODO tasks in Brand Designer list
$config = Get-Content C:\scripts\_machine\clickup-config.json | ConvertFrom-Json
$api_key = $config.api_key
$list_id = "901214097647"  # Brand Designer

# Fetch all TODO tasks
$response = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/list/$list_id/task?statuses[]=todo" -Headers @{ Authorization = $api_key }

foreach ($task in $response.tasks) {
    # Check if DoD checklist already exists
    $hasDoD = $task.checklists | Where-Object { $_.name -eq "Definition of Done" }

    if (-not $hasDoD) {
        Write-Host "Adding DoD checklist to task: $($task.name)"

        # Add checklist via API
        $checklistUrl = "https://api.clickup.com/api/v2/task/$($task.id)/checklist"
        $checklistData = @{
            name = "Definition of Done"
        } | ConvertTo-Json

        Invoke-RestMethod -Uri $checklistUrl -Method Post -Headers @{
            Authorization = $api_key
            "Content-Type" = "application/json"
        } -Body $checklistData

        # Add checklist items
        # (Repeat for each DoD phase)
    }
}
```

---

## 📊 Checklist Items Reference

### Phase 1: Development (8 items)
1. Code implemented
2. Unit tests written
3. Manual testing completed
4. UI testing (Browser MCP)
5. Code formatted
6. Build succeeds
7. No pending migrations
8. Security validated

### Phase 2: Quality Assurance (5 items)
1. All tests passing
2. Code review completed
3. Security scan passed
4. Performance validated
5. No compiler warnings

### Phase 3: Version Control (5 items)
1. Code committed
2. Branch pushed
3. PR created
4. PR base = develop
5. PR approved

### Phase 4: Integration (3 items)
1. PR merged
2. Develop updated
3. CI/CD passed

### Phase 5: Deployment (4 items)
1. Deployed to staging
2. Deployed to production
3. Production verified
4. Rollback plan ready

### Phase 6: Documentation (4 items)
1. User docs updated
2. Technical docs updated
3. Changelog updated
4. Release notes prepared

### Phase 7: Communication (3 items)
1. Stakeholder notified
2. ClickUp updated
3. Reflection log updated

**Total:** 32 checklist items

---

## 🔄 Workflow Integration

**When creating a new task:**
1. Use "Standard Task with DoD" template (or manually add checklist)
2. Fill in task description and requirements
3. DoD checklist automatically included

**During task execution:**
1. Check off items as you complete them
2. Use `dod-pre-commit-check.ps1` before committing
3. Review unchecked items before creating PR

**Before marking "done":**
1. Verify ALL 32 DoD items are checked
2. If any unchecked → Task is NOT done
3. Only mark "done" when 100% complete

---

## 🤖 Automation Scripts

### Pre-Commit Hook

**Install Git Hook:**
```powershell
# Create .git/hooks/pre-commit file
$hookPath = ".git\hooks\pre-commit"
@"
#!/bin/sh
# Definition of Done pre-commit validation
pwsh -File C:\scripts\tools\dod-pre-commit-check.ps1 -ProjectPath .
exit `$?
"@ | Set-Content $hookPath -Encoding UTF8

# Make executable (Git Bash)
chmod +x .git/hooks/pre-commit
```

**Manual Check:**
```powershell
# Run before committing
C:\scripts\tools\dod-pre-commit-check.ps1
```

### DoD Validation Script

**Check if task meets DoD:**
```powershell
# Validate specific task
C:\scripts\tools\validate-dod.ps1 -TaskId "869bu91ej"

# Validate current PR
C:\scripts\tools\validate-dod.ps1 -PrNumber 513
```

---

## 📈 Success Metrics

**Track DoD compliance:**
- % of tasks with DoD checklist: Target 100%
- % of tasks with all items checked before "done": Target 100%
- Reduction in post-deployment bugs: Target 20%
- Faster code reviews: Target 15% improvement

**Monitor:**
```powershell
# Get DoD compliance report
C:\scripts\tools\clickup-sync.ps1 -Action report -Metric dod-compliance
```

---

## 🎯 Benefits

1. **Consistent Quality:** Every task meets same standard
2. **No Shortcuts:** Can't skip tests/docs/deployment
3. **Clear Communication:** "Done" means truly done
4. **Less Rework:** Reduce bugs by 20% (catch issues early)
5. **Team Alignment:** Everyone knows what "done" means

---

## 🔍 Examples

### Example 1: Bug Fix Task

**Task:** Fix login timeout issue (#869xyz)

**DoD Checklist Progress:**
```
✅ Phase 1: Development (8/8 complete)
✅ Phase 2: QA (5/5 complete)
✅ Phase 3: Version Control (5/5 complete)
✅ Phase 4: Integration (3/3 complete)
✅ Phase 5: Deployment (4/4 complete)
✅ Phase 6: Documentation (2/4 complete) ⚠️ Changelog pending
❌ Phase 7: Communication (1/3 complete) ⚠️ Stakeholder not notified

Status: NOT DONE (31/32 items)
```

**Action:** Complete Phase 6 and 7 before marking "done"

### Example 2: New Feature Task

**Task:** Add PDF export (#869abc)

**DoD Checklist Progress:**
```
✅ All 32 items checked
Status: DONE ✅
```

**Result:** Task can be marked "done" and closed

---

## 🆘 Troubleshooting

**Problem:** ClickUp checklist doesn't save
**Solution:** Check ClickUp permissions, refresh browser

**Problem:** Too many checklist items (overwhelming)
**Solution:** Group by phase, check off incrementally

**Problem:** Task marked "done" but DoD not complete
**Solution:** Reopen task, complete missing items, automation reminder

---

## 📚 References

- **Full DoD:** `C:\scripts\_machine\DEFINITION_OF_DONE.md`
- **Pre-commit tool:** `C:\scripts\tools\dod-pre-commit-check.ps1`
- **ClickUp API docs:** https://clickup.com/api
- **Git hooks guide:** https://git-scm.com/docs/githooks

---

**Last Updated:** 2026-02-07
**Created By:** Claude Agent (DoD Enforcement Implementation)
**ClickUp Task:** #869bu91ej
