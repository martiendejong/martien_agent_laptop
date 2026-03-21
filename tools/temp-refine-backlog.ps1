$config = Get-Content 'C:\scripts\_machine\clickup-config.json' -Raw | ConvertFrom-Json
$headers = @{ Authorization = $config.api_key; 'Content-Type' = 'application/json' }

# Task 1: 869ccunh3 - Latest WP plugin on download link
$taskId = '869ccunh3'
Write-Host "Refining $taskId..."
$body = @{
    name = "Plugin download should serve latest WordPress plugin version"
    description = "REFINED DESCRIPTION:`nThe download plugin button in the frontend dashboard should always serve the latest version of the WordPress PHP plugin from the repository.`n`nCURRENT STATE:`n- Download endpoint exists at /api/wordpress/plugin/download`n- It zips the wordpress-plugin/seo-god/ directory`n`nREQUIREMENTS:`n- Verify the download endpoint zips the correct and complete plugin directory`n- Ensure all PHP files, assets, and readme.txt are included`n- The downloaded zip should be installable directly in WordPress`n`nACCEPTANCE CRITERIA:`n1. Click Download Plugin on dashboard`n2. Receive seo-god.zip file`n3. Upload zip to WordPress > Plugins > Add New > Upload`n4. Plugin installs and activates successfully"
    status = "todo"
    priority = 2
} | ConvertTo-Json -Depth 5
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $body -ErrorAction Stop | Out-Null
Write-Host "  Done - moved to todo"

# Task 2: 869ccunbt - FAQ at bottom of WP pages
$taskId = '869ccunbt'
Write-Host "Refining $taskId..."
$body = @{
    name = "WordPress plugin: Display FAQs at bottom of each post/page"
    description = "REFINED DESCRIPTION:`nThe WordPress plugin should automatically display FAQ content at the bottom of each post type (pages, posts, products) where FAQs are enabled.`n`nREQUIREMENTS:`n- Hook into the_content filter to append FAQ section`n- Only show FAQs for posts/pages that have faq_enabled meta set to true`n- Render FAQ as collapsible accordion (question/answer pairs)`n- Include Schema.org FAQPage JSON-LD markup for SEO`n- Style with WordPress-compatible CSS (no Tailwind dependency)`n- Support all post types (post, page, product, custom)`n`nACCEPTANCE CRITERIA:`n1. Enable FAQ for a page in WP admin > SEO God > FAQs`n2. View that page on the frontend`n3. FAQ section appears at bottom with accordion UI`n4. View source shows Schema.org JSON-LD in head"
    status = "todo"
    priority = 2
} | ConvertTo-Json -Depth 5
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $body -ErrorAction Stop | Out-Null
Write-Host "  Done - moved to todo"

# Task 3: 869ccun2h - URLs API 500 error
$taskId = '869ccun2h'
Write-Host "Refining $taskId..."
$body = @{
    name = "Fix URLs API page returning 500 error"
    description = "REFINED DESCRIPTION:`nThe API endpoint for getting URLs returns a 500 Internal Server Error. Debug using browser developer tools and fix the root cause.`n`nDIAGNOSTIC STEPS:`n1. Open browser dev tools Network tab`n2. Navigate to URLs page`n3. Identify the failing API call and response`n4. Check backend logs for stack trace`n5. Fix root cause`n`nLIKELY CAUSES:`n- Database query error (missing column, type mismatch)`n- Null reference in URL mapping`n- Missing relationship/navigation property`n`nACCEPTANCE CRITERIA:`n1. URLs page loads without errors`n2. All URLs from WordPress import are displayed`n3. No 500 errors in Network tab"
    status = "todo"
    priority = 1
} | ConvertTo-Json -Depth 5
Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$taskId" -Headers $headers -Method Put -Body $body -ErrorAction Stop | Out-Null
Write-Host "  Done - moved to todo"

Write-Host "`nAll 3 backlog tasks refined and moved to todo."
