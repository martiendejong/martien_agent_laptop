param(
    [string]$DbPath,
    [string]$SqlFile
)

$sqliteDll = Get-ChildItem "$env:USERPROFILE\.nuget\packages\microsoft.data.sqlite.core" -Recurse -Filter "Microsoft.Data.Sqlite.dll" |
    Where-Object { $_.FullName -match 'net8' } |
    Select-Object -First 1

if (-not $sqliteDll) {
    # Try netstandard fallback
    $sqliteDll = Get-ChildItem "$env:USERPROFILE\.nuget\packages\microsoft.data.sqlite.core" -Recurse -Filter "Microsoft.Data.Sqlite.dll" |
        Select-Object -First 1
}

if (-not $sqliteDll) {
    Write-Error "Could not find Microsoft.Data.Sqlite.dll in NuGet cache"
    exit 1
}

Add-Type -Path $sqliteDll.FullName

$conn = [Microsoft.Data.Sqlite.SqliteConnection]::new("Data Source=$DbPath")
$conn.Open()

$sql = [System.IO.File]::ReadAllText($SqlFile)

# Split on semicolons, skip comments/blanks
$statements = $sql -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -notmatch '^\s*--' }

foreach ($stmt in $statements) {
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $stmt
        $cmd.ExecuteNonQuery() | Out-Null
        Write-Host "OK: $($stmt.Substring(0, [Math]::Min(60, $stmt.Length)))..."
    } catch {
        Write-Host "Skip (already exists?): $($_.Exception.Message)"
    }
}

$conn.Close()
Write-Host "Migration complete."
