param([string]$SessionId, [int]$Lines = 10, [switch]$Tail)
$path = "C:\Users\HP\.claude\projects\C--scripts\$SessionId.jsonl"
if (-not (Test-Path $path)) { Write-Error "Session not found: $path"; exit 1 }

if ($Tail) {
    $content = Get-Content $path -Tail $Lines
} else {
    $content = Get-Content $path -First $Lines
}

foreach ($line in $content) {
    try {
        $obj = $line | ConvertFrom-Json
        $type = $obj.type
        if ($type -eq 'human') {
            $text = $obj.message.content
            if ($text.Length -gt 300) { $text = $text.Substring(0, 300) + "..." }
            Write-Output "[$type] $text"
        } elseif ($type -eq 'assistant') {
            $text = ""
            if ($obj.message.content -is [array]) {
                foreach ($block in $obj.message.content) {
                    if ($block.type -eq 'text') {
                        $text += $block.text
                    } elseif ($block.type -eq 'tool_use') {
                        $text += "[tool: $($block.name)] "
                    }
                }
            } else {
                $text = [string]$obj.message.content
            }
            if ($text.Length -gt 300) { $text = $text.Substring(0, 300) + "..." }
            Write-Output "[$type] $text"
        } else {
            Write-Output "[$type]"
        }
    } catch {
        # skip unparseable lines
    }
}
