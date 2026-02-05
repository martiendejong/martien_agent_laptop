# Secret Detection in Context - Round 14
# Flags sensitive data before it's committed

param(
    [Parameter(Mandatory=$false)]
    [string]$ContextDir = "C:\scripts\_machine"
)

# Patterns for common secrets
$secretPatterns = @(
    @{ Name = "AWS Key"; Pattern = 'AKIA[0-9A-Z]{16}' }
    @{ Name = "Private Key"; Pattern = '-----BEGIN (RSA|DSA|EC) PRIVATE KEY-----' }
    @{ Name = "Password"; Pattern = '(password|passwd|pwd)\s*[:=]\s*[''"]?[^\s''"]+' }
    @{ Name = "API Key"; Pattern = '(api[_-]?key|apikey)\s*[:=]\s*[''"]?[a-zA-Z0-9]{20,}' }
    @{ Name = "GitHub Token"; Pattern = 'gh[pousr]_[A-Za-z0-9_]{36}' }
    @{ Name = "Azure Connection"; Pattern = 'DefaultEndpointsProtocol=https' }
    @{ Name = "Database Connection"; Pattern = 'mongodb://|postgres://|mysql://' }
    @{ Name = "JWT Token"; Pattern = 'eyJ[A-Za-z0-9-_=]+\.eyJ[A-Za-z0-9-_=]+\.' }
)

$findings = @()

Write-Host "Scanning for secrets in context files..." -ForegroundColor Yellow

$files = Get-ChildItem $ContextDir -Include *.md,*.yaml,*.json,*.ps1,*.py -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    foreach ($pattern in $secretPatterns) {
        if ($content -match $pattern.Pattern) {
            $matches = [regex]::Matches($content, $pattern.Pattern)

            foreach ($match in $matches) {
                $findings += [PSCustomObject]@{
                    File = $file.FullName
                    SecretType = $pattern.Name
                    Match = $match.Value.Substring(0, [Math]::Min(50, $match.Value.Length)) + "..."
                    Line = ($content.Substring(0, $match.Index) -split "`n").Count
                }
            }
        }
    }
}

if ($findings.Count -gt 0) {
    Write-Host "`n⚠ WARNING: $($findings.Count) potential secrets found!" -ForegroundColor Red
    $findings | Format-Table -AutoSize

    # Save report
    $reportPath = Join-Path $ContextDir "secret-scan-report.json"
    $findings | ConvertTo-Json | Set-Content $reportPath
    Write-Host "`nReport saved: $reportPath" -ForegroundColor Cyan
    Write-Host "Please review and remove sensitive data before committing!" -ForegroundColor Yellow

    return $findings
} else {
    Write-Host "`n✓ No secrets detected" -ForegroundColor Green
    return @()
}
