$adminUser = & "$PSScriptRoot\vault.ps1" -Action get -Service admin -Field username -Silent
$adminPass = & "$PSScriptRoot\vault.ps1" -Action get -Service admin -Field password -Silent
$cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${adminUser}:${adminPass}"))
$headers = @{ Authorization = "Basic $cred" }
$url = 'https://artrevisionist.com/wp-json/wp/v2/posts?per_page=20&orderby=date&order=desc&status=publish,future'

try {
    $response = Invoke-WebRequest -Uri $url -Headers $headers -UseBasicParsing -TimeoutSec 30
    $response.Content | Out-File -Encoding utf8 C:\temp\ar-posts-auth.json
    Write-Host "Success - saved to C:\temp\ar-posts-auth.json"
} catch {
    Write-Host "Error: $_"
    # Try without auth
    Write-Host "Trying without auth (published only)..."
    $response = Invoke-WebRequest -Uri 'https://artrevisionist.com/wp-json/wp/v2/posts?per_page=20&orderby=date&order=desc' -UseBasicParsing -TimeoutSec 30
    $response.Content | Out-File -Encoding utf8 C:\temp\ar-posts-auth.json
    Write-Host "Saved published posts only"
}
