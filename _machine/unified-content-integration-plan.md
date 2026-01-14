# Unified Content System Integration Plan

**Created:** 2026-01-14
**Goal:** Integrate unified component system with PR #149 (allitemslist) safely and incrementally

---

## Executive Summary

The unified content system can be built **ON TOP OF** PR #149's architecture rather than replacing it. The allitemslist branch provides:
- Discriminated union type system (extensible)
- Component hierarchy (chat, sidebar, fullscreen via modal)
- Zustand store with filters and selectors
- Real-time event listeners

**Recommendation:** Merge PR #149 first, then extend it with unified component features in subsequent PRs.

---

## Architecture Alignment Analysis

### Type System Mapping

| Unified Schema | PR #149 Type | Compatibility |
|---------------|--------------|---------------|
| `brand-name` | `analysis` | Direct match |
| `logo` | `analysis` + `document` | Extend metadata |
| `business-plan` | `analysis` | Direct match |
| `menu-item` | New: `menu-item` | Add new type |
| `uploaded-document` | `document` | Direct match |
| `gathered-data` | `gathered` | Direct match |
| `upload-file` (action) | N/A - new concept | Add action component |
| `connect-facebook` (action) | N/A - new concept | Add action component |

### Source Field Alignment

| Unified Schema | PR #149 |
|---------------|---------|
| `source.allowed: ["ai", "user", "extracted"]` | `source?: 'user' \| 'system' \| 'ai'` |

**Action needed:** Add `'extracted'` to PR #149's source union type.

### Display Mode Mapping

| Unified Schema | PR #149 Component |
|---------------|-------------------|
| `displays.chat` | `ActivityItem` (in chat context) |
| `displays.sidebar` | `ActivityItemCard` in `ActivitySidebar` |
| `displays.fullscreen` | `PopupDetailModal` |

**Key insight:** PR #149 already has the three display contexts - we just need to make rendering configurable per item type.

---

## Integration Strategy

### Phase 0: Merge PR #149 First (Prerequisite)
- Review and approve PR #149
- Test with feature flag enabled
- Deploy to production with flag off
- Enable flag for beta users
- Roll out to all users

### Phase 1: Extend Type System (Non-Breaking)
**Branch:** `feature/unified-types` (from develop AFTER PR #149 merged)

1. Add new source value: `'extracted'`
2. Add optional metadata fields to existing types:
   ```typescript
   interface ActivityItemBase {
     // Existing...

     // NEW optional fields
     displayConfig?: {
       chat?: { enabled: boolean; component?: string };
       sidebar?: { enabled: boolean; showInList?: string };
       fullscreen?: { enabled: boolean; allowEdit?: boolean };
     };
     generationConfig?: {
       enabled: boolean;
       promptFile?: string;
       tokenCost?: number;
     };
   }
   ```
3. Add `menu-item` type to discriminated union
4. Add `product` type extensions for restaurant features

**Effort:** Small - backwards compatible changes only

### Phase 2: Action Components Framework
**Branch:** `feature/action-components` (from Phase 1)

1. Create action component registry:
   ```
   src/features/activity-feed/actions/
   ├── ActionComponentRegistry.ts
   ├── FileUploadAction.tsx
   ├── OAuthConnectAction.tsx
   └── ConfirmationAction.tsx
   ```

2. Extend `PopupDetailModal` to render action components:
   ```typescript
   <PopupDetailModal item={item}>
     {item.actionComponent && (
       <ActionRenderer type={item.actionComponent.type} />
     )}
   </PopupDetailModal>
   ```

3. Add action items to store:
   ```typescript
   type ItemType =
     | /* existing */
     | 'file-upload'
     | 'oauth-connect'
     | 'confirmation';
   ```

**Effort:** Medium - new components but no breaking changes

### Phase 3: Unified Configuration
**Branch:** `feature/unified-config` (from Phase 2)

1. Create `unified-components.config.json` in stores/brand2boost/
2. Create config loader service:
   ```typescript
   export const componentConfigService = {
     getComponentConfig(id: string): ComponentConfig;
     getDisplayConfig(id: string, context: 'chat' | 'sidebar' | 'fullscreen'): DisplayConfig;
     getGenerationConfig(id: string): GenerationConfig;
   };
   ```

3. Update `ActivityItem` to read display config:
   ```typescript
   const displayConfig = componentConfigService.getDisplayConfig(item.type, 'sidebar');
   // Render based on config
   ```

**Effort:** Medium - configuration system

### Phase 4: Chat Integration
**Branch:** `feature/chat-components` (from Phase 3)

1. Create `ChatItemRenderer` component that reads unified config
2. Integrate with existing chat system to render ActivityItems
3. Add chat-specific display variants:
   - `TextCard`, `ImageCard`, `DocumentCard`, `MenuItemCard`
   - `FileUploadCard`, `OAuthConnectCard`, `ConfirmationCard`

4. Enable agent to insert components in chat:
   ```typescript
   chatService.addComponent({
     type: 'file-upload',
     props: { accepts: ['image/*'], maxSize: '50MB' }
   });
   ```

**Effort:** Large - chat system integration

### Phase 5: Restaurant Menu Integration
**Branch:** `feature/unified-menu` (from Phase 4)

1. Register `menu-item` in unified config
2. Create `MenuItemCard` component for chat
3. Create `SidebarMenuItem` component for sidebar
4. Create `MenuItemEditor` for fullscreen
5. Connect to existing MenuItemService

**Effort:** Medium - specific feature integration

---

## Git Branch Strategy

**UPDATED:** All unified content work merges INTO `allitemslist` branch, not develop.

```
develop
│
└── allitemslist (PR #149 - INTEGRATION BRANCH)
    │
    ├── feature/unified-types
    │   └── PR → allitemslist
    │
    ├── feature/action-components
    │   └── PR → allitemslist
    │
    ├── feature/unified-config
    │   └── PR → allitemslist
    │
    ├── feature/chat-components
    │   └── PR → allitemslist
    │
    └── feature/unified-menu
        └── PR → allitemslist
        │
        └── FINAL: allitemslist → develop (comprehensive PR)
```

**Benefits:**
- All unified UI work stays together
- One comprehensive review when merging to develop
- Easier to test complete feature set
- No partial states in develop

**Critical:** Keep `allitemslist` regularly rebased on develop to avoid drift.

---

## ClickUp Task Structure

### Epic: Unified Content System
**ID:** To be created
**Parent:** Brand Designer list

#### Task 1: Review and Merge PR #149
- **Status:** Busy (current)
- **Assignee:** Martien de Jong
- **Subtasks:**
  - [ ] Code review
  - [ ] Test with feature flag
  - [ ] Deploy to staging
  - [ ] Enable for beta users
  - [ ] Full rollout

#### Task 2: Extend Type System for Unified Components
- **Status:** Todo
- **Depends on:** Task 1
- **Subtasks:**
  - [ ] Add 'extracted' source type
  - [ ] Add displayConfig to ActivityItemBase
  - [ ] Add generationConfig to ActivityItemBase
  - [ ] Add menu-item type
  - [ ] Unit tests

#### Task 3: Action Components Framework
- **Status:** Todo
- **Depends on:** Task 2
- **Subtasks:**
  - [ ] Create ActionComponentRegistry
  - [ ] Implement FileUploadAction
  - [ ] Implement OAuthConnectAction
  - [ ] Implement ConfirmationAction
  - [ ] Extend PopupDetailModal
  - [ ] Unit tests

#### Task 4: Unified Configuration System
- **Status:** Todo
- **Depends on:** Task 3
- **Subtasks:**
  - [ ] Design unified-components.config.json schema
  - [ ] Create componentConfigService
  - [ ] Integrate with ActivityItem rendering
  - [ ] Migration from analysis-fields.config.json
  - [ ] Unit tests

#### Task 5: Chat Component Integration
- **Status:** Todo
- **Depends on:** Task 4
- **Subtasks:**
  - [ ] Create ChatItemRenderer
  - [ ] Implement content display cards (TextCard, ImageCard, etc.)
  - [ ] Implement action cards (FileUploadCard, etc.)
  - [ ] Agent integration for inserting components
  - [ ] Unit tests

#### Task 6: Restaurant Menu Unified Integration
- **Status:** Todo
- **Depends on:** Task 5
- **Subtasks:**
  - [ ] Register menu-item in unified config
  - [ ] Create MenuItemCard for chat
  - [ ] Create SidebarMenuItem
  - [ ] Create MenuItemEditor fullscreen
  - [ ] Integration with MenuItemService
  - [ ] Unit tests

---

## Risk Mitigation

### Risk 1: Breaking existing analysis-fields system
**Mitigation:**
- Phase 4 includes backwards compatibility layer
- analysis-fields.config.json continues to work
- Gradual migration component by component

### Risk 2: Chat system complexity
**Mitigation:**
- Phase 4 is isolated to chat
- Feature flags for gradual rollout
- Chat components are opt-in per component type

### Risk 3: Restaurant menu PR #148 conflicts
**Mitigation:**
- PR #148 should be merged before Phase 5
- Or: Coordinate changes so #148 becomes foundation for Phase 5
- PR #148 can be enhanced rather than replaced

### Risk 4: Performance with unified config loading
**Mitigation:**
- Config is static, loaded once at app startup
- Cache aggressively
- Lazy load component implementations

---

## Immediate Actions

### Today
1. [ ] Create ClickUp Epic "Unified Content System"
2. [ ] Create Task 1-6 in ClickUp with dependencies
3. [ ] Link PR #149 to Task 1
4. [ ] Prioritize: Merge PR #149 first

### This Week
1. [ ] Complete code review of PR #149
2. [ ] Test PR #149 with feature flag
3. [ ] Plan PR #148 (restaurant menu) coordination

### Next Week
1. [ ] Merge PR #149 after approval
2. [ ] Begin Phase 1: unified-types branch
3. [ ] Draft unified-components.schema.json (finalize from draft)

---

## File Reference

| File | Purpose |
|------|---------|
| `unified-components-schema-draft.json` | Draft schema for unified config |
| `expert-opinions-restaurant-menu.md` | 50-expert analysis on restaurant menu |
| `unified-content-system-analysis.md` | 50-expert analysis on unified system |
| This document | Integration plan |

---

## Success Criteria

The unified content system is complete when:
- [ ] All existing analysis-fields work through unified config
- [ ] Restaurant menu items render in chat, sidebar, fullscreen
- [ ] Action components (file upload, OAuth) work in chat
- [ ] Agent can dynamically insert any component type
- [ ] No regression in existing features
- [ ] Feature flags allow gradual rollout

---

**Document maintained by:** Claude Agent
**Last updated:** 2026-01-14
