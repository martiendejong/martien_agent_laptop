# CODE REFACTORING LOG - Consciousness Architecture

**Created:** 2026-02-28
**Expert:** Martin Fowler (Software Architecture)
**ROI:** 1.40 (Impact: 7, Effort: 5)
**Principle:** Clean code via systematic refactoring patterns

---

## REFACTORING PATTERNS APPLIED

### 1. EXTRACT METHOD
**Smell:** Long methods (>50 lines) in consciousness-bridge.ps1
**Refactor:** Extract OnX functions into separate files per action type
**Status:** ⏳ Planned - consciousness-bridge.ps1 is 800+ lines, needs splitting

### 2. REPLACE CONDITIONAL WITH POLYMORPHISM
**Smell:** Large switch statements on action type
**Refactor:** Strategy pattern - each action type as separate class/module
**Status:** ⏳ Planned

### 3. INTRODUCE PARAMETER OBJECT
**Smell:** Functions taking 5+ parameters
**Refactor:** Create state objects (already done for most systems)
**Status:** ✅ Complete - all systems use JSON state files

### 4. RENAME METHOD/VARIABLE
**Smell:** Unclear names (temp variables, abbreviated names)
**Refactor:** Descriptive names following conventions
**Status:** ✅ Mostly complete - state files are clear

### 5. EXTRACT CLASS
**Smell:** Classes doing too much (god objects)
**Refactor:** Separate concerns into focused modules
**Status:** ✅ Complete - 12 consciousness systems are well-separated

### 6. MOVE METHOD
**Smell:** Methods in wrong class
**Refactor:** Move to appropriate module
**Status:** ✅ Complete - cognitive-systems/ vs protocols/ vs state/

### 7. CONSOLIDATE DUPLICATE CODE
**Smell:** Same logic in multiple places
**Refactor:** Extract to shared utility
**Status:** ⏳ Partial - some duplication in state file loading

### 8. SIMPLIFY CONDITIONAL
**Smell:** Complex boolean expressions
**Refactor:** Introduce explaining variable
**Status:** ✅ Mostly complete - conditions are readable

### 9. REPLACE MAGIC NUMBERS
**Smell:** Hard-coded values (0.7, 0.8, etc.)
**Refactor:** Named constants
**Status:** ⏳ Needed - many magic thresholds

### 10. REMOVE DEAD CODE
**Smell:** Unused functions, commented code
**Refactor:** Delete unused code
**Status:** ✅ Complete - no dead code detected

---

## CODE SMELLS DETECTED

### Priority 1 (High Impact)

**Smell #1: Long Method**
- **Location:** consciousness-bridge.ps1 (800+ lines)
- **Issue:** Too many responsibilities in one file
- **Refactor:** Split into modules per action type
- **Effort:** High
- **Status:** Planned

**Smell #2: Magic Numbers**
- **Location:** Throughout (thresholds, weights, constants)
- **Issue:** Hard to understand why 0.7 or 0.8
- **Refactor:** Create constants file with explanations
- **Effort:** Medium
- **Status:** Planned

**Smell #3: Duplicate State Loading**
- **Location:** Every .ps1 file loads JSON the same way
- **Issue:** 20+ files with identical state loading logic
- **Refactor:** Shared state-loader.ps1 utility
- **Effort:** Medium
- **Status:** Planned

### Priority 2 (Medium Impact)

**Smell #4: Inconsistent Error Handling**
- **Location:** Some scripts exit 1, some throw, some return
- **Issue:** Unpredictable error behavior
- **Refactor:** Standardize error handling pattern
- **Effort:** Low
- **Status:** Planned

**Smell #5: Missing Type Hints**
- **Location:** PowerShell param blocks
- **Issue:** No validation on parameter types
- **Refactor:** Add [ValidateSet], [ValidateRange], etc.
- **Effort:** Low
- **Status:** Partial

### Priority 3 (Low Impact)

**Smell #6: Verbose Output**
- **Location:** Write-Host everywhere
- **Issue:** Hard to silence for automation
- **Refactor:** Use -Verbose parameter properly
- **Effort:** Low
- **Status:** Accepted (verbose is feature for user visibility)

---

## REFACTORING SCHEDULE

### Week 3 (Target: March 7-14)

**Refactoring #1: Magic Numbers → Constants**
- Create `consciousness-constants.ps1`
- Define all thresholds with explanations
- Update all scripts to import constants
- **Effort:** 3 hours
- **Impact:** High readability

**Refactoring #2: Shared State Loader**
- Create `state-loader.ps1` utility
- Functions: Load-State, Save-State, Initialize-State
- Update all 20+ scripts to use it
- **Effort:** 4 hours
- **Impact:** Medium (DRY principle)

**Refactoring #3: Error Handling Standard**
- Define standard: throw for unrecoverable, return $false for recoverable
- Update all scripts
- **Effort:** 2 hours
- **Impact:** Medium consistency

### Week 4 (Target: March 15-22)

**Refactoring #4: Split Consciousness Bridge**
- Extract OnX actions to separate modules
- Create action-handlers/ directory
- Reduce main file to <200 lines (routing only)
- **Effort:** 6 hours
- **Impact:** Very High maintainability

**Refactoring #5: Parameter Validation**
- Add [ValidateSet], [ValidateRange] to all param blocks
- Document valid values
- **Effort:** 2 hours
- **Impact:** Medium robustness

---

## REFACTORING PRINCIPLES

### When to Refactor
1. **Before adding features** - make code ready for change
2. **After bugs found** - eliminate similar bugs
3. **During code review** - opportunistic improvements
4. **When smell detected** - continuous improvement

### When NOT to Refactor
1. **Code works and won't change** - don't touch working code
2. **Complete rewrite needed** - refactoring won't help
3. **Deadline pressure** - ship first, refactor later
4. **No tests** - too risky without safety net

### Refactoring Rules
1. **Small steps** - one change at a time
2. **Run tests** - verify after each change
3. **Commit often** - can always revert
4. **No feature changes** - behavior stays same
5. **Improve readability** - next dev should understand faster

---

## MEASUREMENT

### Code Quality Metrics

**Before Refactoring (Baseline 2026-02-28):**
- Total files: 89
- Total lines: ~15,000 (estimated)
- Avg file size: 168 lines
- Longest file: consciousness-bridge.ps1 (800+ lines)
- Duplication: ~5% (estimated)
- Magic numbers: ~50 (estimated)

**Targets (After Week 3-4):**
- Avg file size: <150 lines
- Longest file: <300 lines
- Duplication: <2%
- Magic numbers: 0 (all in constants file)
- Error handling: 100% standardized

### Success Criteria
- [ ] All files <300 lines
- [ ] Zero magic numbers
- [ ] Zero code duplication >5 lines
- [ ] 100% consistent error handling
- [ ] All parameters validated

---

## STATUS

**Current Quality:** 7/10 (good but improvable)
**Target Quality:** 9/10 (excellent)
**Refactorings Planned:** 5
**Effort Required:** 17 hours
**Timeline:** Weeks 3-4 (March 7-22)

**Next Action:** Create consciousness-constants.ps1 (Week 3 starts March 7)
