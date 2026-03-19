---
name: deploy-dotnet-iis-skill
description: Deploy .NET applications to IIS via SSH - reads config from PROJECT_MASTER_MAP.md or accepts manual arguments. Production-ready deployment automation with config-based setup, paramiko SSH, 6-step pipeline, and health checks.
allowed-tools: Read, Bash, Grep
user-invocable: true
---

# Deploy .NET to IIS - Production Deployment Automation

**Purpose:** Automated deployment of .NET applications to IIS servers via SSH with comprehensive health checks, rollback support, and zero-downtime deployments.

## When to Use This Skill

**Use when:**
- User says "deploy to IIS"
- User says "deploy [project-name]"
- User wants to push code to production server
- After merging PR to main/master branch

**Don't use when:**
- Deploying to non-IIS servers
- Local development deployments
- Deploying non-.NET applications

## Prerequisites

- Project configured in `C:\scripts\_machine\PROJECT_MASTER_MAP.md`
- SSH credentials available (from PROJECT_MASTER_MAP or vault)
- IIS server accessible via SSH
- .NET application built and ready to deploy

## ZERO TOLERANCE: SSH Rule

**NEVER use bash `ssh` or `scp` on Windows** - Causes security popups (Windows Defender, UAC).
**ALWAYS use paramiko** in Python for SSH operations.

```python
import paramiko

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(host, username=user, password=password)
```

## 6-Step Deployment Pipeline

### Step 1: Read Configuration from PROJECT_MASTER_MAP.md

```python
# Example PROJECT_MASTER_MAP.md entry:
"""
### Password Manager (Vault)
- **Server:** 85.215.217.154 (SSH: administrator / <password>)
- **API Path:** `C:\inetpub\vault\backend`
- **App Pool:** VaultPool
- **Production URL:** https://vault.prospergenics.com
- **Deploy Command:** `python C:\scripts\tools\deploy-dotnet-to-iis.py passwordmanager`
"""
```

### Step 2: Pre-Flight Checks

```python
# 1. SSH connection test
# 2. Verify remote paths exist
# 3. Verify app pool exists
# 4. Check local build exists
```

### Step 3: Backup Current Version

```python
backup_timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
backup_path = f"{config['remote_backend_path']}_backup_{backup_timestamp}"
# Copy current → backup via SSH
```

### Step 4: Upload New Build (Paramiko SFTP)

```python
sftp = ssh.open_sftp()

def upload_directory(sftp, local_path, remote_path):
    """Recursively upload directory via SFTP"""
    # Create remote dir, upload all files recursively

upload_directory(sftp, local_build_path, remote_path)
sftp.close()
```

### Step 5: Restart IIS App Pool

```python
# Stop app pool → wait for Stopped state
# Upload new files
# Start app pool → wait for Started state (max 60s)
```

### Step 6: Health Check

```python
# Wait 30s for warmup
# HTTP GET to /health endpoint
# Verify 200 response
# Print deployment summary
```

## Usage

```bash
# By project name (reads from PROJECT_MASTER_MAP.md)
python C:\scripts\tools\deploy-dotnet-to-iis.py passwordmanager
python C:\scripts\tools\deploy-dotnet-to-iis.py client-manager
```

## Rollback

```bash
# If deployment failed
python C:\scripts\tools\deploy-dotnet-to-iis.py passwordmanager --rollback
```

Rollback finds latest `_backup_YYYYMMDD_HHMMSS` folder and restores it.

## Common Issues

### "SSH connection refused"
- Verify server IP in PROJECT_MASTER_MAP.md
- Check VPN connection if required

### "App pool failed to start"
- Check Event Viewer: `Get-EventLog -LogName Application -Newest 10`
- Check appsettings.json configuration
- Rollback to previous backup

### "Permission denied during upload"
```powershell
icacls "C:\inetpub\vault\backend" /grant "IIS_IUSRS:(OI)(CI)F" /T
```

## PROJECT_MASTER_MAP.md Format

```markdown
### Project Name
- **Local Path:** `<local build output path>`
- **Deployment:**
  - **Server:** <IP or hostname>
  - **SSH:** <username / password> OR vault:ssh-<project>
  - **API Path:** `<remote IIS path for backend>`
  - **Frontend Path:** `<remote IIS path for frontend>` (optional)
  - **App Pool:** <IIS app pool name>
  - **Production URL:** <https://production.url>
  - **Deploy Method:** Python SSH (deploy-dotnet-to-iis.py)
  - **Deploy Command:** `python C:\scripts\tools\deploy-dotnet-to-iis.py <project-name>`
```

## Zero Tolerance Rules

1. **NEVER use bash `ssh` or `scp` on Windows** - security popups
2. **ALWAYS use paramiko** in Python for SSH operations
3. **NO interactive prompts** - all automation must be non-interactive
4. **Backup BEFORE deploy** - always create timestamped backup
5. **Health check AFTER deploy** - verify deployment success

---

**Created:** 2026-03-11
**Status:** PRODUCTION READY
**Script:** `C:\scripts\tools\deploy-dotnet-to-iis.py`
