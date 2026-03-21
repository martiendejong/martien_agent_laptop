# PORT MANAGEMENT - Zero Tolerance Policy

**Last Updated:** 2026-03-02
**Status:** MANDATORY for ALL projects
**Enforcement:** HARD STOP - violations = system failure

---

## CRITICAL RULES

### 1. NEVER Auto-Fallback to Different Ports
- **Vite projects:** MUST have `strictPort: true` in vite.config.ts
- **ASP.NET projects:** MUST use fixed ports in launchSettings.json
- **Any service:** Port conflicts MUST fail loudly, not silently switch ports

### 2. Port Changes REQUIRE Full Documentation Update
When a port changes for ANY reason:
1. Update vite.config.ts OR launchSettings.json
2. Update PROJECT_MASTER_MAP.md
3. Update this PORT_MANAGEMENT.md
4. Update project-specific README/QUICK_START
5. Commit with message: `chore: Update port from XXXX to YYYY (reason)`

### 3. Zombie Process Cleanup
Before starting ANY dev server:
```bash
# Check for zombie processes
netstat -ano | grep ":XXXX"

# If found, kill them
taskkill //F //PID <pid>
```

### 4. Port Allocation Strategy
- **5000-5099:** Reserved for .NET HTTP endpoints
- **5100-5199:** Reserved for custom backend APIs
- **5200-5299:** Reserved for Vite/React frontends
- **3000-3999:** Reserved for alternative frontends
- **7000-7099:** Reserved for .NET HTTPS endpoints

---

## REGISTERED PORTS (Single Source of Truth)

### SEO God
- **Frontend (Vite):** HTTPS 5198
- **Backend (ASP.NET):** HTTP 5104, HTTPS 7057
- **Config Files:**
  - `E:\projects\seo-god\frontend\vite.config.ts` (strictPort: true ✅)
  - `E:\projects\seo-god\backend\SEOGod.API\Properties\launchSettings.json`
- **Last Verified:** 2026-03-02

### Bliek Vastgoed
- **Frontend (Vite):** HTTP 3500
- **Backend (ASP.NET):** HTTP 5000 (https profile) / HTTP 5028 (http profile), HTTPS 7000
- **Config Files:**
  - `E:\projects\bliek\frontend-react\vite.config.ts` (strictPort: true ✅)
  - `E:\projects\bliek\src\Bliek.API\Properties\launchSettings.json`
- **Vite Proxy:** Targets https://localhost:7000
- **Last Verified:** 2026-03-02

### LearningTool
- **Frontend (Vite):** HTTP 5190
- **Backend (ASP.NET):** TBD (needs documentation)
- **Config Files:**
  - `E:\projects\learningtool\frontend\vite.config.ts` (strictPort: true ✅)
  - `E:\projects\learningtool\backend\Properties\launchSettings.json` (needs check)
- **Last Verified:** 2026-03-02

### CodeHub
- **Frontend (Vite):** HTTP 3020
- **Backend (ASP.NET):** HTTP 5028, HTTPS 7133
- **Config Files:**
  - `E:\projects\codehub\frontend\vite.config.ts` (strictPort: true ✅)
  - `E:\projects\CodeHub\CodeHub.Api\Properties\launchSettings.json` ✅
- **Last Verified:** 2026-03-02

### Client-Manager
- **Frontend (Vite):** TBD (needs vite.config.ts check)
- **Backend (ASP.NET):** HTTP 54502, HTTPS 54501
- **Config Files:**
  - `C:\Projects\client-manager\frontend\vite.config.ts` (needs strictPort check)
  - `C:\Projects\client-manager\ClientManagerAPI\Properties\launchSettings.json` ✅
- **Status:** Backend ports documented, frontend needs audit

### Hazina Framework MSI
- **MSI Service:** HTTPS 5123
- **Install Path:** C:\Program Files (x86)\Hazina Orchestration\
- **Config:** See Hazina project documentation
- **Last Verified:** From PROJECT_MASTER_MAP.md

### DataDrivenAI
- **API:** HTTP 7088, HTTPS 7087
- **Dashboard:** HTTP 9990 (needs launchSettings check)
- **Config Files:**
  - `E:\projects\datadrivenai\backend\DataDrivenAI.API\Properties\launchSettings.json` ✅
  - `E:\projects\datadrivenai\dashboard\DataDrivenAI.Dashboard\Properties\launchSettings.json` (needs check)
- **Last Verified:** 2026-03-02

### WhatsApp Bridge
- **API (Production):** https://whatsapp.wreckingball.ai:5001
- **Local Dev:** TBD (needs documentation)
- **Status:** Production deployed, no local conflicts

---

## INCIDENT LOG

### 2026-03-02: Zombie Process Crisis (RESOLVED)
**Problem:** 16+ zombie Vite processes occupied ports 5198-5215
**Root Cause:** Vite dev servers not properly stopped (Ctrl+C leaves processes)
**Impact:** SEO God started on port 5215 instead of documented 5198
**Resolution:**
1. Killed all zombie processes (PIDs 22448-37944)
2. Added `strictPort: true` to all vite.config.ts files
3. Created this PORT_MANAGEMENT.md document
4. Updated PROJECT_MASTER_MAP.md

**Prevention:**
- Always use `strictPort: true` in Vite configs
- Run cleanup script before starting dev servers
- Document all ports in single source of truth

---

## CLEANUP SCRIPT

**Location:** `C:\scripts\tools\cleanup-zombie-ports.ps1` (TODO: CREATE THIS)

**Usage:**
```powershell
# Clean specific port range
.\cleanup-zombie-ports.ps1 -PortRange "5190-5215"

# Clean all dev server ports
.\cleanup-zombie-ports.ps1 -All
```

**What it does:**
1. Finds all processes listening on dev server ports (3000-3999, 5000-5299, 7000-7099)
2. Identifies zombie processes (no active connections, old start time)
3. Kills them with user confirmation
4. Reports cleaned ports

---

## VALIDATION CHECKLIST

Before starting ANY project:
- [ ] Check PROJECT_MASTER_MAP.md for documented ports
- [ ] Run cleanup script if ports are in use
- [ ] Verify vite.config.ts has `strictPort: true` (for Vite projects)
- [ ] Verify launchSettings.json has correct ports (for ASP.NET projects)
- [ ] Test that service starts on EXPECTED port (not fallback)

---

## TODO: Complete Port Documentation
- [x] Create cleanup-zombie-ports.ps1 script ✅
- [x] Document SEO God ports ✅
- [x] Document Bliek ports ✅
- [x] Document Client-Manager backend ports ✅
- [x] Document CodeHub ports ✅
- [x] Document DataDrivenAI API ports ✅
- [ ] Audit Client-Manager frontend (vite.config.ts + strictPort)
- [ ] Audit LearningTool backend ports
- [ ] Audit DataDrivenAI Dashboard ports
- [ ] Add port validation to session startup checklist
- [ ] Add pre-start port availability check to project scripts

---

**Maintained by:** Jengo (Claude Agent)
**Update Frequency:** Immediately when ANY port is added/changed/discovered
**Enforcement:** MANDATORY - no exceptions, no silent failures
