# Artrevisionist Backup System

Automated nightly backup system for artrevisionist data with 5-day retention.

## 📁 What Gets Backed Up

**Source:** `C:\stores\artrevisionist`
**Backup Location:** `C:\backups\artrevisionist`
**Backup Size:** ~144 MB per backup

### Included (Critical Data):
- ✅ `data/` - User data, identity.db, prompt configs, .chats
- ✅ `projects/` - All project folders and configurations
- ✅ `config/` - Configuration files

### Excluded (Application Code & Logs):
- ❌ `backend/` - Application code (from git)
- ❌ `backend - Copy/` - Manual backup copies
- ❌ `www/` - Frontend code (from git)
- ❌ `logs/` - Log files
- ❌ `node_modules/`, `bin/`, `obj/` - Build artifacts

## 🚀 Production Server Setup

**Server:** `85.215.217.154`
**Schedule:** Daily at 3:30 AM (30 min after brand2boost)
**Retention:** 5 most recent backups

### Scheduled Task
```powershell
# Check task status
schtasks /query /TN "Artrevisionist Nightly Backup" /FO LIST

# Run manually
Start-ScheduledTask -TaskName "Artrevisionist Nightly Backup"
```

## 📝 Manual Backup Commands

### On Production Server (SSH)
```powershell
# Run backup
powershell -ExecutionPolicy Bypass -File "C:\scripts\tools\backup-artrevisionist.ps1"

# Dry run (no changes)
powershell -ExecutionPolicy Bypass -Command "& C:\scripts\tools\backup-artrevisionist.ps1 -DryRun"
```

### From Local Machine (Python SSH)
```python
import paramiko
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('85.215.217.154', username='administrator', password='3WsXcFr$7YhNmKi*')
stdin, stdout, stderr = client.exec_command('powershell -ExecutionPolicy Bypass -File "C:\\scripts\\tools\\backup-artrevisionist.ps1"')
print(stdout.read().decode())
client.close()
```

## 📂 Backup Structure

```
C:\backups\artrevisionist\
├── backup_2026-01-27_03-30-00\   (Most recent)
│   ├── data\
│   │   ├── identity.db
│   │   ├── users.json
│   │   ├── .chats\
│   │   └── *.prompts.json
│   ├── projects\
│   │   ├── Valsuani\
│   │   ├── Bugatti\
│   │   └── ...
│   └── config\
├── backup_2026-01-26_03-30-00\
├── backup_2026-01-25_03-30-00\
├── backup_2026-01-24_03-30-00\
├── backup_2026-01-23_03-30-00\   (Oldest - deleted when 6th created)
└── backup.log                      (Backup operation log)
```

## 🔧 Configuration

Edit `C:\scripts\tools\backup-artrevisionist.ps1` to customize:

```powershell
param(
    [string]$SourcePath = "C:\stores\artrevisionist",      # What to backup
    [string]$BackupRoot = "C:\backups\artrevisionist",     # Where to store
    [int]$MaxBackups = 5,                                   # Retention count
    [string[]]$IncludeDirs = @("data", "projects", "config") # Directories to include
)
```

## 📊 View Backup Log

```powershell
# On production server
Get-Content C:\backups\artrevisionist\backup.log -Tail 50
```

## ♻️ Restoring from Backup

### Full Restore
1. Stop the artrevisionist application
2. Copy backup folder contents to source:
```powershell
# Restore data directory
Copy-Item -Path "C:\backups\artrevisionist\backup_2026-01-27_03-30-00\data\*" `
          -Destination "C:\stores\artrevisionist\data" `
          -Recurse -Force

# Restore projects directory
Copy-Item -Path "C:\backups\artrevisionist\backup_2026-01-27_03-30-00\projects\*" `
          -Destination "C:\stores\artrevisionist\projects" `
          -Recurse -Force
```
3. Restart the application

### Restore Specific Files
```powershell
# Restore only the database
Copy-Item -Path "C:\backups\artrevisionist\backup_2026-01-27_03-30-00\data\identity.db*" `
          -Destination "C:\stores\artrevisionist\data"
```

## 🗑️ Uninstall

### Remove Scheduled Task
```powershell
Unregister-ScheduledTask -TaskName "Artrevisionist Nightly Backup" -Confirm:$false
```

### Delete Backups
```powershell
Remove-Item -Path "C:\backups\artrevisionist" -Recurse -Force
```

## ⚠️ Important Notes

1. **Backup Time:** Runs at 3:30 AM daily (staggered 30 min after brand2boost)
2. **Automatic Rotation:** Oldest backup deleted when 6th backup is created
3. **Database Integrity:** SQLite files are backed up with their -wal and -shm files
4. **Total Disk Space:** 5 backups ≈ 720 MB (144 MB × 5)

## 🆘 Troubleshooting

### Check if Task is Running
```powershell
Get-ScheduledTask -TaskName "Artrevisionist Nightly Backup"
```

### View Last Run Result
```powershell
Get-ScheduledTask -TaskName "Artrevisionist Nightly Backup" | Get-ScheduledTaskInfo
```

### Re-register Task
```powershell
powershell -ExecutionPolicy Bypass -File "C:\scripts\tools\register-artrevisionist-backup-task.ps1"
```

## 📅 Backup Schedule (Both Projects)

| Project | Time | Size | Schedule |
|---------|------|------|----------|
| Brand2Boost | 3:00 AM | ~611 MB | Daily |
| Artrevisionist | 3:30 AM | ~144 MB | Daily |

**Total Daily Backup:** ~755 MB
**Total Storage (5-day retention):** ~3.8 GB

---

**Created:** 2026-01-27
**Version:** 1.0
**Location:** Production Server `85.215.217.154`
