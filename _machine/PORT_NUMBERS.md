# PROJECT PORT NUMBERS - REFERENCE

**CRITICAL:** Each application MUST have unique port numbers. NEVER assume or change these without checking this file first.

**Last Updated:** 2026-03-01 14:00

---

## ACTIVE PROJECTS

### SEO God
- **Backend API:** HTTP 5104, HTTPS 7057
- **Frontend:** HTTPS 5198
- **Config:** `E:\projects\seo-god\backend\SEOGod.API\Properties\launchSettings.json`
- **Config:** `E:\projects\seo-god\frontend\vite.config.ts`

### Client-Manager (Brand2Boost)
- **Backend API:** TBD (check launchSettings.json)
- **Frontend:** TBD (check vite.config.ts)
- **Path:** `C:\Projects\client-manager`

### Bliek Vastgoed
- **Backend API:** HTTP 5000, HTTPS 7000
- **Frontend:** HTTP 3500, HTTPS 3501
- **Path:** `E:\projects\bliek`

### Hazina Orchestration
- **MSI Installed Service:** HTTPS 5123
- **Path:** `C:\Program Files (x86)\Hazina Orchestration\`

### LearningTool
- **Backend API:** TBD (check launchSettings.json)
- **Frontend:** TBD (check vite.config.ts)
- **Path:** `E:\projects\learningtool`

### CodeHub
- **Backend API:** TBD (check launchSettings.json)
- **Frontend:** TBD (check vite.config.ts)
- **Path:** `E:\projects\CodeHub`

### Art Revisionist
- **WordPress (XAMPP):** HTTP 80, HTTPS 443
- **React Frontend:** TBD (check vite.config.ts)
- **Path:** `E:\xampp\htdocs\art-revisionist`

---

## SYSTEM SERVICES

### DataDrivenAI
- **API:** HTTPS 7087, HTTP 7088
- **Dashboard:** HTTP 9990
- **Path:** TBD

### WhatsApp Bridge
- **External API:** HTTPS 5001 (whatsapp.wreckingball.ai)

### XAMPP
- **Apache:** HTTP 80, HTTPS 443
- **MySQL:** 3306
- **Path:** `E:\xampp\`

---

## DEFAULT PORTS (DO NOT USE THESE)

### Vite Default
- **Default:** 5173 ⚠️ DO NOT ASSUME - ALWAYS CHECK vite.config.ts

### ASP.NET Default  
- **Default:** Varies ⚠️ DO NOT ASSUME - ALWAYS CHECK launchSettings.json

---

## RULES

1. **NEVER assume default ports** - Always check the actual config files
2. **NEVER change ports without documenting** - Update this file AND PROJECT_MASTER_MAP.md
3. **CHECK CONFLICTS** - Before assigning new ports, check this file for conflicts
4. **Vite ports** are in `vite.config.ts` (server.port)
5. **ASP.NET ports** are in `Properties/launchSettings.json` (applicationUrl)

---

## HOW TO CHECK PORTS

### Backend (ASP.NET)
```bash
cat <project>/backend/<ProjectName>.API/Properties/launchSettings.json | grep applicationUrl
```

### Frontend (Vite)
```bash
cat <project>/frontend/vite.config.ts | grep port
```

### Running Processes
```bash
netstat -ano | findstr LISTENING
```

