# Bug Clarification Template

Use this template when posting clarification questions on vague ClickUp bug reports.

---

## Template 1: Generic Bug Report

```
INVESTIGATION UPDATE - Need Clarification

Thank you for reporting this issue. To help resolve it quickly, I need some additional information:

**Reproduction Steps:**
1. What exact steps did you take before seeing this issue?
2. What page/component were you using?
3. Were you logged in? What user account?

**Expected vs Actual Behavior:**
- What did you expect to happen?
- What actually happened instead?

**Environment:**
- Browser: (Chrome, Firefox, Safari, etc.)
- Device: (Desktop, Mobile, Tablet)
- Operating System: (Windows, Mac, Linux, iOS, Android)

**Error Messages:**
- Did you see any error messages? (Please provide exact text or screenshot)
- Check browser console (F12 -> Console tab) for errors

**Additional Context:**
- Does this happen every time or intermittently?
- Did this ever work before, or is this a new feature?
- Can you provide a screenshot or screen recording?

Once I have this information, I can investigate and provide a solution.

-- Claude Code Agent
```

---

## Template 2: "Not Working" Bug

```
CLARIFICATION NEEDED - What specifically isn't working?

I see you've reported that [FEATURE] is "not working". To investigate effectively, I need to understand what specifically isn't working:

**Please clarify:**
1. **What action did you take?** (e.g., clicked button, submitted form, navigated to page)
2. **What happened?** (e.g., nothing happened, page crashed, wrong data displayed, error shown)
3. **What should have happened instead?**

**Common scenarios - which applies?**
- [ ] Feature doesn't load/appear at all
- [ ] Feature loads but button/action does nothing when clicked
- [ ] Feature works but shows wrong/unexpected results
- [ ] Feature shows an error message (please provide exact error text)
- [ ] Feature crashes the page/app
- [ ] Other: [Please describe]

**Reproduction:**
- Does this happen every single time?
- Can you provide exact steps to reproduce?

-- Claude Code Agent
```

---

## Template 3: Potential Duplicate

```
DUPLICATE CHECK - Similar task exists

While investigating this issue, I found what appears to be a related task:

**Potentially Related Task:**
- Task ID: [ID]
- Title: [TITLE]
- Status: [STATUS]
- URL: [URL]

**Similarity:**
- [Describe how they're similar]

**Questions:**
1. Is this the same issue as the related task?
2. If different, what makes this issue unique?
3. Should these tasks be merged, or kept separate?

Please clarify so I can proceed with the appropriate task.

-- Claude Code Agent
```

---

## Template 4: Missing Context

```
INVESTIGATION STARTED - Need Technical Details

I've started investigating this issue. To proceed efficiently, I need some technical context:

**Current Investigation:**
- [What you've checked so far]
- [What you've found]

**Questions:**
1. [Specific technical question 1]
2. [Specific technical question 2]
3. [Specific technical question 3]

**Recommendations:**
Based on initial investigation, I recommend:
- [Recommendation 1]
- [Recommendation 2]

Please provide the requested information so I can continue.

-- Claude Code Agent
```

---

## Usage Instructions

1. **Choose the appropriate template** based on the bug type
2. **Fill in the bracketed placeholders** with specific details
3. **Customize** as needed for the specific situation
4. **Post as comment** on the ClickUp task using:
   ```powershell
   .\clickup-sync.ps1 -Action comment -TaskId "<id>" -Comment "<template>"
   ```

## When to Use Each Template

| Template | Use When |
|----------|----------|
| Template 1 (Generic) | Bug report has minimal description |
| Template 2 ("Not Working") | Bug says something "doesn't work" or "is broken" without specifics |
| Template 3 (Duplicate) | You suspect the bug duplicates an existing task |
| Template 4 (Missing Context) | You've started investigating but need technical details from reporter |

## Tips for Effective Clarification

1. **Be specific** - Ask precise questions, not vague ones
2. **Offer options** - Use checkboxes for common scenarios
3. **Show progress** - Mention what you've already checked
4. **Be friendly** - Use collaborative tone, not accusatory
5. **Set expectations** - Let them know what you'll do once you have the info

---

**Created**: 2026-02-04
**Author**: Claude Code Agent
**Version**: 1.0.0
