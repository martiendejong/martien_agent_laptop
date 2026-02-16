# Security Checklist 🔒

**Purpose:** Prevent security vulnerabilities in Brand2Boost by following industry best practices.

**Based on:** OWASP Top 10 (2021), CWE Top 25, Azure Security Baseline

---

## Quick Security Review Checklist

**Before every deploy:**

- [ ] No secrets in Git history
- [ ] All inputs validated
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented (output encoding)
- [ ] CSRF tokens on forms
- [ ] Authentication required on sensitive endpoints
- [ ] Authorization checks on all data access
- [ ] HTTPS enforced (no HTTP)
- [ ] Dependencies scanned for vulnerabilities
- [ ] Error messages don't leak sensitive info

---

## OWASP Top 10 (2021) Coverage

### 1. Broken Access Control (A01:2021)

**Risk:** Users access resources they shouldn't (e.g., other users' data)

#### ✅ Prevention

**Multi-Tenant Data Isolation:**
```csharp
// ✅ CORRECT: Always filter by current user
var userId = User.FindFirst(ClaimTypes.NameIdentifier).Value;
var brands = await _db.Brands
    .Where(b => b.UserId == userId)
    .ToListAsync();

// ❌ WRONG: Trust client input
var brands = await _db.Brands
    .Where(b => b.UserId == request.UserId)  // Client can fake this!
    .ToListAsync();
```

**Entity Framework Global Query Filters:**
```csharp
// AppDbContext.cs
protected override void OnModelCreating(ModelBuilder builder)
{
    var userId = _httpContextAccessor.HttpContext?.User
        .FindFirst(ClaimTypes.NameIdentifier)?.Value;

    builder.Entity<Brand>()
        .HasQueryFilter(b => b.UserId == userId);
}
```

**Authorization Attributes:**
```csharp
[Authorize]  // Require authentication
[HttpGet]
public async Task<IActionResult> GetBrands() { /* ... */ }

[Authorize(Roles = "Admin")]  // Require specific role
[HttpPost("admin/users")]
public async Task<IActionResult> CreateUser() { /* ... */ }
```

**Checklist:**
- [ ] Every API endpoint has `[Authorize]` attribute (unless public)
- [ ] User ID extracted from JWT, never from request body
- [ ] EF query filters enforce tenant isolation
- [ ] Direct object references validated (e.g., `BrandId` belongs to user)
- [ ] File uploads restricted by user
- [ ] Admin endpoints require Admin role

---

### 2. Cryptographic Failures (A02:2021)

**Risk:** Sensitive data exposed due to weak encryption

#### ✅ Prevention

**HTTPS Enforced:**
```csharp
// Program.cs
app.UseHttpsRedirection();  // Force HTTPS

// appsettings.json
"Kestrel": {
  "EndpointDefaults": {
    "Protocols": "Http2"
  }
}
```

**Password Hashing (ASP.NET Identity):**
```csharp
// Automatic with Identity
var result = await _userManager.CreateAsync(user, password);
// Uses PBKDF2 with 10,000 iterations by default
```

**JWT Signing:**
```csharp
var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSecret));
var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
```

**Database Encryption:**
```sql
-- Azure PostgreSQL: Transparent Data Encryption (TDE) enabled by default
-- Encryption at rest
```

**Checklist:**
- [ ] HTTPS enforced in production
- [ ] Passwords hashed with ASP.NET Identity (never plain text)
- [ ] JWT signed with strong secret (256-bit minimum)
- [ ] Sensitive data encrypted at rest (Azure TDE)
- [ ] API keys stored in Azure Key Vault (not appsettings.json)
- [ ] No sensitive data in logs
- [ ] SSL/TLS 1.2+ only (no TLS 1.0/1.1)

---

### 3. Injection (A03:2021)

**Risk:** SQL injection, command injection, NoSQL injection

#### ✅ Prevention

**SQL Injection (Entity Framework):**
```csharp
// ✅ CORRECT: Parameterized queries (EF does this automatically)
var user = await _db.Users
    .Where(u => u.Email == email)  // Safe: parameterized
    .FirstOrDefaultAsync();

// ❌ WRONG: String interpolation (vulnerable!)
var sql = $"SELECT * FROM Users WHERE Email = '{email}'";  // NEVER DO THIS
var user = await _db.Users.FromSqlRaw(sql).FirstOrDefaultAsync();

// ✅ CORRECT: If you must use raw SQL, use parameters
var user = await _db.Users
    .FromSqlRaw("SELECT * FROM Users WHERE Email = {0}", email)
    .FirstOrDefaultAsync();
```

**Command Injection:**
```csharp
// ❌ WRONG: Execute shell command with user input
Process.Start("cmd.exe", $"/c del {userFilename}");  // DANGEROUS!

// ✅ CORRECT: Validate and sanitize input
if (!Path.GetFileName(userFilename).Equals(userFilename))
{
    throw new ArgumentException("Invalid filename");
}
```

**NoSQL Injection (if using MongoDB):**
```csharp
// Use strongly-typed queries, not string concatenation
var filter = Builders<User>.Filter.Eq(u => u.Email, email);
```

**Checklist:**
- [ ] Always use Entity Framework LINQ queries (parameterized by default)
- [ ] Never use string interpolation in SQL queries
- [ ] Validate file paths before file operations
- [ ] Never execute shell commands with user input
- [ ] Use parameterized queries for raw SQL (if necessary)

---

### 4. Insecure Design (A04:2021)

**Risk:** Fundamental design flaws, missing security controls

#### ✅ Prevention

**Rate Limiting:**
```csharp
// Install: AspNetCoreRateLimit
services.AddInMemoryRateLimiting();
services.Configure<IpRateLimitOptions>(options =>
{
    options.GeneralRules = new List<RateLimitRule>
    {
        new RateLimitRule
        {
            Endpoint = "POST:/api/auth/login",
            Limit = 5,
            Period = "1m"  // 5 attempts per minute
        }
    };
});
```

**Account Lockout:**
```csharp
// ASP.NET Identity configuration
services.Configure<IdentityOptions>(options =>
{
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
});
```

**Input Validation:**
```csharp
public class RegisterRequest
{
    [Required]
    [EmailAddress]
    [MaxLength(255)]
    public string Email { get; set; }

    [Required]
    [MinLength(8)]
    [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$",
        ErrorMessage = "Password must have uppercase, lowercase, and digit")]
    public string Password { get; set; }
}
```

**Checklist:**
- [ ] Rate limiting on authentication endpoints
- [ ] Account lockout after 5 failed login attempts
- [ ] Strong password requirements (8+ chars, mixed case, digit)
- [ ] Email verification before account activation
- [ ] CAPTCHA on sensitive forms (optional)
- [ ] Security headers configured (see #5)

---

### 5. Security Misconfiguration (A05:2021)

**Risk:** Default credentials, unnecessary features enabled, verbose errors

#### ✅ Prevention

**Security Headers:**
```csharp
// Program.cs
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Add("X-Frame-Options", "DENY");
    context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
    context.Response.Headers.Add("Referrer-Policy", "no-referrer");
    context.Response.Headers.Add("Content-Security-Policy",
        "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'");
    context.Response.Headers.Add("Strict-Transport-Security",
        "max-age=31536000; includeSubDomains");
    await next();
});
```

**Disable Detailed Errors in Production:**
```csharp
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();  // Detailed errors (dev only)
}
else
{
    app.UseExceptionHandler("/error");  // Generic error page (prod)
}
```

**Remove Unnecessary Headers:**
```csharp
// appsettings.json
"Kestrel": {
  "AddServerHeader": false  // Don't reveal "Server: Kestrel"
}
```

**Checklist:**
- [ ] Security headers configured (CSP, X-Frame-Options, HSTS)
- [ ] Detailed error messages disabled in production
- [ ] Server header removed or anonymized
- [ ] Swagger/OpenAPI disabled in production
- [ ] Default admin account removed
- [ ] Unused dependencies removed
- [ ] CORS configured (not wildcard `*`)

---

### 6. Vulnerable and Outdated Components (A06:2021)

**Risk:** Using libraries with known vulnerabilities

#### ✅ Prevention

**Dependency Scanning:**
```bash
# Scan .NET dependencies for vulnerabilities
dotnet list package --vulnerable --include-transitive

# Scan npm dependencies
npm audit

# Update dependencies
dotnet add package PackageName --version X.Y.Z
npm update
```

**Automated Scanning (GitHub Dependabot):**
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "nuget"
    directory: "/ClientManagerAPI"
    schedule:
      interval: "weekly"

  - package-ecosystem: "npm"
    directory: "/ClientManagerFrontend"
    schedule:
      interval: "weekly"
```

**Checklist:**
- [ ] Run `dotnet list package --vulnerable` monthly
- [ ] Run `npm audit` monthly
- [ ] Enable GitHub Dependabot alerts
- [ ] Update dependencies regularly (not just when vulnerable)
- [ ] Review release notes before updating
- [ ] Test after dependency updates

---

### 7. Identification and Authentication Failures (A07:2021)

**Risk:** Weak passwords, session hijacking, credential stuffing

#### ✅ Prevention

**Strong Password Policy:**
```csharp
services.Configure<IdentityOptions>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireUppercase = true;
    options.Password.RequiredLength = 8;
    options.Password.RequireNonAlphanumeric = false;  // Optional
});
```

**JWT Configuration:**
```csharp
var token = new JwtSecurityToken(
    issuer: "Brand2Boost",
    audience: "Brand2Boost-Frontend",
    claims: claims,
    expires: DateTime.UtcNow.AddHours(1),  // Short expiration
    signingCredentials: creds
);
```

**OAuth 2.0 (Google):**
```csharp
services.AddAuthentication()
    .AddGoogle(options =>
    {
        options.ClientId = Configuration["GoogleOAuth:ClientId"];
        options.ClientSecret = Configuration["GoogleOAuth:ClientSecret"];
    });
```

**Checklist:**
- [ ] Passwords at least 8 characters
- [ ] Require uppercase, lowercase, and digit
- [ ] JWT tokens expire within 1 hour
- [ ] Refresh tokens for long-lived sessions
- [ ] OAuth 2.0 for Google login
- [ ] Multi-factor authentication (future)
- [ ] Prevent password reuse (last 5 passwords)
- [ ] Detect credential stuffing (rate limit login)

---

### 8. Software and Data Integrity Failures (A08:2021)

**Risk:** Insecure CI/CD, unsigned code, tampered dependencies

#### ✅ Prevention

**Code Signing (CI/CD):**
```yaml
# .github/workflows/deploy.yml
- name: Sign assemblies
  run: |
    dotnet sign **/*.dll --certificate ${{ secrets.CODE_SIGNING_CERT }}
```

**Verify npm Package Integrity:**
```bash
npm install --integrity  # Verify package hashes
```

**Immutable Infrastructure:**
- Use Docker images with specific tags (not `latest`)
- Tag releases (`v1.0.0`, `v1.0.1`)
- Don't modify running containers (deploy new ones)

**Checklist:**
- [ ] CI/CD pipeline uses trusted runners (GitHub Actions)
- [ ] Code review required before merge
- [ ] Dependencies locked (package-lock.json, .csproj)
- [ ] npm packages verified with `--integrity`
- [ ] Releases tagged in Git
- [ ] Rollback plan documented

---

### 9. Security Logging and Monitoring Failures (A09:2021)

**Risk:** Attacks go undetected, no audit trail

#### ✅ Prevention

**Structured Logging:**
```csharp
_logger.LogWarning("Failed login attempt for user {Email} from IP {IpAddress}",
    email,
    httpContext.Connection.RemoteIpAddress);

_logger.LogInformation("User {UserId} accessed Brand {BrandId}",
    userId,
    brandId);
```

**Application Insights:**
```csharp
services.AddApplicationInsightsTelemetry();

// Track custom events
_telemetry.TrackEvent("TokenPurchased", new Dictionary<string, string>
{
    { "UserId", userId },
    { "Amount", amount.ToString() }
});
```

**Alerts:**
```yaml
# Alert on high error rate
- Name: "High Login Failures"
  Condition: "Failed login count > 10 in 5 minutes"
  Action: "Email security team"

- Name: "Unusual Token Usage"
  Condition: "User consumes >90% of tokens in 1 hour"
  Action: "Alert and investigate"
```

**Checklist:**
- [ ] Log all authentication events (login, logout, failed attempts)
- [ ] Log all authorization failures
- [ ] Log all data access (who accessed what)
- [ ] Never log passwords or API keys
- [ ] Centralize logs (Application Insights)
- [ ] Set up alerts for suspicious activity
- [ ] Retain logs for 90 days minimum
- [ ] Monitor for unusual patterns

---

### 10. Server-Side Request Forgery (SSRF) (A10:2021)

**Risk:** Attacker tricks server into making requests to internal resources

#### ✅ Prevention

**Validate URLs:**
```csharp
// ✅ CORRECT: Whitelist allowed domains
public async Task<string> FetchExternalContent(string url)
{
    var allowedDomains = new[] { "api.openai.com", "api.anthropic.com" };
    var uri = new Uri(url);

    if (!allowedDomains.Contains(uri.Host))
    {
        throw new ArgumentException("Domain not allowed");
    }

    return await _httpClient.GetStringAsync(url);
}

// ❌ WRONG: Trust user-provided URL
public async Task<string> FetchContent(string url)
{
    return await _httpClient.GetStringAsync(url);  // DANGEROUS!
}
```

**Block Internal IPs:**
```csharp
if (uri.Host == "localhost" ||
    uri.Host == "127.0.0.1" ||
    uri.Host.StartsWith("192.168.") ||
    uri.Host.StartsWith("10.") ||
    uri.Host.StartsWith("172.16."))
{
    throw new ArgumentException("Internal IP addresses not allowed");
}
```

**Checklist:**
- [ ] Whitelist allowed external domains
- [ ] Block requests to internal IPs (localhost, 192.168.x.x, 10.x.x.x)
- [ ] Don't follow redirects blindly
- [ ] Validate and sanitize URLs
- [ ] Use DNS rebinding protection

---

## Additional Security Controls

### Cross-Site Scripting (XSS)

**React Automatic Escaping:**
```typescript
// ✅ SAFE: React escapes by default
<div>{userInput}</div>

// ❌ DANGEROUS: dangerouslySetInnerHTML
<div dangerouslySetInnerHTML={{ __html: userInput }} />  // AVOID!

// ✅ CORRECT: Sanitize if you must use HTML
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />
```

**Content Security Policy:**
```csharp
context.Response.Headers.Add("Content-Security-Policy",
    "default-src 'self'; script-src 'self'; object-src 'none';");
```

### Cross-Site Request Forgery (CSRF)

**CSRF Tokens (Antiforgery):**
```csharp
// Program.cs
services.AddAntiforgery(options => options.HeaderName = "X-CSRF-TOKEN");

// Controller
[ValidateAntiForgeryToken]
[HttpPost]
public IActionResult SubmitForm() { /* ... */ }
```

**SameSite Cookies:**
```csharp
services.ConfigureApplicationCookie(options =>
{
    options.Cookie.SameSite = SameSiteMode.Strict;
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
});
```

### File Upload Security

**Validation:**
```csharp
public async Task<IActionResult> UploadFile(IFormFile file)
{
    // Validate file size (10 MB max)
    if (file.Length > 10 * 1024 * 1024)
        return BadRequest("File too large");

    // Validate file extension
    var allowedExtensions = new[] { ".jpg", ".png", ".pdf" };
    var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
    if (!allowedExtensions.Contains(extension))
        return BadRequest("Invalid file type");

    // Validate MIME type (don't trust extension)
    if (!file.ContentType.StartsWith("image/") && file.ContentType != "application/pdf")
        return BadRequest("Invalid content type");

    // Generate random filename (don't use user-provided name)
    var safeFilename = $"{Guid.NewGuid()}{extension}";
    var path = Path.Combine(_uploadsPath, safeFilename);

    // Save file
    using var stream = new FileStream(path, FileMode.Create);
    await file.CopyToAsync(stream);

    return Ok(new { filename = safeFilename });
}
```

---

## Security Testing

### Manual Testing Checklist

**Authentication:**
- [ ] Try accessing protected endpoints without JWT
- [ ] Try using expired JWT
- [ ] Try using JWT for different user
- [ ] Try brute-force login (should be rate limited)

**Authorization:**
- [ ] Try accessing another user's brand
- [ ] Try modifying another user's data
- [ ] Try admin endpoints as regular user

**Injection:**
- [ ] Try SQL injection in search fields (`'; DROP TABLE Users--`)
- [ ] Try XSS in text fields (`<script>alert(1)</script>`)
- [ ] Try path traversal in file uploads (`../../etc/passwd`)

**Encryption:**
- [ ] Verify HTTPS is enforced (try HTTP)
- [ ] Check TLS version (should be 1.2+)
- [ ] Verify passwords are hashed (check database)

### Automated Security Scanning

**OWASP ZAP:**
```bash
# Install OWASP ZAP
# Run automated scan
zap-cli quick-scan --self-contained https://staging.brand2boost.com
```

**npm audit (Frontend):**
```bash
cd ClientManagerFrontend
npm audit --audit-level=moderate
```

**Snyk (Vulnerability Scanning):**
```bash
# Install Snyk CLI
npm install -g snyk

# Scan dependencies
snyk test
```

---

## Incident Response Plan

**If a security breach is detected:**

1. **Contain:** Immediately disable compromised accounts
2. **Investigate:** Review logs to determine scope
3. **Notify:** Inform affected users within 72 hours (GDPR)
4. **Remediate:** Fix vulnerability
5. **Document:** Write incident report
6. **Review:** Update security checklist

**Contacts:**
- Security Lead: [Name]
- Legal: [Name]
- GDPR Officer: [Name]

---

## Security Training

**All developers must:**
- Complete OWASP Top 10 training annually
- Review this checklist before every deploy
- Report vulnerabilities to security team
- Never commit secrets to Git

---

## Related Documentation

- [MULTI_ENVIRONMENT_CONFIGURATION.md](./MULTI_ENVIRONMENT_CONFIGURATION.md) - Secrets management
- [ADR-008: JWT Authentication](./ADR/008-jwt-authentication.md)
- [ADR-004: Multi-Tenant Architecture](./ADR/004-multi-tenant-architecture.md)
- OWASP Top 10: https://owasp.org/Top10/
- CWE Top 25: https://cwe.mitre.org/top25/

---

**Last Updated:** 2026-01-08
**Security Review Frequency:** Quarterly
**Next Review:** 2026-04-01
**Maintained by:** Security Team
