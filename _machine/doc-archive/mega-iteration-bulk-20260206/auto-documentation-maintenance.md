# Auto-Documentation Maintenance

**Purpose:** Automated and semi-automated processes to keep documentation current and accurate

## Core Problem

Documentation becomes outdated when:
- Code changes but docs don't update
- New tools created but not cataloged
- Workflows evolve but guides remain static
- Knowledge gained but not captured

**Solution:** Systematic automation and triggers to maintain documentation currency.

## Automated Documentation Updates

### 1. Tool Catalog Auto-Update

**Trigger:** New .ps1 file created in C:\scripts\tools\

**Automated actions:**
```powershell
# Scan for new tools
Get-ChildItem C:\scripts\tools -Filter *.ps1 |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }

# Extract metadata from comment header
# - Name, Purpose, Parameters, Examples

# Update tools/README.md with new entry
# Update knowledge network tools/ section
# Re-index with hazina-rag
```

**Implementation status:** Manual (future: `auto-catalog-tools.ps1`)

### 2. Skill Registration Auto-Update

**Trigger:** New skill created in .claude/skills/

**Automated actions:**
```powershell
# Scan for new SKILL.md files
Get-ChildItem .claude\skills -Recurse -Filter SKILL.md |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }

# Extract YAML frontmatter
# - name, description, triggers, category

# Update skills index in knowledge network
# Update CLAUDE.md § Available Skills
# Re-index with hazina-rag
```

**Implementation status:** Manual (future: `auto-catalog-skills.ps1`)

### 3. Git Commit History Analysis

**Trigger:** End of session

**Automated actions:**
```bash
# Get commits from today
git log --since="midnight" --pretty=format:"%h - %s" --author="Jengo"

# Categorize by type (docs:, feat:, fix:, refactor:)
# Extract documentation updates
# Check if reflection.log.md was updated
# Warn if code commits but no reflection entry
```

**Implementation status:** Manual check (future: `session-commit-analyzer.ps1`)

### 4. Knowledge Network Sync

**Trigger:** End of session (currently manual)

**Automated actions:**
```powershell
# Scan my_network/ for file changes
# Re-index with hazina-rag
# Report chunk count delta
# Validate all cross-references still valid
```

**Current implementation:**
```bash
# Manual
hazina-rag.ps1 -Action sync -StoreName "C:\scripts\my_network"
```

**Future:** Automatic on session end

### 5. File System Map Update

**Trigger:** New important directories discovered

**Automated actions:**
```powershell
# When accessing path for first time
# Check if documented in file-system-map.md
# If not → add entry with structure
# Update knowledge network
```

**Current implementation:** Manual after user correction

**Future:** Proactive scanning with `discover-file-structure.ps1`

## Semi-Automated Documentation Updates

### 1. Reflection Log Entry

**Trigger:** Mistake made, pattern learned, user feedback

**Process:**
```
1. Manually write reflection entry
2. Auto-extract key learnings with NLP
3. Auto-update anti-patterns catalog
4. Auto-update cognitive-biases.md if new bias
5. Auto-update knowledge network
```

**Current:** Fully manual
**Future:** `extract-reflection-insights.ps1`

### 2. Tool Wishlist Management

**Trigger:** "I wish I had..." thought during session

**Process:**
```
1. Manually add to tool-wishlist.md
2. Auto-calculate value/effort ratio
3. Auto-sort by priority
4. Auto-move to IMPLEMENTED when done
5. Auto-update usage tracking monthly
```

**Current:** Manual add, manual moves
**Future:** `wishlist-manager.ps1`

### 3. Anti-Pattern Detection

**Trigger:** Violation occurred

**Process:**
```
1. Detect violation (pre-commit hook or runtime)
2. Auto-check anti-patterns catalog
3. If known → log repetition (CRITICAL)
4. If new → prompt for catalog entry
5. Auto-update prevention protocols
```

**Current:** Manual detection and cataloging
**Future:** `violation-detector.ps1`

### 4. Success Metrics Collection

**Trigger:** Weekly/monthly review

**Process:**
```
1. Scan git commits for activity counts
2. Scan command history for tool usage
3. Scan reflection.log for violation counts
4. Auto-generate metrics dashboard
5. Compare to previous period (trends)
```

**Current:** Fully manual
**Future:** `metrics-collector.ps1` + `metrics-dashboard.ps1`

## Documentation Validation

### Staleness Detection

**Check frequency:** Weekly

**Validation:**
```powershell
# Find docs not updated in >30 days
Get-ChildItem C:\scripts\_machine\knowledge-base -Recurse -Filter *.md |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Select-Object Name, LastWriteTime

# Flag for review
```

**Future tool:** `stale-docs-detector.ps1`

### Cross-Reference Validation

**Check frequency:** Monthly

**Validation:**
```powershell
# Find broken links in markdown
Get-ChildItem . -Recurse -Filter *.md | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $links = [regex]::Matches($content, '\[.*?\]\((.*?\.md.*?)\)')
    foreach ($link in $links) {
        $target = $link.Groups[1].Value
        if (-not (Test-Path $target)) {
            Write-Warning "Broken link: $($_.Name) -> $target"
        }
    }
}
```

**Future tool:** `validate-doc-links.ps1`

### Accuracy Validation

**Check frequency:** On-demand (when user corrects info)

**Validation:**
```
1. User corrects documentation
2. Search for other mentions of same fact
3. Update all instances
4. Add to knowledge network with high confidence
5. Retract conflicting information
```

**Current:** Manual search and update
**Future:** `fact-check-and-update.ps1`

## Documentation Coverage Gaps

### Detection

**What to check:**
```
- New repos created → need PROJECT_MAP.md
- New services deployed → need SYSTEM_MAP.md entry
- New integrations added → need 04-EXTERNAL-SYSTEMS/ doc
- New workflows established → need 06-WORKFLOWS/ doc
- New team members → need onboarding updated
```

**Detection triggers:**
- git clone executed → check if PROJECT_MAP.md exists
- New directory in C:\Projects\ → check if documented
- New API key added → check if in api-keys-registry.md
- New skill created → check if in catalog

**Future tool:** `coverage-gap-detector.ps1`

### Gap Remediation

**Process:**
```
1. Detect gap (e.g., new repo with no PROJECT_MAP.md)
2. Notify (console warning or log entry)
3. Auto-generate template
4. Prompt for completion
5. Validate when done
```

**Example:**
```powershell
# New repo detected: C:\Projects\new-project
# Auto-generate:
project-map-create.ps1 -ProjectName new-project
# Creates: C:\Projects\new-project\PROJECT_MAP.md

# Prompt: "Please complete the generated PROJECT_MAP.md"
```

## Session-End Documentation Checklist

**Automated validation before session end:**

```markdown
□ Reflection.log.md updated? (if mistakes/learnings)
□ PERSONAL_INSIGHTS.md updated? (if user feedback)
□ Knowledge network synced? (if new files added)
□ Tool wishlist updated? (if "I wish..." thoughts)
□ Anti-patterns catalog updated? (if violations)
□ ClickUp tasks updated? (if work completed)
□ Git commits pushed? (if changes made)
□ Documentation matches reality? (sanity check)
```

**Future tool:** `session-end-validator.ps1`

## Continuous Improvement Protocol

### Monthly Documentation Audit

**Process:**
```
1. Run stale-docs-detector.ps1
2. Run validate-doc-links.ps1
3. Run coverage-gap-detector.ps1
4. Review top 10 outdated docs
5. Update or archive each
6. Re-index knowledge network
```

**Schedule:** First Monday of month

### Quarterly Documentation Consolidation

**Process:**
```
1. Identify duplicate information
2. Consolidate into authoritative source
3. Create cross-references
4. Retire redundant docs
5. Update indexes
```

**Schedule:** Start of quarter (Jan, Apr, Jul, Oct)

## Future Automation Roadmap

### Phase 1: Monitoring (Next 2 weeks)
- ✅ Knowledge network sync automation
- ⏳ Tool catalog auto-update
- ⏳ Skill registration auto-update
- ⏳ Staleness detector

### Phase 2: Validation (Next month)
- ⏳ Cross-reference validator
- ⏳ Coverage gap detector
- ⏳ Session-end validator
- ⏳ Metrics collector

### Phase 3: Proactive Updates (Next quarter)
- ⏳ Auto-extract reflection insights
- ⏳ Auto-update anti-patterns from violations
- ⏳ Auto-generate PROJECT_MAP.md for new repos
- ⏳ Auto-update SYSTEM_MAP.md from scans

### Phase 4: AI-Assisted Maintenance (Future)
- ⏳ NLP-based accuracy validation
- ⏳ Semantic duplicate detection
- ⏳ Auto-suggest documentation updates based on code changes
- ⏳ Cross-repo documentation consistency checks

## Success Metrics

**Well-Maintained Documentation:**
- ✅ No docs >30 days stale
- ✅ Zero broken cross-references
- ✅ Coverage gaps < 5
- ✅ User corrections trigger permanent updates
- ✅ Knowledge network query success rate >90%

**Needs Improvement:**
- ❌ Frequent outdated info corrections
- ❌ Many broken links
- ❌ Large coverage gaps
- ❌ Same corrections repeated
- ❌ Knowledge network queries fail

**Last Updated:** 2026-02-01
**Automation Level:** 20% (mostly manual)
**Goal:** 80% automated by Q2 2026
