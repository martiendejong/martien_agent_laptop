# Visual Workflow System: 100-Point Detailed Changes

**Project:** Hazina Visual Workflow System
**Date:** 2026-01-17
**Version:** 1.0

---

## Table of Contents

1. [.hazina Format Extensions](#1-hazina-format-extensions) (Points 1-15)
2. [Workflow Engine Enhancements](#2-workflow-engine-enhancements) (Points 16-30)
3. [LLM Configuration System](#3-llm-configuration-system) (Points 31-40)
4. [RAG Configuration System](#4-rag-configuration-system) (Points 41-50)
5. [Guardrails System](#5-guardrails-system) (Points 51-60)
6. [Visual Designer](#6-visual-designer) (Points 61-75)
7. [File Structure & Organization](#7-file-structure--organization) (Points 76-82)
8. [Branching & Decision Logic](#8-branching--decision-logic) (Points 83-88)
9. [Monitoring & Debugging](#9-monitoring--debugging) (Points 89-94)
10. [Documentation & Usability](#10-documentation--usability) (Points 95-100)

---

## 1. .hazina Format Extensions

### Points 1-15: Extend .hazina format to support advanced workflow features

1. **Add [StepN] section support** to .hazina workflow files for multi-step workflows
2. **Add Temperature field** to step configuration for per-step LLM temperature control
3. **Add MaxTokens field** to step configuration for token budget limits per step
4. **Add TopP field** to step configuration for nucleus sampling control
5. **Add FrequencyPenalty field** to step configuration for repetition control
6. **Add PresencePenalty field** to step configuration for topic diversity
7. **Add Model field** to step configuration for per-step model selection (gpt-4, claude-3, etc.)
8. **Add FallbackModel field** to step configuration for automatic fallback when primary model fails
9. **Add RAGStore field** to step configuration for store selection per step
10. **Add RAGTopK field** to step configuration for number of retrieval results
11. **Add RAGMinSimilarity field** to step configuration for relevancy threshold
12. **Add RAGUseEmbeddings field** to step configuration (true/false for semantic vs keyword search)
13. **Add RAGMetadataFilter field** to step configuration for filtering by tags, date, etc.
14. **Add Guardrails field** to step configuration (comma-separated list: "no-pii,content-filter,tone-check")
15. **Add StepTimeout field** to step configuration for maximum execution time per step

---

## 2. Workflow Engine Enhancements

### Points 16-30: Enhance Hazina.AI.Workflows.WorkflowEngine to support new features

16. **Create HazinaWorkflowConfigParser** to parse extended .hazina workflow format
17. **Add support for loading workflows from C:\stores\{appName}\.hazina\workflows\** folder
18. **Implement per-step LLM parameter application** (temperature, topP, etc.)
19. **Implement per-step RAG configuration application**
20. **Add GuardrailExecutionService** to execute guardrails before/after each step
21. **Create WorkflowExecutionContext** to pass configuration through execution pipeline
22. **Add event-driven execution model** (StepStarted, StepCompleted, StepFailed events)
23. **Implement workflow state persistence** for pause/resume capability
24. **Add workflow versioning support** (track .hazina file version and migration)
25. **Create WorkflowTemplateService** to manage reusable workflow templates
26. **Add parallel step execution with configurable concurrency limits**
27. **Implement retry logic with exponential backoff** for failed steps
28. **Add circuit breaker pattern** for external service calls (LLM, RAG, etc.)
29. **Create comprehensive WorkflowExecutionResult** with detailed metrics per step
30. **Add support for nested workflows** (workflow calling another workflow)

---

## 3. LLM Configuration System

### Points 31-40: Create flexible per-step LLM configuration

31. **Create LLMStepConfig class** to encapsulate all LLM parameters for a step
32. **Implement ModelRegistry** to manage available models (OpenAI, Anthropic, Google, Ollama, etc.)
33. **Add ModelSelectionStrategy** for automatic model selection based on task complexity
34. **Create TokenBudgetManager** to track and enforce token limits per step and per workflow
35. **Implement CostEstimator** to calculate estimated cost before workflow execution
36. **Add ModelFallbackChain** for automatic failover (gpt-4 → gpt-3.5-turbo → llama-3)
37. **Create PromptTemplateEngine** for dynamic prompt construction with variables
38. **Add ResponseFormatValidator** to ensure LLM outputs match expected format (JSON, XML, etc.)
39. **Implement streaming support** for long-running LLM calls with progress reporting
40. **Create LLMParameterOptimizer** to suggest optimal temperature/topP based on task type

---

## 4. RAG Configuration System

### Points 41-50: Create flexible per-step RAG configuration

41. **Create RAGStepConfig class** to encapsulate all RAG parameters for a step
42. **Implement multi-store query support** (query multiple stores in single step)
43. **Add StoreSelectionStrategy** for automatic store selection based on query type
44. **Create HybridSearchConfig** for combining embedding search + keyword search + metadata filters
45. **Implement RelevancyScorer** with pluggable scoring algorithms (cosine, BM25, custom)
46. **Add CompositeSearchStrategy** to blend results from multiple search methods
47. **Create ContextAssemblyService** to build optimal context from retrieved documents
48. **Implement ChunkingStrategy** for large document handling (split, summarize, etc.)
49. **Add RAGCacheService** to cache frequent queries and reduce latency/cost
50. **Create RAGPerformanceMonitor** to track search quality metrics (precision, recall, NDCG)

---

## 5. Guardrails System

### Points 51-60: Implement comprehensive guardrails for safety and compliance

51. **Create IGuardrail interface** for pluggable guardrail implementations
52. **Implement GuardrailPipeline** to execute multiple guardrails in sequence
53. **Add PIIDetectionGuardrail** to detect and optionally redact PII (SSN, email, phone, etc.)
54. **Implement ToxicityGuardrail** using content safety APIs (OpenAI Moderation, Perspective API)
55. **Create TokenLimitGuardrail** to enforce max tokens per step
56. **Add JSONSchemaGuardrail** to validate JSON outputs against schema
57. **Implement RegexPatternGuardrail** for custom pattern matching and blocking
58. **Create ToneValidationGuardrail** to ensure output matches required tone (professional, casual, etc.)
59. **Add LanguageDetectionGuardrail** to validate output language
60. **Implement AuditLoggingGuardrail** to log all inputs/outputs for compliance

---

## 6. Visual Designer

### Points 61-75: Build n8n-style visual workflow designer

61. **Create React-based workflow designer** using React Flow library
62. **Implement drag-and-drop node palette** with categories (Agents, RAG, Decision, Loop, etc.)
63. **Add node configuration panel** for editing step parameters (temperature, RAG config, etc.)
64. **Implement edge connectors** with visual validation (type checking, cycle detection)
65. **Create node execution status overlay** (pending, running, success, failed)
66. **Add real-time execution visualization** with highlighted active nodes
67. **Implement zoom and pan** for large workflows
68. **Create minimap** for workflow navigation
69. **Add undo/redo** functionality for workflow editing
70. **Implement workflow validation** before save (all required fields filled, no cycles, etc.)
71. **Create .hazina import/export** with bidirectional sync
72. **Add workflow templates library** with pre-built common workflows
73. **Implement collaborative editing** with conflict resolution (optional, future)
74. **Create visual debugging mode** with step-through execution
75. **Add workflow version comparison** (visual diff between versions)

---

## 7. File Structure & Organization

### Points 76-82: Organize workflows and agents in application-specific folders

76. **Create standard folder structure:** `C:\stores\{appName}\.hazina\workflows\`
77. **Create agents folder:** `C:\stores\{appName}\.hazina\agents\`
78. **Create config folder:** `C:\stores\{appName}\.hazina\config\` for app-specific defaults
79. **Create templates folder:** `C:\stores\{appName}\.hazina\templates\` for workflow templates
80. **Implement WorkflowLoader** to scan and load all .hazina files from app folder
81. **Add version compatibility checking** (workflow format version vs engine version)
82. **Create migration tools** to upgrade old .hazina files to new format

---

## 8. Branching & Decision Logic

### Points 83-88: Enhance conditional logic and branching capabilities

83. **Add expression-based conditions** (e.g., "{score} > 0.8 && {language} == 'en'")
84. **Implement LLM-powered decision nodes** (use LLM to decide which branch to take)
85. **Create multi-way branching** (decision node with 3+ outputs, like switch/case)
86. **Add probabilistic routing** (randomly select branch based on weights)
87. **Implement external API decision nodes** (call external service to decide routing)
88. **Create decision logging** to track which branches are taken and why

---

## 9. Monitoring & Debugging

### Points 89-94: Add comprehensive monitoring and debugging tools

89. **Create WorkflowExecutionLogger** with structured logging (JSON format, searchable)
90. **Implement performance metrics collection** (latency, token usage, cost per step)
91. **Add real-time execution dashboard** showing all running workflows
92. **Create workflow execution history** with replay capability
93. **Implement alerting system** for workflow failures or performance degradation
94. **Add trace ID propagation** for distributed tracing across services

---

## 10. Documentation & Usability

### Points 95-100: Ensure system is usable by non-technical users

95. **Create visual workflow creation wizard** with step-by-step guidance
96. **Write comprehensive user guide** with screenshots and video tutorials
97. **Add inline help tooltips** in visual designer for all configuration options
98. **Create example workflows** for common use cases (onboarding, content generation, etc.)
99. **Implement schema validation errors** with helpful error messages and suggestions
100. **Add workflow testing mode** to test workflows with sample inputs before production use

---

## Priority Classification

### P0 - Critical (Must Have for MVP)
- Points: 1-15 (.hazina format extensions)
- Points: 16-30 (Workflow engine enhancements)
- Points: 31-40 (LLM configuration system)
- Points: 41-50 (RAG configuration system)
- Points: 61-70 (Visual designer core)
- Points: 76-82 (File structure & organization)

### P1 - Important (Have for V1.0)
- Points: 51-60 (Guardrails system)
- Points: 83-88 (Branching & decision logic)
- Points: 89-94 (Monitoring & debugging)
- Points: 95-100 (Documentation & usability)

### P2 - Nice to Have (Future iterations)
- Point 73 (Collaborative editing)
- Point 75 (Visual version comparison)
- Point 87 (External API decision nodes)

---

## Implementation Dependencies

### Dependency Graph
```
.hazina Format Extensions (1-15)
  ↓
Workflow Engine Enhancements (16-30)
  ↓
├─→ LLM Configuration System (31-40)
├─→ RAG Configuration System (41-50)
└─→ Guardrails System (51-60)
  ↓
File Structure & Organization (76-82)
  ↓
Visual Designer (61-75)
  ↓
├─→ Branching & Decision Logic (83-88)
├─→ Monitoring & Debugging (89-94)
└─→ Documentation & Usability (95-100)
```

---

## Success Criteria

Each point is considered complete when:
1. ✅ Code is implemented in Hazina framework
2. ✅ Unit tests pass with >80% coverage
3. ✅ Integration tests pass for end-to-end workflows
4. ✅ Documentation is written (inline comments + user guide)
5. ✅ Code review is approved
6. ✅ Works in both client-manager and brand2boost applications

---

## Estimated Effort

| Category | Points | Estimated Days | Estimated Hours |
|----------|--------|----------------|-----------------|
| .hazina Format Extensions | 1-15 | 3-4 days | 24-32h |
| Workflow Engine Enhancements | 16-30 | 7-10 days | 56-80h |
| LLM Configuration System | 31-40 | 4-5 days | 32-40h |
| RAG Configuration System | 41-50 | 4-5 days | 32-40h |
| Guardrails System | 51-60 | 5-6 days | 40-48h |
| Visual Designer | 61-75 | 12-15 days | 96-120h |
| File Structure & Organization | 76-82 | 2-3 days | 16-24h |
| Branching & Decision Logic | 83-88 | 3-4 days | 24-32h |
| Monitoring & Debugging | 89-94 | 3-4 days | 24-32h |
| Documentation & Usability | 95-100 | 4-5 days | 32-40h |
| **TOTAL** | **100 points** | **47-61 days** | **376-488 hours** |

**Note:** Estimates assume one full-time developer. Parallel development by multiple developers can reduce calendar time significantly.

---

## Change Impact Analysis

### High Impact Changes
- Points 1-15: Changes .hazina file format (requires migration for existing files)
- Points 16-30: Core workflow engine changes (affects all workflow execution)
- Points 76-82: Changes where workflows are stored (requires app configuration updates)

### Medium Impact Changes
- Points 31-40: Adds new LLM configuration layer (backward compatible)
- Points 41-50: Adds new RAG configuration layer (backward compatible)
- Points 51-60: Adds new guardrails layer (opt-in, backward compatible)

### Low Impact Changes
- Points 61-75: New visual designer (doesn't affect existing .hazina files)
- Points 83-88: Enhanced branching (backward compatible with existing conditionals)
- Points 89-100: Monitoring, debugging, docs (additive, no breaking changes)

---

## Rollout Strategy

### Phase 1: Foundation (Weeks 1-3)
- Implement points 1-30 (format + engine)
- Test with existing workflows in brand2boost
- Create migration scripts for old workflows

### Phase 2: Configuration Systems (Weeks 4-6)
- Implement points 31-60 (LLM, RAG, guardrails)
- Update existing workflows to use new features
- Performance testing and optimization

### Phase 3: Visual Designer MVP (Weeks 7-10)
- Implement points 61-75 (visual designer)
- User testing with non-technical users
- Iterate based on feedback

### Phase 4: Polish & Production (Weeks 11-13)
- Implement points 76-100 (organization, branching, monitoring, docs)
- Final testing and bug fixes
- Production deployment

---

## Risk Mitigation

### Technical Risks
- **Risk:** .hazina format becomes too complex
  - **Mitigation:** Keep format human-readable, provide visual designer as primary interface
- **Risk:** Performance degradation with per-step configuration
  - **Mitigation:** Lazy loading, caching, parallel execution
- **Risk:** Breaking changes affect existing workflows
  - **Mitigation:** Versioning, migration scripts, backward compatibility

### Usability Risks
- **Risk:** System too complex for non-coders
  - **Mitigation:** Templates, wizards, inline help, video tutorials
- **Risk:** Visual designer doesn't meet user expectations
  - **Mitigation:** Early user testing, iterative development, feedback loops

---

**Document Owner:** Claude Agent
**Last Updated:** 2026-01-17
**Status:** Ready for Review
