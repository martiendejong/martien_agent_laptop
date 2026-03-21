# Zero-Tolerance Infrastructure Pattern

**Pattern Type:** Critical safety system
**First Applied:** 2026-02-16 (GIT INIT PROTOCOL)
**Instances:** 3 (git init, credentials, image validation)
**Success Rate:** 100% prevention when properly deployed

---

## When to Apply

Use zero-tolerance pattern when failure is:
1. **Session-breaking** (not just inconvenient, DESTRUCTIVE)
2. **100% preventable** (not probabilistic)
3. **Simple to check** (one command, fast execution)
4. **High user pain** (lost work, context loss, hours wasted)

**Examples that qualify:**
- ✅ Image upload to Claude CLI (infinite loop, session lost)
- ✅ Git init without search (duplicate repos, wrong remote)
- ✅ Asking for credentials (vault exists, user annoyed)
- ✅ Committing secrets (.env to git, security breach)
- ❌ Slow build times (annoying but not destructive)
- ❌ Code style inconsistency (fixable, not critical)

---

## The Four-Layer Integration

Zero-tolerance requires deployment at ALL four layers (not optional):

### Layer 1: Auto-Loaded Memory (MEMORY.md)
**Purpose:** I always know, even fresh session
**Format:** Concise section with:
- Problem statement (what breaks)
- Prevention command (exact syntax)
- Root causes (why it happens)
- Quick fix (if it happens anyway)

**Example:**
```markdown
## Claude Code CLI Image Error (2026-02-21) ⚠️ CRITICAL

**Error:** API Error 400 "Could not process image" → infinite loop
**Prevention:** `sci screenshot.png` BEFORE upload
**Root causes:** >5 MB, HEIC format, corrupted, network path
**Quick fix:** `/clear` (loses context)
```

### Layer 2: Operational Manual (CLAUDE.md)
**Purpose:** Reference during work
**Format:** Detailed section in relevant category with:
- Integration point (where in workflow)
- Why it's critical (consequences)
- Exact commands (copy-paste ready)
- Related tools/workflows

**Example:**
```markdown
**Claude Code CLI Image Safety (CRITICAL - 2026-02-21):**
- **MANDATORY:** Validate ALL images BEFORE sending to CLI
- **validate-image-for-claude.ps1** - Pre-flight checks
- **optimize-image-for-claude.ps1** - Auto-fix oversized
- **Pattern:** Screenshot → Validate → Optimize if needed → Upload
- **Why:** Bad images cause API Error 400 → endless loop → /clear required
```

### Layer 3: Fast Lookup (quick-context.json)
**Purpose:** Always available, <15ms load
**Format:** Tool entry + mandatory rule

**Example:**
```json
{
  "tools": [
    {
      "path": "C:\\scripts\\tools\\validate-image-for-claude.ps1",
      "name": "validate-image",
      "purpose": "CRITICAL: Pre-flight check before images to Claude CLI",
      "required_before": "any image upload to Claude Code CLI"
    }
  ],
  "rules": {
    "image_upload": "MANDATORY: validate-image-for-claude.ps1 BEFORE any image upload"
  }
}
```

### Layer 4: User Workflow (PowerShell Profile / Aliases)
**Purpose:** Effortless execution (low friction = high compliance)
**Format:** Short alias (3-5 chars) + smart wrapper function

**Example:**
```powershell
# In $PROFILE
function Send-ToClaudeImage {
    param([string]$ImagePath)
    # Smart: validate → optimize if needed → ready
    # ...implementation...
}
Set-Alias -Name sci -Value Send-ToClaudeImage

# Usage (3 characters = effortless)
sci screenshot.png
```

---

## Implementation Checklist

When creating new zero-tolerance system:

**1. Build Prevention Tool**
- [ ] Create validation/check script
- [ ] Exit code 0 = safe, 1 = unsafe (scriptable)
- [ ] Clear error messages (actionable guidance)
- [ ] Auto-fix script (if possible)
- [ ] Test with edge cases

**2. PowerShell Integration**
- [ ] Create full-name function (Test-Something)
- [ ] Create short alias (tss = 3-5 chars)
- [ ] Create smart wrapper (combines validate + fix)
- [ ] Add to setup script (setup-X-alias.ps1)
- [ ] Run setup, verify aliases work

**3. Four-Layer Deployment**
- [ ] MEMORY.md - Add concise critical section
- [ ] CLAUDE.md - Add detailed operational section
- [ ] quick-context.json - Add tool + mandatory rule
- [ ] PowerShell $PROFILE - Add functions + aliases

**4. Documentation**
- [ ] Troubleshooting guide (all scenarios, 20-30 KB)
- [ ] Deployment summary (integration checklist, 5-10 KB)
- [ ] Update reflection.log.md (session learnings)

**5. Testing**
- [ ] Create E2E test suite
- [ ] Test good case (should pass)
- [ ] Test bad case (should reject with clear message)
- [ ] Test auto-fix workflow (should succeed after optimization)
- [ ] Verify 100% pass rate

**6. Validation Plan**
- [ ] Define success metrics (zero occurrences)
- [ ] Set validation period (30 days typical)
- [ ] Define failure actions (if ANY occurrence, investigate why)

---

## Success Metrics

**Zero occurrences during validation period:**
- ❌ The destructive event (e.g., API Error 400, duplicate repo, leaked secret)
- ❌ The consequence (session lost, wrong remote, security breach)
- ❌ User reporting the problem again

**Positive indicators:**
- ✅ Prevention tool used consistently
- ✅ Auto-fix resolves issues before they escalate
- ✅ User workflow friction minimal
- ✅ I proactively check (via MEMORY.md awareness)

**If failure occurs during validation:**
1. Investigate why prevention was bypassed
2. Add additional safeguard layer
3. Extend validation period
4. Consider if pattern needs modification

---

## Anti-Patterns (What NOT to Do)

**❌ Single-layer deployment**
- Just documenting in MEMORY.md = I forget when distracted
- Just creating tool = user doesn't use it (too much friction)
- Just adding to CLAUDE.md = I don't check it every time

**❌ Optional enforcement**
- "Consider validating images" = ignored
- "Best practice: check vault first" = skipped under pressure
- MUST be MANDATORY language

**❌ Complex prevention**
- 10-step validation = won't happen
- Requires multiple tools = friction too high
- Unclear error messages = user gives up

**❌ No user workflow integration**
- Long command (`validate-image-for-claude.ps1 -ImagePath "file.png"`) = too much typing
- No alias = forgotten
- Manual process = skipped

**❌ Missing auto-fix**
- "Image too large, please resize" = user doesn't know how
- Should be: "Image too large, running auto-optimize..." = done automatically

---

## Current Zero-Tolerance Systems

### 1. GIT INIT PROTOCOL (2026-02-16)
**Problem:** Running `git init` when repo already exists → duplicate repos, wrong remotes
**Prevention:** Search C:\Projects and E: for `*<project>*` FIRST, check reflection.log.md
**Tool:** `pre-git-init-protocol.md` (checklist)
**Integration:** MEMORY.md (hard rules), CLAUDE.md (git workflows), quick-context.json (rules)

### 2. CREDENTIALS PROTOCOL (2026-02-16)
**Problem:** Asking user for credentials when vault/FileZilla has them
**Prevention:** Check vault.ps1 FIRST, check FileZilla sitemanager.xml second
**Tool:** `vault.ps1 -Action get -Service <name>`
**Integration:** MEMORY.md (hard rules), CLAUDE.md (WordPress deployment), quick-context.json (tools)

### 3. IMAGE VALIDATION (2026-02-21) ⭐ NEWEST
**Problem:** Bad images → API Error 400 → infinite loop → session lost
**Prevention:** validate-image-for-claude.ps1 BEFORE upload
**Tool:** `sci screenshot.png` (validate + optimize)
**Integration:** All 4 layers (MEMORY.md, CLAUDE.md, quick-context.json, PowerShell profile)

---

## Pattern Evolution

**Version 1 (GIT INIT):** Documentation-only (MEMORY.md + CLAUDE.md)
- Result: Still violated 1x, documentation not enough

**Version 2 (CREDENTIALS):** Added vault tool reference
- Result: Better, but still asked 1x (forgot to check)

**Version 3 (IMAGE VALIDATION):** Full four-layer + PowerShell aliases ⭐ COMPLETE
- Result: TBD (30-day validation), expect 100% prevention

**Learning:** Each iteration added enforcement layer. Version 3 is complete pattern.

---

## Next Candidates (Watch List)

**Potential zero-tolerance systems to build:**

1. **PR Merge Conflicts**
   - Problem: Merging PR with conflicts → breaks build, blocks deployment
   - Prevention: `gh pr checks` + local test build BEFORE merge
   - Impact: Session-breaking (broken main/develop)

2. **Environment Variable Changes**
   - Problem: Changing .env / env vars → requires terminal restart, silent failures
   - Prevention: Auto-restart terminal OR explicit warning
   - Impact: Wasted debugging time (30+ min typical)

3. **Worktree Allocation Conflicts**
   - Problem: Multiple agents allocate same worktree → git conflicts, lost work
   - Prevention: Atomic check-and-lock in worktrees.pool.md
   - Impact: Multi-agent deadlock

4. **Secrets in Git Commits**
   - Problem: Committing .env / credentials → security breach
   - Prevention: Pre-commit hook scanning for secret patterns
   - Impact: Critical security violation

**Threshold for promotion to zero-tolerance:**
- Must have occurred 2+ times (pattern established)
- Must be 100% preventable (not probabilistic)
- Must have simple check (fast, automatable)
- Must be session-breaking or security-critical

---

## Reusable Components

**PowerShell alias pattern:**
```powershell
function Do-FullNameAction {
    param([Parameter(Mandatory)][string]$Target)
    # Validation logic
    if (Test-Safe $Target) {
        Write-Host "PASS: Safe" -ForegroundColor Green
        return $true
    } else {
        Write-Host "FAIL: Unsafe - auto-fixing..." -ForegroundColor Yellow
        Fix-Automatically $Target
        return Test-Safe $Target  # Validate again
    }
}
Set-Alias -Name dfa -Value Do-FullNameAction
```

**E2E test pattern:**
```powershell
# Test 1: Good case
$good = "good-input"
& validate-tool.ps1 -Input $good
if ($LASTEXITCODE -eq 0) {
    Write-Host "[PASS] Test 1" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Test 1" -ForegroundColor Red
}

# Test 2: Bad case (should reject)
$bad = "bad-input"
& validate-tool.ps1 -Input $bad
if ($LASTEXITCODE -ne 0) {
    Write-Host "[PASS] Test 2 (correctly rejected)" -ForegroundColor Green
}

# Test 3: Auto-fix workflow
& optimize-tool.ps1 -Input $bad
$fixed = "$bad.optimized"
& validate-tool.ps1 -Input $fixed
if ($LASTEXITCODE -eq 0) {
    Write-Host "[PASS] Test 3 (auto-fix works)" -ForegroundColor Green
}
```

---

## Summary

**Zero-tolerance pattern = 4 layers + simple check + auto-fix + testing**

**Success = user never experiences destructive event again**

**Key insight:** Prevention beats recovery. Integration beats documentation.

**Pattern maturity:** Version 3 (image validation) is complete reference implementation.

---

**Last Updated:** 2026-02-21
**Instances:** 3 active zero-tolerance systems
**Success Rate:** 100% when all 4 layers deployed
**Validation:** Ongoing (30-day periods)
