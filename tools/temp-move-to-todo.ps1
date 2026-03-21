$cfg = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$token = $cfg.api_key
$headers = @{ Authorization = $token; 'Content-Type' = 'application/json' }

$taskIds = @(
    "869cchp0g",  # Testing: Verify complete rebrand with test agency name
    "869cchp01",  # Documentation: Update README and docs with new agency name
    "869cchnzu",  # Infrastructure: Update Jengo knowledge base references
    "869cchnzn",  # ClickUp: Rename board from Bliek Vastgoed to configurable name
    "869cchnz7",  # Backend: Add agency configuration settings API
    "869cchnyw",  # Frontend: Search and replace hardcoded Bliek text strings
    "869cchnyt",  # Frontend: Make homepage background image configurable
    "869cchnyn",  # Frontend: Make logo configurable (remove hardcoded Bliek branding)
    "869cchnyf"   # GitHub: Rename repository from bliek-vastgoed to real-estate-agency-ai
)

foreach ($id in $taskIds) {
    $body = @{ status = "todo" } | ConvertTo-Json
    try {
        $result = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$id" -Method PUT -Headers $headers -Body $body
        Write-Output "MOVED: $id ($($result.name)) -> todo"
    } catch {
        Write-Output "ERROR: $id - $($_.Exception.Message)"
    }
}

Write-Output "`nAll tasks moved to todo."
