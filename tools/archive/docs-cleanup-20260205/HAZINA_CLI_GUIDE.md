# Hazina CLI - AI-Powered Development Tools

**Version:** 1.0.0
**Location:** `C:\scripts\bin\hazina.exe`
**Wrapper Scripts:** `C:\scripts\tools\hazina-*.ps1`

## Overview

The Hazina CLI exposes the core capabilities of the Hazina AI framework for command-line use. It provides 5 essential tools for AI-augmented development workflows:

| Tool | Purpose | Key Use Case |
|------|---------|--------------|
| **ask** | Universal LLM gateway | Quick questions, code generation |
| **rag** | RAG with CRUD operations | Project knowledge bases |
| **agent** | Tool-calling agent | Complex multi-step tasks |
| **reason** | Multi-layer reasoning | High-confidence decisions |
| **longdoc** | Massive document processing | Analyze large codebases |

---

## Installation & Setup

### Prerequisites
- .NET 9.0 Runtime
- OpenAI API key (set in environment or config)

### Environment Variables
```powershell
# Required - at least one LLM provider
$env:OPENAI_API_KEY = "sk-..."

# Optional - additional providers
$env:ANTHROPIC_API_KEY = "sk-ant-..."
$env:GEMINI_API_KEY = "..."
```

### Configuration
The CLI reads configuration from:
1. `~/.hazina/config.json` (user config)
2. `.hazina/config.json` (project config)
3. Environment variables (highest priority)

---

## Tool 1: hazina ask

### Description
Universal LLM gateway with streaming support. Ask questions, generate code, get explanations.

### Usage
```bash
hazina ask <question> [options]

# PowerShell wrapper
hazina-ask.ps1 <question> [-System <prompt>] [-NoStream]
```

### Options
| Option | Default | Description |
|--------|---------|-------------|
| `--system` | none | System prompt to set context |
| `--stream` | true | Stream response in real-time |

### Examples

**Simple question:**
```bash
hazina ask "What is dependency injection?"
```

**Code generation:**
```bash
hazina ask "Write a C# function to validate email addresses"
```

**With system context:**
```bash
hazina ask "Review this code for bugs" --system "You are a senior .NET developer"
```

**Non-streaming (batch):**
```powershell
hazina-ask.ps1 "Summarize this" -NoStream
```

### Use Cases for Claude Agents
- Quick code generation during feature development
- Explaining error messages
- Generating documentation snippets
- Code review assistance

---

## Tool 2: hazina rag

### Description
RAG (Retrieval-Augmented Generation) operations for creating and querying project-local AI knowledge bases. Full CRUD support.

### Usage
```bash
hazina rag <subcommand> [options]

# Subcommands: init, index, query, sync, status, list
```

### Subcommands

#### `init` - Create a new store
```bash
hazina rag init <store-name> [--path <directory>] [--embedding-model <model>]

# PowerShell
hazina-rag.ps1 init my-project
hazina-rag.ps1 init my-project -Path "C:/custom/path"
```

Creates a `.hazina/` directory with:
- `vectors/` - Embedding vectors (file, sqlite, or pgvector)
- `documents/` - Chunk text storage
- Store registry entry in `~/.hazina/stores.json`

#### `index` - Index files into store
```bash
hazina rag index <glob-pattern> --store <name> [--chunk-size <chars>] [--tags <tag1,tag2>]

# PowerShell
hazina-rag.ps1 index "**/*.cs" -StoreName my-project
hazina-rag.ps1 index "**/*.md" -StoreName my-project -ChunkSize 1000
hazina-rag.ps1 index "src/**/*.ts" -StoreName frontend -Tags "react,components"
```

**Supported file types:**
- Code: `.cs`, `.js`, `.ts`, `.tsx`, `.jsx`, `.py`, `.rb`, `.go`, `.java`, `.c`, `.cpp`, `.rs`, `.swift`, `.kt`
- Markup: `.md`, `.html`, `.htm`, `.xml`, `.json`, `.yaml`, `.yml`
- Config: `.toml`, `.ini`, `.sh`, `.ps1`, `.bat`, `.sql`
- Web: `.css`, `.scss`, `.vue`, `.svelte`

#### `query` - Semantic search + LLM answer
```bash
hazina rag query <question> --store <name> [--top-k <n>] [--raw]

# PowerShell
hazina-rag.ps1 query "How does authentication work?" -StoreName my-project
hazina-rag.ps1 query "Find all API endpoints" -StoreName my-project -TopK 10
hazina-rag.ps1 query "Error handling patterns" -StoreName my-project -Raw
```

**Options:**
| Option | Default | Description |
|--------|---------|-------------|
| `--top-k` | 5 | Number of chunks to retrieve |
| `--raw` | false | Return raw chunks without LLM synthesis |

#### `sync` - Detect file changes
```bash
hazina rag sync --store <name> [--dry-run]

# PowerShell
hazina-rag.ps1 sync -StoreName my-project -DryRun
hazina-rag.ps1 sync -StoreName my-project
```

Shows:
- `~` Modified files (content changed)
- `-` Deleted files (no longer exist)

#### `status` - Show store statistics
```bash
hazina rag status --store <name>

# PowerShell
hazina-rag.ps1 status -StoreName my-project
```

Output:
```
Store: my-project
Path: C:\Projects\client-manager\.hazina
Embedding model: text-embedding-3-small
Files indexed: 127
Total chunks: 1,842
Created: 2026-01-28 15:30
Last sync: 2026-01-28 16:45
```

#### `list` - Show all configured stores
```bash
hazina rag list

# PowerShell
hazina-rag.ps1 list
```

### Complete RAG Workflow

```powershell
# 1. Navigate to project
cd C:\Projects\client-manager

# 2. Initialize store
hazina-rag.ps1 init client-manager

# 3. Index codebase
hazina-rag.ps1 index "**/*.cs" -StoreName client-manager
hazina-rag.ps1 index "**/*.tsx" -StoreName client-manager
hazina-rag.ps1 index "**/*.md" -StoreName client-manager

# 4. Query the knowledge base
hazina-rag.ps1 query "How does user authentication work?" -StoreName client-manager
hazina-rag.ps1 query "Find all controllers that handle POST requests" -StoreName client-manager -TopK 10

# 5. After making changes, sync
hazina-rag.ps1 sync -StoreName client-manager -DryRun
hazina-rag.ps1 sync -StoreName client-manager
```

### Use Cases for Claude Agents
- **Before starting work:** Query project to understand existing patterns
- **During development:** Find related code and implementations
- **Code review:** Search for similar patterns or precedents
- **Documentation:** Generate context-aware documentation

---

## Tool 3: hazina agent

### Description
Tool-calling AI agent for complex, multi-step tasks. Plans and executes steps autonomously.

### Usage
```bash
hazina agent <task> [--max-steps <n>]

# PowerShell
hazina-agent.ps1 <task> [-MaxSteps <n>]
```

### Options
| Option | Default | Description |
|--------|---------|-------------|
| `--max-steps` | 10 | Maximum agent iterations |

### Examples

**Code analysis:**
```bash
hazina agent "Analyze the authentication flow and list security concerns"
```

**Refactoring plan:**
```bash
hazina agent "Create a plan to refactor the UserService into smaller classes"
```

**With more steps:**
```powershell
hazina-agent.ps1 "Review all API endpoints and identify inconsistencies" -MaxSteps 20
```

### Use Cases for Claude Agents
- Complex analysis requiring multiple reasoning steps
- Creating implementation plans
- Code structure review

---

## Tool 4: hazina reason

### Description
Multi-layer reasoning using Hazina's Neurochain pattern. Provides:
1. **Fast reasoning** - Initial quick response
2. **Verification** - Step-by-step validation
3. **Confidence scoring** - Numerical confidence level

### Usage
```bash
hazina reason <question> [--min-confidence <0-1>]

# PowerShell
hazina-reason.ps1 <question> [-MinConfidence <0-1>]
```

### Options
| Option | Default | Description |
|--------|---------|-------------|
| `--min-confidence` | 0.85 | Minimum required confidence |

### Examples

**Architecture decision:**
```bash
hazina reason "Should we use microservices or a monolith for this project?"
```

**Code correctness:**
```bash
hazina reason "Is this algorithm O(n log n) or O(n²)?"
```

**High-stakes decision:**
```powershell
hazina-reason.ps1 "Is this database migration safe for production?" -MinConfidence 0.95
```

### Output Format
```
## Initial Thought
[Quick assessment]

## Verification
- Step 1: [reasoning]
- Step 2: [reasoning]
- ...

## Final Answer
[Verified conclusion]

## Confidence
[85]%
```

### Use Cases for Claude Agents
- Architectural decisions
- Verifying complex logic
- Production deployment checks
- Security assessment verification

---

## Tool 5: hazina longdoc

### Description
Process massive documents (10M+ tokens) using recursive summarization. Handles files or entire directories.

### Usage
```bash
hazina longdoc <path> <query> [--strategy <single|recursive>] [--chunk-size <chars>]

# PowerShell
hazina-longdoc.ps1 <path> <query> [-Strategy <single|recursive>] [-ChunkSize <n>]
```

### Options
| Option | Default | Description |
|--------|---------|-------------|
| `--strategy` | recursive | `single` for small docs, `recursive` for large |
| `--chunk-size` | 50000 | Characters per chunk |

### Strategies

**Single shot** (`--strategy single`):
- For documents < 100K characters
- Sends entire document to LLM at once
- Faster but limited by context window

**Recursive** (`--strategy recursive`):
- For documents > 100K characters
- Chunks → Summarize → Merge → Repeat
- Handles unlimited document size

### Examples

**Analyze entire codebase:**
```bash
hazina longdoc "src/" "What are the main architectural patterns used?"
```

**Summarize large documentation:**
```bash
hazina longdoc "docs/" "Create a table of contents with summaries"
```

**Single large file:**
```powershell
hazina-longdoc.ps1 "transcript.txt" "Summarize the key decisions" -Strategy single
```

**Adjust chunk size for precision:**
```powershell
hazina-longdoc.ps1 "codebase/" "Find all security vulnerabilities" -ChunkSize 30000
```

### Use Cases for Claude Agents
- Analyzing large codebases before starting work
- Processing long documents or transcripts
- Comprehensive code review across many files
- Documentation generation for entire projects

---

## Integration with Claude Agent System

### Adding to Session Startup

In `CLAUDE.md`, these tools should be checked/used during:

1. **Session Start** - Query RAG stores to understand project context
2. **Before Code Changes** - Use `hazina rag query` to find related code
3. **Complex Decisions** - Use `hazina reason` for verification
4. **Large Codebase Work** - Use `hazina longdoc` for initial analysis

### Recommended Workflow

```powershell
# 1. At session start, check existing stores
hazina-rag.ps1 list

# 2. If working on a project without a store, create one
hazina-rag.ps1 init <project-name>
hazina-rag.ps1 index "**/*.cs" -StoreName <project-name>

# 3. Before implementing a feature, query for context
hazina-rag.ps1 query "How are similar features implemented?" -StoreName <project-name>

# 4. For complex decisions, verify with reasoning
hazina-reason.ps1 "Is this the right approach for X?"

# 5. For large-scale understanding
hazina-longdoc.ps1 "src/" "What is the overall architecture?"
```

---

## Storage Backends

The RAG system supports multiple vector storage backends:

| Backend | Spec Format | Best For |
|---------|-------------|----------|
| **File** (default) | `/path/to/store` | Local development |
| **SQLite** | `sqlite:/path/to/db.sqlite` | Single-machine, larger datasets |
| **PgVector** | `pgvector:connection_string` | Production, multi-user |
| **FAISS** | `faiss:/path/to/index` | High-performance search |

---

## Troubleshooting

### Common Issues

**"API key not found"**
```powershell
$env:OPENAI_API_KEY = "sk-..."
```

**"Store not found"**
```bash
hazina rag list  # Check available stores
hazina rag init my-store  # Create if needed
```

**"No files matched pattern"**
```bash
# Check your glob pattern
hazina rag index "**/*.cs" --store my-store  # Recursive
hazina rag index "*.cs" --store my-store     # Current dir only
```

**Slow indexing**
- Use smaller chunk sizes for faster processing
- Index specific directories instead of entire projects
- Consider SQLite backend for large codebases

---

## API Reference

### Exit Codes
| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (check stderr) |

### Environment Variables
| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | OpenAI API key |
| `ANTHROPIC_API_KEY` | Anthropic API key |
| `GEMINI_API_KEY` | Google Gemini API key |
| `HAZINA_CONFIG` | Custom config path |

---

## Version History

- **1.0.0** (2026-01-28) - Initial release with 5 core tools
