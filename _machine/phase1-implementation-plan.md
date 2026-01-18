# Phase 1: Foundation - Detailed Implementation Plan
## Visual Workflow System Development

**Project:** Hazina Visual Workflow System
**Phase:** 1 of 4 - Foundation
**Duration:** 4 weeks (Weeks 1-4)
**Status:** APPROVED - Ready to Begin
**Approved:** 2026-01-17

---

## Phase 1 Overview

### Goals
1. ✅ Extend .hazina format to support per-step configuration
2. ✅ Build enhanced workflow parser
3. ✅ Upgrade workflow engine to apply per-step settings
4. ✅ Implement initial guardrails system
5. ✅ Validate with existing Brand2Boost workflows

### Success Criteria
- ✅ Can define workflow with per-step LLM and RAG configuration in .hazina file
- ✅ Workflow engine executes steps with different settings per step
- ✅ Demonstrate 20%+ AI cost reduction through intelligent model selection
- ✅ Existing Brand2Boost workflows still work (backward compatibility)
- ✅ >80% test coverage for new code

---

## Week-by-Week Breakdown

### Week 1: .hazina Format Extension & Parser

#### Objectives
- Design extended .hazina format specification
- Implement HazinaWorkflowConfigParser
- Ensure backward compatibility with existing format

#### Deliverables

**1.1 Extended .hazina Format Specification**

**File:** `C:\Projects\hazina\docs\hazina-workflow-format-v2.md`

**Format Example:**
```
# Workflow Definition
Name: OnboardingWorkflow
Description: Onboards new users with personalized content
Version: 2.0
Steps: 3

[Step1]
Name: AnalyzeInput
Type: AgentTask
AgentName: InputAnalyzer
Input: {userInput}
Temperature: 0.3
MaxTokens: 500
Model: gpt-4
TopP: 0.9
FrequencyPenalty: 0.0
PresencePenalty: 0.0
FallbackModel: gpt-3.5-turbo
RAGStore: brand-knowledge
RAGTopK: 5
RAGMinSimilarity: 0.8
RAGUseEmbeddings: true
RAGMetadataFilter: tags:onboarding
Guardrails: no-pii,token-limit
StepTimeout: 30000
OutputKey: analysis
ContinueOnFailure: false

[Step2]
Name: GenerateResponse
Type: AgentTask
AgentName: ResponseGenerator
Input: Based on {analysis}, generate personalized response
Temperature: 0.7
MaxTokens: 1000
Model: gpt-4-turbo
RAGStore: content-templates
RAGTopK: 3
Guardrails: tone-check,length-limit
OutputKey: response
ContinueOnFailure: false

[Step3]
Name: SaveResults
Type: AgentTask
AgentName: StorageAgent
Input: Save {response} to user profile
Temperature: 0.0
MaxTokens: 100
Model: gpt-3.5-turbo
Guardrails: json-schema
OutputKey: saved
ContinueOnFailure: true
```

**Backward Compatibility:**
- Old format without [StepN] sections still works
- Old format maps to single-step workflow with default settings
- Version field determines parser behavior (missing = v1, "2.0" = v2)

**1.2 Core Classes**

**File:** `C:\Projects\hazina\src\Core\AI\Hazina.AI.Workflows\Configuration\WorkflowStepConfig.cs`

```csharp
namespace Hazina.AI.Workflows.Configuration;

/// <summary>
/// Complete configuration for a single workflow step
/// </summary>
public class WorkflowStepConfig
{
    // Step Identity
    public string Name { get; set; } = string.Empty;
    public StepType Type { get; set; }
    public string AgentName { get; set; } = string.Empty;
    public string Input { get; set; } = string.Empty;
    public string OutputKey { get; set; } = string.Empty;
    public bool ContinueOnFailure { get; set; } = false;
    public int StepTimeout { get; set; } = 60000; // milliseconds

    // LLM Configuration
    public LLMStepConfig? LLMConfig { get; set; }

    // RAG Configuration
    public RAGStepConfig? RAGConfig { get; set; }

    // Guardrails
    public List<string> Guardrails { get; set; } = new();

    // Conditional Branching
    public WorkflowCondition? Condition { get; set; }
    public WorkflowStepConfig? ThenStep { get; set; }
    public WorkflowStepConfig? ElseStep { get; set; }

    // Loop Configuration
    public WorkflowStepConfig? LoopStep { get; set; }
    public WorkflowCondition? LoopCondition { get; set; }
    public int? MaxIterations { get; set; }

    // Parallel Steps
    public List<WorkflowStepConfig>? ParallelSteps { get; set; }
}

/// <summary>
/// LLM configuration for a step
/// </summary>
public class LLMStepConfig
{
    public string Model { get; set; } = "gpt-3.5-turbo";
    public string? FallbackModel { get; set; }
    public float Temperature { get; set; } = 0.7f;
    public int MaxTokens { get; set; } = 1000;
    public float TopP { get; set; } = 1.0f;
    public float FrequencyPenalty { get; set; } = 0.0f;
    public float PresencePenalty { get; set; } = 0.0f;
}

/// <summary>
/// RAG configuration for a step
/// </summary>
public class RAGStepConfig
{
    public string StoreName { get; set; } = string.Empty;
    public int TopK { get; set; } = 5;
    public double MinSimilarity { get; set; } = 0.7;
    public bool UseEmbeddings { get; set; } = true;
    public string? MetadataFilter { get; set; }
    public int MaxContextLength { get; set; } = 4000;
}

/// <summary>
/// Complete workflow configuration
/// </summary>
public class WorkflowConfig
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Version { get; set; } = "2.0";
    public List<WorkflowStepConfig> Steps { get; set; } = new();
    public Dictionary<string, object> Metadata { get; set; } = new();
}
```

**1.3 Parser Implementation**

**File:** `C:\Projects\hazina\src\Core\AI\Hazina.AI.Workflows\Configuration\HazinaWorkflowConfigParser.cs`

```csharp
namespace Hazina.AI.Workflows.Configuration;

/// <summary>
/// Parser for .hazina workflow format (v2.0)
/// Supports both legacy v1 format and new v2 format with per-step configuration
/// </summary>
public static class HazinaWorkflowConfigParser
{
    /// <summary>
    /// Parse .hazina workflow file
    /// </summary>
    public static WorkflowConfig Parse(string input)
    {
        var lines = input.Split(new[] { "\r\n", "\n" }, StringSplitOptions.TrimEntries);

        // Detect version
        var version = DetectVersion(lines);

        if (version == "1.0" || version == "1")
        {
            return ParseV1Format(input);
        }
        else
        {
            return ParseV2Format(input);
        }
    }

    /// <summary>
    /// Detect format version from content
    /// </summary>
    private static string DetectVersion(string[] lines)
    {
        foreach (var line in lines)
        {
            if (line.StartsWith("Version:", StringComparison.OrdinalIgnoreCase))
            {
                return line.Substring(8).Trim();
            }
        }

        // Check for [StepN] sections (v2 indicator)
        if (lines.Any(l => l.StartsWith("[Step", StringComparison.OrdinalIgnoreCase)))
        {
            return "2.0";
        }

        return "1.0"; // Default to v1
    }

    /// <summary>
    /// Parse v2 format (with [StepN] sections)
    /// </summary>
    private static WorkflowConfig ParseV2Format(string input)
    {
        var config = new WorkflowConfig();
        var lines = input.Split(new[] { "\r\n", "\n" }, StringSplitOptions.TrimEntries);

        WorkflowStepConfig? currentStep = null;
        bool inWorkflowHeader = true;

        foreach (var line in lines)
        {
            if (string.IsNullOrWhiteSpace(line) || line.StartsWith("#"))
                continue;

            // Step section start
            if (line.StartsWith("[Step", StringComparison.OrdinalIgnoreCase))
            {
                if (currentStep != null)
                {
                    config.Steps.Add(currentStep);
                }
                currentStep = new WorkflowStepConfig();
                inWorkflowHeader = false;
                continue;
            }

            var colonIndex = line.IndexOf(':');
            if (colonIndex < 0) continue;

            var key = line.Substring(0, colonIndex).Trim();
            var value = line.Substring(colonIndex + 1).Trim();

            if (inWorkflowHeader)
            {
                ParseWorkflowHeaderField(config, key, value);
            }
            else if (currentStep != null)
            {
                ParseStepField(currentStep, key, value);
            }
        }

        // Add last step
        if (currentStep != null)
        {
            config.Steps.Add(currentStep);
        }

        return config;
    }

    /// <summary>
    /// Parse workflow header fields (Name, Description, Version, etc.)
    /// </summary>
    private static void ParseWorkflowHeaderField(WorkflowConfig config, string key, string value)
    {
        switch (key)
        {
            case "Name":
                config.Name = value;
                break;
            case "Description":
                config.Description = value;
                break;
            case "Version":
                config.Version = value;
                break;
            // Additional metadata fields can be added to Metadata dictionary
            default:
                config.Metadata[key] = value;
                break;
        }
    }

    /// <summary>
    /// Parse step-level fields
    /// </summary>
    private static void ParseStepField(WorkflowStepConfig step, string key, string value)
    {
        switch (key)
        {
            case "Name":
                step.Name = value;
                break;
            case "Type":
                step.Type = Enum.Parse<StepType>(value, ignoreCase: true);
                break;
            case "AgentName":
                step.AgentName = value;
                break;
            case "Input":
                step.Input = value;
                break;
            case "OutputKey":
                step.OutputKey = value;
                break;
            case "ContinueOnFailure":
                step.ContinueOnFailure = bool.Parse(value);
                break;
            case "StepTimeout":
                step.StepTimeout = int.Parse(value);
                break;

            // LLM Configuration
            case "Model":
            case "Temperature":
            case "MaxTokens":
            case "TopP":
            case "FrequencyPenalty":
            case "PresencePenalty":
            case "FallbackModel":
                ParseLLMField(step, key, value);
                break;

            // RAG Configuration
            case "RAGStore":
            case "RAGTopK":
            case "RAGMinSimilarity":
            case "RAGUseEmbeddings":
            case "RAGMetadataFilter":
                ParseRAGField(step, key, value);
                break;

            // Guardrails
            case "Guardrails":
                step.Guardrails = value.Split(',', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries).ToList();
                break;
        }
    }

    /// <summary>
    /// Parse LLM configuration fields
    /// </summary>
    private static void ParseLLMField(WorkflowStepConfig step, string key, string value)
    {
        step.LLMConfig ??= new LLMStepConfig();

        switch (key)
        {
            case "Model":
                step.LLMConfig.Model = value;
                break;
            case "FallbackModel":
                step.LLMConfig.FallbackModel = value;
                break;
            case "Temperature":
                step.LLMConfig.Temperature = float.Parse(value);
                break;
            case "MaxTokens":
                step.LLMConfig.MaxTokens = int.Parse(value);
                break;
            case "TopP":
                step.LLMConfig.TopP = float.Parse(value);
                break;
            case "FrequencyPenalty":
                step.LLMConfig.FrequencyPenalty = float.Parse(value);
                break;
            case "PresencePenalty":
                step.LLMConfig.PresencePenalty = float.Parse(value);
                break;
        }
    }

    /// <summary>
    /// Parse RAG configuration fields
    /// </summary>
    private static void ParseRAGField(WorkflowStepConfig step, string key, string value)
    {
        step.RAGConfig ??= new RAGStepConfig();

        switch (key)
        {
            case "RAGStore":
                step.RAGConfig.StoreName = value;
                break;
            case "RAGTopK":
                step.RAGConfig.TopK = int.Parse(value);
                break;
            case "RAGMinSimilarity":
                step.RAGConfig.MinSimilarity = double.Parse(value);
                break;
            case "RAGUseEmbeddings":
                step.RAGConfig.UseEmbeddings = bool.Parse(value);
                break;
            case "RAGMetadataFilter":
                step.RAGConfig.MetadataFilter = value;
                break;
        }
    }

    /// <summary>
    /// Parse legacy v1 format (backward compatibility)
    /// </summary>
    private static WorkflowConfig ParseV1Format(string input)
    {
        // Use existing HazinaFlowConfigParser for v1 format
        var v1Flows = HazinaFlowConfigParser.Parse(input);

        // Convert to v2 WorkflowConfig
        var config = new WorkflowConfig();

        if (v1Flows.Any())
        {
            var v1Flow = v1Flows.First();
            config.Name = v1Flow.Name;
            config.Description = v1Flow.Description;
            config.Version = "1.0";

            // Convert CallsAgents to steps
            foreach (var agentName in v1Flow.CallsAgents)
            {
                config.Steps.Add(new WorkflowStepConfig
                {
                    Name = agentName,
                    Type = StepType.AgentTask,
                    AgentName = agentName,
                    Input = "{previousResult}",
                    OutputKey = agentName.ToLowerInvariant()
                });
            }
        }

        return config;
    }

    /// <summary>
    /// Load workflow from .hazina file
    /// </summary>
    public static WorkflowConfig LoadFromFile(string path)
    {
        if (!File.Exists(path))
            throw new FileNotFoundException($"Workflow file not found: {path}");

        var content = File.ReadAllText(path);
        return Parse(content);
    }

    /// <summary>
    /// Save workflow to .hazina file
    /// </summary>
    public static void SaveToFile(WorkflowConfig config, string path)
    {
        var content = Serialize(config);
        File.WriteAllText(path, content);
    }

    /// <summary>
    /// Serialize workflow to .hazina format
    /// </summary>
    public static string Serialize(WorkflowConfig config)
    {
        var sb = new StringBuilder();

        // Workflow header
        sb.AppendLine($"# Workflow Definition");
        sb.AppendLine($"Name: {config.Name}");
        sb.AppendLine($"Description: {config.Description}");
        sb.AppendLine($"Version: {config.Version}");
        sb.AppendLine($"Steps: {config.Steps.Count}");
        sb.AppendLine();

        // Steps
        for (int i = 0; i < config.Steps.Count; i++)
        {
            var step = config.Steps[i];
            sb.AppendLine($"[Step{i + 1}]");
            SerializeStep(sb, step);
            sb.AppendLine();
        }

        return sb.ToString();
    }

    /// <summary>
    /// Serialize a single step
    /// </summary>
    private static void SerializeStep(StringBuilder sb, WorkflowStepConfig step)
    {
        sb.AppendLine($"Name: {step.Name}");
        sb.AppendLine($"Type: {step.Type}");
        sb.AppendLine($"AgentName: {step.AgentName}");
        sb.AppendLine($"Input: {step.Input}");

        // LLM Config
        if (step.LLMConfig != null)
        {
            sb.AppendLine($"Temperature: {step.LLMConfig.Temperature}");
            sb.AppendLine($"MaxTokens: {step.LLMConfig.MaxTokens}");
            sb.AppendLine($"Model: {step.LLMConfig.Model}");
            sb.AppendLine($"TopP: {step.LLMConfig.TopP}");
            sb.AppendLine($"FrequencyPenalty: {step.LLMConfig.FrequencyPenalty}");
            sb.AppendLine($"PresencePenalty: {step.LLMConfig.PresencePenalty}");
            if (!string.IsNullOrEmpty(step.LLMConfig.FallbackModel))
                sb.AppendLine($"FallbackModel: {step.LLMConfig.FallbackModel}");
        }

        // RAG Config
        if (step.RAGConfig != null)
        {
            sb.AppendLine($"RAGStore: {step.RAGConfig.StoreName}");
            sb.AppendLine($"RAGTopK: {step.RAGConfig.TopK}");
            sb.AppendLine($"RAGMinSimilarity: {step.RAGConfig.MinSimilarity}");
            sb.AppendLine($"RAGUseEmbeddings: {step.RAGConfig.UseEmbeddings}");
            if (!string.IsNullOrEmpty(step.RAGConfig.MetadataFilter))
                sb.AppendLine($"RAGMetadataFilter: {step.RAGConfig.MetadataFilter}");
        }

        // Guardrails
        if (step.Guardrails.Any())
        {
            sb.AppendLine($"Guardrails: {string.Join(",", step.Guardrails)}");
        }

        sb.AppendLine($"StepTimeout: {step.StepTimeout}");
        sb.AppendLine($"OutputKey: {step.OutputKey}");
        sb.AppendLine($"ContinueOnFailure: {step.ContinueOnFailure}");
    }
}
```

#### Testing Requirements
- Unit tests for parser (15+ test cases covering v1/v2 formats, edge cases)
- Round-trip serialization tests (parse → serialize → parse should match)
- Backward compatibility tests with existing .hazina files

#### Week 1 Deliverables Checklist
- [ ] Format specification document
- [ ] WorkflowStepConfig class
- [ ] LLMStepConfig class
- [ ] RAGStepConfig class
- [ ] WorkflowConfig class
- [ ] HazinaWorkflowConfigParser implementation
- [ ] Unit tests (>80% coverage)
- [ ] Integration tests with sample .hazina files

---

### Week 2: Workflow Engine Upgrades

#### Objectives
- Enhance WorkflowEngine to apply per-step configuration
- Implement event-driven execution model
- Add comprehensive execution results

#### Deliverables

**2.1 Enhanced Workflow Engine**

**File:** `C:\Projects\hazina\src\Core\AI\Hazina.AI.Workflows\Engine\EnhancedWorkflowEngine.cs`

```csharp
namespace Hazina.AI.Workflows.Engine;

/// <summary>
/// Enhanced workflow engine with per-step configuration support
/// </summary>
public class EnhancedWorkflowEngine
{
    private readonly IProviderOrchestrator _llmOrchestrator;
    private readonly Dictionary<string, IRAGEngine> _ragEngines;
    private readonly IGuardrailPipeline _guardrailPipeline;
    private readonly ILogger<EnhancedWorkflowEngine> _logger;

    // Events for real-time monitoring
    public event EventHandler<StepStartedEventArgs>? StepStarted;
    public event EventHandler<StepCompletedEventArgs>? StepCompleted;
    public event EventHandler<StepFailedEventArgs>? StepFailed;
    public event EventHandler<WorkflowCompletedEventArgs>? WorkflowCompleted;

    public EnhancedWorkflowEngine(
        IProviderOrchestrator llmOrchestrator,
        Dictionary<string, IRAGEngine> ragEngines,
        IGuardrailPipeline guardrailPipeline,
        ILogger<EnhancedWorkflowEngine> logger)
    {
        _llmOrchestrator = llmOrchestrator;
        _ragEngines = ragEngines;
        _guardrailPipeline = guardrailPipeline;
        _logger = logger;
    }

    /// <summary>
    /// Execute workflow from .hazina file
    /// </summary>
    public async Task<WorkflowExecutionResult> ExecuteWorkflowAsync(
        string workflowPath,
        Dictionary<string, object> initialContext,
        CancellationToken cancellationToken = default)
    {
        // Load workflow configuration
        var config = HazinaWorkflowConfigParser.LoadFromFile(workflowPath);

        return await ExecuteWorkflowAsync(config, initialContext, cancellationToken);
    }

    /// <summary>
    /// Execute workflow from configuration
    /// </summary>
    public async Task<WorkflowExecutionResult> ExecuteWorkflowAsync(
        WorkflowConfig config,
        Dictionary<string, object> initialContext,
        CancellationToken cancellationToken = default)
    {
        var result = new WorkflowExecutionResult
        {
            WorkflowName = config.Name,
            StartTime = DateTime.UtcNow
        };

        var context = new WorkflowExecutionContext(initialContext);

        try
        {
            foreach (var step in config.Steps)
            {
                var stepResult = await ExecuteStepAsync(step, context, cancellationToken);
                result.StepResults.Add(stepResult);

                if (!stepResult.Success && !step.ContinueOnFailure)
                {
                    result.Success = false;
                    result.Error = $"Step '{step.Name}' failed: {stepResult.Error}";
                    break;
                }

                // Update context with step output
                if (stepResult.Success && !string.IsNullOrEmpty(step.OutputKey))
                {
                    context.SetValue(step.OutputKey, stepResult.Output);
                }
            }

            result.Success = result.StepResults.All(r => r.Success);
            result.FinalContext = context.GetAllValues();
        }
        catch (Exception ex)
        {
            result.Success = false;
            result.Error = ex.Message;
            _logger.LogError(ex, "Workflow execution failed: {WorkflowName}", config.Name);
        }

        result.EndTime = DateTime.UtcNow;
        result.Duration = result.EndTime - result.StartTime;

        // Raise completion event
        WorkflowCompleted?.Invoke(this, new WorkflowCompletedEventArgs(result));

        return result;
    }

    /// <summary>
    /// Execute a single workflow step with per-step configuration
    /// </summary>
    private async Task<StepExecutionResult> ExecuteStepAsync(
        WorkflowStepConfig step,
        WorkflowExecutionContext context,
        CancellationToken cancellationToken)
    {
        var stepResult = new StepExecutionResult
        {
            StepName = step.Name,
            StartTime = DateTime.UtcNow
        };

        // Raise step started event
        StepStarted?.Invoke(this, new StepStartedEventArgs(step.Name));

        try
        {
            // Process input template with context variables
            var processedInput = context.ProcessTemplate(step.Input);

            // Execute RAG search if configured
            string? ragContext = null;
            if (step.RAGConfig != null)
            {
                ragContext = await ExecuteRAGSearchAsync(processedInput, step.RAGConfig, cancellationToken);
                stepResult.RAGResultsCount = ragContext?.Split('\n').Length ?? 0;
            }

            // Build final prompt
            var finalPrompt = ragContext != null
                ? $"Context:\n{ragContext}\n\nQuery: {processedInput}"
                : processedInput;

            // Execute guardrails (pre-execution)
            if (step.Guardrails.Any())
            {
                var guardrailResult = await _guardrailPipeline.ExecuteAsync(
                    finalPrompt, step.Guardrails, GuardrailStage.PreExecution, cancellationToken);

                if (!guardrailResult.Passed)
                {
                    stepResult.Success = false;
                    stepResult.Error = $"Pre-execution guardrail failed: {guardrailResult.FailureReason}";
                    StepFailed?.Invoke(this, new StepFailedEventArgs(step.Name, stepResult.Error));
                    return stepResult;
                }
            }

            // Execute LLM with step-specific configuration
            var llmResponse = await ExecuteLLMCallAsync(
                finalPrompt,
                step.LLMConfig ?? new LLMStepConfig(),
                cancellationToken);

            stepResult.Output = llmResponse;
            stepResult.TokensUsed = EstimateTokens(finalPrompt) + EstimateTokens(llmResponse);
            stepResult.EstimatedCost = EstimateCost(step.LLMConfig?.Model ?? "gpt-3.5-turbo", stepResult.TokensUsed);

            // Execute guardrails (post-execution)
            if (step.Guardrails.Any())
            {
                var guardrailResult = await _guardrailPipeline.ExecuteAsync(
                    llmResponse, step.Guardrails, GuardrailStage.PostExecution, cancellationToken);

                if (!guardrailResult.Passed)
                {
                    stepResult.Success = false;
                    stepResult.Error = $"Post-execution guardrail failed: {guardrailResult.FailureReason}";
                    StepFailed?.Invoke(this, new StepFailedEventArgs(step.Name, stepResult.Error));
                    return stepResult;
                }
            }

            stepResult.Success = true;
            StepCompleted?.Invoke(this, new StepCompletedEventArgs(step.Name, stepResult));
        }
        catch (Exception ex)
        {
            stepResult.Success = false;
            stepResult.Error = ex.Message;
            _logger.LogError(ex, "Step execution failed: {StepName}", step.Name);
            StepFailed?.Invoke(this, new StepFailedEventArgs(step.Name, ex.Message));
        }

        stepResult.EndTime = DateTime.UtcNow;
        stepResult.Duration = stepResult.EndTime - stepResult.StartTime;
        return stepResult;
    }

    /// <summary>
    /// Execute RAG search with step-specific configuration
    /// </summary>
    private async Task<string?> ExecuteRAGSearchAsync(
        string query,
        RAGStepConfig ragConfig,
        CancellationToken cancellationToken)
    {
        if (!_ragEngines.TryGetValue(ragConfig.StoreName, out var ragEngine))
        {
            _logger.LogWarning("RAG store not found: {StoreName}", ragConfig.StoreName);
            return null;
        }

        var ragOptions = new RAGQueryOptions
        {
            TopK = ragConfig.TopK,
            MinSimilarity = ragConfig.MinSimilarity,
            UseEmbeddings = ragConfig.UseEmbeddings,
            MaxContextLength = ragConfig.MaxContextLength
        };

        if (!string.IsNullOrEmpty(ragConfig.MetadataFilter))
        {
            ragOptions.MetadataFilter = ParseMetadataFilter(ragConfig.MetadataFilter);
        }

        var ragResponse = await ragEngine.QueryAsync(query, ragOptions, cancellationToken);
        return ragResponse.ContextUsed;
    }

    /// <summary>
    /// Execute LLM call with step-specific configuration
    /// </summary>
    private async Task<string> ExecuteLLMCallAsync(
        string prompt,
        LLMStepConfig llmConfig,
        CancellationToken cancellationToken)
    {
        // TODO: Apply llmConfig parameters to orchestrator call
        // This will require enhancements to IProviderOrchestrator interface

        var messages = new List<HazinaChatMessage>
        {
            new HazinaChatMessage
            {
                Role = HazinaMessageRole.User,
                Text = prompt
            }
        };

        var response = await _llmOrchestrator.GetResponse(
            messages,
            HazinaChatResponseFormat.Text,
            null,
            null,
            cancellationToken
        );

        return response.Result;
    }

    // Helper methods
    private MetadataFilter ParseMetadataFilter(string filter) { /* TODO */ return new MetadataFilter(); }
    private int EstimateTokens(string text) { return text.Length / 4; } // Rough estimate
    private decimal EstimateCost(string model, int tokens) { /* TODO: Actual cost calculation */ return 0.0001m * tokens; }
}

/// <summary>
/// Workflow execution context with variable substitution
/// </summary>
public class WorkflowExecutionContext
{
    private readonly Dictionary<string, object> _values;

    public WorkflowExecutionContext(Dictionary<string, object> initialValues)
    {
        _values = new Dictionary<string, object>(initialValues);
    }

    public void SetValue(string key, object value)
    {
        _values[key] = value;
    }

    public object? GetValue(string key)
    {
        return _values.TryGetValue(key, out var value) ? value : null;
    }

    public Dictionary<string, object> GetAllValues()
    {
        return new Dictionary<string, object>(_values);
    }

    /// <summary>
    /// Process template string by replacing {variableName} placeholders
    /// </summary>
    public string ProcessTemplate(string template)
    {
        var result = template;
        foreach (var kvp in _values)
        {
            result = result.Replace($"{{{kvp.Key}}}", kvp.Value?.ToString() ?? "");
        }
        return result;
    }
}

/// <summary>
/// Comprehensive workflow execution result
/// </summary>
public class WorkflowExecutionResult
{
    public string WorkflowName { get; set; } = string.Empty;
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public TimeSpan Duration { get; set; }
    public bool Success { get; set; }
    public string? Error { get; set; }
    public List<StepExecutionResult> StepResults { get; set; } = new();
    public Dictionary<string, object> FinalContext { get; set; } = new();

    public int TotalTokensUsed => StepResults.Sum(r => r.TokensUsed);
    public decimal TotalEstimatedCost => StepResults.Sum(r => r.EstimatedCost);
}

/// <summary>
/// Step execution result with detailed metrics
/// </summary>
public class StepExecutionResult
{
    public string StepName { get; set; } = string.Empty;
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public TimeSpan Duration { get; set; }
    public bool Success { get; set; }
    public string Output { get; set; } = string.Empty;
    public string? Error { get; set; }
    public int TokensUsed { get; set; }
    public decimal EstimatedCost { get; set; }
    public int RAGResultsCount { get; set; }
}

// Event argument classes
public class StepStartedEventArgs : EventArgs
{
    public string StepName { get; }
    public StepStartedEventArgs(string stepName) { StepName = stepName; }
}

public class StepCompletedEventArgs : EventArgs
{
    public string StepName { get; }
    public StepExecutionResult Result { get; }
    public StepCompletedEventArgs(string stepName, StepExecutionResult result)
    {
        StepName = stepName;
        Result = result;
    }
}

public class StepFailedEventArgs : EventArgs
{
    public string StepName { get; }
    public string Error { get; }
    public StepFailedEventArgs(string stepName, string error)
    {
        StepName = stepName;
        Error = error;
    }
}

public class WorkflowCompletedEventArgs : EventArgs
{
    public WorkflowExecutionResult Result { get; }
    public WorkflowCompletedEventArgs(WorkflowExecutionResult result)
    {
        Result = result;
    }
}
```

#### Week 2 Deliverables Checklist
- [ ] EnhancedWorkflowEngine implementation
- [ ] WorkflowExecutionContext class
- [ ] Event-driven execution model
- [ ] Comprehensive result tracking (tokens, cost, duration)
- [ ] Integration with existing IProviderOrchestrator
- [ ] Unit tests for engine
- [ ] Integration tests with sample workflows

---

### Week 3: Initial Guardrails System

#### Objectives
- Implement guardrails infrastructure
- Build 3 initial guardrails (PII, TokenLimit, JSONSchema)
- Integrate with workflow engine

#### Deliverables

**3.1 Guardrails Infrastructure**

**File:** `C:\Projects\hazina\src\Core\AI\Hazina.AI.Guardrails\IGuardrail.cs`

```csharp
namespace Hazina.AI.Guardrails;

public enum GuardrailStage
{
    PreExecution,   // Before LLM call
    PostExecution   // After LLM call
}

public interface IGuardrail
{
    string Name { get; }
    GuardrailStage Stage { get; }

    Task<GuardrailResult> ValidateAsync(
        string content,
        GuardrailContext context,
        CancellationToken cancellationToken = default);
}

public class GuardrailResult
{
    public bool Passed { get; set; }
    public string? FailureReason { get; set; }
    public Dictionary<string, object> Metadata { get; set; } = new();
}

public class GuardrailContext
{
    public string WorkflowName { get; set; } = string.Empty;
    public string StepName { get; set; } = string.Empty;
    public Dictionary<string, object> Parameters { get; set; } = new();
}
```

**File:** `C:\Projects\hazina\src\Core\AI\Hazina.AI.Guardrails\GuardrailPipeline.cs`

```csharp
namespace Hazina.AI.Guardrails;

public interface IGuardrailPipeline
{
    Task<GuardrailResult> ExecuteAsync(
        string content,
        List<string> guardrailNames,
        GuardrailStage stage,
        CancellationToken cancellationToken = default);
}

public class GuardrailPipeline : IGuardrailPipeline
{
    private readonly Dictionary<string, IGuardrail> _guardrails;
    private readonly ILogger<GuardrailPipeline> _logger;

    public GuardrailPipeline(
        IEnumerable<IGuardrail> guardrails,
        ILogger<GuardrailPipeline> logger)
    {
        _guardrails = guardrails.ToDictionary(g => g.Name, StringComparer.OrdinalIgnoreCase);
        _logger = logger;
    }

    public async Task<GuardrailResult> ExecuteAsync(
        string content,
        List<string> guardrailNames,
        GuardrailStage stage,
        CancellationToken cancellationToken = default)
    {
        foreach (var name in guardrailNames)
        {
            if (!_guardrails.TryGetValue(name, out var guardrail))
            {
                _logger.LogWarning("Guardrail not found: {GuardrailName}", name);
                continue;
            }

            // Skip if guardrail doesn't apply to this stage
            if (guardrail.Stage != stage)
                continue;

            var result = await guardrail.ValidateAsync(content, new GuardrailContext(), cancellationToken);

            if (!result.Passed)
            {
                _logger.LogWarning("Guardrail {GuardrailName} failed: {Reason}", name, result.FailureReason);
                return result;
            }
        }

        return new GuardrailResult { Passed = true };
    }
}
```

**3.2 Initial Guardrail Implementations**

**File:** `C:\Projects\hazina\src\Core\AI\Hazina.AI.Guardrails\Implementations\PIIDetectionGuardrail.cs`

```csharp
namespace Hazina.AI.Guardrails.Implementations;

public class PIIDetectionGuardrail : IGuardrail
{
    public string Name => "no-pii";
    public GuardrailStage Stage => GuardrailStage.PostExecution;

    private static readonly Regex[] PII_PATTERNS = new[]
    {
        new Regex(@"\b\d{3}-\d{2}-\d{4}\b"),           // SSN
        new Regex(@"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b"),  // Email
        new Regex(@"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"),   // Phone
        new Regex(@"\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b") // Credit card
    };

    public Task<GuardrailResult> ValidateAsync(
        string content,
        GuardrailContext context,
        CancellationToken cancellationToken = default)
    {
        foreach (var pattern in PII_PATTERNS)
        {
            var match = pattern.Match(content);
            if (match.Success)
            {
                return Task.FromResult(new GuardrailResult
                {
                    Passed = false,
                    FailureReason = $"Potential PII detected: {match.Value.Substring(0, Math.Min(10, match.Value.Length))}..."
                });
            }
        }

        return Task.FromResult(new GuardrailResult { Passed = true });
    }
}
```

**File:** `C:\Projects\hazina\src\Core\AI\Hazina.AI.Guardrails\Implementations\TokenLimitGuardrail.cs`

```csharp
namespace Hazina.AI.Guardrails.Implementations;

public class TokenLimitGuardrail : IGuardrail
{
    public string Name => "token-limit";
    public GuardrailStage Stage => GuardrailStage.PostExecution;

    private const int DEFAULT_MAX_TOKENS = 2000;

    public Task<GuardrailResult> ValidateAsync(
        string content,
        GuardrailContext context,
        CancellationToken cancellationToken = default)
    {
        var maxTokens = context.Parameters.TryGetValue("maxTokens", out var max)
            ? Convert.ToInt32(max)
            : DEFAULT_MAX_TOKENS;

        var estimatedTokens = content.Length / 4; // Rough estimate

        if (estimatedTokens > maxTokens)
        {
            return Task.FromResult(new GuardrailResult
            {
                Passed = false,
                FailureReason = $"Output exceeds token limit: {estimatedTokens} > {maxTokens}"
            });
        }

        return Task.FromResult(new GuardrailResult { Passed = true });
    }
}
```

**File:** `C:\Projects\hazina\src\Core\AI\Hazina.AI.Guardrails\Implementations\JSONSchemaGuardrail.cs`

```csharp
namespace Hazina.AI.Guardrails.Implementations;

public class JSONSchemaGuardrail : IGuardrail
{
    public string Name => "json-schema";
    public GuardrailStage Stage => GuardrailStage.PostExecution;

    public Task<GuardrailResult> ValidateAsync(
        string content,
        GuardrailContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Basic JSON validation
            JsonDocument.Parse(content);

            // TODO: Add actual schema validation using JSON Schema library

            return Task.FromResult(new GuardrailResult { Passed = true });
        }
        catch (JsonException ex)
        {
            return Task.FromResult(new GuardrailResult
            {
                Passed = false,
                FailureReason = $"Invalid JSON: {ex.Message}"
            });
        }
    }
}
```

#### Week 3 Deliverables Checklist
- [ ] IGuardrail interface
- [ ] GuardrailPipeline implementation
- [ ] PIIDetectionGuardrail
- [ ] TokenLimitGuardrail
- [ ] JSONSchemaGuardrail
- [ ] Integration with EnhancedWorkflowEngine
- [ ] Unit tests for each guardrail
- [ ] Integration tests with workflows

---

### Week 4: Testing, Validation & Documentation

#### Objectives
- Comprehensive testing with Brand2Boost workflows
- Cost reduction validation
- Backward compatibility verification
- Documentation

#### Deliverables

**4.1 Sample Workflows**

Create 3 test workflows in `C:\stores\brand2boost\.hazina\workflows\`

1. **onboarding-test.hazina** - User onboarding with per-step model selection
2. **brand-analysis-test.hazina** - Multi-step analysis with different RAG stores
3. **content-generation-test.hazina** - Content generation with guardrails

**4.2 Cost Reduction Analysis**

Run workflows with:
- Old engine (single model, default settings)
- New engine (per-step model selection, optimized settings)

Measure:
- Total tokens used
- Estimated cost
- Execution time
- Output quality

**Target:** 20%+ cost reduction while maintaining quality

**4.3 Integration Tests**

**File:** `C:\Projects\hazina\tests\Hazina.AI.Workflows.Tests\IntegrationTests.cs`

```csharp
[TestClass]
public class WorkflowIntegrationTests
{
    [TestMethod]
    public async Task Execute_OnboardingWorkflow_Success()
    {
        // Load workflow
        var workflow = HazinaWorkflowConfigParser.LoadFromFile(
            @"C:\stores\brand2boost\.hazina\workflows\onboarding-test.hazina");

        // Execute
        var engine = CreateTestEngine();
        var result = await engine.ExecuteWorkflowAsync(
            workflow,
            new Dictionary<string, object> { ["userInput"] = "Test user data" });

        // Assert
        Assert.IsTrue(result.Success);
        Assert.IsTrue(result.StepResults.All(r => r.Success));
        Assert.IsTrue(result.TotalEstimatedCost < 0.10m); // Cost target
    }

    [TestMethod]
    public async Task Execute_V1Workflow_BackwardCompatibility()
    {
        // Load old v1 format workflow
        var workflow = HazinaWorkflowConfigParser.LoadFromFile(
            @"C:\stores\brand2boost\.hazina\workflows\legacy-v1.hazina");

        // Execute
        var engine = CreateTestEngine();
        var result = await engine.ExecuteWorkflowAsync(
            workflow,
            new Dictionary<string, object>());

        // Assert - should work without errors
        Assert.IsTrue(result.Success);
    }

    [TestMethod]
    public async Task Guardrail_PIIDetection_BlocksOutput()
    {
        var workflow = new WorkflowConfig
        {
            Name = "Test",
            Steps = new List<WorkflowStepConfig>
            {
                new WorkflowStepConfig
                {
                    Name = "GeneratePII",
                    Type = StepType.AgentTask,
                    AgentName = "TestAgent",
                    Input = "Generate text with SSN 123-45-6789",
                    Guardrails = new List<string> { "no-pii" }
                }
            }
        };

        var engine = CreateTestEngine();
        var result = await engine.ExecuteWorkflowAsync(workflow, new Dictionary<string, object>());

        // Should fail due to PII in output
        Assert.IsFalse(result.Success);
        Assert.IsTrue(result.Error.Contains("PII"));
    }
}
```

**4.4 Documentation**

**File:** `C:\Projects\hazina\docs\workflow-system-user-guide.md`

Content:
- Introduction to v2.0 workflow format
- Examples of per-step configuration
- Available guardrails and how to use them
- Migration guide from v1 to v2
- Troubleshooting common issues

#### Week 4 Deliverables Checklist
- [ ] 3 sample Brand2Boost workflows created
- [ ] Cost reduction analysis completed (>20% reduction)
- [ ] Backward compatibility tests passing
- [ ] Integration test suite (10+ tests)
- [ ] Performance benchmarks documented
- [ ] User guide written
- [ ] API documentation generated

---

## Phase 1 Exit Criteria

Phase 1 is complete and ready for Phase 2 when:

✅ **Functionality**
- [ ] .hazina v2.0 format fully specified and documented
- [ ] Parser can load v1 and v2 formats
- [ ] Enhanced workflow engine executes workflows with per-step config
- [ ] 3 guardrails implemented and working
- [ ] Event-driven execution model functional

✅ **Quality**
- [ ] >80% unit test coverage
- [ ] All integration tests passing
- [ ] No critical or high-severity bugs
- [ ] Performance meets targets (<100ms overhead per step)

✅ **Validation**
- [ ] 20%+ cost reduction demonstrated
- [ ] Backward compatibility verified with existing workflows
- [ ] At least 3 Brand2Boost workflows running in production

✅ **Documentation**
- [ ] User guide written
- [ ] API documentation generated
- [ ] Migration guide available

---

## Development Environment Setup

### Prerequisites
- Visual Studio 2022 or VS Code
- .NET 8.0 SDK
- Git
- Access to Hazina repository

### Repository Structure

```
C:\Projects\hazina\
├── src\
│   └── Core\
│       └── AI\
│           ├── Hazina.AI.Workflows\
│           │   ├── Configuration\
│           │   │   ├── WorkflowStepConfig.cs
│           │   │   ├── LLMStepConfig.cs
│           │   │   ├── RAGStepConfig.cs
│           │   │   ├── WorkflowConfig.cs
│           │   │   └── HazinaWorkflowConfigParser.cs
│           │   ├── Engine\
│           │   │   ├── EnhancedWorkflowEngine.cs
│           │   │   └── WorkflowExecutionContext.cs
│           │   └── Hazina.AI.Workflows.csproj
│           └── Hazina.AI.Guardrails\
│               ├── IGuardrail.cs
│               ├── GuardrailPipeline.cs
│               ├── Implementations\
│               │   ├── PIIDetectionGuardrail.cs
│               │   ├── TokenLimitGuardrail.cs
│               │   └── JSONSchemaGuardrail.cs
│               └── Hazina.AI.Guardrails.csproj
├── tests\
│   └── Hazina.AI.Workflows.Tests\
│       ├── ParserTests.cs
│       ├── EngineTests.cs
│       ├── GuardrailTests.cs
│       └── IntegrationTests.cs
└── docs\
    ├── hazina-workflow-format-v2.md
    └── workflow-system-user-guide.md
```

### Development Workflow

1. **Start of week:** Review objectives and deliverables
2. **Daily:** Commit changes, update tests
3. **Mid-week:** Code review checkpoint
4. **End of week:** Demo to stakeholders, collect feedback
5. **Week 4:** Phase 1 demo and go/no-go decision for Phase 2

---

## Risk Mitigation

### Week 1 Risks
- **Risk:** Parser too complex
- **Mitigation:** Start with simple cases, add complexity incrementally
- **Fallback:** Simplify format if needed

### Week 2 Risks
- **Risk:** Engine changes break existing workflows
- **Mitigation:** Comprehensive backward compatibility tests
- **Fallback:** Feature flag to disable per-step config

### Week 3 Risks
- **Risk:** Guardrails too restrictive (false positives)
- **Mitigation:** Configurable sensitivity, override options
- **Fallback:** Make guardrails opt-in, not default

### Week 4 Risks
- **Risk:** Cost reduction target not met
- **Mitigation:** Adjust model selection strategy, optimize settings
- **Fallback:** Document actual savings, adjust expectations

---

## Communication Plan

### Daily Standups
- Progress update
- Blockers
- Next steps

### Weekly Demos
- **Week 1:** Parser demo with sample .hazina files
- **Week 2:** Engine demo executing multi-step workflow
- **Week 3:** Guardrails demo blocking invalid content
- **Week 4:** Full Phase 1 demo with cost analysis

### Stakeholder Updates
- Weekly email summary
- Metrics dashboard (tests passing, coverage, etc.)
- Phase 1 completion report at week 4

---

## Next Steps After Phase 1

Once Phase 1 is complete and approved:

1. **Phase 1 Retrospective** - What went well, what to improve
2. **Phase 2 Planning** - Detailed plan for configuration systems
3. **Resource Allocation** - Confirm team for Phase 2
4. **Production Deployment** - Deploy Phase 1 to production (if standalone value)

---

**Prepared By:** Claude Agent
**Date:** 2026-01-17
**Status:** Ready to Begin Development
**Next Action:** Allocate worktree and begin Week 1 implementation

Let's build this! 🚀
