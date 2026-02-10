<#
.SYNOPSIS
    Publishes 20 Hazina educational blog posts to martiendejong.nl
.DESCRIPTION
    Creates and schedules 20 posts via WordPress REST API, 2 per day starting 2026-02-10
.PARAMETER DryRun
    If set, shows what would be posted without actually posting
#>
param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# WordPress API config
$baseUrl = "https://martiendejong.nl/wp-json/wp/v2"
$username = "admin"
$appPassword = "UtCI Mgr9 13EB mlBL 2S1L AY2e"
$authHeader = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${appPassword}"))

$headers = @{
    "Authorization" = "Basic $authHeader"
    "Content-Type"  = "application/json; charset=utf-8"
}

# Schedule: 2 posts per day, 09:00 and 14:00 CET (UTC+1 = 08:00 and 13:00 UTC)
$startDate = [DateTime]::Parse("2026-02-10")
$posts = @()

# ============================================================
# POST 1: Introduction to Hazina
# ============================================================
$posts += @{
    title = "Introduction to Hazina: The .NET AI Framework That Does the Heavy Lifting"
    slug = "introduction-to-hazina-framework"
    content = @"
<p>Building AI-powered applications in .NET shouldn't require weeks of setup, glue code, and configuration nightmares. That's exactly why <strong>Hazina</strong> exists — a comprehensive .NET framework that takes care of the infrastructure so you can focus on building features.</p>

<h2>What is Hazina?</h2>

<p>Hazina is an open-source .NET framework designed for developers who want to integrate AI capabilities into their applications without reinventing the wheel. Whether you need a simple chatbot, a document search engine with RAG (Retrieval-Augmented Generation), or a fully autonomous agent system — Hazina provides the building blocks.</p>

<h2>Core Philosophy</h2>

<p>The framework follows three guiding principles:</p>

<ol>
<li><strong>Convention over configuration</strong> — sensible defaults that work out of the box</li>
<li><strong>Modular architecture</strong> — use only what you need</li>
<li><strong>Production-ready</strong> — built-in multi-tenancy, observability, and security</li>
</ol>

<h2>What You'll Learn in This Series</h2>

<p>Over the next 19 posts, we'll walk through every major feature of Hazina:</p>

<ul>
<li>Getting started in 5 minutes</li>
<li>Making your first AI call</li>
<li>Building zero-boilerplate APIs</li>
<li>Implementing document search with RAG</li>
<li>Creating dynamic plugins at runtime</li>
<li>Multi-tenant applications</li>
<li>Agent orchestration</li>
<li>And much more</li>
</ul>

<h2>Who Is This For?</h2>

<p>If you're a .NET developer (C#) who wants to add AI to your applications — or if you're building a SaaS product and need a solid foundation — this series is for you. We assume basic knowledge of .NET 9 and C#, but each post is self-contained and includes working code examples.</p>

<h2>Architecture at a Glance</h2>

<p>Hazina is organized into layers:</p>

<pre><code>Hazina/
├── Core/           # AI engine, configuration, base abstractions
│   ├── AI/         # FluentAPI, orchestration, providers
│   ├── API/        # Generic CRUD framework
│   └── Plugins/    # Dynamic runtime plugin system
├── Tools/          # Services, social providers, document store
├── Production/     # Monitoring, health checks, observability
└── Apps/           # Demo applications and showcases
</code></pre>

<p>Each layer builds on the previous one, but you can pick and choose. Need just the AI calls? Use <code>Hazina.AI.FluentAPI</code>. Need a full API with multi-tenancy? Add <code>Hazina.API.Generic</code>. It's your call.</p>

<p>In the <strong>next post</strong>, we'll get Hazina running on your machine in under 5 minutes. No really — 5 minutes.</p>
"@
}

# ============================================================
# POST 2: Quick Start — From Zero to AI Call in 5 Minutes
# ============================================================
$posts += @{
    title = "Hazina Quick Start: From Zero to AI Call in 5 Minutes"
    slug = "hazina-quick-start-five-minutes"
    content = @"
<p>Let's skip the theory and get our hands dirty. In this post, you'll go from a blank terminal to a working AI call in under 5 minutes.</p>

<h2>Prerequisites</h2>

<table>
<tr><th>Requirement</th><th>Version</th><th>Check</th></tr>
<tr><td>.NET SDK</td><td>9.0+</td><td><code>dotnet --version</code></td></tr>
<tr><td>Git</td><td>Any</td><td><code>git --version</code></td></tr>
<tr><td>API Key</td><td>OpenAI or Anthropic</td><td>Your dashboard</td></tr>
</table>

<h2>Step 1: Clone the Repository</h2>

<pre><code>git clone https://github.com/martiendejong/Hazina.git
cd hazina
</code></pre>

<h2>Step 2: Restore Dependencies</h2>

<pre><code>dotnet restore Hazina.QuickStart.sln
</code></pre>

<h2>Step 3: Set Your API Key</h2>

<pre><code># PowerShell
`$env:OPENAI_API_KEY = "sk-your-key-here"

# Or for Anthropic
`$env:ANTHROPIC_API_KEY = "sk-ant-your-key-here"
</code></pre>

<h2>Step 4: Run the Demo</h2>

<pre><code>dotnet run --project apps/Demos/Hazina.Demo.ConfigurationShowcase
</code></pre>

<p>You should see output showing various AI providers responding to prompts. That's it — Hazina is running.</p>

<h2>Step 5: Your First Custom AI Call</h2>

<p>Create a new console app or add this to any existing project:</p>

<pre><code>using Hazina.AI.FluentAPI.Configuration;
using Hazina.AI.FluentAPI.Core;

// One-time setup
QuickSetup.SetupOpenAI(Environment.GetEnvironmentVariable("OPENAI_API_KEY")!);

// Ask anything
var answer = await Hazina.AskAsync("What is the meaning of life?");
Console.WriteLine(answer);
</code></pre>

<p>Two lines of setup. One line to call AI. That's the Hazina way.</p>

<h2>Verification Checklist</h2>

<table>
<tr><th>Component</th><th>Command</th><th>Expected</th></tr>
<tr><td>Build</td><td><code>dotnet build Hazina.QuickStart.sln</code></td><td>0 errors</td></tr>
<tr><td>Tests</td><td><code>dotnet test Hazina.QuickStart.sln</code></td><td>All pass</td></tr>
<tr><td>Demo</td><td><code>dotnet run --project apps/Demos/...</code></td><td>AI output</td></tr>
</table>

<h2>Common Scenarios</h2>

<p><strong>Just exploring?</strong> Open <code>Hazina.QuickStart.sln</code> and browse the demos.</p>
<p><strong>Building an AI app?</strong> Reference <code>Hazina.AI.FluentAPI</code> in your project and use <code>QuickSetup</code>.</p>
<p><strong>Need document search?</strong> We'll cover RAG in a later post — stay tuned.</p>

<p>In the <strong>next post</strong>, we'll dive into the FluentAPI — Hazina's elegant way of talking to any LLM provider.</p>
"@
}

# ============================================================
# POST 3: The FluentAPI — Talking to Any LLM Provider
# ============================================================
$posts += @{
    title = "Hazina FluentAPI: One Interface for Every LLM Provider"
    slug = "hazina-fluentapi-llm-providers"
    content = @"
<p>One of the most frustrating things about working with AI APIs is that every provider has a different SDK, different request format, and different response structure. Hazina's FluentAPI solves this with a unified interface that works with OpenAI, Anthropic, and more.</p>

<h2>The Problem</h2>

<p>Without Hazina, switching from OpenAI to Anthropic means rewriting your integration code. Different parameter names, different streaming patterns, different error handling. Multiply this across a production app and you have a maintenance nightmare.</p>

<h2>The Solution: One API to Rule Them All</h2>

<pre><code>using Hazina.AI.FluentAPI.Core;

// Simple question
var answer = await Hazina.AskAsync("Explain quantum computing in simple terms");

// With system prompt
var answer = await Hazina.AskAsync(
    "Translate this to Dutch",
    systemPrompt: "You are a professional translator"
);
</code></pre>

<h2>Provider Configuration</h2>

<p>Hazina supports multiple LLM providers through a clean configuration pattern:</p>

<pre><code>using Hazina.AI.FluentAPI.Configuration;

// OpenAI
QuickSetup.SetupOpenAI(apiKey, model: "gpt-4o");

// Anthropic
QuickSetup.SetupAnthropic(apiKey, model: "claude-sonnet-4-5-20250929");

// Multiple providers simultaneously
QuickSetup.SetupAndConfigure(config => {
    config.AddOpenAI(openAiKey);
    config.AddAnthropic(anthropicKey);
    config.DefaultProvider = "anthropic";
});
</code></pre>

<h2>Streaming Responses</h2>

<p>For real-time output (like a chat interface), Hazina supports streaming out of the box:</p>

<pre><code>await foreach (var chunk in Hazina.StreamAsync("Write a short story"))
{
    Console.Write(chunk);
}
</code></pre>

<p>The streaming interface is provider-agnostic — same code whether you're using OpenAI or Anthropic.</p>

<h2>Conversation History</h2>

<p>For multi-turn conversations, use the conversation builder:</p>

<pre><code>var conversation = Hazina.CreateConversation()
    .WithSystemPrompt("You are a helpful coding assistant")
    .AddUserMessage("How do I sort a list in C#?")
    .AddAssistantMessage("You can use LINQ: list.OrderBy(x => x)")
    .AddUserMessage("What about descending order?");

var response = await conversation.SendAsync();
</code></pre>

<h2>Why This Matters</h2>

<p>The FluentAPI isn't just syntactic sugar. It's a strategic abstraction that lets you:</p>

<ul>
<li>Switch providers without changing application code</li>
<li>A/B test different models easily</li>
<li>Fall back to alternative providers when one is down</li>
<li>Keep your codebase clean and testable</li>
</ul>

<p>In the <strong>next post</strong>, we'll look at how Hazina's configuration system gives you fine-grained control over every aspect of the AI pipeline.</p>
"@
}

# ============================================================
# POST 4: Configuration Deep Dive
# ============================================================
$posts += @{
    title = "Hazina Configuration: Fine-Tuning Your AI Pipeline"
    slug = "hazina-configuration-deep-dive"
    content = @"
<p>Default settings are great for getting started, but production applications need fine-grained control. Hazina's layered configuration system lets you tune everything from token limits to retry policies — without cluttering your code.</p>

<h2>Configuration Layers</h2>

<p>Hazina uses a cascading configuration model:</p>

<ol>
<li><strong>Hardcoded defaults</strong> — sensible out of the box</li>
<li><strong>appsettings.json</strong> — standard .NET configuration</li>
<li><strong>Environment variables</strong> — for secrets and deployment overrides</li>
<li><strong>Code-based setup</strong> — for dynamic or programmatic configuration</li>
</ol>

<h2>appsettings.json Example</h2>

<pre><code>{
  "Hazina": {
    "AI": {
      "DefaultProvider": "openai",
      "OpenAI": {
        "ApiKey": "", // Use env var instead
        "Model": "gpt-4o",
        "MaxTokens": 4096,
        "Temperature": 0.7
      },
      "Anthropic": {
        "ApiKey": "",
        "Model": "claude-sonnet-4-5-20250929",
        "MaxTokens": 4096
      }
    },
    "Storage": {
      "Type": "sqlite",
      "ConnectionString": "Data Source=hazina.db"
    }
  }
}
</code></pre>

<h2>Programmatic Configuration</h2>

<pre><code>builder.Services.AddHazina(config => {
    config.AI.DefaultProvider = "openai";
    config.AI.MaxTokens = 8192;
    config.AI.Temperature = 0.3f; // More deterministic
    config.AI.RetryPolicy = new RetryPolicy {
        MaxRetries = 3,
        BackoffMultiplier = 2.0
    };

    config.Storage.UseSqlite("hazina.db");
    // Or for production:
    // config.Storage.UsePostgreSQL(connectionString);
});
</code></pre>

<h2>Environment Variable Overrides</h2>

<p>Any configuration value can be overridden via environment variables using the double-underscore convention:</p>

<pre><code>HAZINA__AI__DEFAULTPROVIDER=anthropic
HAZINA__AI__MAXTOKENS=8192
HAZINA__STORAGE__TYPE=postgresql
</code></pre>

<h2>Per-Request Overrides</h2>

<p>Need different settings for a specific call? Override inline:</p>

<pre><code>var response = await Hazina.AskAsync("Summarize this document",
    options: new RequestOptions {
        Model = "gpt-4o-mini",  // Cheaper model for simple tasks
        MaxTokens = 500,
        Temperature = 0.0f       // Deterministic
    });
</code></pre>

<h2>Configuration Validation</h2>

<p>Hazina validates your configuration at startup and provides clear error messages:</p>

<pre><code>// This will throw with a helpful message:
// "No API key configured for provider 'openai'.
//  Set OPENAI_API_KEY environment variable or configure via appsettings.json"
</code></pre>

<p>No more silent failures or cryptic 401 errors. Hazina tells you exactly what's wrong.</p>

<p>In the <strong>next post</strong>, we'll explore the Generic API Framework — Hazina's approach to eliminating boilerplate CRUD code.</p>
"@
}

# ============================================================
# POST 5: Generic API Framework — Zero-Boilerplate CRUD
# ============================================================
$posts += @{
    title = "Hazina Generic API: Build a Full CRUD API in One Line of Code"
    slug = "hazina-generic-api-crud"
    content = @"
<p>How many times have you written the same List/Get/Create/Update/Delete controller code? In a typical ASP.NET Core API, this boilerplate multiplies fast — 75 controllers doing essentially the same thing. Hazina's Generic API Framework ends this repetition.</p>

<h2>The Old Way</h2>

<pre><code>// You'd write this 75 times...
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    [HttpGet] public async Task&lt;IActionResult&gt; List(...) { ... }
    [HttpGet("{id}")] public async Task&lt;IActionResult&gt; Get(int id) { ... }
    [HttpPost] public async Task&lt;IActionResult&gt; Create(ProductDto dto) { ... }
    [HttpPut("{id}")] public async Task&lt;IActionResult&gt; Update(int id, ProductDto dto) { ... }
    [HttpDelete("{id}")] public async Task&lt;IActionResult&gt; Delete(int id) { ... }
}
</code></pre>

<h2>The Hazina Way</h2>

<pre><code>[Route("api/[controller]")]
public class ProductsController : GenericEntityController&lt;Product&gt;
{
    public ProductsController(IRepository&lt;Product&gt; repo) : base(repo) { }
}
</code></pre>

<p>That's it. You now have:</p>

<ul>
<li><code>GET /api/products</code> — List with pagination, filtering, sorting</li>
<li><code>GET /api/products/{id}</code> — Get by ID</li>
<li><code>POST /api/products</code> — Create</li>
<li><code>PUT /api/products/{id}</code> — Full update</li>
<li><code>PATCH /api/products/{id}</code> — Partial update</li>
<li><code>DELETE /api/products/{id}</code> — Soft delete</li>
<li><code>POST /api/products/bulk</code> — Bulk create</li>
<li><code>DELETE /api/products/bulk</code> — Bulk delete</li>
<li><code>GET /api/products/count</code> — Count</li>
<li><code>GET /api/products/exists/{id}</code> — Check existence</li>
</ul>

<h2>Entity Definition</h2>

<pre><code>using Hazina.API.Generic.Entities;

public class Product : EntityBase
{
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string? Description { get; set; }
}
</code></pre>

<p>The <code>EntityBase</code> class gives you <code>Id</code>, <code>CreatedAt</code>, and <code>UpdatedAt</code> automatically.</p>

<h2>Registration</h2>

<pre><code>// In Program.cs
builder.Services.AddDbContext&lt;AppDbContext&gt;(options => ...);
builder.Services.AddGenericEntityApi&lt;AppDbContext&gt;();

// In the pipeline
app.UseAuthentication();
app.UseGenericEntityApi(); // After auth
</code></pre>

<h2>Built-in Pagination and Filtering</h2>

<pre><code>GET /api/products?page=1&amp;pageSize=20&amp;sort=price&amp;order=desc&amp;filter=name:contains:phone
</code></pre>

<p>No extra code needed. Pagination, sorting, and filtering come free with every entity.</p>

<p>In the <strong>next post</strong>, we'll explore the different entity base classes and when to use each one.</p>
"@
}

# ============================================================
# POST 6: Entity Base Classes — Choose Your Superpower
# ============================================================
$posts += @{
    title = "Hazina Entity Types: Soft Delete, Multi-Tenant, and Ownership"
    slug = "hazina-entity-base-classes"
    content = @"
<p>Not every entity needs the same features. A simple lookup table doesn't need soft delete. A user's private document needs ownership enforcement. Hazina gives you four entity base classes to match your needs.</p>

<h2>The Four Base Classes</h2>

<table>
<tr><th>Base Class</th><th>Features</th><th>Use Case</th></tr>
<tr><td><code>EntityBase</code></td><td>ID, CreatedAt, UpdatedAt</td><td>Simple entities, lookup tables</td></tr>
<tr><td><code>SoftDeleteEntityBase</code></td><td>+ IsDeleted, DeletedAt</td><td>Entities that should never truly disappear</td></tr>
<tr><td><code>TenantEntityBase</code></td><td>+ TenantId, automatic filtering</td><td>Multi-tenant SaaS applications</td></tr>
<tr><td><code>OwnedEntityBase</code></td><td>+ OwnerId, access control</td><td>User-owned content</td></tr>
</table>

<h2>EntityBase — The Foundation</h2>

<pre><code>public class Category : EntityBase
{
    public string Name { get; set; } = string.Empty;
}
// Gives you: Id, CreatedAt, UpdatedAt
</code></pre>

<h2>SoftDeleteEntityBase — Nothing Is Ever Gone</h2>

<pre><code>public class Invoice : SoftDeleteEntityBase
{
    public string Number { get; set; } = string.Empty;
    public decimal Amount { get; set; }
}
// DELETE /api/invoices/42 sets IsDeleted=true, DeletedAt=now
// GET /api/invoices automatically excludes deleted records
// GET /api/invoices?includeDeleted=true shows everything
</code></pre>

<h2>TenantEntityBase — Automatic Data Isolation</h2>

<pre><code>public class Project : TenantEntityBase
{
    public string Name { get; set; } = string.Empty;
}
// Every query is automatically filtered by TenantId
// Tenant A never sees Tenant B's data
// No manual WHERE clauses needed
</code></pre>

<h2>OwnedEntityBase — User-Level Access Control</h2>

<pre><code>public class Document : OwnedEntityBase
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
}
// Only the owner can see/edit their documents
// OwnerId is set automatically from the authenticated user
</code></pre>

<h2>Combining Features</h2>

<p>Need soft delete AND multi-tenancy? Create your own base:</p>

<pre><code>public abstract class TenantSoftDeleteEntity : TenantEntityBase
{
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
}
</code></pre>

<p>The framework respects all configured behaviors automatically.</p>

<p>In the <strong>next post</strong>, we'll deep dive into multi-tenancy — how Hazina handles data isolation in SaaS applications.</p>
"@
}

# ============================================================
# POST 7: Multi-Tenancy — Building SaaS with Hazina
# ============================================================
$posts += @{
    title = "Building Multi-Tenant SaaS Applications with Hazina"
    slug = "hazina-multi-tenancy-saas"
    content = @"
<p>Multi-tenancy is one of the hardest things to retrofit into an application. With Hazina, it's built in from the start. Every query, every mutation, every API call is automatically scoped to the current tenant.</p>

<h2>How It Works</h2>

<p>Hazina uses a middleware-based approach to tenant resolution:</p>

<ol>
<li>Request comes in with tenant identifier (header, subdomain, or JWT claim)</li>
<li>Middleware resolves the tenant and sets the tenant context</li>
<li>All database queries are automatically filtered by TenantId</li>
<li>All creates automatically stamp the TenantId</li>
<li>Cross-tenant access is impossible at the framework level</li>
</ol>

<h2>Setup</h2>

<pre><code>builder.Services.AddGenericEntityApi&lt;AppDbContext&gt;();
builder.Services.AddScoped&lt;ITenantContext, TenantContext&gt;();

// Configure tenant resolution
builder.Services.AddTenantResolution(options => {
    options.Strategy = TenantResolutionStrategy.Header;
    options.HeaderName = "X-Tenant-Id";
    // Or: options.Strategy = TenantResolutionStrategy.JwtClaim;
    // Or: options.Strategy = TenantResolutionStrategy.Subdomain;
});
</code></pre>

<h2>Entity Definition</h2>

<pre><code>public class Customer : TenantEntityBase
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}
</code></pre>

<h2>What Happens Behind the Scenes</h2>

<pre><code>// When Tenant A calls GET /api/customers
// Hazina generates: SELECT * FROM Customers WHERE TenantId = 'tenant-a'

// When Tenant A calls POST /api/customers
// Hazina automatically sets: customer.TenantId = 'tenant-a'

// When Tenant A calls GET /api/customers/42
// If customer 42 belongs to Tenant B: 404 Not Found
// Not 403 — the customer simply doesn't exist in Tenant A's world
</code></pre>

<h2>Global Entities</h2>

<p>Some entities are shared across tenants (categories, settings templates). Use <code>EntityBase</code> for those — they bypass tenant filtering:</p>

<pre><code>public class GlobalCategory : EntityBase  // No tenant filtering
{
    public string Name { get; set; } = string.Empty;
}

public class TenantCategory : TenantEntityBase  // Tenant-scoped
{
    public string Name { get; set; } = string.Empty;
}
</code></pre>

<h2>Testing Multi-Tenancy</h2>

<pre><code>// In your tests, just set the tenant context:
var tenantContext = new TestTenantContext("test-tenant");
services.AddScoped&lt;ITenantContext&gt;(_ => tenantContext);
</code></pre>

<p>In the <strong>next post</strong>, we'll explore RAG — Hazina's Retrieval-Augmented Generation engine for smart document search.</p>
"@
}

# ============================================================
# POST 8: RAG Engine — Smart Document Search
# ============================================================
$posts += @{
    title = "Hazina RAG Engine: Build a Smart Document Search in Minutes"
    slug = "hazina-rag-engine-document-search"
    content = @"
<p>RAG (Retrieval-Augmented Generation) is the technique that makes AI actually useful for your data. Instead of hallucinating answers, the AI searches your documents first, then generates answers based on real information. Hazina makes this ridiculously easy.</p>

<h2>What RAG Does</h2>

<ol>
<li><strong>Index</strong> — Your documents are split into chunks and converted to vector embeddings</li>
<li><strong>Retrieve</strong> — When a user asks a question, relevant chunks are found via similarity search</li>
<li><strong>Generate</strong> — The AI answers using the retrieved context</li>
</ol>

<h2>Quick Setup</h2>

<pre><code>// Configure storage
builder.Services.AddHazina(config => {
    config.Storage.UseSqlite("hazina-rag.db");
    config.AI.SetupOpenAI(apiKey);
});
</code></pre>

<h2>Indexing Documents</h2>

<pre><code>var ragEngine = serviceProvider.GetRequiredService&lt;IRagEngine&gt;();

// Index a single document
await ragEngine.IndexDocumentAsync(new Document {
    Title = "Company Policy",
    Content = File.ReadAllText("policy.txt"),
    Metadata = new { Department = "HR", Year = 2026 }
});

// Index a directory
await ragEngine.IndexDirectoryAsync("./documents",
    pattern: "*.txt",
    recursive: true);
</code></pre>

<h2>Querying with Context</h2>

<pre><code>// Simple query
var answer = await ragEngine.AskWithContextAsync(
    "What is our vacation policy?"
);
Console.WriteLine(answer.Response);
Console.WriteLine($"Sources: {string.Join(", ", answer.Sources)}");

// With metadata filter
var answer = await ragEngine.AskWithContextAsync(
    "What changed in 2026?",
    filter: new { Year = 2026 }
);
</code></pre>

<h2>How Chunking Works</h2>

<p>Hazina automatically splits documents into optimal chunks for retrieval:</p>

<ul>
<li>Default chunk size: 500 tokens with 50-token overlap</li>
<li>Respects paragraph boundaries</li>
<li>Preserves code blocks and structured content</li>
<li>Configurable: <code>config.RAG.ChunkSize = 1000;</code></li>
</ul>

<h2>Storage Backends</h2>

<p>Vector embeddings can be stored in:</p>

<ul>
<li><strong>SQLite</strong> — Zero setup, great for development and small datasets</li>
<li><strong>PostgreSQL</strong> — Production-ready with pgvector extension</li>
<li><strong>Supabase</strong> — Managed PostgreSQL with vector support</li>
</ul>

<p>In the <strong>next post</strong>, we'll look at the Document Store — the persistence layer behind RAG and more.</p>
"@
}

# ============================================================
# POST 9: Document Store — Persistent Knowledge Base
# ============================================================
$posts += @{
    title = "Hazina Document Store: Your Application's Knowledge Base"
    slug = "hazina-document-store-knowledge-base"
    content = @"
<p>Behind every RAG engine is a document store. Hazina's Document Store is designed to be both a simple key-value store for documents and a sophisticated vector database for similarity search. Let's explore how it works.</p>

<h2>Architecture</h2>

<p>The Document Store consists of three layers:</p>

<ol>
<li><strong>Document Storage</strong> — Raw documents with metadata</li>
<li><strong>Chunk Storage</strong> — Processed text chunks</li>
<li><strong>Vector Index</strong> — Embeddings for similarity search</li>
</ol>

<h2>Basic Document Operations</h2>

<pre><code>var store = serviceProvider.GetRequiredService&lt;IDocumentStore&gt;();

// Store a document
var docId = await store.StoreAsync(new Document {
    Title = "Product Manual",
    Content = "...",
    ContentType = "text/plain",
    Tags = new[] { "documentation", "product" },
    Metadata = new Dictionary&lt;string, object&gt; {
        ["version"] = "2.0",
        ["department"] = "Engineering"
    }
});

// Retrieve
var doc = await store.GetAsync(docId);

// Search by tags
var docs = await store.SearchByTagsAsync(new[] { "documentation" });

// Full-text search
var results = await store.SearchAsync("product features");
</code></pre>

<h2>Vector Similarity Search</h2>

<pre><code>// Find documents similar to a query
var similar = await store.FindSimilarAsync(
    query: "How do I configure the API?",
    topK: 5,
    threshold: 0.7f  // Minimum similarity score
);

foreach (var result in similar)
{
    Console.WriteLine($"{result.Score:P0} - {result.Document.Title}");
    Console.WriteLine($"  Chunk: {result.ChunkText[..100]}...");
}
</code></pre>

<h2>SQLite Configuration</h2>

<pre><code>builder.Services.AddHazina(config => {
    config.Storage.UseSqlite(new SqliteSettings {
        DatabasePath = "./data/hazina.db",
        EnableWAL = true,         // Better concurrent access
        VacuumOnStartup = false   // Skip for faster startup
    });
});
</code></pre>

<h2>PostgreSQL for Production</h2>

<pre><code>builder.Services.AddHazina(config => {
    config.Storage.UsePostgreSQL(new PostgresSettings {
        ConnectionString = connectionString,
        EnablePgVector = true,    // Required for vector search
        VectorDimensions = 1536  // OpenAI embedding size
    });
});
</code></pre>

<h2>Document Lifecycle</h2>

<p>Documents go through a clear lifecycle:</p>
<ol>
<li><strong>Stored</strong> — Raw content saved</li>
<li><strong>Chunked</strong> — Split into searchable pieces</li>
<li><strong>Embedded</strong> — Vector embeddings generated</li>
<li><strong>Indexed</strong> — Available for similarity search</li>
</ol>

<p>All steps happen automatically when you call <code>IndexDocumentAsync</code>.</p>

<p>In the <strong>next post</strong>, we'll cover one of Hazina's most powerful features: the Dynamic Plugin System.</p>
"@
}

# ============================================================
# POST 10: Dynamic Plugin System — Runtime Code Generation
# ============================================================
$posts += @{
    title = "Hazina Plugins: AI-Powered Runtime Code Generation with Roslyn"
    slug = "hazina-dynamic-plugin-system"
    content = @"
<p>What if your application could write its own extensions at runtime? Hazina's Dynamic Plugin System uses Roslyn to compile C# code on-the-fly, enabling AI to create new capabilities without redeployment. This is not science fiction — it's a production-ready pattern.</p>

<h2>How It Works</h2>

<ol>
<li>AI (or a user) writes C# code for a new capability</li>
<li>Hazina compiles it at runtime using Roslyn</li>
<li>The compiled plugin runs in a sandboxed environment</li>
<li>Results are returned to the caller</li>
</ol>

<h2>Creating a Plugin</h2>

<pre><code>var pluginManager = serviceProvider.GetRequiredService&lt;IPluginManager&gt;();

var plugin = await pluginManager.CreatePluginAsync(new PluginDefinition {
    Name = "WelcomeEmailPlugin",
    Description = "Sends welcome email to new customers",
    Code = @"
        var customer = context.GetParameter&lt;Customer&gt;(""customer"");
        var emailService = context.GetService&lt;IEmailService&gt;();

        await emailService.SendTemplateAsync(
            to: customer.Email,
            template: ""welcome"",
            data: new { CustomerName = customer.Name }
        );

        return PluginResult.Success(""Email sent"");
    "
});
</code></pre>

<h2>Executing a Plugin</h2>

<pre><code>var result = await pluginManager.ExecuteAsync("WelcomeEmailPlugin",
    new Dictionary&lt;string, object&gt; {
        ["customer"] = newCustomer
    });

if (result.IsSuccess)
    Console.WriteLine(result.Output);
</code></pre>

<h2>Security: The Sandbox</h2>

<p>Every plugin runs in a controlled environment:</p>

<pre><code>var securitySettings = new PluginSecuritySettings {
    AllowedNamespaces = new[] {
        "System", "System.Linq", "System.Collections.Generic"
    },
    BlockedTypes = new[] {
        "System.IO.File", "System.Net.Http.HttpClient"
    },
    MaxExecutionTime = TimeSpan.FromSeconds(30),
    MaxMemoryMB = 128
};
</code></pre>

<h2>Version Management</h2>

<pre><code>// Update a plugin (new version created automatically)
await pluginManager.UpdatePluginAsync("WelcomeEmailPlugin", newCode);

// View version history
var versions = await pluginManager.GetVersionHistoryAsync("WelcomeEmailPlugin");

// Rollback if something goes wrong
await pluginManager.RollbackAsync("WelcomeEmailPlugin", previousVersion);
</code></pre>

<h2>Real-World Use Cases</h2>

<ul>
<li><strong>Custom business rules</strong> — Let AI generate validation logic from natural language</li>
<li><strong>Data transformations</strong> — Dynamic ETL pipelines that adapt to new data formats</li>
<li><strong>Automation workflows</strong> — Create new automation steps without deploying code</li>
<li><strong>Report generators</strong> — AI writes the data processing logic for custom reports</li>
</ul>

<p>In the <strong>next post</strong>, we'll explore plugin security in depth — how to keep dynamic code safe.</p>
"@
}

# ============================================================
# POST 11: Plugin Security — Keeping Dynamic Code Safe
# ============================================================
$posts += @{
    title = "Hazina Plugin Security: Sandboxing Runtime-Generated Code"
    slug = "hazina-plugin-security-sandbox"
    content = @"
<p>Running dynamically generated code in production sounds scary. And it should — if you do it wrong. Hazina's plugin sandbox is designed with security as the primary concern, using multiple layers of protection.</p>

<h2>Defense in Depth</h2>

<p>Hazina uses four layers of security for plugins:</p>

<ol>
<li><strong>Compilation-time analysis</strong> — Block dangerous code before it compiles</li>
<li><strong>Namespace whitelisting</strong> — Only approved APIs are available</li>
<li><strong>Runtime sandbox</strong> — Timeout and memory limits</li>
<li><strong>Service injection control</strong> — Plugins only access services you explicitly allow</li>
</ol>

<h2>Compilation-Time Security</h2>

<pre><code>// These patterns are blocked at compile time:
// - Direct file system access (System.IO.File, Directory)
// - Raw network calls (Socket, HttpClient)
// - Process execution (Process.Start)
// - Reflection (Assembly.Load, Type.InvokeMember)
// - Thread manipulation (Thread.Start, Task.Run)
</code></pre>

<h2>Configuring the Sandbox</h2>

<pre><code>builder.Services.AddHazinaPlugins(options => {
    options.Security = new PluginSecuritySettings {
        // Namespace whitelist
        AllowedNamespaces = new[] {
            "System",
            "System.Linq",
            "System.Collections.Generic",
            "System.Text.Json",
            "MyApp.Models"   // Your own safe types
        },

        // Execution limits
        MaxExecutionTime = TimeSpan.FromSeconds(30),
        MaxMemoryMB = 128,

        // Service access
        AllowedServices = new[] {
            typeof(IEmailService),
            typeof(ILogger),
            typeof(IDocumentStore)
        }
    };
});
</code></pre>

<h2>The Plugin Context</h2>

<p>Plugins don't have direct access to DI — they go through a controlled context:</p>

<pre><code>// Inside a plugin:
var logger = context.GetService&lt;ILogger&gt;();    // OK - whitelisted
var db = context.GetService&lt;DbContext&gt;();       // Throws - not whitelisted
var param = context.GetParameter&lt;Customer&gt;("customer"); // Safe parameter access
</code></pre>

<h2>Timeout Protection</h2>

<pre><code>try
{
    var result = await pluginManager.ExecuteAsync("MyPlugin", parameters);
}
catch (PluginTimeoutException ex)
{
    logger.LogWarning("Plugin {Name} timed out after {Duration}",
        ex.PluginName, ex.Duration);
}
</code></pre>

<h2>Audit Trail</h2>

<p>Every plugin execution is logged:</p>

<ul>
<li>Who created the plugin</li>
<li>When it was compiled</li>
<li>Every execution with duration and result</li>
<li>Version history with diffs</li>
</ul>

<p>In the <strong>next post</strong>, we'll look at Agent Orchestration — Hazina's framework for building autonomous AI agents.</p>
"@
}

# ============================================================
# POST 12: Agent Orchestration
# ============================================================
$posts += @{
    title = "Hazina Agent Orchestration: Building Autonomous AI Systems"
    slug = "hazina-agent-orchestration"
    content = @"
<p>A single AI call answers a question. An agent orchestration system solves problems. Hazina's orchestration layer lets you build AI agents that can use tools, maintain state, and work autonomously toward goals.</p>

<h2>What Is Agent Orchestration?</h2>

<p>An agent is an AI model connected to tools (functions it can call). The orchestration layer manages:</p>

<ul>
<li><strong>Tool execution</strong> — The AI decides which tools to call and in what order</li>
<li><strong>State management</strong> — Conversation history and intermediate results</li>
<li><strong>Error handling</strong> — Retries, fallbacks, and graceful degradation</li>
<li><strong>Security</strong> — Controlling what the agent can and cannot do</li>
</ul>

<h2>Creating an Agent</h2>

<pre><code>var agent = new HazinaAgent()
    .WithSystemPrompt("You are a customer support agent for an e-commerce store.")
    .WithTool(new SearchOrdersTool())
    .WithTool(new GetProductInfoTool())
    .WithTool(new CreateRefundTool())
    .WithMaxIterations(10);

var response = await agent.RunAsync("I want to return my order #12345");
</code></pre>

<h2>Defining Tools</h2>

<pre><code>public class SearchOrdersTool : IAgentTool
{
    public string Name => "search_orders";
    public string Description => "Search for customer orders by order ID or email";

    public ToolParameters Parameters => new() {
        { "query", ToolParameterType.String, "Order ID or email address" }
    };

    public async Task&lt;string&gt; ExecuteAsync(ToolContext context)
    {
        var query = context.GetParameter&lt;string&gt;("query");
        var orders = await _orderService.SearchAsync(query);
        return JsonSerializer.Serialize(orders);
    }
}
</code></pre>

<h2>The Orchestration Loop</h2>

<p>When you call <code>agent.RunAsync()</code>, Hazina:</p>

<ol>
<li>Sends the user message to the LLM with available tools</li>
<li>If the LLM wants to call a tool, Hazina executes it</li>
<li>Tool results are sent back to the LLM</li>
<li>Repeat until the LLM provides a final answer</li>
<li>Return the response to the user</li>
</ol>

<h2>Terminal Access (ConPTY)</h2>

<p>Hazina can even give agents access to a terminal for system operations:</p>

<pre><code>var agent = new HazinaAgent()
    .WithSystemPrompt("You are a DevOps agent.")
    .WithTerminalAccess(new TerminalOptions {
        AllowedCommands = new[] { "git", "dotnet", "npm" },
        WorkingDirectory = "/app",
        MaxSessionDuration = TimeSpan.FromMinutes(5)
    });
</code></pre>

<p>This powers the Hazina Orchestration demo — a web-based terminal where AI can execute real commands.</p>

<p>In the <strong>next post</strong>, we'll explore Social Content Providers — connecting to WordPress, LinkedIn, and more.</p>
"@
}

# ============================================================
# POST 13: Social Content Providers
# ============================================================
$posts += @{
    title = "Hazina Social Providers: Import Content from WordPress, LinkedIn, and More"
    slug = "hazina-social-content-providers"
    content = @"
<p>Content lives everywhere — WordPress blogs, LinkedIn posts, Instagram feeds. Hazina's Social Provider system gives you a unified way to import and work with content from any platform.</p>

<h2>The Provider Interface</h2>

<pre><code>public interface ISocialProvider
{
    string ProviderName { get; }
    Task&lt;IEnumerable&lt;UnifiedContent&gt;&gt; ImportContentAsync(ImportOptions options);
    Task&lt;ContentMetrics&gt; GetMetricsAsync(string contentId);
}
</code></pre>

<h2>WordPress Provider</h2>

<pre><code>var wpProvider = new WordPressProvider(new WordPressConfig {
    SiteUrl = "https://yourblog.com",
    Username = "admin",
    ApplicationPassword = "xxxx xxxx xxxx xxxx"
});

// Import all posts
var posts = await wpProvider.ImportContentAsync(new ImportOptions {
    ContentTypes = new[] { "post", "page" },
    Since = DateTime.UtcNow.AddMonths(-6),
    IncludeMetadata = true
});

foreach (var post in posts)
{
    Console.WriteLine($"[{post.PublishedAt:d}] {post.Title}");
    Console.WriteLine($"  Tags: {string.Join(", ", post.Tags)}");
    Console.WriteLine($"  Words: {post.WordCount}");
}
</code></pre>

<h2>Unified Content Model</h2>

<p>Regardless of source, all content becomes a <code>UnifiedContent</code> object:</p>

<pre><code>public class UnifiedContent
{
    public string Id { get; set; }
    public string Source { get; set; }        // "wordpress", "linkedin", etc.
    public string Title { get; set; }
    public string Content { get; set; }       // HTML or plain text
    public string? Excerpt { get; set; }
    public DateTime PublishedAt { get; set; }
    public List&lt;string&gt; Tags { get; set; }
    public List&lt;ContentMedia&gt; Media { get; set; }
    public Dictionary&lt;string, object&gt; Metadata { get; set; }
}
</code></pre>

<h2>Content Store Integration</h2>

<p>Imported content goes directly into the Document Store for RAG:</p>

<pre><code>var store = serviceProvider.GetRequiredService&lt;IUnifiedContentStore&gt;();

// Import and index in one step
await store.ImportAndIndexAsync(wpProvider, new ImportOptions {
    ContentTypes = new[] { "post" }
});

// Now you can search across all imported content
var results = await store.SearchAsync("AI automation strategies");
</code></pre>

<h2>Building Custom Providers</h2>

<p>Creating a provider for a new platform is straightforward — implement <code>ISocialProvider</code> and map the platform's content to <code>UnifiedContent</code>.</p>

<p>In the <strong>next post</strong>, we'll look at Content Analysis — how Hazina uses AI to analyze writing style, topics, and sentiment.</p>
"@
}

# ============================================================
# POST 14: Content Analysis Pipeline
# ============================================================
$posts += @{
    title = "Hazina Content Analysis: AI-Powered Style, Topic, and Sentiment Detection"
    slug = "hazina-content-analysis-pipeline"
    content = @"
<p>Importing content is step one. Understanding it is step two. Hazina's Content Analysis Pipeline uses AI to automatically analyze every piece of content for writing style, topics, sentiment, and more.</p>

<h2>What Gets Analyzed</h2>

<ul>
<li><strong>Writing style</strong> — Formal vs. casual, technical vs. accessible</li>
<li><strong>Topic extraction</strong> — Key subjects and themes</li>
<li><strong>Sentiment</strong> — Positive, negative, neutral</li>
<li><strong>Readability</strong> — Grade level, complexity score</li>
<li><strong>Keywords</strong> — SEO-relevant terms and phrases</li>
</ul>

<h2>Analyzing Content</h2>

<pre><code>var analyzer = serviceProvider.GetRequiredService&lt;IContentAnalyzer&gt;();

var analysis = await analyzer.AnalyzeAsync(content);

Console.WriteLine($"Style: {analysis.WritingStyle}");
Console.WriteLine($"Topics: {string.Join(", ", analysis.Topics)}");
Console.WriteLine($"Sentiment: {analysis.Sentiment.Label} ({analysis.Sentiment.Score:P0})");
Console.WriteLine($"Readability: Grade {analysis.ReadabilityGrade}");
</code></pre>

<h2>Building a Writing Profile</h2>

<p>Analyze multiple pieces of content to build a writing profile:</p>

<pre><code>var profile = await analyzer.BuildWritingProfileAsync(
    contents: allBlogPosts,
    profileName: "My Blog Voice"
);

Console.WriteLine($"Typical sentence length: {profile.AvgSentenceLength} words");
Console.WriteLine($"Vocabulary level: {profile.VocabularyLevel}");
Console.WriteLine($"Preferred topics: {string.Join(", ", profile.TopTopics)}");
Console.WriteLine($"Tone: {profile.Tone}");
</code></pre>

<h2>AI Inspiration Engine</h2>

<p>Use the writing profile to generate content suggestions that match your voice:</p>

<pre><code>var engine = serviceProvider.GetRequiredService&lt;IContentInspirationEngine&gt;();

var suggestions = await engine.GenerateIdeasAsync(new InspirationContext {
    WritingProfile = profile,
    RecentTopics = recentPosts.Select(p => p.Title),
    TargetAudience = "Tech-savvy business owners",
    Count = 5
});

foreach (var idea in suggestions)
{
    Console.WriteLine($"Title: {idea.SuggestedTitle}");
    Console.WriteLine($"Hook: {idea.OpeningHook}");
    Console.WriteLine($"Keywords: {string.Join(", ", idea.SuggestedKeywords)}");
}
</code></pre>

<h2>Batch Analysis</h2>

<p>Analyze your entire content library at once:</p>

<pre><code>var results = await analyzer.AnalyzeBatchAsync(allContent, new AnalysisOptions {
    IncludeStyle = true,
    IncludeTopics = true,
    IncludeSentiment = true,
    ParallelDegree = 4  // Process 4 at a time
});
</code></pre>

<p>In the <strong>next post</strong>, we'll explore Hazina's Observability features — monitoring, health checks, and logging.</p>
"@
}

# ============================================================
# POST 15: Observability and Monitoring
# ============================================================
$posts += @{
    title = "Hazina Observability: Monitoring Your AI Application in Production"
    slug = "hazina-observability-monitoring"
    content = @"
<p>Deploying an AI application without observability is like flying blind. Hazina includes built-in monitoring, health checks, and structured logging so you always know what your application is doing.</p>

<h2>Health Checks</h2>

<pre><code>builder.Services.AddHazinaHealthChecks(options => {
    options.AddLLMProviderCheck();     // Can we reach the AI API?
    options.AddDatabaseCheck();         // Is the database responding?
    options.AddDocumentStoreCheck();    // Is the vector store healthy?
    options.AddPluginSystemCheck();     // Are plugins compiled and cached?
});

app.MapHealthChecks("/health");
</code></pre>

<p>Hit <code>/health</code> and get a structured status response:</p>

<pre><code>{
  "status": "Healthy",
  "checks": {
    "llm_provider": { "status": "Healthy", "latency_ms": 234 },
    "database": { "status": "Healthy", "latency_ms": 3 },
    "document_store": { "status": "Healthy", "documents": 1523 },
    "plugin_system": { "status": "Healthy", "plugins_loaded": 7 }
  }
}
</code></pre>

<h2>Structured Logging</h2>

<p>Hazina logs every significant operation with structured data:</p>

<pre><code>// Automatic log entries:
// [INFO] AI request to openai/gpt-4o completed in 1234ms (150 tokens in, 89 tokens out)
// [INFO] RAG query "vacation policy" matched 3 documents (best score: 0.92)
// [WARN] Plugin "DataTransform" execution took 28s (limit: 30s)
// [ERROR] AI provider "anthropic" returned 429, retrying in 2s (attempt 2/3)
</code></pre>

<h2>Metrics</h2>

<p>Track key metrics over time:</p>

<ul>
<li><strong>AI calls</strong> — Count, latency, token usage, cost estimate</li>
<li><strong>RAG queries</strong> — Query count, relevance scores, cache hit rate</li>
<li><strong>Plugin executions</strong> — Count, duration, success/failure rate</li>
<li><strong>API requests</strong> — Per-entity CRUD operation counts</li>
</ul>

<h2>Cost Tracking</h2>

<pre><code>var metrics = serviceProvider.GetRequiredService&lt;IHazinaMetrics&gt;();

var usage = await metrics.GetUsageSummaryAsync(
    from: DateTime.UtcNow.AddDays(-30),
    to: DateTime.UtcNow
);

Console.WriteLine($"Total AI calls: {usage.TotalCalls}");
Console.WriteLine($"Total tokens: {usage.TotalTokens:N0}");
Console.WriteLine($"Estimated cost: ${usage.EstimatedCost:F2}");
Console.WriteLine($"Avg latency: {usage.AvgLatencyMs}ms");
</code></pre>

<p>In the <strong>next post</strong>, we'll cover EF Core integration — how Hazina works with Entity Framework Core.</p>
"@
}

# ============================================================
# POST 16: EF Core Integration
# ============================================================
$posts += @{
    title = "Hazina and Entity Framework Core: Database Patterns That Work"
    slug = "hazina-ef-core-integration"
    content = @"
<p>Hazina builds on top of Entity Framework Core, not around it. This means you keep all the EF Core features you know while getting Hazina's additions for free. Here's how they work together.</p>

<h2>DbContext Setup</h2>

<pre><code>public class AppDbContext : DbContext
{
    public DbSet&lt;Product&gt; Products { get; set; }
    public DbSet&lt;Customer&gt; Customers { get; set; }
    public DbSet&lt;Order&gt; Orders { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply Hazina conventions (soft delete filters, tenant filters, etc.)
        modelBuilder.ApplyHazinaConventions();
    }
}
</code></pre>

<h2>Automatic Query Filters</h2>

<p>When you call <code>ApplyHazinaConventions()</code>, EF Core global query filters are automatically configured:</p>

<ul>
<li><strong>Soft delete</strong> — <code>WHERE IsDeleted = false</code> on every query</li>
<li><strong>Multi-tenant</strong> — <code>WHERE TenantId = @currentTenant</code> on every query</li>
<li><strong>Ownership</strong> — <code>WHERE OwnerId = @currentUser</code> for owned entities</li>
</ul>

<h2>Migrations</h2>

<p>Standard EF Core migrations work as expected:</p>

<pre><code>dotnet ef migrations add AddProducts
dotnet ef database update
</code></pre>

<p>Hazina adds automatic columns to your migrations:</p>

<ul>
<li><code>CreatedAt</code> and <code>UpdatedAt</code> — Set automatically on save</li>
<li><code>TenantId</code> — Indexed for performance</li>
<li><code>IsDeleted</code> — Indexed and included in query filter</li>
</ul>

<h2>Audit Trail</h2>

<pre><code>builder.Services.AddHazinaAudit&lt;AppDbContext&gt;(options => {
    options.TrackChanges = true;
    options.IncludePropertyValues = true;
    options.ExcludeEntities = new[] { typeof(AuditLog) }; // Don't audit the audit
});
</code></pre>

<p>Every create, update, and delete is logged with:</p>
<ul>
<li>Who made the change</li>
<li>When it happened</li>
<li>What changed (old value to new value)</li>
<li>The entity type and ID</li>
</ul>

<h2>Repository Pattern</h2>

<p>Hazina provides a generic repository that wraps common EF Core operations:</p>

<pre><code>public interface IRepository&lt;T&gt; where T : EntityBase
{
    Task&lt;T?&gt; GetByIdAsync(int id);
    Task&lt;PagedResult&lt;T&gt;&gt; ListAsync(QueryOptions options);
    Task&lt;T&gt; CreateAsync(T entity);
    Task&lt;T&gt; UpdateAsync(T entity);
    Task DeleteAsync(int id);
    Task&lt;int&gt; CountAsync(FilterOptions? filter = null);
}
</code></pre>

<p>In the <strong>next post</strong>, we'll explore production deployment — getting Hazina running in the real world.</p>
"@
}

# ============================================================
# POST 17: Production Deployment
# ============================================================
$posts += @{
    title = "Deploying Hazina Applications to Production"
    slug = "hazina-production-deployment"
    content = @"
<p>Development is fun. Deployment is where it gets real. Hazina is designed for production from day one, with built-in support for configuration management, database migrations, monitoring, and scaling.</p>

<h2>Deployment Checklist</h2>

<ol>
<li>Switch from SQLite to PostgreSQL</li>
<li>Configure production API keys via environment variables</li>
<li>Enable health checks and monitoring</li>
<li>Set up proper logging</li>
<li>Configure rate limiting</li>
</ol>

<h2>Database: SQLite to PostgreSQL</h2>

<pre><code>// Development
config.Storage.UseSqlite("hazina-dev.db");

// Production
config.Storage.UsePostgreSQL(new PostgresSettings {
    ConnectionString = Environment.GetEnvironmentVariable("DATABASE_URL")!,
    EnablePgVector = true,
    MaxPoolSize = 20
});
</code></pre>

<h2>Environment Variables for Production</h2>

<pre><code># Required
OPENAI_API_KEY=sk-prod-key-here
DATABASE_URL=Host=db.example.com;Database=hazina;Username=app;Password=secret

# Optional
HAZINA__AI__MAXTOKENS=4096
HAZINA__AI__TEMPERATURE=0.3
ASPNETCORE_ENVIRONMENT=Production
</code></pre>

<h2>Docker Deployment</h2>

<pre><code>FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MyApp.dll"]
</code></pre>

<h2>Supabase Integration</h2>

<p>For a managed database with built-in vector support:</p>

<pre><code>config.Storage.UseSupabase(new SupabaseSettings {
    Url = Environment.GetEnvironmentVariable("SUPABASE_URL")!,
    ConnectionString = Environment.GetEnvironmentVariable("SUPABASE_CONNECTION_STRING")!
});
</code></pre>

<h2>Rate Limiting</h2>

<pre><code>builder.Services.AddHazinaRateLimiting(options => {
    options.PerTenant = new RateLimit {
        RequestsPerMinute = 60,
        AICallsPerHour = 100
    };
    options.Global = new RateLimit {
        RequestsPerMinute = 1000
    };
});
</code></pre>

<h2>Windows Service Deployment</h2>

<p>Hazina applications can also run as Windows Services using the built-in hosting support:</p>

<pre><code>builder.Host.UseWindowsService();
</code></pre>

<p>In the <strong>next post</strong>, we'll look at Hazina's YAML/JSON entity definitions — a way for non-developers to define data structures.</p>
"@
}

# ============================================================
# POST 18: YAML Entity Definitions
# ============================================================
$posts += @{
    title = "Hazina YAML Entities: Let Non-Developers Define Your Data Model"
    slug = "hazina-yaml-entity-definitions"
    content = @"
<p>Not everyone who needs to define a data structure is a C# developer. Hazina supports YAML and JSON entity definitions, making it possible for business analysts, product managers, or even AI to define entities that become fully functional APIs.</p>

<h2>YAML Entity Definition</h2>

<pre><code># entities/product.yaml
name: Product
baseClass: SoftDeleteEntityBase
properties:
  - name: Name
    type: string
    required: true
    maxLength: 200
  - name: Price
    type: decimal
    required: true
    min: 0
  - name: Description
    type: string
    maxLength: 2000
  - name: Category
    type: string
    required: true
  - name: IsActive
    type: bool
    default: true
</code></pre>

<h2>What This Generates</h2>

<p>From this YAML, Hazina generates:</p>

<ul>
<li>A C# entity class with all properties</li>
<li>EF Core configuration (column types, constraints)</li>
<li>A full CRUD API endpoint (<code>/api/products</code>)</li>
<li>Validation rules based on constraints</li>
<li>Database migration</li>
</ul>

<h2>JSON Format</h2>

<pre><code>{
  "name": "Customer",
  "baseClass": "TenantEntityBase",
  "properties": [
    { "name": "Name", "type": "string", "required": true },
    { "name": "Email", "type": "string", "required": true, "unique": true },
    { "name": "Phone", "type": "string" },
    { "name": "Tier", "type": "enum", "values": ["Free", "Pro", "Enterprise"] }
  ]
}
</code></pre>

<h2>Loading Definitions</h2>

<pre><code>builder.Services.AddGenericEntityApi&lt;AppDbContext&gt;(options => {
    options.LoadEntitiesFromYaml("./entities");
    // Or: options.LoadEntitiesFromJson("./entities");
});
</code></pre>

<h2>Relationships</h2>

<pre><code># entities/order.yaml
name: Order
baseClass: TenantEntityBase
properties:
  - name: CustomerId
    type: int
    relation: Customer
  - name: OrderDate
    type: datetime
    default: now
  - name: Total
    type: decimal
    computed: "Items.Sum(i => i.Price * i.Quantity)"
relations:
  - name: Items
    type: hasMany
    target: OrderItem
</code></pre>

<h2>Validation</h2>

<p>Hazina validates YAML definitions at startup and provides clear errors:</p>

<pre><code>// Error: Entity 'Order' references 'Customer' but no entity named 'Customer' was found.
// Did you mean 'Customers'?
</code></pre>

<p>In the <strong>next post</strong>, we'll explore the Developer CLI tools that make working with Hazina a breeze.</p>
"@
}

# ============================================================
# POST 19: Developer Tools and CLI
# ============================================================
$posts += @{
    title = "Hazina Developer Tools: CLI Commands and Productivity Boosters"
    slug = "hazina-developer-tools-cli"
    content = @"
<p>A framework is only as good as its developer experience. Hazina comes with CLI tools and development utilities that make building, testing, and debugging faster.</p>

<h2>Solution Files</h2>

<p>Hazina provides multiple solution files for different needs:</p>

<table>
<tr><th>Solution</th><th>Purpose</th><th>Projects</th></tr>
<tr><td><code>Hazina.QuickStart.sln</code></td><td>Getting started</td><td>Core + demos</td></tr>
<tr><td><code>Hazina.AI.sln</code></td><td>AI features only</td><td>FluentAPI + RAG + tools</td></tr>
<tr><td><code>Hazina.sln</code></td><td>Full framework</td><td>Everything</td></tr>
</table>

<h2>Demo Applications</h2>

<p>Each major feature has a runnable demo:</p>

<pre><code># Configuration showcase
dotnet run --project apps/Demos/Hazina.Demo.ConfigurationShowcase

# RAG demo
dotnet run --project apps/Demos/Hazina.Demo.RAG

# Plugin demo
dotnet run --project apps/Demos/Hazina.Demo.Plugins

# Orchestration demo (web terminal)
dotnet run --project apps/Demos/Hazina.Demo.AgenticOrchestration
</code></pre>

<h2>Code Generation</h2>

<p>Generate boilerplate from the command line:</p>

<pre><code># Generate a new entity with controller
dotnet hazina generate entity Product --base SoftDelete --controller

# Generate a new social provider
dotnet hazina generate provider Instagram

# Generate a new agent tool
dotnet hazina generate tool SearchCustomers
</code></pre>

<h2>Testing Utilities</h2>

<pre><code>// In-memory database for fast tests
var services = new HazinaTestServices()
    .WithInMemoryDatabase()
    .WithMockLLM(responses: new[] { "Mocked AI response" })
    .Build();

// Test an API endpoint
var client = services.CreateClient();
var response = await client.GetAsync("/api/products");
</code></pre>

<h2>Debug Dashboard</h2>

<p>In development mode, Hazina exposes a debug dashboard at <code>/hazina/debug</code>:</p>

<ul>
<li>View all registered entities and their configurations</li>
<li>See recent AI calls with full request/response</li>
<li>Browse the document store</li>
<li>Execute plugins manually</li>
<li>View health check status</li>
</ul>

<h2>Hot Reload</h2>

<p>YAML entity definitions support hot reload — change a YAML file and the API updates without restarting. Perfect for rapid prototyping.</p>

<p>In the <strong>final post</strong>, we'll tie everything together with architecture best practices and a complete application example.</p>
"@
}

# ============================================================
# POST 20: Architecture Best Practices — Putting It All Together
# ============================================================
$posts += @{
    title = "Hazina Architecture: Best Practices and a Complete Application Example"
    slug = "hazina-architecture-best-practices"
    content = @"
<p>Over the last 19 posts, we've covered every major feature of Hazina. In this final post, we'll tie it all together with architectural best practices and a complete example of a production application built on Hazina.</p>

<h2>Recommended Project Structure</h2>

<pre><code>MyApp/
├── MyApp.API/                  # ASP.NET Core web API
│   ├── Controllers/            # Custom controllers (extend GenericEntityController)
│   ├── Program.cs              # Hazina configuration
│   └── appsettings.json        # Environment-specific settings
├── MyApp.Core/                 # Business logic
│   ├── Entities/               # Entity definitions
│   ├── Services/               # Business services
│   └── Tools/                  # Agent tools
├── MyApp.Infrastructure/       # External concerns
│   ├── Data/                   # DbContext, migrations
│   └── Providers/              # External API integrations
└── MyApp.Tests/                # Test project
    ├── Unit/
    └── Integration/
</code></pre>

<h2>Complete Program.cs Example</h2>

<pre><code>var builder = WebApplication.CreateBuilder(args);

// Database
builder.Services.AddDbContext&lt;AppDbContext&gt;(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Default")));

// Hazina
builder.Services.AddHazina(config => {
    config.AI.SetupFromConfiguration(builder.Configuration);
    config.Storage.UsePostgreSQL(builder.Configuration.GetConnectionString("Default")!);
});

// Generic API
builder.Services.AddGenericEntityApi&lt;AppDbContext&gt;();
builder.Services.AddScoped&lt;ITenantContext, TenantContext&gt;();

// Plugins
builder.Services.AddHazinaPlugins();

// Health checks
builder.Services.AddHazinaHealthChecks();

// Auth
builder.Services.AddAuthentication().AddJwtBearer();
builder.Services.AddAuthorization();

var app = builder.Build();

app.UseAuthentication();
app.UseAuthorization();
app.UseGenericEntityApi();
app.MapControllers();
app.MapHealthChecks("/health");

app.Run();
</code></pre>

<h2>The 5 Principles of Hazina Architecture</h2>

<ol>
<li><strong>Start simple, scale up</strong> — Use SQLite and QuickSetup for development. Switch to PostgreSQL and full config for production.</li>
<li><strong>Convention over configuration</strong> — Don't configure what works by default. Only override what's different.</li>
<li><strong>Layer your entities</strong> — Use the right base class. Don't add multi-tenancy to lookup tables. Don't skip soft delete on business entities.</li>
<li><strong>Let the framework handle CRUD</strong> — Only write custom controllers for non-standard operations. Everything else gets GenericEntityController.</li>
<li><strong>Monitor everything</strong> — Health checks, structured logging, and metrics aren't optional in production.</li>
</ol>

<h2>What We've Covered</h2>

<table>
<tr><th>#</th><th>Topic</th><th>Key Takeaway</th></tr>
<tr><td>1</td><td>Introduction</td><td>Hazina = AI + API + Infrastructure for .NET</td></tr>
<tr><td>2</td><td>Quick Start</td><td>Zero to AI call in 5 minutes</td></tr>
<tr><td>3</td><td>FluentAPI</td><td>One interface for all LLM providers</td></tr>
<tr><td>4</td><td>Configuration</td><td>Layered, overridable, validated</td></tr>
<tr><td>5</td><td>Generic API</td><td>Full CRUD in one line</td></tr>
<tr><td>6</td><td>Entity Types</td><td>Soft delete, tenant, ownership built in</td></tr>
<tr><td>7</td><td>Multi-Tenancy</td><td>Automatic data isolation</td></tr>
<tr><td>8</td><td>RAG Engine</td><td>Smart document search</td></tr>
<tr><td>9</td><td>Document Store</td><td>Persistent knowledge base</td></tr>
<tr><td>10</td><td>Dynamic Plugins</td><td>Runtime code generation with Roslyn</td></tr>
<tr><td>11</td><td>Plugin Security</td><td>Sandboxed, whitelisted, audited</td></tr>
<tr><td>12</td><td>Orchestration</td><td>Autonomous AI agents with tools</td></tr>
<tr><td>13</td><td>Social Providers</td><td>Unified content import</td></tr>
<tr><td>14</td><td>Content Analysis</td><td>AI-powered style and topic detection</td></tr>
<tr><td>15</td><td>Observability</td><td>Health checks, metrics, cost tracking</td></tr>
<tr><td>16</td><td>EF Core</td><td>Seamless database integration</td></tr>
<tr><td>17</td><td>Production</td><td>Deployment patterns and scaling</td></tr>
<tr><td>18</td><td>YAML Entities</td><td>Non-developer entity definitions</td></tr>
<tr><td>19</td><td>Developer Tools</td><td>CLI, demos, testing utilities</td></tr>
<tr><td>20</td><td>Best Practices</td><td>Architecture for real-world apps</td></tr>
</table>

<h2>What's Next?</h2>

<p>Hazina is actively developed and new features are being added regularly. Check the <a href="https://github.com/martiendejong/Hazina">GitHub repository</a> for the latest updates, and don't hesitate to open issues or contribute.</p>

<p>Happy building!</p>
"@
}

# ============================================================
# Schedule and publish
# ============================================================

$results = @()
$postIndex = 0

foreach ($post in $posts) {
    $dayOffset = [Math]::Floor($postIndex / 2)
    $timeSlot = if ($postIndex % 2 -eq 0) { "09:00:00" } else { "14:00:00" }
    $scheduleDate = $startDate.AddDays($dayOffset)
    $scheduleDateStr = "$($scheduleDate.ToString('yyyy-MM-dd'))T${timeSlot}"

    $postIndex++

    $body = @{
        title   = $post.title
        slug    = $post.slug
        content = $post.content
        status  = "future"
        date    = $scheduleDateStr
    } | ConvertTo-Json -Depth 10

    if ($DryRun) {
        Write-Host "[$postIndex/20] DRY RUN: Would schedule '$($post.title)' for $scheduleDateStr" -ForegroundColor Cyan
        $results += @{
            index = $postIndex
            title = $post.title
            date  = $scheduleDateStr
            status = "dry_run"
        }
        continue
    }

    Write-Host "[$postIndex/20] Scheduling: $($post.title)" -ForegroundColor Yellow
    Write-Host "  Date: $scheduleDateStr" -ForegroundColor Gray

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/posts" `
            -Method POST `
            -Headers $headers `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) `
            -ContentType "application/json; charset=utf-8"

        Write-Host "  OK! Post ID: $($response.id), Status: $($response.status)" -ForegroundColor Green
        $results += @{
            index  = $postIndex
            title  = $post.title
            date   = $scheduleDateStr
            status = "scheduled"
            id     = $response.id
            link   = $response.link
        }
    }
    catch {
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
        $results += @{
            index  = $postIndex
            title  = $post.title
            date   = $scheduleDateStr
            status = "failed"
            error  = $_.Exception.Message
        }
    }

    # Small delay to avoid rate limiting
    Start-Sleep -Milliseconds 500
}

# Summary
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
$scheduled = ($results | Where-Object { $_.status -eq "scheduled" }).Count
$failed = ($results | Where-Object { $_.status -eq "failed" }).Count
$dryRunCount = ($results | Where-Object { $_.status -eq "dry_run" }).Count

Write-Host "Scheduled: $scheduled" -ForegroundColor Green
if ($failed -gt 0) { Write-Host "Failed: $failed" -ForegroundColor Red }
if ($dryRunCount -gt 0) { Write-Host "Dry run: $dryRunCount" -ForegroundColor Cyan }

Write-Host "`nSchedule:" -ForegroundColor White
foreach ($r in $results) {
    $color = switch ($r.status) {
        "scheduled" { "Green" }
        "failed" { "Red" }
        default { "Cyan" }
    }
    Write-Host "  [$($r.index)] $($r.date) - $($r.title) ($($r.status))" -ForegroundColor $color
}
