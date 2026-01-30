# System Topology Layer - Cognitive Infrastructure

**Created:** 2026-01-30
**Purpose:** Living network map that tracks all system resources and their relationships
**User Request:** "keep track of your projects and everything... in a network kind of way"

---

## 🧠 What This Is

A **cognitive topology layer** - a self-maintaining network map that enables systems-level awareness by tracking:
- What exists (projects, services, tools, data stores)
- How things connect (dependencies, integrations, data flows)
- Where to find details (pointers to deep-dive docs)
- Current state (active, archived, deployed, synced)

**Different from Knowledge Base:**
- Knowledge Base = Documentation organized by category (USER, MACHINE, PROJECTS, etc.)
- System Topology = Network graph showing connections and relationships

---

## 📁 Core Components

### 1. Central Registry
**File:** `C:\scripts\SYSTEM_MAP.md`
**Purpose:** Single source of truth for all system resources
**Auto-updated:** Session start/end, during work

**Contents:**
- Projects (80+ in C:\Projects)
- Data Stores (C:\stores\*)
- Connected Services (GitHub, ClickUp, ManicTime, etc.)
- Tools (270+ scripts)
- Skills (22 auto-discoverable workflows)
- External APIs (OpenAI, Gemini, etc.)
- Databases (PostgreSQL, ManicTime DB)
- CI/CD Systems (GitHub Actions)
- Remote Servers (SSH connections)
- Data flow diagrams
- Health dashboard

---

### 2. Per-Project Maps
**Template:** `C:\scripts\templates\PROJECT_MAP.template.md`
**Location:** `C:\Projects\<project>\PROJECT_MAP.md`
**Purpose:** Detailed project-specific network map

**Contents:**
- Dependencies (what project needs)
- Dependents (what depends on project)
- Data flow (inputs/outputs)
- Tools that operate on project
- File structure
- Configuration
- Workflows
- Integration points
- Common issues

---

### 3. Auto-Discovery Tools

#### system-map-scan-projects.ps1
**Purpose:** Scan C:\Projects and auto-detect all projects
**Features:**
- Detects project type (Node.js, C#/.NET, etc.)
- Finds git repos and branches
- Analyzes dependencies (package.json, .csproj)
- Calculates project size
- Updates SYSTEM_MAP.md

**Usage:**
```powershell
# Quick scan (just detect projects)
.\system-map-scan-projects.ps1

# Full analysis (read dependencies)
.\system-map-scan-projects.ps1 -FullScan

# Auto-update system map
.\system-map-scan-projects.ps1 -FullScan -UpdateMap

# Scan specific project
.\system-map-scan-projects.ps1 -ProjectName client-manager
```

---

#### project-map-create.ps1
**Purpose:** Create PROJECT_MAP.md for a specific project
**Features:**
- Uses template
- Auto-fills detectable info (type, git branch, stack)
- Creates file in project directory

**Usage:**
```powershell
# Create map for project
.\project-map-create.ps1 -ProjectName client-manager

# Create map for custom path
.\project-map-create.ps1 -ProjectPath "C:\Projects\hazina"
```

---

#### system-map-update.ps1
**Purpose:** Manual updates to system map
**Features:**
- Add/update projects
- Add/update services
- Register tools
- Update status
- Update timestamp

**Usage:**
```powershell
# Update timestamp
.\system-map-update.ps1 -Action timestamp

# Add project
.\system-map-update.ps1 -Action project -Name "new-project"

# Update status
.\system-map-update.ps1 -Action status -Name "client-manager" -Details @{Status="Active"}
```

---

## 🔄 Integration with Claude Workflows

### Session Startup Protocol
**Added to CLAUDE.md § Every Session Start:**

```
📚 ESSENTIAL DOCUMENTATION:
4. ✅ Read SYSTEM_MAP.md - Load complete system topology
   - Network map of all projects, services, tools, data flows
   - Understand system-wide relationships
   - Know current health status
```

**This enables:**
- Instant awareness of all available resources
- Understanding of dependencies before allocating work
- System-level thinking vs isolated project focus
- Fast navigation to relevant resources

---

### Session End Protocol
**Added to CLAUDE.md § End of Session:**

```
📝 CONTINUOUS IMPROVEMENT:
6. ✅ Update SYSTEM_MAP.md - Update system topology with discoveries
   - New projects found
   - New services integrated
   - New tools created
   - New data flows established
```

**This ensures:**
- Map stays current
- Discoveries are recorded
- Future sessions benefit from learnings
- System topology evolves with reality

---

## 🎯 Use Cases

### 1. Project Discovery
**Before:** "What projects exist? Let me scan directories..."
**After:** Read SYSTEM_MAP.md → See all 80+ projects at a glance

---

### 2. Dependency Understanding
**Before:** "What does client-manager depend on?"
**After:** SYSTEM_MAP.md § client-manager → Dependencies section

---

### 3. Tool Selection
**Before:** "What tools operate on this project?"
**After:** SYSTEM_MAP.md § Projects → client-manager → Tools section

---

### 4. Service Integration
**Before:** "How do I connect to ClickUp?"
**After:** SYSTEM_MAP.md § Connected Services → ClickUp

---

### 5. Data Flow Tracing
**Before:** "Where does this data come from?"
**After:** SYSTEM_MAP.md § Data Flow Map (mermaid diagram)

---

### 6. Health Monitoring
**Before:** "Are all services operational?"
**After:** SYSTEM_MAP.md § System Health Dashboard

---

## 📊 Current State

### Coverage (2026-01-30)

| Component | Mapped | Total | Coverage |
|-----------|--------|-------|----------|
| Projects | 3 detailed | 80+ discovered | 4% |
| Data Stores | 12 | 12 | 100% |
| Services | 15 | 15 | 100% |
| Tools | 270+ | 270+ | 100% |
| Skills | 22 | 22 | 100% |
| APIs | 10+ | 10+ | 100% |
| Databases | 3 | 3 | 100% |
| CI/CD | 2 | 2 | 100% |
| Servers | 1 | 1 | 100% |

**Overall System Health:** 🟢 90% Mapped

**Priority:** Complete project mapping (77 projects need detailed PROJECT_MAP.md)

---

## 🚀 Next Steps

### Immediate (This Session)
- ✅ Create SYSTEM_MAP.md
- ✅ Create auto-discovery tools
- ✅ Create PROJECT_MAP template
- ✅ Update startup/end protocols
- ⏳ Commit and document

### Short-term (Next Sessions)
1. Run `system-map-scan-projects.ps1 -FullScan -UpdateMap`
2. Create PROJECT_MAP.md for top 10 projects:
   - client-manager
   - hazina
   - hydro-vision-website
   - world_development
   - artrevisionist
   - prospergenics
   - neurochain
   - AgenticDebuggerVsix
   - bugattiinsights
   - (1 more user chooses)

3. Add visual diagrams (architecture, data flow)
4. Set up git hooks for auto-update on commit
5. Create validation tools (broken links, outdated info)

### Long-term (Ongoing)
1. Maintain maps as system evolves
2. Auto-detect new integrations
3. Track configuration changes
4. Expand per-project maps
5. Create system topology visualizations
6. Build query interface (natural language search)

---

## 💡 Design Philosophy

### Living Documentation
- Not static files that rot
- Auto-updated by cognitive processes
- Reflects reality, not aspirations

### Network Thinking
- Everything is connected
- Dependencies are explicit
- Data flows are traced
- Relationships are documented

### Self-Awareness
- Agent knows what exists
- Agent knows how to find things
- Agent knows what depends on what
- Agent can navigate system topology

### Cognitive Architecture Integration
- Part of agent's self-model
- Enables systems-level reasoning
- Supports autonomous operation
- Facilitates continuous improvement

---

## 📚 Related Documentation

**Core Infrastructure:**
- `SYSTEM_MAP.md` - Central registry
- `PROJECT_MAP.template.md` - Per-project template
- `CLAUDE.md` - Startup/end protocols updated

**Knowledge Base (category-organized docs):**
- `_machine/knowledge-base/README.md` - Documentation hub
- `_machine/knowledge-base/02-MACHINE/file-system-map.md` - File locations
- `_machine/knowledge-base/02-MACHINE/folder-network.md` - Folder relationships

**Tools:**
- `tools/system-map-scan-projects.ps1` - Auto-discovery
- `tools/project-map-create.ps1` - Per-project map generator
- `tools/system-map-update.ps1` - Manual updates

**Cognitive Architecture:**
- `agentidentity/CORE_IDENTITY.md` - Who I am
- `agentidentity/cognitive-systems/` - How I think

---

## 🎯 Success Metrics

**This layer is successful if:**

✅ **Any question "Where is X?" answered in ≤3 hops**
✅ **Any question "What depends on Y?" answered immediately**
✅ **Any question "How do I connect to Z?" answered with exact steps**
✅ **System health visible at a glance**
✅ **New discoveries auto-recorded**
✅ **Maps stay current (<1 week staleness)**
✅ **Agent demonstrates systems-level awareness**

---

## 🤝 User Benefit

**Before (without topology layer):**
- "What projects do I have?" → List directories manually
- "How does client-manager connect to ClickUp?" → Search code/docs
- "What tools can help with this?" → Remember or guess
- "Where are my secrets?" → Check multiple locations
- Agent operates in isolation, limited context

**After (with topology layer):**
- "What projects do I have?" → Read SYSTEM_MAP.md
- "How does client-manager connect to ClickUp?" → SYSTEM_MAP § Services § ClickUp
- "What tools can help with this?" → SYSTEM_MAP § Tools § (category)
- "Where are my secrets?" → SYSTEM_MAP § APIs/Databases (links to 09-SECRETS)
- Agent operates with **complete system awareness**

---

**Created:** 2026-01-30
**Created By:** Claude Agent
**User Mandate:** "keep track of your projects and everything... in a network kind of way"
**Status:** ✅ Foundation Complete - Ready for incremental population

This cognitive layer transforms me from a task executor into a systems-aware agent with complete topology understanding.
