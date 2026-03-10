$api_key = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $api_key; 'Content-Type' = 'application/json' }

$tasks = @{
    '869cdpzmt' = @{
        comment = "REFINED - CSS layout fix`n`nMUST HAVE:`n- #root: remove max-width, margin, padding (CSS reset)`n- First child of main (motion.div wrapping Outlet in MainLayout): max-width: 1024px; margin: auto`n`nFiles: frontend/src/index.css + MainLayout.tsx`n-- Jengo"
    }
    '869cdpy7n' = @{
        comment = "REFINED - WordPress plugin activation flow`n`nMUST HAVE:`n- Backend: POST /api/wordpress/plugin-activate (no auth). Takes {email, siteUrl, siteTitle}. Find/create user + website. Return {token, websiteId, dashboardUrl}`n- Backend: GET /api/wordpress/plugin-status?siteUrl=. Returns {connected, websiteId}`n- WP plugin activate(): shows Link button if no connection; dashboard link if connected; reconnect notice if broken`n- WP plugin: AJAX handler stores websiteId + token in WP options, shows dashboard link`n- WP plugin: deactivation keeps options; reactivation tests connection first`n`nFiles: WordPressController.cs + seo-god.php`n-- Jengo"
    }
    '869cdpxh6' = @{
        comment = "REFINED - FAQ generate 500 error`n`nROOT CAUSE: GenerateFAQs passes wpId (int parsed from urlId) to generator which does p.Id == wpId but p.Id is auto-increment DB key, not WP ID. Also double-save: generator already saves FAQs, controller re-adds them causing EF error.`n`nMUST HAVE:`n- UrlsController.GenerateFAQs: look up entity by WordPressId first, pass database Id to generator`n- Remove duplicate _context.FAQs.Add + SaveChanges in controller after generator returns`n`nFiles: UrlsController.cs`n-- Jengo"
    }
    '869cdpxgc' = @{
        comment = "REFINED - FAQ form disappears on toggle`n`nROOT CAUSE: generateFAQs() sets loading=true. Line 340 returns early spinner when loading=true, hiding entire page including toggle header.`n`nMUST HAVE:`n- Add generating bool state separate from loading`n- loading = initial page load only`n- generating = FAQ auto-generation in progress`n- Header/toggle visible during generating; spinner in FAQ content area only`n`nFiles: frontend/src/pages/URLFAQPage.tsx`n-- Jengo"
    }
    '869cdpwz7' = @{
        comment = "REFINED - Remove sync button from URL rows`n`nMUST HAVE:`n- Remove Sync button (RefreshCw) from each row actions column in URLsPageNew.tsx`n- Remove refreshingUrl state and refreshSingleUrl function (unused after removal)`n`nFiles: frontend/src/pages/URLsPageNew.tsx`n-- Jengo"
    }
    '869cdpwyf' = @{
        comment = "REFINED - FAQ toggle always ON by default`n`nROOT CAUSE: faqMap lookup key = contentType + full item.id (complex doc store path: wordpress/uuid/post/6). But faqMap keys from URLs API are format type-wpId (page-52). Keys never match, faqEnabled stays undefined, undefined !== false so shows ON.`n`nMUST HAVE:`n- Fix urlKey: use item.id.split('/').pop() to extract WP integer ID`n- urlKey = type-wpId matching URLs API response`n`nFiles: frontend/src/pages/URLsPageNew.tsx`n-- Jengo"
    }
}

foreach ($id in $tasks.Keys) {
    $body = @{ status = 'todo' } | ConvertTo-Json
    Invoke-RestMethod -Method Put -Uri "https://api.clickup.com/api/v2/task/$id" -Headers $headers -Body $body | Out-Null
    Write-Host "Moved $id to todo"

    $cbody = @{ comment_text = $tasks[$id].comment } | ConvertTo-Json -Depth 3
    Invoke-RestMethod -Method Post -Uri "https://api.clickup.com/api/v2/task/$id/comment" -Headers $headers -Body $cbody | Out-Null
    Write-Host "Commented on $id"
}
Write-Host "All 6 tasks moved to todo with refinements."
