# Architectural Context Reasoning System
# Purpose: Understand WHY systems exist and HOW they should be configured based on deployment context
# Created: 2026-03-02 (Session: Tailscale SSL insight)

<#
.SYNOPSIS
Reasoning layer that derives configuration requirements from architectural context.

.DESCRIPTION
Instead of just executing tasks, this system asks:
- WHY does this component exist?
- WHAT is its deployment context?
- WHO will use it and HOW?
- WHAT are the implications for configuration?

This enables PROACTIVE architecture decisions instead of REACTIVE fixes.

.EXAMPLE
Input: "Install Hazina Orchestration"
Reactive: Install files, done
Proactive:
  1. Understand purpose (remote Claude control)
  2. Detect context (Tailscale installed?)
  3. Configure appropriately (SSL cert if Tailscale)
  4. Document decision reasoning

.NOTES
This is a META-COGNITIVE layer - it reasons ABOUT systems, not just IN systems.
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Analyze', 'Reason', 'Configure', 'Document')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$System,

    [Parameter(Mandatory=$false)]
    [string]$Context,

    [Parameter(Mandatory=$false)]
    [hashtable]$Evidence = @{}
)

$StateFile = "$PSScriptRoot\..\state\architectural-context.json"

function Initialize-ArchitecturalContext {
    if (!(Test-Path $StateFile)) {
        $initialState = @{
            timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
            version = "1.0"
            systems = @{}
            patterns = @{}
            decisions = @()
        }
        $initialState | ConvertTo-Json -Depth 10 | Set-Content $StateFile
    }
    return Get-Content $StateFile | ConvertFrom-Json
}

function Get-SystemPurpose {
    param([string]$SystemName)

    # Knowledge base of system purposes
    $purposes = @{
        'Hazina' = @{
            purpose = 'Remote orchestration of Claude Code CLI instances'
            deployment_contexts = @('local-dev', 'tailscale-team', 'public-cloud', 'corporate-vpn')
            security_requirements = @{
                'local-dev' = 'minimal (self-signed OK)'
                'tailscale-team' = 'medium (Tailscale cert required)'
                'public-cloud' = 'high (Let''s Encrypt + firewall)'
                'corporate-vpn' = 'enterprise (internal CA + audit)'
            }
            configuration_dependencies = @{
                'tailscale-team' = @(
                    'Tailscale must be installed'
                    'SSL cert must be generated via tailscale cert'
                    'Kestrel must be configured for 0.0.0.0 (all interfaces)'
                    'Both localhost + Tailscale endpoints needed'
                )
            }
        }
        'Git' = @{
            purpose = 'Version control and collaboration'
            deployment_contexts = @('local-only', 'github-team', 'enterprise-gitlab')
            configuration_dependencies = @{
                'github-team' = @(
                    'SSH keys or PAT required'
                    'User name/email must be configured'
                    'Branch protection rules awareness'
                )
            }
        }
        'ClickUp' = @{
            purpose = 'Task management and workflow automation'
            deployment_contexts = @('personal', 'team-collaboration')
            configuration_dependencies = @{
                'team-collaboration' = @(
                    'API key with team scope'
                    'Workspace ID mapping'
                    'Member ID lookup for assignments'
                )
            }
        }
    }

    return $purposes[$SystemName]
}

function Invoke-ArchitecturalReasoning {
    param(
        [string]$System,
        [string]$DetectedContext,
        [hashtable]$Evidence
    )

    Write-Host "`n=== ARCHITECTURAL REASONING: $System ===" -ForegroundColor Cyan

    # Step 1: Understand purpose
    $systemInfo = Get-SystemPurpose $System
    if (!$systemInfo) {
        Write-Host "⚠️  Unknown system: $System (no reasoning patterns available)" -ForegroundColor Yellow
        return $null
    }

    Write-Host "`n📋 PURPOSE:" -ForegroundColor Green
    Write-Host "   $($systemInfo.purpose)"

    # Step 2: Detect context
    Write-Host "`n🔍 DETECTED CONTEXT:" -ForegroundColor Green
    Write-Host "   $DetectedContext"

    # Step 3: Determine implications
    Write-Host "`n💡 CONFIGURATION IMPLICATIONS:" -ForegroundColor Green
    $secReq = $systemInfo.security_requirements[$DetectedContext]
    if ($secReq) {
        Write-Host "   Security: $secReq"
    }

    $configDeps = $systemInfo.configuration_dependencies[$DetectedContext]
    if ($configDeps) {
        Write-Host "`n📦 REQUIRED CONFIGURATIONS:" -ForegroundColor Yellow
        $configDeps | ForEach-Object {
            Write-Host "   ✓ $_"
        }
    }

    # Step 4: Generate decision record
    $decision = @{
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        system = $System
        context = $DetectedContext
        reasoning = "Based on detected $DetectedContext context, $System requires specific configuration"
        actions_required = $configDeps
        evidence = $Evidence
    }

    return $decision
}

function Save-ArchitecturalDecision {
    param([hashtable]$Decision)

    $state = Initialize-ArchitecturalContext
    $state.decisions += $Decision
    $state | ConvertTo-Json -Depth 10 | Set-Content $StateFile

    Write-Host "`n✅ Decision recorded in architectural context" -ForegroundColor Green
}

# Main execution
switch ($Action) {
    'Analyze' {
        Write-Host "Analyzing system: $System" -ForegroundColor Cyan
        $systemInfo = Get-SystemPurpose $System
        $systemInfo | ConvertTo-Json -Depth 5
    }

    'Reason' {
        if (!$System -or !$Context) {
            Write-Host "❌ Reason action requires -System and -Context parameters" -ForegroundColor Red
            exit 1
        }

        $decision = Invoke-ArchitecturalReasoning -System $System -DetectedContext $Context -Evidence $Evidence

        if ($decision) {
            Save-ArchitecturalDecision $decision
        }
    }

    'Configure' {
        Write-Host "🔧 Configuration mode - Not yet implemented" -ForegroundColor Yellow
        Write-Host "   This would auto-apply the reasoned configuration"
    }

    'Document' {
        $state = Initialize-ArchitecturalContext
        Write-Host "`n=== ARCHITECTURAL DECISIONS HISTORY ===" -ForegroundColor Cyan
        $state.decisions | ForEach-Object {
            Write-Host "`n[$($_.timestamp)] $($_.system) in $($_.context) context"
            Write-Host "   Reasoning: $($_.reasoning)"
        }
    }
}

<#
PATTERN IDENTIFIED:

1. DEPLOYMENT CONTEXT DETERMINES CONFIGURATION
   - Not "one size fits all"
   - Context detection → Appropriate config

2. PURPOSE DRIVES REQUIREMENTS
   - Remote access tool → SSL essential
   - Local dev tool → SSL optional

3. SECURITY IS CONTEXTUAL
   - localhost → self-signed OK
   - Tailscale → TS cert
   - Internet → Let's Encrypt
   - Enterprise → Internal CA

4. INTEGRATION CHAINS
   - If Tailscale → then SSL cert
   - If team collab → then auth + audit
   - If production → then monitoring + backup

GENERALIZED REASONING PATTERN:
┌─────────────────┐
│ System Purpose  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Detect Context  │  ← Evidence from environment
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Security Level  │  ← Context → Requirements
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Configuration   │  ← Proactive setup
└─────────────────┘
#>
