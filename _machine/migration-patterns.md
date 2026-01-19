# EF Core Migration Patterns - Safe Schema Evolution

**Purpose:** Reference guide for AI agents and developers on safe migration patterns.

**Core Principle:** Breaking changes require multi-step migrations with deployment coordination.

---

## 🚨 Anti-Patterns (NEVER DO THIS)

### ❌ Implicit Table Names (Relying on EF Core Conventions)

**Incident:** EFCORE-TABLENAMING-20260119 ([Details](./ef-core-table-naming-incident.md))

```csharp
// WRONG - Implicit table name, relies on EF Core conventions
builder.Entity<Project>(entity =>
{
    entity.HasKey(e => e.Id);
    entity.HasIndex(e => e.CreatedAt);
    // MISSING: entity.ToTable("ProjectsDb");
});

// Migration creates table: "ProjectsDb"
// EF Core assumes table: "Projects" (pluralized entity name)
// RESULT: Mismatch → "SQLite Error: no such table Projects"
```

**Why it fails:**
- EF Core uses pluralization conventions (Project → Projects)
- Migrations can create tables with custom names
- DbContext doesn't "remember" custom names from migrations
- Future migrations use default convention names
- Application crashes with "table not found" errors

**Correct approach:**
```csharp
// ALWAYS use explicit table name
builder.Entity<Project>(entity =>
{
    entity.ToTable("ProjectsDb");  // ← REQUIRED, even if matches convention
    entity.HasKey(e => e.Id);
    entity.HasIndex(e => e.CreatedAt);
});
```

**Prevention:**
- ✅ **MANDATORY:** ALL entities must have `.ToTable("TableName")`
- ✅ Run `audit-dbcontext-table-names.ps1` before creating migrations
- ✅ Verify DbContext table names match actual database schema
- ✅ Never assume EF Core conventions will remain stable

**Impact:** Complete application failure, migration errors, data access crashes

---

### ❌ Single-Step Column Rename
```csharp
// WRONG - Breaks existing code immediately
migrationBuilder.RenameColumn(
    name: "OldName",
    table: "Users",
    newName: "NewName");
```

**Why it fails:**
- Existing code expects `OldName` column
- Moment migration runs, all queries fail
- No graceful transition period

### ❌ Drop Column Without Data Migration
```csharp
// WRONG - Data loss without backup
migrationBuilder.DropColumn(
    name: "LegacyEmail",
    table: "Users");
```

**Why it fails:**
- Data permanently deleted
- No opportunity to migrate data to new structure
- Cannot rollback if mistake discovered

### ❌ Add NOT NULL to Existing Column
```csharp
// WRONG - Fails if any existing rows have NULL
migrationBuilder.AlterColumn<string>(
    name: "Email",
    table: "Users",
    nullable: false);  // ← Will fail if NULLs exist
```

**Why it fails:**
- Database rejects constraint if NULL values exist
- Migration fails halfway
- Database left in inconsistent state

---

## ✅ Safe Patterns

### Pattern 1: Column Rename (3-Step Migration)

**Scenario:** Rename `Users.OldEmail` → `Users.Email`

#### Migration 1: Add New Column
```csharp
// 20260119120000_AddEmailColumn.cs
protected override void Up(MigrationBuilder migrationBuilder)
{
    migrationBuilder.AddColumn<string>(
        name: "Email",
        table: "Users",
        nullable: true);

    // Backfill data from old column
    migrationBuilder.Sql(@"
        UPDATE Users
        SET Email = OldEmail
        WHERE Email IS NULL
    ");
}
```

**Deploy:** Code that reads/writes to BOTH columns

```csharp
// Transition period: support both columns
public class User
{
    public string OldEmail { get; set; }  // Keep temporarily
    public string Email { get; set; }      // New column

    public void SetEmail(string email)
    {
        Email = email;
        OldEmail = email;  // Write to both during transition
    }
}
```

#### Migration 2: Drop Old Column (After Validation)
```csharp
// 20260126120000_DropOldEmailColumn.cs (1 week later)
protected override void Up(MigrationBuilder migrationBuilder)
{
    // Safe to drop - all code now uses Email column
    migrationBuilder.DropColumn(
        name: "OldEmail",
        table: "Users");
}
```

**Timeline:**
1. Deploy Migration 1 + dual-column code
2. Validate in production for 1 week
3. Deploy Migration 2 (remove OldEmail)
4. Clean up dual-column code

---

### Pattern 2: Add NOT NULL Constraint (2-Step Migration)

**Scenario:** Make `Users.Email` required (NOT NULL)

#### Migration 1: Backfill NULL Values
```csharp
// 20260119120000_BackfillNullEmails.cs
protected override void Up(MigrationBuilder migrationBuilder)
{
    // Strategy depends on business logic:
    // Option A: Set default value
    migrationBuilder.Sql(@"
        UPDATE Users
        SET Email = CONCAT('user', Id, '@placeholder.com')
        WHERE Email IS NULL
    ");

    // Option B: Delete invalid rows (if acceptable)
    migrationBuilder.Sql(@"
        DELETE FROM Users WHERE Email IS NULL
    ");
}
```

#### Migration 2: Add NOT NULL Constraint
```csharp
// 20260119130000_MakeEmailRequired.cs (run immediately after validation)
protected override void Up(MigrationBuilder migrationBuilder)
{
    migrationBuilder.AlterColumn<string>(
        name: "Email",
        table: "Users",
        nullable: false);  // Safe now - no NULLs exist
}
```

---

### Pattern 3: Table Rename (Avoid If Possible)

**Scenario:** Rename `OldUsers` → `Users`

**Best approach:** Don't rename - create new table and migrate

#### Migration 1: Create New Table
```csharp
migrationBuilder.CreateTable(
    name: "Users",
    columns: table => new
    {
        Id = table.Column<int>(nullable: false)
            .Annotation("SqlServer:Identity", "1, 1"),
        Email = table.Column<string>(nullable: false),
        // ... other columns
    });

// Copy data
migrationBuilder.Sql(@"
    INSERT INTO Users (Email, CreatedAt, ...)
    SELECT Email, CreatedAt, ...
    FROM OldUsers
");
```

#### Deploy: Dual-Write Period
```csharp
// Write to both tables during transition
public void CreateUser(User user)
{
    _context.Users.Add(user);
    _context.OldUsers.Add(MapToOldUser(user));  // Temporary
    _context.SaveChanges();
}
```

#### Migration 2: Drop Old Table (After Validation)
```csharp
migrationBuilder.DropTable(name: "OldUsers");
```

---

### Pattern 4: Foreign Key Changes (3-Step Migration)

**Scenario:** Change `Orders.UserId` FK from `int` → `Guid`

#### Migration 1: Add New Column
```csharp
migrationBuilder.AddColumn<Guid>(
    name: "UserGuid",
    table: "Orders",
    nullable: true);

// Backfill: lookup User Guid from User table
migrationBuilder.Sql(@"
    UPDATE o
    SET o.UserGuid = u.Guid
    FROM Orders o
    INNER JOIN Users u ON o.UserId = u.Id
");

// Add FK constraint
migrationBuilder.AddForeignKey(
    name: "FK_Orders_Users_UserGuid",
    table: "Orders",
    column: "UserGuid",
    principalTable: "Users",
    principalColumn: "Guid");
```

#### Deploy: Dual-Column Code
```csharp
public class Order
{
    public int UserId { get; set; }      // Old FK (keep temporarily)
    public Guid? UserGuid { get; set; }  // New FK

    // Use UserGuid preferentially
    public User GetUser(DbContext db)
    {
        return UserGuid.HasValue
            ? db.Users.Find(UserGuid.Value)
            : db.Users.Find(UserId);
    }
}
```

#### Migration 2: Make New Column Required
```csharp
migrationBuilder.AlterColumn<Guid>(
    name: "UserGuid",
    table: "Orders",
    nullable: false);  // Safe - all rows backfilled
```

#### Migration 3: Drop Old Column
```csharp
migrationBuilder.DropForeignKey(
    name: "FK_Orders_Users_UserId",
    table: "Orders");

migrationBuilder.DropColumn(
    name: "UserId",
    table: "Orders");
```

---

## 🔍 Pattern Selection Decision Tree

```
Is the change breaking? (affects existing queries/code)
├─ NO → Single migration OK
│  └─ Examples: Add column, add index, add table
│
└─ YES → Multi-step migration required
   ├─ Column rename? → 3-step (add + backfill + drop)
   ├─ Drop column? → 2-step (migrate data + drop)
   ├─ NOT NULL constraint? → 2-step (backfill + alter)
   ├─ Type change? → 3-step (add + migrate + drop)
   └─ FK change? → 3-step (add + backfill + drop)
```

---

## 📋 Pre-Migration Checklist

Before creating migration:
- [ ] Read current schema: `dotnet ef dbcontext script`
- [ ] Check for pending migrations: `dotnet ef migrations list`
- [ ] Identify breaking changes
- [ ] Determine if multi-step migration needed
- [ ] Plan deployment sequence
- [ ] Prepare rollback strategy

Before applying migration:
- [ ] Run `ef-preflight-check.ps1`
- [ ] Run `ef-migration-preview.ps1`
- [ ] Test on production-clone database
- [ ] Generate rollback script
- [ ] Backup production database
- [ ] Schedule deployment window (if locking operations)

---

## 🚀 Example: Complete Multi-Step Migration

**Goal:** Rename `DailyLimit` → `MonthlyLimit` (breaking change)

### Step 1: Create First Migration
```bash
# Pre-flight check
.\ef-preflight-check.ps1 -Context AppDbContext -ProjectPath .

# Create migration
dotnet ef migrations add AddMonthlyLimitColumn --context AppDbContext
```

```csharp
// 20260119120000_AddMonthlyLimitColumn.cs
protected override void Up(MigrationBuilder migrationBuilder)
{
    migrationBuilder.AddColumn<decimal>(
        name: "MonthlyLimit",
        table: "Accounts",
        nullable: true);

    // Backfill: convert daily to monthly (daily * 30)
    migrationBuilder.Sql(@"
        UPDATE Accounts
        SET MonthlyLimit = DailyLimit * 30
        WHERE MonthlyLimit IS NULL
    ");
}

protected override void Down(MigrationBuilder migrationBuilder)
{
    migrationBuilder.DropColumn(
        name: "MonthlyLimit",
        table: "Accounts");
}
```

**Preview:**
```bash
.\ef-migration-preview.ps1 -Migration AddMonthlyLimitColumn -Context AppDbContext -GenerateRollback
```

**Apply:**
```bash
dotnet ef database update --context AppDbContext
```

### Step 2: Deploy Dual-Column Code
```csharp
public class Account
{
    public decimal DailyLimit { get; set; }    // Old (keep for now)
    public decimal? MonthlyLimit { get; set; } // New

    public decimal GetEffectiveLimit()
    {
        // Prefer new column, fallback to old
        return MonthlyLimit ?? (DailyLimit * 30);
    }

    public void SetLimit(decimal monthlyLimit)
    {
        MonthlyLimit = monthlyLimit;
        DailyLimit = monthlyLimit / 30;  // Keep in sync during transition
    }
}
```

**Validate in production for 1 week**

### Step 3: Make New Column Required
```bash
dotnet ef migrations add MakeMonthlyLimitRequired --context AppDbContext
```

```csharp
// 20260126120000_MakeMonthlyLimitRequired.cs
protected override void Up(MigrationBuilder migrationBuilder)
{
    // Safe - all rows have values
    migrationBuilder.AlterColumn<decimal>(
        name: "MonthlyLimit",
        table: "Accounts",
        nullable: false);
}
```

### Step 4: Drop Old Column
```bash
dotnet ef migrations add DropDailyLimitColumn --context AppDbContext
```

```csharp
// 20260202120000_DropDailyLimitColumn.cs
protected override void Up(MigrationBuilder migrationBuilder)
{
    migrationBuilder.DropColumn(
        name: "DailyLimit",
        table: "Accounts");
}
```

### Step 5: Clean Up Code
```csharp
public class Account
{
    public decimal MonthlyLimit { get; set; }  // Now single source of truth

    public decimal GetEffectiveLimit()
    {
        return MonthlyLimit;  // Simple now
    }
}
```

---

## 🎯 Key Takeaways

1. **Breaking changes = Multi-step migrations** (no exceptions)
2. **Always backfill data before constraints**
3. **Deploy code that handles both old and new schema**
4. **Validate in production before dropping old columns**
5. **Generate rollback scripts before applying**
6. **Test on production-clone database first**

---

**For AI Agents:**
- Read this file BEFORE creating migrations
- Match your scenario to a pattern above
- Follow the pattern exactly - don't improvise
- When in doubt, use multi-step approach
- ALWAYS run ef-preflight-check.ps1 first

**Last Updated:** 2026-01-19
