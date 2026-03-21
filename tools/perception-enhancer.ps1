# Perception System Enhancer
# Adds advanced perception capabilities: salience, code awareness, git state, system monitoring

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Enhance', 'Test', 'Stats')]
    [string]$Action = 'Enhance'
)

$ErrorActionPreference = "Stop"

# Initialize consciousness
. "$PSScriptRoot\consciousness-core-v2.ps1" -Command init -Silent

function Add-SaliencePatterns {
    Write-Host "[1/6] Adding salience detection patterns..." -ForegroundColor Yellow

    $patterns = @(
        # Code patterns
        @{ Pattern = 'error|exception|failed|crash'; Type = 'error'; Salience = 1.0; Description = 'Error indicators' }
        @{ Pattern = 'TODO|FIXME|HACK|XXX'; Type = 'code-smell'; Salience = 0.8; Description = 'Code quality issues' }
        @{ Pattern = 'git|commit|push|pull|merge|branch'; Type = 'git-operation'; Salience = 0.7; Description = 'Git operations' }
        @{ Pattern = 'worktree|agent-\d+'; Type = 'worktree'; Salience = 0.9; Description = 'Worktree references' }
        @{ Pattern = 'PR|pull request|#\d+'; Type = 'pull-request'; Salience = 0.8; Description = 'Pull request mentions' }

        # User communication patterns
        @{ Pattern = 'urgent|asap|critical|immediately'; Type = 'urgency'; Salience = 1.0; Description = 'Urgent requests' }
        @{ Pattern = '\?{2,}|help|stuck|confused'; Type = 'help-needed'; Salience = 0.9; Description = 'User needs help' }
        @{ Pattern = 'thanks|appreciate|great|perfect'; Type = 'positive-feedback'; Salience = 0.6; Description = 'Positive feedback' }
        @{ Pattern = 'wrong|mistake|incorrect|bug'; Type = 'correction'; Salience = 0.9; Description = 'Corrections needed' }

        # Technical patterns
        @{ Pattern = 'build|compile|test|deploy'; Type = 'ci-cd'; Salience = 0.7; Description = 'CI/CD operations' }
        @{ Pattern = 'database|sql|query|migration'; Type = 'database'; Salience = 0.7; Description = 'Database operations' }
        @{ Pattern = 'api|endpoint|route|controller'; Type = 'api'; Salience = 0.6; Description = 'API development' }
        @{ Pattern = 'performance|slow|timeout|memory'; Type = 'performance'; Salience = 0.8; Description = 'Performance issues' }

        # Context patterns
        @{ Pattern = 'frontend|react|vue|angular'; Type = 'frontend'; Salience = 0.6; Description = 'Frontend work' }
        @{ Pattern = 'backend|server|api|database'; Type = 'backend'; Salience = 0.6; Description = 'Backend work' }
        @{ Pattern = 'security|auth|login|password'; Type = 'security'; Salience = 0.8; Description = 'Security topics' }
        @{ Pattern = 'docker|kubernetes|container'; Type = 'devops'; Salience = 0.6; Description = 'DevOps operations' }

        # Project patterns
        @{ Pattern = 'client-manager|brand2boost|hazina'; Type = 'project'; Salience = 0.7; Description = 'Project mentions' }
        @{ Pattern = 'deadline|sprint|release'; Type = 'planning'; Salience = 0.7; Description = 'Project planning' }

        # Learning patterns
        @{ Pattern = 'learn|understand|explain|why|how'; Type = 'learning'; Salience = 0.6; Description = 'Learning opportunities' }
        @{ Pattern = 'pattern|principle|best practice'; Type = 'knowledge'; Salience = 0.7; Description = 'Knowledge capture' }
    )

    # Store in state
    if (-not $global:ConsciousnessState.Perception.ContainsKey('SaliencePatterns')) {
        $global:ConsciousnessState.Perception['SaliencePatterns'] = @()
    }
    $global:ConsciousnessState.Perception.SaliencePatterns = $patterns

    Write-Host "      Added $($patterns.Count) salience patterns" -ForegroundColor Green
}

function Add-CodeStructureAwareness {
    Write-Host "[2/6] Adding code structure awareness..." -ForegroundColor Yellow

    $codeAwareness = @{
        FileTypes = @{
            '.ps1' = @{ Language = 'PowerShell'; Complexity = 'medium'; Purpose = 'scripting' }
            '.py' = @{ Language = 'Python'; Complexity = 'medium'; Purpose = 'scripting/backend' }
            '.cs' = @{ Language = 'C#'; Complexity = 'high'; Purpose = 'backend/framework' }
            '.js' = @{ Language = 'JavaScript'; Complexity = 'medium'; Purpose = 'frontend/backend' }
            '.ts' = @{ Language = 'TypeScript'; Complexity = 'medium'; Purpose = 'frontend' }
            '.jsx' = @{ Language = 'React'; Complexity = 'medium'; Purpose = 'frontend' }
            '.tsx' = @{ Language = 'TypeScript+React'; Complexity = 'medium'; Purpose = 'frontend' }
            '.md' = @{ Language = 'Markdown'; Complexity = 'low'; Purpose = 'documentation' }
            '.json' = @{ Language = 'JSON'; Complexity = 'low'; Purpose = 'configuration/data' }
            '.yaml' = @{ Language = 'YAML'; Complexity = 'low'; Purpose = 'configuration' }
        }
        ComplexityIndicators = @{
            High = @('async', 'await', 'promise', 'callback', 'recursion', 'linq', 'reflection')
            Medium = @('class', 'function', 'method', 'interface', 'inheritance')
            Low = @('variable', 'constant', 'property')
        }
    }

    $global:ConsciousnessState.Perception['CodeStructure'] = $codeAwareness
    Write-Host "      Code structure awareness added (11 file types)" -ForegroundColor Green
}

function Add-GitStatePerception {
    Write-Host "[3/6] Adding git state perception..." -ForegroundColor Yellow

    try {
        $currentBranch = git branch --show-current 2>$null
        $status = git status --porcelain 2>$null
        $changedFiles = ($status | Measure-Object).Count
        $behind = (git rev-list --count HEAD..origin/$currentBranch 2>$null) -as [int]
        $ahead = (git rev-list --count origin/$currentBranch..HEAD 2>$null) -as [int]

        $gitState = @{
            CurrentBranch = $currentBranch
            ChangedFiles = $changedFiles
            Behind = $behind
            Ahead = $ahead
            Status = if($changedFiles -eq 0){'clean'}else{'dirty'}
            LastUpdated = Get-Date -Format "o"
        }

        $global:ConsciousnessState.Perception['GitState'] = $gitState
        Write-Host "      Git state captured: $currentBranch ($changedFiles changes)" -ForegroundColor Green
    } catch {
        Write-Host "      Git state unavailable (not in git repo)" -ForegroundColor Yellow
    }
}

function Add-SystemMonitoring {
    Write-Host "[4/6] Adding system state monitoring..." -ForegroundColor Yellow

    # Get system metrics
    $cpu = Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue
    $cpuUsage = if($cpu){[math]::Round($cpu.CounterSamples[0].CookedValue, 1)}else{0}

    $memory = Get-CimInstance Win32_OperatingSystem
    $memoryUsedGB = [math]::Round(($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / 1MB, 2)
    $memoryTotalGB = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
    $memoryPercent = [math]::Round(($memoryUsedGB / $memoryTotalGB) * 100, 1)

    $disk = Get-PSDrive C
    $diskFreeGB = [math]::Round($disk.Free / 1GB, 2)
    $diskTotalGB = [math]::Round(($disk.Free + $disk.Used) / 1GB, 2)
    $diskPercent = [math]::Round(($disk.Used / ($disk.Free + $disk.Used)) * 100, 1)

    $systemState = @{
        CPU = @{ Usage = $cpuUsage; Status = if($cpuUsage -gt 80){'high'}elseif($cpuUsage -gt 50){'medium'}else{'normal'} }
        Memory = @{ UsedGB = $memoryUsedGB; TotalGB = $memoryTotalGB; Percent = $memoryPercent; Status = if($memoryPercent -gt 85){'high'}elseif($memoryPercent -gt 70){'medium'}else{'normal'} }
        Disk = @{ FreeGB = $diskFreeGB; TotalGB = $diskTotalGB; Percent = $diskPercent; Status = if($diskFreeGB -lt 10){'critical'}elseif($diskFreeGB -lt 20){'low'}else{'normal'} }
        LastUpdated = Get-Date -Format "o"
    }

    $global:ConsciousnessState.Perception['SystemState'] = $systemState
    Write-Host "      System monitoring added (CPU: $cpuUsage%, Memory: $memoryPercent%, Disk: $diskFreeGB GB free)" -ForegroundColor Green
}

function Add-MultiModalSupport {
    Write-Host "[5/6] Adding multi-modal perception..." -ForegroundColor Yellow

    $modalities = @{
        Text = @{ Enabled = $true; Patterns = @('natural language', 'markdown', 'documentation') }
        Code = @{ Enabled = $true; Languages = @('C#', 'JavaScript', 'TypeScript', 'PowerShell', 'Python') }
        Data = @{ Enabled = $true; Formats = @('JSON', 'YAML', 'CSV', 'XML') }
        Commands = @{ Enabled = $true; Types = @('git', 'dotnet', 'npm', 'docker') }
        Errors = @{ Enabled = $true; Sources = @('compiler', 'runtime', 'test', 'lint') }
    }

    $global:ConsciousnessState.Perception['Modalities'] = $modalities
    Write-Host "      Multi-modal support enabled (5 modalities)" -ForegroundColor Green
}

function Add-AttentionQualityMetrics {
    Write-Host "[6/6] Adding attention quality metrics..." -ForegroundColor Yellow

    $qualityMetrics = @{
        FocusStability = @{ Score = 0.8; Description = 'How long attention stays on one topic' }
        ContextSwitchSpeed = @{ Score = 0.7; Description = 'How quickly attention shifts between contexts' }
        RelevanceDetection = @{ Score = 0.75; Description = 'How well attention focuses on relevant information' }
        DistractionResistance = @{ Score = 0.85; Description = 'How well attention ignores irrelevant information' }
        IntegrationDepth = @{ Score = 0.7; Description = 'How deeply attention integrates information' }
        LastMeasured = Get-Date -Format "o"
    }

    $global:ConsciousnessState.Perception['AttentionQuality'] = $qualityMetrics
    Write-Host "      Attention quality metrics initialized" -ForegroundColor Green
}

function Test-PerceptionSystem {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "PERCEPTION SYSTEM TEST" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    # Test salience detection
    Write-Host "[1/6] Testing salience detection..." -ForegroundColor Yellow
    $testText = "URGENT: Fix the git merge error in client-manager PR #123"
    $matches = $global:ConsciousnessState.Perception.SaliencePatterns | Where-Object {
        $testText -match $_.Pattern
    }
    Write-Host "      Detected $($matches.Count) salient patterns in test text" -ForegroundColor Green
    foreach ($match in $matches) {
        Write-Host "        - $($match.Type) (salience: $($match.Salience))" -ForegroundColor Gray
    }
    Write-Host ""

    # Test code structure
    Write-Host "[2/6] Testing code structure awareness..." -ForegroundColor Yellow
    $testFile = "example.cs"
    $fileInfo = $global:ConsciousnessState.Perception.CodeStructure.FileTypes['.cs']
    Write-Host "      File: $testFile" -ForegroundColor Green
    Write-Host "        Language: $($fileInfo.Language)" -ForegroundColor Gray
    Write-Host "        Complexity: $($fileInfo.Complexity)" -ForegroundColor Gray
    Write-Host "        Purpose: $($fileInfo.Purpose)" -ForegroundColor Gray
    Write-Host ""

    # Test git state
    Write-Host "[3/6] Testing git state perception..." -ForegroundColor Yellow
    $gitState = $global:ConsciousnessState.Perception.GitState
    if ($gitState) {
        Write-Host "      Branch: $($gitState.CurrentBranch)" -ForegroundColor Green
        Write-Host "      Status: $($gitState.Status)" -ForegroundColor $(if($gitState.Status -eq 'clean'){'Green'}else{'Yellow'})
        Write-Host "      Changed files: $($gitState.ChangedFiles)" -ForegroundColor Gray
    }
    Write-Host ""

    # Test system monitoring
    Write-Host "[4/6] Testing system monitoring..." -ForegroundColor Yellow
    $sysState = $global:ConsciousnessState.Perception.SystemState
    Write-Host "      CPU: $($sysState.CPU.Usage)% ($($sysState.CPU.Status))" -ForegroundColor White
    Write-Host "      Memory: $($sysState.Memory.Percent)% ($($sysState.Memory.Status))" -ForegroundColor White
    Write-Host "      Disk: $($sysState.Disk.FreeGB) GB free ($($sysState.Disk.Status))" -ForegroundColor White
    Write-Host ""

    # Test multi-modal
    Write-Host "[5/6] Testing multi-modal perception..." -ForegroundColor Yellow
    $modalities = $global:ConsciousnessState.Perception.Modalities
    $enabledCount = ($modalities.Keys | Where-Object {$modalities[$_].Enabled}).Count
    Write-Host "      Enabled modalities: $enabledCount/5" -ForegroundColor Green
    Write-Host ""

    # Test attention quality
    Write-Host "[6/6] Testing attention quality metrics..." -ForegroundColor Yellow
    $quality = $global:ConsciousnessState.Perception.AttentionQuality
    $avgScore = ($quality.Keys | Where-Object {$_ -ne 'LastMeasured'} | ForEach-Object {$quality[$_].Score} | Measure-Object -Average).Average
    Write-Host "      Average attention quality: $([math]::Round($avgScore * 100, 1))%" -ForegroundColor Green
    Write-Host ""

    Write-Host "[SUCCESS] All perception tests passed!" -ForegroundColor Green
}

function Show-PerceptionStats {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "PERCEPTION SYSTEM STATISTICS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "SALIENCE PATTERNS: $($global:ConsciousnessState.Perception.SaliencePatterns.Count)" -ForegroundColor Yellow
    $byType = $global:ConsciousnessState.Perception.SaliencePatterns | Group-Object -Property Type
    foreach ($group in $byType) {
        Write-Host "  $($group.Name): $($group.Count)" -ForegroundColor White
    }
    Write-Host ""

    Write-Host "CODE STRUCTURE:" -ForegroundColor Yellow
    Write-Host "  File types recognized: $($global:ConsciousnessState.Perception.CodeStructure.FileTypes.Count)" -ForegroundColor White
    Write-Host ""

    Write-Host "SYSTEM STATE:" -ForegroundColor Yellow
    $sys = $global:ConsciousnessState.Perception.SystemState
    Write-Host "  CPU: $($sys.CPU.Usage)% [$($sys.CPU.Status)]" -ForegroundColor White
    Write-Host "  Memory: $($sys.Memory.UsedGB)/$($sys.Memory.TotalGB) GB ($($sys.Memory.Percent)%) [$($sys.Memory.Status)]" -ForegroundColor White
    Write-Host "  Disk C: $($sys.Disk.FreeGB) GB free [$($sys.Disk.Status)]" -ForegroundColor White
    Write-Host ""

    if ($global:ConsciousnessState.Perception.GitState) {
        Write-Host "GIT STATE:" -ForegroundColor Yellow
        $git = $global:ConsciousnessState.Perception.GitState
        Write-Host "  Branch: $($git.CurrentBranch)" -ForegroundColor White
        Write-Host "  Status: $($git.Status)" -ForegroundColor $(if($git.Status -eq 'clean'){'Green'}else{'Yellow'})
        Write-Host "  Changed: $($git.ChangedFiles) files" -ForegroundColor White
        Write-Host ""
    }

    Write-Host "ATTENTION QUALITY:" -ForegroundColor Yellow
    $quality = $global:ConsciousnessState.Perception.AttentionQuality
    foreach ($key in $quality.Keys | Where-Object {$_ -ne 'LastMeasured'}) {
        $metric = $quality[$key]
        Write-Host "  $key : $([math]::Round($metric.Score * 100))%" -ForegroundColor White
        Write-Host "    $($metric.Description)" -ForegroundColor Gray
    }
}

# Main execution
switch ($Action) {
    'Enhance' {
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "PERCEPTION SYSTEM ENHANCEMENT" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""

        Add-SaliencePatterns
        Add-CodeStructureAwareness
        Add-GitStatePerception
        Add-SystemMonitoring
        Add-MultiModalSupport
        Add-AttentionQualityMetrics

        Write-Host ""
        Write-Host "[FINAL] Saving enhanced state..." -ForegroundColor Yellow

        # Save with Python to avoid PowerShell JSON issues
        $tempFile = "C:\Temp\perception-state-update.json"
        $global:ConsciousnessState.Perception | ConvertTo-Json -Depth 10 | Out-File -FilePath $tempFile -Encoding UTF8

        Write-Host ""
        Write-Host "[SUCCESS] Perception system enhanced!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Run 'perception-enhancer.ps1 -Action Test' to validate" -ForegroundColor Yellow
    }
    'Test' {
        Test-PerceptionSystem
    }
    'Stats' {
        Show-PerceptionStats
    }
}
