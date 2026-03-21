# Password Manager - Complete Deployment Runbook

**Last Updated:** 2026-03-11
**Project:** Password Manager (vault.prospergenics.com)
**Status:** Production

---

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Backend API Deployment](#backend-api-deployment)
4. [Frontend Deployment](#frontend-deployment)
5. [Extension Deployment](#extension-deployment)
6. [Verification Steps](#verification-steps)
7. [Rollback Procedures](#rollback-procedures)
8. [Troubleshooting](#troubleshooting)

---

## Overview

**Architecture:**
- **Backend API:** ASP.NET Core 8.0 + Entity Framework + SQLite
- **Frontend:** React + TypeScript + Vite + Tailwind CSS
- **Extension:** Chrome Manifest V3 browser extension
- **Server:** Windows Server with IIS 10.0
- **Deployment:** Python SSH automation (paramiko)

**Production URLs:**
- Frontend: https://vault.prospergenics.com
- API: https://vault.prospergenics.com/api
- Health: https://vault.prospergenics.com/api/health
- Extension: https://vault.prospergenics.com/extension/

**Server Details:**
- **IP:** 85.215.217.154
- **SSH Port:** 22
- **Credentials:** vault:windows-server-admin

---

## Prerequisites

### Local Environment
```bash
# Required software
- .NET SDK 8.0+
- Node.js 18+
- Python 3.12+
- Git

# Python packages
pip install paramiko

# Verify installations
dotnet --version    # Should be 8.0.x
node --version      # Should be 18.x+
python --version    # Should be 3.12+
```

### Remote Server Access
```bash
# Test SSH connection
ssh administrator@85.215.217.154

# Credentials stored in vault:windows-server-admin
# Format: administrator / [password from vault]
```

### Project Locations
```bash
# Local paths
Backend:   E:\projects\passwordmanager\backend\PasswordManager.API
Frontend:  E:\projects\passwordmanager\frontend
Extension: E:\projects\passwordmanager\extension

# Remote paths
Backend:   C:\inetpub\vault\backend
Frontend:  C:\inetpub\vault.prospergenics.com
Extension: C:\inetpub\vault.prospergenics.com\extension
```

---

## Backend API Deployment

### Step 1: Pre-Deployment Checks

```bash
# Navigate to backend
cd E:\projects\passwordmanager\backend\PasswordManager.API

# Check git status
git status

# Ensure on master branch
git checkout master
git pull origin master

# Verify no uncommitted changes
# (or commit/stash them first)
```

### Step 2: Local Build Test

```bash
# Clean previous builds
dotnet clean

# Restore packages
dotnet restore

# Build in Release mode
dotnet build -c Release

# Run tests (if any)
dotnet test
```

### Step 3: Deploy to Production

**Using deploy-dotnet-iis skill (RECOMMENDED):**
```bash
# Activate skill in Claude Code
/deploy-dotnet-iis passwordmanager

# Or use direct Python script:
python C:/scripts/tools/deploy-dotnet-to-iis.py \
    "E:\projects\passwordmanager\backend\PasswordManager.API" \
    "C:\inetpub\vault\backend" \
    "VaultPool"
```

**What the script does:**
1. Builds project locally with `dotnet publish -c Release`
2. Connects to server via SSH (paramiko)
3. Stops IIS app pool (VaultPool)
4. Uploads all files via SFTP (~130 files, ~10MB)
5. Starts IIS app pool
6. Restarts IIS

**Expected output:**
```
============================================================
  .NET to IIS Deployment
============================================================

Building Locally: E:\projects\passwordmanager\backend\PasswordManager.API
[OK] Build successful!

Connecting to 85.215.217.154
[OK] Connected!

Deploying to IIS
Stopping App Pool: VaultPool
Transferring Files via SFTP
Found 129 files to transfer
[OK] 84 files transferred

Starting App Pool: VaultPool
Restarting IIS

============================================================
  Deployment Complete!
============================================================
```

### Step 4: Verify Backend

```bash
# Health check
curl https://vault.prospergenics.com/api/health

# Expected response:
# {
#   "status": "healthy",
#   "timestamp": "2026-03-11T...",
#   "environment": "Production"
# }

# Test authentication endpoint
curl -X POST https://vault.prospergenics.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"invalid"}'

# Expected: HTTP 401 Unauthorized (correct behavior)
```

---

## Frontend Deployment

### Step 1: Build Frontend

```bash
# Navigate to frontend
cd E:\projects\passwordmanager\frontend

# Install dependencies (if needed)
npm install

# Build for production
npm run build

# Output: frontend/dist/ directory
```

### Step 2: Deploy Frontend Files

**Manual deployment (SFTP):**
```python
# Use Python SFTP script
python << 'EOF'
import paramiko

SERVER = "85.215.217.154"
USERNAME = "administrator"
PASSWORD = "[from vault:windows-server-admin]"
LOCAL = "E:/projects/passwordmanager/frontend/dist"
REMOTE = "C:/inetpub/vault.prospergenics.com"

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(SERVER, username=USERNAME, password=PASSWORD)
sftp = ssh.open_sftp()

# Upload files
import os
for file in ["index.html", "vite.svg"]:
    sftp.put(f"{LOCAL}/{file}", f"{REMOTE}/{file}")

# Upload assets directory
# (similar process for assets/*)

sftp.close()
ssh.close()
print("Frontend deployed!")
EOF
```

**Note:** Frontend is static files, no build/restart needed.

### Step 3: Verify Frontend

```bash
# Test frontend loads
curl -I https://vault.prospergenics.com

# Expected: HTTP 200 OK, Content-Type: text/html
```

---

## Extension Deployment

### Step 1: Build Extension

```bash
# Navigate to extension
cd E:\projects\passwordmanager\extension

# Install dependencies (if needed)
npm install

# Build for production
npm run build

# Output: extension/dist/ directory
# Files: background.js, content.js, popup.js, manifest.json, assets/
```

### Step 2: Create Zip Package

```bash
# Create zip from dist folder
cd E:\projects\passwordmanager\extension
zip -r password-manager-extension.zip dist/

# Expected: password-manager-extension.zip (~67 KB)
```

### Step 3: Deploy to Production

**Using Python deployment script:**
```bash
python C:/temp/deploy-extension.py
```

**Or manually via SFTP:**
```python
import paramiko

SERVER = "85.215.217.154"
USERNAME = "administrator"
PASSWORD = "[from vault:windows-server-admin]"
LOCAL = "E:/projects/passwordmanager/extension"
REMOTE = "C:/inetpub/vault.prospergenics.com/extension"

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(SERVER, username=USERNAME, password=PASSWORD)
sftp = ssh.open_sftp()

# Upload zip
sftp.put(f"{LOCAL}/password-manager-extension.zip",
         f"{REMOTE}/password-manager-extension.zip")

# Upload individual files from dist/
# (background.js, content.js, popup.js, manifest.json, assets/*)

sftp.close()
ssh.close()
print("Extension deployed!")
```

### Step 4: Verify Extension

```bash
# Check download page
curl -I https://vault.prospergenics.com/extension/

# Expected: HTTP 200 OK

# Check zip file
curl -I https://vault.prospergenics.com/extension/password-manager-extension.zip

# Expected: HTTP 200 OK, Content-Length: ~67005
```

---

## Verification Steps

### Complete System Check

```bash
# 1. Backend API
curl https://vault.prospergenics.com/api/health | python -m json.tool

# 2. Frontend
curl -I https://vault.prospergenics.com

# 3. Extension download
curl -I https://vault.prospergenics.com/extension/

# 4. Database connectivity (via SSH)
ssh administrator@85.215.217.154
dir C:\inetpub\vault\backend\passwordmanager.db
# Should show file size (e.g., 135 KB)
```

### End-to-End Testing

```bash
# 1. Register new user
curl -X POST https://vault.prospergenics.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "isGlobalAdmin": false
  }'

# Expected: HTTP 200 with JWT token

# 2. Login
curl -X POST https://vault.prospergenics.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!"
  }'

# Expected: HTTP 200 with JWT token

# 3. Get projects (requires auth)
curl -X GET https://vault.prospergenics.com/api/projects \
  -H "Authorization: Bearer [token]"

# Expected: HTTP 200 with projects array
```

---

## Rollback Procedures

### Backend Rollback

```bash
# Option 1: Redeploy previous version
git checkout [previous-commit-hash]
/deploy-dotnet-iis passwordmanager

# Option 2: SSH to server and restore backup
ssh administrator@85.215.217.154
cd C:\inetpub\vault\backend
# Copy files from backup directory
```

### Frontend Rollback

```bash
# Redeploy previous build
git checkout [previous-commit-hash]
cd frontend
npm run build
# Upload dist/ files via SFTP
```

### Extension Rollback

```bash
# Upload previous version zip
git checkout [previous-commit-hash]
cd extension
npm run build
zip -r password-manager-extension.zip dist/
# Upload via SFTP
```

---

## Troubleshooting

### Backend Issues

**Problem:** API returns 500 errors
```bash
# Check IIS app pool
ssh administrator@85.215.217.154
powershell -Command "Get-IISAppPool -Name VaultPool"

# Restart if needed
powershell -Command "Restart-WebAppPool -Name VaultPool"

# Check logs
dir C:\inetpub\vault\backend\logs\*.log
```

**Problem:** Database connection errors
```bash
# Verify database file exists
ssh administrator@85.215.217.154
dir C:\inetpub\vault\backend\passwordmanager.db

# Check file permissions
powershell -Command "Get-Acl C:\inetpub\vault\backend\passwordmanager.db"
```

### Frontend Issues

**Problem:** Page shows 404
```bash
# Check IIS site is running
ssh administrator@85.215.217.154
powershell -Command "Get-Website -Name 'vault.prospergenics.com'"

# Verify files exist
dir C:\inetpub\vault.prospergenics.com\index.html
```

### Extension Issues

**Problem:** Extension won't load
```bash
# Verify manifest.json is valid
cd E:\projects\passwordmanager\extension\dist
python -m json.tool manifest.json

# Common issues:
# - Invalid JSON syntax
# - Missing required permissions
# - Incorrect API URL in constants.ts
```

**Problem:** API calls fail from extension
```bash
# Check CORS settings in backend
# Program.cs should allow chrome-extension:// origins

# Verify API URL in extension
# extension/src/shared/constants.ts
# Should be: https://vault.prospergenics.com/api
```

---

## Configuration Files

### Backend: appsettings.Production.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=passwordmanager.db"
  },
  "JwtSettings": {
    "Key": "[CHANGE_THIS - vault:jwt-secret-key]",
    "Issuer": "PasswordManagerAPI",
    "Audience": "PasswordManagerClient"
  },
  "EncryptionSettings": {
    "Key": "[CHANGE_THIS - vault:encryption-key]"
  },
  "AppUrl": "https://vault.prospergenics.com"
}
```

### Backend: web.config

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <handlers>
      <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" />
    </handlers>
    <aspNetCore processPath="dotnet"
                arguments=".\PasswordManager.API.dll"
                stdoutLogEnabled="true"
                stdoutLogFile=".\logs\stdout"
                hostingModel="outofprocess">
      <environmentVariables>
        <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Production" />
      </environmentVariables>
    </aspNetCore>
  </system.webServer>
</configuration>
```

### Extension: manifest.json

```json
{
  "manifest_version": 3,
  "name": "Password Manager",
  "version": "1.0.0",
  "permissions": ["storage", "activeTab", "contextMenus", "alarms"],
  "host_permissions": [
    "https://vault.prospergenics.com/*",
    "<all_urls>"
  ],
  "background": {
    "service_worker": "background.js"
  },
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content.js"],
    "run_at": "document_end"
  }]
}
```

---

## Quick Reference Commands

```bash
# Full deployment (all components)
/deploy-dotnet-iis passwordmanager                    # Backend
cd frontend && npm run build                          # Frontend build
python C:/temp/deploy-extension.py                   # Extension

# Verification
curl https://vault.prospergenics.com/api/health       # Backend
curl -I https://vault.prospergenics.com               # Frontend
curl -I https://vault.prospergenics.com/extension/    # Extension

# Logs
ssh administrator@85.215.217.154
dir C:\inetpub\vault\backend\logs\*.log               # Backend logs
powershell -Command "Get-EventLog -LogName Application -Newest 50"  # IIS logs
```

---

## Security Notes

**Credentials:**
- All passwords stored in vault (not in this document)
- SSH credentials: `vault:windows-server-admin`
- JWT secret: `vault:jwt-secret-key`
- Encryption key: `vault:encryption-key`

**HTTPS:**
- All production URLs use HTTPS
- SSL certificate managed by IIS
- No HTTP access allowed

**Database:**
- SQLite database file permissions: IIS_IUSRS read/write
- Located at: `C:\inetpub\vault\backend\passwordmanager.db`
- Backup recommended before deployments

---

## Deployment Checklist

### Pre-Deployment
- [ ] Git status clean (or changes committed)
- [ ] Tests passing locally
- [ ] Version number updated (if applicable)
- [ ] Changelog updated
- [ ] Database backup created

### Deployment
- [ ] Backend deployed successfully
- [ ] Frontend built and deployed
- [ ] Extension built and deployed
- [ ] No errors in deployment logs

### Post-Deployment
- [ ] Health endpoint returns 200
- [ ] Frontend loads correctly
- [ ] Extension downloads successfully
- [ ] End-to-end test passes
- [ ] No errors in server logs
- [ ] Database accessible

### Rollback (if needed)
- [ ] Previous version identified
- [ ] Rollback procedure executed
- [ ] Verification completed
- [ ] Incident documented

---

**Document Maintained By:** Claude Sonnet 4.5
**Last Deployment:** 2026-03-11 16:50 UTC
**Next Review:** As needed
