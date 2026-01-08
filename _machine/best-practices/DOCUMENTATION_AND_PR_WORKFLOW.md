# Best Practice: Documentation and PR Workflow for Incomplete Work

**Date**: 2026-01-08
**Time**: 21:08:00 UTC
**Created by**: Claude Opus 4.5 (claude-sonnet-4-5-20250929)
**Context**: Learned during hazina chat LLM configuration fix (PR #13)

---

## Overview

This document captures best practices for handling incomplete work, creating PRs with partial fixes, and maintaining clear documentation for future work.

## The Pattern

### When to Use This Approach

Use this pattern when:
- Work session is running long and needs to be preserved
- Fix is complex and spans multiple files (>5 locations)
- Testing reveals the fix is incomplete
- Token limits or time constraints prevent completion
- Linter or external factors interfere with changes
- Need to document findings before losing context

### Do NOT Use When

Avoid this pattern for:
- Simple, single-file fixes
- Quick bug fixes that can be completed in <30 minutes
- Changes that are fully tested and working
- Minor refactoring or formatting changes

---

## The Workflow

### 1. Create Comprehensive Documentation FIRST

Before creating the PR, create two documentation files:

#### A. Fix Summary (PROBLEM_FIX_SUMMARY.md)
**Purpose**: Complete technical specification of the solution

**Template**:
```markdown
# [Feature/Bug] Fix - Summary

**Date**: YYYY-MM-DDTHH:MM:SSZ
**Signed by**: [AI Model] ([model-id])

## Problem
[Clear description of the issue]

## Root Cause
[Technical analysis of why it happens]

## Solution Overview
[High-level approach to fix]

## Changes Made (Current Status)
- ✅ [Completed change 1]
- ✅ [Completed change 2]
- ❌ [Incomplete change 1]

## Implementation Details

### File 1: path/to/file.cs
**Lines**: X, Y, Z

```csharp
// CURRENT (WRONG):
[bad code]

// CHANGE TO:
[good code]
```

**Impact**: [What breaks if not fixed]

### File 2: path/to/file.cs
[repeat pattern]

## Testing Checklist
1. Build verification
2. Unit tests
3. Integration tests
4. Manual testing steps

## Notes
- [Any gotchas]
- [Known issues]
- [Dependencies]
```

#### B. Remaining Work (REMAINING_WORK.md)
**Purpose**: Action-oriented task list for completion

**Template**:
```markdown
# Remaining Work: [Feature Name]

**Date**: YYYY-MM-DD
**Time**: HH:MM:SS UTC
**Signed by**: [AI Model] ([model-id])
**PR**: [PR URL]
**Branch**: [branch-name]

---

## Status Overview

### ✅ Completed
- [List of completed items]
- [With commit hashes if relevant]

### ❌ Incomplete
- [List of incomplete items]
- [Why incomplete]

---

## Required Changes

### 1. [Component Name] (PRIORITY LEVEL)
**File**: `path/to/file`

**Line X**:
```code
// CURRENT (WRONG):
[code]

// CHANGE TO:
[code]
```

**Impact**: [Explain consequence]

---

## Testing Checklist
[Specific commands and expected results]

---

## Known Issues
[Documented problems]

---

## Verification Commands
```bash
# Commands to verify fix is complete
```

---

## Dependencies
[Any prerequisites]

---

## Rollback Plan
[How to undo if needed]

---

## Next Steps
1. [Step-by-step action items]
2. [With time estimates]

**Estimated time**: X minutes/hours

---

**Document created**: YYYY-MM-DDTHH:MM:SSZ
**Last updated**: YYYY-MM-DDTHH:MM:SSZ
**Status**: WORK IN PROGRESS
**Priority**: [HIGH/MEDIUM/LOW]
```

### 2. Commit Documentation

```bash
git add [SUMMARY].md [REMAINING_WORK].md
git commit -m "Add comprehensive documentation for [feature]

Documents completed work and remaining tasks.

Date: YYYY-MM-DDTHH:MM:SSZ
Signed-off-by: [AI Model] <email>"
```

### 3. Create Pull Request

Use `gh pr create` with comprehensive body:

```bash
gh pr create --title "[Type]: [Clear description]" --body "$(cat <<'EOFPR'
## Problem
[Brief description]

## Root Cause
[Brief technical explanation]

## Changes Made (Partial Fix)
1. ✅ [Change 1]
2. ✅ [Change 2]
3. ✅ [Change 3]

## Remaining Work ⚠️
**See `REMAINING_WORK.md` for complete details**

### Still Need to Fix:
- [ ] Component 1: [description]
- [ ] Component 2: [description]

## Testing Status
- ✅ Builds successfully
- ❌ [Feature] still fails
- ⏳ Needs complete application of fixes

## Files Changed
- [List of files]

## Notes
[Important context]

---
**Signed**: YYYY-MM-DDTHH:MM:SSZ
**Documentation**: See `[SUMMARY].md` and `REMAINING_WORK.md`
EOFPR
)"
```

### 4. Update Todo List

```bash
# Mark completed items
# Add new actionable items from REMAINING_WORK.md
# Include PR number in todos
```

---

## Documentation Standards

### DateTime Signatures

**Always include datetime signatures in**:
1. MD file headers
2. Git commit messages
3. PR descriptions
4. Todo updates

**Format**:
- ISO 8601: `YYYY-MM-DDTHH:MM:SSZ`
- Example: `2026-01-08T21:08:00Z`

**Include**:
```markdown
**Date**: 2026-01-08
**Time**: 21:08:00 UTC
**Signed by**: Claude Opus 4.5 (claude-sonnet-4-5-20250929)
```

**In commits**:
```
Date: 2026-01-08T21:08:00Z
Signed-off-by: Claude Opus 4.5 <noreply@anthropic.com>
```

### Status Markers

Use consistent emoji/markers:
- ✅ Completed
- ❌ Incomplete/Failing
- ⏳ Pending/In Progress
- ⚠️ Warning/Attention Needed
- 📝 Documentation
- 🔧 Configuration
- 🐛 Bug Fix
- ✨ New Feature

### Priority Levels

Use clear priority markers:
- **HIGH**: Blocks core functionality
- **MEDIUM**: Affects secondary features
- **LOW**: Nice to have, no user impact

---

## Code Change Documentation

### For Each Changed File

```markdown
### [Component Name] ([PRIORITY])
**File**: `src/path/to/file.cs`

**Line(s)**: 42, 108, 234

**Current code (WRONG)**:
```csharp
var config = new Config(apiKey);
```

**Change to**:
```csharp
var config = Config.FromConfiguration(configuration);
```

**Impact**: [Explain what breaks without this fix]
**Reason**: [Explain why the change is needed]
**Dependencies**: [List any prerequisites]
```

---

## Verification Steps

### Always Include

1. **Build verification commands**
   ```bash
   cd /path/to/project
   dotnet build
   # Expected: 0 errors
   ```

2. **Search commands to verify fix completeness**
   ```bash
   grep -rn "OldPattern" src/ --include="*.cs"
   # Expected: 0 results (or only comments)
   ```

3. **Runtime testing steps**
   - Specific API calls to test
   - Expected responses
   - How to verify logs

4. **Regression testing**
   - What else might break
   - How to test it

---

## Common Pitfalls

### 1. Linter Interference
**Problem**: Linter reverts changes during development

**Solution**:
- Make all changes in focused session
- Commit immediately
- Verify with `git diff` before committing
- Document linter behavior in NOTES section

### 2. Incomplete Testing
**Problem**: Fix appears to work but doesn't

**Solution**:
- Always test end-to-end, not just compilation
- Include specific test commands in docs
- Document expected vs actual results

### 3. Lost Context
**Problem**: Returning to work later, forgot details

**Solution**:
- Document EVERYTHING in REMAINING_WORK.md
- Include line numbers and exact code snippets
- Add "why" explanations, not just "what"

### 4. Scattered Changes
**Problem**: Can't remember all files that need changes

**Solution**:
- Use grep to find ALL occurrences upfront
- List every file and line number
- Include verification command to confirm completeness

---

## Integration with Control Plane

### File Locations

Place documentation in:
- **Project repo**: `[PROJECT_ROOT]/[FEATURE]_SUMMARY.md`
- **Project repo**: `[PROJECT_ROOT]/REMAINING_WORK.md`
- **Control plane**: `C:\scripts\_machine\best-practices\[PATTERN].md`
- **Architecture docs**: `C:\scripts\_machine\[COMPONENT]_DEEP_DIVE.md`

### Linking

In control plane docs, reference active PRs:
```markdown
## Active Work
- PR #13: Chat LLM Config Fix
  - Status: INCOMPLETE
  - Docs: REMAINING_WORK.md
  - Priority: HIGH
  - Blocking: Chat functionality
```

---

## Example: Real-World Application

See:
- **PR**: https://github.com/martiendejong/Hazina/pull/13
- **Summary**: `C:\Projects\hazina\CHAT_FIX_SUMMARY.md`
- **Remaining**: `C:\Projects\hazina\REMAINING_WORK.md`

This PR demonstrates the pattern with:
- Partial fix (3 of 3 files changed, but 1 of 4 locations incomplete)
- Clear documentation of what's left
- Verification commands
- Testing checklist
- Rollback plan

---

## Checklist for This Pattern

When creating incomplete PR:

- [ ] Create SUMMARY.md with full technical details
- [ ] Create REMAINING_WORK.md with action items
- [ ] Add datetime signatures to all docs
- [ ] Commit documentation before PR
- [ ] Push branch with docs
- [ ] Create PR with comprehensive body
- [ ] Reference both MD files in PR
- [ ] Use status markers (✅/❌/⏳)
- [ ] Include verification commands
- [ ] Add testing checklist
- [ ] Document known issues
- [ ] Add rollback plan
- [ ] Update todo list
- [ ] Create lesson in C:\scripts\_machine\best-practices

---

## Benefits of This Pattern

1. **Continuity**: Anyone can pick up the work
2. **Clarity**: Exactly what's done and what's left
3. **Searchability**: Easy to find with grep/search
4. **Accountability**: Datetime signatures track work
5. **Quality**: Thorough documentation prevents mistakes
6. **Efficiency**: No time wasted figuring out what's left
7. **Communication**: Clear status for reviewers

---

## Anti-Patterns to Avoid

❌ **Don't**:
- Create PR with vague "WIP" title
- Commit without documentation
- List todos in PR comments (use MD files)
- Forget datetime signatures
- Skip verification commands
- Assume someone knows the context

✅ **Do**:
- Be exhaustively specific
- Include every file and line number
- Write for someone with zero context
- Sign and date everything
- Make docs self-contained
- Test your own documentation

---

**Document created**: 2026-01-08T21:08:00Z
**Last updated**: 2026-01-08T21:08:00Z
**Pattern verified**: hazina PR #13
**Status**: ACTIVE PATTERN
**Category**: Development Workflow
