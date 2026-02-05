# ADR-004: Multi-Tenant SaaS Architecture

**Status:** Accepted
**Date:** 2024-05-15
**Decision Makers:** Architecture Team, Product Lead

## Context

Brand2Boost is a multi-tenant SaaS platform where multiple users (tenants) share the same application instance. We needed to decide:
- **Data isolation strategy** - How to separate tenant data?
- **Security model** - Prevent cross-tenant data leaks?
- **Scalability** - How to scale as tenants grow?
- **Cost efficiency** - Minimize infrastructure per tenant?

**Tenancy levels:**
1. **User** - Individual person with account
2. **Brand** - A brand owned by user (future: shared brands)
3. **Organization** - Multiple users under one billing entity (Enterprise, future)

## Decision

**Shared Database with Row-Level Tenancy** (Most Common SaaS Pattern)

**Architecture:**
- Single database instance (PostgreSQL)
- Single application instance (ASP.NET Core API)
- Tenant ID (`UserId`) in every row
- Application-level data filtering
- JWT contains tenant ID (UserId)
- Every query filters by `UserId`

**Example:**
```sql
-- Every table has UserId column
SELECT * FROM Brands WHERE UserId = 'current-user-id';
SELECT * FROM ChatMessages WHERE UserId = 'current-user-id';
```

**Enforcement:**
- Entity Framework query filters (automatic)
- Middleware extracts UserId from JWT
- All queries scoped to current user

## Consequences

### Positive
✅ **Cost Efficient**
- Single database for all tenants
- Minimize infrastructure costs
- Easy to start (no per-tenant provisioning)

✅ **Simple Deployment**
- One application instance
- One database
- Standard Azure App Service

✅ **Easy Maintenance**
- Single schema to update
- Migrations apply to all tenants at once
- No complex orchestration

✅ **Resource Sharing**
- Database connection pooling
- Cache sharing
- CPU/memory shared across tenants

✅ **Fast Onboarding**
- New user = new rows in shared tables
- No database provisioning
- Instant signup

### Negative
❌ **Data Isolation Risk**
- Bug in query filter = data leak across tenants
- Must be extremely careful with queries
- Higher security risk than separate databases

❌ **Noisy Neighbor Problem**
- One tenant's heavy usage impacts others
- Can't isolate resource consumption per tenant
- Need rate limiting and quotas

❌ **Scalability Ceiling**
- Single database has limits (even PostgreSQL)
- Eventually need sharding
- Can't scale one tenant independently

❌ **Backup/Restore Complexity**
- Can't restore just one tenant's data
- All-or-nothing backup
- Tenant-specific restore requires manual filtering

### Neutral
⚪ **Performance**
- Queries need `WHERE UserId = ...` filter (slight overhead)
- But: Index on UserId makes this fast
- Acceptable trade-off

## Alternatives Considered

### Option A: Separate Database Per Tenant
**How it works:**
- Each user gets own PostgreSQL database
- Connection string routing based on user

**Pros:**
- Perfect data isolation
- Can scale tenants independently
- Easy per-tenant backup/restore
- No noisy neighbor

**Cons:**
- **High cost** (database per user = $$$)
- Complex provisioning (create DB on signup)
- Migration hell (migrate 1000s of databases)
- Connection pool explosion

**Why rejected:** Too expensive. Not feasible for $29/month subscriptions.

### Option B: Separate Schema Per Tenant
**How it works:**
- One database, multiple schemas (one per tenant)
- `tenant_001.Brands`, `tenant_002.Brands`

**Pros:**
- Better isolation than shared schema
- Single database instance
- Per-tenant migrations possible

**Cons:**
- PostgreSQL schema switching has performance cost
- Still complex to manage 1000s of schemas
- Backup/restore still complex
- Not standard EF Core pattern

**Why rejected:** Middle ground that's complex without enough benefit.

### Option C: Completely Separate Instances (Infrastructure per Tenant)
**How it works:**
- Each tenant gets own App Service + Database

**Pros:**
- Ultimate isolation
- Can customize per tenant (white-labeling)
- Independent scaling

**Cons:**
- **Extremely expensive** (App Service per tenant)
- Not SaaS, closer to managed hosting
- Maintenance nightmare (update 1000s of instances)

**Why rejected:** Not economically viable for SaaS business model.

### Option D: Hybrid (Shared for Small, Dedicated for Enterprise)
**How it works:**
- Free/Pro: Shared database
- Enterprise: Dedicated database (optional)

**Pros:**
- Flexibility
- Upsell path (dedicated instance)
- Cost-effective for most users

**Cons:**
- Two codebases to maintain
- Complexity in routing
- Not needed yet (premature optimization)

**Why rejected:** Not needed at current scale. Can migrate later.

## Implementation Details

### Database Schema

**Every table has UserId:**
```sql
CREATE TABLE Brands (
    Id UUID PRIMARY KEY,
    UserId UUID NOT NULL REFERENCES AspNetUsers(Id),
    Name VARCHAR(255),
    Description TEXT,
    CreatedAt TIMESTAMP
);

CREATE INDEX IX_Brands_UserId ON Brands(UserId);

CREATE TABLE ChatMessages (
    Id UUID PRIMARY KEY,
    UserId UUID NOT NULL REFERENCES AspNetUsers(Id),
    BrandId UUID REFERENCES Brands(Id),
    Message TEXT,
    CreatedAt TIMESTAMP
);

CREATE INDEX IX_ChatMessages_UserId ON ChatMessages(UserId);
```

### Entity Framework Query Filters

**Global Filter (Applied to All Queries):**
```csharp
public class AppDbContext : DbContext
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    protected override void OnModelCreating(ModelBuilder builder)
    {
        // Get current user ID from JWT
        var currentUserId = _httpContextAccessor.HttpContext?.User
            .FindFirst(ClaimTypes.NameIdentifier)?.Value;

        // Apply filter to all entities with UserId
        builder.Entity<Brand>()
            .HasQueryFilter(b => b.UserId == currentUserId);

        builder.Entity<ChatMessage>()
            .HasQueryFilter(m => m.UserId == currentUserId);

        // ... apply to all tenant-scoped entities
    }
}
```

**Result:**
```csharp
// This query AUTOMATICALLY includes WHERE UserId = current-user
var brands = await _db.Brands.ToListAsync();

// Equivalent to:
// SELECT * FROM Brands WHERE UserId = 'abc-123';
```

### Bypassing Filter (Admin Use Case)

```csharp
// Remove query filter for admin queries
var allBrands = await _db.Brands
    .IgnoreQueryFilters()
    .ToListAsync();
```

### Tenant Context Service

```csharp
public interface ITenantContext
{
    string UserId { get; }
    bool IsAuthenticated { get; }
}

public class TenantContext : ITenantContext
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public string UserId =>
        _httpContextAccessor.HttpContext?.User
            .FindFirst(ClaimTypes.NameIdentifier)?.Value ?? string.Empty;

    public bool IsAuthenticated =>
        _httpContextAccessor.HttpContext?.User?.Identity?.IsAuthenticated ?? false;
}
```

### Middleware for Tenant Extraction

```csharp
public class TenantMiddleware
{
    public async Task InvokeAsync(HttpContext context, ITenantContext tenantContext)
    {
        // Extract tenant from JWT or header
        var userId = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userId))
        {
            context.Response.StatusCode = 401;
            await context.Response.WriteAsync("Unauthorized");
            return;
        }

        // Tenant context is now available in services
        await _next(context);
    }
}
```

## Security Best Practices

### 1. Always Filter by UserId
**Never trust client input for UserId!**

❌ **WRONG:**
```csharp
// Client sends userId in request body - NEVER DO THIS
var brand = await _db.Brands.FindAsync(request.BrandId);
```

✅ **CORRECT:**
```csharp
// Extract userId from authenticated JWT
var userId = User.FindFirst(ClaimTypes.NameIdentifier).Value;
var brand = await _db.Brands
    .Where(b => b.UserId == userId && b.Id == request.BrandId)
    .FirstOrDefaultAsync();
```

### 2. Test Cross-Tenant Isolation

```csharp
[Fact]
public async Task User_Cannot_Access_Other_Users_Brand()
{
    // Setup: Create brands for two users
    var user1Brand = CreateBrand(userId: "user-1");
    var user2Brand = CreateBrand(userId: "user-2");

    // Login as user-1
    AuthenticateAs("user-1");

    // Try to access user-2's brand
    var result = await _controller.GetBrand(user2Brand.Id);

    // Should return NotFound (not Unauthorized to avoid info leak)
    Assert.IsType<NotFoundResult>(result);
}
```

### 3. Audit Logging

Log all data access with tenant ID:
```csharp
_logger.LogInformation(
    "User {UserId} accessed Brand {BrandId}",
    currentUserId,
    brandId
);
```

### 4. Rate Limiting Per Tenant

```csharp
[RateLimit(MaxRequests = 100, PerSeconds = 60, Scope = RateLimitScope.User)]
public IActionResult GetBrands() { /* ... */ }
```

## Scaling Strategy

### Current: Single Database (0-10K users)
- Shared PostgreSQL instance
- Connection pooling
- Vertical scaling (bigger VM)

### Future: Sharding (10K-100K users)
**Shard by UserId:**
- Database 1: Users A-M
- Database 2: Users N-Z
- Routing layer determines database

**Implementation:**
```csharp
public class ShardedDbContext : DbContext
{
    protected override void OnConfiguring(DbContextOptionsBuilder options)
    {
        var shard = GetShardForUser(_currentUserId);
        var connectionString = _config[$"ConnectionStrings:Shard{shard}"];
        options.UseNpgsql(connectionString);
    }

    private int GetShardForUser(string userId)
    {
        // Hash user ID to determine shard
        return Math.Abs(userId.GetHashCode()) % _totalShards;
    }
}
```

### Far Future: Hybrid Model (100K+ users)
- Most tenants: Shared database
- Enterprise tenants: Dedicated database
- Dynamic routing based on subscription tier

## Monitoring

**Track per tenant:**
- API request count
- Database query count
- Token usage
- Storage usage
- Error rate

**Alerts:**
- Tenant exceeding quotas
- Abnormal usage patterns (potential abuse)
- Cross-tenant access attempts (security issue)

## Migration Path

If we outgrow shared database:

**Step 1: Identify Large Tenants**
- Query for users with >X brands, >Y messages

**Step 2: Migrate to Dedicated Database**
- Export tenant data
- Create dedicated database
- Update connection routing
- Migrate tenant

**Step 3: Gradual Migration**
- Migrate 1 tenant at a time
- Validate data integrity
- No downtime for other tenants

## References

- Multi-Tenancy Patterns: https://docs.microsoft.com/en-us/azure/architecture/guide/multitenant/overview
- EF Core Query Filters: https://docs.microsoft.com/en-us/ef/core/querying/filters
- SaaS Architecture: https://aws.amazon.com/solutions/saas/

---

**Review Date:** 2026-01-01 (Yearly review)
**Related ADRs:**
- ADR-002: SQLite Dev / PostgreSQL Prod
- ADR-006: Entity Framework Core as ORM
- ADR-008: JWT Authentication Strategy
