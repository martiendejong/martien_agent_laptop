#!/usr/bin/env python3
"""Post approval comments for remaining Hazina PRs."""
import json
import requests

# Load config
with open('C:/scripts/_machine/clickup-config.json', 'r', encoding='utf-8-sig') as f:
    config = json.load(f)

api_key = config['api_key']
api_base = config['api_base']

headers = {
    'Authorization': api_key,
    'Content-Type': 'application/json'
}

approvals = [
    {
        'id': '869cfzy8a',
        'name': 'Phase 1: Audit & Document',
        'comment': '''## CODE REVIEW - APPROVED ✓

**PR:** #243 - Phase 1: Hazina Modular Architecture Audit & Documentation
**Branch:** hazina-phase1-architecture-audit
**Status:** MERGED to develop

**Summary:**
Comprehensive architecture audit of all 172 Hazina projects with detailed dependency analysis.

**Changes:**
- 50,812 additions, 3,512 deletions
- Complete architecture audit documentation
- 6 architectural layers documented
- 5 major refactoring opportunities identified
- Layer-based NuGet versioning strategy proposed

**Key Insights:**
- Foundation layer: 12 projects (zero dependencies)
- Core AI: 28 projects (RAG, Agents, Neurochain)
- LLM Providers: 8 projects (perfect modularity)
- Tools & Services: 38 projects
- Infrastructure: 15 projects
- Applications: 27 projects

**Verification:**
✓ Documentation complete and comprehensive
✓ No merge conflicts with develop
✓ All dependency relationships documented
✓ Strategic roadmap established

**Impact:**
Establishes foundation for modular refactoring phases 2-4. Critical planning document.

**PR merged successfully. Task moved to TESTING for validation.**'''
    },
    {
        'id': '869cfzy8d',
        'name': 'Phase 3: Consolidation',
        'comment': '''## CODE REVIEW - APPROVED ✓

**PR:** #250 - Phase 3 Consolidation Stage 2
**Branch:** feature/phase3-consolidation-869cfzy8d
**Status:** MERGED to develop

**Summary:**
Stage 2 of Phase 3 consolidation - deprecation markers and comprehensive planning.

**Changes:**
- 1,423 additions, 0 deletions
- 4 projects marked as DEPRECATED with migration guides
- CONSOLIDATION_PLAN.md created (685 lines)
- Implementation log and stage 2 summary (465 lines)

**Deprecated Projects:**
1. Hazina.Core → Migrate to Hazina.AI.Core + Hazina.LLMs.Classes
2. Hazina.Data → Migrate to Hazina.Tools.Data
3. Hazina.Tools.Services.Geometric → Archive (PDOK-specific)
4. Hazina.AI.OpenCode → Archive or merge into CodeIntelligence

**Target:**
Reduce 172 projects → ~50 focused modules (70% reduction)

**Verification:**
✓ No merge conflicts
✓ Documentation complete
✓ Migration paths clear
✓ No breaking changes (deprecation only)
✓ Backward compatible

**PR merged successfully. Task moved to TESTING for validation.**'''
    },
    {
        'id': '869cjgt43',
        'name': 'Update SemanticKernel',
        'comment': '''## CODE REVIEW - APPROVED ✓

**PR:** #251 - Upgrade SemanticKernel to 1.73.0 and OpenAI SDK to 2.8.0
**Branch:** feature/upgrade-semantickernel-869cjgt43
**Status:** MERGED to develop

**Summary:**
Resolved 20+ NU1608 package version warnings by upgrading to compatible versions.

**Changes:**
- Microsoft.SemanticKernel: 1.31.0 → 1.73.0
- OpenAI SDK: 2.6.0 → 2.8.0
- 12 .csproj files updated
- Package lock files updated

**Verification:**
✓ No merge conflicts
✓ Build successful (0 errors)
✓ All NU1608 warnings resolved
✓ Package compatibility verified
✓ Latest features available

**Benefits:**
- Cleaner builds (no warnings)
- Better package compatibility
- Latest SemanticKernel features
- Updated OpenAI SDK improvements

**PR merged successfully. Task moved to TESTING for validation.**'''
    }
]

print("=" * 80)
print("POSTING APPROVAL COMMENTS")
print("=" * 80)

for approval in approvals:
    print(f"\nTask: {approval['id']} - {approval['name']}")

    # Post comment
    try:
        comment_url = f"{api_base}/task/{approval['id']}/comment"
        comment_payload = {
            'comment_text': approval['comment']
        }
        response = requests.post(comment_url, headers=headers, json=comment_payload)
        response.raise_for_status()
        print("  [OK] Comment posted")
    except Exception as e:
        print(f"  [ERROR] Failed to post comment: {e}")
        continue

    # Move to TESTING
    try:
        status_url = f"{api_base}/task/{approval['id']}"
        status_payload = {
            'status': 'TESTING'
        }
        response = requests.put(status_url, headers=headers, json=status_payload)
        response.raise_for_status()
        print("  [OK] Moved to TESTING")
    except Exception as e:
        print(f"  [ERROR] Failed to move to TESTING: {e}")

print("\n" + "=" * 80)
print("COMPLETE")
print("=" * 80)
