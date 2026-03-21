# Test pattern saving
$LibraryPath = "C:\scripts\agentidentity\coding-patterns\pattern-library.json"

# Read library
$library = Get-Content $LibraryPath | ConvertFrom-Json

# Create test pattern
$testPattern = @{
    id = "test-123"
    type = "ui-component"
    stack = "html-css"
    category = "test"
    name = "Test Pattern"
    description = "Test"
    code = @{
        html = "<div>test</div>"
        css = ".test {}"
        js = ""
    }
    metadata = @{
        quality = 0.9
        usageCount = 0
        tags = @("test")
    }
}

Write-Host "Before: $($library.patterns.'ui-components'.'html-css'.Count) patterns"

# Try to add
$htmlCssList = [System.Collections.ArrayList]@($library.patterns.'ui-components'.'html-css')
$null = $htmlCssList.Add($testPattern)

Write-Host "ArrayList count: $($htmlCssList.Count)"

# Update library
$library.patterns.'ui-components'.'html-css' = $htmlCssList.ToArray()

Write-Host "After array update: $($library.patterns.'ui-components'.'html-css'.Count) patterns"

# Update total
$library.metadata.totalPatterns = $library.patterns.'ui-components'.'html-css'.Count

# Save
$library | ConvertTo-Json -Depth 10 | Set-Content $LibraryPath

Write-Host "Saved. Verifying..."

# Read back
$verify = Get-Content $LibraryPath | ConvertFrom-Json
Write-Host "Verified: $($verify.patterns.'ui-components'.'html-css'.Count) patterns"
