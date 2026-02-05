# Automatic Context Clustering (R21-005)
# Groups related context files by co-access patterns

param(
    [switch]$Build,
    [switch]$Show,
    [string]$FindRelated
)

$ClusterDataPath = "C:\scripts\_machine\context-clusters.yaml"
$EventLogPath = "C:\scripts\logs\conversation-events.log.jsonl"

function Build-ContextClusters {
    if (!(Test-Path $EventLogPath)) {
        Write-Host "No event log found at $EventLogPath"
        return
    }

    Write-Host "Mining conversation events for co-access patterns..." -ForegroundColor Cyan

    # Parse events to find file access patterns
    $fileAccesses = @{}
    $coAccess = @{}

    Get-Content $EventLogPath | ForEach-Object {
        try {
            $event = $_ | ConvertFrom-Json
            if ($event.event_type -eq "file_read" -and $event.file_path) {
                $sessionId = $event.session_id
                $filePath = $event.file_path

                if (!$fileAccesses.ContainsKey($sessionId)) {
                    $fileAccesses[$sessionId] = @()
                }
                $fileAccesses[$sessionId] += $filePath
            }
        }
        catch {
            # Skip malformed entries
        }
    }

    # Build co-access matrix
    foreach ($session in $fileAccesses.Keys) {
        $files = $fileAccesses[$session] | Select-Object -Unique

        for ($i = 0; $i -lt $files.Count; $i++) {
            for ($j = $i + 1; $j -lt $files.Count; $j++) {
                $file1 = $files[$i]
                $file2 = $files[$j]

                # Sort for consistency
                $pair = @($file1, $file2) | Sort-Object
                $key = "$($pair[0])|$($pair[1])"

                if (!$coAccess.ContainsKey($key)) {
                    $coAccess[$key] = 0
                }
                $coAccess[$key]++
            }
        }
    }

    # Build clusters using simple threshold-based approach
    $threshold = 3  # Need at least 3 co-accesses to cluster
    $clusters = @{}
    $clusterIndex = 0

    foreach ($pair in $coAccess.Keys) {
        if ($coAccess[$pair] -ge $threshold) {
            $files = $pair -split '\|'

            # Find existing cluster or create new one
            $foundCluster = $false
            foreach ($cid in $clusters.Keys) {
                if ($clusters[$cid].files -contains $files[0] -or $clusters[$cid].files -contains $files[1]) {
                    $clusters[$cid].files += $files[0]
                    $clusters[$cid].files += $files[1]
                    $clusters[$cid].files = $clusters[$cid].files | Select-Object -Unique
                    $foundCluster = $true
                    break
                }
            }

            if (!$foundCluster) {
                $clusters["cluster_$clusterIndex"] = @{
                    files = @($files[0], $files[1])
                    strength = $coAccess[$pair]
                }
                $clusterIndex++
            }
        }
    }

    # Save clusters
    $output = @{
        generated = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        total_sessions = $fileAccesses.Count
        total_clusters = $clusters.Count
        clusters = $clusters
    }

    $output | ConvertTo-Yaml | Out-File -FilePath $ClusterDataPath -Encoding UTF8

    Write-Host "Built $($clusters.Count) clusters from $($fileAccesses.Count) sessions" -ForegroundColor Green
}

function Show-Clusters {
    if (!(Test-Path $ClusterDataPath)) {
        Write-Host "No cluster data. Run with -Build first."
        return
    }

    $data = Get-Content $ClusterDataPath -Raw | ConvertFrom-Yaml

    Write-Host "`n=== Context Clusters ===" -ForegroundColor Cyan
    Write-Host "Generated: $($data.generated)"
    Write-Host "Total Sessions: $($data.total_sessions)"
    Write-Host "Total Clusters: $($data.total_clusters)`n"

    foreach ($clusterName in $data.clusters.Keys) {
        $cluster = $data.clusters[$clusterName]
        Write-Host "[$clusterName]" -ForegroundColor Yellow
        $cluster.files | ForEach-Object {
            Write-Host "  - $_"
        }
        Write-Host ""
    }
}

function Find-RelatedFiles {
    param([string]$TargetFile)

    if (!(Test-Path $ClusterDataPath)) {
        Write-Host "No cluster data. Run with -Build first."
        return
    }

    $data = Get-Content $ClusterDataPath -Raw | ConvertFrom-Yaml

    $relatedFiles = @()

    foreach ($clusterName in $data.clusters.Keys) {
        $cluster = $data.clusters[$clusterName]
        if ($cluster.files -contains $TargetFile) {
            $relatedFiles += $cluster.files | Where-Object { $_ -ne $TargetFile }
        }
    }

    if ($relatedFiles.Count -gt 0) {
        Write-Host "`nFiles related to '$TargetFile':" -ForegroundColor Cyan
        $relatedFiles | Select-Object -Unique | ForEach-Object {
            Write-Host "  - $_"
        }
    }
    else {
        Write-Host "No related files found for '$TargetFile'"
    }
}

# Main execution
if ($Build) {
    Build-ContextClusters
}
elseif ($Show) {
    Show-Clusters
}
elseif ($FindRelated) {
    Find-RelatedFiles -TargetFile $FindRelated
}
else {
    Write-Host "Usage: context-clustering.ps1 [-Build] [-Show] [-FindRelated <file>]"
    Write-Host "  -Build              : Analyze event log and build clusters"
    Write-Host "  -Show               : Display current clusters"
    Write-Host "  -FindRelated <file> : Find files related to given file"
}
