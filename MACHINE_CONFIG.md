# Machine Configuration - Laptop

**Machine Type:** Laptop (Portable Development Environment)  
**Updated:** 2026-02-16  
**Compared To:** Desktop (Primary Development Machine)

---

## System Specifications

- **OS:** Microsoft Windows 11 Pro
- **Build:** 10.0.26200
- **Architecture:** x64-based PC
- **RAM:** 15.7 GB

---

## Drives Configuration

### Available Drives
- **C:\** - System + Development + Data (all-in-one)

### Missing Drives (vs Desktop)
- **E:\** - NOT AVAILABLE (desktop has separate data drive)
  - Desktop E:\xampp\htdocs → Laptop: NOT AVAILABLE
  - Desktop E:\jengo\documents → Laptop: C:\jengo\documents

---

## Directory Structure

```
C:\
├── scripts\          # Jengo control plane
├── Projects\         # Development repos + worker-agents pool
├── stores\           # Config/data stores
└── jengo\            # Working documents (NEW for laptop)
    └── documents\
        ├── output/
        ├── temp/
        ├── screenshots/
        ├── playwright/
        ├── projects/
        └── archive/
```

---

## Key Differences vs Desktop

**Missing on Laptop:**
- E: drive (all paths updated to C:)
- Local WordPress/XAMPP (remote deployment only)
- Personal files (desktop-only)

**Laptop-Specific:**
- Working documents: C:\jengo\documents\
- WordPress: Remote operations only (REST API / SSH / FTP)
- Portable configuration (single drive)

---

**Last Updated:** 2026-02-16  
**Migration Complete:** ✅ Laptop ready for development
