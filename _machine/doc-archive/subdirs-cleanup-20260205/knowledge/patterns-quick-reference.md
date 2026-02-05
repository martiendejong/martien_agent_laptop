# Patterns Quick Reference
**Last Updated:** 2026-01-11
**Total Patterns:** 69

---

## Pattern Index by Category

### Configuration & Initialization
- **Pattern 68**: Default Values in Base Classes
  - Check ALL base class properties before using derived classes
  - Empty string ≠ null for SDK validation
  - Set ALL required properties explicitly

### Error Handling & Debugging
- **Pattern 67**: Misleading Success Logs
  - Place success logs AFTER verification, not before async operations
  - Log actual result data, not assumptions
  - Add logging at EVERY layer of abstraction

- **Pattern 69**: Multi-Layer Error Investigation
  - Don't stop at first error level - drill down to root cause
  - Frontend → Backend Controller → Service → SDK → Configuration
  - User-facing error often 3-5 layers away from root cause

### Cross-Repository Coordination
- **Pattern 66**: Cross-Repo Dependency Tracking
  - Document dependencies in pr-dependencies.md
  - Add DEPENDENCY ALERT headers to both upstream and downstream PRs
  - Specify explicit merge order
  - Local ProjectReferences propagate changes immediately on rebuild

---

## Quick Lookup Table

| Pattern # | Name | When to Use | Key Action |
|-----------|------|-------------|------------|
| 66 | Cross-Repo Dependencies | Multi-repo fixes | Update pr-dependencies.md |
| 67 | Misleading Success Logs | Async operations | Log AFTER verification |
| 68 | Base Class Defaults | Config initialization | Check ALL properties |
| 69 | Multi-Layer Errors | Complex bugs | Drill through ALL layers |

---

## Debugging Checklist

### When Investigation Stalls
- [ ] Have I checked git history for recent changes?
- [ ] Have I added logging at ALL layers?
- [ ] Have I verified success logs reflect actual completion?
- [ ] Have I checked base class properties?
- [ ] Have I examined SDK source code?
- [ ] Have I searched with multiple strategies? (grep, glob, git log)
- [ ] Have I asked user for actual logs vs relying on description?

### Before Creating Cross-Repo PR
- [ ] Identified which repo contains actual fix (upstream)
- [ ] Created upstream PR first
- [ ] Updated pr-dependencies.md
- [ ] Added DEPENDENCY ALERT header to upstream PR
- [ ] Added DEPENDENCY ALERT header to downstream PR
- [ ] Linked PRs to each other in descriptions
- [ ] Specified merge order clearly

### Before Merging Config Changes
- [ ] Verified all base class properties are set
- [ ] Checked for empty string vs null validation differences
- [ ] Added tests for config initialization
- [ ] Documented which properties are required

---

## Common Pitfalls

### Configuration
```csharp
// ❌ WRONG - Missing Model property
var config = new OpenAIConfig(apiKey);
config.ImageModel = "dall-e-3";
// config.Model is still string.Empty!

// ✅ CORRECT - Set ALL required properties
var config = new OpenAIConfig(apiKey);
config.Model = "gpt-4o-mini";
config.ImageModel = "dall-e-3";
```

### Logging
```csharp
// ❌ WRONG - Success logged before verification
Console.WriteLine("Operation successful");
var result = await DoSomethingAsync();
return result;

// ✅ CORRECT - Log after verification
var result = await DoSomethingAsync();
if (result?.IsSuccessful == true)
{
    Console.WriteLine("Operation successful");
}
return result;
```

### Error Investigation
```
// ❌ WRONG - Stop at first error
Frontend says: "No data returned"
Fix: Add null check in frontend
// Bug still exists in backend!

// ✅ CORRECT - Drill to root cause
Frontend: "No data returned"
  ↓ Why?
Backend: "ExtractUrl returned empty"
  ↓ Why?
Service: "Generation failed"
  ↓ Why?
Config: Model property not set
  ↓ FIX HERE
```

---

## Time Investment Guidelines

Based on 2026-01-11 session:

| Activity | Expected Time | Value |
|----------|---------------|-------|
| Layer 1 fix (obvious bug) | 15-30 min | Quick win |
| Layer 2 investigation | 30-60 min | Moderate |
| Layer 3 root cause | 30-90 min | High learning value |
| Documentation | 30-60 min | Prevents future issues |

**ROI:** Patterns documented prevent 2-3 hours per future occurrence.

**Decision Point:** After 2 hours of investigation, create detailed logs even if not fixed yet. The investigation itself is valuable.

---

## Cross-Reference

### Full Documentation
- Complete session details: `knowledge/image-generation-debugging-complete.md`
- All patterns with context: `reflection.log.md`
- Repository changelogs: `<repo>/CLAUDE.md`

### Related Patterns
- Pattern 64: TypeScript Cleanup Can Break Runtime Logic
- Pattern 65: Defensive Extraction - Try Everything, Log Everything

---

**Usage:** Reference this file when encountering similar issues. For full context and examples, see the complete documentation.
