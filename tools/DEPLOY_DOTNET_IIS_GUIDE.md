# Deploy .NET to IIS - Quick Reference

**Script:** `C:\scripts\tools\deploy-dotnet-to-iis.py`
**Skill:** `C:\scripts\skills\deploy-dotnet-iis.skill.md`
**Config:** `C:\scripts\_machine\PROJECT_MASTER_MAP.md`

## Quick Start

### Config-Based Deployment (Recommended)

```bash
# Deploy using PROJECT_MASTER_MAP.md configuration
python C:\scripts\tools\deploy-dotnet-to-iis.py client-manager
python C:\scripts\tools\deploy-dotnet-to-iis.py email-bridge
python C:\scripts\tools\deploy-dotnet-to-iis.py whatsapp-bridge
```

### Manual Deployment

```bash
# Full control with manual parameters
python C:\scripts\tools\deploy-dotnet-to-iis.py \
    "C:\Projects\client-manager\ClientManagerAPI" \
    "C:\stores\brand2boost\backend" \
    "Brand2boost"
```

## What It Does

1. ✅ **Builds** your .NET app locally (`dotnet publish -c Release`)
2. ✅ **Stops** IIS app pool
3. ✅ **Transfers** files via SFTP (paramiko - no security popups!)
4. ✅ **Starts** app pool + restarts IIS
5. ✅ **Tests** health endpoint to verify deployment

## Prerequisites

- Python 3.x installed
- `paramiko` library: `pip install paramiko`
- .NET SDK installed for building
- SSH access to server (85.215.217.154)
- IIS app pool already created on server

## Supported Projects

From PROJECT_MASTER_MAP.md:

- **client-manager** → Brand2Boost API (https://api.brand2boost.com)
- **email-bridge** → Email Bridge API (https://mailbridge.wreckingball.ai)
- **whatsapp-bridge** → WhatsApp Bridge API (https://whatsapp.wreckingball.ai:5001)

## Adding New Projects

1. **Update PROJECT_MASTER_MAP.md:**

```markdown
### My Project Name
- **Local Path:** `C:\Projects\my-project`
- **Deployment:**
  - **Server:** 85.215.217.154 (SSH: administrator / SpaceElevator1tam!)
  - **API Path:** `C:\inetpub\myproject`
  - **App Pool:** MyProjectPool
  - **Production URL:** https://api.myproject.com
  - **Deploy Method:** Python SSH (deploy-dotnet-to-iis.py)
```

2. **Create IIS app pool** (one-time, on server):

```powershell
Import-Module WebAdministration
New-WebAppPool -Name "MyProjectPool"
```

3. **Deploy:**

```bash
python C:\scripts\tools\deploy-dotnet-to-iis.py my-project
```

## Troubleshooting

**Build fails:**
```bash
# Test build manually
cd C:\Projects\your-project
dotnet build
dotnet publish -c Release -o C:\temp\test-publish
```

**Connection refused:**
- Check firewall allows SSH (port 22)
- Verify credentials in PROJECT_MASTER_MAP.md
- Test manual SSH: `ssh administrator@85.215.217.154`

**App pool not found:**
- Connect to server via RDP
- Open IIS Manager
- Create app pool with exact name from config

**Health check fails:**
- Check IIS bindings (HTTPS certificate)
- Check Windows Event Viewer for .NET errors
- Manually browse to production URL

## Windows SSH Rule Compliance

This script follows **ZERO TOLERANCE Windows SSH Rule**:

- ❌ **NEVER** uses bash `ssh` or `scp` (causes popups)
- ✅ **ALWAYS** uses `paramiko` library (silent, secure)

## Example Output

```
============================================================
  CONFIG-BASED DEPLOYMENT
============================================================
Project: client-manager

Project: Client-Manager (Brand2Boost / Brand Designer)
Source: C:\Projects\client-manager
Target: C:\stores\brand2boost\backend
App Pool: Brand2boost
Server: 85.215.217.154
============================================================
  .NET to IIS Deployment
============================================================

============================================================
  Building Locally: C:\Projects\client-manager\ClientManagerAPI
============================================================
[OK] Build successful! Output: C:\temp\dotnet-publish

============================================================
  Connecting to 85.215.217.154
============================================================
[OK] Connected!

============================================================
  Deploying to IIS
============================================================
[OK] 147 files transferred

============================================================
  Deployment Complete!
============================================================

Testing https://api.brand2boost.com in 5 seconds...
[OK] API is ONLINE! (Status: 200)
```

## Integration Examples

**After merging PR:**
```bash
gh pr merge 123 --squash
python C:\scripts\tools\deploy-dotnet-to-iis.py client-manager
```

**As part of release workflow:**
```bash
# Create PR
gh pr create --title "Feature XYZ" --body "..."

# After review + merge
python C:\scripts\tools\deploy-dotnet-to-iis.py client-manager
```

## Security

- SSH credentials in PROJECT_MASTER_MAP.md (git-ignored)
- Never commit credentials to public repos
- Rotate passwords regularly
- Consider moving to vault system for production

---

**Created:** 2026-03-11
**Last Updated:** 2026-03-11
**Status:** Production Ready ✅
