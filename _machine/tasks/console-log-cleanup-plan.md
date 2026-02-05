# Console.log Cleanup Plan

**Created:** 2026-02-05 05:40 UTC
**Status:** Ready for execution when base repo clean
**Scope:** 327 console.log statements in src/ (920 total including node_modules)

---

## 📊 Current State

### Statistics
- **Total:** 920 console.log statements
- **In src/:** 327 (our code)
- **In node_modules/:** 593 (external, ignore)

### Top Files (by count)
1. `ImageSet.tsx` - 81 console.logs (25% of total!)
2. `ChatWindow.tsx` - 46 console.logs
3. `activity.ts` - 21 console.logs
4. `useChatConnectionV2.ts` - 18 console.logs
5. `AnalysisEditor.tsx` - 17 console.logs
6. `DynamicActionsSidebar.tsx` - 17 console.logs

### Categories Identified
- **Debug logs:** 75+ instances (marked with 🎨, DEBUG, etc.)
- **Temporary logs:** ~50 instances (TEMP, TODO comments nearby)
- **Meaningful logs:** ~50 instances (error conditions, important state changes)
- **Noise logs:** ~150 instances (props logging, render tracking)

---

## 🎯 Cleanup Strategy

### Phase 1: Remove Obvious Debug Logs (Target: -150 logs)
Remove logs with debug markers:
- `console.log('🎨 [Component] ...')`
- `console.log('DEBUG: ...')`
- `console.log('TEMP: ...')`
- `console.log('Value:', value)` (simple value dumps)

### Phase 2: Replace with devTools (Target: -100 logs)
Replace remaining development logs with the new `devTools.ts` utility:
```typescript
import { devLog } from '@/utils/devTools'
devLog('Component mounted', { props }) // Only logs in development
```

Benefits:
- Auto-disabled in production
- Consistent formatting
- Easy to grep for cleanup later

### Phase 3: Keep Strategic Logs (Target: ~77 remaining)
Preserve meaningful logs:
- Error conditions
- Important state transitions
- User-facing operations (upload, publish, etc.)
- Integration points (SignalR, API calls)

### Target Outcome
- **Before:** 327 console.logs
- **After:** ~77 console.logs (77% reduction)
- **All remaining:** Either production-safe or wrapped in `isDev` checks

---

## 📋 File-by-File Plan

### High Priority (81 logs in 1 file!)
**`ClientManagerFrontend/src/components/view/analysis/ImageSet.tsx`** (81 logs)
- Lines 26-34: Remove debug logs for value preview
- Replace all debug emoji logs (🎨) with devLog
- Keep error logs for image operations
- Estimated: 81 → 10 logs (88% reduction)

### Medium Priority (46-21 logs per file)
1. **`ChatWindow.tsx`** (46 logs)
   - Remove message logging
   - Keep connection errors
   - Estimated: 46 → 8 logs

2. **`activity.ts`** (21 logs)
   - Remove service call logging
   - Keep error handling
   - Estimated: 21 → 4 logs

3. **`useChatConnectionV2.ts`** (18 logs)
   - Remove state change logs
   - Keep connection errors
   - Estimated: 18 → 3 logs

### Low Priority (17 logs per file)
- `AnalysisEditor.tsx` (17) → 5 logs
- `DynamicActionsSidebar.tsx` (17) → 4 logs
- `useChatConnection.ts` (15) → 3 logs
- `signalRBridge.ts` (13) → 5 logs

### Remaining Files
All files with <10 logs: Review and reduce by ~70%

---

## 🛠️ Implementation Steps

### 1. Allocate Worktree
```bash
# When base repo is clean
bash C:/scripts/tools/check-branch-conflicts.sh client-manager cleanup/console-logs
# Allocate agent-XXX with paired worktrees
```

### 2. Branch Strategy
```bash
cd C:/Projects/worker-agents/agent-XXX/client-manager
git checkout -b cleanup/console-logs
```

### 3. Systematic Cleanup
```bash
# Start with ImageSet.tsx (biggest win)
# Edit file, remove debug logs
# Test in development: npm run dev
# Verify no console errors

# Move to next high-priority files
# Repeat: Edit → Test → Commit
```

### 4. Testing Checklist
- [ ] Development build succeeds
- [ ] No runtime errors in browser console
- [ ] Image generation still works (ImageSet.tsx critical)
- [ ] Chat functionality intact (ChatWindow.tsx)
- [ ] Activity feed loads (activity.ts)

### 5. Commit Strategy
Small, focused commits:
```
git commit -m "refactor: Remove debug console.logs from ImageSet.tsx (81 → 10)"
git commit -m "refactor: Clean up ChatWindow console.logs (46 → 8)"
git commit -m "refactor: Replace service logs with devLog in activity.ts"
```

### 6. PR Creation
```bash
gh pr create --base develop \
  --title "refactor: Console.log cleanup (327 → ~77, 77% reduction)" \
  --body "..."
```

---

## 🧪 Testing Strategy

### Manual Testing Required
1. **ImageSet component** (CRITICAL - 81 logs removed)
   - Generate logo with AI
   - Regenerate specific variant
   - Download SVG
   - Select/deselect variants

2. **Chat Window** (46 logs removed)
   - Send messages
   - Receive responses
   - Scroll behavior
   - Message history

3. **Activity Service** (21 logs removed)
   - Load activity feed
   - Create new activity
   - Update activity status

### Automated Testing
```bash
# Frontend tests
cd ClientManagerFrontend
npm run test

# Lint check
npm run lint

# Build verification
npm run build
```

---

## 📈 Expected Impact

### Performance
- Minimal (console.log has low overhead)
- Cleaner browser console in development
- No production impact (most were dev-only)

### Developer Experience
- **Huge win** - 77% cleaner console output
- Easier debugging (signal in noise ratio improved)
- Professional codebase appearance

### Code Quality
- Removes code smell (excessive logging)
- Sets precedent for using devTools.ts
- Demonstrates systematic cleanup approach

---

## ⚠️ Risks & Mitigations

### Risk 1: Breaking Functionality
**Mitigation:** Test each major file after cleanup
**Fallback:** Small commits make revert easy

### Risk 2: Hidden Dependencies
**Mitigation:** Some logs might be checked by tests
**Action:** Run full test suite before PR

### Risk 3: Merge Conflicts
**Mitigation:** Active files (ImageSet, ChatWindow) likely to have conflicts
**Action:** Merge develop frequently, communicate with other agents

---

## 🎯 Success Criteria

✅ **Cleanup successful ONLY IF:**
- 327 → ~77 console.logs (77% reduction)
- All tests passing
- Manual testing of top 5 files completed
- Build succeeds (frontend + backend)
- PR created with comprehensive changelog
- No production errors after merge

---

## 📝 Notes for Executor

**Branch:** `cleanup/console-logs`
**Paired Worktrees:** client-manager (no Hazina changes needed)
**Estimated Time:** 2-3 hours for thorough cleanup + testing
**Best Time:** When base repo is clean (no active debugging)

**Key Files Reference:**
```bash
# Quick grep to see current state
cd C:/Projects/client-manager/ClientManagerFrontend/src
grep -r "console\.log" --include="*.ts" --include="*.tsx" | wc -l

# Top offenders
grep -r "console\.log" --include="*.ts" --include="*.tsx" | \
  cut -d: -f1 | sort | uniq -c | sort -rn | head -10
```

---

**Created by:** Jengo (Autonomous Agent)
**Ready for:** Any future session when base repo is clean
**Priority:** Medium (code quality improvement, not critical)
