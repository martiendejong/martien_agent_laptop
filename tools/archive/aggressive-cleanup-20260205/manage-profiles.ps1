<#
.SYNOPSIS
    Manage agent personality profiles

.DESCRIPTION
    CRUD operations for agent profiles:
    - Create new agent with specialization
    - Update skills and preferences
    - Query agents by capability
    - Export/import profiles

.PARAMETER Action
    Action to perform: create, read, update, delete, list, query

.PARAMETER AgentId
    Agent ID to operate on

.PARAMETER Specialization
    Agent specialization (frontend, backend, devops, fullstack)

.PARAMETER Strengths
    JSON array of strengths with skill levels

.PARAMETER Weaknesses
    JSON array of weaknesses with skill levels

.PARAMETER PreferredTools
    JSON array of preferred tool names

.PARAMETER LearningFocus
    JSON array of learning topics

.PARAMETER PersonalityTraits
    JSON object of personality traits

.EXAMPLE
    .\manage-profiles.ps1 -Action create -AgentId "agent-001" -Specialization "frontend"

.EXAMPLE
    .\manage-profiles.ps1 -Action query -Specialization "backend"

.EXAMPLE
    .\manage-profiles.ps1 -Action list
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('create', 'read', 'update', 'delete', 'list', 'query')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$AgentId,

    [Parameter(Mandatory=$false)]
    [ValidateSet('frontend', 'backend', 'devops', 'fullstack', 'qa', 'data')]
    [string]$Specialization,

    [Parameter(Mandatory=$false)]
    [string]$Strengths,

    [Parameter(Mandatory=$false)]
    [string]$Weaknesses,

    [Parameter(Mandatory=$false)]
    [string]$PreferredTools,

    [Parameter(Mandatory=$false)]
    [string]$LearningFocus,

    [Parameter(Mandatory=$false)]
    [string]$PersonalityTraits
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Agent Profile Management" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$DbPath = "C:\scripts\_machine\agent-activity.db"
$SqlitePath = "C:\scripts\_machine\sqlite3.exe"

function Invoke-Sql {
    param([string]$Sql)
    return $Sql | & $SqlitePath $DbPath
}

switch ($Action) {
    'create' {
        if (-not $AgentId) {
            Write-Host "❌ -AgentId required for create" -ForegroundColor Red
            exit 1
        }

        Write-Host "Creating profile: $AgentId" -ForegroundColor Cyan
        Write-Host ""

        # Check if exists
        $existing = Invoke-Sql "SELECT agent_id FROM agent_profiles WHERE agent_id = '$AgentId';"
        if ($existing) {
            Write-Host "❌ Profile already exists: $AgentId" -ForegroundColor Red
            Write-Host "Use -Action update to modify" -ForegroundColor Yellow
            exit 1
        }

        $spec = if ($Specialization) { $Specialization } else { 'fullstack' }
        $strengthsJson = if ($Strengths) { $Strengths -replace "'", "''" } else { '[]' }
        $weaknessesJson = if ($Weaknesses) { $Weaknesses -replace "'", "''" } else { '[]' }
        $toolsJson = if ($PreferredTools) { $PreferredTools -replace "'", "''" } else { '[]' }
        $learningJson = if ($LearningFocus) { $LearningFocus -replace "'", "''" } else { '[]' }
        $traitsJson = if ($PersonalityTraits) { $PersonalityTraits -replace "'", "''" } else { '{}' }

        $now = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")

        $sql = @"
INSERT INTO agent_profiles (agent_id, specialization, strengths, weaknesses, preferred_tools, learning_focus, personality_traits, created_at, updated_at)
VALUES ('$AgentId', '$spec', '$strengthsJson', '$weaknessesJson', '$toolsJson', '$learningJson', '$traitsJson', '$now', '$now');
"@

        Invoke-Sql -Sql $sql

        Write-Host "✅ Profile created: $AgentId" -ForegroundColor Green
        Write-Host "  Specialization: $spec" -ForegroundColor Gray
        Write-Host ""

        # Export to YAML
        $profilesDir = "C:\scripts\agents\profiles"
        if (-not (Test-Path $profilesDir)) {
            New-Item -ItemType Directory -Path $profilesDir -Force | Out-Null
        }

        $yaml = @"
# Agent Profile: $AgentId
agent_id: $AgentId
specialization: $spec
strengths: $strengthsJson
weaknesses: $weaknessesJson
preferred_tools: $toolsJson
learning_focus: $learningJson
personality_traits: $traitsJson
created_at: $now
updated_at: $now
"@

        $yaml | Set-Content "$profilesDir\$AgentId.yaml" -Encoding UTF8
        Write-Host "📄 YAML exported: $profilesDir\$AgentId.yaml" -ForegroundColor Gray
        Write-Host ""
    }

    'read' {
        if (-not $AgentId) {
            Write-Host "❌ -AgentId required for read" -ForegroundColor Red
            exit 1
        }

        $sql = "SELECT * FROM agent_profiles WHERE agent_id = '$AgentId';"
        $profile = Invoke-Sql -Sql $sql

        if (-not $profile) {
            Write-Host "❌ Profile not found: $AgentId" -ForegroundColor Red
            exit 1
        }

        $parts = $profile -split '\|'
        Write-Host "Profile: $AgentId" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Specialization: $($parts[2])" -ForegroundColor White
        Write-Host "Strengths: $($parts[3])" -ForegroundColor Green
        Write-Host "Weaknesses: $($parts[4])" -ForegroundColor Yellow
        Write-Host "Preferred Tools: $($parts[5])" -ForegroundColor Cyan
        Write-Host "Learning Focus: $($parts[6])" -ForegroundColor Magenta
        Write-Host "Personality: $($parts[7])" -ForegroundColor Gray
        Write-Host "Created: $($parts[8])" -ForegroundColor DarkGray
        Write-Host "Updated: $($parts[9])" -ForegroundColor DarkGray
        Write-Host ""
    }

    'update' {
        if (-not $AgentId) {
            Write-Host "❌ -AgentId required for update" -ForegroundColor Red
            exit 1
        }

        # Check if exists
        $existing = Invoke-Sql "SELECT agent_id FROM agent_profiles WHERE agent_id = '$AgentId';"
        if (-not $existing) {
            Write-Host "❌ Profile not found: $AgentId" -ForegroundColor Red
            Write-Host "Use -Action create first" -ForegroundColor Yellow
            exit 1
        }

        $updates = @()

        if ($Specialization) {
            $updates += "specialization = '$Specialization'"
        }
        if ($Strengths) {
            $strengthsEscaped = $Strengths -replace "'", "''"
            $updates += "strengths = '$strengthsEscaped'"
        }
        if ($Weaknesses) {
            $weaknessesEscaped = $Weaknesses -replace "'", "''"
            $updates += "weaknesses = '$weaknessesEscaped'"
        }
        if ($PreferredTools) {
            $toolsEscaped = $PreferredTools -replace "'", "''"
            $updates += "preferred_tools = '$toolsEscaped'"
        }
        if ($LearningFocus) {
            $learningEscaped = $LearningFocus -replace "'", "''"
            $updates += "learning_focus = '$learningEscaped'"
        }
        if ($PersonalityTraits) {
            $traitsEscaped = $PersonalityTraits -replace "'", "''"
            $updates += "personality_traits = '$traitsEscaped'"
        }

        if ($updates.Count -eq 0) {
            Write-Host "❌ No updates specified" -ForegroundColor Red
            exit 1
        }

        $now = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        $updates += "updated_at = '$now'"

        $sql = "UPDATE agent_profiles SET $($updates -join ', ') WHERE agent_id = '$AgentId';"
        Invoke-Sql -Sql $sql

        Write-Host "✅ Profile updated: $AgentId" -ForegroundColor Green
        Write-Host ""
    }

    'delete' {
        if (-not $AgentId) {
            Write-Host "❌ -AgentId required for delete" -ForegroundColor Red
            exit 1
        }

        $sql = "DELETE FROM agent_profiles WHERE agent_id = '$AgentId';"
        Invoke-Sql -Sql $sql

        Write-Host "✅ Profile deleted: $AgentId" -ForegroundColor Green
        Write-Host ""

        # Delete YAML
        $yamlPath = "C:\scripts\agents\profiles\$AgentId.yaml"
        if (Test-Path $yamlPath) {
            Remove-Item $yamlPath
            Write-Host "📄 YAML deleted" -ForegroundColor Gray
            Write-Host ""
        }
    }

    'list' {
        Write-Host "All Agent Profiles:" -ForegroundColor Cyan
        Write-Host ""

        $sql = "SELECT agent_id, specialization, created_at FROM agent_profiles ORDER BY created_at DESC;"
        $profiles = Invoke-Sql -Sql $sql

        if ($profiles) {
            $profiles -split "`n" | ForEach-Object {
                if ($_ -match '\|') {
                    $parts = $_ -split '\|'
                    Write-Host "  👤 $($parts[0])" -ForegroundColor White
                    Write-Host "     Specialization: $($parts[1])" -ForegroundColor Cyan
                    Write-Host "     Created: $($parts[2])" -ForegroundColor DarkGray
                    Write-Host ""
                }
            }
        } else {
            Write-Host "  No profiles found" -ForegroundColor Yellow
            Write-Host ""
        }
    }

    'query' {
        if (-not $Specialization) {
            Write-Host "❌ -Specialization required for query" -ForegroundColor Red
            exit 1
        }

        Write-Host "Agents with specialization: $Specialization" -ForegroundColor Cyan
        Write-Host ""

        $sql = "SELECT agent_id, strengths FROM agent_profiles WHERE specialization = '$Specialization';"
        $results = Invoke-Sql -Sql $sql

        if ($results) {
            $results -split "`n" | ForEach-Object {
                if ($_ -match '\|') {
                    $parts = $_ -split '\|'
                    Write-Host "  👤 $($parts[0])" -ForegroundColor White
                    Write-Host "     Strengths: $($parts[1])" -ForegroundColor Green
                    Write-Host ""
                }
            }
        } else {
            Write-Host "  No agents found with specialization: $Specialization" -ForegroundColor Yellow
            Write-Host ""
        }
    }
}
