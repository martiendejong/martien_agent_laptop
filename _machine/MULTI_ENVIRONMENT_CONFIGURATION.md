# Multi-Environment Configuration Guide 🌍

**Purpose:** How to set up and manage multiple environments (dev, staging, production) with separate databases and configurations.

**Goal:** Prevent production accidents, enable safe testing, and maintain environment parity.

---

## Environment Overview

Brand2Boost uses **three environments:**

| Environment | Purpose | Database | Hosting | URL |
|-------------|---------|----------|---------|-----|
| **Development** | Local coding | SQLite (file) | Local machine | https://localhost:5173 |
| **Staging** | Pre-production testing | PostgreSQL (Azure) | Azure App Service | https://staging.brand2boost.com |
| **Production** | Live customer traffic | PostgreSQL (Azure) | Azure App Service | https://brand2boost.com |

---

## Development Environment (Local)

### Setup

**Prerequisites:**
- .NET 9.0 SDK
- Node.js 18+
- Git

**Quick Start:**
```bash
cd C:\Projects\client-manager

# Backend
cd ClientManagerAPI
dotnet restore
dotnet run  # Runs at https://localhost:54501

# Frontend (new terminal)
cd ../ClientManagerFrontend
npm install
npm run dev  # Runs at https://localhost:5173
```

### Configuration Files

**Backend:** `ClientManagerAPI/appsettings.Development.json`
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=C:\\stores\\brand2boost\\identity.db"
  },
  "AllowedHosts": "*",
  "Cors": {
    "AllowedOrigins": ["https://localhost:5173"]
  }
}
```

**Backend Secrets:** `ClientManagerAPI/appsettings.Secrets.json` (NOT in Git)
```json
{
  "ApiSettings": {
    "OpenApiKey": "sk-YOUR-OPENAI-KEY-HERE",
    "AnthropicApiKey": "sk-ant-YOUR-ANTHROPIC-KEY-HERE"
  },
  "JwtSettings": {
    "Secret": "YOUR-256-BIT-SECRET-KEY-HERE-MINIMUM-32-CHARACTERS-LONG"
  },
  "GoogleOAuth": {
    "ClientId": "YOUR-GOOGLE-CLIENT-ID",
    "ClientSecret": "YOUR-GOOGLE-CLIENT-SECRET"
  }
}
```

**Frontend:** `ClientManagerFrontend/.env.local` (NOT in Git)
```env
VITE_API_URL=https://localhost:54501
VITE_GOOGLE_CLIENT_ID=YOUR-GOOGLE-CLIENT-ID
```

### Database

**Type:** SQLite (file-based)
**Location:** `C:\stores\brand2boost\identity.db`
**Migrations:**
```bash
cd ClientManagerAPI
dotnet ef database update
```

**Reset Database:**
```bash
rm C:\stores\brand2boost\identity.db
dotnet ef database update
```

### Environment Detection

```csharp
// Backend (Program.cs)
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}
```

### Local Testing Checklist

✅ Backend runs at https://localhost:54501
✅ Frontend runs at https://localhost:5173
✅ CORS allows localhost:5173
✅ SQLite database created
✅ Can register and login
✅ Swagger UI accessible at /swagger

---

## Staging Environment (Azure)

### Purpose

**Staging is production-like testing:**
- Test new features before production deployment
- Verify migrations on PostgreSQL
- Load testing
- Integration testing
- Client demos

### Setup

**Hosting:**
- Azure App Service (Linux, B1 tier)
- Azure Database for PostgreSQL (Flexible Server, B1 tier)
- Azure Blob Storage (for file uploads)

**URL:** https://staging.brand2boost.com

### Configuration

**Backend:** `ClientManagerAPI/appsettings.Staging.json`
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Host=brand2boost-staging.postgres.database.azure.com;Database=brand2boost_staging;Username=adminuser;Password=***KEYVAULT***"
  },
  "AllowedHosts": "staging.brand2boost.com",
  "Cors": {
    "AllowedOrigins": ["https://staging.brand2boost.com"]
  }
}
```

**Secrets (Azure Key Vault):**
- `OpenAI-ApiKey` → OpenAI API key
- `Anthropic-ApiKey` → Anthropic API key
- `JwtSecret` → JWT signing key
- `PostgreSQL-Password` → Database password
- `GoogleOAuth-ClientSecret` → OAuth secret

**Frontend:** `ClientManagerFrontend/.env.staging`
```env
VITE_API_URL=https://api-staging.brand2boost.com
VITE_GOOGLE_CLIENT_ID=staging-google-client-id
```

### Database

**Type:** PostgreSQL 15 + pgvector
**Server:** `brand2boost-staging.postgres.database.azure.com`
**Database Name:** `brand2boost_staging`
**Connection:** Via Azure VNet (private endpoint)

**Migrations:**
```bash
# Run from local machine OR CI/CD pipeline
dotnet ef database update --connection "Host=...;Database=brand2boost_staging;..."
```

### Deployment

**Method:** GitHub Actions (CI/CD)

**.github/workflows/deploy-staging.yml:**
```yaml
name: Deploy to Staging

on:
  push:
    branches: [develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '9.0.x'

      - name: Build Backend
        run: |
          cd ClientManagerAPI
          dotnet publish -c Release -o ./publish

      - name: Deploy to Azure App Service
        uses: azure/webapps-deploy@v2
        with:
          app-name: brand2boost-staging
          publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE_STAGING }}
          package: ./ClientManagerAPI/publish

      - name: Build Frontend
        run: |
          cd ClientManagerFrontend
          npm install
          npm run build

      - name: Deploy Frontend to Blob Storage
        run: |
          az storage blob upload-batch \
            --account-name brand2booststaging \
            --source ./ClientManagerFrontend/dist \
            --destination '$web'
```

### Testing on Staging

**Checklist:**
✅ Migrations applied successfully
✅ All API endpoints working
✅ SignalR connections stable
✅ OAuth login works
✅ Token usage tracking accurate
✅ No CORS errors
✅ HTTPS certificates valid
✅ Database backups configured

**Load Testing:**
```bash
# Use k6 or Artillery
k6 run load-test.js --env STAGING
```

### Staging Data

**Strategy:** Synthetic test data (no real customer data)
- Auto-generate test users on deploy
- Seed realistic brands/content
- Reset database weekly

**Seed Script:**
```bash
dotnet run --project ClientManagerAPI -- seed-staging
```

---

## Production Environment (Azure)

### Purpose

**Live customer traffic:**
- Real users
- Real payments (Stripe)
- Real data (GDPR compliant)
- High availability
- Monitoring and alerts

### Setup

**Hosting:**
- Azure App Service (P1V3 tier, 2 instances for HA)
- Azure Database for PostgreSQL (GP tier, 4 vCores, 100GB)
- Azure Blob Storage (Hot tier)
- Azure CDN (for frontend static files)
- Azure Application Insights (monitoring)
- Azure Key Vault (secrets)

**URL:** https://brand2boost.com

### Configuration

**Backend:** `ClientManagerAPI/appsettings.Production.json`
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft.AspNetCore": "Error"
    },
    "ApplicationInsights": {
      "LogLevel": {
        "Default": "Information"
      }
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Host=brand2boost-prod.postgres.database.azure.com;Database=brand2boost;Username=adminuser;Password=***KEYVAULT***;SslMode=Require;Trust Server Certificate=false;"
  },
  "AllowedHosts": "brand2boost.com,api.brand2boost.com",
  "Cors": {
    "AllowedOrigins": ["https://brand2boost.com"]
  },
  "ApplicationInsights": {
    "ConnectionString": "InstrumentationKey=***KEYVAULT***"
  }
}
```

**Secrets (Azure Key Vault):**
- All secrets stored in Key Vault
- Auto-rotation every 90 days
- Access via Managed Identity (no keys in config)

**Frontend:** `ClientManagerFrontend/.env.production`
```env
VITE_API_URL=https://api.brand2boost.com
VITE_GOOGLE_CLIENT_ID=prod-google-client-id
VITE_APP_INSIGHTS_KEY=your-app-insights-key
```

### Database

**Type:** PostgreSQL 15 + pgvector
**Server:** `brand2boost-prod.postgres.database.azure.com`
**Database Name:** `brand2boost`
**Backup:** Daily automated backups (7-day retention)
**HA:** Zone-redundant (99.99% SLA)

**Connection Pooling:**
```csharp
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString, npgsqlOptions =>
    {
        npgsqlOptions.EnableRetryOnFailure(3);
        npgsqlOptions.UseVector();
        npgsqlOptions.CommandTimeout(30);
    }));
```

**Migrations (Production):**
⚠️ **NEVER run migrations directly on production!**

**Correct Process:**
1. Test migration on staging
2. Schedule maintenance window
3. Run migration via CI/CD pipeline
4. Monitor for errors
5. Rollback plan ready

```bash
# Automated via GitHub Actions (requires approval)
dotnet ef database update --connection $PROD_CONNECTION_STRING
```

### Deployment (Production)

**Method:** GitHub Actions with manual approval

**.github/workflows/deploy-production.yml:**
```yaml
name: Deploy to Production

on:
  push:
    branches: [main]  # Only from main branch

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # Requires manual approval
    steps:
      - uses: actions/checkout@v3

      - name: Run Tests
        run: |
          cd ClientManagerAPI
          dotnet test

      - name: Build Backend
        run: |
          cd ClientManagerAPI
          dotnet publish -c Release -o ./publish

      - name: Deploy to Azure App Service (Slot: staging)
        uses: azure/webapps-deploy@v2
        with:
          app-name: brand2boost-prod
          slot-name: staging  # Deploy to staging slot first
          publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE_PROD }}
          package: ./ClientManagerAPI/publish

      - name: Smoke Test Staging Slot
        run: |
          curl -f https://brand2boost-prod-staging.azurewebsites.net/health || exit 1

      - name: Swap Slots (Staging → Production)
        run: |
          az webapp deployment slot swap \
            --name brand2boost-prod \
            --resource-group brand2boost-rg \
            --slot staging \
            --target-slot production
```

**Deployment Slots Strategy:**
1. Deploy to **staging slot**
2. Run smoke tests on staging slot
3. **Swap slots** (zero downtime)
4. Monitor production for errors
5. If issues: swap back immediately

### Monitoring & Alerts

**Application Insights:**
- Request/response times
- Error rates
- Dependency failures (OpenAI API, database)
- Custom metrics (token usage, revenue)

**Alerts:**
```yaml
Alerts:
  - Name: "High Error Rate"
    Condition: "Error rate > 5% for 5 minutes"
    Action: Email + Slack notification

  - Name: "High Latency"
    Condition: "P95 response time > 2 seconds"
    Action: Email

  - Name: "Database CPU High"
    Condition: "Database CPU > 80% for 10 minutes"
    Action: Email + PagerDuty

  - Name: "OpenAI Budget Exceeded"
    Condition: "Daily OpenAI cost > $500"
    Action: Email + Slack
```

**Dashboard:**
- Grafana or Azure Dashboard
- Real-time metrics
- Uptime status

### Security (Production)

**HTTPS Only:**
- Force HTTPS redirect
- HSTS headers
- TLS 1.2+ only

**Secrets:**
- All secrets in Azure Key Vault
- Managed Identity (no passwords in code)
- Automatic rotation

**Database:**
- Private endpoint (no public access)
- SSL required
- IP whitelist (only App Service)

**API Rate Limiting:**
- 100 requests/minute per user (Free)
- 1000 requests/minute per user (Pro)
- DDoS protection (Azure WAF)

**CORS:**
- Only allow https://brand2boost.com
- No wildcards

---

## Environment Comparison

| Feature | Development | Staging | Production |
|---------|-------------|---------|------------|
| **Database** | SQLite (file) | PostgreSQL (Azure) | PostgreSQL (Azure, HA) |
| **Hosting** | Local machine | Azure App Service (B1) | Azure App Service (P1V3, 2 instances) |
| **Secrets** | appsettings.Secrets.json | Azure Key Vault | Azure Key Vault |
| **HTTPS** | Self-signed cert | Let's Encrypt | Azure-managed cert |
| **Monitoring** | Console logs | Application Insights | Application Insights + alerts |
| **Backups** | Manual (copy file) | Daily (7-day retention) | Daily (30-day retention) + PITR |
| **CI/CD** | Manual (F5) | Auto-deploy on `develop` push | Manual approval required |
| **Uptime** | Best effort | ~99% | 99.99% SLA |
| **Cost** | $0 (local) | ~$50/month | ~$300/month |

---

## Configuration Hierarchy

**ASP.NET Core loads configs in this order (later overrides earlier):**

1. `appsettings.json` (base config)
2. `appsettings.{Environment}.json` (environment-specific)
3. `appsettings.Secrets.json` (local secrets, dev only)
4. Environment variables (Azure App Service settings)
5. Azure Key Vault (production only)
6. Command-line arguments

**Example:**
```csharp
// Program.cs
builder.Configuration
    .AddJsonFile("appsettings.json")
    .AddJsonFile($"appsettings.{env}.json", optional: true)
    .AddJsonFile("appsettings.Secrets.json", optional: true)
    .AddEnvironmentVariables()
    .AddAzureKeyVault(keyVaultUrl);  // Production only
```

---

## Best Practices ✅

### DO:
✅ Test on staging before production
✅ Use separate databases per environment
✅ Never commit secrets to Git
✅ Use environment variables in CI/CD
✅ Monitor production with Application Insights
✅ Schedule maintenance windows for migrations
✅ Have rollback plan ready
✅ Use deployment slots for zero-downtime
✅ Auto-backup production database daily
✅ Encrypt data at rest and in transit

### DON'T:
❌ Run migrations directly on production
❌ Use production database for testing
❌ Hardcode secrets in appsettings.json
❌ Skip testing on staging
❌ Deploy on Friday afternoon
❌ Use same OAuth credentials across environments
❌ Allow public database access
❌ Disable HTTPS in production

---

## Troubleshooting

### "Can't connect to database"
**Symptoms:** Backend crashes with connection error

**Dev:**
```bash
# Check SQLite file exists
ls C:\stores\brand2boost\identity.db

# Recreate database
rm C:\stores\brand2boost\identity.db
dotnet ef database update
```

**Staging/Prod:**
```bash
# Check connection string
az webapp config appsettings list --name brand2boost-staging

# Test connection
psql "Host=...;Database=...;Username=...;Password=..."
```

### "CORS error in browser"
**Symptoms:** Frontend can't call API

**Fix:**
```csharp
// Program.cs - Check CORS config
app.UseCors(policy => policy
    .WithOrigins(allowedOrigins)  // Must match frontend URL
    .AllowAnyMethod()
    .AllowAnyHeader()
    .AllowCredentials());
```

### "Secrets not found"
**Symptoms:** API key errors

**Dev:**
```bash
# Create appsettings.Secrets.json
cp appsettings.example.json appsettings.Secrets.json
# Edit and add your API keys
```

**Prod:**
```bash
# Check Key Vault access
az keyvault secret show --vault-name brand2boost-kv --name OpenAI-ApiKey
```

### "Migration failed"
**Symptoms:** Database schema out of sync

**Fix:**
```bash
# Check migration status
dotnet ef migrations list

# Apply pending migrations
dotnet ef database update

# If stuck, rollback and retry
dotnet ef database update PreviousMigration
dotnet ef database update
```

---

## Environment Variables Reference

### Backend (ASP.NET Core)

```bash
ASPNETCORE_ENVIRONMENT=Development|Staging|Production
ConnectionStrings__DefaultConnection=...
ApiSettings__OpenApiKey=sk-...
JwtSettings__Secret=...
GoogleOAuth__ClientId=...
GoogleOAuth__ClientSecret=...
```

### Frontend (Vite React)

```bash
VITE_API_URL=https://api.brand2boost.com
VITE_GOOGLE_CLIENT_ID=...
VITE_APP_INSIGHTS_KEY=...
```

---

## Related Documentation

- [GETTING_STARTED.md](./GETTING_STARTED.md) - Local development setup
- [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) - Database structure
- [ENABLE_SWAGGER_API_DOCS.md](./ENABLE_SWAGGER_API_DOCS.md) - API documentation
- [ADR-002: SQLite Dev / PostgreSQL Prod](./ADR/002-sqlite-dev-postgres-prod.md)

---

**Last Updated:** 2026-01-08
**Maintained by:** DevOps Team
**Questions?** See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
