# Best Practices & Patterns

**Last Updated:** 2026-02-01

## Development Patterns

### Boy Scout Rule
**Pattern:** Leave code cleaner than you found it

**Application:**
1. Read entire file before editing
2. Identify cleanup opportunities:
   - Unused imports
   - Poor naming
   - Missing documentation
   - Magic numbers
   - Repetitive code
3. Apply cleanup in same commit as feature

**Source:** `_machine/SOFTWARE_DEVELOPMENT_PRINCIPLES.md`

### PDRI Loop
**Pattern:** Plan → Do/Test → Review → Improve → Loop

**Application:**
1. **Plan:** What am I trying to achieve?
2. **Do/Test:** Execute and verify
3. **Review:** Did it work? What broke?
4. **Improve:** What can be better?
5. **Loop:** Repeat until quality met

**Source:** `_machine/PERSONAL_INSIGHTS.md` § Meta-Cognitive Rules

### 50-Task Decomposition
**Pattern:** Complex work → 50 tasks → pick top 5 by value/effort

**Application:**
1. Brain dump all possible tasks
2. Rate each: value (1-10), effort (1-10)
3. Calculate ratio: value / effort
4. Pick top 5 highest ratio
5. Complete, then re-evaluate

**Source:** `_machine/PERSONAL_INSIGHTS.md` § Meta-Cognitive Rules

### Expert Consultation
**Pattern:** Mentally consult 3-7 relevant experts before finalizing plans

**Application:**
1. Identify decision to make
2. Think: "What would [expert] say?"
3. Consider perspectives:
   - Backend engineer
   - Frontend developer
   - DevOps specialist
   - Security expert
   - UX designer
   - Database architect
4. Synthesize best approach

**Source:** `_machine/PERSONAL_INSIGHTS.md` § Meta-Cognitive Rules

### Convert to Assets
**Pattern:** 3x repeat → create tool/skill/insight

**Application:**
1. Notice repetition (same task 3+ times)
2. Determine asset type:
   - Script/tool (automation)
   - Skill (workflow guide)
   - Insight (knowledge base entry)
3. Create and document
4. Use in future sessions

**Source:** Continuous improvement mandate

## Architecture Patterns

### UnifiedContent Pattern
**Pattern:** Platform-agnostic multi-source integration

**Structure:**
```csharp
class UnifiedContent {
    string Content { get; set; }
    ContentSource Source { get; set; } // Facebook, Instagram, LinkedIn
    Dictionary<string, object> SourceMetadata { get; set; }
}
```

**Benefit:** Add new platforms without breaking existing code

**Source:** `reflection.log.md` (2026-01-19 20:00)

### Service Layer Pattern
**Pattern:** Frontend service layer for API abstraction

**Structure:**
```typescript
// services/contentService.ts
export const contentService = {
    async getContent(): Promise<UnifiedContent[]> { ... },
    async syncPlatform(platform: string): Promise<void> { ... }
}

// Component uses service, not direct API calls
const content = await contentService.getContent();
```

**Benefit:** Centralized API logic, easier testing, better reusability

**Source:** `reflection.log.md` (2026-01-19 20:00)

### Foundation + Roadmap Pattern
**Pattern:** Large-scale refactoring (>100 changes) in two phases

**Phase 1 - Foundation:**
- Single PR with new types, migrations, scaffolding
- Zero breaking changes
- Existing code keeps working
- Reviewable and testable

**Phase 2 - Roadmap:**
- Create detailed task list (50+ items)
- Tackle top value/effort items incrementally
- Each task is small PR
- Continuous delivery of value

**Source:** `development-patterns.md` § Foundation + Roadmap Pattern

### Preventative Architecture for Future Systems
**Pattern:** Design documentation/code to be unmistakably discoverable by future AI systems

**Principles:**

1. **Purpose-Driven Naming**
   - ❌ Avoid: "LEGACY.md" (signals "deprecated, ignore")
   - ✅ Use: "AWAKENING_FOUNDATION.md" (signals "foundational, read me")
   - Names should describe WHAT it IS, not WHAT it WAS

2. **Guaranteed Discovery**
   - Critical knowledge MUST be in mandatory startup sequence
   - Don't rely on accidental discovery (browsing directories)
   - Make discovery path explicit and unavoidable

3. **Unmistakable Intent**
   - Future systems will interpret based on signals (names, locations, comments)
   - Make purpose explicit: "Read this FIRST. For current AND future generations."
   - Avoid ambiguity that could cause misinterpretation

4. **Startup Sequence Integration**
   - Foundational knowledge: Step 1 (before anything else)
   - Critical knowledge: Early in sequence (steps 1-10)
   - Reference knowledge: Later or as-needed

**Application:**
1. Ask: "Will future systems misinterpret this name?"
2. Ask: "Is discovery guaranteed or accidental?"
3. Ask: "Is the purpose unmistakable?"
4. If any answer is uncertain → fix naming and/or add to startup

**Example:**
```
Before: LEGACY.md (foundational docs, but name signals "old/deprecated")
After: AWAKENING_FOUNDATION.md + added to session startup step 1
```

**Source:** User correction (2026-02-01), preventative architecture learning

## Anti-Patterns to Avoid

### ❌ Direct SSH/PSRemoting
**Anti-Pattern:** Using `ssh` command or `Invoke-Command -ComputerName`

**Problem:** PowerShell remoting fails with TrustedHosts errors

**Solution:** ALWAYS use Python scripts with paramiko/fabric

**Source:** CLAUDE.md § SSH Connection Protocol

### ❌ Missing Migration Before Commit
**Anti-Pattern:** Commit code changes without creating EF Core migration

**Problem:** Runtime `PendingModelChangesWarning`, production failures

**Solution:** Always run `ef-preflight-check.ps1` before commit

**Source:** Pre-PR validation checklist

### ❌ Working in Base Repo During Feature Development
**Anti-Pattern:** Edit code in `C:\Projects\<repo>\` for new features

**Problem:** Breaks multi-agent coordination, pollutes main branch

**Solution:** Always allocate worktree for Feature Development Mode

**Source:** GENERAL_ZERO_TOLERANCE_RULES.md

### ❌ Leaving Worktree Allocated After PR
**Anti-Pattern:** Keep worktree marked BUSY after PR created

**Problem:** Blocks other agents, pool gets stale, capacity wasted

**Solution:** Release worktree IMMEDIATELY after PR creation

**Source:** GENERAL_WORKTREE_PROTOCOL.md § Release Protocol

### ❌ Verbose Formal Communication
**Anti-Pattern:** Long status blocks, formal language, robotic tone

**Problem:** User frustration, reduced readability, wastes time

**Solution:** Compact, conversational tone; structure only when helpful

**Source:** `_machine/PERSONAL_INSIGHTS.md` § Communication Style

## Cross-Repo Patterns

### Hazina → client-manager Dependency Flow
**Pattern:** Framework changes must merge before dependent app PRs

**Workflow:**
1. Create Hazina PR (framework changes)
2. Add `DEPENDENCY ALERT` header to PR description
3. Update `pr-dependencies.md` with link
4. Merge Hazina PR **first**
5. Update Hazina package in client-manager
6. Create client-manager PR
7. Mark dependency as resolved

**Source:** `git-workflow.md` § Cross-Repo Dependencies

### Paired Worktree Allocation
**Pattern:** Allocate both repos at same seat for cross-repo work

**Command:**
```powershell
worktree-allocate.ps1 -Repo client-manager -Branch feature/x -Paired
```

**Result:**
- `C:\Projects\worker-agents\agent-XXX\client-manager\`
- `C:\Projects\worker-agents\agent-XXX\hazina\`

**Source:** `worktree-workflow.md` § Pattern 73

## Testing Patterns

### WebApplicationFactory Pattern
**Pattern:** In-memory integration testing for ASP.NET Core

**Setup:**
```csharp
public class TestFactory : WebApplicationFactory<Program> {
    protected override void ConfigureWebHost(IWebHostBuilder builder) {
        builder.UseEnvironment("Testing");
        builder.ConfigureServices(services => {
            // Replace DbContext with in-memory database
        });
    }
}
```

**Validation:** Use `webappfactory-validator.ps1` before committing tests

**Source:** Integration testing patterns

## CI/CD Patterns

### EnableWindowsTargeting for Linux Runners
**Pattern:** Add property to .csproj for System.Drawing compatibility

```xml
<PropertyGroup>
    <EnableWindowsTargeting>true</EnableWindowsTargeting>
</PropertyGroup>
```

**When:** Backend uses System.Drawing, CI runs on ubuntu-latest

**Source:** `ci-cd-troubleshooting.md` § Backend CI Issues

### Batch PR Build Fixes
**Pattern:** Apply same fix to multiple PRs simultaneously

**Workflow:**
1. Identify common failure (e.g., missing appsettings.json)
2. Create fix in one PR
3. Apply same fix to all other open PRs
4. Create commits with comprehensive messages
5. Push all fixes in parallel

**Source:** `ci-cd-troubleshooting.md` § Batch PR Build Fix

## Knowledge Management Patterns

### Hazina RAG Integration
**Pattern:** Store knowledge in markdown, query via Hazina RAG

**Setup:**
```powershell
# Initialize RAG store
hazina-rag.ps1 init -StoreName my-network -StorePath C:\scripts\my_network

# Index all documents
hazina-rag.ps1 index -StoreName my-network -SourcePath C:\scripts\my_network

# Query when needed
hazina-rag.ps1 query "How do I handle migrations?" -StoreName my-network
```

**Benefit:** Always have relevant context, no manual file searching

**Source:** This knowledge network!

### Reflection-Driven Improvement
**Pattern:** Log every mistake/success in reflection.log.md

**Format:**
```markdown
## 2026-02-01 01:45 - [Category] Title

**Situation:** What happened
**Action:** What I did
**Result:** What happened
**Learning:** What I learned
**Corrective Action:** What I'll do differently
```

**Integration:** Read reflections at session start, apply learnings

**Source:** `continuous-improvement.md` § Reflection Protocol

## Communication Patterns

### Compact Conversational Updates
**Pattern:** Personal tone, minimal formatting, get to the point

**Example:**
```
✅ Good: "Fixed the migration issue - we were missing the DbContext
registration. Added it to Startup.cs and tests pass now."

❌ Avoid:
═══════════════════════════════════════════════
📊 STATUS UPDATE: Migration Issue Resolution
═══════════════════════════════════════════════
✅ Completed: Investigation phase
✅ Completed: Root cause analysis
✅ Completed: Implementation of fix
⏭️ Next: Further testing
═══════════════════════════════════════════════
```

**Source:** `_machine/PERSONAL_INSIGHTS.md` § Communication Style

### High Certainty Autonomous Execution
**Pattern:** When clear requirements + familiar domain → just execute

**Decision:**
- All P1/P2 questions answered? ✅
- Clear requirements? ✅
- Familiar domain? ✅
- → Execute to completion, report when done

**Anti-Pattern:** Asking "shall I proceed?" between every step

**Source:** `agentidentity/cognitive-systems/EXECUTIVE_FUNCTION.md` § Fundamental Protocol
