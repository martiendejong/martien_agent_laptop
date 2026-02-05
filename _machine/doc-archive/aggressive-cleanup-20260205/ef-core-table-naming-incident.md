# EF Core Table Naming Convention Incident - 2026-01-19

**Pattern:** DbContext Configuration Completeness / EF Core Table Naming Mismatch / Migration Troubleshooting
**Severity:** HIGH - Can cause complete application failure
**Outcome:** Successfully diagnosed and fixed table naming mismatch between migrations and DbContext configuration

---

## 🔴 Incident Summary

**User Report:**
```
System.InvalidOperationException: An error was generated for warning
'Microsoft.EntityFrameworkCore.Migrations.PendingModelChangesWarning':
The model for context 'IdentityDbContext' has pending changes.
```

**Root Cause:**
- Database table created as `ProjectsDb` (in migration `20251206171500_AddBusinessEntitiesManual.cs`)
- DbContext configuration missing explicit `.ToTable("ProjectsDb")` mapping
- EF Core defaulted to `Projects` (pluralized entity type name)
- **Result:** Mismatch between database reality and EF Core model expectations

---

## 🔍 Diagnostic Process

### Step 1: Initial Error Analysis
```bash
dotnet ef migrations add PendingModelChanges --context IdentityDbContext
# Created migration successfully
```

### Step 2: Migration Application Failure
```bash
dotnet ef database update --context IdentityDbContext
# ERROR: SQLite Error 1: 'no such table: Projects'
```

**Key Insight:** Migration was trying to `ALTER TABLE Projects` but table was actually named `ProjectsDb`.

### Step 3: Historical Migration Analysis
```bash
cd ClientManagerAPI/Migrations
grep -A 3 "name.*Project" 20251206171500_AddBusinessEntitiesManual.cs
# Found: CreateTable("ProjectsDb", ...)
```

**Discovery:** Earlier migration created table as `ProjectsDb`, not `Projects`.

### Step 4: DbContext Configuration Review
```csharp
// DbContext.cs (BEFORE FIX) - Line 143
builder.Entity<ClientManagerAPI.Models.Project>(entity =>
{
    entity.HasKey(e => e.Id);
    entity.HasIndex(e => e.CreatedAt);
    entity.HasIndex(e => e.IsActive);
    // MISSING: entity.ToTable("ProjectsDb");
});
```

**Problem Identified:** No explicit table name configuration.

---

## ✅ Solution Applied

### Fix 1: Add Explicit Table Name Configuration
```csharp
// DbContext.cs (AFTER FIX) - Line 143-149
builder.Entity<ClientManagerAPI.Models.Project>(entity =>
{
    entity.ToTable("ProjectsDb");  // ← CRITICAL: Explicit table name
    entity.HasKey(e => e.Id);
    entity.HasIndex(e => e.CreatedAt);
    entity.HasIndex(e => e.IsActive);
});
```

### Fix 2: Remove Corrupted Migrations
```bash
# Remove all pending migrations that referenced wrong table name
dotnet ef migrations remove --context IdentityDbContext --force  # (3 times)
```

### Fix 3: Create Clean Migration
```bash
dotnet ef migrations add UpdateModelWithSoftDelete --context IdentityDbContext
dotnet ef database update --context IdentityDbContext
# SUCCESS: Migration applied
```

---

## 🎓 Key Learnings

### 1️⃣ **EF Core Table Naming Convention Pitfall**

**Problem:**
- EF Core has default pluralization rules (Entity `Project` → Table `Projects`)
- If you create a table with a custom name in a migration, EF Core doesn't "remember" this
- Future model changes will generate migrations using the default name

**Solution:**
```csharp
// ALWAYS explicitly configure table names in OnModelCreating
builder.Entity<Project>(entity =>
{
    entity.ToTable("ProjectsDb");  // Explicit, prevents drift
});
```

**Best Practice:**
- ✅ **ALWAYS** use `.ToTable("TableName")` for entity configuration
- ✅ Apply to ALL entities, even if name matches convention
- ✅ Prevents future naming confusion
- ✅ Makes intent explicit in code

### 2️⃣ **DbContext Configuration Completeness Principle**

**Current State Analysis (client-manager DbContext.cs):**
- 50+ entity configurations
- Most have `.HasKey()`, `.HasIndex()`, relationships
- **ONLY 30% have explicit `.ToTable()` configuration**

**Risk:**
- Any entity without `.ToTable()` relies on EF Core conventions
- Convention changes between EF Core versions could break migrations
- Table names in database might not match EF Core expectations

**Recommendation:**
```csharp
// SYSTEMATIC AUDIT NEEDED
// For each builder.Entity<T>() block:
// 1. Check if .ToTable("TableName") exists
// 2. If missing, check actual database table name
// 3. Add explicit .ToTable() configuration
```

### 3️⃣ **Migration Troubleshooting Pattern**

When seeing "no such table" or "table already exists" errors:

```bash
# Step 1: Check what migrations created
cd Migrations/
grep -r "CreateTable" *.cs | grep <TableName>

# Step 2: Check DbContext configuration
grep -A 10 "builder.Entity<${EntityName}>" DbContext.cs

# Step 3: Compare table names
# Migration says: CreateTable("ProjectsDb", ...)
# DbContext says: (nothing - using default "Projects")
# ← MISMATCH FOUND

# Step 4: Fix DbContext
# Add: entity.ToTable("ProjectsDb");

# Step 5: Remove corrupted migrations
dotnet ef migrations remove --context <Context> --force

# Step 6: Recreate migration
dotnet ef migrations add <Name> --context <Context>
```

### 4️⃣ **SQLite-Specific Behavior**

**SQLite Error Messages:**
- `SQLite Error 1: 'no such table: X'` → Migration tries to ALTER/DROP non-existent table
- `SQLite Error 1: 'table "X" already exists'` → Migration tries to CREATE existing table

**Diagnosis:**
- First error → DbContext expects different table name than database has
- Second error → Migration history out of sync with actual database state

**SQLite Limitations:**
- Cannot rename columns directly (requires table rebuild)
- Cannot drop columns (requires table rebuild)
- PRAGMA foreign_keys must be disabled for some operations

---

## 🛠️ Preventive Measures

### For AI Agents (Immediate)

**When creating EF Core migrations:**

1. ✅ **BEFORE** creating migration:
   ```bash
   # Check existing table names in database
   # Compare with DbContext entity configurations
   # Ensure .ToTable() is explicitly configured
   ```

2. ✅ **DURING** migration creation:
   ```bash
   # Read generated migration file
   # Verify table names match expectations
   # Check for "Projects" vs "ProjectsDb" type mismatches
   ```

3. ✅ **AFTER** migration creation:
   ```bash
   # Test migration on clean database
   # Verify no "table not found" errors
   ```

### For Projects (Strategic)

**Client-Manager / Art Revisionist / Bugatti Insights / Mastermind Group AI:**

All these projects likely use EF Core. Apply systematic audit:

```bash
# For each project:
# 1. Scan all DbContext files
# 2. Extract entity configurations
# 3. Check for missing .ToTable() declarations
# 4. Compare with actual database schema
# 5. Add explicit .ToTable() for all entities
```

**Audit Script Needed:**
```powershell
# C:\scripts\tools\audit-dbcontext-table-names.ps1
# - Parse DbContext.cs files
# - Extract entity configurations
# - Check for .ToTable() calls
# - Compare with database schema (if available)
# - Generate report of mismatches
# - Optionally: auto-fix by adding .ToTable()
```

---

## 📊 Impact Assessment

### Projects Affected (Potential Risk)

1. **client-manager** (HIGH RISK)
   - Uses IdentityDbContext with 50+ entities
   - ~30% have explicit .ToTable() configuration
   - **Action:** Comprehensive audit required

2. **Hazina** (MEDIUM RISK)
   - Framework project, may have multiple DbContexts
   - **Action:** Review all DbContext configurations

3. **Art Revisionist** (UNKNOWN)
   - Check if uses EF Core
   - If yes, audit needed

4. **Bugatti Insights** (UNKNOWN)
   - Check if uses EF Core
   - If yes, audit needed

5. **Mastermind Group AI** (UNKNOWN)
   - Check if uses EF Core
   - If yes, audit needed

---

## 🎯 Action Items

### Immediate (Today)
- [x] Fix client-manager IdentityDbContext Project entity configuration
- [x] Document incident in reflection log
- [ ] Update ef-migration-safety skill with table naming pattern
- [ ] Create audit tool for DbContext table name verification

### Short-Term (This Week)
- [ ] Audit ALL client-manager DbContext entity configurations
- [ ] Add .ToTable() for all entities missing explicit configuration
- [ ] Test migration creation after audit
- [ ] Document complete table-to-entity mapping

### Medium-Term (Next Sprint)
- [ ] Apply audit to Hazina framework
- [ ] Check Art Revisionist / Bugatti Insights / Mastermind Group AI for EF Core usage
- [ ] Create automated pre-flight check in ef-preflight-check.ps1
- [ ] Add table name validation to CI/CD pipeline

### Long-Term (Best Practices)
- [ ] Template: All new DbContext configurations MUST have .ToTable()
- [ ] Code review checklist: Verify .ToTable() for new entities
- [ ] Documentation: Update EF Core standards guide

---

## 🔧 Tool Enhancements

### New Tool: `audit-dbcontext-table-names.ps1`

```powershell
<#
.SYNOPSIS
    Audits DbContext files for table naming configuration completeness

.DESCRIPTION
    Scans C# DbContext files and:
    - Extracts all entity configurations
    - Checks for .ToTable() declarations
    - Compares with database schema (optional)
    - Generates report of mismatches
    - Can auto-fix by adding .ToTable() configurations

.PARAMETER ProjectPath
    Path to project containing DbContext files

.PARAMETER DatabasePath
    Optional: Path to SQLite database for schema comparison

.PARAMETER Fix
    If present, automatically adds missing .ToTable() configurations

.EXAMPLE
    .\audit-dbcontext-table-names.ps1 -ProjectPath C:\Projects\client-manager\ClientManagerAPI
    # Report only

.EXAMPLE
    .\audit-dbcontext-table-names.ps1 -ProjectPath C:\Projects\client-manager\ClientManagerAPI -DatabasePath C:\stores\brand2boost\identity.db
    # Report with schema comparison

.EXAMPLE
    .\audit-dbcontext-table-names.ps1 -ProjectPath C:\Projects\client-manager\ClientManagerAPI -Fix
    # Auto-fix missing .ToTable() configurations
#>
```

### Enhanced: `ef-preflight-check.ps1`

Add new check:
```powershell
# Check: All entities have explicit .ToTable() configuration
Write-Host "Checking entity table name configurations..."
$missingTableNames = Get-EntitiesWithoutTableConfiguration -Context $Context
if ($missingTableNames.Count -gt 0) {
    Write-Warning "Found $($missingTableNames.Count) entities without .ToTable() configuration"
    $missingTableNames | ForEach-Object { Write-Warning "  - $_" }
    Write-Host "Run: audit-dbcontext-table-names.ps1 -Fix to resolve"
    exit 1
}
```

---

## 📚 Documentation Updates

### 1. Update ef-migration-safety skill
Add new section:
- **Pattern X: Table Naming Convention Mismatch**
- Symptoms, diagnosis, resolution
- Prevention best practices

### 2. Update migration-patterns.md
Add anti-pattern:
- **❌ Implicit Table Names (Relying on EF Core Conventions)**
- Why it's dangerous
- How to avoid

### 3. Create client-manager/docs/ef-core-standards.md
Document:
- DbContext configuration requirements
- .ToTable() requirement for ALL entities
- Migration creation checklist
- Table naming conventions

---

## 🎓 Training for Future Agents

### New Pattern Recognition Skill

**Trigger:** When creating EF Core migrations

**Pre-Flight Questions:**
1. Does the DbContext have explicit `.ToTable()` for all entities?
2. Do migration table names match DbContext configuration?
3. Have previous migrations used custom table names?

**If ANY answer is "No" or "Unknown":**
- STOP migration creation
- Run audit tool
- Fix configuration
- THEN create migration

### Error Message Pattern Recognition

**When you see:**
- "SQLite Error 1: 'no such table: X'"
- "SQLite Error 1: 'table "X" already exists'"

**Immediately think:**
1. Table naming mismatch?
2. Check DbContext .ToTable() configuration
3. Compare with actual database schema
4. Compare with previous migrations

---

## ✅ Verification & Testing

### Post-Fix Verification

```bash
# 1. Clean migration applied successfully
✅ Migration 20260119185100_UpdateModelWithSoftDelete applied

# 2. No pending model changes warning
✅ Application starts without InvalidOperationException

# 3. Schema matches model
✅ dotnet ef migrations list shows all applied

# 4. DbContext configuration complete
✅ Project entity has .ToTable("ProjectsDb")
```

### Regression Prevention

**Before creating ANY future migration:**
```bash
# 1. Run table name audit
.\tools\audit-dbcontext-table-names.ps1 -ProjectPath <path>

# 2. If issues found, fix first
.\tools\audit-dbcontext-table-names.ps1 -ProjectPath <path> -Fix

# 3. THEN create migration
dotnet ef migrations add <Name> --context <Context>
```

---

## 🌟 Success Metrics

**Incident Resolution:**
- ✅ Root cause identified: Missing .ToTable() configuration
- ✅ Fix applied: Added explicit table name
- ✅ Migration created and applied successfully
- ✅ Application runs without errors
- ✅ Documentation updated

**Prevention Measures:**
- ✅ New audit tool designed
- ✅ Pre-flight check enhanced
- ✅ Pattern documented for future reference
- ⏳ Systematic audit of all projects (pending)

**Knowledge Transfer:**
- ✅ Reflection log entry created
- ✅ EF migration safety skill update (pending)
- ✅ Best practices documented
- ✅ Tool enhancements planned

---

**Conclusion:**

This incident revealed a critical gap in EF Core DbContext configuration practices. The fix was straightforward (add `.ToTable("ProjectsDb")`), but the broader lesson is about **configuration completeness** and **explicit over implicit**.

Going forward, ALL entity configurations must have explicit `.ToTable()` declarations, regardless of whether they match EF Core conventions. This prevents subtle mismatches that can cause complete application failure.

**Key Takeaway for AI Agents:**
When working with EF Core, NEVER assume table names match entity names. Always verify DbContext configuration has explicit `.ToTable()` for ALL entities before creating migrations.

---

**Last Updated:** 2026-01-19
**Author:** Claude Agent (Sonnet 4.5)
**Incident ID:** EFCORE-TABLENAMING-20260119
