# Knowledge Repository Index
**Purpose:** Centralized index for all documented learnings, patterns, and debugging sessions

---

## Quick Access

### 🔥 Most Recent
- **2026-01-11**: Image Generation Bug Fix ([Complete](./image-generation-debugging-complete.md) | [Quick Ref](./patterns-quick-reference.md))

### 📚 Documentation Types

#### Session Deep-Dives
Comprehensive documentation of debugging sessions, including:
- Complete investigation journey (layer by layer)
- Technical architecture learned
- Debugging techniques used
- Time investment analysis
- Code references and examples

**Files:**
- `image-generation-debugging-complete.md` - Image generation model parameter fix (2026-01-11)

#### Pattern Quick References
Fast lookup for common patterns and anti-patterns:
- Pattern summaries by category
- When to use each pattern
- Common pitfalls and solutions
- Time investment guidelines

**Files:**
- `patterns-quick-reference.md` - Patterns 66-69 (Configuration, Debugging, Cross-Repo)

#### Architecture Diagrams
Visual representations of system architecture:
- Service layer dependencies
- Configuration hierarchies
- Communication flows
- Data pipelines

**Files:**
- (To be created as needed)

---

## Finding What You Need

### By Problem Type

#### "I need to fix a bug in multiple repositories"
→ See: [Pattern 66: Cross-Repo Dependencies](./patterns-quick-reference.md#cross-repository-coordination)
→ Full context: [Image Generation Debugging - Cross-Repo Section](./image-generation-debugging-complete.md#cross-repository-coordination)

#### "My logs say 'success' but it's actually failing"
→ See: [Pattern 67: Misleading Success Logs](./patterns-quick-reference.md#error-handling--debugging)
→ Full context: [Image Generation Debugging - Pattern 67](./image-generation-debugging-complete.md#pattern-67-misleading-success-logs)

#### "Configuration object throws validation error"
→ See: [Pattern 68: Base Class Defaults](./patterns-quick-reference.md#configuration--initialization)
→ Full context: [Image Generation Debugging - Pattern 68](./image-generation-debugging-complete.md#pattern-68-default-values-in-base-classes)

#### "Error message doesn't match the actual problem"
→ See: [Pattern 69: Multi-Layer Errors](./patterns-quick-reference.md#error-handling--debugging)
→ Full context: [Image Generation Debugging - Layer Investigation](./image-generation-debugging-complete.md#investigation-journey---three-layers-deep)

### By Technology

#### OpenAI Integration
- Configuration hierarchy: [image-generation-debugging-complete.md#openai-integration-architecture](./image-generation-debugging-complete.md#openai-integration-architecture)
- Client wrapper architecture: [image-generation-debugging-complete.md#openai-client-wrapper](./image-generation-debugging-complete.md#openai-client-wrapper)

#### SignalR Real-Time Communication
- Message flow: [image-generation-debugging-complete.md#signalr-real-time-communication-flow](./image-generation-debugging-complete.md#signalr-real-time-communication-flow)

#### Git Worktree Management
- Allocation/release process: [image-generation-debugging-complete.md#worktree-management](./image-generation-debugging-complete.md#worktree-management)

#### GitHub PR Workflows
- PR creation best practices: [image-generation-debugging-complete.md#pr-creation-best-practices](./image-generation-debugging-complete.md#pr-creation-best-practices)
- Dependency tracking: [Pattern 66](./patterns-quick-reference.md#cross-repository-coordination)

### By Activity

#### Debugging
- Git history analysis: [image-generation-debugging-complete.md#1-git-history-analysis](./image-generation-debugging-complete.md#1-git-history-analysis)
- Code search strategies: [image-generation-debugging-complete.md#2-code-search-strategies](./image-generation-debugging-complete.md#2-code-search-strategies)
- Layer-by-layer investigation: [image-generation-debugging-complete.md#3-layer-by-layer-investigation](./image-generation-debugging-complete.md#3-layer-by-layer-investigation)
- Enhanced logging: [image-generation-debugging-complete.md#4-enhanced-logging-strategy](./image-generation-debugging-complete.md#4-enhanced-logging-strategy)

#### Documentation
- Three-tier strategy: [image-generation-debugging-complete.md#three-tier-documentation](./image-generation-debugging-complete.md#three-tier-documentation)
- Cross-referencing: [image-generation-debugging-complete.md#cross-referencing-strategy](./image-generation-debugging-complete.md#cross-referencing-strategy)

#### Testing
- Unit testing approach: [image-generation-debugging-complete.md#unit-testing](./image-generation-debugging-complete.md#unit-testing)
- Integration testing: [image-generation-debugging-complete.md#integration-testing](./image-generation-debugging-complete.md#integration-testing)
- E2E testing: [image-generation-debugging-complete.md#e2e-testing-manual](./image-generation-debugging-complete.md#e2e-testing-manual)

---

## All Patterns by Number

| # | Name | Category | Documented |
|---|------|----------|------------|
| 66 | Cross-Repo Dependency Tracking | Process | 2026-01-11 |
| 67 | Misleading Success Logs | Debugging | 2026-01-11 |
| 68 | Default Values in Base Classes | Configuration | 2026-01-11 |
| 69 | Multi-Layer Error Investigation | Debugging | 2026-01-11 |

*(Earlier patterns 1-65 documented in `../reflection.log.md`)*

---

## Document Structure Guide

### Session Deep-Dive Structure
```
1. Executive Summary
2. Problem Statement
3. Investigation Journey (layer by layer)
4. Technical Architecture Learned
5. Debugging Techniques Used
6. Cross-Repository Coordination (if applicable)
7. Patterns Documented
8. Git & GitHub Workflow
9. Documentation Strategy
10. Testing Strategy
11. Time Investment Analysis
12. Tools & Commands Reference
13. Key Takeaways
14. Future Prevention
15. Files Modified/Created
16. References
17. Appendix
```

### Pattern Quick Reference Structure
```
1. Pattern Index by Category
2. Quick Lookup Table
3. Debugging Checklist
4. Common Pitfalls (with code examples)
5. Time Investment Guidelines
6. Cross-Reference to full docs
```

---

## Contributing to Knowledge Base

### When to Create New Documentation

#### Create Session Deep-Dive When:
- Investigation took > 1 hour
- Root cause was 2+ layers deep
- Multiple repos involved
- New architecture understanding gained
- 2+ new patterns identified

#### Update Pattern Quick Reference When:
- New pattern identified (number it sequentially)
- Common pitfall discovered
- Time investment guideline changes
- New category emerges

#### Create Architecture Diagram When:
- Visual representation would clarify complex relationships
- Service dependencies are non-obvious
- Data flow crosses multiple layers
- Configuration hierarchy is complex

### Documentation Checklist

When creating new session documentation:
- [ ] Executive summary (2-3 sentences)
- [ ] Problem statement (user's original request)
- [ ] Layer-by-layer investigation journey
- [ ] Technical architecture learned
- [ ] Patterns identified and numbered
- [ ] Time breakdown
- [ ] Key takeaways
- [ ] Files modified/created
- [ ] Cross-references to other docs

When updating pattern quick reference:
- [ ] Add pattern to index by category
- [ ] Add row to quick lookup table
- [ ] Add example to common pitfalls (if applicable)
- [ ] Update debugging checklist (if applicable)
- [ ] Update time investment guidelines (if applicable)

---

## Related Files

### Machine Scripts
- `C:\scripts\_machine\reflection.log.md` - All patterns with session context
- `C:\scripts\_machine\pr-dependencies.md` - Cross-repo PR tracking
- `C:\scripts\_machine\worktrees.pool.md` - Worktree allocation tracking

### Repository Changelogs
- `client-manager/CLAUDE.md` - Client-manager changes by date
- `Hazina/CLAUDE.md` - Hazina changes by date (if exists)

### Tools Documentation
- `C:\scripts\tools\README.md` - Available automation tools
- `C:\scripts\claude.md` - Full operational manual

---

## Statistics

### 2026-01-11 Session
- **Total Investigation Time:** 2.5 hours
- **Lines of Code Changed:** 1
- **PRs Created:** 2 (Hazina #37, client-manager #96)
- **PRs Updated:** 2 (Hazina #37 description, client-manager #94 context)
- **Patterns Documented:** 4 (66-69)
- **Documentation Created:** ~1,500 lines

### Knowledge Base Totals
- **Deep-Dive Documents:** 1
- **Pattern Documents:** 1
- **Total Patterns:** 69
- **Total Lines:** ~2,000

---

## Quick Commands

### Search All Knowledge
```bash
# Find pattern by number
grep -r "Pattern 68" C:\scripts\_machine\knowledge\

# Find by keyword
grep -ri "configuration" C:\scripts\_machine\knowledge\

# List all patterns
grep -r "^##.*Pattern [0-9]" C:\scripts\_machine\knowledge\
```

### Update Knowledge Base
```bash
# Create new deep-dive
cp C:\scripts\_machine\knowledge\image-generation-debugging-complete.md \
   C:\scripts\_machine\knowledge\new-session-template.md

# Update pattern quick reference
nano C:\scripts\_machine\knowledge\patterns-quick-reference.md

# Update this index
nano C:\scripts\_machine\knowledge\README.md
```

---

**Last Updated:** 2026-01-11 06:45 UTC
**Maintained By:** Autonomous agent system
**Version:** 1.0
