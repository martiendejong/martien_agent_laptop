# Data Migration Strategy 🔄

**Purpose:** Safely evolve database schema without breaking production or losing data.

**Goal:** Zero-downtime deployments, backward compatibility, and safe rollback.

---

## Quick Reference

**Adding a new optional field:**
```bash
# 1. Add property to entity
# 2. Generate migration
dotnet ef migrations add AddDescriptionToBrand

# 3. Test on staging
dotnet ef database update --connection "staging-connection"

# 4. Deploy to production (auto-applies migration)
```

**Removing a field (2-step process):**
```bash
# Step 1: Stop using field in code, deploy, wait 24 hours
# Step 2: Drop column, deploy
dotnet ef migrations add RemoveUnusedColumn
```

---

## Migration Principles

### 1. Backward Compatibility

**Always deploy database changes BEFORE code changes.**

**Deployment order:**
```
1. Database migration (new schema)
2. Application deployment (new code)
```

**Why?** If code expects new column but column doesn't exist → crash.

**Example:**
```csharp
// ❌ WRONG ORDER:
// 1. Deploy code (expects Brand.Description)
// 2. Apply migration (adds Description column)
// → Code crashes between step 1 and 2!

// ✅ CORRECT ORDER:
// 1. Apply migration (adds Description column)
// 2. Deploy code (uses Description)
// → Code still works with or without new column
```

### 2. Non-Breaking Changes Only

**Safe (additive):**
✅ Add new table
✅ Add new optional column (`nullable` or with `default value`)
✅ Add new index
✅ Increase column size (VARCHAR(50) → VARCHAR(100))

**Unsafe (destructive):**
❌ Drop table
❌ Drop column
❌ Rename column (without backward compat)
❌ Change column type
❌ Add required column (without default)
❌ Decrease column size

### 3. Expand-Contract Pattern

**For breaking changes, use 2-phase deployment:**

**Phase 1: Expand** (additive changes)
- Add new column alongside old column
- Dual-write to both columns
- Deploy code that uses new column

**Phase 2: Contract** (remove old column)
- Stop using old column in code
- Deploy code
- Wait 24-48 hours (ensure rollback possible)
- Drop old column
- Deploy again

---

## Entity Framework Migrations

### Creating a Migration

**1. Add property to entity**

```csharp
// Models/Brand.cs
public class Brand
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;

    // NEW: Add description
    public string? Description { get; set; }  // Nullable = optional
}
```

**2. Generate migration**

```bash
cd ClientManagerAPI
dotnet ef migrations add AddDescriptionToBrand
```

**3. Review generated migration**

```csharp
// Migrations/20260108_AddDescriptionToBrand.cs
public partial class AddDescriptionToBrand : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "Description",
            table: "Brands",
            type: "text",
            nullable: true);  // ✅ Good: Nullable
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "Description",
            table: "Brands");
    }
}
```

**4. Test locally**

```bash
# Apply migration
dotnet ef database update

# Verify schema
sqlite3 C:\stores\brand2boost\identity.db ".schema Brands"

# Test app still works
dotnet run
```

**5. Commit migration**

```bash
git add Migrations/20260108_AddDescriptionToBrand.cs
git add Models/Brand.cs
git commit -m "feat: add Description to Brand entity"
```

### Applying Migration (Staging)

**Option A: Manual (Recommended for First Time)**

```bash
# Get connection string from Azure
az keyvault secret show \
  --vault-name brand2boost-kv \
  --name PostgreSQL-ConnectionString \
  --query value -o tsv

# Apply migration
dotnet ef database update \
  --connection "Host=...;Database=brand2boost_staging;..."
```

**Option B: Automatic (CI/CD Pipeline)**

`.github/workflows/deploy-staging.yml`:
```yaml
- name: Run Database Migrations
  run: |
    cd ClientManagerAPI
    dotnet ef database update \
      --connection "${{ secrets.STAGING_DB_CONNECTION }}"
```

### Applying Migration (Production)

**⚠️ NEVER run migrations directly on production!**

**Correct process:**

1. **Test on staging first**
   - Apply migration to staging
   - Run full test suite
   - Manual QA testing
   - Leave running for 24 hours

2. **Schedule maintenance window** (optional)
   - For large tables (>1M rows)
   - For schema changes that lock tables
   - Otherwise: migrations are usually fast (<1 second)

3. **Apply via CI/CD with approval**
   ```yaml
   jobs:
     migrate-production:
       environment: production  # Requires manual approval
       steps:
         - name: Run Migrations
           run: |
             dotnet ef database update \
               --connection "${{ secrets.PROD_DB_CONNECTION }}"
   ```

4. **Monitor for errors**
   - Check Application Insights
   - Check error rate
   - Be ready to rollback

---

## Common Migration Scenarios

### Scenario 1: Add Optional Column

**Example:** Add `Description` to `Brand`

```csharp
// 1. Add property (nullable)
public string? Description { get; set; }

// 2. Generate migration
dotnet ef migrations add AddDescriptionToBrand

// 3. Migration code (auto-generated)
migrationBuilder.AddColumn<string>(
    name: "Description",
    table: "Brands",
    nullable: true);  // ✅ Safe: existing rows get NULL
```

**Deployment:**
- Apply migration → Deploy code ✅
- No downtime needed

---

### Scenario 2: Add Required Column with Default

**Example:** Add `CreatedAt` to `Brand` (required)

```csharp
// 1. Add property (non-nullable)
public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

// 2. Generate migration
dotnet ef migrations add AddCreatedAtToBrand

// 3. Edit migration to add default value
protected override void Up(MigrationBuilder migrationBuilder)
{
    migrationBuilder.AddColumn<DateTime>(
        name: "CreatedAt",
        table: "Brands",
        type: "timestamp with time zone",
        nullable: false,
        defaultValueSql: "CURRENT_TIMESTAMP");  // ✅ Default for existing rows
}
```

**Deployment:**
- Apply migration → Deploy code ✅
- Existing rows get current timestamp as default

---

### Scenario 3: Rename Column (Backward Compatible)

**Example:** Rename `Name` to `BrandName`

**⚠️ Two-phase deployment:**

**Phase 1: Add new column, dual-write**

```csharp
// Add new property alongside old
public string Name { get; set; } = string.Empty;  // OLD
public string BrandName { get; set; } = string.Empty;  // NEW

// Migration
migrationBuilder.AddColumn<string>("BrandName", "Brands", nullable: true);
migrationBuilder.Sql("UPDATE Brands SET BrandName = Name");  // Copy data

// Code: Write to both columns
brand.Name = value;
brand.BrandName = value;

// Code: Read from new column
var name = brand.BrandName ?? brand.Name;  // Fallback for old rows
```

**Deploy Phase 1** → Wait 24-48 hours

**Phase 2: Remove old column**

```csharp
// Remove old property
// public string Name { get; set; }  ← DELETE THIS

// Migration
migrationBuilder.DropColumn("Name", "Brands");

// Code: Only use BrandName now
var name = brand.BrandName;
```

**Deploy Phase 2**

---

### Scenario 4: Change Column Type

**Example:** Change `TokenBalance` from `int` to `long`

**⚠️ Two-phase deployment:**

**Phase 1: Add new column**

```csharp
// Add new property
public int TokenBalance { get; set; }  // OLD
public long TokenBalanceLong { get; set; }  // NEW

// Migration
migrationBuilder.AddColumn<long>("TokenBalanceLong", "Users", nullable: false, defaultValue: 0L);
migrationBuilder.Sql("UPDATE Users SET TokenBalanceLong = TokenBalance");

// Code: Dual-write
user.TokenBalance = (int)value;
user.TokenBalanceLong = value;
```

**Deploy Phase 1** → Wait 24-48 hours

**Phase 2: Remove old column**

```csharp
// Rename property
public long TokenBalance { get; set; }  // Renamed from TokenBalanceLong

// Migration
migrationBuilder.DropColumn("TokenBalance", "Users");
migrationBuilder.RenameColumn("TokenBalanceLong", "Users", "TokenBalance");
```

**Deploy Phase 2**

---

### Scenario 5: Add Foreign Key

**Example:** Add `UserId` foreign key to `ChatMessages`

```csharp
// 1. Add property
public Guid UserId { get; set; }
public User User { get; set; } = null!;

// 2. Generate migration
dotnet ef migrations add AddUserIdToChatMessages

// 3. Migration code
migrationBuilder.AddColumn<Guid>(
    name: "UserId",
    table: "ChatMessages",
    nullable: false,
    defaultValue: Guid.Empty);  // ⚠️ Needs manual data migration

migrationBuilder.AddForeignKey(
    name: "FK_ChatMessages_Users_UserId",
    table: "ChatMessages",
    column: "UserId",
    principalTable: "Users",
    principalColumn: "Id",
    onDelete: ReferentialAction.Cascade);

// 4. Add data migration
migrationBuilder.Sql(@"
    UPDATE ChatMessages
    SET UserId = (SELECT TOP 1 Id FROM Users WHERE Email = 'admin@brand2boost.com')
    WHERE UserId = '00000000-0000-0000-0000-000000000000'
");
```

---

### Scenario 6: Drop Table

**Example:** Remove `LegacyAuditLog` table

**⚠️ Three-phase deployment:**

**Phase 1: Stop writing to table**
- Remove all code that inserts/updates table
- Deploy code
- Wait 1 week (ensure no issues)

**Phase 2: Archive data** (optional)
```sql
-- Export to CSV or backup table
CREATE TABLE LegacyAuditLog_Archive AS SELECT * FROM LegacyAuditLog;
```

**Phase 3: Drop table**
```csharp
migrationBuilder.DropTable("LegacyAuditLog");
```

---

## Rollback Strategy

### Automatic Rollback (Undo Migration)

**If migration fails:**

```bash
# Rollback to previous migration
dotnet ef database update PreviousMigrationName

# Or rollback all migrations
dotnet ef database update 0
```

**Example:**
```bash
# Current migration: AddDescriptionToBrand
# Rollback to previous:
dotnet ef database update AddUserIdToBrand

# Check migration history
dotnet ef migrations list
```

### Rollback with Data Loss

**If migration dropped column/table:**

⚠️ **You CANNOT rollback without data loss!**

**Mitigation:**
1. **Always backup before migration:**
   ```bash
   # PostgreSQL backup
   pg_dump -h hostname -U username -d brand2boost > backup_20260108.sql
   ```

2. **Test on staging first**

3. **For critical changes, use phased deployment** (expand-contract)

---

## Data Migration (Moving Data)

### Simple Data Update

```csharp
// In migration
migrationBuilder.Sql(@"
    UPDATE Brands
    SET Description = 'Default description'
    WHERE Description IS NULL
");
```

### Complex Data Transformation

**Option A: SQL in migration**

```csharp
protected override void Up(MigrationBuilder migrationBuilder)
{
    // Add new column
    migrationBuilder.AddColumn<string>("FullName", "Users", nullable: true);

    // Populate from existing data
    migrationBuilder.Sql(@"
        UPDATE Users
        SET FullName = CONCAT(FirstName, ' ', LastName)
        WHERE FullName IS NULL
    ");

    // Make non-nullable after populating
    migrationBuilder.AlterColumn<string>(
        name: "FullName",
        table: "Users",
        nullable: false);
}
```

**Option B: Background job (for large tables)**

```csharp
// Migration: Only add column
migrationBuilder.AddColumn<string>("FullName", "Users", nullable: true);

// Separate background job (Hangfire)
[AutomaticRetry(Attempts = 3)]
public async Task MigrateUserFullNames()
{
    var users = await _db.Users.Where(u => u.FullName == null).ToListAsync();

    foreach (var user in users)
    {
        user.FullName = $"{user.FirstName} {user.LastName}";
    }

    await _db.SaveChangesAsync();
}
```

---

## Testing Migrations

### Local Testing (SQLite)

```bash
# Apply migration
dotnet ef database update

# Test app
dotnet run

# Check schema
sqlite3 C:\stores\brand2boost\identity.db ".schema Brands"

# Rollback and retry
dotnet ef database update PreviousMigration
dotnet ef database update
```

### Staging Testing (PostgreSQL)

```bash
# Apply to staging
dotnet ef database update --connection "staging-connection"

# Run integration tests
dotnet test

# Manual QA testing
# Test CRUD operations on affected entities

# Leave running for 24 hours
# Monitor for errors in Application Insights
```

### Integration Tests

```csharp
[Fact]
public async Task Migration_AddDescriptionToBrand_Works()
{
    // Arrange: Start with old schema (before migration)
    await _db.Database.MigrateAsync("AddUserIdToBrand");  // Previous migration

    var brand = new Brand { Name = "Test" };
    _db.Brands.Add(brand);
    await _db.SaveChangesAsync();

    // Act: Apply new migration
    await _db.Database.MigrateAsync();  // Latest migration

    // Assert: Can access new column
    var updated = await _db.Brands.FindAsync(brand.Id);
    Assert.NotNull(updated.Description);  // New column exists
}
```

---

## SQLite vs PostgreSQL Migrations

### Conditional Migrations

**pgvector extension (PostgreSQL only):**

```csharp
protected override void Up(MigrationBuilder migrationBuilder)
{
    // Only for PostgreSQL (not SQLite)
    if (migrationBuilder.ActiveProvider == "Npgsql.EntityFrameworkCore.PostgreSQL")
    {
        migrationBuilder.AlterDatabase()
            .Annotation("Npgsql:PostgresExtension:vector", ",,");

        migrationBuilder.AddColumn<Vector>(
            name: "Embedding",
            table: "Brands",
            type: "vector(1536)",
            nullable: true);
    }
    else
    {
        // SQLite fallback (store as TEXT)
        migrationBuilder.AddColumn<string>(
            name: "Embedding",
            table: "Brands",
            type: "TEXT",
            nullable: true);
    }
}
```

### Full-Text Search (PostgreSQL only)

```csharp
if (migrationBuilder.ActiveProvider == "Npgsql.EntityFrameworkCore.PostgreSQL")
{
    migrationBuilder.Sql(@"
        CREATE INDEX idx_brands_name_fulltext
        ON Brands USING GIN(to_tsvector('english', Name))
    ");
}
```

---

## Migration Checklist

**Before creating migration:**
- [ ] Is this change backward compatible?
- [ ] Does it require 2-phase deployment?
- [ ] Will it lock tables? (for how long?)
- [ ] Is there a rollback plan?

**Before applying migration:**
- [ ] Tested on local SQLite
- [ ] Tested on staging PostgreSQL
- [ ] Integration tests pass
- [ ] Manual QA complete
- [ ] Database backup taken
- [ ] Team notified (if breaking change)

**After applying migration:**
- [ ] Monitor error rate (5 minutes)
- [ ] Check Application Insights
- [ ] Verify data looks correct
- [ ] Document in changelog

---

## Common Mistakes & Fixes

### Mistake #1: Required Column Without Default

```csharp
// ❌ WRONG: Breaks existing rows
migrationBuilder.AddColumn<DateTime>(
    name: "CreatedAt",
    nullable: false);  // ← Existing rows have no value!

// ✅ CORRECT: Add default
migrationBuilder.AddColumn<DateTime>(
    name: "CreatedAt",
    nullable: false,
    defaultValueSql: "CURRENT_TIMESTAMP");
```

### Mistake #2: Renaming Without Backward Compat

```csharp
// ❌ WRONG: One-step rename
migrationBuilder.RenameColumn("Name", "Brands", "BrandName");
// → Old code expects "Name", crashes!

// ✅ CORRECT: Two-phase (see Scenario 3 above)
```

### Mistake #3: Dropping Column With Data

```csharp
// ❌ WRONG: Data loss!
migrationBuilder.DropColumn("Description", "Brands");

// ✅ CORRECT: Archive first
migrationBuilder.Sql(@"
    UPDATE Brands SET Notes = CONCAT(Notes, ' | ', Description)
    WHERE Description IS NOT NULL
");
migrationBuilder.DropColumn("Description", "Brands");
```

---

## Tools

**Entity Framework CLI:**
```bash
dotnet ef migrations add MyMigration
dotnet ef migrations list
dotnet ef migrations remove  # Remove last migration (if not applied)
dotnet ef database update
dotnet ef database update MigrationName  # Rollback to specific migration
```

**Database Diff Tools:**
- [Flyway](https://flywaydb.org/) - Version control for databases
- [Liquibase](https://www.liquibase.org/) - Database change management
- [pgAdmin](https://www.pgadmin.org/) - PostgreSQL GUI (compare schemas)

---

## Related Documentation

- [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) - Current schema
- [MULTI_ENVIRONMENT_CONFIGURATION.md](./MULTI_ENVIRONMENT_CONFIGURATION.md) - Staging/prod setup
- [ADR-002: SQLite Dev / PostgreSQL Prod](./ADR/002-sqlite-dev-postgres-prod.md)
- [ADR-006: Entity Framework Core as ORM](./ADR/006-entity-framework-core.md) (future)

---

**Last Updated:** 2026-01-08
**Maintained by:** Backend Team
**Questions?** See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
