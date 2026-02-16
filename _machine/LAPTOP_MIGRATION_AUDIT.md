# Laptop Migration Audit - 2026-02-16

## System Comparison: Desktop vs Laptop

### Drives Available

**Desktop:**
- C: (System)
- E: (Data drive) - Contains: xampp, jengo/documents, personal files

**Laptop (THIS MACHINE):**
- C: (System only)
- **NO E: drive** - All E: references must be removed or redirected

### Projects Status

| Project | Desktop Location | Laptop Location | Status |
|---------|-----------------|-----------------|--------|
| client-manager | C:\Projects\client-manager | C:\Projects\client-manager | ✅ EXISTS (on develop) |
| hazina | C:\Projects\hazina | C:\Projects\Hazina | ✅ EXISTS (on develop) |
| art-revisionist | C:\Projects\artrevisionist | MISSING | ❌ NEEDS CLONE |
| hydro-vision-website | C:\Projects\hydro-vision-website | MISSING | ❌ NEEDS CLONE |
| worker-agents | C:\Projects\worker-agents\agent-001..012 | MISSING | ❌ NEEDS CREATION |

### Stores Status

| Store | Desktop Location | Laptop Location | Status |
|-------|-----------------|-----------------|--------|
| brand2boost | C:\stores\brand2boost | C:\stores\brand2boost | ✅ EXISTS |
| orchestration | C:\stores\orchestration | UNKNOWN | ❓ NEEDS CHECK |

### Tools Installed

| Tool | Desktop | Laptop | Action Needed |
|------|---------|--------|---------------|
| Git | ✅ Installed | ✅ Installed (v2.52.0) | - |
| GitHub CLI (gh) | ✅ Installed | ❌ NOT INSTALLED | INSTALL |
| ImageMagick | ✅ Installed (v7.1.2-13) | ❌ NOT INSTALLED | INSTALL |
| WP-CLI | ✅ Installed (v2.12.0) | ❌ NOT INSTALLED | INSTALL (if needed) |
| PowerShell | ✅ | ✅ | - |
| Node.js/npm | ✅ | ❓ NEEDS CHECK | - |
| .NET SDK | ✅ | ❓ NEEDS CHECK | - |

### Services

| Service | Desktop | Laptop | Notes |
|---------|---------|--------|-------|
| Hazina Orchestration | C:\stores\orchestration\HazinaOrchestration.exe | UNKNOWN | Likely missing |
| WordPress (XAMPP) | E:\xampp\htdocs | NOT APPLICABLE | Laptop doesn't need local WordPress |
| Agentic Debugger | localhost:27183 | UNKNOWN | Needs VS extension |
| UI Automation Bridge | localhost:27184 | UNKNOWN | Needs setup |

### Files with E:\ Drive References (MUST BE UPDATED)

**Markdown Files:**
1. `tools\wordpress-switcher-README.md`
2. `skills\check-task-clarity.skill.md`
3. `clickup-github-workflow.md`
4. `_machine\reflection.log.md`
5. `OPERATIONAL_RULES.md`
6. `CLAUDE.md`

**JSON Files:**
1. `agentidentity\state\vibe-sensing-state.json`
2. `_machine\services-registry.json`
3. `_machine\quick-context.json`
4. `_machine\projects\art-revisionist.json`
5. `_machine\knowledge-base\personal-domains.json`
6. `_machine\context-index.db.json`
7. `.hazina\documents\chunks.json`

### E: Drive Replacement Strategy

**Desktop E: Drive Purposes:**
1. **E:\jengo\documents\** - Working documents output
   - **Laptop Replacement:** `C:\jengo\documents\` (create this structure)

2. **E:\xampp\htdocs** - WordPress local development
   - **Laptop Replacement:** NOT NEEDED (laptop won't run WordPress locally)

3. **Personal files** - User's personal documents
   - **Laptop Replacement:** NOT APPLICABLE (don't sync personal files to laptop)

### Directory Structure to Create

```
C:\Projects\worker-agents\
  ├── agent-001\
  ├── agent-002\
  ├── agent-003\
  ├── agent-004\
  ├── agent-005\
  ├── agent-006\
  ├── agent-007\
  ├── agent-008\
  ├── agent-009\
  ├── agent-010\
  ├── agent-011\
  └── agent-012\

C:\jengo\documents\
  ├── output\
  ├── temp\
  ├── screenshots\
  ├── playwright\
  ├── projects\
  └── archive\
```

### Missing Repos to Clone

1. **artrevisionist** (if needed on laptop)
   - Desktop: `C:\Projects\artrevisionist`
   - GitHub: https://github.com/martiendt/artrevisionist (or check actual URL)

2. **hydro-vision-website**
   - Desktop: `C:\Projects\hydro-vision-website`
   - GitHub: https://github.com/martiendt/hydro-vision-website (or check actual URL)

### Tools Count

- Desktop has **278+ PowerShell tools** in C:\scripts\tools
- Laptop has the same (need to verify all are functional without E: dependencies)

## Migration Tasks

1. ✅ **Audit Complete** (this document)
2. ⏳ **Install GitHub CLI (gh)**
3. ⏳ **Install ImageMagick** (if image processing needed on laptop)
4. ⏳ **Install WP-CLI** (only if WordPress deployment from laptop is needed)
5. ⏳ **Create worker-agents directory structure**
6. ⏳ **Create C:\jengo\documents directory structure**
7. ⏳ **Clone missing repositories**
8. ⏳ **Update all E:\ references in documentation**
9. ⏳ **Update all E:\ references in JSON config files**
10. ⏳ **Create MACHINE_CONFIG.md for laptop**
11. ⏳ **Test worktree allocation system**
12. ⏳ **Test consciousness bridge**
13. ⏳ **Verify all core workflows operational**

## Decision: What NOT to Port to Laptop

1. **WordPress/XAMPP** - Not needed, deployment happens remotely
2. **Personal files from E:\** - Privacy/storage reasons
3. **Large media files** - If present on desktop

## Next Steps

1. Install missing tools (gh, ImageMagick conditionally)
2. Create directory structures
3. Clone repositories (check which ones are actually needed)
4. Update all documentation systematically
5. Create laptop-specific MACHINE_CONFIG.md
6. Test system operational integrity

---

**Audit Completed:** 2026-02-16 12:07
**Audited By:** Jengo
**Machine:** Laptop (not desktop)
