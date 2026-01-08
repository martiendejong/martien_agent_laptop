# Branch Cleanup & Merge Plan - Hazina & Client-Manager
**Gegenereerd**: 2026-01-08
**Status**: Pending User Approval

---

## 🎯 PRIORITEIT 1: Unmerged Changes naar Develop

### HAZINA

- [ ] **agent-003-brand-fragments** (10 commits voor op develop)
  - Actie: Review code changes
  - Actie: Create PR naar develop
  - Actie: Merge PR
  - Actie: Delete branch lokaal + remote

- [ ] **agent-006-deduplication** (6 commits voor op develop)
  - Actie: Review code changes
  - Actie: Create PR naar develop
  - Actie: Merge PR
  - Actie: Delete branch lokaal + remote

- [ ] **reduce_token_usage** (1 commit voor op develop)
  - Actie: Review code changes
  - Actie: Create PR naar develop
  - Actie: Merge PR
  - Actie: Delete branch lokaal + remote

### CLIENT-MANAGER

- [ ] **agent001-webpage-retrieval-tools** (1 commit voor op develop, NIET gepushed!)
  - Actie: Push naar remote: `git push -u origin agent001-webpage-retrieval-tools`
  - Actie: Review code changes
  - Actie: Create PR naar develop
  - Actie: Merge PR
  - Actie: Delete branch lokaal + remote

---

## 🎯 PRIORITEIT 2: Develop naar Main Mergen

- [ ] **HAZINA: Merge develop → main** (9 commits)
  - Actie: Review develop commits vs main
  - Actie: Create PR: develop → main
  - Actie: Merge PR
  - Notitie: Na deze merge is main up-to-date

- [ ] **CLIENT-MANAGER: Merge develop → main** (75 commits!)
  - Actie: Review develop commits vs main
  - Actie: Create PR: develop → main
  - Actie: Merge PR
  - Notitie: Na deze merge is main up-to-date

---

## 🎯 PRIORITEIT 3: Delete Gemerged Branches

### HAZINA - Branches volledig gemerged in develop

- [ ] **agent-002-context-compression** (0 commits voor)
  - Actie: Verify merged: `git branch --merged develop | grep agent-002-context-compression`
  - Actie: Delete lokaal: `git branch -d agent-002-context-compression`
  - Actie: Delete remote: `git push origin --delete agent-002-context-compression`

- [ ] **agent-002-tool-agent-3layer** (0 commits voor)
  - Actie: Verify merged: `git branch --merged develop`
  - Actie: Delete lokaal: `git branch -d agent-002-tool-agent-3layer`
  - Actie: Keep remote (already merged via PR)

- [ ] **agent-005-google-drive-hazina** (0 commits voor op develop, maar 8 voor op main)
  - Actie: Verify merged: `git branch --merged develop`
  - Actie: Delete lokaal: `git branch -d agent-005-google-drive-hazina`
  - Actie: Delete remote: `git push origin --delete agent-005-google-drive-hazina`

- [ ] **agent-006-workflow-fix** (0 commits voor op develop)
  - Actie: Verify merged: `git branch --merged develop`
  - Actie: Delete lokaal: `git branch -d agent-006-workflow-fix`
  - Actie: Delete remote: `git push origin --delete agent-006-workflow-fix`

- [ ] **bulkchanges3** (0 commits voor)
  - Actie: Verify merged: `git branch --merged develop`
  - Actie: Delete lokaal: `git branch -d bulkchanges3`
  - Actie: Delete remote: `git push origin --delete bulkchanges3`

- [ ] **fix/add-missing-projects-and-fix-promptmanagement** (0 commits voor)
  - Actie: Verify merged: `git branch --merged develop`
  - Actie: Delete lokaal: `git branch -d fix/add-missing-projects-and-fix-promptmanagement`
  - Actie: Delete remote: `git push origin --delete fix/add-missing-projects-and-fix-promptmanagement`

- [ ] **fix/package-version-conflicts** (0 commits voor)
  - Actie: Verify merged: `git branch --merged develop`
  - Actie: Delete lokaal: `git branch -d fix/package-version-conflicts`
  - Actie: Delete remote: `git push origin --delete fix/package-version-conflicts`

- [ ] **token_use_optimization** (0 commits voor)
  - Actie: Verify merged: `git branch --merged develop`
  - Actie: Delete lokaal: `git branch -d token_use_optimization`
  - Actie: Delete remote: `git push origin --delete token_use_optimization`

### CLIENT-MANAGER - Agent Branches Gemerged in Develop

- [ ] **agent-001** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-001`

- [ ] **agent-001-chat-virtual-scrolling** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-001-chat-virtual-scrolling && git push origin --delete agent-001-chat-virtual-scrolling`

- [ ] **agent-001-content-hooks-feature** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-001-content-hooks-feature && git push origin --delete agent-001-content-hooks-feature`

- [ ] **agent-001-content-hooks-ui** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-001-content-hooks-ui`

- [ ] **agent-001-disable-signup-message** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-001-disable-signup-message && git push origin --delete agent-001-disable-signup-message`

- [ ] **agent-001-fix-user-management** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-001-fix-user-management && git push origin --delete agent-001-fix-user-management`

- [ ] **agent-001-holographic-evolution** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-001-holographic-evolution`

- [ ] **agent-001-holographic-evolution-v2** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-001-holographic-evolution-v2 && git push origin --delete agent-001-holographic-evolution-v2`

- [ ] **agent-001-license-manager** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-001-license-manager`
  - Actie: Delete remote: `git push origin --delete agent-001-license-manager`

- [ ] **agent-001-product-catalog-phase1** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-001-product-catalog-phase1 && git push origin --delete agent-001-product-catalog-phase1`

- [ ] **agent-001-product-catalog-phases234** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-001-product-catalog-phases234`

- [ ] **agent-001-product-catalog-phases234-docs** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-001-product-catalog-phases234-docs && git push origin --delete agent-001-product-catalog-phases234-docs`

- [ ] **agent-001-product-catalog-phases234-impl** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-001-product-catalog-phases234-impl && git push origin --delete agent-001-product-catalog-phases234-impl`

- [ ] **agent-001-revolutionary-ui-concepts** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-001-revolutionary-ui-concepts`

- [ ] **agent-001-ui-proposals** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-001-ui-proposals`

- [ ] **agent-001-ui-proposals-revolutionary** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-001-ui-proposals-revolutionary && git push origin --delete agent-001-ui-proposals-revolutionary`

- [ ] **agent001-webpage-tools** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent001-webpage-tools`

- [ ] **agent-002** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-002`

- [ ] **agent-002-fix-registration-duplicate-email** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-002-fix-registration-duplicate-email`
  - Actie: Delete remote: `git push origin --delete agent-002-fix-registration-duplicate-email`

- [ ] **agent-002-tool-agent-3layer** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-002-tool-agent-3layer && git push origin --delete agent-002-tool-agent-3layer`

- [ ] **agent-003-brand-fragments** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-003-brand-fragments && git push origin --delete agent-003-brand-fragments`

- [ ] **agent-003-document-tagging** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-003-document-tagging && git push origin --delete agent-003-document-tagging`

- [ ] **agent-004** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-004`

- [ ] **agent-004-revolutionary-concepts-final** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-004-revolutionary-concepts-final`
  - Actie: Delete remote: `git push origin --delete agent-004-revolutionary-concepts-final`

- [ ] **agent-005-documentation-improvements** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d agent-005-documentation-improvements && git push origin --delete agent-005-documentation-improvements`

- [ ] **agent-005-google-drive-integration** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d agent-005-google-drive-integration`
  - Actie: Delete remote: `git push origin --delete agent-005-google-drive-integration`

### CLIENT-MANAGER - Feature Branches Gemerged in Develop

- [ ] **feature/logo-variation-improvements** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d feature/logo-variation-improvements && git push origin --delete feature/logo-variation-improvements`

- [ ] **feature/restaurant-menu-documents** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d feature/restaurant-menu-documents && git push origin --delete feature/restaurant-menu-documents`

- [ ] **feature/reliability-improvements** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feature/reliability-improvements`

- [ ] **fix/build-errors-duplicate-class-and-tokentransaction** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d fix/build-errors-duplicate-class-and-tokentransaction && git push origin --delete fix/build-errors-duplicate-class-and-tokentransaction`

### CLIENT-MANAGER - Improvement Branches Gemerged in Develop

- [ ] **improvement/CM-002-dynamic-model-routing** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d improvement/CM-002-dynamic-model-routing && git push origin --delete improvement/CM-002-dynamic-model-routing`

- [ ] **improvement/CM-011-query-optimization** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d improvement/CM-011-query-optimization && git push origin --delete improvement/CM-011-query-optimization`

- [ ] **improvement/CM-022-content-adaptation** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d improvement/CM-022-content-adaptation && git push origin --delete improvement/CM-022-content-adaptation`

- [ ] **improvement/CM-051-semantic-cache** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d improvement/CM-051-semantic-cache && git push origin --delete improvement/CM-051-semantic-cache`

- [ ] **improvement/CM-054-progressive-refinement** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d improvement/CM-054-progressive-refinement && git push origin --delete improvement/CM-054-progressive-refinement`

- [ ] **improvement/CM-054-quality-scoring** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d improvement/CM-054-quality-scoring`
  - Actie: Delete remote: `git push origin --delete improvement/CM-054-quality-scoring`

- [ ] **improvement/CM-064-unlimited-plan** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d improvement/CM-064-unlimited-plan && git push origin --delete improvement/CM-064-unlimited-plan`

- [ ] **improvement/CM-161-interactive-demo** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d improvement/CM-161-interactive-demo && git push origin --delete improvement/CM-161-interactive-demo`

### CLIENT-MANAGER - Bulkchanges Branches (All 0 commits ahead)

- [ ] **bulkchanges** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d bulkchanges`
  - Actie: Delete remote: `git push origin --delete bulkchanges`

- [ ] **bulkchanges3** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d bulkchanges3`
  - Actie: Delete remote: `git push origin --delete bulkchanges3`

- [ ] **bulkchanges3-import-website** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d bulkchanges3-import-website`

- [ ] **bulkchanges3-interview-tool** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d bulkchanges3-interview-tool`

- [ ] **bulkchanges3-naming** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d bulkchanges3-naming`

- [ ] **bulkchanges3-routing** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d bulkchanges3-routing`

- [ ] **bulkchanges3-tagging** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d bulkchanges3-tagging`

### CLIENT-MANAGER - Feedback Branches (All 0 commits ahead)

- [ ] **feedback2-fix-chat-naming-v2** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback2-fix-chat-naming-v2`

- [ ] **feedback2-fix-connection-status-v2** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback2-fix-connection-status-v2`

- [ ] **feedback2-fix-logo-transparency** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback2-fix-logo-transparency`

- [ ] **feedback2-fix-new-project-creation-critical** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback2-fix-new-project-creation-critical`

- [ ] **feedback3-fix-new-project-message-display** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback3-fix-new-project-message-display`

- [ ] **feedback-fix-analysis-fields-generation** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback-fix-analysis-fields-generation`

- [ ] **feedback-fix-chat-naming** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback-fix-chat-naming`

- [ ] **feedback-fix-loading-duration** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback-fix-loading-duration`

- [ ] **feedback-fix-new-project-creation** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback-fix-new-project-creation`

- [ ] **feedback-improve-connection-status-ui** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback-improve-connection-status-ui`

- [ ] **feedback-prevent-brand-name-duplication** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback-prevent-brand-name-duplication`

- [ ] **feedback-prevent-duplicate-gathered-data** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d feedback-prevent-duplicate-gathered-data`

### CLIENT-MANAGER - Task Branches (All 0 commits ahead)

- [ ] **task1-instant-scroll-on-open** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d task1-instant-scroll-on-open`

- [ ] **task2-fix-image-reference-retrieval** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d task2-fix-image-reference-retrieval`

- [ ] **task-filter-gathered-data** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d task-filter-gathered-data`

- [ ] **task-fix-signalr-connection** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d task-fix-signalr-connection`

- [ ] **task-improve-logo-generation** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d task-improve-logo-generation`

- [ ] **task-loading-indicators** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d task-loading-indicators`

### CLIENT-MANAGER - Misc Branches (All 0 commits ahead)

- [ ] **google_adk** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d google_adk`

- [ ] **picture_upload** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d picture_upload`

- [ ] **reduce_token_usage** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d reduce_token_usage`

- [ ] **test** (0 commits voor)
  - Actie: Delete lokaal: `git branch -d test`

- [ ] **token_use_optimization** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d token_use_optimization && git push origin --delete token_use_optimization`

- [ ] **upgrade_ui_infrastructure** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d upgrade_ui_infrastructure && git push origin --delete upgrade_ui_infrastructure`

- [ ] **new_ui** (0 commits voor)
  - Actie: Delete lokaal + remote
  - Commands: `git branch -d new_ui && git push origin --delete new_ui`

---

## 🎯 PRIORITEIT 4: Investigate Remote-Only Branches

### HAZINA

- [ ] **refactor-name-and-structure** (remote only)
  - Actie: Fetch: `git fetch origin refactor-name-and-structure`
  - Actie: Check commits: `git log origin/refactor-name-and-structure --not develop`
  - Actie: Als al gemerged: `git push origin --delete refactor-name-and-structure`
  - Actie: Anders: Review en besluit

### CLIENT-MANAGER

- [ ] **feature/single-llm-with-tools** (remote only)
  - Actie: Fetch: `git fetch origin feature/single-llm-with-tools`
  - Actie: Check commits: `git log origin/feature/single-llm-with-tools --not develop`
  - Actie: Als al gemerged: `git push origin --delete feature/single-llm-with-tools`
  - Actie: Anders: Review en besluit

- [ ] **hazina** (remote only)
  - Actie: Fetch: `git fetch origin hazina`
  - Actie: Check commits: `git log origin/hazina --not develop`
  - Actie: Als al gemerged: `git push origin --delete hazina`
  - Actie: Anders: Review en besluit

- [ ] **payment** (remote only)
  - Actie: Fetch: `git fetch origin payment`
  - Actie: Check commits: `git log origin/payment --not develop`
  - Actie: Als al gemerged: `git push origin --delete payment`
  - Actie: Anders: Review en besluit

- [ ] **rename_api** (remote only)
  - Actie: Fetch: `git fetch origin rename_api`
  - Actie: Check commits: `git log origin/rename_api --not develop`
  - Actie: Als al gemerged: `git push origin --delete rename_api`
  - Actie: Anders: Review en besluit

---

## 🎯 PRIORITEIT 5: Local-Only Old Branches (Besluit nodig)

### HAZINA

- [ ] **bulkchanges** (lokaal only, oude branch)
  - Actie: Review of nog nodig
  - Actie: Delete als niet nodig: `git branch -D bulkchanges`
  - Actie: Of push + PR: `git push -u origin bulkchanges`

- [ ] **bulkchanges3-import-website** (lokaal only)
  - Actie: Review of nog nodig
  - Actie: Delete als niet nodig: `git branch -D bulkchanges3-import-website`

- [ ] **bulkchanges3-naming** (lokaal only)
  - Actie: Review of nog nodig
  - Actie: Delete als niet nodig: `git branch -D bulkchanges3-naming`

- [ ] **bulkchanges3-tagging** (lokaal only)
  - Actie: Review of nog nodig
  - Actie: Delete als niet nodig: `git branch -D bulkchanges3-tagging`

- [ ] **google_adk** (lokaal only)
  - Actie: Review of nog nodig
  - Actie: Delete als niet nodig: `git branch -D google_adk`

- [ ] **maibn** (lokaal only)
  - Actie: Review of nog nodig
  - Actie: Delete als niet nodig: `git branch -D maibn`

- [ ] **picture_upload** (lokaal only)
  - Actie: Review of nog nodig
  - Actie: Delete als niet nodig: `git branch -D picture_upload`

- [ ] **task3-document-summarization** (lokaal only)
  - Actie: Review of nog nodig
  - Actie: Delete als niet nodig: `git branch -D task3-document-summarization`

---

## 📊 SAMENVATTING

**Totaal aantal taken**: ~120+ branches
- Priority 1 (Unmerged): 4 branches
- Priority 2 (Develop→Main): 2 merges
- Priority 3 (Cleanup gemerged): ~100+ branches
- Priority 4 (Remote-only investigate): 6 branches
- Priority 5 (Local-only oude branches): 8 branches

**Geschatte tijdsinvestering**:
- Priority 1: 2-4 uur (review + PRs)
- Priority 2: 1-2 uur (review + merge)
- Priority 3: 30-60 min (bulk delete commands)
- Priority 4: 30 min (investigate)
- Priority 5: 15 min (review + delete)

**Totaal**: ~5-8 uur werk

---

## 🚀 QUICK WIN COMMANDS

### Bulk delete gemerged lokale branches (CLIENT-MANAGER):
```bash
cd "C:\Projects\client-manager"
git branch --merged develop | grep -v "\*\|develop\|main" | xargs -r git branch -d
```

### Bulk delete gemerged lokale branches (HAZINA):
```bash
cd "C:\Projects\hazina"
git branch --merged develop | grep -v "\*\|develop\|main" | xargs -r git branch -d
```

### Delete remote gemerged branches (na manual review!):
```bash
# Hazina
cd "C:\Projects\hazina"
git push origin --delete agent-002-context-compression
git push origin --delete agent-005-google-drive-hazina
git push origin --delete agent-006-workflow-fix
git push origin --delete bulkchanges3
git push origin --delete fix/add-missing-projects-and-fix-promptmanagement
git push origin --delete fix/package-version-conflicts

# Client-Manager (veel meer, zie individuele taken)
```

---

## ✅ COMPLETION CHECKLIST

- [ ] Priority 1 completed: All unmerged changes in develop
- [ ] Priority 2 completed: Develop merged to main (both repos)
- [ ] Priority 3 completed: All gemerged branches deleted
- [ ] Priority 4 completed: Remote-only branches investigated
- [ ] Priority 5 completed: Old local branches cleaned up
- [ ] Final verification: `git branch -a` shows only active branches
- [ ] Update dit bestand met completion status

---

**NEXT STEP**: Review dit plan en geef toestemming om te starten met Priority 1!
