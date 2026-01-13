# Hazina AI Framework - Deep Dive Documentation

**Project Name:** Hazina (formerly DevGPT)
**Type:** Production-Ready AI Infrastructure Framework for .NET
**Purpose:** Multi-Provider LLM Abstraction with Built-In Production Features
**Status:** ✅ Active Development
**Generated:** 2026-01-08

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Core Capabilities](#core-capabilities)
6. [Solution Files Guide](#solution-files-guide)
7. [Package Ecosystem](#package-ecosystem)
8. [Multi-Provider Support](#multi-provider-support)
9. [RAG Engine](#rag-engine)
10. [Agentic Workflows](#agentic-workflows)
11. [Neurochain (Multi-Layer Reasoning)](#neurochain-multi-layer-reasoning)
12. [Production Features](#production-features)
13. [NuGet Packages](#nuget-packages)
14. [Development Workflow](#development-workflow)
15. [Use Cases](#use-cases)

---

## OVERVIEW

### What is Hazina?

Hazina is a **production-ready AI infrastructure framework for .NET** that provides:

- **Multi-provider LLM abstraction** - Switch between OpenAI, Anthropic, Gemini, Mistral, local models
- **Automatic failover** - Circuit breaker pattern with provider fallback
- **Built-in production features** - Cost tracking, health monitoring, observability
- **RAG engine** - Retrieval-Augmented Generation with smart chunking
- **Agentic workflows** - Multi-agent coordination and tool calling
- **Neurochain** - Multi-layer reasoning for high-confidence responses
- **Zero vendor lock-in** - Unified API across all providers

### Why Hazina?

**Comparison Table:**

| Feature | Hazina | LangChain | Semantic Kernel | DIY |
|---------|--------|-----------|-----------------|-----|
| **Language** | C# native | Python | C# | C# |
| **Setup time** | 4 lines | 50+ lines | 30+ lines | 200+ lines |
| **Multi-provider failover** | Built-in ✅ | Manual | Plugin required | Build it yourself |
| **Hallucination detection** | Built-in ✅ | External tools | Not included | Build it yourself |
| **Cost tracking** | Automatic ✅ | Manual | Manual | Build it yourself |
| **Production monitoring** | Included ✅ | External | External | Build it yourself |
| **Local + Cloud** | Unified API ✅ | Separate configs | Separate configs | Multiple implementations |

**Value Proposition:**
- **12-19 weeks of work** → **0 with Hazina**
- **4 lines to production** - One-line setup, auto-failover, built-in monitoring
- **Ship faster** - RAG, agents, embeddings included, not bolted on

### History: DevGPT → Hazina

**Original Name:** DevGPT
**Rebrand Date:** Late 2025
**Reason:** Better positioning as production AI framework, not just developer tool

**Legacy References:**
- Many files still have `DevGPT` namespace (being migrated)
- NuGet packages published under `DevGPT.*` (will publish as `Hazina.*`)
- Solution files: Some still named `DevGPT.*.sln`

### Key Metrics

- **108 C# project files** (.csproj)
- **62 logical projects** (per SOLUTIONS.md)
- **7 solution files** (QuickStart, Core, AI, Tools, Apps, and 2 legacy)
- **~30+ NuGet packages** (DevGPT.* namespace, migrating to Hazina.*)
- **Multi-framework support:** .NET 9.0 (primary), .NET 8.0 (supported)
- **Active GitHub repo:** (URL to be confirmed)

---

## ARCHITECTURE

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Your Application                          │
│                   (Client Manager, CLI, Desktop, etc.)          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Hazina.AI.FluentAPI                          │
│  Hazina.AI() → .WithProvider() → .WithFaultDetection() → Ask()  │
│                  Developer-Friendly Entry Point                  │
└─────────────────────────────────────────────────────────────────┘
          │              │              │              │
    ┌─────┴─────┐  ┌─────┴─────┐  ┌─────┴─────┐  ┌─────┴─────┐
    │           │  │           │  │           │  │           │
    ▼           ▼  ▼           ▼  ▼           ▼  ▼           ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│Providers │ │   RAG    │ │  Agents  │ │Neurochain│ │   Tools  │
├──────────┤ ├──────────┤ ├──────────┤ ├──────────┤ ├──────────┤
│ OpenAI   │ │Indexing  │ │Tools     │ │Fast Layer│ │BigQuery  │
│Anthropic │ │Retrieval │ │Workflows │ │Deep Layer│ │Social    │
│  Gemini  │ │Chunking  │ │Coord     │ │Verify    │ │WordPress │
│ Mistral  │ │Generate  │ │State     │ │Consensus │ │Chat      │
│  Local   │ │Embed     │ │Memory    │ │Confidence│ │FileOps   │
└──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
    │           │           │           │           │
    └───────────┴───────────┴───────────┴───────────┘
                      │
                      ▼
    ┌─────────────────────────────────────────────┐
    │         Core Infrastructure Layer            │
    ├─────────────────────────────────────────────┤
    │ • LLM Clients (OpenAI, Anthropic, Gemini)   │
    │ • Embedding Stores (PostgreSQL, Supabase)   │
    │ • Document Stores (Vector DB, Full-Text)    │
    │ • Security (Auth, Secrets, Encryption)      │
    │ • Observability (Logs, Metrics, Traces)     │
    └─────────────────────────────────────────────┘
                      │
      ┌───────────────┼───────────────┐
      │               │               │
      ▼               ▼               ▼
┌──────────┐   ┌──────────┐   ┌──────────┐
│OpenAI API│   │Claude API│   │PostgreSQL│
└──────────┘   └──────────┘   └──────────┘
```

### Layered Architecture

**Layer 1: Application Layer**
- Client applications (Brand2Boost, CLI tools, Desktop apps)
- Consumes Hazina via NuGet packages or project references

**Layer 2: FluentAPI (Developer Interface)**
- `Hazina.AI.FluentAPI` - Fluent, chainable API
- High-level abstractions hiding complexity
- Configuration via code or JSON

**Layer 3: Feature Modules**
- `Hazina.AI.RAG` - RAG engine
- `Hazina.AI.Agents` - Agent framework
- `Hazina.Neurochain` - Multi-layer reasoning
- `Hazina.AI.Providers` - Provider abstraction
- `Hazina.Tools.*` - Service tools (BigQuery, Social, etc.)

**Layer 4: Core Infrastructure**
- `Hazina.LLMs.*` - LLM client libraries (OpenAI, Anthropic, etc.)
- `Hazina.Store.*` - Storage abstractions (Embeddings, Documents)
- `Hazina.Security.*` - Auth, secrets, encryption
- `Hazina.Observability.*` - Logging, metrics, tracing

**Layer 5: External Services**
- OpenAI API, Anthropic API, Gemini API, Mistral API
- PostgreSQL (with pgvector extension)
- Supabase (managed PostgreSQL + vector search)

---

## TECHNOLOGY STACK

### Core Technologies

**Framework:**
- **.NET 9.0** - Latest LTS (primary target)
- **.NET 8.0** - Supported (compatibility target)
- **C# 13** - Latest language features

**LLM Providers (Official SDKs):**
- **OpenAI** - OpenAI SDK for .NET
- **Anthropic** - Anthropic SDK for .NET
- **Google Gemini** - Google.GenerativeAI SDK
- **Mistral** - MistralAI SDK
- **HuggingFace** - Custom HTTP client
- **Semantic Kernel** - Microsoft's SK integration
- **Local models** - Ollama, LM Studio support

**Vector Storage:**
- **PostgreSQL + pgvector** - Production-grade vector DB
- **Supabase** - Managed PostgreSQL with vector search
- **In-Memory** - For development/testing

**Document Storage:**
- **PostgreSQL** - Full-text search with GIN indexes
- **SQLite** - Embedded storage
- **Entity Framework Core** - ORM

**Observability:**
- **Serilog** - Structured logging
- **OpenTelemetry** - Distributed tracing
- **Application Insights** - Azure monitoring integration
- **Custom metrics** - Token usage, cost tracking

**Security:**
- **ASP.NET Core Data Protection** - Key management
- **Azure Key Vault** - Secret storage (optional)
- **Environment variables** - API key storage

**HTTP & APIs:**
- **HttpClient** - HTTP communications
- **Polly** - Resilience policies (retry, circuit breaker, timeout)
- **Refit** - Type-safe REST client (some providers)

**Serialization:**
- **System.Text.Json** - JSON serialization
- **Newtonsoft.Json** - Fallback for compatibility

**Testing:**
- **xUnit** - Unit testing framework
- **Moq** - Mocking library
- **Testcontainers** - Integration testing with containers

**Build & Packaging:**
- **MSBuild** - Build system
- **NuGet** - Package distribution
- **Directory.Build.props** - Centralized MSBuild properties

---

## PROJECT STRUCTURE

### Repository Layout

```
C:\Projects\hazina\
├── Hazina.sln                    ← Full solution (all 62 projects)
├── Hazina.QuickStart.sln         ← Quick start (10 essential projects)
├── Hazina.Core.sln               ← Core infrastructure
├── Hazina.AI.sln                 ← AI features
├── Hazina.Tools.sln              ← Tools & services
├── Hazina.Apps.sln               ← Applications & demos
│
├── Libraries/                     ← Core framework libraries
│   ├── LLMs/                     ← LLM provider clients
│   │   ├── OpenAI/               ← OpenAI integration
│   │   ├── Anthropic/            ← Anthropic (Claude) integration
│   │   ├── Gemini/               ← Google Gemini integration
│   │   ├── Mistral/              ← Mistral AI integration
│   │   ├── HuggingFace/          ← HuggingFace integration
│   │   ├── SemanticKernel/       ← Microsoft Semantic Kernel
│   │   ├── Client/               ← Unified LLM client abstraction
│   │   ├── Classes/              ← Shared LLM models/classes
│   │   ├── Helpers/              ← LLM helper utilities
│   │   └── ClientTools/          ← LLM client tools
│   │
│   ├── Store/                    ← Storage abstractions
│   │   ├── EmbeddingStore/       ← Vector embeddings storage
│   │   └── DocumentStore/        ← Document storage
│   │
│   ├── DevGPT.Generator/         ← Code generation
│   ├── DevGPT.DynamicAPI/        ← Dynamic API creation
│   └── DevGPT.AgentFactory/      ← Agent factory pattern
│
├── src/                           ← Main source code
│   ├── AI/                       ← AI-specific features
│   │   ├── Hazina.AI.FluentAPI/  ← Developer-friendly API
│   │   ├── Hazina.AI.RAG/        ← RAG engine
│   │   ├── Hazina.AI.Agents/     ← Agentic workflows
│   │   ├── Hazina.AI.Providers/  ← Multi-provider orchestration
│   │   └── Hazina.AI.FaultDetection/ ← Hallucination detection
│   │
│   ├── Neurochain/               ← Multi-layer reasoning
│   │   ├── Hazina.Neurochain.Core/
│   │   ├── Hazina.Neurochain.Layers/
│   │   └── Hazina.Neurochain.Consensus/
│   │
│   ├── Production/               ← Production features
│   │   ├── Hazina.Production.Monitoring/
│   │   ├── Hazina.Production.CostTracking/
│   │   └── Hazina.Production.HealthChecks/
│   │
│   ├── Security/                 ← Security features
│   │   ├── Hazina.Security.Auth/
│   │   ├── Hazina.Security.Secrets/
│   │   └── Hazina.Security.Encryption/
│   │
│   └── Observability/            ← Monitoring & logging
│       ├── Hazina.Observability.Logging/
│       ├── Hazina.Observability.Metrics/
│       ├── Hazina.Observability.Tracing/
│       └── Hazina.Observability.LLMLogs/
│
├── Tools/                         ← Service tools (legacy DevGPTTools)
│   ├── Tools.Core/
│   ├── Tools.Data/
│   ├── Tools.Models/
│   ├── Tools.AI.Agents/
│   ├── Tools.Services/
│   ├── Tools.Services.BigQuery/
│   ├── Tools.Services.Chat/
│   ├── Tools.Services.Social/
│   ├── Tools.Services.WordPress/
│   ├── Tools.Services.FileOps/
│   ├── Tools.Services.Prompts/
│   └── Tools.Services.*/
│
├── apps/                          ← Applications & demos
│   ├── CLI/                      ← Command-line tools
│   ├── Desktop/                  ← Desktop applications
│   ├── Web/                      ← Web applications
│   ├── Demos/                    ← Demo projects
│   │   ├── Hazina.Demo.RAG/
│   │   ├── Hazina.Demo.Agents/
│   │   ├── Hazina.Demo.Supabase/
│   │   └── Hazina.Demo.Neurochain/
│   └── Testing/                  ← Test applications
│
├── Tests/                         ← Test projects
│   ├── Hazina.AI.Tests/
│   ├── Hazina.Neurochain.Tests/
│   ├── Hazina.RAG.Tests/
│   └── */
│
├── docs/                          ← Documentation
│   ├── quickstart.md
│   ├── RAG_GUIDE.md
│   ├── AGENTS_GUIDE.md
│   ├── NEUROCHAIN_GUIDE.md
│   ├── KNOWLEDGE_STORAGE.md
│   ├── CODE_INTELLIGENCE_GUIDE.md
│   ├── PRODUCTION_MONITORING_GUIDE.md
│   ├── SUPABASE_SETUP.md
│   └── */
│
├── scripts/                       ← Build & automation scripts
│   ├── publish-all.ps1
│   ├── pack-all.ps1
│   ├── fix_references.ps1
│   └── RenameDevGPTToHazina.ps1
│
├── config/                        ← Configuration templates
├── data/                          ← Sample data
├── monitoring/                    ← Monitoring configs
├── archive/                       ← Archived code
├── local_packages/                ← Local NuGet packages
├── nupkgs/                        ← Built NuGet packages
│
├── README.md                      ← Main README
├── SOLUTIONS.md                   ← Solution files guide
├── CONTRIBUTING.md                ← Contribution guidelines
├── LICENSE                        ← MIT License
├── NuGet.config                   ← NuGet configuration
├── Directory.Build.props          ← Centralized MSBuild props
├── docker-compose.yml             ← Docker setup
├── Dockerfile                     ← Container image
└── */                             ← Additional files
```

### Key Directories

**Libraries/** - Core framework libraries (LLM clients, storage)
**src/** - Main Hazina features (AI, Neurochain, Production, Security)
**Tools/** - Service tools (legacy DevGPTTools being migrated)
**apps/** - Applications, demos, testing
**Tests/** - Unit and integration tests
**docs/** - Documentation and guides

---

## CORE CAPABILITIES

### 1. Multi-Provider LLM Abstraction

**Unified API across all providers:**
```csharp
// Setup with automatic failover
var ai = QuickSetup.SetupWithFailover(openAiKey, anthropicKey);

// Use any provider with same API
var response = await ai.GetResponse(messages);
// Uses OpenAI (primary), fails over to Claude (fallback)
```

**Supported Providers:**
- **OpenAI** - GPT-4, GPT-3.5, GPT-4-Turbo
- **Anthropic** - Claude 3 (Opus, Sonnet, Haiku)
- **Google** - Gemini Pro, Gemini Ultra
- **Mistral** - Mistral Large, Mistral Medium
- **HuggingFace** - Any HF model
- **Local models** - Ollama, LM Studio, custom endpoints

**Provider Selection Strategies:**
- `LeastCost` - Always use cheapest provider
- `FastestResponse` - Use fastest provider
- `BestQuality` - Use highest-quality model
- `Failover` - Primary with fallback
- `RoundRobin` - Distribute load across providers

**Circuit Breaker:**
- Detects provider failures
- Opens circuit after N failures
- Auto-recovery after timeout
- Prevents cascading failures

### 2. RAG (Retrieval-Augmented Generation)

**Smart Document Indexing:**
```csharp
var rag = new RAGEngine(ai, vectorStore);

// Index documents with automatic chunking
await rag.IndexDocumentsAsync(documents, new IndexOptions
{
    ChunkSize = 1000,
    ChunkOverlap = 200,
    Strategy = ChunkingStrategy.Semantic
});
```

**Retrieval:**
```csharp
var response = await rag.QueryAsync("question", new RAGQueryOptions
{
    TopK = 5,
    MinSimilarity = 0.7,
    RequireCitation = true
});
```

**Features:**
- **Smart chunking** - Semantic, sentence, paragraph, sliding window
- **Vector embeddings** - OpenAI, Cohere, local models
- **Hybrid search** - Vector + full-text search
- **Metadata filtering** - Filter by date, author, type, etc.
- **Citation tracking** - Track which documents contributed to answer
- **Re-ranking** - Cross-encoder re-ranking for better results

### 3. Agentic Workflows

**Multi-Agent Coordination:**
```csharp
var coordinator = new MultiAgentCoordinator();

coordinator.AddAgent(new Agent("researcher", researchPrompt, ai));
coordinator.AddAgent(new Agent("writer", writerPrompt, ai));
coordinator.AddAgent(new Agent("reviewer", reviewerPrompt, ai));

var result = await coordinator.ExecuteAsync("Write blog post about AI",
    CoordinationStrategy.Sequential);
```

**Agent Features:**
- **Tool calling** - Agents can use external tools (APIs, databases, etc.)
- **State management** - Persistent agent state across conversations
- **Workflows** - Sequential, parallel, conditional execution
- **Memory** - Short-term (conversation) and long-term (RAG) memory
- **Reflection** - Agents can critique and improve their own output

**Built-In Tools:**
- Web search
- File operations
- Database queries
- API calls
- Code execution
- Custom tools (extensible)

### 4. Neurochain (Multi-Layer Reasoning)

**High-Confidence Responses:**
```csharp
var neurochain = new NeuroChainOrchestrator();
neurochain.AddLayer(new FastReasoningLayer(ai));   // Quick analysis
neurochain.AddLayer(new DeepReasoningLayer(ai));   // Thorough analysis
neurochain.AddLayer(new VerificationLayer(ai));    // Cross-validation

var result = await neurochain.ReasonAsync("Complex question");
// Returns 95-99% confidence through independent validation
```

**Reasoning Layers:**
- **Fast Layer** - Quick initial response (GPT-3.5)
- **Deep Layer** - Thorough analysis (GPT-4)
- **Verification Layer** - Cross-validate responses
- **Consensus Layer** - Combine multiple models
- **Confidence Scoring** - Estimate response reliability

**Use Cases:**
- Medical/legal advice (requires high confidence)
- Financial analysis
- Code review and security audits
- Fact-checking
- Any domain requiring >95% confidence

### 5. Fault Detection & Hallucination Prevention

**Automatic Validation:**
```csharp
var result = await Hazina.AI()
    .WithFaultDetection(minConfidence: 0.9)
    .Ask("What is the capital of France?")
    .ExecuteAsync();

if (result.Confidence < 0.9) {
    // Low confidence, may be hallucination
    // Automatically retries with refined prompt
}
```

**Detection Methods:**
- **Self-consistency** - Ask same question multiple ways, check agreement
- **Fact verification** - Cross-check facts with external sources
- **Confidence scoring** - Model's internal confidence
- **Contradiction detection** - Check for logical contradictions
- **Source verification** - Verify claims against provided documents

### 6. Cost Tracking & Budgets

**Automatic Cost Tracking:**
```csharp
ai.EnableCostTracking(budgetLimit: 10.00m);

var response = await ai.GetResponse(messages);
// Cost automatically tracked

var usage = ai.GetCostSummary();
Console.WriteLine($"Total cost: ${usage.TotalCost}");
Console.WriteLine($"Remaining budget: ${usage.RemainingBudget}");
```

**Features:**
- **Per-request cost** - Track cost of each API call
- **Budget limits** - Set hard limits, throw exception when exceeded
- **Usage analytics** - Cost by provider, model, user, time period
- **Cost optimization** - Suggest cheaper models when possible
- **Forecasting** - Predict costs based on usage patterns

### 7. Production Monitoring

**Health Checks:**
```csharp
ai.EnableHealthMonitoring();

var health = await ai.GetHealthStatusAsync();
// Checks:
// - Provider availability
// - API key validity
// - Circuit breaker status
// - Response latency
// - Error rates
```

**Observability:**
- **Structured logging** (Serilog, Application Insights)
- **Distributed tracing** (OpenTelemetry)
- **Metrics** (Prometheus, Grafana)
- **Alerting** (when error rate spikes, budget exceeded, etc.)

---

## SOLUTION FILES GUIDE

Hazina uses **focused solution files** to reduce cognitive load and improve build times.

### Hazina.QuickStart.sln (⭐ Start Here)

**Best for:** Getting started, learning Hazina, simple integrations
**Projects:** 10 essential packages
**Build time:** ~30 seconds

**Contains:**
1. `Hazina.AI.FluentAPI` - Developer-first API
2. `Hazina.AI.Providers` - Multi-provider abstraction
3. `Hazina.Neurochain.Core` - Multi-layer reasoning
4. `Hazina.AI.RAG` - RAG engine
5. `Hazina.AI.Agents` - Agentic workflows
6. `Hazina.LLMs.OpenAI` - OpenAI provider
7. `Hazina.LLMs.Anthropic` - Anthropic provider
8. `Hazina.Store.EmbeddingStore` - Embeddings storage
9. `Hazina.Store.DocumentStore` - Document storage
10. `Hazina.Production.Monitoring` - Production monitoring

**Use when:**
- New to Hazina
- Building simple AI apps
- Exploring capabilities

---

### Hazina.Core.sln

**Best for:** Core infrastructure work, LLM provider development
**Projects:** ~20 foundation packages
**Build time:** ~1 minute

**Contains:**
- All LLM provider libraries (`Hazina.LLMs.*`)
- Storage abstractions (`Hazina.Store.*`)
- Security packages (`Hazina.Security.*`)
- Observability packages (`Hazina.Observability.*`)

**Use when:**
- Working on LLM provider integrations
- Developing storage adapters
- Security or observability improvements
- Low-level infrastructure work

---

### Hazina.AI.sln

**Best for:** AI features development, advanced reasoning
**Projects:** ~15 AI-related packages
**Build time:** ~45 seconds

**Contains:**
- `Hazina.AI.*` - All AI packages
- `Hazina.Neurochain.*` - Multi-layer reasoning
- `Hazina.AI.RAG.*` - RAG components
- `Hazina.AI.Agents.*` - Agent framework
- `Hazina.AI.FaultDetection.*` - Hallucination detection

**Use when:**
- Developing AI algorithms
- Working on multi-layer reasoning
- Building agentic workflows
- RAG improvements

---

### Hazina.Tools.sln

**Best for:** Tools and services development
**Projects:** ~25 tool/service packages
**Build time:** ~1.5 minutes

**Contains:**
- `Tools.Core` - Core tool infrastructure
- `Tools.Services.*` - BigQuery, Social, WordPress, Chat, etc.
- `Tools.AI.Agents` - Tool-enabled agents
- `Tools.Data` - Data processing

**Use when:**
- Building new services (BigQuery, Social, etc.)
- Extending tool capabilities
- Working on data processing pipelines
- Integration with external services

---

### Hazina.Apps.sln

**Best for:** Application development and demos
**Projects:** ~10 app projects
**Build time:** ~1 minute

**Contains:**
- `apps/CLI/` - Command-line tools
- `apps/Desktop/` - Desktop applications
- `apps/Web/` - Web applications
- `apps/Demos/` - Demo projects
- `apps/Testing/` - Test applications

**Use when:**
- Building end-user applications
- Creating demos
- Testing integrations
- Working on UI/UX

---

### Hazina.sln (Full Solution)

**Best for:** Full builds, release preparation, comprehensive testing
**Projects:** All 62 projects
**Build time:** ~5 minutes

**Use when:**
- Preparing releases
- Running full test suites
- Validating cross-project changes
- Building all NuGet packages

**Warning:** Heavy solution, only use when necessary!

---

## PACKAGE ECOSYSTEM

### Core Packages (Public NuGet)

**Entry Point:**
- `Hazina.AI.FluentAPI` - Main developer API

**AI Capabilities:**
- `Hazina.AI.RAG` - RAG engine
- `Hazina.AI.Agents` - Agentic workflows
- `Hazina.AI.Providers` - Multi-provider orchestration
- `Hazina.AI.FaultDetection` - Hallucination detection

**Reasoning:**
- `Hazina.Neurochain.Core` - Multi-layer reasoning
- `Hazina.Neurochain.Layers` - Reasoning layers
- `Hazina.Neurochain.Consensus` - Consensus algorithms

**LLM Providers:**
- `Hazina.LLMs.OpenAI` - OpenAI integration
- `Hazina.LLMs.Anthropic` - Anthropic (Claude)
- `Hazina.LLMs.Gemini` - Google Gemini
- `Hazina.LLMs.Mistral` - Mistral AI
- `Hazina.LLMs.HuggingFace` - HuggingFace
- `Hazina.LLMs.SemanticKernel` - Microsoft SK
- `Hazina.LLMs.Client` - Unified client
- `Hazina.LLMs.Classes` - Shared models
- `Hazina.LLMs.Helpers` - Helper utilities

**Storage:**
- `Hazina.Store.EmbeddingStore` - Vector embeddings
- `Hazina.Store.DocumentStore` - Document storage

**Production:**
- `Hazina.Production.Monitoring` - Health checks, metrics
- `Hazina.Production.CostTracking` - Cost tracking
- `Hazina.Production.HealthChecks` - Health checks

**Security:**
- `Hazina.Security.Auth` - Authentication
- `Hazina.Security.Secrets` - Secret management
- `Hazina.Security.Encryption` - Encryption

**Observability:**
- `Hazina.Observability.Logging` - Structured logging
- `Hazina.Observability.Metrics` - Metrics
- `Hazina.Observability.Tracing` - Distributed tracing
- `Hazina.Observability.LLMLogs` - LLM call logging

### Tools Packages (Internal, Not on NuGet Yet)

**Core:**
- `Hazina.Tools.Core` - Tool infrastructure
- `Hazina.Tools.Data` - Data layer
- `Hazina.Tools.Models` - Data models

**AI & Agents:**
- `Hazina.Tools.AI.Agents` - Tool-enabled agents

**Services:**
- `Hazina.Tools.Services` - Base services
- `Hazina.Tools.Services.BigQuery` - Google BigQuery
- `Hazina.Tools.Services.Chat` - Chat services
- `Hazina.Tools.Services.Social` - Social media
- `Hazina.Tools.Services.WordPress` - WordPress integration
- `Hazina.Tools.Services.FileOps` - File operations
- `Hazina.Tools.Services.Prompts` - Prompt management
- `Hazina.Tools.Services.Store` - Store services
- `Hazina.Tools.Services.ContentRetrieval` - Content retrieval
- `Hazina.Tools.Services.Intake` - Data intake
- `Hazina.Tools.Services.Web` - Web scraping/crawling

**Infrastructure:**
- `Hazina.Tools.Common.Infrastructure.AspNetCore` - ASP.NET Core helpers
- `Hazina.Tools.Common.Models` - Common models

---

## MULTI-PROVIDER SUPPORT

### Supported Providers

**Cloud LLMs:**
1. **OpenAI** - GPT-4, GPT-3.5, GPT-4-Turbo, GPT-4o
2. **Anthropic** - Claude 3 Opus, Sonnet, Haiku
3. **Google** - Gemini Pro, Gemini Ultra
4. **Mistral** - Mistral Large, Medium, Small
5. **HuggingFace** - Any HF Inference API model

**Local LLMs:**
6. **Ollama** - Run models locally (Llama 3, Mistral, etc.)
7. **LM Studio** - Local model server
8. **Custom endpoints** - Any OpenAI-compatible API

**Frameworks:**
9. **Semantic Kernel** - Microsoft's AI framework

### Provider Abstraction

**Unified Interface:**
```csharp
public interface ILLMProvider
{
    Task<LLMResponse> GetResponseAsync(LLMRequest request);
    Task<Stream> GetStreamingResponseAsync(LLMRequest request);
    Task<EmbeddingResult> GetEmbeddingsAsync(string[] texts);
    ProviderCapabilities GetCapabilities();
}
```

**All providers implement this interface** → Zero code changes to switch providers

### Automatic Failover

**Configuration:**
```csharp
var ai = Hazina.AI()
    .WithPrimaryProvider(new OpenAIProvider(apiKey))
    .WithFallbackProvider(new AnthropicProvider(apiKey))
    .WithCircuitBreaker(failureThreshold: 3, timeout: TimeSpan.FromMinutes(5))
    .Build();
```

**How It Works:**
1. Try primary provider (OpenAI)
2. If fails (timeout, rate limit, error):
   - Increment failure counter
   - If counter >= threshold → Open circuit
3. Use fallback provider (Anthropic)
4. After timeout → Reset circuit, try primary again

**Circuit Breaker States:**
- **Closed** - Normal operation, using primary
- **Open** - Too many failures, using fallback
- **Half-Open** - Testing if primary recovered

---

## RAG ENGINE

### Architecture

```
Document Ingestion → Chunking → Embedding → Vector Store
                                                  │
User Query → Embedding → Similarity Search → Retrieve Top-K
                                                  │
                               Context + Query → LLM → Response
```

### Document Ingestion

**Supported Formats:**
- Text files (.txt, .md)
- PDFs (.pdf)
- Word documents (.docx)
- HTML (.html)
- JSON (.json)
- Custom parsers (extensible)

**Chunking Strategies:**
- **Semantic** - Split on semantic boundaries (paragraphs, topics)
- **Sentence** - Split on sentence boundaries
- **Paragraph** - Split on paragraph boundaries
- **Sliding window** - Overlapping chunks (configurable overlap)
- **Token-based** - Split by token count (respects model limits)

**Metadata Extraction:**
- Title, author, date
- Source URL, file path
- Custom metadata tags

### Embedding Generation

**Embedding Providers:**
- OpenAI `text-embedding-ada-002` (1536 dims)
- OpenAI `text-embedding-3-small` (1536 dims, cheaper)
- OpenAI `text-embedding-3-large` (3072 dims, highest quality)
- Cohere embeddings
- HuggingFace sentence transformers
- Local embedding models (via Ollama)

**Batch Processing:**
- Processes 100-1000 documents/second
- Automatic batching for API efficiency
- Progress tracking

### Vector Storage

**Supported Backends:**
1. **PostgreSQL + pgvector** (production)
   - Up to 100M+ vectors
   - HNSW index for fast search
   - Full metadata filtering

2. **Supabase** (managed PostgreSQL)
   - Easy setup
   - Built-in auth
   - Real-time subscriptions

3. **In-Memory** (development)
   - Fast, no setup
   - Limited to RAM size
   - Not persistent

**Index Types:**
- **HNSW** (Hierarchical Navigable Small World) - Fast approximate search
- **IVFFlat** - Inverted file index, good for large datasets
- **Brute-force** - Exact search, slow but accurate

### Retrieval

**Similarity Metrics:**
- **Cosine similarity** (default) - Best for most cases
- **Euclidean distance** - For normalized vectors
- **Dot product** - Fast, good for some models

**Hybrid Search:**
```csharp
var results = await rag.HybridSearchAsync(query, new HybridSearchOptions
{
    VectorWeight = 0.7,      // 70% vector similarity
    FullTextWeight = 0.3,    // 30% keyword matching
    TopK = 10
});
```

**Re-Ranking:**
- Cross-encoder models for better relevance
- Re-rank top-K results before LLM
- Improves answer quality significantly

### Generation

**Prompt Template:**
```
Context:
{retrieved_documents}

Question: {user_question}

Please answer the question based on the context above.
If the answer is not in the context, say "I don't know".
Cite sources for your answer.
```

**Citation Tracking:**
- Tracks which documents contributed to answer
- Returns source IDs and snippets
- Enables fact-checking

---

## AGENTIC WORKFLOWS

### Agent Architecture

```
Agent = Prompt + Tools + Memory + LLM
```

**Components:**
1. **Prompt** - System prompt defining agent role/behavior
2. **Tools** - Functions agent can call (search, database, APIs)
3. **Memory** - Short-term (conversation) + long-term (RAG)
4. **LLM** - Language model powering the agent

### Tool Calling

**Built-In Tools:**
- `WebSearch` - Search the internet
- `Calculator` - Perform calculations
- `FileRead` - Read files
- `FileWrite` - Write files
- `DatabaseQuery` - Query databases
- `APICall` - Call external APIs
- `CodeExecutor` - Execute code (sandboxed)

**Custom Tools:**
```csharp
public class WeatherTool : ITool
{
    public string Name => "get_weather";
    public string Description => "Get current weather for a location";

    public async Task<ToolResult> ExecuteAsync(ToolCall call)
    {
        var location = call.Parameters["location"];
        var weather = await GetWeatherAsync(location);
        return new ToolResult { Success = true, Data = weather };
    }
}
```

**Function Calling:**
- Uses OpenAI function calling API
- Anthropic tool use
- JSON mode for structured output

### Multi-Agent Coordination

**Coordination Strategies:**

1. **Sequential** - Agents run one after another
   ```csharp
   var result = await coordinator.ExecuteAsync(task,
       CoordinationStrategy.Sequential);
   // Agent1 → Agent2 → Agent3
   ```

2. **Parallel** - Agents run concurrently
   ```csharp
   var result = await coordinator.ExecuteAsync(task,
       CoordinationStrategy.Parallel);
   // Agent1, Agent2, Agent3 simultaneously
   ```

3. **Hierarchical** - Manager agent delegates to worker agents
   ```csharp
   var manager = new ManagerAgent(managerPrompt, ai);
   manager.AddWorker(new Agent("researcher", ...));
   manager.AddWorker(new Agent("writer", ...));
   ```

4. **Autonomous** - Agents decide when to collaborate
   ```csharp
   var swarm = new AutonomousSwarm();
   swarm.AddAgent(agent1, agent2, agent3);
   // Agents communicate via shared message bus
   ```

### Agent Memory

**Short-Term Memory:**
- Conversation history
- Last N messages kept in context
- Automatic summarization when context full

**Long-Term Memory:**
- RAG-backed memory
- Stores important facts/learnings
- Retrieved when relevant to current task

**Episodic Memory:**
- Remembers past task executions
- "Last time I did this, I learned..."
- Improves over time

### Agent State Management

**Persistent State:**
```csharp
public class AgentState
{
    public string AgentId { get; set; }
    public Dictionary<string, object> Variables { get; set; }
    public List<Message> ConversationHistory { get; set; }
    public List<string> CompletedTasks { get; set; }
}
```

**State Storage:**
- JSON files (simple)
- Database (PostgreSQL, SQLite)
- Redis (fast, distributed)

---

## NEUROCHAIN (MULTI-LAYER REASONING)

### Concept

**Problem:** Single LLM calls can produce incorrect or low-confidence answers.

**Solution:** Multiple independent reasoning layers validate each other.

**Result:** 95-99% confidence through cross-validation.

### Architecture

```
User Question
     │
     ▼
┌─────────────────────┐
│  Fast Layer (GPT-3.5) │ → Quick initial answer
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│  Deep Layer (GPT-4)  │ → Thorough analysis
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│ Verification Layer   │ → Cross-check facts
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│  Consensus Layer     │ → Combine + score confidence
└─────────────────────┘
     │
     ▼
 Final Answer + Confidence Score
```

### Reasoning Layers

**1. Fast Reasoning Layer:**
- Uses fast model (GPT-3.5, Claude Haiku)
- Generates initial answer quickly
- Good for obvious questions
- Low cost

**2. Deep Reasoning Layer:**
- Uses powerful model (GPT-4, Claude Opus)
- Thorough analysis
- Chain-of-thought reasoning
- Higher cost, better quality

**3. Verification Layer:**
- Fact-checks previous layers
- Cross-references external sources
- Detects contradictions
- Validates claims

**4. Consensus Layer:**
- Compares answers from all layers
- Computes agreement score
- Resolves conflicts
- Returns final answer + confidence

### Confidence Scoring

**Factors:**
- **Agreement** - Do all layers agree?
- **Consistency** - Are answers logically consistent?
- **Evidence** - How much supporting evidence?
- **Model confidence** - Internal model confidence scores

**Score Ranges:**
- **0.95-1.0** - Very high confidence (use answer)
- **0.80-0.95** - High confidence (probably correct)
- **0.60-0.80** - Medium confidence (verify manually)
- **0.00-0.60** - Low confidence (don't trust)

### Use Cases

**Medical/Legal Advice:**
- Requires >95% confidence
- Wrong answers = serious consequences
- Neurochain validates before returning

**Financial Analysis:**
- Stock predictions, market analysis
- High stakes decisions
- Cross-validate with multiple models

**Code Review:**
- Detect security vulnerabilities
- Verify correctness of fixes
- High confidence in recommendations

**Fact-Checking:**
- Verify news articles
- Detect misinformation
- Cross-reference multiple sources

---

## PRODUCTION FEATURES

### Cost Tracking

**Automatic Tracking:**
```csharp
ai.EnableCostTracking(budgetLimit: 10.00m);

var response = await ai.GetResponse(messages);

var usage = ai.GetCostSummary();
Console.WriteLine($"Total: ${usage.TotalCost}");
Console.WriteLine($"Budget remaining: ${usage.RemainingBudget}");
Console.WriteLine($"Requests: {usage.RequestCount}");
```

**Cost Breakdown:**
- Per model (GPT-4 vs GPT-3.5)
- Per provider (OpenAI vs Anthropic)
- Per user (in multi-tenant apps)
- Per time period (daily, monthly)

**Budget Limits:**
- Hard limit (throw exception when exceeded)
- Soft limit (warning only)
- Per-user limits
- Per-organization limits

### Health Monitoring

**Health Checks:**
```csharp
var health = await ai.GetHealthStatusAsync();

if (health.Status == HealthStatus.Unhealthy)
{
    // Provider down, use failover
    // Or alert ops team
}
```

**Checks:**
- Provider availability (are APIs reachable?)
- API key validity (are keys still valid?)
- Circuit breaker status (is circuit open?)
- Response latency (are responses slow?)
- Error rates (are errors spiking?)

**Integration:**
- ASP.NET Core health checks middleware
- Kubernetes liveness/readiness probes
- Azure App Service health checks

### Observability

**Structured Logging (Serilog):**
```csharp
Log.Information("LLM request {@Request}", request);
Log.Information("LLM response {@Response} Cost: {Cost}", response, cost);
Log.Error(ex, "LLM request failed {@Request}", request);
```

**Distributed Tracing (OpenTelemetry):**
- Trace LLM calls across services
- Visualize call graphs
- Identify bottlenecks
- Correlate logs and metrics

**Metrics (Prometheus):**
- Request count
- Response latency (p50, p95, p99)
- Error rate
- Cost per request
- Tokens used

**Dashboards:**
- Grafana for metrics visualization
- Application Insights for Azure
- Custom dashboards

### Error Handling

**Automatic Retries (Polly):**
```csharp
var policy = Policy
    .Handle<HttpRequestException>()
    .WaitAndRetryAsync(3, retryAttempt =>
        TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));
```

**Circuit Breaker:**
- Prevents cascading failures
- Fails fast when provider down
- Auto-recovery

**Timeouts:**
- Per-request timeouts
- Prevent hanging forever
- Fallback to alternate provider

---

## NUGET PACKAGES

### Published Packages (DevGPT.* namespace)

**Current Status:**
- Published under `DevGPT.*` namespace
- Migration to `Hazina.*` namespace in progress
- ~30+ packages on NuGet.org

**Examples:**
- `DevGPT.LLMs.OpenAI`
- `DevGPT.LLMs.Anthropic`
- `DevGPT.Store.EmbeddingStore`
- `DevGPT.AgentFactory`
- `DevGPT.GenerationTools.*`

### Planned Packages (Hazina.* namespace)

**Core Packages:**
- `Hazina.AI.FluentAPI`
- `Hazina.AI.RAG`
- `Hazina.AI.Agents`
- `Hazina.Neurochain.Core`
- `Hazina.Production.Monitoring`

**Provider Packages:**
- `Hazina.LLMs.OpenAI`
- `Hazina.LLMs.Anthropic`
- `Hazina.LLMs.Gemini`
- `Hazina.LLMs.Mistral`
- `Hazina.LLMs.HuggingFace`

### Package Versioning

**Semantic Versioning:**
- MAJOR.MINOR.PATCH
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

**Current Version:** ~1.0.16 (DevGPT packages)

### Installation

**Via .NET CLI:**
```bash
dotnet add package Hazina.AI.FluentAPI
dotnet add package Hazina.AI.RAG
dotnet add package Hazina.LLMs.OpenAI
```

**Via Package Manager Console:**
```powershell
Install-Package Hazina.AI.FluentAPI
Install-Package Hazina.AI.RAG
Install-Package Hazina.LLMs.OpenAI
```

**Via .csproj:**
```xml
<PackageReference Include="Hazina.AI.FluentAPI" Version="1.0.*" />
<PackageReference Include="Hazina.AI.RAG" Version="1.0.*" />
<PackageReference Include="Hazina.LLMs.OpenAI" Version="1.0.*" />
```

---

## DEVELOPMENT WORKFLOW

### Local Setup

**Prerequisites:**
- .NET 9.0 SDK
- Visual Studio 2022 or Rider
- PostgreSQL (optional, for vector storage)
- Git

**Clone & Build:**
```bash
cd C:\Projects
git clone <hazina-repo-url> hazina
cd hazina

# Start with QuickStart solution
dotnet restore Hazina.QuickStart.sln
dotnet build Hazina.QuickStart.sln

# Or full build (takes ~5 minutes)
dotnet build Hazina.sln
```

**Configuration:**
```bash
# Set API keys
setx OPENAI_API_KEY "sk-..."
setx ANTHROPIC_API_KEY "sk-ant-..."

# Or use appsettings.json in your app
```

### Testing

**Run Unit Tests:**
```bash
dotnet test Hazina.sln
```

**Run Specific Test Project:**
```bash
dotnet test Tests/Hazina.AI.Tests/
```

**Code Coverage:**
```bash
dotnet test --collect:"XPlat Code Coverage"
```

### Building NuGet Packages

**Build All Packages:**
```bash
pwsh scripts/pack-all.ps1
# Outputs to nupkgs/
```

**Build Single Package:**
```bash
dotnet pack src/AI/Hazina.AI.FluentAPI/ -o nupkgs/
```

**Publish to NuGet:**
```bash
pwsh scripts/publish-all.ps1
# Requires NuGet API key
```

### Documentation

**Generate API Docs:**
```bash
dotnet tool install -g docfx
docfx docs/docfx.json
```

**Serve Docs Locally:**
```bash
docfx serve docs/_site
# Open http://localhost:8080
```

---

## USE CASES

### 1. Customer Support Chatbot

**Scenario:** Build a customer support chatbot that answers questions from your documentation.

**Implementation:**
```csharp
// Index documentation
var rag = new RAGEngine(ai, vectorStore);
await rag.IndexDocumentsAsync(documentationFiles);

// Answer customer questions
var response = await rag.QueryAsync(customerQuestion, new RAGQueryOptions
{
    TopK = 5,
    RequireCitation = true
});
```

**Benefits:**
- Accurate answers from your docs
- Automatic citation of sources
- Scales to millions of requests

### 2. Code Review Assistant

**Scenario:** Automatically review pull requests for bugs, security issues, and best practices.

**Implementation:**
```csharp
var neurochain = new NeuroChainOrchestrator();
neurochain.AddLayer(new FastReasoningLayer(ai));   // Quick scan
neurochain.AddLayer(new DeepReasoningLayer(ai));   // Thorough review
neurochain.AddLayer(new VerificationLayer(ai));    // Security audit

var review = await neurochain.ReasonAsync($"Review this code:\n{codeChanges}");
if (review.Confidence > 0.95)
{
    await PostReviewComment(review.Result);
}
```

**Benefits:**
- High-confidence recommendations
- Catches bugs before merge
- Enforces best practices

### 3. Research Assistant

**Scenario:** Multi-agent system that researches a topic, writes a report, and fact-checks it.

**Implementation:**
```csharp
var coordinator = new MultiAgentCoordinator();
coordinator.AddAgent(new Agent("researcher", researchPrompt, ai)
    .WithTool(new WebSearchTool()));
coordinator.AddAgent(new Agent("writer", writerPrompt, ai));
coordinator.AddAgent(new Agent("fact-checker", factCheckPrompt, ai)
    .WithTool(new FactVerificationTool()));

var report = await coordinator.ExecuteAsync("Research AI trends 2026",
    CoordinationStrategy.Sequential);
```

**Benefits:**
- Comprehensive research
- High-quality writing
- Fact-checked output

### 4. Multi-Lingual Translation

**Scenario:** Translate content with fallback to multiple providers.

**Implementation:**
```csharp
var ai = Hazina.AI()
    .WithPrimaryProvider(new OpenAIProvider(key1))
    .WithFallbackProvider(new AnthropicProvider(key2))
    .WithCircuitBreaker(failureThreshold: 3)
    .Build();

var translation = await ai.GetResponseAsync($"Translate to French: {text}");
// Automatically fails over if OpenAI down
```

**Benefits:**
- 99.9% uptime via failover
- No vendor lock-in
- Cost optimization (use cheaper provider)

### 5. Content Moderation

**Scenario:** Detect harmful content in user-generated posts.

**Implementation:**
```csharp
var result = await Hazina.AI()
    .WithFaultDetection(minConfidence: 0.95)
    .Ask($"Is this content safe? {userPost}")
    .ExecuteAsync();

if (result.Confidence > 0.95 && result.Result.Contains("unsafe"))
{
    await FlagContentForReview(userPost);
}
```

**Benefits:**
- High confidence required for flagging
- Reduces false positives
- Protects users

---

## RELATED DOCUMENTATION

- [PROJECTS_INDEX.md](./PROJECTS_INDEX.md) - Master project index
- [CLIENT_MANAGER_DEEP_DIVE.md](./CLIENT_MANAGER_DEEP_DIVE.md) - Client Manager uses Hazina
- [STORES_INDEX.md](./STORES_INDEX.md) - Data stores documentation
- [TECH_STACK_REFERENCE.md](./TECH_STACK_REFERENCE.md) - Technology stack details

**Hazina Internal Docs:**
- [README.md](../hazina/README.md) - Main README
- [SOLUTIONS.md](../hazina/SOLUTIONS.md) - Solution files guide
- [docs/quickstart.md](../hazina/docs/quickstart.md) - 30-minute RAG tutorial
- [docs/RAG_GUIDE.md](../hazina/docs/RAG_GUIDE.md) - RAG documentation
- [docs/AGENTS_GUIDE.md](../hazina/docs/AGENTS_GUIDE.md) - Agents documentation
- [docs/NEUROCHAIN_GUIDE.md](../hazina/docs/NEUROCHAIN_GUIDE.md) - Neurochain docs
- [docs/PRODUCTION_MONITORING_GUIDE.md](../hazina/docs/PRODUCTION_MONITORING_GUIDE.md) - Production monitoring

---

**Last Updated:** 2026-01-08
**Document Version:** 1.0
**Maintained by:** Claude Agent System
**Framework Version:** Hazina 1.0.16 (DevGPT legacy packages)
