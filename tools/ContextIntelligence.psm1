# Context Intelligence API (R22-003)
# Unified PowerShell module for all context intelligence functions

# Import central knowledge store functions
$KnowledgeStore = "C:\scripts\_machine\knowledge-store.yaml"

function Get-KnowledgeStore {
    if (Test-Path $KnowledgeStore) {
        return Get-Content $KnowledgeStore -Raw | ConvertFrom-Yaml
    }
    return $null
}

function Set-KnowledgeStore {
    param([object]$Store)
    $Store | ConvertTo-Yaml | Out-File -FilePath $KnowledgeStore -Encoding UTF8
}

# ===== Prediction Functions =====

function Get-ContextPrediction {
    <#
    .SYNOPSIS
    Get context prediction for current situation

    .PARAMETER Context
    Context name to predict for

    .PARAMETER Method
    Prediction method (time_of_day, recent_files, markov_chain, etc)
    #>
    param(
        [string]$Context,
        [string]$Method = "all"
    )

    # Delegate to self-improving-prediction.ps1
    $result = & "C:\scripts\tools\self-improving-prediction.ps1" -Analyze
    return $result | ConvertFrom-Json
}

function Update-PredictionWeights {
    <#
    .SYNOPSIS
    Update prediction weights based on accuracy
    #>
    & "C:\scripts\tools\self-improving-prediction.ps1" -UpdateWeights
}

# ===== Clustering Functions =====

function Get-ContextClusters {
    <#
    .SYNOPSIS
    Get all context clusters
    #>
    $store = Get-KnowledgeStore
    return $store.clusters.groups
}

function Find-RelatedContexts {
    <#
    .SYNOPSIS
    Find contexts related to specified file

    .PARAMETER FilePath
    File to find related contexts for
    #>
    param([string]$FilePath)

    $result = & "C:\scripts\tools\context-clustering.ps1" -FindRelated $FilePath
    return $result
}

function Update-ContextClusters {
    <#
    .SYNOPSIS
    Rebuild context clusters from recent activity
    #>
    & "C:\scripts\tools\context-clustering.ps1" -Build
}

# ===== Pattern Mining Functions =====

function Get-UniversalPatterns {
    <#
    .SYNOPSIS
    Get universal patterns across all sessions

    .PARAMETER Type
    Pattern type (temporal, sequential, workflow, contextual)
    #>
    param([string]$Type)

    if ($Type) {
        $result = & "C:\scripts\tools\cross-session-patterns.ps1" -Pattern $Type
        return $result | ConvertFrom-Json
    }
    else {
        $store = Get-KnowledgeStore
        return $store.patterns
    }
}

function Update-UniversalPatterns {
    <#
    .SYNOPSIS
    Mine latest patterns from all sessions
    #>
    & "C:\scripts\tools\cross-session-patterns.ps1" -Mine
}

# ===== Mode Management Functions =====

function Get-ContextMode {
    <#
    .SYNOPSIS
    Get current operating mode (proactive/reactive) for context

    .PARAMETER Context
    Context to check mode for
    #>
    param([string]$Context)

    $result = & "C:\scripts\tools\proactive-mode.ps1" -GetConfidence -Context $Context
    $data = $result | ConvertFrom-Json

    $threshold = 0.8
    return @{
        context = $Context
        confidence = $data.confidence
        mode = if ($data.confidence -ge $threshold) { "PROACTIVE" } else { "REACTIVE" }
    }
}

function Get-ContextConfidence {
    <#
    .SYNOPSIS
    Get confidence score for context

    .PARAMETER Context
    Context to calculate confidence for
    #>
    param([string]$Context)

    $result = & "C:\scripts\tools\proactive-mode.ps1" -GetConfidence -Context $Context
    return $result | ConvertFrom-Json
}

# ===== Semantic Search Functions =====

function Find-ContextBySemantic {
    <#
    .SYNOPSIS
    Search for context using semantic search

    .PARAMETER Query
    Search query

    .PARAMETER Preload
    Also return related contexts for preloading

    .PARAMETER MaxResults
    Maximum results to return
    #>
    param(
        [string]$Query,
        [switch]$Preload,
        [int]$MaxResults = 10
    )

    $params = @("-Query", $Query, "-MaxResults", $MaxResults)
    if ($Preload) {
        $params += "-Preload"
    }

    & "C:\scripts\tools\context-semantic-search.ps1" @params
}

# ===== Event Bus Functions =====

function Publish-ContextEvent {
    <#
    .SYNOPSIS
    Publish an event to the context event bus

    .PARAMETER EventType
    Type of event

    .PARAMETER Data
    Event data (JSON string)
    #>
    param(
        [string]$EventType,
        [string]$Data = ""
    )

    & "C:\scripts\tools\context-event-bus.ps1" -Publish -EventType $EventType -Data $Data
}

function Get-ContextEvents {
    <#
    .SYNOPSIS
    Get pending events from event bus

    .PARAMETER FilterType
    Filter by event type
    #>
    param([string]$FilterType)

    $params = @("-Subscribe")
    if ($FilterType) {
        $params += @("-FilterType", $FilterType)
    }

    $result = & "C:\scripts\tools\context-event-bus.ps1" @params
    return $result | ConvertFrom-Json
}

function Invoke-EventProcessing {
    <#
    .SYNOPSIS
    Process all pending events in event bus
    #>
    & "C:\scripts\tools\context-event-bus.ps1" -ProcessQueue
}

# ===== Utility Functions =====

function Get-ContextIntelligenceStatus {
    <#
    .SYNOPSIS
    Get overall status of context intelligence system
    #>
    $store = Get-KnowledgeStore

    return @{
        predictions = @{
            accuracy = $store.predictions.accuracy.overall_accuracy
            total = $store.predictions.accuracy.total_predictions
        }
        clusters = @{
            count = $store.clusters.groups.Count
            last_build = $store.clusters.metadata.last_cluster_build
        }
        patterns = @{
            workflow = $store.patterns.workflow
        }
        statistics = $store.statistics
    }
}

# Export module members
Export-ModuleMember -Function @(
    'Get-ContextPrediction',
    'Update-PredictionWeights',
    'Get-ContextClusters',
    'Find-RelatedContexts',
    'Update-ContextClusters',
    'Get-UniversalPatterns',
    'Update-UniversalPatterns',
    'Get-ContextMode',
    'Get-ContextConfidence',
    'Find-ContextBySemantic',
    'Publish-ContextEvent',
    'Get-ContextEvents',
    'Invoke-EventProcessing',
    'Get-ContextIntelligenceStatus'
)
