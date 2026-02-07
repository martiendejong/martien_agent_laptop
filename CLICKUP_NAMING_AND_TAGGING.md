# ClickUp Task Naming & Tagging System

**Created:** 2026-02-07
**Purpose:** Standardized naming conventions and tagging taxonomy for ClickUp tasks
**Status:** PROPOSED → IMPLEMENTATION

---

## 🎯 Goals

1. **Scannability:** Identify task type, priority, and scope at a glance
2. **Searchability:** Find related tasks quickly via tags
3. **Prioritization:** Integrate MoSCoW framework into task metadata
4. **Automation:** Enable agent filtering and smart workflows
5. **Consistency:** Same structure across all projects (client-manager, art-revisionist)

---

## 📝 Task Naming Convention

### Format

```
[Type] [MoSCoW] Task Description (Component/Area)
```

### Components

| Component | Options | Example |
|-----------|---------|---------|
| **Type** | `FEAT`, `FIX`, `ENH`, `REFACTOR`, `DOC`, `TEST`, `INFRA` | `FEAT` |
| **MoSCoW** | `[M]`, `[S]`, `[C]`, `[W]` (optional for new tasks) | `[M]` |
| **Description** | Clear, action-oriented, 3-8 words | "User Profile Export System" |
| **Component** | Optional context in parentheses | "(Dashboard)" |

### Examples

**Before:**
```
Post Duplication & Cloning System
Media Upload & Management System
AI Art Style Classifier
```

**After:**
```
FEAT [M] Post Duplication System (Social Media)
FEAT [S] Media Upload & Management (Content)
FEAT [M] AI Art Style Classifier (Metadata)
```

### Type Definitions

| Type | Meaning | Use When |
|------|---------|----------|
| `FEAT` | New feature | Adding new functionality |
| `FIX` | Bug fix | Fixing broken behavior |
| `ENH` | Enhancement | Improving existing feature |
| `REFACTOR` | Code improvement | Restructuring without changing behavior |
| `DOC` | Documentation | Adding/updating docs |
| `TEST` | Testing | Adding/fixing tests |
| `INFRA` | Infrastructure | DevOps, CI/CD, deployment |

### MoSCoW Priority Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| `[M]` | Must Have | Critical, cannot skip |
| `[S]` | Should Have | Important, include if time allows |
| `[C]` | Could Have | Nice-to-have, lower priority |
| `[W]` | Won't Have | Out of scope for current iteration |

**Note:** MoSCoW code is added AFTER task analysis, not during initial creation.

---

## 🏷️ Tagging Taxonomy

### Tag Categories

ClickUp allows multiple tags per task. Use this hierarchy:

#### 1. MoSCoW Priority Tags (MANDATORY after analysis)

```
moscow:must-have
moscow:should-have
moscow:could-have
moscow:wont-have
```

#### 2. Type Tags (MANDATORY)

```
type:feature
type:bug
type:enhancement
type:refactor
type:documentation
type:test
type:infrastructure
```

#### 3. Domain Tags (Choose 1-2)

**Client-Manager:**
```
domain:frontend
domain:backend
domain:api
domain:database
domain:ai-llm
domain:social-media
domain:calendar
domain:dashboard
domain:auth
```

**Art-Revisionist:**
```
domain:frontend
domain:backend
domain:wordpress
domain:ai-vision
domain:metadata
domain:provenance
domain:search
domain:media
```

#### 4. Complexity Tags (Optional)

```
complexity:simple      (< 4 hours)
complexity:moderate    (4-16 hours)
complexity:complex     (16-40 hours)
complexity:epic        (> 40 hours)
```

#### 5. Impact Tags (Optional)

```
impact:critical     (System broken without this)
impact:high         (Major value/improvement)
impact:medium       (Notable improvement)
impact:low          (Minor enhancement)
```

#### 6. Blocker Tags (For blocked tasks)

```
blocked:scope          (Unclear requirements)
blocked:dependency     (Waiting on other task/PR)
blocked:external       (Third-party issue)
blocked:decision       (Need user decision)
blocked:technical      (Technical challenge)
```

#### 7. Architecture Tags (Optional)

```
arch:breaking-change   (Requires migration)
arch:api-change        (Changes public API)
arch:database-schema   (Database changes)
arch:performance       (Performance sensitive)
arch:security          (Security implications)
```

---

## 📋 Complete Example

**Task Name:**
```
FEAT [M] AI Art Style Classifier (Metadata)
```

**Tags:**
```
moscow:must-have
type:feature
domain:ai-vision
domain:metadata
complexity:moderate
impact:high
arch:api-change
```

**Description:**
```
Automatically detect art movements, periods, and techniques from images
using GPT-4 Vision API.

MoSCoW Analysis:
- MUST: GPT-4 Vision integration, basic classification
- SHOULD: Multi-label, confidence scores
- COULD: Artist matching, subject matter
- WON'T: Custom ML training, real-time processing
```

---

## 🔄 Implementation Workflow

### For New Tasks

```
1. User/Agent creates task with basic name
2. Agent reads task and performs MoSCoW analysis
3. Agent updates task:
   - Rename with convention: "FEAT [M] Description (Component)"
   - Add tags: moscow:must-have, type:feature, domain:*, etc.
   - Post MoSCoW analysis as comment
4. Task ready for implementation
```

### For Existing Tasks

```
1. Agent reads existing task
2. Agent performs MoSCoW analysis
3. Agent updates task:
   - Rename using new convention
   - Add appropriate tags
   - Post MoSCoW comment
4. Log update in ClickUp comment
```

### Bulk Migration Script

```powershell
# Pseudo-code for bulk migration
Get-ClickUpTasks -Project "client-manager" | ForEach-Object {
    $task = $_

    # Analyze task
    $moscow = Get-MoSCoWAnalysis $task.description
    $type = Detect-TaskType $task.name
    $domains = Detect-Domains $task.description

    # Generate new name
    $newName = "$type [$moscow] $($task.name) ($domains[0])"

    # Update task
    Update-ClickUpTask -TaskId $task.id -Name $newName
    Add-ClickUpTags -TaskId $task.id -Tags @(
        "moscow:$moscow",
        "type:$type",
        "domain:$($domains -join ',')"
    )

    # Post comment
    Add-ClickUpComment -TaskId $task.id -Comment "📋 Task renamed and tagged per new convention"
}
```

---

## 🎨 Visual Benefits

### Before (Current State)
```
☐ Post Duplication & Cloning System
☐ Media Upload & Management System
☐ AI Art Style Classifier
☐ Provenance Confidence Scoring (0-100%)
```

### After (With Naming & Tagging)
```
☐ FEAT [M] Post Duplication System (Social Media)
   🏷️ moscow:must-have | type:feature | domain:social-media | complexity:complex

☐ FEAT [S] Media Upload & Management (Content)
   🏷️ moscow:should-have | type:feature | domain:frontend | complexity:complex

☐ FEAT [M] AI Art Style Classifier (Metadata)
   🏷️ moscow:must-have | type:feature | domain:ai-vision | impact:high

☐ ENH [S] Provenance Confidence Scoring (Provenance)
   🏷️ moscow:should-have | type:enhancement | domain:metadata | complexity:moderate
```

---

## 🔍 Search Examples

With proper tagging, you can filter:

```
Find all Must Have features:
→ Filter: moscow:must-have + type:feature

Find all AI-related tasks:
→ Filter: domain:ai-vision OR domain:ai-llm

Find all blocked tasks with scope issues:
→ Filter: status:blocked + blocked:scope

Find all breaking changes:
→ Filter: arch:breaking-change

Find quick wins (simple + high impact):
→ Filter: complexity:simple + impact:high
```

---

## 📊 Integration with MoSCoW Prioritization

### How They Work Together

1. **Initial Task Creation**
   - Name: Basic description
   - Tags: None yet
   - Status: todo

2. **MoSCoW Analysis Phase** (Agent/User)
   - Agent analyzes requirements
   - Identifies Must/Should/Could/Won't items
   - Posts analysis as comment

3. **Task Update Phase**
   - Rename: Add type and MoSCoW code
   - Tags: Add moscow:* + other relevant tags
   - Ready for implementation

4. **Implementation Phase**
   - Agent filters by moscow:must-have
   - Implements critical items first
   - Updates task as work progresses

---

## 🚀 Migration Strategy

### Phase 1: New Tasks (Immediate)
- All NEW tasks use new naming convention
- Apply tags during creation/analysis

### Phase 2: High-Priority Tasks (This Week)
- Migrate all "todo" and "busy" tasks
- Focus on client-manager first

### Phase 3: Backlog Tasks (Next Week)
- Migrate "blocked" and "review" tasks
- Update done tasks only if referenced

### Phase 4: Archive (Optional)
- Leave completed tasks as-is unless needed
- Focus on active/future work

---

## 🛠️ ClickUp API Operations

### Rename Task
```powershell
C:/scripts/tools/clickup-sync.ps1 -Action rename -TaskId "869c1dnyd" -NewName "FEAT [M] Post Duplication System (Social Media)"
```

### Add Tags
```powershell
C:/scripts/tools/clickup-sync.ps1 -Action add-tags -TaskId "869c1dnyd" -Tags "moscow:must-have,type:feature,domain:social-media"
```

### Bulk Update
```powershell
# Get all tasks, analyze, rename, and tag
C:/scripts/tools/bulk-clickup-migration.ps1 -Project "client-manager" -DryRun $false
```

---

## ✅ Success Criteria

After implementation:

- ✅ All active tasks follow naming convention
- ✅ All tasks have minimum 2 tags (moscow + type)
- ✅ Tasks are searchable by MoSCoW priority
- ✅ Blocked tasks clearly labeled with blocker type
- ✅ Agent can filter tasks for autonomous work
- ✅ User can quickly identify high-priority work
- ✅ Consistent structure across both projects

---

## 📝 Examples by Project

### Client-Manager Examples

```
FEAT [M] Parent-Child Post Model (Social Media)
  moscow:must-have | type:feature | domain:backend | arch:database-schema

FIX [M] Login Redirect Loop (Auth)
  moscow:must-have | type:bug | domain:auth | impact:critical

ENH [S] Chat Input Multi-Line Support (Chat)
  moscow:should-have | type:enhancement | domain:frontend | complexity:simple

REFACTOR [C] Code Organization Cleanup (Codebase)
  moscow:could-have | type:refactor | domain:backend | complexity:moderate
```

### Art-Revisionist Examples

```
FEAT [M] AI Art Style Classifier (Metadata)
  moscow:must-have | type:feature | domain:ai-vision | impact:high | complexity:moderate

FEAT [S] Provenance Confidence Scoring (Provenance)
  moscow:should-have | type:feature | domain:metadata | complexity:moderate

ENH [C] Audio Guide Generator (Accessibility)
  moscow:could-have | type:enhancement | domain:ai-llm | complexity:complex

DOC [S] Valsuani Evidence Documentation (Publication)
  moscow:should-have | type:documentation | domain:wordpress | complexity:simple
```

---

## 🔄 Maintenance

### Weekly Review
- Check that new tasks follow convention
- Update MoSCoW tags as priorities shift
- Remove obsolete tags

### Monthly Audit
- Ensure tagging consistency
- Update taxonomy if new patterns emerge
- Archive completed tasks

---

## 🎯 Quick Reference Card

```
NAMING: [Type] [MoSCoW] Description (Component)

TYPES: FEAT | FIX | ENH | REFACTOR | DOC | TEST | INFRA

MOSCOW: [M] Must | [S] Should | [C] Could | [W] Won't

TAGS (Minimum):
  - moscow:* (after analysis)
  - type:*
  - domain:* (1-2 tags)

OPTIONAL TAGS:
  - complexity:*
  - impact:*
  - blocked:*
  - arch:*
```

---

## 📚 Related Documentation

- `MOSCOW_PRIORITIZATION.md` - MoSCoW framework details
- `clickup-github-workflow.md` - ClickUp-Git integration
- `.claude/skills/clickhub-coding-agent/SKILL.md` - Autonomous agent workflow

---

**Last Updated:** 2026-02-07
**Status:** PROPOSED - Awaiting user approval before bulk migration
**Author:** Claude Code Agent (Jengo)
