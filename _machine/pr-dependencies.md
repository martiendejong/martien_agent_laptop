# Active PR Dependencies

Track cross-repository PR dependencies between Hazina and client-manager.

## Current Dependencies

| Downstream PR | Depends On (Hazina) | Status | Notes |
|---------------|---------------------|--------|-------|
| [client-manager#257](https://github.com/martiendejong/client-manager/pull/257) | [Hazina#85](https://github.com/martiendejong/Hazina/pull/85) | ⏳ Waiting | Backend genericness - Pagination, Repository, SoftDelete patterns |
| [artrevisionist#22](https://github.com/martiendejong/artrevisionist/pull/22) | [Hazina#51](https://github.com/martiendejong/Hazina/pull/51) | ⏳ Waiting | Document processing - UploadedFile and ImageMetadata enhancements |
| [client-manager#96](https://github.com/martiendejong/client-manager/pull/96) | [Hazina#37](https://github.com/martiendejong/Hazina/pull/37) | ⏳ Waiting | Image generation fix - missing Model parameter in OpenAIConfig |
| [client-manager#35](https://github.com/martiendejong/client-manager/pull/35) | [Hazina#9](https://github.com/martiendejong/Hazina/pull/9) | ⏳ Waiting | SemanticCache adapters need GenerateEmbeddingAsync |

## PRs Requiring Base Branch Fix

✅ **All base branches fixed on 2026-01-09**

| PR | Title | Base | Status |
|---|---|---|---|
| [#54](https://github.com/martiendejong/client-manager/pull/54) | Multi-Client Switcher | develop | ✅ Fixed |
| [#55](https://github.com/martiendejong/client-manager/pull/55) | Smart Scheduling | develop | ✅ Fixed |
| [#56](https://github.com/martiendejong/client-manager/pull/56) | Approval Workflows | develop | ✅ Fixed |
| [#57](https://github.com/martiendejong/client-manager/pull/57) | ROI Calculator | develop | ✅ Fixed |

## Client-Manager Stabilization Status

**Current State (2026-01-09):**
- ✅ Critical fix PRs merged:
  - [Hazina #13](https://github.com/martiendejong/Hazina/pull/13) - Chat LLM config fix (merged 2026-01-08T21:36:15Z)
  - [Client-Manager #58](https://github.com/martiendejong/client-manager/pull/58) - DI refactoring (merged 2026-01-08T21:36:20Z)
- ✅ Both repos build successfully (0 errors)
- ⏸️ 12 feature PRs queued, ready for merge after testing

**Merge Order (after testing):**
1. #50 (Translation) - 260 lines
2. #52 (Cross-Post) - 586 lines
3. #47 (Quality Score) - 1008 lines
4. #53 (Content Calendar) - 1112 lines
5. #49 (Alt Text) - 1259 lines
6. #46 (Test Infrastructure) - 1639 lines
7. #51 (Content Templates) - 2078 lines
8. #48 (Performance) - 4147 lines
9. #54-57 (after base branch fix)

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

### 2026-01-09 (13:30 UTC)
- ✅ All PR issues resolved:
  - **Client-Manager:** All 3 open PRs (#52, #56, #57) are MERGEABLE with passing checks
  - **Hazina:** All 5 open PRs (#15-19) are MERGEABLE
  - PR #15 has stale Trivy failure from old commit, recent runs all pass
  - Only NU1902 warnings (package vulnerabilities) remain - non-blocking

### 2026-01-09 (12:30 UTC)
- ✅ Fixed PR #52 (Cross-Post Optimizer) build failure:
  - Removed directory-based feature chunks from vite.config.ts
  - Merged latest develop to get @radix-ui/react-dropdown-menu dependency
  - Build now succeeds
- ✅ Fixed base branches for PRs #54-57 (all changed from main → develop)
- ✅ PR #57 conflicts were already resolved in previous merge commit

### 2026-01-09 (earlier)
- ✅ Merged critical fix PRs:
  - Hazina #13 (Chat LLM config fix)
  - Client-Manager #58 (DI refactoring)
- Updated stabilization status to reflect successful builds
- Fixed Hazina PR #13 base branch from main → develop before merge

### 2026-01-08 (evening)
- Added PRs Requiring Base Branch Fix section (PRs #54-57 target main instead of develop)
- Added Client-Manager Stabilization Status section
- Added recommended merge order for 12 queued PRs

### 2026-01-08
- File created for tracking cross-repo dependencies
- Added convention to claude.md
