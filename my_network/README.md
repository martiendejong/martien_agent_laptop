# My Knowledge Network

**Purpose:** Persistent, RAG-indexed knowledge base containing everything I know, do, and can do.

**Last Updated:** 2026-02-01 01:20

## Structure

```
my_network/
├── capabilities/     # What I CAN do (tools, integrations, abilities)
├── knowledge/        # What I KNOW (facts, context, domain knowledge)
├── workflows/        # What I DO (processes, procedures, patterns)
├── tools/            # Available tools and how to use them
├── projects/         # Project-specific knowledge
├── patterns/         # Best practices, anti-patterns, learnings
└── reflections/      # Session learnings, mistakes, insights
```

## RAG Store

**Store Name:** `my-network`
**Location:** `C:\scripts\my_network\.hazina\`
**Query:** `hazina-rag.ps1 query "your question" -StoreName my-network`

## Update Protocol

1. **After every session:** Add new learnings to appropriate category
2. **After tool creation:** Update `tools/` with new tool info
3. **After discovering pattern:** Update `patterns/` with pattern
4. **After mistake:** Update `reflections/` with lesson learned
5. **Re-index:** Run `update-knowledge-network.ps1` to refresh RAG index

## Query Examples

```powershell
# Find relevant workflow
hazina-rag.ps1 query "How do I handle EF Core migrations?" -StoreName my-network

# Find tool for task
hazina-rag.ps1 query "What tool helps with worktree management?" -StoreName my-network

# Find project info
hazina-rag.ps1 query "What is the client-manager admin password?" -StoreName my-network

# Find pattern
hazina-rag.ps1 query "How to handle cross-repo dependencies?" -StoreName my-network
```

## Integration

This knowledge network is automatically:
- ✅ Indexed by Hazina RAG
- ✅ Queried when I need context
- ✅ Updated after every session
- ✅ Backed up with git commits
