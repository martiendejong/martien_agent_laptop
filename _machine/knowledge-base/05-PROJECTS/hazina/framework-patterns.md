# Hazina Framework - Architecture, Patterns, and Conventions

**Tags:** `#hazina` `#framework` `#library` `#architecture` `#patterns` `#nuget` `#ai-infrastructure`

**Last Updated:** 2026-01-25
**Expert:** #42 (Hazina Framework Specialist)
**Related:** [client-manager Integration](../client-manager/), [Cross-Repo Dependencies](../../02-WORKFLOWS/cross-repo-dependencies.md)

---

## Table of Contents

1. [Framework Purpose](#framework-purpose)
2. [Framework Architecture](#framework-architecture)
3. [Core Patterns](#core-patterns)
4. [Key Components](#key-components)
5. [Integration Patterns](#integration-patterns)
6. [Development Conventions](#development-conventions)
7. [NuGet Packaging](#nuget-packaging)
8. [Cross-Repo Coordination](#cross-repo-coordination)
9. [Common Usage Patterns](#common-usage-patterns)
10. [Migration & Evolution](#migration--evolution)

---

## Framework Purpose

### What is Hazina?

**Hazina** is a production-ready AI infrastructure framework for .NET that eliminates the complexity of building AI-powered applications.

**Core Value Proposition:**
- **97% complexity reduction** - 70+ lines of infrastructure code → 4 lines
- **15+ weeks of development → < 1 day** to production
- **Zero vendor lock-in** - Switch between OpenAI, Anthropic, Google, local models with zero code changes
- **Production-first** - Built-in failover, cost tracking, hallucination detection, monitoring

### Why Separate from client-manager?

**Hazina exists as a separate repository for:**

1. **Reusability Across Projects**
   - Shared AI infrastructure for multiple applications
   - Independent versioning and release cycles
   - NuGet packaging for distribution

2. **Clear Separation of Concerns**
   - Hazina = AI infrastructure library (no business logic)
   - client-manager = Business application (uses Hazina)
   - Clean architectural boundaries

3. **Independent Development**
   - Hazina can evolve without breaking client-manager
   - Breaking changes are managed via semantic versioning
   - Multiple teams can work independently

4. **Open Source Potential**
   - Hazina is designed as a public framework
   - client-manager remains private business logic
   - Community contributions target Hazina, not client code

**Relationship:** client-manager **consumes** Hazina as a NuGet package dependency.

---

## Framework Architecture

### Overall Structure

```
C:\Projects\hazina\
├── src\
│   ├── Core\                           # Core AI infrastructure
│   │   ├── AI\                         # Modern AI capabilities (Hazina v2.0+)
│   │   │   ├── Hazina.AI.FluentAPI     # ⭐ Main entry point (4-line setup)
│   │   │   ├── Hazina.AI.Providers     # Multi-provider abstraction
│   │   │   ├── Hazina.AI.FaultDetection# Hallucination detection
│   │   │   ├── Hazina.AI.Orchestration # Context management
│   │   │   ├── Hazina.AI.RAG           # Retrieval-Augmented Generation
│   │   │   ├── Hazina.AI.Agents        # Autonomous agents
│   │   │   ├── Hazina.AI.Vision        # Image analysis
│   │   │   ├── Hazina.AI.Memory        # Conversation memory
│   │   │   ├── Hazina.Neurochain.Core  # Multi-layer reasoning
│   │   │   └── ...
│   │   ├── LLMs\                       # Legacy LLM abstractions (v1.x)
│   │   │   ├── Hazina.LLMs.Classes     # Base LLM types
│   │   │   ├── Hazina.LLMs.Client      # Client interfaces
│   │   │   └── Hazina.LLMs.Tools       # Tool calling
│   │   ├── LLMs.Providers\             # Provider implementations
│   │   │   ├── Hazina.LLMs.OpenAI      # OpenAI integration
│   │   │   ├── Hazina.LLMs.Anthropic   # Claude integration
│   │   │   ├── Hazina.LLMs.Gemini      # Google Gemini
│   │   │   ├── Hazina.LLMs.GoogleADK   # Google AI Dev Kit
│   │   │   ├── Hazina.LLMs.Mistral     # Mistral AI
│   │   │   ├── Hazina.LLMs.Ollama      # Local LLMs
│   │   │   └── Hazina.LLMs.SemanticKernel
│   │   └── Agents\                     # Agent frameworks
│   │       ├── Hazina.AgentFactory     # Agent creation
│   │       ├── Hazina.DynamicAPI       # Runtime API generation
│   │       └── Hazina.Generator        # Code generation
│   ├── Tools\                          # Supporting services
│   │   ├── Foundation\                 # Core utilities
│   │   │   ├── Hazina.Tools.Core       # Base types
│   │   │   ├── Hazina.Tools.Data       # Data access
│   │   │   ├── Hazina.Tools.Models     # Domain models
│   │   │   └── Hazina.Tools.Extensions # Extension methods
│   │   ├── Services\                   # Service implementations
│   │   │   ├── Hazina.Tools.Services.Chat      # Chat services
│   │   │   ├── Hazina.Tools.Services.Embeddings# Vector embeddings
│   │   │   ├── Hazina.Tools.Services.Images    # Image processing
│   │   │   ├── Hazina.Tools.Services.GoogleDrive
│   │   │   ├── Hazina.Tools.Services.Social    # Social media
│   │   │   ├── Hazina.Tools.Services.WordPress
│   │   │   └── ...
│   │   └── Production\
│   │       └── Hazina.Production.Monitoring    # Metrics & health
├── apps\                               # Demo applications
│   ├── Demos\
│   ├── CLI\
│   ├── Desktop\
│   └── Web\
├── Tests\                              # Unit & integration tests
├── docs\                               # Documentation
└── Directory.Build.props               # Shared build config

```

### Public API Surface

**Primary Entry Point:** `Hazina.AI.FluentAPI`

```csharp
// This is THE recommended way to use Hazina
using Hazina.AI.FluentAPI;

QuickSetup.SetupAndConfigure("sk-...", "sk-ant-...");
var result = await Hazina.AskSafeAsync("Question");
```

**Internal vs Public Components:**

| Package | Visibility | Purpose |
|---------|-----------|---------|
| `Hazina.AI.FluentAPI` | ⭐ **Public API** | Main entry point, fluent builder |
| `Hazina.AI.Providers` | **Public** | Provider abstraction |
| `Hazina.AI.RAG` | **Public** | RAG engine |
| `Hazina.AI.Agents` | **Public** | Agent framework |
| `Hazina.LLMs.OpenAI` | **Public** | OpenAI provider |
| `Hazina.LLMs.Anthropic` | **Public** | Claude provider |
| `Hazina.Tools.Services.*` | **Public** | Service utilities |
| `Hazina.Tools.Core` | Internal (used by services) | Base types |
| `Hazina.Tools.Data` | Internal | Data access |

**Design Philosophy:**
- **Minimal public API** - Only expose what's necessary
- **Internal by default** - Keep implementation details hidden
- **Stable contracts** - Public APIs follow semantic versioning strictly
- **Breaking changes** documented in MIGRATION_GUIDE.md

---

## Core Patterns

### 1. Fluent Builder Pattern

**Pattern:** Chainable method calls for configuration

```csharp
var result = await Hazina.AI()
    .WithProvider("openai")              // Provider selection
    .WithFaultDetection(confidence: 0.9) // Feature flags
    .WithSystemMessage("You are helpful")// Context
    .Ask("Question")                     // Query
    .ExpectJson()                        // Validation
    .ExecuteAsync();                     // Execution
```

**Benefits:**
- **Self-documenting** - Intent clear from chain
- **Type-safe** - IntelliSense guides usage
- **Flexible** - Mix and match features as needed
- **Testable** - Easy to mock individual steps

**Implementation Pattern:**
```csharp
public class HazinaBuilder
{
    public HazinaBuilder WithProvider(string provider)
    {
        // Configure
        return this; // Enable chaining
    }

    public async Task<Result> ExecuteAsync()
    {
        // Terminal operation
    }
}
```

### 2. Provider Abstraction Pattern

**Pattern:** Unified interface for multiple AI providers

```csharp
// Same code works with ANY provider
IProviderOrchestrator orchestrator = QuickSetup.SetupWithFailover(
    openAIKey: "sk-...",      // Primary
    anthropicKey: "sk-ant-..." // Fallback
);

// Automatic failover if OpenAI fails
var response = await orchestrator.GetResponseAsync(messages);
```

**Architecture:**
```
┌──────────────────────────────────────┐
│     Application Code                 │
└──────────────────────────────────────┘
               ▼
┌──────────────────────────────────────┐
│  IProviderOrchestrator               │ ← Single interface
│  - GetResponseAsync()                │
│  - CreateBuilder()                   │
└──────────────────────────────────────┘
               ▼
┌──────────────────────────────────────┐
│  ProviderRegistry                    │
│  - Manages multiple providers        │
│  - Automatic failover                │
│  - Cost tracking                     │
│  - Health monitoring                 │
└──────────────────────────────────────┘
        │         │         │
        ▼         ▼         ▼
   ┌────────┐ ┌────────┐ ┌────────┐
   │ OpenAI │ │Anthropic│ │ Gemini │
   └────────┘ └────────┘ └────────┘
```

**Benefits:**
- **Zero vendor lock-in** - Switch providers without code changes
- **Automatic failover** - Resilience built-in
- **Cost optimization** - Route to cheapest/fastest provider
- **Future-proof** - New providers added without breaking changes

### 3. Configuration Object Pattern

**Pattern:** Use object initializers (not constructors) for config

**❌ Old Pattern (v1.x - breaking changes on every update):**
```csharp
var config = new OpenAIConfig("sk-...", "gpt-4o-mini");
```

**✅ New Pattern (v2.0+ - backward compatible):**
```csharp
var config = new OpenAIConfig
{
    ApiKey = "sk-...",
    Model = "gpt-4o-mini",
    MaxTokens = 4000 // Optional - has defaults
};
```

**Why This Matters:**
- **Backward compatibility** - Adding new properties doesn't break existing code
- **Optional parameters** - Defaults for everything
- **Self-documenting** - Property names are clear
- **Extensible** - New features added without breaking changes

**Base Class Pattern:**
```csharp
public abstract class HazinaConfigBase
{
    public string ApiKey { get; set; }
    public string Model { get; set; }
    public int MaxTokens { get; set; } = 4000;
    // Common properties inherited by all providers
}

public class OpenAIConfig : HazinaConfigBase
{
    public string Organization { get; set; } // OpenAI-specific
}

public class AnthropicConfig : HazinaConfigBase
{
    public string Version { get; set; } = "2023-06-01"; // Anthropic-specific
}
```

### 4. Extension Method Pattern

**Pattern:** Add functionality without modifying core types

```csharp
// Extension methods for IServiceCollection
public static class HazinaServiceCollectionExtensions
{
    public static IServiceCollection AddHazinaAI(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Register all Hazina services
        services.AddSingleton<IProviderOrchestrator>(...);
        services.AddScoped<IRAGEngine>(...);
        return services;
    }
}

// Usage in client-manager
services.AddHazinaAI(configuration);
```

**Benefits:**
- **Clean integration** - Feels native to ASP.NET Core
- **Discoverability** - IntelliSense shows extensions
- **Testability** - Easy to mock dependencies
- **Framework patterns** - Follows .NET conventions

### 5. Dependency Injection Pattern

**Pattern:** Services registered via DI container

```csharp
// In client-manager Startup.cs / Program.cs
services.AddHazinaAI(configuration);

// Constructor injection
public class MyController : ControllerBase
{
    private readonly IProviderOrchestrator _orchestrator;
    private readonly IRAGEngine _ragEngine;

    public MyController(
        IProviderOrchestrator orchestrator,
        IRAGEngine ragEngine)
    {
        _orchestrator = orchestrator;
        _ragEngine = ragEngine;
    }
}
```

**Lifetime Management:**
- **Singleton:** `IProviderOrchestrator` (thread-safe, expensive to create)
- **Scoped:** `IRAGEngine`, `ChatService` (per-request state)
- **Transient:** Builders, validators (cheap, stateless)

---

## Key Components

### 1. LLM Integration Patterns

**Multi-Provider Support:**

```csharp
// OpenAI
var openAIConfig = new OpenAIConfig
{
    ApiKey = "sk-...",
    Model = "gpt-4o-mini"
};
var openAI = new OpenAIClientWrapper(openAIConfig);

// Anthropic
var anthropicConfig = new AnthropicConfig
{
    ApiKey = "sk-ant-...",
    Model = "claude-3-5-sonnet-20241022"
};
var claude = new ClaudeClientWrapper(anthropicConfig);

// Google Gemini
var geminiConfig = new GeminiConfig
{
    ApiKey = "...",
    Model = "gemini-pro"
};
var gemini = new GeminiClientWrapper(geminiConfig);
```

**Common Interface:**
```csharp
public interface ILLMClient
{
    Task<LLMResponse> GetResponseAsync(
        List<HazinaChatMessage> messages,
        CancellationToken cancellationToken = default);

    Task<Stream> GetResponseStreamAsync(
        List<HazinaChatMessage> messages,
        CancellationToken cancellationToken = default);
}
```

**Logging Decorator Pattern:**
```csharp
// Wrap any LLM client with logging
ILLMClient llmClient = new OpenAIClientWrapper(config);

if (_llmLogRepository != null)
{
    llmClient = new LLMLoggingClientDecorator(
        llmClient,
        _llmLogRepository,
        _llmLoggingOptions,
        "OpenAI"
    );
}

// Now all calls are automatically logged
var response = await llmClient.GetResponseAsync(messages);
```

### 2. Image Processing (AI Image Generation, Vision)

**Hazina.Tools.Services.Images** - Provider-agnostic image operations

**Architecture:**
```
┌─────────────────────────────────────────┐
│  ImageTool (IImageTool)                 │
└─────────────────────────────────────────┘
              ▼
┌─────────────────────────────────────────┐
│  ImageProviderResolver                  │
│  - Routes operations to providers       │
└─────────────────────────────────────────┘
       │              │
       ▼              ▼
┌────────────┐  ┌────────────┐
│   Local    │  │     AI     │
│ (ImageSharp│  │ (OpenAI/   │
│  Crop,     │  │  Stable    │
│  Resize,   │  │  Diffusion)│
│  Text)     │  │            │
└────────────┘  └────────────┘
```

**Usage Example:**
```csharp
var result = await _imageTool.EditAsync(new ImageEditRequest
{
    InputImage = inputStream,
    Operations = new[]
    {
        new CropOperation(X: 0, Y: 0, Width: 800, Height: 600),
        new ResizeOperation(Width: 400, Height: 300),
        new AddTextOperation(
            Text: "Brand2Boost",
            X: 10, Y: 10,
            FontSize: 24,
            ColorHex: "#FF0000"
        ),
        new ApplyFilterOperation(ImageFilter.Grayscale)
    },
    OutputFormat = ImageOutputFormat.Png
});
```

**Why Provider-Agnostic?**
- Local operations (crop, resize) use ImageSharp (no API calls)
- AI operations (inpainting) can use OpenAI DALL-E, Stability AI, etc.
- Swap providers via configuration, not code changes

### 3. Social Media Abstractions

**Pattern:** Unified interface for multiple social platforms

```csharp
// Common interface
public interface ISocialMediaProvider
{
    Task<PostResult> CreatePostAsync(SocialMediaPost post);
    Task<Stream> GenerateImageAsync(ImageGenerationRequest request);
}

// Implementations
- FacebookProvider
- InstagramProvider
- LinkedInProvider
- TwitterProvider
```

**Used in client-manager for:**
- Automated social media posting
- Content generation
- Image creation for campaigns

### 4. Background Job Patterns

**Hazina uses Hangfire-compatible patterns:**

```csharp
public interface IBackgroundJobService
{
    Task EnqueueAsync<T>(Expression<Action<T>> methodCall);
    Task ScheduleAsync<T>(Expression<Action<T>> methodCall, TimeSpan delay);
}

// Usage in client-manager
await _backgroundJobService.EnqueueAsync<IEmbeddingsWorkQueue>(
    q => q.ProcessPendingAsync()
);
```

### 5. Caching Mechanisms

**Multi-Level Caching:**

```csharp
public class ProjectContextCache
{
    private readonly IMemoryCache _memoryCache;
    private readonly IDistributedCache _distributedCache;

    public async Task<T> GetOrCreateAsync<T>(
        string key,
        Func<Task<T>> factory,
        TimeSpan? expiration = null)
    {
        // L1: Memory cache (fast, local)
        if (_memoryCache.TryGetValue(key, out T cached))
            return cached;

        // L2: Distributed cache (shared across instances)
        var serialized = await _distributedCache.GetStringAsync(key);
        if (serialized != null)
        {
            var value = JsonSerializer.Deserialize<T>(serialized);
            _memoryCache.Set(key, value, expiration ?? TimeSpan.FromMinutes(10));
            return value;
        }

        // L3: Source of truth (database, API)
        var result = await factory();
        _memoryCache.Set(key, result, expiration ?? TimeSpan.FromMinutes(10));
        await _distributedCache.SetStringAsync(
            key,
            JsonSerializer.Serialize(result),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = expiration ?? TimeSpan.FromHours(1)
            });
        return result;
    }
}
```

---

## Integration Patterns

### How client-manager Consumes Hazina

**1. NuGet Package Reference:**

```xml
<!-- client-manager.csproj -->
<ItemGroup>
  <PackageReference Include="Hazina.AI.FluentAPI" Version="2.0.0" />
  <PackageReference Include="Hazina.AI.RAG" Version="2.0.0" />
  <PackageReference Include="Hazina.LLMs.OpenAI" Version="2.0.0" />
  <PackageReference Include="Hazina.Tools.Services.Chat" Version="2.0.0" />
  <PackageReference Include="Hazina.Tools.Services.Embeddings" Version="2.0.0" />
</ItemGroup>
```

**2. Dependency Injection Setup:**

```csharp
// ClientManagerAPI/Extensions/HazinaServiceCollectionExtensions.cs
public static class HazinaServiceCollectionExtensions
{
    public static IServiceCollection AddHazinaServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // 1. Provider orchestrator (singleton)
        services.AddSingleton<IProviderOrchestrator>(sp =>
        {
            var openAiKey = configuration["Hazina:OpenAI:ApiKey"];
            var anthropicKey = configuration["Hazina:Anthropic:ApiKey"];
            return QuickSetup.SetupWithFailover(openAiKey, anthropicKey);
        });

        // 2. RAG engine (scoped per request)
        services.AddScoped<IRAGEngine>(sp =>
        {
            var orchestrator = sp.GetRequiredService<IProviderOrchestrator>();
            var embeddingStore = sp.GetRequiredService<IEmbeddingStore>();
            return new RAGEngine(embeddingStore, orchestrator, new RAGOptions
            {
                ChunkSize = 512,
                TopK = 5,
                MinSimilarity = 0.7
            });
        });

        // 3. Chat service
        services.AddScoped<ChatService>();

        return services;
    }
}
```

**3. Configuration Binding:**

```json
// appsettings.json
{
  "Hazina": {
    "OpenAI": {
      "ApiKey": "sk-...",
      "Model": "gpt-4o-mini"
    },
    "Anthropic": {
      "ApiKey": "sk-ant-...",
      "Model": "claude-3-5-sonnet-20241022"
    },
    "RAG": {
      "ChunkSize": 512,
      "ChunkOverlap": 50,
      "TopK": 5,
      "MinSimilarity": 0.7
    }
  }
}
```

**4. Usage in Controllers:**

```csharp
// ClientManagerAPI/Controllers/AnalysisController.cs
public class AnalysisController : ControllerBase
{
    private readonly IProviderOrchestrator _orchestrator;
    private readonly ChatService _chatService;

    public AnalysisController(
        IProviderOrchestrator orchestrator,
        ChatService chatService)
    {
        _orchestrator = orchestrator;
        _chatService = chatService;
    }

    [HttpPost("analyze")]
    public async Task<IActionResult> Analyze([FromBody] AnalysisRequest request)
    {
        var result = await Hazina.AI()
            .WithOrchestrator(_orchestrator)
            .WithFaultDetection(confidence: 0.9)
            .Ask(request.Query)
            .ExecuteAsync();

        return Ok(result);
    }
}
```

### Extension Method Patterns

**Pattern:** Add Hazina-specific functionality to ASP.NET Core

```csharp
public static class ToolsContextSocialExtensions
{
    public static async Task<SocialMediaPost> CreatePostAsync(
        this ToolsContext context,
        string projectId,
        SocialMediaPostRequest request)
    {
        // Extension method adds domain-specific functionality
        // Uses Hazina services under the hood
    }
}
```

---

## Development Conventions

### 1. Coding Standards

**Enforced via `.editorconfig` and analyzers:**

```ini
# Directory.Build.props
<EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
<EnableNETAnalyzers>true</EnableNETAnalyzers>

# Analyzers
- SonarAnalyzer.CSharp
- StyleCop.Analyzers
- Meziantou.Analyzer
```

**Key Rules:**
- **Cyclomatic Complexity ≤10** (HARD LIMIT)
- **100% XML documentation** for public APIs
- **Boy Scout Rule** - Always leave code better than found
- **No magic numbers** - Extract to named constants
- **Async all the way** - No `.Result` or `.Wait()`

**See:** `HAZINA_CODING_STANDARDS.md` (79 KB complete guide)

### 2. Naming Conventions

**Namespaces:**
```
Hazina.{Area}.{Feature}

Examples:
- Hazina.AI.FluentAPI
- Hazina.AI.Providers
- Hazina.Tools.Services.Chat
- Hazina.LLMs.OpenAI
```

**Interfaces:**
```csharp
IProviderOrchestrator
ILLMClient
IRAGEngine
IChatService
```

**Implementations:**
```csharp
ProviderOrchestrator  (implements IProviderOrchestrator)
OpenAIClientWrapper   (implements ILLMClient)
RAGEngine             (implements IRAGEngine)
ChatService           (implements IChatService)
```

**Configuration Classes:**
```csharp
{Provider}Config : HazinaConfigBase

OpenAIConfig
AnthropicConfig
GeminiConfig
```

### 3. Documentation Requirements

**Public APIs require XML docs:**

```csharp
/// <summary>
/// Executes the AI request with all configured options.
/// </summary>
/// <returns>The AI response with metadata.</returns>
/// <exception cref="InvalidOperationException">
/// Thrown when no orchestrator is configured.
/// </exception>
/// <remarks>
/// Example usage:
/// <code>
/// var result = await Hazina.AI()
///     .WithProvider("openai")
///     .Ask("Hello")
///     .ExecuteAsync();
/// </code>
/// </remarks>
public async Task<HazinaResult> ExecuteAsync()
```

**README.md in every project:**
- Purpose and features
- Installation instructions
- Usage examples
- API reference
- Dependencies

### 4. Testing Patterns

**Unit Tests:**
```
Tests\Core\Hazina.AI.FluentAPI.Tests\
Tests\Core\Hazina.AI.Providers.Tests\
Tests\Core\Hazina.LLMs.OpenAI.Tests\
```

**Naming:** `{Class}_{Method}_{Scenario}_{ExpectedBehavior}`

```csharp
[Fact]
public async Task HazinaBuilder_WithProvider_ValidName_ReturnsBuilder()
{
    // Arrange
    var builder = Hazina.AI();

    // Act
    var result = builder.WithProvider("openai");

    // Assert
    Assert.NotNull(result);
    Assert.IsType<HazinaBuilder>(result);
}
```

**Coverage Targets:**
- Critical code (LLM calls, failover): 100%
- New code: 70% minimum
- Overall: 60%+

---

## NuGet Packaging

### Package Structure

**Example: Hazina.AI.FluentAPI**

```
Hazina.AI.FluentAPI.2.0.0.nupkg
├── lib/
│   └── net9.0/
│       ├── Hazina.AI.FluentAPI.dll
│       └── Hazina.AI.FluentAPI.xml  (XML docs)
├── README.md
├── icon.png
└── .nuspec metadata
```

### Versioning Strategy

**Semantic Versioning: MAJOR.MINOR.PATCH**

- **MAJOR:** Breaking changes (v1.0 → v2.0)
- **MINOR:** New features, backward compatible (v2.0 → v2.1)
- **PATCH:** Bug fixes (v2.1.0 → v2.1.1)

**Example Evolution:**
- v1.0.0 - Initial release (constructor-based config)
- v2.0.0 - **BREAKING:** Object initializer pattern
- v2.1.0 - Added streaming support (non-breaking)
- v2.1.1 - Fixed failover bug

**Breaking Change Documentation:**
```markdown
# MIGRATION_GUIDE.md

## v1.x → v2.0

### Config Classes - Object Initializers

**Before (v1.x):**
```csharp
var config = new OpenAIConfig("sk-...", "gpt-4o-mini");
```

**After (v2.0):**
```csharp
var config = new OpenAIConfig
{
    ApiKey = "sk-...",
    Model = "gpt-4o-mini"
};
```
```

### Publishing Process

**Manual Process (Current):**

```powershell
# 1. Build packages
cd C:\Projects\hazina
.\pack-all.ps1

# 2. Publish to NuGet.org
.\publish-all.ps1

# 3. Update client-manager
cd C:\Projects\client-manager
dotnet add package Hazina.AI.FluentAPI --version 2.0.0
```

**CI/CD (Future):**
- GitHub Actions on tag push
- Automated versioning
- NuGet.org publish
- GitHub Releases

### Version Dependencies

**Hazina Internal:**
```xml
<!-- Hazina.AI.FluentAPI.csproj -->
<ItemGroup>
  <ProjectReference Include="..\Hazina.AI.Providers\Hazina.AI.Providers.csproj" />
  <ProjectReference Include="..\Hazina.AI.FaultDetection\Hazina.AI.FaultDetection.csproj" />
</ItemGroup>
```

**client-manager → Hazina:**
```xml
<!-- ClientManagerAPI.csproj -->
<ItemGroup>
  <PackageReference Include="Hazina.AI.FluentAPI" Version="2.0.0" />
  <PackageReference Include="Hazina.Tools.Services.Chat" Version="2.0.0" />
</ItemGroup>
```

**Rule:** All Hazina packages in client-manager must use same MAJOR.MINOR version to avoid conflicts.

---

## Cross-Repo Coordination

### Why Hazina PR Must Merge First

**Dependency Chain:**
```
Hazina PR → Merge → NuGet Publish → client-manager Update → client-manager PR
```

**Example Scenario:**

1. **Feature:** Add new `WithStreaming()` method to FluentAPI
2. **Hazina PR:** Implement feature, tests, docs
3. **Merge Hazina PR** → Trigger NuGet publish (v2.1.0)
4. **client-manager PR:** Update package, use new feature
5. **Merge client-manager PR**

**If Order Reversed (WRONG):**
```
client-manager PR references Hazina.AI.FluentAPI v2.1.0
→ Package doesn't exist yet (Hazina PR not merged)
→ Build fails
→ PR blocked
```

**See:** `C:\scripts\git-workflow.md` § Cross-Repo Dependencies

### Testing Strategy Across Repos

**Phase 1: Hazina Development**
```bash
cd C:\Projects\hazina
dotnet test
```

**Phase 2: Integration Testing**
```bash
# Option A: Local package
cd C:\Projects\hazina
.\pack-all.ps1
cd C:\Projects\client-manager
dotnet add package Hazina.AI.FluentAPI --source C:\Projects\hazina\nupkgs

# Option B: NuGet.org pre-release
dotnet add package Hazina.AI.FluentAPI --version 2.1.0-beta
```

**Phase 3: Production**
```bash
# After Hazina v2.1.0 published to NuGet.org
dotnet add package Hazina.AI.FluentAPI --version 2.1.0
```

### Breaking Change Management

**Process:**
1. **Document in Hazina PR:** Add to MIGRATION_GUIDE.md
2. **Version bump:** Increment MAJOR version
3. **Coordinate with client-manager:** Plan update timeline
4. **Deprecation period:** Mark old APIs as `[Obsolete]` first
5. **Migration:** Update client-manager in separate PR
6. **Verification:** Full integration tests

**Example:**
```csharp
// Hazina v2.0 - Deprecated
[Obsolete("Use object initializer pattern. Will be removed in v3.0")]
public OpenAIConfig(string apiKey, string model) { }

// Hazina v3.0 - Removed
// Constructor no longer exists
```

---

## Common Usage Patterns

### Pattern 1: Simple Question Answering

```csharp
// Setup (once at startup)
QuickSetup.SetupAndConfigure("sk-...");

// Use anywhere
var answer = await Hazina.AskAsync("What is the capital of France?");
// "The capital of France is Paris."
```

### Pattern 2: RAG (Document Question Answering)

```csharp
// Setup
var orchestrator = QuickSetup.SetupOpenAI("sk-...");
var ragEngine = new RAGEngine(documentStore, embeddingStore, orchestrator);

// Index documents
await ragEngine.IndexDocumentAsync(new Document
{
    Content = "Hazina is a .NET AI framework...",
    Metadata = new DocumentMetadata
    {
        Title = "Hazina Documentation",
        Tags = new[] { "ai", "framework" }
    }
});

// Query
var response = await ragEngine.QueryAsync("What is Hazina?");
Console.WriteLine(response.Answer);
Console.WriteLine($"Sources: {string.Join(", ", response.Citations)}");
```

### Pattern 3: Multi-Provider Failover

```csharp
var orchestrator = QuickSetup.SetupWithFailover(
    openAIKey: "sk-...",
    anthropicKey: "sk-ant-..."
);

// If OpenAI fails → automatically tries Claude
var result = await orchestrator.CreateBuilder()
    .Ask("Explain quantum computing")
    .ExecuteAsync();
```

### Pattern 4: Cost-Optimized Setup

```csharp
var orchestrator = QuickSetup.SetupCostOptimized("sk-...", "sk-ant-...");
orchestrator.SetDefaultStrategy(SelectionStrategy.LeastCost);

// Automatically routes to cheapest provider
var result = await Hazina.AskAsync("Summarize this text");
```

### Pattern 5: Hallucination Detection

```csharp
var result = await Hazina.AI()
    .WithFaultDetection(confidence: 0.9)
    .WithGroundTruth("capital_france", "Paris")
    .Ask("What is the capital of France?")
    .ExecuteAsync();

// Automatically retries if:
// - Confidence < 0.9
// - Response contradicts ground truth
// - Hallucination detected
```

### Pattern 6: JSON Response Validation

```csharp
var json = await Hazina.AI()
    .WithFaultDetection()
    .Ask("Get user data as JSON")
    .ExpectJson()
    .ExecuteAsync();

// Validates JSON format, retries if invalid
```

### Pattern 7: Conversation Context

```csharp
var orchestrator = QuickSetup.SetupOpenAI("sk-...");
var context = new ContextManager(orchestrator).CreateContext();

// Message 1
await Hazina.AI()
    .WithOrchestrator(orchestrator)
    .WithContext(context)
    .Ask("My name is Alice")
    .ExecuteAsync();

// Message 2 - remembers context
var result = await Hazina.AI()
    .WithOrchestrator(orchestrator)
    .WithContext(context)
    .Ask("What is my name?")
    .ExecuteAsync();
// "Your name is Alice."
```

### Pattern 8: Streaming Response

```csharp
var fullResponse = await Hazina.AI()
    .Ask("Write a long story")
    .ExecuteStreamAsync(chunk =>
    {
        Console.Write(chunk); // Print as it arrives
    });
```

### Pattern 9: User-Scoped RAG (client-manager pattern)

```csharp
public class UserDocumentService
{
    private readonly IRAGEngine _ragEngine;
    private readonly string _userId;

    public async Task<RAGResponse> QueryUserDocumentsAsync(string query)
    {
        // Only retrieve user's documents
        return await _ragEngine.QueryAsync(query, filter: new MetadataFilter
        {
            MustMatch = new Dictionary<string, string>
            {
                ["userId"] = _userId
            }
        });
    }
}
```

### Pattern 10: LLM Logging (Observability)

```csharp
// Wrap any LLM client with logging
ILLMClient llmClient = new OpenAIClientWrapper(config);

if (_llmLogRepository != null)
{
    llmClient = new LLMLoggingClientDecorator(
        llmClient,
        _llmLogRepository,
        _llmLoggingOptions,
        "OpenAI"
    );
}

// All calls automatically logged to database
var response = await llmClient.GetResponseAsync(messages);
```

---

## Migration & Evolution

### v1.x → v2.0 Migration

**Major Changes:**

1. **Config Classes:** Constructor → Object initializer
2. **Namespaces:** Added `Hazina.AI.*` for new features
3. **Fluent API:** New recommended entry point

**Migration Path:**

```csharp
// v1.x (still works, but deprecated)
var config = new OpenAIConfig("sk-...", "gpt-4o-mini");
var client = new OpenAIClientWrapper(config);

// v2.0 (recommended)
QuickSetup.SetupAndConfigure("sk-...");
var result = await Hazina.AskAsync("Question");
```

**Timeline:**
- v2.0: Both patterns work (old marked `[Obsolete]`)
- v2.1-2.9: Deprecation warnings
- v3.0: Old patterns removed

### Future Roadmap

**Planned Features:**
- **v2.1:** Streaming improvements, cost budgets
- **v2.2:** GraphRAG (knowledge graphs)
- **v2.3:** Local LLM optimization (Ollama, LLaMA)
- **v3.0:** Breaking changes cleanup

**See:** `TECHNICAL_ROADMAP.md` in Hazina repository

---

## Best Practices

### DO ✅

1. **Use FluentAPI as entry point**
   ```csharp
   QuickSetup.SetupAndConfigure("sk-...");
   await Hazina.AskAsync("Question");
   ```

2. **Enable fault detection in production**
   ```csharp
   .WithFaultDetection(confidence: 0.9)
   ```

3. **Reuse orchestrators** (thread-safe, expensive to create)
   ```csharp
   services.AddSingleton<IProviderOrchestrator>(...)
   ```

4. **Use contexts for multi-turn conversations**
   ```csharp
   .WithContext(conversationContext)
   ```

5. **Set budget limits**
   ```csharp
   orchestrator.CostTracker.SetBudgetLimit(50m, BudgetPeriod.Daily);
   ```

### DON'T ❌

1. **Don't create orchestrators per request** (expensive)
   ```csharp
   ❌ new ProviderOrchestrator(...) // Per-request
   ✅ services.AddSingleton<IProviderOrchestrator>(...) // Startup
   ```

2. **Don't ignore async/await**
   ```csharp
   ❌ result.Result // Deadlock risk
   ✅ await result
   ```

3. **Don't hardcode provider names in business logic**
   ```csharp
   ❌ if (provider == "openai") { ... }
   ✅ Use abstraction via IProviderOrchestrator
   ```

4. **Don't skip XML documentation**
   ```csharp
   ❌ public void Method() { } // CS1591 error
   ✅ /// <summary>...</summary>
   ```

5. **Don't mix v1.x and v2.0 patterns**
   ```csharp
   ❌ var config = new OpenAIConfig("key", "model"); // v1.x
   ✅ var config = new OpenAIConfig { ApiKey = "key" }; // v2.0
   ```

---

## Anti-Patterns to Avoid

### 1. Sync-over-Async

```csharp
❌ BAD:
var result = Hazina.AskAsync("Question").Result; // Deadlock risk

✅ GOOD:
var result = await Hazina.AskAsync("Question");
```

### 2. Leaking Infrastructure Details

```csharp
❌ BAD: Business logic depends on specific provider
if (provider is OpenAIClientWrapper openAI)
{
    // OpenAI-specific logic
}

✅ GOOD: Use abstraction
var result = await _orchestrator.GetResponseAsync(messages);
```

### 3. Per-Request Orchestrator Creation

```csharp
❌ BAD: Create new orchestrator per request
public IActionResult MyAction()
{
    var orchestrator = QuickSetup.SetupOpenAI("sk-..."); // SLOW
    return Ok(orchestrator.AskAsync("Question"));
}

✅ GOOD: Inject singleton
private readonly IProviderOrchestrator _orchestrator;
public MyController(IProviderOrchestrator orchestrator)
{
    _orchestrator = orchestrator;
}
```

---

## Summary

**Hazina Framework provides:**

1. **97% complexity reduction** - Production AI in 4 lines of code
2. **Zero vendor lock-in** - Switch providers without code changes
3. **Production-ready** - Built-in failover, cost tracking, monitoring
4. **Clean architecture** - Separation between framework and business logic
5. **Semantic versioning** - Clear breaking change management
6. **Comprehensive docs** - XML docs, READMEs, migration guides

**client-manager Integration:**
- Consumes Hazina via NuGet packages
- Dependency injection for clean separation
- Configuration-driven provider selection
- User-scoped RAG for multi-tenancy

**Key Takeaway:** Hazina eliminates AI infrastructure complexity, letting client-manager focus on business logic.

---

**Last Updated:** 2026-01-25
**Maintained By:** Claude Agent (Self-improving documentation)
**See Also:**
- [client-manager Architecture](../client-manager/architecture.md)
- [Cross-Repo Dependencies](../../02-WORKFLOWS/cross-repo-dependencies.md)
- [Hazina README.md](C:\Projects\hazina\README.md)
- [Hazina Technical Guide](C:\Projects\hazina\TECHNICAL_GUIDE.md)
