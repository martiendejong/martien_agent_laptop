$api_key = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'
$headers = @{ 'Authorization' = $api_key }

# Check all workspaces for "seo" related lists
$workspaces = @('9015747737', '9015748488', '9012956001')

foreach ($wsId in $workspaces) {
    Write-Host "=== Workspace $wsId ===" -ForegroundColor Yellow
    try {
        $spaces = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/team/$wsId/space?archived=false" -Headers $headers
        foreach ($space in $spaces.spaces) {
            # Get folders
            try {
                $folders = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/space/$($space.id)/folder?archived=false" -Headers $headers
                foreach ($folder in $folders.folders) {
                    foreach ($list in $folder.lists) {
                        if ($list.name -match 'seo' -or $list.name -match 'god') {
                            Write-Host "FOUND: $($list.name) (ID: $($list.id))" -ForegroundColor Green
                        }
                    }
                }
            } catch {}
            # Get folderless lists
            try {
                $lists = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/space/$($space.id)/list?archived=false" -Headers $headers
                foreach ($list in $lists.lists) {
                    Write-Host "  List: $($list.name) (ID: $($list.id), tasks: $($list.task_count))"
                    if ($list.name -match 'seo' -or $list.name -match 'god') {
                        Write-Host "  *** MATCH: $($list.name) ***" -ForegroundColor Green
                    }
                }
            } catch {}
        }
    } catch {
        Write-Host "Error: $_"
    }
}
