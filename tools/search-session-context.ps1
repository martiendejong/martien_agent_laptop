param([string]$SessionId, [string]$Pattern, [int]$Context = 200)
$path = "C:\Users\HP\.claude\projects\C--scripts\$SessionId.jsonl"
$lines = Get-Content $path

$matchCount = 0
foreach ($line in $lines) {
    if ($line -match $Pattern) {
        $matchCount++
        try {
            $obj = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($obj.type -eq 'assistant' -and $obj.message.content -is [array]) {
                foreach ($block in $obj.message.content) {
                    if ($block.type -eq 'text' -and $block.text -match $Pattern) {
                        $text = $block.text
                        $idx = $text.IndexOf(($text -split $Pattern)[0])
                        $start = [Math]::Max(0, $text.IndexOf($Matches[0]) - $Context)
                        $end = [Math]::Min($text.Length, $text.IndexOf($Matches[0]) + $Matches[0].Length + $Context)
                        Write-Output "--- MATCH $matchCount (assistant text) ---"
                        Write-Output $text.Substring($start, $end - $start)
                        Write-Output ""
                    }
                }
            } elseif ($obj.type -eq 'user' -or $obj.type -eq 'human') {
                $text = [string]$obj.message.content
                if ($text -match $Pattern) {
                    if ($text.Length -gt 500) { $text = $text.Substring(0, 500) + "..." }
                    Write-Output "--- MATCH $matchCount (user) ---"
                    Write-Output $text
                    Write-Output ""
                }
            }
        } catch {}
    }
}
Write-Output "Total matches: $matchCount"
