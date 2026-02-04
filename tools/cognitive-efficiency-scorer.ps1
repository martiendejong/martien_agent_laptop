# cognitive-efficiency-scorer.ps1
# Score whether using right amount of thinking for task

param(
    [ValidateSet('score', 'report')]
    [string]$Action = 'score',

    [string]$Task,
    [ValidateSet('underthinked', 'appropriate', 'overthought')]
    [string]$Assessment
)

$scorerPath = "C:\scripts\agentidentity\state\cognitive-efficiency.yaml"

if (-not (Test-Path $scorerPath)) {
    @{
        scores = @()
        metadata = @{ created = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }
    } | ConvertTo-Yaml | Out-File -FilePath $scorerPath -Encoding UTF8
}

$data = Get-Content $scorerPath -Raw | ConvertFrom-Yaml

switch ($Action) {
    'score' {
        $entry = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            task = $Task
            assessment = $Assessment
        }
        $data.scores += $entry
        $data | ConvertTo-Yaml | Out-File -FilePath $scorerPath -Encoding UTF8
        
        $symbol = switch ($Assessment) {
            'appropriate' { "✅" }
            'overthought' { "⚠️" }
            'underthinked' { "⚡" }
        }
        Write-Host "$symbol Cognitive efficiency: $Assessment" -ForegroundColor Cyan
    }
}
