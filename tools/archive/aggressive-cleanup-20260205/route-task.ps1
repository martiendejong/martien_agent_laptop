<#
.SYNOPSIS
    Intelligent task routing based on agent profiles

.DESCRIPTION
    Analyzes task requirements and routes to most suitable agent:
    - "Fix React rendering bug" → agent-001 (frontend specialist)
    - "Optimize database queries" → agent-002 (backend specialist)
    - "Set up CI/CD pipeline" → agent-003 (devops specialist)

    Uses agent profiles to match skills with task requirements.

.PARAMETER TaskDescription
    Description of the task to route

.PARAMETER RequiredSkills
    JSON array of required skills (optional)

.PARAMETER ShowReasoning
    Show why each agent was scored

.EXAMPLE
    .\route-task.ps1 -TaskDescription "Fix React rendering bug"

.EXAMPLE
    .\route-task.ps1 -TaskDescription "Optimize SQL queries" -RequiredSkills '["SQL", "Performance"]'
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskDescription,

    [Parameter(Mandatory=$false)]
    [string]$RequiredSkills,

    [Parameter(Mandatory=$false)]
    [switch]$ShowReasoning
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Intelligent Task Routing" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Task: $TaskDescription" -ForegroundColor White
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

# Keyword-based skill detection
function Detect-Skills {
    param([string]$Description)

    $skills = @{}

    # Frontend keywords
    if ($Description -match '(?i)(react|vue|angular|component|css|html|frontend|ui|ux)') {
        $skills['frontend'] = 10
    }

    # Backend keywords
    if ($Description -match '(?i)(api|backend|server|database|sql|entity\s+framework|repository|service)') {
        $skills['backend'] = 10
    }

    # DevOps keywords
    if ($Description -match '(?i)(deploy|ci/cd|pipeline|docker|kubernetes|infrastructure|github\s+actions)') {
        $skills['devops'] = 10
    }

    # Performance keywords
    if ($Description -match '(?i)(optimize|performance|speed|slow|n\+1|query)') {
        $skills['performance'] = 8
    }

    # Testing keywords
    if ($Description -match '(?i)(test|spec|unit|integration|e2e)') {
        $skills['testing'] = 8
    }

    # Bug fixing keywords
    if ($Description -match '(?i)(bug|fix|error|crash|issue)') {
        $skills['debugging'] = 8
    }

    # Refactoring keywords
    if ($Description -match '(?i)(refactor|clean|improve|modernize)') {
        $skills['refactoring'] = 7
    }

    return $skills
}

# Detect required skills
$detectedSkills = Detect-Skills -Description $TaskDescription

if ($RequiredSkills) {
    $explicitSkills = $RequiredSkills | ConvertFrom-Json
    foreach ($skill in $explicitSkills) {
        $detectedSkills[$skill] = 10
    }
}

if ($detectedSkills.Count -eq 0) {
    Write-Host "⚠️ Could not detect required skills from task description" -ForegroundColor Yellow
    Write-Host "   Task will be routed to fullstack agent" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Detected Skills:" -ForegroundColor Cyan
$detectedSkills.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object {
    Write-Host "  - $($_.Key): $($_.Value)/10" -ForegroundColor White
}
Write-Host ""

# Load all agent profiles
$sql = "SELECT agent_id, specialization, strengths FROM agent_profiles;"
$profiles = Invoke-Sql -Sql $sql

if (-not $profiles) {
    Write-Host "❌ No agent profiles found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Create profiles with:" -ForegroundColor Yellow
    Write-Host "  .\manage-profiles.ps1 -Action create -AgentId 'agent-001' -Specialization 'frontend'" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Score each agent
Write-Host "Scoring Agents:" -ForegroundColor Cyan
Write-Host ""

$agentScores = @()

$profiles -split "`n" | ForEach-Object {
    if ($_ -match '\|') {
        $parts = $_ -split '\|'
        $agentId = $parts[0]
        $spec = $parts[1]
        $strengths = $parts[2]

        $score = 0

        # Specialization match
        if ($detectedSkills.ContainsKey($spec)) {
            $score += $detectedSkills[$spec] * 2  # Double weight for specialization
        }

        # Parse strengths JSON
        try {
            $strengthsList = $strengths | ConvertFrom-Json
            foreach ($strength in $strengthsList) {
                $skillName = $strength.skill.ToLower()
                $skillLevel = $strength.level

                # Check if this skill is required
                foreach ($required in $detectedSkills.Keys) {
                    if ($skillName -match $required) {
                        $score += $skillLevel
                    }
                }
            }
        } catch {
            # Strengths not valid JSON - skip
        }

        $agentScores += @{
            agent_id = $agentId
            specialization = $spec
            score = $score
        }

        if ($ShowReasoning) {
            Write-Host "  👤 $agentId ($spec)" -ForegroundColor White
            Write-Host "     Score: $score" -ForegroundColor $(if ($score -gt 15) { 'Green' } elseif ($score -gt 5) { 'Yellow' } else { 'Gray' })
            Write-Host ""
        }
    }
}

# Sort by score
$agentScores = $agentScores | Sort-Object -Property score -Descending

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkCyan
Write-Host ""

# Recommend top agent
$bestAgent = $agentScores[0]

if ($bestAgent.score -eq 0) {
    Write-Host "⚠️ No agent has matching skills" -ForegroundColor Yellow
    Write-Host "   Routing to first available agent: $($bestAgent.agent_id)" -ForegroundColor Gray
} else {
    Write-Host "✅ Recommended Agent: $($bestAgent.agent_id)" -ForegroundColor Green
    Write-Host "   Specialization: $($bestAgent.specialization)" -ForegroundColor Cyan
    Write-Host "   Match Score: $($bestAgent.score)" -ForegroundColor White
}

Write-Host ""

if ($agentScores.Count -gt 1) {
    Write-Host "Alternatives:" -ForegroundColor Gray
    for ($i = 1; $i -lt [Math]::Min(3, $agentScores.Count); $i++) {
        $alt = $agentScores[$i]
        Write-Host "  $($i). $($alt.agent_id) ($($alt.specialization)) - Score: $($alt.score)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# Return best agent
return $bestAgent.agent_id
