# Active PR Dependencies

Track cross-repository PR dependencies between Hazina and client-manager.

## Current Dependencies

| Downstream PR | Depends On (Hazina) | Status | Notes |
|---------------|---------------------|--------|-------|
| [client-manager#35](https://github.com/martiendejong/client-manager/pull/35) | [Hazina#9](https://github.com/martiendejong/Hazina/pull/9) | ⏳ Waiting | SemanticCache adapters need GenerateEmbeddingAsync |

## Legend

- **Downstream PR**: The PR that requires changes from another repo
- **Depends On**: The Hazina PR(s) that must be merged first
- **Status**:
  - ⏳ Waiting - Hazina PR not yet merged
  - ✅ Ready - Hazina PR merged, downstream can proceed
  - 🔀 Merged - Both PRs merged successfully
  - ❌ Blocked - Issue preventing merge

## How to Use

### When creating a client-manager PR that depends on Hazina:

1. Add entry to this file with the dependency
2. Add `## ⚠️ DEPENDENCY ALERT` header to client-manager PR description
3. Add `## ⚠️ DOWNSTREAM DEPENDENCIES` header to Hazina PR description

### When merging Hazina PRs:

1. Check this file for dependent client-manager PRs
2. Update status from ⏳ to ✅
3. Notify user about ready downstream PRs

### Cleanup:

- Remove entries when both PRs are merged (status 🔀)
- Archive old entries monthly

---

## History

### 2026-01-08
- File created for tracking cross-repo dependencies
- Added convention to claude.md
