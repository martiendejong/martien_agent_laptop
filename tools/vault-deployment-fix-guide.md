# vault.prospergenics.com Deployment Fix Guide

## Issues Identified

### 1. SQLite Database Error (CRITICAL)
**Error:** `SQLite Error 14: 'unable to open database file'`

**Cause:**
- Connection string uses relative path: `Data Source=passwordmanager.db`
- IIS application pool identity doesn't have write permissions
- Database file doesn't exist and can't be created

**Solution:** See fix script below

### 2. SSL Certificate Warning
**Error:** Browser shows certificate warning/untrusted certificate

**Possible Causes:**
- Self-signed certificate
- Certificate not properly bound to IIS site
- Intermediate certificates missing
- Let's Encrypt certificate needs renewal

---

## Quick Fix (Run on Server)

### Option A: Run PowerShell Script (Recommended)

1. Copy `fix-vault-local.ps1` to the vault.prospergenics.com server
2. Open PowerShell as Administrator
3. Run:
   ```powershell
   cd C:\path\to\script
   .\fix-vault-local.ps1
   ```

### Option B: Manual Fix Steps

Run these commands on the server as Administrator:

```powershell
# 1. Create Data directory
New-Item -ItemType Directory -Force -Path "C:\inetpub\vault.prospergenics.com\Data"

# 2. Get app pool name
Import-Module WebAdministration
$appPool = (Get-Website -Name 'vault.prospergenics.com').applicationPool
Write-Host "App Pool: $appPool"

# 3. Grant permissions
$path = "C:\inetpub\vault.prospergenics.com\Data"
$acl = Get-Acl $path
$identity = "IIS AppPool\$appPool"
$permission = $identity, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl $path $acl

# 4. Update connection string
$configPath = "C:\inetpub\vault.prospergenics.com\appsettings.Production.json"
$json = Get-Content $configPath | ConvertFrom-Json
$json.ConnectionStrings.DefaultConnection = "Data Source=C:\inetpub\vault.prospergenics.com\Data\passwordmanager.db"
$json | ConvertTo-Json -Depth 10 | Set-Content $configPath

# 5. Restart app pool
Restart-WebAppPool -Name $appPool

# 6. Test
Start-Sleep -Seconds 5
Invoke-WebRequest -Uri "https://vault.prospergenics.com" -UseBasicParsing
```

---

## SSL Certificate Fix

### Check Current Certificate

```powershell
Import-Module WebAdministration

# Get binding information
$binding = Get-WebBinding -Name 'vault.prospergenics.com' -Protocol 'https'
$thumbprint = $binding.certificateHash

# Get certificate details
$cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $thumbprint }
$cert | Format-List Subject, Issuer, NotBefore, NotAfter
```

### Option 1: Install Let's Encrypt Certificate

Using **win-acme** (recommended):

```powershell
# Download win-acme
Invoke-WebRequest -Uri "https://github.com/win-acme/win-acme/releases/latest/download/win-acme.v2.x.x.xxx.x64.trimmed.zip" -OutFile "C:\temp\win-acme.zip"
Expand-Archive -Path "C:\temp\win-acme.zip" -DestinationPath "C:\win-acme"

# Run interactive setup
cd C:\win-acme
.\wacs.exe

# Follow prompts:
# 1. Choose "Create certificate (full options)"
# 2. Choose "Manual input"
# 3. Enter: vault.prospergenics.com
# 4. Choose "http-01" validation
# 5. Choose "IIS Central Certificate Store" or "IIS binding"
# 6. Complete setup
```

### Option 2: Upload Existing Certificate

If you have a certificate from another provider:

```powershell
# Import PFX certificate
$pfxPath = "C:\path\to\certificate.pfx"
$pfxPassword = ConvertTo-SecureString -String "YOUR_PASSWORD" -Force -AsPlainText
$cert = Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation Cert:\LocalMachine\My -Password $pfxPassword

# Bind to IIS site
New-WebBinding -Name "vault.prospergenics.com" -Protocol https -Port 443 -IPAddress "*" -HostHeader "vault.prospergenics.com" -SslFlags 1
$binding = Get-WebBinding -Name "vault.prospergenics.com" -Protocol https
$binding.AddSslCertificate($cert.Thumbprint, "My")
```

---

## Verification Steps

After applying fixes, verify:

### 1. Database Access
```powershell
# Check if database file was created
Test-Path "C:\inetpub\vault.prospergenics.com\Data\passwordmanager.db"

# Check file permissions
Get-Acl "C:\inetpub\vault.prospergenics.com\Data" | Format-List
```

### 2. Application Response
```powershell
# Test HTTP response
Invoke-WebRequest -Uri "https://vault.prospergenics.com" -UseBasicParsing

# Should NOT show SQLite error
```

### 3. SSL Certificate
```powershell
# Test from browser (should show green padlock)
# Or use:
$request = [System.Net.WebRequest]::Create("https://vault.prospergenics.com")
$response = $request.GetResponse()
$cert = $request.ServicePoint.Certificate
Write-Host "Issuer: $($cert.Issuer)"
Write-Host "Subject: $($cert.Subject)"
Write-Host "Valid Until: $($cert.GetExpirationDateString())"
```

### 4. API Endpoints
```powershell
# Test API health
Invoke-RestMethod -Uri "https://vault.prospergenics.com/api/health" -Method GET
```

---

## Common Issues

### Database Still Not Created
- **Check app pool identity:** Ensure it's ApplicationPoolIdentity (default)
- **Check permissions:** Run `icacls "C:\inetpub\vault.prospergenics.com\Data"` to verify
- **Check logs:** Look in Windows Event Viewer > Application logs

### Certificate Still Shows Warning
- **Check binding:** Ensure certificate is bound to correct site and port
- **Check intermediate certs:** Let's Encrypt needs intermediate certificates
- **Check hostname:** Certificate must match domain name exactly
- **Browser cache:** Clear browser cache and try in incognito mode

### Application Won't Start
```powershell
# Check app pool status
Get-WebAppPoolState -Name "vault.prospergenics.com"

# Check app pool logs
Get-EventLog -LogName Application -Source "ASP.NET Core*" -Newest 10

# Enable stdout logging in web.config
# Add to <aspNetCore> element:
#   stdoutLogEnabled="true"
#   stdoutLogFile=".\logs\stdout"
```

---

## Remote Access Options

If you need remote access to troubleshoot:

### Option 1: RDP (Remote Desktop)
- Requires: Windows credentials with admin rights
- Connect: `mstsc /v:vault.prospergenics.com`

### Option 2: PowerShell Remoting
```powershell
# Enable on server first:
Enable-PSRemoting -Force

# Connect from local machine:
Enter-PSSession -ComputerName vault.prospergenics.com -Credential (Get-Credential)
```

### Option 3: SSH (if enabled)
```bash
# Add SSH public key to server first:
# C:\ProgramData\ssh\administrators_authorized_keys

# Then connect:
ssh administrator@vault.prospergenics.com
```

---

## Contact Information

If you need assistance:
- **Server location:** vault.prospergenics.com
- **Local project:** E:\projects\passwordmanager
- **Config files:** E:\projects\passwordmanager\backend\PasswordManager.API\appsettings.Production.json

---

**Generated:** 2026-03-10
**Status:** Ready for deployment fix
