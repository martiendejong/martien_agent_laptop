# Data Stores Index & Documentation

**Location:** `C:\stores\`
**Purpose:** Configuration and Data Storage Separated from Code
**Status:** ✅ Active
**Generated:** 2026-01-08

---

## OVERVIEW

### What are Data Stores?

**Data stores** are configuration and data directories that are **separate from code repositories**. This separation allows:

- **Configuration flexibility** - Change settings without code changes
- **Data persistence** - User data persists across code deployments
- **Multi-environment** - Dev, staging, prod configs in separate stores
- **Git tracking** - Stores can be versioned independently
- **Security** - Sensitive data (DBs, secrets) outside code repos

---

## DIRECTORY STRUCTURE

```
C:\stores\
├── brand2boost/                  ← Client Manager / Brand2Boost SaaS
├── brand2boost.b/                ← Backup/archive
├── artrevisionist/               ← Art Revisionist project
├── artrevisionist.b/             ← Backup/archive
├── branddesigner/                ← Brand designer
├── config/                       ← General configuration
├── SCP/                          ← SCP-related data
└── (other stores)
```

---

## BRAND2BOOST STORE (Primary)

**Location:** `C:\stores\brand2boost\`
**Used By:** Client Manager / Brand2Boost SaaS
**Git Tracked:** Yes (has .git folder)
**Size:** ~8MB (databases + configs + prompts)

### Contents Overview

**Databases (SQLite):**
- `identity.db` - User authentication (4KB, active)
- `identity.db-shm`, `identity.db-wal` - SQLite shared memory, write-ahead log
- `llm-logs.db` - LLM API call logs (3MB)

**Configuration Files:**
- `analysis-fields.config.json` - Brand analysis field definitions (8.4KB)
- `interview.settings.json` - Interview workflow settings (7.3KB)
- `opening-questions.json` - Initial onboarding questions (1.2KB)
- `tools.config.json` - AI tool configurations (345B)
- `users.json` - User management data (488B)

**AI Prompts (30+ files):**
- Brand development: `brand-*.prompt.txt`
- Business planning: `business-*.prompt.txt`
- Visual identity: `logo-*.prompt.txt`, `color-scheme.prompt.txt`, `typography.prompt.txt`
- Content generation: `image-prompt-*.prompt.txt`, `variation-style-generator.prompt.txt`
- Workflow steps: `step1_concept.txt`, `step2_identity.txt`, `step3_visuals.txt`, `step4_business_plan.txt`
- Onboarding: `onboarding.prompt.txt`

**Documentation:**
- `ANALYSIS_AND_IMPROVEMENTS.md` - Analysis and improvement tracking (10.8KB)

### Key Files Detailed

**1. identity.db**
- **Purpose:** User authentication database
- **Type:** SQLite
- **Size:** 4KB
- **Tables:**
  - AspNetUsers - User accounts
  - AspNetRoles - User roles
  - AspNetUserRoles - User-role mappings
  - User profiles, settings, etc.

**2. llm-logs.db**
- **Purpose:** LLM API call logging
- **Type:** SQLite
- **Size:** 3MB
- **Contents:**
  - API calls to OpenAI, Anthropic, etc.
  - Token usage per request
  - Cost tracking
  - Response times
  - Error logs

**3. analysis-fields.config.json**
- **Purpose:** Define fields for brand analysis
- **Format:** JSON array of field definitions
- **Fields:**
  - Field name, type, description
  - Validation rules
  - Display order
  - Required vs optional
  - AI analysis instructions

**4. interview.settings.json**
- **Purpose:** Configure interview workflow
- **Settings:**
  - Question flow logic
  - Skip conditions
  - Progress tracking
  - Completion criteria
  - AI assistance settings

**5. AI Prompt Files**

**Brand Prompts:**
- `brand.story.prompt.txt` - Generate brand story narrative
- `brand-document-fragment.prompt.txt` - Generate brand doc sections (8KB)
- `brand-name.prompt.txt` - Generate brand name suggestions
- `brand-profile.prompt.txt` - Create brand profile

**Business Prompts:**
- `business.description.prompt.txt` - Business description generation
- `business-goals.prompt.txt` - Define business goals
- `business-plan.prompt.txt` - Business plan generation (2.9KB)

**Visual Prompts:**
- `logo.prompt.txt` - Logo generation instructions
- `logo-requirements.prompt.txt` - Logo requirement analysis (1.3KB)
- `color-scheme.prompt.txt` - Color palette suggestions (1.7KB)
- `typography.prompt.txt` - Typography recommendations (2.4KB)

**Content Prompts:**
- `image-prompt-generator.prompt.txt` - Generate DALL-E prompts (1.7KB)
- `image-prompt-instructions.prompt.txt` - Image generation guide (1.5KB)
- `variation-style-generator.prompt.txt` - Generate style variations (3.3KB)

**Core Prompts:**
- `basisprompt.txt` - Base system prompt for all AI interactions (11.6KB)
- `onboarding.prompt.txt` - Onboarding flow instructions (3.8KB)
- `prompt.datagathering.txt` - Data gathering phase (4.2KB)

**Workflow Prompts:**
- `step1_concept.txt` - Phase 1: Concept development (2.5KB)
- `step2_identity.txt` - Phase 2: Brand identity (4.5KB)
- `step3_visuals.txt` - Phase 3: Visual design (2.7KB)
- `step4_business_plan.txt` - Phase 4: Business planning (2.6KB)

**Other Prompts:**
- `core-values.prompt.txt` - Core values definition
- `mission.prompt.txt` - Mission statement
- `vision.prompt.txt` - Vision statement
- `target-audience.prompt.txt` - Target audience analysis
- `tone-of-voice.prompt.txt` - Tone of voice definition
- `usps.prompt.txt` - Unique selling propositions
- `narrative.prompt.txt` - Brand narrative
- `location.prompt.txt` - Location-based branding

---

## OTHER STORES

### artrevisionist
**Purpose:** Configuration for Art Revisionist project
**Type:** Project-specific configuration
**Status:** Active

### artrevisionist.b
**Purpose:** Backup/archive of artrevisionist
**Type:** Backup
**Status:** Archive

### brand2boost.b
**Purpose:** Backup/archive of brand2boost
**Type:** Backup
**Status:** Archive

### branddesigner
**Purpose:** Brand designer configuration
**Type:** Project-specific configuration
**Status:** Active

### config
**Purpose:** General machine-wide configuration
**Type:** Configuration
**Status:** Active

### SCP
**Purpose:** SCP-related data (Secure Copy Protocol or project-specific)
**Type:** Data storage
**Status:** Active

---

## USAGE PATTERNS

### By Client Manager API

**Configuration Loading:**
```csharp
var storeRoot = "C:\\stores\\brand2boost";
var promptsPath = Path.Combine(storeRoot, "*.prompt.txt");
var configPath = Path.Combine(storeRoot, "interview.settings.json");

// Load prompts
var prompts = Directory.GetFiles(storeRoot, "*.prompt.txt");

// Load config
var settings = JsonSerializer.Deserialize<InterviewSettings>(
    File.ReadAllText(configPath));
```

**Database Access:**
```csharp
var connectionString = "Data Source=C:\\stores\\brand2boost\\identity.db";
var optionsBuilder = new DbContextOptionsBuilder<IdentityDbContext>();
optionsBuilder.UseSqlite(connectionString);
```

**LLM Logging:**
```csharp
var logsDb = "C:\\stores\\brand2boost\\llm-logs.db";
// Log API calls, token usage, costs
await LogLLMCallAsync(request, response, cost, logsDb);
```

---

## SEPARATION OF CONCERNS

### Why Separate Stores from Code?

**1. Configuration Management:**
- Change AI prompts without redeploying code
- A/B test different prompts
- Environment-specific configurations

**2. Data Persistence:**
- User data survives code redeployments
- Database persists across builds
- API logs retained independently

**3. Security:**
- Databases outside git (not committed by accident)
- Sensitive configs in separate location
- Easier to .gitignore

**4. Multi-Environment:**
```
C:\stores\brand2boost\          ← Production
C:\stores\brand2boost-dev\      ← Development
C:\stores\brand2boost-staging\  ← Staging
```

**5. Backup & Recovery:**
- Backup stores independently
- Restore configs without touching code
- Version control prompts separately

---

## MAINTENANCE

### Backup Strategy

**Databases:**
```bash
# Backup identity.db daily
sqlite3 C:\stores\brand2boost\identity.db ".backup C:\backups\identity-$(date +%Y%m%d).db"

# Backup llm-logs.db weekly
sqlite3 C:\stores\brand2boost\llm-logs.db ".backup C:\backups\llm-logs-$(date +%Y%m%d).db"
```

**Git Tracking:**
```bash
cd C:\stores\brand2boost
git add *.config.json *.prompt.txt
git commit -m "Update prompts and configs"
git push
```

**Database Cleanup:**
```bash
# Clean old LLM logs (keep last 30 days)
sqlite3 C:\stores\brand2boost\llm-logs.db "DELETE FROM logs WHERE timestamp < datetime('now', '-30 days')"

# Vacuum to reclaim space
sqlite3 C:\stores\brand2boost\llm-logs.db "VACUUM"
```

### Configuration Updates

**Updating Prompts:**
1. Edit .prompt.txt file in store
2. Test with API
3. If good → commit to git
4. No code deploy needed!

**Updating Settings:**
1. Edit .config.json file
2. Validate JSON syntax
3. Test with API
4. Commit to git

**Schema Migrations:**
```bash
# When adding new fields to identity.db
cd C:\Projects\client-manager\ClientManagerAPI
dotnet ef migrations add NewMigration
dotnet ef database update --connection "Data Source=C:\\stores\\brand2boost\\identity.db"
```

---

## RELATED DOCUMENTATION

- [PROJECTS_INDEX.md](./PROJECTS_INDEX.md) - Master project index
- [CLIENT_MANAGER_DEEP_DIVE.md](./CLIENT_MANAGER_DEEP_DIVE.md) - Client Manager uses stores
- [SCRIPTS_INDEX.md](./SCRIPTS_INDEX.md) - Scripts control plane
- [TECH_STACK_REFERENCE.md](./TECH_STACK_REFERENCE.md) - Technology stack

---

**Last Updated:** 2026-01-08
**Document Version:** 1.0
**Maintained by:** Claude Agent System
**Primary Store:** brand2boost (8MB, 30+ prompt files, 2 databases)
