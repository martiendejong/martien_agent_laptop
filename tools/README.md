# Solution Integrity Tools

## Overview

Tools for detecting and fixing .NET solution file integrity issues - specifically when .csproj files exist on disk but are not included in the solution file.

## Problem This Solves

**Symptom:** Hundreds of build errors like:
- `NU1105: Unable to find project information for '<project>.csproj'`
- `CS0006: Metadata file '<project>.dll' could not be found`

**Root Cause:** Projects exist on disk but weren't added to the solution file with `dotnet sln add`.

**Impact:** Cascading build failures across entire solution.

## Tools

### detect-missing-projects.ps1

Scans a single solution for projects missing from the solution file.

**Usage:**
```powershell
# Check a solution
.\detect-missing-projects.ps1 -SolutionPath "C:\Projects\hazina\Hazina.sln"

# Auto-fix missing projects
.\detect-missing-projects.ps1 -SolutionPath "C:\Projects\hazina\Hazina.sln" -AutoFix
```

**Exit codes:**
- `0`: All projects included in solution
- `1`: Missing projects detected

### check-all-solutions.ps1

Orchestrates checking multiple repositories.

**Usage:**
```powershell
# Check all configured repositories
.\check-all-solutions.ps1

# Auto-fix all issues
.\check-all-solutions.ps1 -AutoFix
```

## Quick Diagnostic

```bash
# Count projects on disk vs solution
find . -name "*.csproj" | grep -v "/bin/" | grep -v "/obj/" | wc -l
dotnet sln list | grep -v "^Project" | wc -l
```

## Related Documentation

- Reflection log: `C:\scripts\_machine\reflection.log.md` (2026-01-10 16:46)
- Pattern 70: Solution File Validation

---
*Created: 2026-01-10*
