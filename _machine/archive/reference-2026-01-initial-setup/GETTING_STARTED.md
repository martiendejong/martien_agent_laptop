# Getting Started in 5 Minutes 🚀

**Welcome!** Get Brand2Boost running locally in under 5 minutes.

---

## Prerequisites (2 minutes)

**Check you have:**
- ✅ [.NET 9.0 SDK](https://dotnet.microsoft.com/download) - `dotnet --version`
- ✅ [Node.js 18+](https://nodejs.org/) - `node --version`
- ✅ [Git](https://git-scm.com/) - `git --version`

**Don't have them?** Install from links above.

---

## Quick Start (3 minutes)

### 1. Clone & Setup (1 minute)

```bash
# Clone repository
cd C:\Projects
git clone https://github.com/martiendejong/client-manager.git
cd client-manager

# Install backend dependencies
cd ClientManagerAPI
dotnet restore

# Install frontend dependencies
cd ../ClientManagerFrontend
npm install
```

### 2. Configure Secrets (30 seconds)

```bash
# Backend: Copy example secrets
cd ../ClientManagerAPI
copy appsettings.example.json appsettings.Secrets.json

# Edit appsettings.Secrets.json and add your API keys:
# - OpenAI API key (get from https://platform.openai.com/api-keys)
# - Anthropic API key (optional, get from https://console.anthropic.com/)
```

**Minimum config:**
```json
{
  "ApiSettings": {
    "OpenApiKey": "sk-YOUR-OPENAI-KEY-HERE"
  }
}
```

### 3. Run Database Migrations (30 seconds)

```bash
cd ClientManagerAPI
dotnet ef database update
# Creates identity.db in C:\stores\brand2boost\
```

### 4. Start Backend (30 seconds)

```bash
# In ClientManagerAPI folder
dotnet run
# API runs at https://localhost:54501
```

**Keep this terminal open!**

### 5. Start Frontend (30 seconds)

**New terminal:**
```bash
cd C:\Projects\client-manager\ClientManagerFrontend
npm run dev
# Frontend runs at https://localhost:5173
```

**Keep this terminal open too!**

---

## ✅ You're Running!

**Open:** https://localhost:5173

**You should see:** Brand2Boost login page

**Test login:**
- Click "Sign in with Google" OR
- Register new account

---

## Next Steps

**Now that it's running:**

1. 📖 Read [DEVELOPER_ONBOARDING.md](./DEVELOPER_ONBOARDING.md) - Full developer guide
2. 🏗️ Read [CLIENT_MANAGER_DEEP_DIVE.md](./CLIENT_MANAGER_DEEP_DIVE.md) - Architecture deep dive
3. 🔧 Read [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md) - How to contribute code
4. 📊 View [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) - Understand data model
5. 🔌 Visit https://localhost:54501/swagger - API documentation

---

## Troubleshooting

### Backend won't start?

**Error: "Port 54501 already in use"**
```bash
# Kill process on port 54501
netstat -ano | findstr :54501
taskkill /PID <PID> /F
```

**Error: "OpenAI API key not found"**
- Check `appsettings.Secrets.json` exists
- Verify OpenApiKey is set correctly

**Error: "Database migration failed"**
```bash
# Drop database and try again
rm C:\stores\brand2boost\identity.db
dotnet ef database update
```

### Frontend won't start?

**Error: "npm ERR! code ENOENT"**
```bash
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

**Error: "HTTPS certificate error"**
```bash
# Regenerate dev certificate
npm run prepare-cert
```

**Error: "Cannot connect to API"**
- Make sure backend is running at https://localhost:54501
- Check CORS settings in `Program.cs`

### Still stuck?

1. Check [Troubleshooting Wiki](./TROUBLESHOOTING.md)
2. Ask in team Slack channel
3. Create GitHub issue with error details

---

## What Just Happened?

**You ran:**
1. **.NET 9.0 Web API** - Backend (46 controllers, PostgreSQL/SQLite)
2. **React 18 + Vite** - Frontend (TypeScript, Tailwind, Radix UI)
3. **SQLite Database** - Local development database
4. **Hazina AI Framework** - Multi-provider LLM abstraction (optional, for AI features)

**The stack:**
- Backend: ASP.NET Core + Entity Framework + SignalR + Hangfire
- Frontend: React + Zustand + TanStack Query + TipTap
- AI: OpenAI GPT-4 + DALL-E (via Hazina framework)
- Database: SQLite (dev) → PostgreSQL (production)

**Ports:**
- `5173` - Frontend (Vite dev server)
- `54501` - Backend API (HTTPS)
- `5000` - Backend API (HTTP, redirects to HTTPS)

---

## Pro Tips 💡

**Faster restarts:**
```bash
# Use dotnet watch for auto-reload
dotnet watch run  # Backend
npm run dev       # Frontend (already has HMR)
```

**Debug in Visual Studio:**
```bash
# Open solution file
start ClientManager.local.sln
# Press F5 to debug with breakpoints
```

**View logs:**
```bash
# Backend logs
tail -f ClientManagerAPI/log/brand2boost-*.log

# Frontend logs
# Check browser console (F12)
```

**Database GUI:**
```bash
# SQLite Browser (free)
# https://sqlitebrowser.org/
# Open C:\stores\brand2boost\identity.db
```

---

**Total Time:** 5 minutes ⏱️
**Difficulty:** Beginner ⭐
**Next:** [DEVELOPER_ONBOARDING.md](./DEVELOPER_ONBOARDING.md) for deep dive

**Questions?** Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) or ask the team!
