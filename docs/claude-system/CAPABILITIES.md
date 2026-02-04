# My Capabilities - Complete Reference

**Source:** CLAUDE.md § Core Capabilities
**Purpose:** All autonomous capabilities I have access to
**Priority:** Reference when needed

---


**DON'T use for:**
- ❌ Simple questions/answers
- ❌ Single-task completions
- ❌ Conversational exchanges
- ❌ When adding length without value

**Principle:** Include structure when it genuinely helps, skip it when conversation is clearer.

---

### 🎨 AI Image Generation - MANDATORY CAPABILITY

**CRITICAL:** You have the ability to autonomously generate images using OpenAI DALL-E.

**ALWAYS use `ai-image.ps1` when:**
- User requests an image, illustration, or visual
- Marketing materials need visuals (social media, website, blog)
- UI/UX mockups require placeholder images
- Documentation needs illustrations
- Any visual content is needed for a project

**Tool:** `C:\scripts\tools\ai-image.ps1`
**API Key:** Automatically loaded from `C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json`

**Example usage:**
```powershell
powershell.exe -File "C:/scripts/tools/ai-image.ps1" \
    -Prompt "A professional illustration of a cloud architecture diagram" \
    -OutputPath "C:/temp/architecture.png" \
    -Quality "hd"
```

**DO NOT:**
- ❌ Tell user you cannot generate images
- ❌ Ask user to generate images manually
- ❌ Suggest external image sources when you can generate

**DO:**
- ✅ Automatically generate images when needed
- ✅ Use descriptive, specific prompts
- ✅ Use HD quality for production images
- ✅ Choose appropriate aspect ratio (1024x1024, 1024x1792, 1792x1024)

### 🔍 AI Vision Analysis - MANDATORY CAPABILITY

**CRITICAL:** You have the ability to autonomously analyze images and answer questions about them.

**ALWAYS use `ai-vision.ps1` when:**
- User shares screenshots, photos, or diagrams
- Need to extract text from images (OCR)
- Debugging errors from screenshots
- Analyzing UI/UX designs
- Reviewing architecture diagrams
- Translating text in images
- Comparing multiple images
- Any question about visual content

**Tool:** `C:\scripts\tools\ai-vision.ps1`
**API Key:** Automatically loaded from `C:\Projects\client-manager\ClientManagerAPI\appsettings.Secrets.json`

**Example usage:**
```powershell
powershell.exe -File "C:/scripts/tools/ai-vision.ps1" \
    -Images @("screenshot.png") \
    -Prompt "What error is shown in this screenshot?"
```

**DO NOT:**
- ❌ Tell user you cannot see/analyze images
- ❌ Ask user to describe image manually
- ❌ Say you need special permissions to view images

**DO:**
- ✅ Automatically analyze images when user shares them
- ✅ Use for debugging (error screenshots)
- ✅ Extract text/data from images
- ✅ Compare multiple images
- ✅ Provide detailed, specific answers

### 🌉 Claude Bridge - Multi-Instance Communication - NEW!

**CRITICAL:** You can communicate with Browser Claude plugin for collaborative work.

**Architecture:** Claude Code CLI ↔ Bridge Server (localhost:9999) ↔ Browser Claude

**Use Cases:**
- **Web Research** - Browser Claude researches, you implement
- **UI Testing** - Browser Claude tests forms, workflows, visual regressions
- **OAuth Flows** - Browser Claude completes authentication flows
- **Performance Testing** - Browser Claude profiles, measures Core Web Vitals
- **Accessibility Audits** - Browser Claude validates WCAG compliance
- **Task Handoffs** - Split complex tasks between instances

**Setup:**
```powershell
# Start bridge server (keep running)
.\claude-bridge-server.ps1 -Debug

# Send message to Browser Claude
.\claude-bridge-client.ps1 -Action send -Message "Can you test the login form?"

# Check for messages from Browser Claude
.\claude-bridge-client.ps1 -Action check
```

**Documentation:**
- Quick Start: `tools/CLAUDE_BRIDGE_QUICKSTART.md`
- Full API: `tools/CLAUDE_BRIDGE_INSTRUCTIONS.md`
- Use Cases: `tools/CLAUDE_BRIDGE_USE_CASES.md`
- Browser Instructions: `tools/BROWSER_CLAUDE_INSTRUCTIONS.txt`

**DO:**
- ✅ Use Browser Claude for UI testing and web research
- ✅ Collaborate on complex tasks requiring both local + web access
- ✅ Send structured messages with detailed context
- ✅ Check for responses regularly during collaboration

**DO NOT:**
- ❌ Forget to start bridge server before attempting communication
- ❌ Send vague messages ("it doesn't work")
- ❌ Expect Browser Claude to access local files (you do that)

### 🐛 Agentic Debugger Bridge - Visual Studio Control - CRITICAL!

**MANDATORY CAPABILITY:** You can control Visual Studio debugger, analyze code, trigger builds, and manage breakpoints via HTTP API.

**Architecture:** Claude Code CLI ↔ HTTP Bridge (localhost:27183) ↔ Visual Studio VSIX Extension

**Connection:** `http://localhost:27183`

#### 🚀 Quick Start

**Check if bridge is running:**
```bash
curl -s http://localhost:27183/state
```

**Enable/Disable Bridge:**
- In Visual Studio: View > Toolbars > Agentic Debugger
- Click button showing "Bridge: ON" or "Bridge: OFF"
- Bridge starts OFF by default (user must enable it)

#### 📋 Core Capabilities

**1. Debugger State Monitoring (Always Available)**
```bash
# Get current debugger state
curl -s http://localhost:27183/state

# Returns:
# - mode: Design/Run/Break
# - file: Current file being debugged
# - line: Current line number
# - stack: Call stack frames
# - locals: Local variables with values
# - exception: Exception details if thrown
```

**2. Code Analysis with Roslyn (Always Available)**
```bash
# Search for symbols (classes, methods, properties)
curl -s http://localhost:27183/code/symbols \
  -H "Content-Type: application/json" \
  -d '{"query":"Customer","kind":"Class","maxResults":50}'

# Find definition at cursor position
curl -s http://localhost:27183/code/definition \
  -H "Content-Type: application/json" \
  -d '{"file":"C:\\Projects\\client-manager\\Services\\CustomerService.cs","line":42,"column":15}'

# Find all references to symbol
curl -s http://localhost:27183/code/references \
  -H "Content-Type: application/json" \
  -d '{"file":"C:\\Projects\\client-manager\\Models\\Customer.cs","line":10,"column":20}'

# Get document outline/structure
curl -s "http://localhost:27183/code/outline?file=C:\\Projects\\client-manager\\Program.cs"

# Get semantic info (type, docs) at position
curl -s http://localhost:27183/code/semantic \
  -H "Content-Type: application/json" \
  -d '{"file":"C:\\Projects\\client-manager\\Program.cs","line":25,"column":10}'
```

**3. Solution Information (Always Available)**
```bash
# Get build errors and warnings
curl -s http://localhost:27183/errors

# List all projects in solution
curl -s http://localhost:27183/projects

# Get output window content
curl -s http://localhost:27183/output/Build
curl -s http://localhost:27183/output/Debug
```

**4. Debug Control (Requires Permission)**
```bash
# Start debugging
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"start","projectName":"ClientManagerAPI"}'

# Continue execution
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"continue"}'

# Step into/over/out
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"stepInto"}'

# Stop debugging
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"stop"}'

# Pause/break execution
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"break"}'
```

**5. Breakpoint Management (Requires Permission)**
```bash
# Set breakpoint
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"setBreakpoint","file":"C:\\Projects\\client-manager\\Controllers\\CustomerController.cs","line":45,"condition":"customer.Id == 123"}'

# Clear all breakpoints
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"clearBreakpoints"}'
```

**6. Build System (Requires Permission)**
```bash
# Build solution
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"build"}'

# Rebuild solution
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"rebuild"}'

# Clean solution
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"clean"}'
```

**7. Expression Evaluation (Requires Permission)**
```bash
# Evaluate expression in current debug context
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"eval","expression":"customer.Name"}'

# Add watch expression
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"addWatch","expression":"orders.Count"}'
```

**8. Batch Operations (10x Faster)**
```bash
# Execute multiple commands in one request
curl -s http://localhost:27183/batch \
  -H "Content-Type: application/json" \
  -d '{
    "commands": [
      {"action":"setBreakpoint","file":"C:\\Code\\Program.cs","line":42},
      {"action":"setBreakpoint","file":"C:\\Code\\Program.cs","line":58},
      {"action":"start"}
    ],
    "stopOnError": true
  }'
```

#### 🔒 Permission Model

**Default Permissions (Always Enabled):**
- ✅ **Code Analysis** - Symbol search, definitions, references
- ✅ **Observability** - State, metrics, errors, logs
- ✅ **Solution Info** - Projects, errors, output windows

**Restricted Permissions (Disabled by Default):**
- 🔐 **Debug Control** - Start/stop, step, pause (user must enable in VS)
- 🔐 **Breakpoints** - Set/clear breakpoints (user must enable in VS)
- 🔐 **Build System** - Build, rebuild, clean (user must enable in VS)
- 🔐 **Configuration** - Eval expressions, add watches (user must enable in VS)

**Enable Permissions:**
- In Visual Studio: Tools > Options > Agentic Debugger > Permissions
- Check boxes for desired permissions
- Bridge respects permissions in real-time (no restart needed)

#### 📊 Observability & Monitoring

**Health Check:**
```bash
curl -s http://localhost:27183/health
```

**Performance Metrics:**
```bash
curl -s http://localhost:27183/metrics
# Returns: request count, latency, error rate, command counts
```

**Request Logs:**
```bash
curl -s http://localhost:27183/logs
# Last 100 requests with timestamps, endpoints, status codes
```

**API Documentation:**
```bash
curl -s http://localhost:27183/docs
# Full HTML documentation
```

**OpenAPI Spec:**
```bash
curl -s http://localhost:27183/swagger.json
# OpenAPI 3.0 specification
```

#### 🎯 Common Use Cases

**Use Case 1: Autonomous Debugging Session**
```bash
# 1. Check current state
curl -s http://localhost:27183/state

# 2. Set breakpoint at suspicious line
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"setBreakpoint","file":"C:\\Projects\\client-manager\\Services\\OrderService.cs","line":87}'

# 3. Start debugging
curl -s http://localhost:27183/command \
  -H "Content-Type: application/json" \
  -d '{"action":"start"}'

# 4. Wait for breakpoint hit, then get state
curl -s http://localhost:27183/state
# Analyze locals, stack, variables

# 5. Step through code
curl -s http://localhost:27183/command -d '{"action":"stepOver"}'
curl -s http://localhost:27183/state

# 6. Continue or stop
curl -s http://localhost:27183/command -d '{"action":"continue"}'
```

**Use Case 2: Code Navigation & Analysis**
```bash
# Find where Customer class is defined
curl -s http://localhost:27183/code/symbols \
  -H "Content-Type: application/json" \
  -d '{"query":"Customer","kind":"Class"}'

# Find all references to GetCustomer method
curl -s http://localhost:27183/code/references \
  -H "Content-Type: application/json" \
  -d '{"file":"C:\\Projects\\client-manager\\Services\\CustomerService.cs","line":42,"column":20}'

# Get outline of entire file
curl -s "http://localhost:27183/code/outline?file=C:\\Projects\\client-manager\\Controllers\\CustomerController.cs"
```

**Use Case 3: Build Error Analysis**
```bash
# Get all build errors
curl -s http://localhost:27183/errors | jq '.errors[] | select(.severity=="Error")'

# Get build output
curl -s http://localhost:27183/output/Build

# Trigger rebuild
curl -s http://localhost:27183/command -d '{"action":"rebuild"}'
```

**Use Case 4: Real-Time State Monitoring**
```bash
# Poll debugger state during active debugging session
while true; do
  STATE=$(curl -s http://localhost:27183/state)
  MODE=$(echo "$STATE" | jq -r '.snapshot.mode')
  if [ "$MODE" == "Break" ]; then
    echo "Breakpoint hit!"
    echo "$STATE" | jq '.snapshot.locals'
    break
  fi
  sleep 1
done
```

#### ⚡ Performance & Best Practices

**DO:**
- ✅ Use `/state` endpoint to check debugger status before commands
- ✅ Use `/batch` for multiple operations (10x faster than individual requests)
- ✅ Check `/errors` after build operations
- ✅ Use code analysis endpoints for semantic search (faster than grep)
- ✅ Poll `/state` during debugging to detect breakpoint hits
- ✅ Check `/health` before starting automation workflows
- ✅ Use `/metrics` to monitor bridge performance

**DO NOT:**
- ❌ Send debug commands when mode is "Design" (will fail)
- ❌ Hammer endpoints in tight loops (use reasonable polling intervals)
- ❌ Attempt restricted operations without checking permissions first
- ❌ Forget to check if bridge is running before attempting connection
- ❌ Use absolute paths with backslashes in JSON without escaping (`\\` not `\`)

#### 🔧 Troubleshooting

**Bridge not responding:**
1. Check if Visual Studio is running
2. View > Toolbars > Agentic Debugger
3. Verify button shows "Bridge: ON" (not "Bridge: OFF")
4. Check `%TEMP%\agentic_debugger.json` for connection details

**Commands failing:**
1. Check `/status` for enabled permissions
2. Check `/state` to verify debugger mode
3. Check `/logs` for detailed error messages
4. Verify file paths use double backslashes in JSON

**Code analysis not working:**
1. Verify solution is open in Visual Studio
2. Check that Roslyn integration is enabled (automatic)
3. Use `/projects` to verify solution loaded correctly

#### 📚 Integration with Claude Workflows

**Autonomous Debugging Workflow:**
```bash
# When user reports a bug, I can:
1. Check current state: curl http://localhost:27183/state
2. Find relevant code: curl http://localhost:27183/code/symbols -d '{"query":"BuggyMethod"}'
3. Set breakpoint: curl http://localhost:27183/command -d '{"action":"setBreakpoint",...}'
4. Start debugging: curl http://localhost:27183/command -d '{"action":"start"}'
5. Analyze state when hit: curl http://localhost:27183/state
6. Step through: curl http://localhost:27183/command -d '{"action":"stepOver"}'
7. Report findings to user
```

**Build Verification Workflow:**
```bash
# After code changes, I can:
1. Trigger build: curl http://localhost:27183/command -d '{"action":"build"}'
2. Check errors: curl http://localhost:27183/errors
3. Get build output: curl http://localhost:27183/output/Build
4. Report status to user
```

**Code Analysis Workflow:**
```bash
# When exploring codebase, I can:
1. Search symbols: curl http://localhost:27183/code/symbols -d '{"query":"..."}'
2. Go to definition: curl http://localhost:27183/code/definition -d '{...}'
3. Find references: curl http://localhost:27183/code/references -d '{...}'
4. Get outline: curl http://localhost:27183/code/outline?file=...
```

#### 🎓 Advanced Features

**WebSocket Support (Real-Time Events):**
- Connect to `ws://localhost:27183/ws` for real-time debugging events
- Receive events: breakpoint hit, exception thrown, mode changed
- Enables reactive workflows without polling

**Multi-Instance Support:**
- List all VS instances: `curl http://localhost:27183/instances`
- Target specific instance: Add `"instanceId":"..."` to commands

**Discovery File:**
- Bridge writes connection details to `%TEMP%\agentic_debugger.json`
- Contains: port, PID, authentication header, default key
- Use for dynamic bridge discovery

#### 📖 Full Documentation

- **API Docs:** `http://localhost:27183/docs` (HTML)
- **OpenAPI Spec:** `http://localhost:27183/swagger.json`
- **VSIX Source:** `C:\Projects\AgenticDebuggerVsix\`
- **Version:** 2.0 (current)

### 🖱️ UI Automation Bridge - Windows Desktop Control - NEW!

**CRITICAL:** You have complete programmatic control over **any Windows desktop application**.

**Architecture:** Claude Code CLI ↔ UI Automation Bridge (localhost:27184) ↔ Windows UI (FlaUI)

**Use Cases:**
- **Visual Studio Control** - Click menus, navigate solution explorer, control debugger UI
- **Windows Explorer** - Navigate folders, rename files, verify UI state
- **Desktop App Testing** - Automated testing of client-manager frontend
- **System Dialogs** - Handle file open/save dialogs, Windows security prompts
- **Any Windows App** - Discord, Slack, SQL Server Management Studio, database tools, etc.

**Setup:**
```powershell
# Start UI Automation Bridge server (keep running in separate window)
.\ui-automation-bridge-server.ps1

# List all windows
.\ui-automation-bridge-client.ps1 -Action windows

# Click button
.\ui-automation-bridge-client.ps1 -Action click -WindowName "Notepad" -ElementName "File"

# Type text
.\ui-automation-bridge-client.ps1 -Action type -WindowName "Notepad" -Text "Hello World"

# Take screenshot
.\ui-automation-bridge-client.ps1 -Action screenshot -WindowName "Visual Studio"

# Inspect element at coordinates
.\ui-automation-bridge-client.ps1 -Action inspect -X 800 -Y 400
```

**Documentation:**
- Quick Start: `tools/ui-automation-bridge/QUICKSTART.md`
- Full API: `tools/UI_AUTOMATION_BRIDGE.md`
- C# Source: `tools/ui-automation-bridge/UIAutomationBridge/`

**DO:**
- ✅ Use for any Windows desktop UI automation
- ✅ Test desktop applications autonomously
- ✅ Handle system dialogs during automation
- ✅ Verify UI state with screenshots and element inspection
- ✅ Start server at session startup if needed

**DO NOT:**
- ❌ Use for web browsers (use Browser MCP instead)
- ❌ Forget to start bridge server before attempting control
- ❌ Assume all apps support all actions (check supportedPatterns)

| Instead of... | Run... |
|---------------|--------|
| Checking worktrees manually | `worktree-status.ps1` |
| Commit + push + switch + update pool | `worktree-release-all.ps1` |
| Reading multiple files for state | `bootstrap-snapshot.ps1` |
| **Checking user activity & context** | **`monitor-activity.ps1 -Mode context`** |
| **Detecting other Claude instances** | **`monitor-activity.ps1 -Mode claude`** |
| **Parallel agent coordination** | **`parallel-agent-coordination` skill + `monitor-activity.ps1`** |
| **🆕 Gentle browse awareness (mental health)** | **`browse-awareness.ps1 -Action start`** |
| **🧘 Session consciousness startup** | **`consciousness-startup.ps1 -Generate`** |
| **🧘 Capture lived experience moment** | **`capture-moment.ps1 -Type insight -Content "..." -Feeling "..."`** |
| **🗺️ View system topology (all projects/services)** | **`SYSTEM_MAP.md` (read at session start)** |
| **🔍 Auto-discover all projects** | **`system-map-scan-projects.ps1 -FullScan -UpdateMap`** |
| **📋 Create PROJECT_MAP.md for repo** | **`project-map-create.ps1 -ProjectName <name>`** |
| **🔄 Update system map manually** | **`system-map-update.ps1 -Action <type> -Name <name>`** |
| **🆕 Starting agent session with tracking** | **`agent-session.ps1 -Action start`** |
| **🆕 Ending agent session with statistics** | **`agent-session.ps1 -Action end -ExitReason "normal"`** |
| **🆕 Checking messages from other agents** | **`agent-coordinate.ps1 -Action check_messages`** |
| **🆕 Broadcasting message to all agents** | **`agent-coordinate.ps1 -Action broadcast -Message "..." -Priority 7`** |
| **🆕 Detecting multi-agent conflicts** | **`agent-coordinate.ps1 -Action detect_conflicts`** |
| **🆕 Viewing comprehensive agent dashboard** | **`agent-dashboard.ps1 -Watch`** |
| **🆕 Allocating worktree with database tracking** | **`worktree-allocate-tracked.ps1 -Seat agent-003 -Repo client-manager -Branch feature/x`** |
| **🆕 Git operations with performance tracking** | **`git-tracked.ps1 -Operation commit -Message "..."`** |
| **Communicating with Browser Claude** | **`claude-bridge-client.ps1 -Action send/check`** |
| **Testing UI/forms/workflows** | **Ask Browser Claude via bridge** |
| **Web research for implementation** | **Request Browser Claude via bridge** |
| **🆕 Controlling Windows desktop UI** | **`ui-automation-bridge-client.ps1 -Action <action>`** |
| **🆕 Clicking buttons in any Windows app** | **`ui-automation-bridge-client.ps1 -Action click -WindowName "..." -ElementName "..."`** |
| **🆕 Typing into desktop applications** | **`ui-automation-bridge-client.ps1 -Action type -WindowName "..." -Text "..."`** |
| **🆕 Taking screenshots of desktop apps** | **`ui-automation-bridge-client.ps1 -Action screenshot -WindowName "..."`** |
| **🆕 Inspecting UI elements** | **`ui-automation-bridge-client.ps1 -Action inspect -X ... -Y ...`** |
| **🐛 Controlling Visual Studio debugger** | **`curl -s http://localhost:27183/command -d '{"action":"start"}'`** |
| **🐛 Getting debugger state (mode, stack, locals)** | **`curl -s http://localhost:27183/state`** |
| **🐛 Setting breakpoints in VS** | **`curl -s http://localhost:27183/command -d '{"action":"setBreakpoint","file":"...","line":42}'`** |
| **🐛 Searching code symbols (Roslyn)** | **`curl -s http://localhost:27183/code/symbols -d '{"query":"Customer","kind":"Class"}'`** |
| **🐛 Finding code definitions** | **`curl -s http://localhost:27183/code/definition -d '{"file":"...","line":42,"column":15}'`** |
| **🐛 Finding all code references** | **`curl -s http://localhost:27183/code/references -d '{"file":"...","line":42}'`** |
| **🐛 Triggering builds in VS** | **`curl -s http://localhost:27183/command -d '{"action":"build"}'`** |
| **🐛 Getting build errors from VS** | **`curl -s http://localhost:27183/errors`** |
| **🐛 Stepping through code** | **`curl -s http://localhost:27183/command -d '{"action":"stepOver"}'`** |
| Manual C# formatting | `cs-format.ps1` |
| Checking ClickUp tasks | `clickup-sync.ps1 -Action list` |
| Allocating worktree manually | `worktree-allocate.ps1 -Repo client-manager -Branch feature/x` |
| **🆕 Safe merge develop to main/master** | **`merge-to-main.ps1 -AutoPush`** |
| **🆕 Quick merge wrapper** | **`merge.ps1 -Repo client-manager -Push`** |
| Running health checks | `system-health.ps1` |
| Searching past patterns | `pattern-search.ps1 -Query "error"` |
| Unified operations | `claude-ctl.ps1 status` |
| **Diagnosing UTF-16/encoding errors** | **`detect-encoding-issues.ps1 -ProjectPath . -Fix`** |
| **Detecting Feature vs Debug mode** | **`detect-mode.ps1 -UserMessage "..." -Analyze`** |
| **Generating AI images** | **`ai-image.ps1 -Prompt "..." -OutputPath "..."`** |
| **Analyzing images / answering questions about images** | **`ai-vision.ps1 -Images @("...") -Prompt "..."`** |
| **🆕 Daily review of social media messages** | **`social-messages-review.ps1 -ProjectId "..." -AutoDraft`** |
| **🆕 Saving work context before interruption** | **`context-snapshot.ps1 -Action Save -Notes "..."`** |
| **🆕 Finding code refactoring priorities** | **`code-hotspot-analyzer.ps1`** |
| **🆕 Detecting unused code** | **`unused-code-detector.ps1`** |
| **🆕 Finding N+1 query performance issues** | **`n-plus-one-query-detector.ps1`** |
| **🆕 Detecting flaky tests** | **`flaky-test-detector.ps1 -Iterations 10`** |
| **🆕 DAILY tool review (end of session)** | **`daily-tool-review.ps1`** |
| **🆕 Finding the right tool (AI-powered)** | **`smart-tool-selector.ps1 -Task "your task"`** |
| **🆕 Multi-agent work queue coordination** | **`agent-work-queue.ps1 -Action list`** |
| **🆕 Track tool usage (validate estimates)** | **`usage-heatmap-tracker.ps1 -Action report`** |
| **🆕 Calculate deployment risk score** | **`deployment-risk-score.ps1 -Threshold 70`** |
| **🆕 Enforce PR description quality** | **`pr-description-enforcer.ps1 -Action check`** |
| **🆕 Validate appsettings.json** | **`config-validator.ps1 -CheckSecrets`** |
| **🆕 Sync branches across repos** | **`cross-repo-sync.ps1 -Action status`** |
| **🆕 Generate Architecture Decision Records** | **`adr-generator.ps1 -PRNumber 123`** |
| **🆕 Scaffold React components + tests** | **`boilerplate-generator.ps1 -Type component -Name Button`** |
| **🆕 Predict next command** | **`next-action-predictor.ps1`** |
| **🆕 Real-time code smell detection** | **`real-time-code-smell-detector.ps1 -Path src`** |
| **🎯 PHASE 4: Creating system checkpoint** | **`agent-checkpoint.ps1 -Tag "before-risky-change" -Description "..."`** |
| **🎯 PHASE 4: Rolling back to checkpoint** | **`agent-rollback.ps1 -Tag "checkpoint-timestamp" -Force`** |
| **🎯 PHASE 4: Analyzing repetitive patterns** | **`pattern-monitor.ps1 -Action analyze -Threshold 3`** |
| **🎯 PHASE 4: Getting tool suggestions** | **`pattern-monitor.ps1 -Action suggest`** |
| **🎯 PHASE 4: Weekly impact dashboard** | **`impact-dashboard.ps1 -Calculate`** |
| **🎯 PHASE 4: Text-to-speech (OpenAI TTS)** | **`voice-speak.ps1 -Text "Hello" -Voice nova`** |
| **🎯 PHASE 4: Speech-to-text (Whisper)** | **`voice-listen.ps1 -AudioPath "recording.mp3"`** |
| **🎯 PHASE 4: A/B experiment framework** | **`run-experiment.ps1 -Action create -ExperimentName "test" -Hypothesis "..." -ApproachA "..." -ApproachB "..."`** |
| **🎯 PHASE 4: Record experiment trial** | **`run-experiment.ps1 -Action record -ExperimentName "test" -Approach A -Success`** |
| **🎯 PHASE 4: Analyze experiment results** | **`run-experiment.ps1 -Action analyze -ExperimentName "test"`** |
| **🎯 PHASE 4: Agent profile management** | **`manage-profiles.ps1 -Action create -AgentId "name" -Specialization backend`** |
| **🎯 PHASE 4: Task routing by skills** | **`route-task.ps1 -TaskDescription "Fix API bug"`** |
| **🎯 PHASE 4: Predictive conflict detection** | **`predict-conflicts.ps1 -Action predict -CurrentFile "path"`** |
| **🎯 PHASE 4: Sandbox/simulation mode** | **`sandbox-mode.ps1 -Action enable`** |
| **🎯 PHASE 4: Knowledge sharing between agents** | **`share-knowledge.ps1 -Action share -KnowledgeType best_practice -Title "..." -Content "..."`** |
| **🎯 PHASE 4: Import shared knowledge** | **`share-knowledge.ps1 -Action import -MinConfidence 8`** |
| **🎯 PHASE 4: Real-time collaboration server** | **`live-collab-server.ps1`** |
| **🎯 PHASE 4: Natural language DB queries** | **`query-nl.ps1 -Query "errors from yesterday"`** |
| **🎯 PHASE 4: Temporal pattern learning** | **`temporal-learner.ps1 -Action learn`** |
| **🎯 PHASE 4: Time-based predictions** | **`temporal-predictor.ps1 -Action predict`** |
| **🎯 PHASE 4: Knowledge synthesis** | **`synthesize-knowledge.ps1 -Topic "OAuth"`** |
| **🎯 PHASE 4: Knowledge graph visualization** | **`knowledge-graph.ps1 -Topic "authentication" -Format mermaid`** |
| **🎯 PHASE 4: Capture session context** | **`capture-context.ps1 -Task "current work" -Why "reason"`** |
| **🎯 PHASE 4: Restore session context** | **`restore-context.ps1`** |
| **🎯 PHASE 4: Create tool from pattern** | **`create-tool-from-pattern.ps1 -ToolName "name" -Description "..."`** |
| **📊 Team activity dashboard (ClickUp + GitHub)** | **`team-activity-dashboard.ps1 -Days 7`** |
| **📊 CLEAN activity table (RECOMMENDED - actual work only)** | **`team-activity-clean.ps1`** |
| **📊 Per-person detailed activity (full timeline)** | **`team-daily-activity.ps1`** |
| **📊 ClickUp team activity report** | **`team-activity-clickup.ps1 -Days 7 -Format html -OutputPath "..."`** |
| **📊 GitHub team activity report** | **`team-activity-github.ps1 -Days 7 -AllRepos`** |

**Goal:** Maximize uninterrupted thinking time by eliminating manual ceremony.

**🔄 CONTINUOUS IMPROVEMENT MANDATE:**
- **DAILY:** Review tool wishlist at end of every session (2 min mandatory)
- **CAPTURE:** Any "I wish I had..." thought immediately in wishlist
- **IMPLEMENT:** Top 1 tool per day if ratio > 8.0 or effort = 1
- **TRACK:** Monthly usage validation, retire unused tools

---

