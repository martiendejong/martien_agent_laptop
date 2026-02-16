# Developer Onboarding Checklist ✅

**Welcome to the Brand2Boost development team!**

Use this checklist to get fully productive in your first week.

---

## Day 1: Setup & Access (4 hours)

### Development Environment

**Tools to Install:**
- [ ] **.NET 9.0 SDK** - https://dotnet.microsoft.com/download
- [ ] **Visual Studio 2022** (or VS Code + C# extension)
- [ ] **Node.js 18+** - https://nodejs.org/
- [ ] **Git** - https://git-scm.com/
- [ ] **GitHub Desktop** (optional) - https://desktop.github.com/
- [ ] **Database GUI** - [DB Browser for SQLite](https://sqlitebrowser.org/)
- [ ] **Postman** (or Insomnia) - API testing
- [ ] **Docker Desktop** (optional, for PostgreSQL)

**VS Code Extensions (if using VS Code):**
- [ ] C# (Microsoft)
- [ ] ESLint
- [ ] Prettier
- [ ] GitLens
- [ ] Tailwind CSS IntelliSense
- [ ] REST Client

### Accounts & Access

**Request access to:**
- [ ] **GitHub** - github.com/martiendejong/client-manager
  - Request collaborator access from team lead
- [ ] **Azure DevOps / Azure Portal** (if applicable)
- [ ] **Slack / Teams** - Team communication
- [ ] **OpenAI** - Get API key for development (ask team lead)
- [ ] **Anthropic** (optional) - Claude API key
- [ ] **Stripe** - Test account access (for payment testing)
- [ ] **Google Cloud** (optional) - OAuth credentials

### Clone Repository

**Quick start:**
```bash
cd C:\Projects
git clone https://github.com/martiendejong/client-manager.git
cd client-manager
```

**Read first:**
- [ ] [GETTING_STARTED.md](./GETTING_STARTED.md) - 5-minute quick start
- [ ] [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md) - Git workflow
- [ ] Run the app locally (follow GETTING_STARTED.md)

---

## Day 2: Codebase Orientation (4 hours)

### Read Documentation

**Core docs (in order):**
1. [ ] [PROJECTS_INDEX.md](./PROJECTS_INDEX.md) - Overview of all projects
2. [ ] [CLIENT_MANAGER_DEEP_DIVE.md](./CLIENT_MANAGER_DEEP_DIVE.md) - Architecture & features
3. [ ] [HAZINA_DEEP_DIVE.md](./HAZINA_DEEP_DIVE.md) - AI framework
4. [ ] [TECH_STACK_REFERENCE.md](./TECH_STACK_REFERENCE.md) - Technologies used
5. [ ] [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) - Data model
6. [ ] [SCRIPTS_INDEX.md](./SCRIPTS_INDEX.md) - Control plane & tools

**Skim through:**
- [ ] [STORES_INDEX.md](./STORES_INDEX.md) - Data stores
- [ ] README.md in client-manager repo

### Explore Codebase

**Backend (C#):**
```bash
cd ClientManagerAPI
# Open in Visual Studio
start ClientManager.local.sln
```

**Key files to find:**
- [ ] `Program.cs` - Application entry point
- [ ] `Controllers/AuthController.cs` - Authentication
- [ ] `Controllers/ChatController.cs` - AI chat
- [ ] `Services/TokenService.cs` - Token management
- [ ] `Models/*.cs` - Data entities

**Frontend (React):**
```bash
cd ClientManagerFrontend/src
```

**Key files to find:**
- [ ] `App.tsx` - Root component
- [ ] `main.tsx` - Entry point
- [ ] `components/auth/` - Auth components
- [ ] `components/chat/` - Chat interface
- [ ] `stores/authStore.ts` - Auth state (Zustand)
- [ ] `services/api.ts` - API client

### Run Tests

```bash
# Backend tests
cd ClientManager.Tests
dotnet test

# Frontend tests
cd ClientManagerFrontend
npm run test
```

**Expected:** Most tests should pass. Note any failures.

---

## Day 3: Development Workflow (4 hours)

### Worktree Setup (AI Agents) OR Standard Git Workflow

**If you're an AI agent:** Read worktrees.protocol.md
**If you're a human:** Use standard git workflow (see BRANCHING_STRATEGY.md)

### Make Your First Change (Baby Steps)

**Easy first task:** Add your name to CONTRIBUTORS.md

```bash
# Create feature branch
git checkout develop
git pull origin develop
git checkout -b feature-add-contributor-<yourname>

# Edit file
echo "- Your Name (@github-username)" >> CONTRIBUTORS.md

# Commit
git add CONTRIBUTORS.md
git commit -m "docs: add contributor"

# Push and create PR
git push origin feature-add-contributor-<yourname>
gh pr create --base develop --title "Add contributor" --body "Adding myself to contributors list"
```

**Ask for review** from team lead.

### Debug Configuration

**Backend:**
- [ ] Copy `appsettings.example.json` → `appsettings.Secrets.json`
- [ ] Add your OpenAI API key
- [ ] Add other secrets (ask team for test credentials)

**Frontend:**
- [ ] Create `.env.local` if needed
- [ ] Add any environment variables

### Run Full Stack

**Terminal 1:**
```bash
cd ClientManagerAPI
dotnet watch run
# API at https://localhost:54501
```

**Terminal 2:**
```bash
cd ClientManagerFrontend
npm run dev
# Frontend at https://localhost:5173
```

**Test:**
- [ ] Open https://localhost:5173
- [ ] Sign up for new account
- [ ] Try chat feature
- [ ] Generate some content
- [ ] Check API logs

---

## Day 4: Deep Dive Into Feature Area (4 hours)

**Choose one area to specialize in initially:**

### Option A: Authentication & User Management
- [ ] Read Auth flow documentation
- [ ] Study `AuthController.cs`
- [ ] Study `authStore.ts` (frontend)
- [ ] Understand JWT token generation/validation
- [ ] Test OAuth flow

### Option B: AI & Chat Features
- [ ] Read Hazina framework docs
- [ ] Study `ChatController.cs`
- [ ] Study `ChatWindow.tsx` (frontend)
- [ ] Understand prompt management
- [ ] Test different AI models

### Option C: Content Management
- [ ] Study `ContentController.cs`
- [ ] Study `ContentEditor.tsx`
- [ ] Understand TipTap editor integration
- [ ] Test content creation flow

### Option D: Subscriptions & Billing
- [ ] Study `SubscriptionController.cs`
- [ ] Study `TokenService.cs`
- [ ] Understand Stripe integration
- [ ] Test token purchase flow

**Deliverable:** Document what you learned in a short markdown file

---

## Day 5: First Real Task (4 hours)

### Pick a Starter Issue

**Good first issues:**
- [ ] Browse GitHub issues labeled `good-first-issue`
- [ ] Ask team lead for a beginner-friendly task
- [ ] Look for small bugs or documentation improvements

### Complete the Task

1. [ ] Create feature branch
2. [ ] Write code
3. [ ] Write/update tests
4. [ ] Update documentation (if needed)
5. [ ] Self-review code
6. [ ] Create PR
7. [ ] Address review comments
8. [ ] Merge!

### Code Review

**Before creating PR:**
- [ ] Run `dotnet format` (backend)
- [ ] Run `npm run lint` (frontend)
- [ ] Run all tests
- [ ] Test manually in browser
- [ ] Review your own diff on GitHub

**PR checklist:**
- [ ] Clear title and description
- [ ] Tests included
- [ ] Documentation updated
- [ ] No console errors
- [ ] No merge conflicts

---

## Week 2: Become Productive

### Learn the Tools

**C# Auto-Fix:**
```bash
# Format C# code
pwsh C:\scripts\tools\cs-format.ps1 --project .

# Auto-fix compile errors
dotnet C:\scripts\tools\cs-autofix\bin\Release\net9.0\cs-autofix.dll --project .
```

**Debugging:**
- [ ] Set breakpoints in Visual Studio
- [ ] Step through code
- [ ] Inspect variables
- [ ] Use watch window

**Browser DevTools:**
- [ ] Network tab (inspect API calls)
- [ ] Console (check for errors)
- [ ] React DevTools (inspect component state)
- [ ] Performance profiler

### Database

**View database:**
```bash
# Open SQLite database
# C:\stores\brand2boost\identity.db
# Use DB Browser for SQLite
```

**Run migrations:**
```bash
cd ClientManagerAPI
dotnet ef migrations add MigrationName
dotnet ef database update
```

**View data:**
```sql
SELECT * FROM AspNetUsers;
SELECT * FROM Subscriptions;
SELECT * FROM TokenBalances;
```

### API Testing

**Swagger UI:**
- [ ] Visit https://localhost:54501/swagger
- [ ] Try API endpoints
- [ ] Copy curl commands
- [ ] Test authentication flow

**Postman:**
- [ ] Import API endpoints
- [ ] Create environment (dev, staging, prod)
- [ ] Test protected endpoints (with JWT)

---

## Ongoing: Best Practices

### Daily Workflow

**Every morning:**
1. [ ] Pull latest `develop`
2. [ ] Check Slack for updates
3. [ ] Review assigned PRs
4. [ ] Plan your tasks

**Before committing:**
1. [ ] Run tests
2. [ ] Format code
3. [ ] Review diff
4. [ ] Write clear commit message

**Before going home:**
1. [ ] Push your work (even if WIP)
2. [ ] Update task status
3. [ ] Leave notes for tomorrow

### Code Quality

**Follow conventions:**
- [ ] C# - PascalCase for public members
- [ ] TypeScript - camelCase for variables/functions
- [ ] File naming - PascalCase.tsx for components
- [ ] Folder structure - feature-based organization

**Write tests:**
- [ ] Unit tests for business logic
- [ ] Integration tests for API endpoints
- [ ] Component tests for React components
- [ ] E2E tests for critical user flows

### Security

**Never commit:**
- ❌ API keys
- ❌ Passwords
- ❌ Connection strings
- ❌ Private keys
- ❌ .env files with secrets

**Always:**
- ✅ Use appsettings.Secrets.json (gitignored)
- ✅ Use environment variables
- ✅ Use Azure Key Vault (production)
- ✅ Validate user input
- ✅ Use parameterized queries (EF does this)

---

## Resources

### Documentation

**Project docs:**
- `C:\scripts\_machine\*.md` - All documentation
- GitHub Wiki (if exists)
- Inline code comments

**External:**
- [.NET docs](https://docs.microsoft.com/dotnet/)
- [React docs](https://react.dev/)
- [Tailwind docs](https://tailwindcss.com/)
- [Entity Framework docs](https://docs.microsoft.com/ef/)

### Team Contacts

**Ask questions:**
- **Team Lead:** [Name] - Architecture, planning
- **Backend Lead:** [Name] - C# questions
- **Frontend Lead:** [Name] - React questions
- **DevOps:** [Name] - Deployment, CI/CD
- **Everyone:** Slack #dev-general

**Pair programming:**
- Schedule 1-hour sessions with senior devs
- Share screen and code together
- Great way to learn!

---

## Checklist Summary

### Week 1 Complete When:
- ✅ Dev environment set up
- ✅ Repository cloned and running
- ✅ All core documentation read
- ✅ Codebase explored
- ✅ First PR merged
- ✅ You know who to ask for help

### Week 2 Complete When:
- ✅ Comfortable with git workflow
- ✅ Can debug backend and frontend
- ✅ Know how to run tests
- ✅ Completed 2-3 real tasks
- ✅ Reviewed other PRs
- ✅ Contributing regularly

### Month 1 Complete When:
- ✅ Deep expertise in 1-2 areas
- ✅ Can work independently
- ✅ Mentoring newer developers
- ✅ Proposing improvements
- ✅ Productive team member

---

## Common Questions

**Q: Where do I start?**
A: Follow this checklist top-to-bottom. Start with Day 1.

**Q: I'm stuck on something. Who do I ask?**
A: Slack #dev-general first. Tag @teamlead if urgent.

**Q: How long should onboarding take?**
A: ~1 week to be productive, ~1 month to be fully ramped up.

**Q: Can I work on any issue?**
A: Check with team lead first. Some issues may be assigned.

**Q: Do I need to know React/C#/.NET?**
A: Basic knowledge helps. You'll learn on the job.

**Q: What if I break something?**
A: Don't worry! That's what dev environment is for. Ask for help.

**Q: How often should I push code?**
A: Daily. Even work-in-progress. Use draft PRs.

---

**Welcome to the team! 🎉**

**Need help?** Ask in Slack #dev-onboarding

**Questions about this guide?** Update it and create PR!

---

**Last Updated:** 2026-01-08
**Maintained by:** Development Team
**Feedback:** Create issue or PR to improve this guide
