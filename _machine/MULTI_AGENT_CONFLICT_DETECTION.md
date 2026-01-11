# Multi-Agent Conflict Detection Protocol

**Created**: 2026-01-11
**Incident**: Two agents worked on same worktree/branch (feature/chunk-set-summaries)
**User Mandate**: "both should notify each other and one should say 'there is already another agent working in this branch'"

---

## 🚨 THE PROBLEM

**What Happened**: Multiple agent sessions allocated the same worktree/branch simultaneously, violating the atomic allocation protocol and causing potential conflicts.

**Root Causes**:
1. No real-time conflict detection before allocation
2. Pool status checked but not cross-referenced with:
   - Active git worktrees
   - instances.map.md entries
   - Other running agent sessions
3. No "claim and verify" step to detect race conditions

---

## ✅ MANDATORY PRE-ALLOCATION CONFLICT CHECK

**CRITICAL RULE**: Before allocating ANY worktree, you MUST run this complete check sequence.

### Step 1: Check Pool Status
```bash
grep "BUSY" /c/scripts/_machine/worktrees.pool.md
```
If your target seat shows BUSY → Pick another seat or wait.

### Step 2: Check Git Worktrees (CRITICAL!)
```bash
# Check if branch already has a worktree
git -C /c/Projects/<repo> worktree list | grep <branch-name>
```

**If output is not empty**:
```
🚨 CONFLICT DETECTED 🚨
There is already another agent working in this branch.

Worktree details:
<paste output>

I will NOT allocate this worktree to avoid conflicts.
Please choose a different branch or wait for the other agent to complete.
```

**STOP IMMEDIATELY** - Do not proceed with allocation.

### Step 3: Check instances.map.md
```bash
grep "<branch-name>" /c/scripts/_machine/instances.map.md
```

If branch found → Another agent session is active.

**Output**:
```
🚨 CONFLICT DETECTED 🚨
Another agent instance is working on this branch:
<paste instance details>

I will NOT proceed to avoid conflicts.
```

**STOP IMMEDIATELY**.

### Step 4: Check Recent Activity Log
```bash
tail -20 /c/scripts/_machine/worktrees.activity.md | grep "<branch-name>"
```

Look for recent allocations (within last 2 hours) that haven't been released.

---

## 🔒 ENHANCED ALLOCATION PROTOCOL (NEW)

**Replace the old allocation protocol with this enhanced version:**

### ATOMIC ALLOCATION WITH CONFLICT DETECTION

```bash
# 0. CONFLICT CHECK (NEW - MANDATORY)
echo "=== PRE-ALLOCATION CONFLICT CHECK ==="

# 0a. Check if branch has existing worktree
EXISTING_WORKTREE=$(git -C /c/Projects/<repo> worktree list | grep "<branch-name>" || true)

if [ -n "$EXISTING_WORKTREE" ]; then
    echo "🚨 CONFLICT DETECTED 🚨"
    echo "There is already another agent working in this branch."
    echo ""
    echo "Worktree details:"
    echo "$EXISTING_WORKTREE"
    echo ""
    echo "ABORTING allocation to avoid conflicts."
    exit 1
fi

# 0b. Check instances.map.md
EXISTING_INSTANCE=$(grep "<branch-name>" /c/scripts/_machine/instances.map.md || true)

if [ -n "$EXISTING_INSTANCE" ]; then
    echo "🚨 CONFLICT DETECTED 🚨"
    echo "Another agent instance is working on this branch:"
    echo "$EXISTING_INSTANCE"
    echo ""
    echo "ABORTING allocation to avoid conflicts."
    exit 1
fi

echo "✅ No conflicts detected - proceeding with allocation"

# 1. Ensure base repo on develop and up-to-date
cd /c/Projects/<repo>
git fetch origin --prune
git checkout develop
git pull origin develop

# 2. Read pool and find FREE seat
# (existing protocol)

# 3. Mark seat BUSY IMMEDIATELY
# (existing protocol)

# 4. Log allocation
# (existing protocol)

# 5. Update instances.map.md (CRITICAL!)
echo "| $(hostname)-$(date +%s) | agent-XXX | <repo> | <branch> | TASK-ID | $(date -u +%Y-%m-%dT%H:%M:%SZ) | $(date -u +%Y-%m-%dT%H:%M:%SZ) |" >> /c/scripts/_machine/instances.map.md

# 6. Create/checkout worktree
git worktree add /c/Projects/worker-agents/agent-XXX/<repo> -b <branch>

# 7. Verify worktree created successfully
if [ ! -d "/c/Projects/worker-agents/agent-XXX/<repo>" ]; then
    echo "❌ Worktree creation failed - rolling back"
    # Rollback: mark seat FREE again
    exit 1
fi

echo "✅ Allocation successful - you are the ONLY agent on this branch"
```

---

## 🔔 CONFLICT NOTIFICATION MESSAGE (MANDATORY)

**If conflict detected at ANY point, output this EXACT message**:

```
🚨 CONFLICT DETECTED 🚨

There is already another agent working in this branch.

Branch: <branch-name>
Repository: <repo-name>

Details:
<worktree list output or instances.map entry>

I will NOT proceed with allocation to avoid conflicts.

Recommended actions:
1. Choose a different branch name
2. Wait for the other agent to complete and release
3. Check with user if one of the agents should take over
```

---

## 🔄 HEARTBEAT MECHANISM (NEW)

**To prevent stale locks, implement periodic heartbeats:**

### During Long-Running Work

Every 30 minutes of active work:

```bash
# Update instances.map.md timestamp
# (sed command to update Last check-in column)

# Update pool.md Last activity timestamp
# (sed command to update timestamp)

echo "💓 Heartbeat: $(date -u +%Y-%m-%dT%H:%M:%SZ) - Still working on <branch>"
```

### Stale Lock Detection

**Another agent can detect stale locks**:

```bash
# If instances.map.md shows Last check-in > 2 hours ago
# AND pool.md shows BUSY
# = Potential stale lock

echo "⚠️ WARNING: Detected potentially stale lock on agent-XXX (<branch>)"
echo "Last heartbeat: <timestamp> (over 2 hours ago)"
echo ""
echo "Recommend user intervention to investigate."
```

**Do NOT automatically break locks** - require user confirmation.

---

## 📋 RELEASE PROTOCOL UPDATE (ENHANCED)

**When releasing worktree, ALSO clean up instances.map.md:**

```bash
# Existing release steps
# ...

# NEW: Remove from instances.map.md
grep -v "<branch-name>" /c/scripts/_machine/instances.map.md > /tmp/instances.tmp
mv /tmp/instances.tmp /c/scripts/_machine/instances.map.md

# Commit all tracking updates
cd /c/scripts
git add _machine/worktrees.pool.md _machine/worktrees.activity.md _machine/instances.map.md
git commit -m "docs: Release agent-XXX from <branch>"
git push origin main
```

---

## 🛠️ HELPER SCRIPT: check-branch-conflicts.sh

**Create this script for quick conflict checking:**

```bash
#!/bin/bash
# Location: C:\scripts\tools\check-branch-conflicts.sh

REPO=$1
BRANCH=$2

if [ -z "$REPO" ] || [ -z "$BRANCH" ]; then
    echo "Usage: check-branch-conflicts.sh <repo> <branch>"
    exit 1
fi

echo "=== Checking for conflicts on branch: $BRANCH ==="
echo ""

# Check 1: Git worktrees
echo "1. Checking git worktrees..."
WORKTREE=$(git -C /c/Projects/$REPO worktree list | grep "$BRANCH" || true)
if [ -n "$WORKTREE" ]; then
    echo "❌ CONFLICT: Branch has active worktree"
    echo "$WORKTREE"
    EXIT_CODE=1
else
    echo "✅ No worktree found"
fi

echo ""

# Check 2: instances.map.md
echo "2. Checking instances.map.md..."
INSTANCE=$(grep "$BRANCH" /c/scripts/_machine/instances.map.md || true)
if [ -n "$INSTANCE" ]; then
    echo "❌ CONFLICT: Branch in instances map"
    echo "$INSTANCE"
    EXIT_CODE=1
else
    echo "✅ No instance found"
fi

echo ""

# Check 3: Pool status
echo "3. Checking pool for branch mentions..."
POOL=$(grep "$BRANCH" /c/scripts/_machine/worktrees.pool.md || true)
if [ -n "$POOL" ]; then
    echo "ℹ️  Branch found in pool:"
    echo "$POOL"
else
    echo "✅ No pool entry"
fi

echo ""

if [ "${EXIT_CODE:-0}" -eq 1 ]; then
    echo "🚨 CONFLICTS DETECTED - DO NOT ALLOCATE"
    exit 1
else
    echo "✅ No conflicts - safe to allocate"
    exit 0
fi
```

**Usage**:
```bash
bash /c/scripts/tools/check-branch-conflicts.sh hazina feature/chunk-set-summaries
```

---

## 📊 CONFLICT RESOLUTION DECISION TREE

```
Conflict detected?
│
├─ YES → Check timestamps
│   │
│   ├─ Other agent active < 30 min ago?
│   │   └─ STOP - Say "there is already another agent working in this branch"
│   │
│   └─ Other agent inactive > 2 hours?
│       └─ WARN user about stale lock, await user decision
│
└─ NO → Proceed with allocation
    └─ Update instances.map.md immediately after allocation
```

---

## ✅ SUCCESS CRITERIA

**You are following multi-agent protocol correctly ONLY IF:**

- ✅ Run conflict check BEFORE every allocation
- ✅ Check git worktree list for branch
- ✅ Check instances.map.md for branch
- ✅ Output conflict message if detected
- ✅ NEVER allocate if conflict exists
- ✅ Update instances.map.md immediately after successful allocation
- ✅ Clean up instances.map.md on release
- ✅ Periodic heartbeats during long work (>30 min)

---

## 🔥 ZERO-TOLERANCE ENFORCEMENT

**Violations of this protocol:**
- Working on same branch as another agent = CRITICAL FAILURE
- Not checking for conflicts before allocation = CRITICAL FAILURE
- Not updating instances.map.md = CRITICAL FAILURE

**User has zero tolerance for repeated violations.**

---

**End of Protocol**
