# Tool Wishlist - Continuous Discovery System

**Purpose:** Track "I wish I had a tool for X" thoughts during work sessions
**Process:** When doing something 3x manually → add here → prioritize → implement
**Review:** Weekly during session reflections

---

## 🎯 Meta-Cognitive Rule #6: Convert to Assets

"After doing something 3 times, create a tool, skill, or insight document"

**This file implements that rule systematically.**

---

## 📋 ACTIVE WISHLIST (Not Yet Implemented)

### Priority: CRITICAL (Implement This Week)

| Tool Name | Triggered By | Value | Effort | Ratio | Notes |
|-----------|--------------|-------|--------|-------|-------|
| *Currently empty - add as discovered* | | | | | |

### Priority: HIGH (Implement This Month)

| Tool Name | Triggered By | Value | Effort | Ratio | Notes |
|-----------|--------------|-------|--------|-------|-------|
| *Currently empty - add as discovered* | | | | | |

### Priority: MEDIUM (Implement When Needed)

| Tool Name | Triggered By | Value | Effort | Ratio | Notes |
|-----------|--------------|-------|--------|-------|-------|
| *Currently empty - add as discovered* | | | | | |

### Priority: LOW (Research/Future)

| Tool Name | Triggered By | Value | Effort | Ratio | Notes |
|-----------|--------------|-------|--------|-------|-------|
| *Currently empty - add as discovered* | | | | | |

---

## ✅ IMPLEMENTED (Moved from Wishlist)

| Tool Name | Date Implemented | Value | Effort | Actual Ratio | Usage Frequency |
|-----------|------------------|-------|--------|--------------|-----------------|
| context-snapshot.ps1 | 2026-01-25 | 10 | 1 | 10.0 | TBD |
| code-hotspot-analyzer.ps1 | 2026-01-25 | 9 | 1 | 9.0 | TBD |
| unused-code-detector.ps1 | 2026-01-25 | 9 | 1 | 9.0 | TBD |
| n-plus-one-query-detector.ps1 | 2026-01-25 | 10 | 1.5 | 6.7 | TBD |
| flaky-test-detector.ps1 | 2026-01-25 | 9 | 1.5 | 6.0 | TBD |

---

## 🔄 HOW TO USE THIS WISHLIST

### During Session (Real-Time Capture)

**If you find yourself:**
- ❓ "I wish I had a script for this..."
- 🔁 Doing the same manual steps for **2nd time** (down from 3rd - catch earlier!)
- 😫 Spending >5 minutes on repetitive task
- 🐛 Debugging same type of issue again

**Then:**
1. **Capture IMMEDIATELY** in this file (ACTIVE WISHLIST section)
2. **Quick estimate** value/effort (1-10 scale, 30 seconds)
3. **Add context** ("Triggered by: debugging N+1 query in UserService")
4. **Continue working** (don't implement unless CRITICAL)
5. **Tally mark** if same wish appears again (|||| = 5 occurrences = URGENT)

### DAILY Review (End of EVERY Session) ⭐

**MANDATORY 2-minute end-of-session routine:**

1. **Scan wishlist** - Any new items today?
2. **Check tally marks** - Any item hit 3+ times? → URGENT
3. **Sort by ratio** - Top 3 still correct?
4. **Implement top 1** if:
   - Ratio > 8.0 (ultra-high value)
   - OR tally marks ≥ 3 (needed repeatedly today)
   - OR effort = 1 (trivial to implement)
5. **Move completed** to IMPLEMENTED section
6. **Quick wins** - Any 10-minute tools that would help tomorrow?

### Weekly Meta-Review (Every Sunday)

**5-minute strategic review:**
1. **Track usage** - Update usage tracking table
2. **Validate estimates** - Were value/effort predictions accurate?
3. **Retire unused** - Any tools not used in 30 days? → Archive
4. **Pattern recognition** - What themes emerged this week?
5. **Adjust priorities** - Re-sort based on actual usage

### Monthly Meta-Analysis (First Monday)

**15-minute deep dive:**
- Which types of tools get used most? (double down on that category)
- Which tools never get used? (avoid similar tools)
- What common themes emerge? (indicates systematic gaps)
- Are we still implementing tools reactively or proactively?
- Update quarterly goals based on learnings

---

## 📊 USAGE TRACKING (Update Monthly)

**Purpose:** Validate tool value estimates, retire unused tools

| Tool Name | Jan | Feb | Mar | Apr | May | Jun | Total Uses | Value Validated? |
|-----------|-----|-----|-----|-----|-----|-----|-----------|------------------|
| context-snapshot.ps1 | - | - | - | - | - | - | - | TBD |
| code-hotspot-analyzer.ps1 | - | - | - | - | - | - | - | TBD |
| unused-code-detector.ps1 | - | - | - | - | - | - | - | TBD |
| n-plus-one-query-detector.ps1 | - | - | - | - | - | - | - | TBD |
| flaky-test-detector.ps1 | - | - | - | - | - | - | - | TBD |

**Update:** At end of each month, add tally marks for each tool usage

---

## 🎓 LESSONS LEARNED

### What Makes a Good Tool?

**HIGH VALUE tools:**
- ✅ Save >10 minutes per use
- ✅ Used weekly or more
- ✅ Prevent bugs/mistakes
- ✅ Improve code quality
- ✅ Enable capabilities not possible manually

**LOW VALUE tools (avoid):**
- ❌ One-time use only
- ❌ Faster to do manually
- ❌ Too specific to one project
- ❌ Requires complex setup
- ❌ Maintenance burden > benefit

### Implementation Patterns That Work

**From existing 106 tools:**
1. **PowerShell for Windows** - Best ecosystem integration
2. **Auto-loading wrappers** (ai-image.ps1 pattern) - Simplify usage
3. **JSON output options** - Enable tool composition
4. **DryRun modes** - Safety for destructive ops
5. **Comprehensive help** - Document inline with examples

---

## 💡 INSPIRATION SOURCES

**Where to find tool ideas:**

1. **Daily Work Frustrations**
   - What's tedious?
   - What requires multiple steps?
   - What do I forget to do?

2. **Error Patterns**
   - What errors occur repeatedly?
   - What debugging steps are repeated?
   - What mistakes happen frequently?

3. **Code Reviews**
   - What issues come up in every PR?
   - What manual checks are needed?
   - What patterns violate standards?

4. **External Research**
   - GitHub trending repositories
   - DevOps/testing blogs
   - .NET/React ecosystem tools
   - Other teams' toolchains

5. **User Feedback**
   - What does user struggle with?
   - What manual tasks does user do?
   - What "how do I..." questions come up?

---

## 🎯 QUARTERLY GOALS

### Q1 2026 (Jan-Mar)
- [x] Implement top 5 Tier S tools (ratio > 6.0)
- [ ] Implement remaining 15 Tier S tools (ratio > 5.0)
- [ ] Establish usage tracking habit (monthly updates)
- [ ] Create 5 new tools from wishlist captures

### Q2 2026 (Apr-Jun)
- [ ] Implement top 20 Tier A tools (ratio 3.0-5.0)
- [ ] Review and retire unused tools
- [ ] Create tool composition examples
- [ ] Document reusable patterns

### Q3 2026 (Jul-Sep)
- [ ] Implement Tier B tools as needed
- [ ] Establish quarterly tool audit process
- [ ] Create tool effectiveness metrics
- [ ] Share learnings in documentation

### Q4 2026 (Oct-Dec)
- [ ] Research and prototype advanced tools
- [ ] Tool ecosystem consolidation
- [ ] Performance optimization of heavily-used tools
- [ ] Year-end retrospective and 2027 planning

---

**Last Updated:** 2026-01-25 02:15 (Changed to DAILY review cadence)
**Next Review:** END OF EVERY SESSION (daily mandatory)
**Weekly Meta-Review:** Every Sunday
**Monthly Analysis:** First Monday of month
**Maintenance:** Living document - update multiple times per day
