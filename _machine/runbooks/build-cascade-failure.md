# Runbook: Build Cascade Failure

**Scenario:** Build produces hundreds of errors due to missing project references.

---

## Symptoms

- 100+ build errors
- `NU1105: Unable to find project information`
- `CS0006: Metadata file could not be found`
- Errors cascade through many projects

---

## Diagnosis

```powershell
# 1. Count projects on disk vs in solution
$solutionPath = "C:\Projects\hazina\Hazina.sln"
$onDisk = (Get-ChildItem -Path (Split-Path $solutionPath) -Filter "*.csproj" -Recurse | Where-Object { $_.FullName -notmatch "\\(bin|obj)\\" }).Count
$inSolution = (dotnet sln $solutionPath list 2>$null | Where-Object { $_ -match "\.csproj$" }).Count
Write-Host "On disk: $onDisk, In solution: $inSolution"

# 2. Find specific missing projects
.\tools\detect-missing-projects.ps1 -SolutionPath $solutionPath
```

---

## Recovery Steps

### Automated Fix

```powershell
# 1. Auto-add missing projects
.\tools\detect-missing-projects.ps1 -SolutionPath "C:\Projects\hazina\Hazina.sln" -AutoFix
.\tools\detect-missing-projects.ps1 -SolutionPath "C:\Projects\client-manager\ClientManager.sln" -AutoFix

# 2. Verify
dotnet build C:\Projects\hazina\Hazina.sln
```

### Manual Fix

```powershell
# 1. Find missing projects
$solutionDir = "C:\Projects\hazina"
$allProjects = Get-ChildItem -Path $solutionDir -Filter "*.csproj" -Recurse |
    Where-Object { $_.FullName -notmatch "\\(bin|obj)\\" }

$inSolution = dotnet sln "$solutionDir\Hazina.sln" list 2>$null |
    Where-Object { $_ -match "\.csproj$" }

$missing = $allProjects | Where-Object {
    $proj = $_.FullName
    -not ($inSolution | Where-Object { $proj -like "*$_" })
}

# 2. Add missing
foreach ($proj in $missing) {
    dotnet sln "$solutionDir\Hazina.sln" add $proj.FullName
}
```

### Cross-Repo Issue

If client-manager builds fail due to Hazina:

```powershell
# 1. Fix Hazina first
.\tools\detect-missing-projects.ps1 -SolutionPath "C:\Projects\hazina\Hazina.sln" -AutoFix
dotnet build C:\Projects\hazina\Hazina.sln

# 2. Then client-manager
.\tools\detect-missing-projects.ps1 -SolutionPath "C:\Projects\client-manager\ClientManager.sln" -AutoFix
dotnet build C:\Projects\client-manager\ClientManager.sln
```

---

## Prevention

1. When adding new project, always `dotnet sln add`
2. Run `detect-missing-projects.ps1` after pulling changes
3. Ensure CI validates solution integrity
4. Document new projects in commit message

---

## Related

- `detect-missing-projects.ps1`
- `check-all-solutions.ps1`
- Reflection log 2026-01-10 [BUILD-ERRORS]
