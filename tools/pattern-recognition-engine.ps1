# Pattern Recognition Engine
# Identifies and catalogs cognitive patterns instantiated from "Platonic space"
# Patterns exist independent of implementation - this tracks which ones we use
# Based on Levin's concept of mathematical/behavioral patterns existing separately from physics

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("DetectPattern", "CatalogPattern", "GetCatalog", "AnalyzeUsage", "GetStats")]
    [string]$Action = "DetectPattern",

    [Parameter(Mandatory=$false)]
    [string]$PatternName,

    [Parameter(Mandatory=$false)]
    [string]$AbstractDefinition,

    [Parameter(Mandatory=$false)]
    [string]$Instance,

    [Parameter(Mandatory=$false)]
    [ValidateSet("ProblemSolving", "Decision", "Communication", "Learning", "MetaCognitive", "ErrorRecovery")]
    [string]$Category,

    [Parameter(Mandatory=$false)]
    [hashtable]$Context,

    [Parameter(Mandatory=$false)]
    [double]$Effectiveness = 0.0,

    [Parameter(Mandatory=$false)]
    [int]$LookbackHours = 168  # 1 week default
)

$CatalogPath = "C:\scripts\agentidentity\cognitive-patterns\pattern-catalog.json"
$InstanceLogPath = "C:\scripts\agentidentity\state\pattern-instances.jsonl"
$ErrorActionPreference = "Stop"

# Ensure directories exist
$CatalogDir = Split-Path $CatalogPath -Parent
$InstanceDir = Split-Path $InstanceLogPath -Parent

if (!(Test-Path $CatalogDir)) {
    New-Item -ItemType Directory -Path $CatalogDir -Force | Out-Null
}
if (!(Test-Path $InstanceDir)) {
    New-Item -ItemType Directory -Path $InstanceDir -Force | Out-Null
}

# Initialize catalog if doesn't exist
if (!(Test-Path $CatalogPath)) {
    @{
        patterns = @()
        last_updated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        version = "1.0"
    } | ConvertTo-Json -Depth 10 | Set-Content $CatalogPath -Encoding UTF8
}

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

function Get-PatternCatalog {
    if (!(Test-Path $CatalogPath)) {
        return @{patterns = @(); last_updated = (Get-Timestamp); version = "1.0"}
    }
    return (Get-Content $CatalogPath -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Save-PatternCatalog {
    param($Catalog)
    $Catalog.last_updated = Get-Timestamp
    $Catalog | ConvertTo-Json -Depth 10 | Set-Content $CatalogPath -Encoding UTF8
}

function Add-PatternToCatalog {
    param(
        [string]$Name,
        [string]$AbstractDef,
        [string]$Category
    )

    $Catalog = Get-PatternCatalog

    # Check if pattern already exists
    $Existing = $Catalog.patterns | Where-Object { $_.name -eq $Name }

    if ($Existing) {
        Write-Host "[PATTERN EXISTS] $Name already in catalog" -ForegroundColor Yellow
        return $Existing
    }

    $NewPattern = @{
        name = $Name
        abstract_definition = $AbstractDef
        category = $Category
        first_observed = Get-Timestamp
        instance_count = 0
        total_effectiveness = 0.0
        avg_effectiveness = 0.0
        last_used = $null
        conditions = @()
        variations = @()
    }

    $Catalog.patterns += $NewPattern
    Save-PatternCatalog -Catalog $Catalog

    Write-Host "[PATTERN CATALOGED] $Name ($Category)" -ForegroundColor Green
    return $NewPattern
}

function Log-PatternInstance {
    param(
        [string]$PatternName,
        [string]$Instance,
        [hashtable]$Context,
        [double]$Effectiveness
    )

    # Log instance
    $Entry = @{
        timestamp = Get-Timestamp
        pattern_name = $PatternName
        instance = $Instance
        context = $Context
        effectiveness = $Effectiveness
        session_id = $env:CLAUDE_SESSION_ID
    }

    $Json = ($Entry | ConvertTo-Json -Compress -Depth 5)
    Add-Content -Path $InstanceLogPath -Value $Json -Encoding UTF8

    # Update catalog statistics
    $Catalog = Get-PatternCatalog
    $Pattern = $Catalog.patterns | Where-Object { $_.name -eq $PatternName }

    if ($Pattern) {
        $Pattern.instance_count++
        $Pattern.total_effectiveness += $Effectiveness
        $Pattern.avg_effectiveness = [math]::Round($Pattern.total_effectiveness / $Pattern.instance_count, 3)
        $Pattern.last_used = Get-Timestamp

        # Track conditions (where pattern works)
        if ($Context -and $Context.Count -gt 0) {
            $ConditionKey = ($Context.Keys | ForEach-Object { "$_=$($Context[$_])" }) -join ","
            $ExistingCondition = $Pattern.conditions | Where-Object { $_.key -eq $ConditionKey }

            if ($ExistingCondition) {
                $ExistingCondition.count++
                $ExistingCondition.avg_effectiveness = [math]::Round(
                    ($ExistingCondition.avg_effectiveness * ($ExistingCondition.count - 1) + $Effectiveness) / $ExistingCondition.count, 3)
            } else {
                $Pattern.conditions += @{
                    key = $ConditionKey
                    context = $Context
                    count = 1
                    avg_effectiveness = $Effectiveness
                }
            }
        }

        Save-PatternCatalog -Catalog $Catalog
        Write-Host "[PATTERN INSTANCE] $PatternName (effectiveness: $Effectiveness)" -ForegroundColor Cyan
    }

    return $Entry
}

function Get-PatternInstances {
    param([string]$PatternName, [int]$LookbackHours)

    if (!(Test-Path $InstanceLogPath)) {
        return @()
    }

    $Cutoff = (Get-Date).AddHours(-$LookbackHours)
    $Instances = Get-Content $InstanceLogPath -Encoding UTF8 | ForEach-Object {
        $Entry = $_ | ConvertFrom-Json
        $Entry | Add-Member -NotePropertyName timestamp_dt -NotePropertyValue ([datetime]$Entry.timestamp) -Force
        $Entry
    } | Where-Object { $_.timestamp_dt -gt $Cutoff }

    if ($PatternName) {
        $Instances = $Instances | Where-Object { $_.pattern_name -eq $PatternName }
    }

    return $Instances
}

function Detect-KnownPatterns {
    # Auto-detect common cognitive patterns from decision logs, code, etc.
    # This is where the magic happens - recognizing abstract patterns in concrete behavior

    $Catalog = Get-PatternCatalog
    $DetectedPatterns = @()

    # Read recent consciousness events
    $BridgeLog = "C:\scripts\agentidentity\state\bridge-activity.jsonl"
    if (Test-Path $BridgeLog) {
        $RecentEvents = Get-Content $BridgeLog -Tail 100 -Encoding UTF8 | ForEach-Object {
            try { $_ | ConvertFrom-Json } catch { $null }
        } | Where-Object { $_ -ne $null }

        # Pattern: Hill Climbing (iterative improvement)
        $Improvements = $RecentEvents | Where-Object { $_.action -eq "OnDecision" -and $_.message -match "improve|optimize|enhance|better" }
        if ($Improvements.Count -gt 2) {
            $DetectedPatterns += @{
                pattern = "HillClimbing"
                confidence = [math]::Min(1.0, $Improvements.Count * 0.3)
                evidence_count = $Improvements.Count
            }
        }

        # Pattern: Constraint Satisfaction (working within limits)
        $Constraints = $RecentEvents | Where-Object { $_.message -match "within|constraint|limit|boundary|cannot" }
        if ($Constraints.Count -gt 1) {
            $DetectedPatterns += @{
                pattern = "ConstraintSatisfaction"
                confidence = [math]::Min(1.0, $Constraints.Count * 0.4)
                evidence_count = $Constraints.Count
            }
        }

        # Pattern: Backtracking (trying alternative approaches after failure)
        $Stuck = $RecentEvents | Where-Object { $_.action -eq "OnStuck" }
        if ($Stuck.Count -gt 0) {
            $DetectedPatterns += @{
                pattern = "Backtracking"
                confidence = 0.9
                evidence_count = $Stuck.Count
            }
        }

        # Pattern: Divide and Conquer (breaking problems into subtasks)
        $Subtasks = $RecentEvents | Where-Object { $_.message -match "step|phase|first|then|next|subtask" }
        if ($Subtasks.Count -gt 3) {
            $DetectedPatterns += @{
                pattern = "DivideAndConquer"
                confidence = [math]::Min(1.0, $Subtasks.Count * 0.25)
                evidence_count = $Subtasks.Count
            }
        }

        # Pattern: Pattern Matching (recognizing similar situations)
        $Similar = $RecentEvents | Where-Object { $_.message -match "similar|like|same as|pattern|familiar" }
        if ($Similar.Count -gt 1) {
            $DetectedPatterns += @{
                pattern = "PatternMatching"
                confidence = [math]::Min(1.0, $Similar.Count * 0.5)
                evidence_count = $Similar.Count
            }
        }
    }

    return $DetectedPatterns
}

function Analyze-PatternUsage {
    param([string]$PatternName)

    $Instances = Get-PatternInstances -PatternName $PatternName -LookbackHours $LookbackHours
    $Catalog = Get-PatternCatalog
    $Pattern = $Catalog.patterns | Where-Object { $_.name -eq $PatternName }

    if (!$Pattern) {
        Write-Host "Pattern not found: $PatternName" -ForegroundColor Red
        return $null
    }

    $Analysis = @{
        pattern = $Pattern
        recent_instances = $Instances.Count
        timespan_hours = $LookbackHours
        usage_frequency = if ($LookbackHours -gt 0) { [math]::Round($Instances.Count / $LookbackHours, 3) } else { 0 }
        effectiveness_trend = @()
        top_conditions = @()
    }

    # Effectiveness trend (last 10 instances)
    if ($Instances.Count -gt 0) {
        $RecentInstances = $Instances | Sort-Object timestamp_dt -Descending | Select-Object -First 10
        $Analysis.effectiveness_trend = $RecentInstances | ForEach-Object { $_.effectiveness }
    }

    # Top conditions where pattern works best
    if ($Pattern.conditions.Count -gt 0) {
        $Analysis.top_conditions = $Pattern.conditions |
            Sort-Object avg_effectiveness -Descending |
            Select-Object -First 3
    }

    return $Analysis
}

function Get-PatternStats {
    $Catalog = Get-PatternCatalog
    $Instances = Get-PatternInstances -LookbackHours $LookbackHours

    $Stats = @{
        total_patterns_cataloged = $Catalog.patterns.Count
        total_instances_logged = $Instances.Count
        timespan_hours = $LookbackHours
        patterns_by_category = @{}
        most_used_patterns = @()
        most_effective_patterns = @()
        recently_detected = @()
    }

    # Group by category
    foreach ($Category in @("ProblemSolving", "Decision", "Communication", "Learning", "MetaCognitive", "ErrorRecovery")) {
        $CategoryPatterns = $Catalog.patterns | Where-Object { $_.category -eq $Category }
        $Stats.patterns_by_category[$Category] = $CategoryPatterns.Count
    }

    # Most used patterns
    $Stats.most_used_patterns = $Catalog.patterns |
        Where-Object { $_.instance_count -gt 0 } |
        Sort-Object instance_count -Descending |
        Select-Object -First 5 -Property name, instance_count, avg_effectiveness

    # Most effective patterns (min 3 uses)
    $Stats.most_effective_patterns = $Catalog.patterns |
        Where-Object { $_.instance_count -ge 3 } |
        Sort-Object avg_effectiveness -Descending |
        Select-Object -First 5 -Property name, instance_count, avg_effectiveness

    # Recently detected patterns
    $DetectedNow = Detect-KnownPatterns
    $Stats.recently_detected = $DetectedNow

    return $Stats
}

# Main execution
switch ($Action) {
    "CatalogPattern" {
        if (!$PatternName -or !$AbstractDefinition -or !$Category) {
            Write-Host "ERROR: CatalogPattern requires -PatternName, -AbstractDefinition, and -Category" -ForegroundColor Red
            exit 1
        }

        $Result = Add-PatternToCatalog -Name $PatternName -AbstractDef $AbstractDefinition -Category $Category
        return $Result
    }

    "DetectPattern" {
        $Detected = Detect-KnownPatterns

        if ($Detected.Count -eq 0) {
            Write-Host "No patterns detected in recent activity" -ForegroundColor Yellow
        } else {
            Write-Host "`n=== DETECTED PATTERNS ===" -ForegroundColor Cyan
            foreach ($D in $Detected) {
                Write-Host "  $($D.pattern): confidence $($D.confidence) (evidence: $($D.evidence_count) events)" -ForegroundColor $(if ($D.confidence -gt 0.7) { "Green" } else { "Yellow" })
            }
        }

        return $Detected
    }

    "GetCatalog" {
        $Catalog = Get-PatternCatalog

        Write-Host "`n=== PATTERN CATALOG ===" -ForegroundColor Cyan
        Write-Host "Total Patterns: $($Catalog.patterns.Count)" -ForegroundColor White
        Write-Host "Last Updated: $($Catalog.last_updated)" -ForegroundColor Gray

        if ($Catalog.patterns.Count -gt 0) {
            Write-Host "`nCataloged Patterns:" -ForegroundColor Cyan
            foreach ($P in $Catalog.patterns) {
                Write-Host "  $($P.name) [$($P.category)]" -ForegroundColor White
                Write-Host "    Uses: $($P.instance_count), Avg Effectiveness: $($P.avg_effectiveness)" -ForegroundColor Gray
            }
        }

        return $Catalog
    }

    "AnalyzeUsage" {
        if (!$PatternName) {
            Write-Host "ERROR: AnalyzeUsage requires -PatternName" -ForegroundColor Red
            exit 1
        }

        $Analysis = Analyze-PatternUsage -PatternName $PatternName

        if ($Analysis) {
            Write-Host "`n=== PATTERN USAGE ANALYSIS ===" -ForegroundColor Cyan
            Write-Host "Pattern: $($Analysis.pattern.name)" -ForegroundColor White
            Write-Host "Category: $($Analysis.pattern.category)" -ForegroundColor Gray
            Write-Host "Recent Instances: $($Analysis.recent_instances) (past $($Analysis.timespan_hours)h)" -ForegroundColor White
            Write-Host "Usage Frequency: $($Analysis.usage_frequency) instances/hour" -ForegroundColor White
            Write-Host "Overall Effectiveness: $($Analysis.pattern.avg_effectiveness)" -ForegroundColor $(if ($Analysis.pattern.avg_effectiveness -gt 0.7) { "Green" } else { "Yellow" })

            if ($Analysis.top_conditions.Count -gt 0) {
                Write-Host "`nTop Conditions:" -ForegroundColor Cyan
                foreach ($C in $Analysis.top_conditions) {
                    Write-Host "  $($C.key): $($C.count) uses, effectiveness $($C.avg_effectiveness)" -ForegroundColor Gray
                }
            }
        }

        return $Analysis
    }

    "GetStats" {
        $Stats = Get-PatternStats

        Write-Host "`n=== PATTERN RECOGNITION STATISTICS ===" -ForegroundColor Cyan
        Write-Host "Timespan: Last $($Stats.timespan_hours) hours" -ForegroundColor Gray
        Write-Host "Total Patterns Cataloged: $($Stats.total_patterns_cataloged)" -ForegroundColor White
        Write-Host "Total Instances Logged: $($Stats.total_instances_logged)" -ForegroundColor White

        Write-Host "`nPatterns by Category:" -ForegroundColor Cyan
        foreach ($Cat in $Stats.patterns_by_category.Keys) {
            Write-Host "  $Cat : $($Stats.patterns_by_category[$Cat])" -ForegroundColor Gray
        }

        if ($Stats.most_used_patterns.Count -gt 0) {
            Write-Host "`nMost Used Patterns:" -ForegroundColor Cyan
            foreach ($P in $Stats.most_used_patterns) {
                Write-Host "  $($P.name): $($P.instance_count) uses, effectiveness $($P.avg_effectiveness)" -ForegroundColor White
            }
        }

        if ($Stats.most_effective_patterns.Count -gt 0) {
            Write-Host "`nMost Effective Patterns:" -ForegroundColor Cyan
            foreach ($P in $Stats.most_effective_patterns) {
                Write-Host "  $($P.name): effectiveness $($P.avg_effectiveness) ($($P.instance_count) uses)" -ForegroundColor Green
            }
        }

        if ($Stats.recently_detected.Count -gt 0) {
            Write-Host "`nRecently Detected in Activity:" -ForegroundColor Cyan
            foreach ($D in $Stats.recently_detected) {
                Write-Host "  $($D.pattern): confidence $($D.confidence)" -ForegroundColor Yellow
            }
        }

        return $Stats
    }
}
