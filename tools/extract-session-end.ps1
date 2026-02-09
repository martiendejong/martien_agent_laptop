param([string]$SessionId, [int]$TailLines = 30)
$path = "C:\Users\HP\.claude\projects\C--scripts\$SessionId.jsonl"
$lines = Get-Content $path -Tail $TailLines

foreach ($line in $lines) {
    try {
        $obj = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
        if (-not $obj) { continue }

        if ($obj.type -eq 'human' -or $obj.type -eq 'user') {
            $text = $obj.message.content
            if ($text -is [string]) {
                if ($text.Length -gt 500) { $text = $text.Substring(0, 500) + "..." }
                Write-Output "=== USER ==="
                Write-Output $text
                Write-Output ""
            }
        }
        elseif ($obj.type -eq 'assistant') {
            $content = $obj.message.content
            if ($content -is [array]) {
                $textParts = @()
                foreach ($block in $content) {
                    if ($block.type -eq 'text' -and $block.text) {
                        $textParts += $block.text
                    }
                    elseif ($block.type -eq 'tool_use') {
                        $textParts += "[TOOL: $($block.name) - $($block.input | ConvertTo-Json -Compress -Depth 2 | ForEach-Object { if ($_.Length -gt 200) { $_.Substring(0,200)+"..." } else { $_ } })]"
                    }
                }
                $combined = ($textParts -join " ").Trim()
                if ($combined.Length -gt 800) { $combined = $combined.Substring(0, 800) + "..." }
                if ($combined) {
                    Write-Output "=== ASSISTANT ==="
                    Write-Output $combined
                    Write-Output ""
                }
            }
            elseif ($content -is [string] -and $content.Trim()) {
                if ($content.Length -gt 800) { $content = $content.Substring(0, 800) + "..." }
                Write-Output "=== ASSISTANT ==="
                Write-Output $content
                Write-Output ""
            }
        }
        elseif ($obj.type -eq 'system') {
            Write-Output "=== SYSTEM ==="
            $sc = [string]$obj.message.content
            if ($sc.Length -gt 300) { $sc = $sc.Substring(0,300) + "..." }
            Write-Output $sc
            Write-Output ""
        }
    } catch {}
}
