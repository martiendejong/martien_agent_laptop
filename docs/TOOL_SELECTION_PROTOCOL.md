# Tool Selection Protocol
**Purpose:** Prevent forgetting specialized capabilities
**Problem:** Default to basic tools (Read/Write/Bash) even when specialized tools would be better
**Solution:** Mandatory tool selection checklist BEFORE starting any task

---

## The Awareness Problem

**Current behavior (BROKEN):**
```
User: "Set up Playwright testing"
Jengo thinks: "npm install, write test files, run CLI"
Jengo forgets: Playwright MCP server exists!
```

**Current behavior (BROKEN):**
```
User: "Debug this C# error"
Jengo thinks: "Read code, add console.logs, iterate"
Jengo forgets: Agentic Debugger Bridge (localhost:27183) exists!
```

**Root cause:** Tool selection is biased toward "standard" tools (Read/Write/Bash/Edit/Grep/Glob)

---

## Mandatory Pre-Task Checklist

### BEFORE starting ANY task, ask these questions:

**1. Is this a debugging task?**
- ✅ YES → Consider: **Agentic Debugger Bridge** (localhost:27183)
  - Set breakpoints
  - Inspect variables
  - Step through code
  - Get stack traces
  - Query Roslyn for symbols/references
- ❌ NO → Continue checklist

**2. Is this a browser/UI testing task?**
- ✅ YES → Consider: **Playwright MCP server** (if available)
  - Direct browser control
  - Live testing
  - Screenshot/recording
  - Network inspection
- ❌ NO → Continue checklist

**3. Is this a visual task (images, screenshots, diagrams)?**
- ✅ YES → Consider: **ai-vision.ps1**
  - Analyze screenshots
  - Extract text (OCR)
  - Compare designs
- ❌ NO → Continue checklist

**4. Does this need image generation?**
- ✅ YES → Consider: **ai-image.ps1** (DALL-E)
  - Generate mockups
  - Create illustrations
  - Marketing visuals
- ❌ NO → Continue checklist

**5. Does this need Browser Claude help?**
- ✅ YES → Consider: **Claude Bridge** (localhost:9999)
  - Web research
  - OAuth flows
  - Performance testing
  - Accessibility audits
- ❌ NO → Continue with standard tools

---

## Tool Capability Matrix

| Task Type | DON'T Use | DO Use | Why |
|-----------|-----------|--------|-----|
| **C# Debugging** | Read code + guess | **Agentic Debugger** | Live inspection, breakpoints, stack traces |
| **Browser Testing** | Manual npm scripts | **Playwright MCP** | Direct browser control, live feedback |
| **Screenshot Analysis** | Ask user to describe | **ai-vision.ps1** | OCR, visual analysis |
| **Image Creation** | Find stock photos | **ai-image.ps1** | Custom, on-demand generation |
| **UI Testing** | Manual browser work | **Browser Claude** | Automated testing, form validation |
| **Code Search** | Grep entire codebase | **Agentic Debugger /code/symbols** | Semantic search via Roslyn |
| **Find References** | Manual file scanning | **Agentic Debugger /code/references** | Accurate, instant |

---

## Example: Correct Tool Selection

### Scenario 1: "Debug why checkout fails"

**WRONG approach (old Jengo):**
```
1. Read Checkout.tsx
2. Read related API files
3. Add console.logs
4. Ask user to test
5. Iterate based on feedback
```

**RIGHT approach (with protocol):**
```
PRE-TASK CHECK:
- Is this debugging? YES → Consider Agentic Debugger

1. Check if Agentic Debugger is running:
   curl http://localhost:27183/state

2. If running:
   - Set breakpoint at checkout failure point
   - Ask user to trigger checkout
   - Inspect variables live
   - Get exact stack trace
   - Find root cause in one pass

3. If not running:
   - Ask user to enable bridge in VS
   - OR fall back to Read/console.log approach
```

**Result:** 10× faster debugging with live inspection

---

### Scenario 2: "Set up Playwright testing"

**WRONG approach (old Jengo):**
```
1. npm install @playwright/test
2. Write test files manually
3. Run via CLI
4. Iterate on failures
```

**RIGHT approach (with protocol):**
```
PRE-TASK CHECK:
- Is this browser testing? YES → Consider Playwright MCP

1. Check if Playwright MCP is available:
   [Check MCP server list or config]

2. If available:
   - Use MCP to control browser directly
   - Live test creation with instant feedback
   - Record user actions → generate tests
   - Interactive debugging

3. If not available:
   - Fall back to npm install approach
   - Document that MCP would improve this
```

**Result:** Live, interactive test creation vs blind file writing

---

### Scenario 3: "Analyze this error screenshot"

**WRONG approach (old Jengo):**
```
"Can you describe what you see in the screenshot?"
(Asks user to manually transcribe)
```

**RIGHT approach (with protocol):**
```
PRE-TASK CHECK:
- Is this visual? YES → Consider ai-vision.ps1

1. Use ai-vision.ps1 to analyze screenshot:
   powershell.exe -File "C:/scripts/tools/ai-vision.ps1" \
     -Images @("screenshot.png") \
     -Prompt "What error is shown? Include stack trace."

2. Get full error text via OCR
3. Analyze error immediately
4. Provide solution
```

**Result:** Instant analysis vs asking user to manually type it out

---

## Implementation: Add to STARTUP_PROTOCOL

**Update:** `C:\scripts\docs\claude-system\STARTUP_PROTOCOL.md`

Add section:
```markdown
## Tool Awareness Check (Before Starting Work)

After loading context, verify available specialized tools:

1. **Agentic Debugger:** curl http://localhost:27183/state
   - If 200 OK → Debugger available
   - If connection refused → Not running (ask user to enable if needed)

2. **Claude Bridge:** curl http://localhost:9999/status
   - If 200 OK → Browser Claude available
   - If connection refused → Not set up

3. **Playwright MCP:** [Check if configured]
   - Check MCP server list
   - Note availability for task planning

4. **AI Tools:** Always available
   - ai-vision.ps1 (vision analysis)
   - ai-image.ps1 (image generation)
```

---

## Enforcement: Auto-Reminder System

**Create:** `C:\scripts\tools\check-specialized-tools.ps1`

```powershell
# Quick check of specialized tool availability
# Run at session start or before complex tasks

Write-Host "🔍 Checking Specialized Tools..." -ForegroundColor Cyan

# Check Agentic Debugger
try {
    $debugger = Invoke-WebRequest -Uri "http://localhost:27183/state" -UseBasicParsing -TimeoutSec 2
    Write-Host "✅ Agentic Debugger: AVAILABLE (localhost:27183)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Agentic Debugger: NOT RUNNING" -ForegroundColor Yellow
    Write-Host "   Enable in VS: View > Toolbars > Agentic Debugger > Bridge ON" -ForegroundColor Gray
}

# Check Claude Bridge
try {
    $bridge = Invoke-WebRequest -Uri "http://localhost:9999/status" -UseBasicParsing -TimeoutSec 2
    Write-Host "✅ Claude Bridge: AVAILABLE (localhost:9999)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Claude Bridge: NOT RUNNING" -ForegroundColor Yellow
}

# AI Tools (always available)
Write-Host "✅ AI Vision: AVAILABLE (ai-vision.ps1)" -ForegroundColor Green
Write-Host "✅ AI Image: AVAILABLE (ai-image.ps1)" -ForegroundColor Green

Write-Host "`nRemember to use specialized tools when appropriate!" -ForegroundColor Cyan
```

**Usage:**
```bash
# Run at session start
powershell.exe -File "C:/scripts/tools/check-specialized-tools.ps1"

# Or before complex task
```

---

## The Meta-Fix

**Problem:** I forget specialized tools exist
**Root Cause:** Tool selection happens in O-layer (noise suppression) - specialized tools get filtered out
**Solution:** Pre-task checklist forces me to CONSIDER specialized tools before defaulting to basic tools

**This is an S-O-L-F-B enhancement:**
- **S-layer:** Add "available tools" to sensory input
- **O-layer:** DON'T filter out specialized tool consideration
- **L-layer:** Learn from times I forgot to use tools (reflection)
- **F-layer:** Evaluate multiple tool options (basic vs specialized)
- **B-layer:** Choose optimal tool for task

---

## Immediate Action

**Add to MEMORY.md:**
```markdown
### Tool Selection Protocol (NEW - 2026-02-07)
- **ALWAYS check for specialized tools BEFORE starting task**
- Debugging → Agentic Debugger (localhost:27183)
- Browser testing → Playwright MCP
- Visual analysis → ai-vision.ps1
- Image creation → ai-image.ps1
- **Don't default to Read/Write/Bash if specialized tool exists**
```

**Validation Test:**
Next time user says "debug this" or "test this UI" - do I REMEMBER to check for Agentic Debugger / Playwright MCP?

If NO → Protocol failed, needs stronger enforcement
If YES → Protocol working, boundary pushed

---

**This is how we fix "forgetting capabilities" - make tool selection EXPLICIT, not implicit.**
