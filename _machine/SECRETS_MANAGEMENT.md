# Secrets Management Best Practices 🔐

**Purpose:** Securely manage API keys, passwords, connection strings, and other sensitive credentials.

**Goal:** Never expose secrets in Git, logs, or error messages. Use secure storage for all environments.

---

## What is a Secret?

**Secrets include:**
- API keys (OpenAI, Anthropic, Stripe)
- Database passwords
- JWT signing keys
- OAuth client secrets
- Encryption keys
- Connection strings
- Service principal credentials
- Private SSH keys
- SSL/TLS certificates

**NOT secrets:**
- Public configuration (URLs, feature flags)
- Non-sensitive environment variables
- Client IDs (public part of OAuth)
- Application settings (logging levels)

---

## Golden Rules ⭐

### ❌ NEVER:
- Commit secrets to Git (even in private repos)
- Hardcode secrets in source code
- Share secrets via email/Slack
- Log secrets in console or files
- Include secrets in error messages
- Store secrets in client-side code (JavaScript)
- Use default/weak secrets ("admin", "password123")

### ✅ ALWAYS:
- Use environment variables or key vaults
- Rotate secrets regularly (every 90 days)
- Use different secrets per environment
- Encrypt secrets at rest
- Audit secret access
- Revoke secrets when team members leave
- Use strong, randomly generated secrets

---

## Secrets by Environment

| Environment | Storage Method | Access Method |
|-------------|----------------|---------------|
| **Local Dev** | `appsettings.Secrets.json` (gitignored) | File read |
| **CI/CD** | GitHub Secrets | Environment variables |
| **Staging** | Azure Key Vault | Managed Identity |
| **Production** | Azure Key Vault | Managed Identity |

---

## Local Development (appsettings.Secrets.json)

### Setup

**1. Create secrets file** (already gitignored)

```bash
cd ClientManagerAPI
cp appsettings.example.json appsettings.Secrets.json
```

**2. Add your secrets**

`ClientManagerAPI/appsettings.Secrets.json`:
```json
{
  "ApiSettings": {
    "OpenApiKey": "sk-proj-abc123...",
    "AnthropicApiKey": "sk-ant-xyz789..."
  },
  "JwtSettings": {
    "Secret": "ThisIsAVeryLongSecretKeyThatShouldBeAtLeast32CharactersLong!"
  },
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=C:\\stores\\brand2boost\\identity.db"
  },
  "GoogleOAuth": {
    "ClientId": "123456789-abc.apps.googleusercontent.com",
    "ClientSecret": "GOCSPX-abc123xyz789"
  },
  "Stripe": {
    "SecretKey": "sk_test_abc123...",
    "WebhookSecret": "whsec_abc123..."
  }
}
```

**3. Verify file is gitignored**

`.gitignore` should contain:
```gitignore
appsettings.Secrets.json
*.Secrets.json
*.local.json
```

**4. Check Git status**

```bash
git status
# Should NOT show appsettings.Secrets.json
```

### Loading Secrets (Program.cs)

```csharp
builder.Configuration
    .AddJsonFile("appsettings.json", optional: false)
    .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
    .AddJsonFile("appsettings.Secrets.json", optional: true)  // Local secrets
    .AddEnvironmentVariables();
```

### Accessing Secrets (Service)

```csharp
public class OpenAIService
{
    private readonly string _apiKey;

    public OpenAIService(IConfiguration config)
    {
        _apiKey = config["ApiSettings:OpenApiKey"]
            ?? throw new InvalidOperationException("OpenAI API key not configured");
    }
}
```

### ⚠️ What if I Accidentally Commit a Secret?

**DO NOT just delete the file and commit again!** The secret is still in Git history.

**Correct steps:**

1. **Revoke the secret immediately**
   - OpenAI: Delete API key at https://platform.openai.com/api-keys
   - Generate new key

2. **Remove from Git history**
   ```bash
   # Use BFG Repo-Cleaner
   bfg --replace-text passwords.txt  # List of secrets to remove
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   git push --force
   ```

3. **Add to .gitignore** if not already there

4. **Notify team** to pull latest changes and update their secrets

---

## GitHub Actions (CI/CD Secrets)

### Adding Secrets to GitHub

**1. Go to repository settings**
- GitHub repo → Settings → Secrets and variables → Actions

**2. Add secret**
- Name: `AZURE_PUBLISH_PROFILE_STAGING`
- Value: (paste Azure publish profile XML)

**3. Use in workflow**

`.github/workflows/deploy-staging.yml`:
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

      - name: Deploy to Azure
        uses: azure/webapps-deploy@v2
        with:
          app-name: brand2boost-staging
          publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE_STAGING }}
```

### Environment-Specific Secrets

**Use GitHub Environments:**

1. Create environment: `Settings → Environments → New environment`
   - Name: `production`
   - Add protection rules (require approval)

2. Add secrets to environment:
   - `AZURE_PUBLISH_PROFILE` (production value)

3. Use in workflow:
```yaml
jobs:
  deploy-prod:
    runs-on: ubuntu-latest
    environment: production  # Uses production secrets
    steps:
      - uses: azure/webapps-deploy@v2
        with:
          publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE }}
```

### Secret Naming Conventions

```
# Good naming
AZURE_PUBLISH_PROFILE_STAGING
AZURE_PUBLISH_PROFILE_PRODUCTION
OPENAI_API_KEY
STRIPE_SECRET_KEY_TEST
STRIPE_SECRET_KEY_LIVE

# Bad naming
SECRET1
API_KEY
PASSWORD
```

---

## Azure Key Vault (Staging & Production)

### Why Key Vault?

✅ **Centralized secret storage**
✅ **Automatic rotation**
✅ **Audit logging** (who accessed what secret when)
✅ **Access policies** (RBAC)
✅ **Versioning** (rollback to previous secret)
✅ **Managed by Azure** (high availability)

### Setup Key Vault

**1. Create Key Vault**

```bash
# Azure CLI
az keyvault create \
  --name brand2boost-kv \
  --resource-group brand2boost-rg \
  --location eastus
```

**2. Add secrets**

```bash
# Add OpenAI API key
az keyvault secret set \
  --vault-name brand2boost-kv \
  --name OpenAI-ApiKey \
  --value "sk-proj-abc123..."

# Add database password
az keyvault secret set \
  --vault-name brand2boost-kv \
  --name PostgreSQL-Password \
  --value "super-secure-password-123"

# Add JWT secret
az keyvault secret set \
  --vault-name brand2boost-kv \
  --name JwtSecret \
  --value "ThisIsAVeryLongSecretKey..."
```

**3. Enable Managed Identity on App Service**

```bash
az webapp identity assign \
  --name brand2boost-staging \
  --resource-group brand2boost-rg
```

**4. Grant App Service access to Key Vault**

```bash
# Get App Service principal ID
APP_IDENTITY=$(az webapp identity show \
  --name brand2boost-staging \
  --resource-group brand2boost-rg \
  --query principalId -o tsv)

# Grant access
az keyvault set-policy \
  --name brand2boost-kv \
  --object-id $APP_IDENTITY \
  --secret-permissions get list
```

### Loading Secrets from Key Vault (Program.cs)

```csharp
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

// In production, use Key Vault
if (!builder.Environment.IsDevelopment())
{
    var keyVaultUrl = new Uri("https://brand2boost-kv.vault.azure.net/");

    // Use Managed Identity (no credentials needed!)
    var credential = new DefaultAzureCredential();

    builder.Configuration.AddAzureKeyVault(
        keyVaultUrl,
        credential);
}
```

### Accessing Secrets (Same as Before)

```csharp
// No code changes needed!
_apiKey = config["OpenAI-ApiKey"];  // Loaded from Key Vault in prod
```

**Note:** Key Vault secret names use hyphens (`OpenAI-ApiKey`), but Configuration API normalizes to colons (`OpenAI:ApiKey`).

### Secret Rotation

**Automatic Rotation (Azure Key Vault):**

1. Set expiration on secret:
   ```bash
   az keyvault secret set \
     --vault-name brand2boost-kv \
     --name OpenAI-ApiKey \
     --value "sk-new-key..." \
     --expires "2026-04-01T00:00:00Z"
   ```

2. Set up Event Grid notification (alerts 30 days before expiry)

3. Rotate secret before expiry

**Manual Rotation Process:**

1. Generate new secret (e.g., new OpenAI API key)
2. Add new version to Key Vault:
   ```bash
   az keyvault secret set \
     --vault-name brand2boost-kv \
     --name OpenAI-ApiKey \
     --value "sk-new-key..."
   ```
3. App automatically uses latest version (no restart needed)
4. Test that app still works
5. Revoke old secret after 24 hours

---

## Secret Rotation Schedule

**Rotate every:**
- JWT signing key: **90 days**
- Database passwords: **90 days**
- API keys (OpenAI, Anthropic): **180 days** (or if compromised)
- OAuth client secrets: **180 days**
- SSL/TLS certificates: **365 days** (auto-renewed by Azure)
- Stripe API keys: **Never** (unless compromised)

**Set calendar reminders!**

---

## Secrets in Frontend

### ❌ NEVER Store Secrets in Frontend

```typescript
// ❌ WRONG: API key in JavaScript (exposed to users!)
const openai = new OpenAI({
  apiKey: 'sk-proj-abc123...'  // NEVER DO THIS!
});
```

### ✅ Use Backend Proxy

```typescript
// ✅ CORRECT: Call your backend, which has the API key
const response = await fetch('/api/chat', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${userJwt}`  // User's JWT, not API key
  },
  body: JSON.stringify({ message: 'Hello' })
});
```

**Backend handles OpenAI:**
```csharp
[Authorize]
[HttpPost("chat")]
public async Task<IActionResult> Chat([FromBody] ChatRequest request)
{
    // Backend has OpenAI API key (secure)
    var completion = await _openAIClient.CreateCompletion(request.Message);
    return Ok(completion);
}
```

### Environment Variables in Frontend (Public Config)

`.env.production`:
```env
# ✅ OK: These are public (not secrets)
VITE_API_URL=https://api.brand2boost.com
VITE_GOOGLE_CLIENT_ID=123456-abc.apps.googleusercontent.com
VITE_STRIPE_PUBLISHABLE_KEY=pk_live_abc123  # Publishable, not secret

# ❌ NEVER: These are secrets
VITE_OPENAI_API_KEY=sk-...  # WRONG! Don't do this!
```

---

## Secret Detection Tools

### 1. git-secrets (Pre-Commit Hook)

**Install:**
```bash
# macOS/Linux
brew install git-secrets

# Windows
choco install git-secrets
```

**Setup:**
```bash
cd C:\Projects\client-manager
git secrets --install
git secrets --register-aws  # AWS patterns
git secrets --add 'sk-[a-zA-Z0-9]{32,}'  # OpenAI keys
git secrets --add 'sk-ant-[a-zA-Z0-9-]{32,}'  # Anthropic keys
```

**Test:**
```bash
echo "sk-proj-abc123..." > test.txt
git add test.txt
git commit -m "test"
# Should BLOCK commit with: "secret detected!"
```

### 2. GitHub Secret Scanning

**Enable in repository:**
- Settings → Code security and analysis → Secret scanning → Enable

**What it catches:**
- AWS keys
- Azure keys
- OpenAI keys
- Stripe keys
- Google OAuth secrets
- And 200+ other secret types

**Alert when found:**
- Email notification
- GitHub UI alert
- Can auto-revoke some secret types (Stripe, GitHub)

### 3. Trufflehog (Scan History)

**Scan entire Git history for secrets:**
```bash
# Install
brew install trufflesecurity/trufflehog/trufflehog

# Scan repository
trufflehog git file://. --since-commit HEAD~100
```

---

## Secrets in Logs

### ❌ Don't Log Secrets

```csharp
// ❌ WRONG: Logs API key to Application Insights
_logger.LogInformation("Calling OpenAI with key {ApiKey}", _apiKey);
```

### ✅ Log Safely

```csharp
// ✅ CORRECT: Log only last 4 chars
var maskedKey = $"sk-...{_apiKey[^4..]}";
_logger.LogInformation("Calling OpenAI with key {ApiKey}", maskedKey);

// ✅ CORRECT: Don't log key at all
_logger.LogInformation("Calling OpenAI API");
```

### Redact Secrets in Logs

```csharp
public class SecretRedactionProcessor : ILogProcessor
{
    private static readonly Regex ApiKeyPattern = new Regex(@"sk-[a-zA-Z0-9]{32,}");

    public void Process(LogEvent logEvent)
    {
        if (logEvent.MessageTemplate.Text.Contains("sk-"))
        {
            logEvent.MessageTemplate = new MessageTemplate(
                ApiKeyPattern.Replace(logEvent.MessageTemplate.Text, "sk-***REDACTED***"));
        }
    }
}
```

---

## Secrets in Error Messages

### ❌ Don't Expose Secrets in Errors

```csharp
// ❌ WRONG: Connection string in error
try
{
    await _db.Database.OpenConnectionAsync();
}
catch (Exception ex)
{
    throw new Exception($"Failed to connect to {_connectionString}", ex);
    // Exposes password in error message!
}
```

### ✅ Generic Error Messages

```csharp
// ✅ CORRECT: Generic error
try
{
    await _db.Database.OpenConnectionAsync();
}
catch (Exception ex)
{
    _logger.LogError(ex, "Database connection failed");
    throw new Exception("Database connection failed");
    // No secret in error message
}
```

---

## Developer Onboarding (Secrets)

**New developer checklist:**

1. [ ] Install Git
2. [ ] Clone repository
3. [ ] Copy `appsettings.example.json` → `appsettings.Secrets.json`
4. [ ] Ask team lead for dev API keys (Slack DM, never email)
5. [ ] Paste keys into `appsettings.Secrets.json`
6. [ ] Verify file is gitignored: `git status` (should NOT show file)
7. [ ] Run app locally to test

**Team lead provides:**
- OpenAI API key (dev/test account)
- Anthropic API key (dev/test account)
- Stripe test keys (test mode)
- Google OAuth credentials (dev client ID/secret)

**Never share production secrets with developers!**

---

## Secrets Checklist (Before Deploy)

**Pre-deploy security audit:**

- [ ] No secrets in Git history (`git log -p | grep -i 'sk-'`)
- [ ] `.gitignore` includes `*.Secrets.json`
- [ ] All secrets in Azure Key Vault (staging/prod)
- [ ] Managed Identity enabled on App Service
- [ ] Key Vault access policies configured
- [ ] Secrets rotated in last 90 days
- [ ] Different secrets for dev/staging/prod
- [ ] Logs don't contain secrets
- [ ] Error messages don't contain secrets
- [ ] GitHub secret scanning enabled
- [ ] Frontend has no secrets (only backend)

---

## Common Mistakes & Fixes

### Mistake #1: Committed Secret to Git

**Fix:**
1. Revoke secret immediately
2. Remove from Git history (BFG Repo-Cleaner)
3. Generate new secret
4. Force push (⚠️ notify team first)

### Mistake #2: Using Same Secret in All Environments

**Fix:**
- Generate separate secrets for dev/staging/prod
- Use Key Vault for staging/prod
- Local file for dev only

### Mistake #3: Sharing Secrets via Slack/Email

**Fix:**
- Use secure password manager (1Password, LastPass)
- Or: Add secret to Key Vault, grant access via Azure RBAC

### Mistake #4: Hardcoded Secret in Code

```csharp
// ❌ WRONG
var apiKey = "sk-proj-abc123...";

// ✅ CORRECT
var apiKey = _config["OpenAI:ApiKey"];
```

### Mistake #5: API Key in JavaScript

```typescript
// ❌ WRONG: Frontend API key
const openai = new OpenAI({ apiKey: 'sk-...' });

// ✅ CORRECT: Call backend
fetch('/api/chat', { method: 'POST', ... });
```

---

## Emergency: Secret Compromised

**If a secret is leaked (GitHub, logs, email):**

1. **Revoke immediately** (within 5 minutes)
   - OpenAI: Delete key at https://platform.openai.com/api-keys
   - Azure: Disable managed identity temporarily

2. **Assess impact**
   - Check logs for unauthorized usage
   - Check billing for unusual activity
   - Determine scope of exposure

3. **Generate new secret**
   - Create new API key/password
   - Update Key Vault or appsettings.Secrets.json

4. **Deploy new secret**
   - Restart App Service (picks up new Key Vault value)
   - Or: Update config and redeploy

5. **Notify stakeholders**
   - Security team
   - Management (if high severity)
   - Legal (if GDPR/PII involved)

6. **Post-incident review**
   - How did it happen?
   - How to prevent in future?
   - Update security checklist

---

## Tools & Resources

**Secret Scanning:**
- [git-secrets](https://github.com/awslabs/git-secrets) - Pre-commit hook
- [Trufflehog](https://github.com/trufflesecurity/trufflehog) - Scan Git history
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning) - Built-in
- [GitGuardian](https://www.gitguardian.com/) - Commercial tool

**Secret Management:**
- [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/)
- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
- [HashiCorp Vault](https://www.vaultproject.io/)
- [1Password](https://1password.com/) - Team password manager

**Guides:**
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [Azure Key Vault Best Practices](https://docs.microsoft.com/en-us/azure/key-vault/general/best-practices)

---

## Related Documentation

- [MULTI_ENVIRONMENT_CONFIGURATION.md](./MULTI_ENVIRONMENT_CONFIGURATION.md) - Environment setup
- [SECURITY_CHECKLIST.md](./SECURITY_CHECKLIST.md) - Security best practices
- [ADR-002: SQLite Dev / PostgreSQL Prod](./ADR/002-sqlite-dev-postgres-prod.md)

---

**Last Updated:** 2026-01-08
**Secret Rotation Due:** 2026-04-01
**Maintained by:** Security Team & DevOps
