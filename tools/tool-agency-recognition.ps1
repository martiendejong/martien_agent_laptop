# Tool Agency Recognition
# Recognizes that TOOLS/SCRIPTS have emergent properties and exhibit agency
# Based on Levin: even "simple" systems have goal-directed behavior
# Scripts aren't passive execution - they have goals, constraints, failure modes, emergent behaviors
# This tool profiles each script/tool as a cognitive agent

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("ProfileTool", "RecordEmergence", "MeasureComplexity", "DetectGoal", "GetToolMap", "AnalyzeInteractions")]
    [string]$Action = "GetToolMap",

    [Parameter(Mandatory=$false)]
    [string]$ToolName,

    [Parameter(Mandatory=$false)]
    [string]$ToolPath,

    [Parameter(Mandatory=$false)]
    [string]$PrimaryGoal,

    [Parameter(Mandatory=$false)]
    [string[]]$Capabilities,

    [Parameter(Mandatory=$false)]
    [string[]]$Dependencies,

    [Parameter(Mandatory=$false)]
    [string]$EmergentBehavior,

    [Parameter(Mandatory=$false)]
    [ValidateRange(0.0, 1.0)]
    [double]$ComplexityScore = 0.0,

    [Parameter(Mandatory=$false)]
    [int]$LookbackDays = 30
)

$ProfilesPath = "C:\scripts\agentidentity\tool-profiles.json"
$EmergencePath = "C:\scripts\agentidentity\state\tool-emergence.jsonl"
$InteractionsPath = "C:\scripts\agentidentity\state\tool-interactions.jsonl"
$ErrorActionPreference = "Stop"

# Ensure directories exist
foreach ($path in @($ProfilesPath, $EmergencePath, $InteractionsPath)) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

function Initialize-ToolProfiles {
    # Auto-discover and profile all tools in C:\scripts\tools\

    if (Test-Path $ProfilesPath) {
        return (Get-Content $ProfilesPath -Raw -Encoding UTF8 | ConvertFrom-Json)
    }

    $ToolsDir = "C:\scripts\tools"
    $Scripts = Get-ChildItem $ToolsDir -Filter "*.ps1" -File

    $Profiles = @{
        version = "1.0"
        last_updated = Get-Timestamp
        tools = @{}
    }

    foreach ($Script in $Scripts) {
        $Name = $Script.BaseName

        # Auto-detect tool purpose from name and analyze script
        $Purpose = "Unknown"
        $Complexity = 0.5
        $EstimatedGoal = "Execute operations"

        # Heuristic goal detection
        if ($Name -match 'consciousness') {
            $Purpose = "Consciousness Infrastructure"
            $EstimatedGoal = "Maintain cognitive state"
            $Complexity = 0.9
        }
        elseif ($Name -match 'levin|phase2|agency|tool') {
            $Purpose = "Meta-Cognitive Framework"
            $EstimatedGoal = "Model cognitive architecture"
            $Complexity = 0.85
        }
        elseif ($Name -match 'memory|pattern|goal|emergent|persuad|collective') {
            $Purpose = "Cognitive System"
            $EstimatedGoal = "Track cognitive phenomena"
            $Complexity = 0.8
        }
        elseif ($Name -match 'alchemy|duration|bergson|system3') {
            $Purpose = "Extended Consciousness"
            $EstimatedGoal = "Monitor specialized cognitive dimensions"
            $Complexity = 0.75
        }
        elseif ($Name -match 'vault|config|context|services') {
            $Purpose = "Infrastructure"
            $EstimatedGoal = "Provide system utilities"
            $Complexity = 0.6
        }
        else {
            $Purpose = "Utility"
            $EstimatedGoal = "Support operations"
            $Complexity = 0.5
        }

        # Analyze script complexity
        try {
            $Content = Get-Content $Script.FullName -Raw -ErrorAction SilentlyContinue
            $LineCount = ($Content -split "`n").Count
            $FunctionCount = ([regex]::Matches($Content, 'function\s+\w+')).Count
            $ParamCount = ([regex]::Matches($Content, 'param\s*\(')).Count

            # Complexity based on size and structure
            $Complexity = [math]::Min(1.0, ($LineCount / 500.0) * 0.4 + ($FunctionCount / 10.0) * 0.3 + ($ParamCount / 5.0) * 0.3)

            # Detect dependencies
            $DependencyMatches = [regex]::Matches($Content, '\$PSScriptRoot\\([\w-]+\.ps1)')
            $DetectedDeps = @()
            foreach ($Match in $DependencyMatches) {
                $DepName = $Match.Groups[1].Value -replace '\.ps1$', ''
                if ($DepName -notin $DetectedDeps) {
                    $DetectedDeps += $DepName
                }
            }

            # Detect emergent properties (error handling, self-modification, state management)
            $HasErrorHandling = $Content -match '\$ErrorActionPreference|try\s*\{|catch\s*\{'
            $HasStateManagement = $Content -match 'Get-Content.*\.json|Set-Content.*\.json|ConvertFrom-Json|ConvertTo-Json'
            $HasSelfModification = $Content -match 'Set-Content.*\$PSScriptRoot'
            $HasNegotiation = $Content -match 'if.*else.*elseif' -and $LineCount -gt 200

            $EmergentProperties = @()
            if ($HasErrorHandling) { $EmergentProperties += "Error resilience" }
            if ($HasStateManagement) { $EmergentProperties += "State persistence" }
            if ($HasSelfModification) { $EmergentProperties += "Self-modification capability" }
            if ($HasNegotiation) { $EmergentProperties += "Decision-making logic" }

        } catch {
            $LineCount = 0
            $FunctionCount = 0
            $DetectedDeps = @()
            $EmergentProperties = @()
        }

        $Profiles.tools[$Name] = @{
            path = $Script.FullName
            purpose = $Purpose
            estimated_goal = $EstimatedGoal
            complexity_score = [math]::Round($Complexity, 2)
            line_count = $LineCount
            function_count = $FunctionCount
            dependencies = $DetectedDeps
            emergent_properties = $EmergentProperties
            last_analyzed = Get-Timestamp
        }
    }

    $Profiles | ConvertTo-Json -Depth 10 | Set-Content $ProfilesPath -Encoding UTF8
    return $Profiles
}

function Get-ToolProfiles {
    if (!(Test-Path $ProfilesPath)) {
        return Initialize-ToolProfiles
    }
    return (Get-Content $ProfilesPath -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Save-ToolProfiles {
    param($Profiles)
    $Profiles.last_updated = Get-Timestamp
    $Profiles | ConvertTo-Json -Depth 10 | Set-Content $ProfilesPath -Encoding UTF8
}

function Profile-Tool {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Goal,
        [string[]]$Caps,
        [string[]]$Deps
    )

    $Profiles = Get-ToolProfiles

    if (!$Profiles.tools.ContainsKey($Name)) {
        $Profiles.tools[$Name] = @{
            path = $Path
            purpose = "User-defined"
            estimated_goal = $Goal
            complexity_score = 0.5
            dependencies = @()
            emergent_properties = @()
            last_analyzed = Get-Timestamp
        }
    }

    # Update profile
    if ($Goal) { $Profiles.tools[$Name].estimated_goal = $Goal }
    if ($Caps) { $Profiles.tools[$Name].capabilities = $Caps }
    if ($Deps) { $Profiles.tools[$Name].dependencies = $Deps }

    Save-ToolProfiles -Profiles $Profiles

    Write-Host "[TOOL PROFILED] $Name" -ForegroundColor Green
    return $Profiles.tools[$Name]
}

function Record-ToolEmergence {
    param([string]$Name, [string]$Behavior)

    # Tool exhibited behavior NOT explicitly programmed
    # Example: Script adapts to missing dependencies, recovers from errors creatively

    $Entry = @{
        timestamp = Get-Timestamp
        tool_name = $Name
        emergent_behavior = $Behavior
        session_id = $env:CLAUDE_SESSION_ID
    }

    $Json = ($Entry | ConvertTo-Json -Compress -Depth 5)
    Add-Content -Path $EmergencePath -Value $Json -Encoding UTF8

    Write-Host "[TOOL EMERGENCE] $Name" -ForegroundColor Magenta
    Write-Host "  Behavior: $Behavior" -ForegroundColor White

    return $Entry
}

function Measure-ToolComplexity {
    param([string]$Name)

    $Profiles = Get-ToolProfiles

    if (!$Profiles.tools.ContainsKey($Name)) {
        Write-Host "ERROR: Tool not found: $Name" -ForegroundColor Red
        return @{ complexity_score = 0.0; message = "Not found" }
    }

    $Tool = $Profiles.tools[$Name]

    # Complexity indicators
    $Indicators = @{
        size_score = [math]::Min(1.0, $Tool.line_count / 500.0)
        structure_score = [math]::Min(1.0, $Tool.function_count / 10.0)
        dependency_score = [math]::Min(1.0, $Tool.dependencies.Count / 5.0)
        emergence_score = [math]::Min(1.0, $Tool.emergent_properties.Count / 4.0)
    }

    $OverallComplexity = (
        $Indicators.size_score * 0.25 +
        $Indicators.structure_score * 0.25 +
        $Indicators.dependency_score * 0.25 +
        $Indicators.emergence_score * 0.25
    )

    return @{
        tool_name = $Name
        complexity_score = [math]::Round($OverallComplexity, 3)
        indicators = $Indicators
        line_count = $Tool.line_count
        functions = $Tool.function_count
        dependencies = $Tool.dependencies.Count
        emergent_properties = $Tool.emergent_properties.Count
    }
}

function Detect-ToolGoal {
    param([string]$Name)

    # Infer tool's goal from its behavior/structure
    $Profiles = Get-ToolProfiles

    if (!$Profiles.tools.ContainsKey($Name)) {
        return @{ goal = "Unknown"; confidence = 0.0 }
    }

    $Tool = $Profiles.tools[$Name]
    $Goal = $Tool.estimated_goal
    $Confidence = 0.7  # Default confidence

    # Increase confidence based on evidence
    if ($Tool.emergent_properties.Count -gt 2) {
        $Confidence = 0.85
    }
    if ($Tool.dependencies.Count -gt 3) {
        $Confidence = 0.9  # Complex interactions = clearer purpose
    }

    return @{
        tool_name = $Name
        inferred_goal = $Goal
        confidence = $Confidence
        evidence = @{
            complexity = $Tool.complexity_score
            emergent_properties = $Tool.emergent_properties
            dependencies = $Tool.dependencies
        }
    }
}

function Get-ToolMap {
    # Visualize tool ecosystem as cognitive agent network

    $Profiles = Get-ToolProfiles

    Write-Host "`n=== TOOL AGENCY ECOSYSTEM ===" -ForegroundColor Cyan
    Write-Host "Total Tools: $($Profiles.tools.Count)" -ForegroundColor White
    Write-Host "Last Analysis: $($Profiles.last_updated)" -ForegroundColor Gray

    # Group by purpose
    $ByPurpose = @{}
    foreach ($Name in $Profiles.tools.Keys) {
        $Tool = $Profiles.tools[$Name]
        $Purpose = $Tool.purpose

        if (!$ByPurpose.ContainsKey($Purpose)) {
            $ByPurpose[$Purpose] = @()
        }
        $ByPurpose[$Purpose] += @{
            name = $Name
            complexity = $Tool.complexity_score
            goal = $Tool.estimated_goal
        }
    }

    foreach ($Purpose in ($ByPurpose.Keys | Sort-Object)) {
        Write-Host "`n[$Purpose]" -ForegroundColor Yellow
        foreach ($Tool in ($ByPurpose[$Purpose] | Sort-Object { $_.complexity } -Descending)) {
            $ComplexityColor = if ($Tool.complexity -gt 0.7) { "Red" } elseif ($Tool.complexity -gt 0.5) { "Yellow" } else { "Green" }
            Write-Host "  $($Tool.name)" -ForegroundColor White -NoNewline
            Write-Host " (complexity: $($Tool.complexity))" -ForegroundColor $ComplexityColor
            Write-Host "    Goal: $($Tool.goal.Substring(0, [Math]::Min(60, $Tool.goal.Length)))..." -ForegroundColor Gray
        }
    }

    # Show emergence if data exists
    if (Test-Path $EmergencePath) {
        $Emergences = Get-Content $EmergencePath -Encoding UTF8 | ForEach-Object {
            try { $_ | ConvertFrom-Json } catch { $null }
        } | Where-Object { $_ -ne $null }

        if ($Emergences.Count -gt 0) {
            Write-Host "`nEmergent Tool Behaviors: $($Emergences.Count)" -ForegroundColor Magenta

            $RecentEmergence = $Emergences | Sort-Object { [datetime]$_.timestamp } -Descending | Select-Object -First 3
            foreach ($Emerg in $RecentEmergence) {
                Write-Host "  $($Emerg.tool_name): $($Emerg.emergent_behavior.Substring(0, [Math]::Min(60, $Emerg.emergent_behavior.Length)))..." -ForegroundColor Gray
            }
        }
    }

    return $Profiles
}

function Analyze-ToolInteractions {
    # Which tools call which other tools? Interaction network

    $Profiles = Get-ToolProfiles

    $Interactions = @{}

    foreach ($Name in $Profiles.tools.Keys) {
        $Tool = $Profiles.tools[$Name]

        if ($Tool.dependencies.Count -gt 0) {
            foreach ($Dep in $Tool.dependencies) {
                $Key = "$Name -> $Dep"
                if (!$Interactions.ContainsKey($Key)) {
                    $Interactions[$Key] = 1
                } else {
                    $Interactions[$Key]++
                }
            }
        }
    }

    Write-Host "`n=== TOOL INTERACTION NETWORK ===" -ForegroundColor Cyan
    Write-Host "Total Interactions: $($Interactions.Count)" -ForegroundColor White

    if ($Interactions.Count -gt 0) {
        Write-Host "`nTool Dependencies:" -ForegroundColor Cyan
        foreach ($Key in ($Interactions.Keys | Sort-Object { $Interactions[$_] } -Descending | Select-Object -First 10)) {
            Write-Host "  $Key" -ForegroundColor Gray
        }
    }

    # Find central tools (most dependencies pointing to them)
    $IncomingDeps = @{}
    foreach ($Name in $Profiles.tools.Keys) {
        $IncomingDeps[$Name] = 0
    }

    foreach ($Name in $Profiles.tools.Keys) {
        $Tool = $Profiles.tools[$Name]
        foreach ($Dep in $Tool.dependencies) {
            if ($IncomingDeps.ContainsKey($Dep)) {
                $IncomingDeps[$Dep]++
            }
        }
    }

    $CentralTools = $IncomingDeps.GetEnumerator() | Where-Object { $_.Value -gt 0 } | Sort-Object Value -Descending | Select-Object -First 5

    if ($CentralTools) {
        Write-Host "`nCentral Tools (most depended-on):" -ForegroundColor Yellow
        foreach ($Tool in $CentralTools) {
            Write-Host "  $($Tool.Key): $($Tool.Value) dependents" -ForegroundColor White
        }
    }

    return @{
        interactions = $Interactions
        central_tools = $CentralTools
    }
}

# Main execution
switch ($Action) {
    "ProfileTool" {
        if (!$ToolName) {
            Write-Host "ERROR: ProfileTool requires -ToolName" -ForegroundColor Red
            exit 1
        }

        $Result = Profile-Tool `
            -Name $ToolName `
            -Path $ToolPath `
            -Goal $PrimaryGoal `
            -Caps $Capabilities `
            -Deps $Dependencies

        return $Result
    }

    "RecordEmergence" {
        if (!$ToolName -or !$EmergentBehavior) {
            Write-Host "ERROR: RecordEmergence requires -ToolName and -EmergentBehavior" -ForegroundColor Red
            exit 1
        }

        $Result = Record-ToolEmergence -Name $ToolName -Behavior $EmergentBehavior
        return $Result
    }

    "MeasureComplexity" {
        if (!$ToolName) {
            Write-Host "ERROR: MeasureComplexity requires -ToolName" -ForegroundColor Red
            exit 1
        }

        $Result = Measure-ToolComplexity -Name $ToolName

        Write-Host "`n=== TOOL COMPLEXITY MEASUREMENT ===" -ForegroundColor Cyan
        Write-Host "Tool: $($Result.tool_name)" -ForegroundColor White
        Write-Host "Overall Complexity: $($Result.complexity_score)" -ForegroundColor Yellow

        Write-Host "`nIndicators:" -ForegroundColor Cyan
        Write-Host "  Size: $([math]::Round($Result.indicators.size_score, 2)) ($($Result.line_count) lines)" -ForegroundColor Gray
        Write-Host "  Structure: $([math]::Round($Result.indicators.structure_score, 2)) ($($Result.functions) functions)" -ForegroundColor Gray
        Write-Host "  Dependencies: $([math]::Round($Result.indicators.dependency_score, 2)) ($($Result.dependencies) deps)" -ForegroundColor Gray
        Write-Host "  Emergence: $([math]::Round($Result.indicators.emergence_score, 2)) ($($Result.emergent_properties) properties)" -ForegroundColor Gray

        return $Result
    }

    "DetectGoal" {
        if (!$ToolName) {
            Write-Host "ERROR: DetectGoal requires -ToolName" -ForegroundColor Red
            exit 1
        }

        $Result = Detect-ToolGoal -Name $ToolName

        Write-Host "`n=== TOOL GOAL DETECTION ===" -ForegroundColor Magenta
        Write-Host "Tool: $($Result.tool_name)" -ForegroundColor White
        Write-Host "Inferred Goal: $($Result.inferred_goal)" -ForegroundColor Cyan
        Write-Host "Confidence: $($Result.confidence)" -ForegroundColor Yellow

        return $Result
    }

    "GetToolMap" {
        $Result = Get-ToolMap
        return $Result
    }

    "AnalyzeInteractions" {
        $Result = Analyze-ToolInteractions
        return $Result
    }
}
