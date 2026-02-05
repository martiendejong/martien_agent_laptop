# Cross-Domain Improvement Transfer (R24-002)
# Creates templates for applying improvements to other projects

param(
    [Parameter(Mandatory)]
    [string]$TargetProject,

    [string]$OutputPath = "C:\scripts\_machine\templates",
    [switch]$GenerateAll
)

function New-ParameterizedTemplate {
    param([string]$ProjectName)

    $template = @"
# Context Intelligence System Template
# Generated for project: $ProjectName
# Date: $(Get-Date -Format 'yyyy-MM-dd')

## Overview
This template adapts the context intelligence improvements (Rounds 21-24)
for the $ProjectName project.

## Prerequisites
1. Event logging system (conversation-events.log.jsonl equivalent)
2. File access tracking
3. PowerShell execution environment

## Parameterization
Replace these placeholders:
- {{PROJECT_ROOT}} = Root directory of $ProjectName
- {{CONFIG_PATH}} = Configuration storage location
- {{LOG_PATH}} = Event log location
- {{TOOL_PATH}} = Where to install tools

## Core Components

### 1. Knowledge Store
File: {{CONFIG_PATH}}/knowledge-store.yaml
Purpose: Central storage for all context intelligence

### 2. Prediction System
File: {{TOOL_PATH}}/self-improving-prediction.ps1
Adaptations needed:
- Update prediction methods for ${ProjectName}'s specific patterns
- Adjust weights for project-specific contexts

### 3. Context Clustering
File: {{TOOL_PATH}}/context-clustering.ps1
Adaptations needed:
- Parse ${ProjectName}'s event log format
- Identify project-specific file patterns

### 4. Pattern Mining
File: {{TOOL_PATH}}/cross-session-patterns.ps1
Adaptations needed:
- Define ${ProjectName}-specific workflow keywords
- Map temporal patterns to project rhythms

### 5. Event Bus
File: {{TOOL_PATH}}/context-event-bus.ps1
Adaptations needed:
- Define project-specific event types
- Create routing rules for project needs

### 6. Orchestrator
File: {{TOOL_PATH}}/Start-ContextIntelligence.ps1
Adaptations needed:
- Set project-specific defaults
- Configure tool execution order

## Implementation Steps

1. Create directory structure:
   mkdir -p {{CONFIG_PATH}}
   mkdir -p {{TOOL_PATH}}

2. Copy templates:
   cp C:\scripts\tools\*.ps1 {{TOOL_PATH}}/

3. Parameterize configurations:
   - Replace all paths
   - Update project-specific constants
   - Adjust thresholds for project scale

4. Initialize knowledge store:
   {{TOOL_PATH}}/Validate-KnowledgeStore.ps1 -Validate

5. Test individual components:
   - Prediction: {{TOOL_PATH}}/self-improving-prediction.ps1 -Report
   - Clustering: {{TOOL_PATH}}/context-clustering.ps1 -Build
   - Patterns: {{TOOL_PATH}}/cross-session-patterns.ps1 -Mine

6. Run orchestrator:
   {{TOOL_PATH}}/Start-ContextIntelligence.ps1

## Project-Specific Customizations

### For $ProjectName:
- [TODO: List specific adaptations needed]
- [TODO: Identify domain-specific patterns]
- [TODO: Define success metrics]

## Value Proposition
Expected benefits for ${ProjectName}:
- Predictive context loading (reduce manual work)
- Automatic pattern discovery (learn from usage)
- Self-improving accuracy (gets better over time)
- Resilient operation (graceful degradation)

## Effort Estimate
- Initial setup: 4-6 hours
- Customization: 2-4 hours
- Testing: 2-3 hours
- Total: 8-13 hours

## Success Metrics
Track these to measure effectiveness:
- Context prediction accuracy (target: >70%)
- Reduced manual context requests (target: -50%)
- Pattern discovery rate (new patterns per week)
- System uptime (target: >99%)
"@

    return $template
}

function Export-AllTemplates {
    param([string]$ProjectName)

    if (!(Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    }

    # Main template
    $mainTemplate = New-ParameterizedTemplate -ProjectName $ProjectName
    $mainTemplate | Out-File -FilePath "$OutputPath\${ProjectName}_template.md" -Encoding UTF8

    # Configuration template
    $configTemplate = @"
# Knowledge Store Configuration Template
# Project: $ProjectName

metadata:
  version: "1.0"
  project: "$ProjectName"
  created: "$(Get-Date -Format 'yyyy-MM-dd')"

project_paths:
  root: "{{PROJECT_ROOT}}"
  config: "{{CONFIG_PATH}}"
  logs: "{{LOG_PATH}}"
  tools: "{{TOOL_PATH}}"

project_contexts:
  # Define project-specific contexts
  # Example:
  # - name: "backend"
  #   paths: ["src/api/*"]
  #   keywords: ["controller", "service"]
  # - name: "frontend"
  #   paths: ["src/ui/*"]
  #   keywords: ["component", "view"]

predictions:
  weights:
    time_of_day: 1.0
    recent_files: 1.5
    conversation_intent: 1.2
    markov_chain: 1.0
    project_context: 1.3
    semantic_similarity: 1.1

patterns:
  temporal: {}
  sequential: []
  contextual: []
  workflow:
    # Define project-specific workflows
    # Example: debug: 0, feature: 0, refactor: 0, docs: 0

clusters:
  groups: {}
  metadata:
    total_sessions_analyzed: 0

confidence:
  thresholds:
    proactive_mode: 0.8
    high_confidence: 0.7
    medium_confidence: 0.5

events:
  queue: []
  subscribers: {}

statistics:
  total_sessions: 0
  project: "$ProjectName"
"@

    $configTemplate | Out-File -FilePath "$OutputPath\${ProjectName}_config_template.yaml" -Encoding UTF8

    Write-Host "Templates exported to: $OutputPath" -ForegroundColor Green
    Write-Host "  - ${ProjectName}_template.md" -ForegroundColor Cyan
    Write-Host "  - ${ProjectName}_config_template.yaml" -ForegroundColor Cyan
}

# Main execution
Write-Host "Generating improvement templates for: $TargetProject" -ForegroundColor Cyan

Export-AllTemplates -ProjectName $TargetProject

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Review $OutputPath\${TargetProject}_template.md"
Write-Host "2. Customize for project-specific needs"
Write-Host "3. Replace {{PLACEHOLDERS}} with actual paths"
Write-Host "4. Follow implementation steps in template"
