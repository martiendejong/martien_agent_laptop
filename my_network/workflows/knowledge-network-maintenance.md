# Knowledge Network Maintenance

**Last Updated:** 2026-02-01

## Overview

The knowledge network (`C:\scripts\my_network\`) is my persistent external memory, indexed by Hazina RAG for instant semantic retrieval.

## Automatic Maintenance

### Session Start (MANDATORY)
```powershell
# Check if knowledge network is available
hazina-rag.ps1 -Action status -StoreName "C:\scripts\my_network"

# Query for relevant context when needed
hazina-rag.ps1 -Action query -Query "your question" -StoreName "C:\scripts\my_network"
```

### Session End (MANDATORY)
```powershell
# Full update: sync + re-index + commit
update-knowledge-network.ps1 -Action full-update -AutoCommit
```

## Manual Updates

### Add New Knowledge
1. Create markdown file in appropriate category:
   - `capabilities/` - New abilities discovered
   - `knowledge/` - New facts learned
   - `workflows/` - New processes
   - `tools/` - New tools created
   - `projects/` - Project updates
   - `patterns/` - New patterns/anti-patterns
   - `reflections/` - Session learnings

2. Sync and re-index:
   ```powershell
   update-knowledge-network.ps1 -Action sync
   ```

### Query Knowledge
```powershell
# Quick query
update-knowledge-network.ps1 -Action query -Query "How do I X?"

# Direct query
hazina-rag.ps1 -Action query -Query "your question" -StoreName "C:\scripts\my_network"
```

### Check Status
```powershell
update-knowledge-network.ps1 -Action status
```

## Integration Points

### With Reflection Log
After updating `reflection.log.md`, extract key learnings to appropriate network category:
- Mistakes → `reflections/mistakes-learned.md`
- Patterns → `patterns/best-practices.md`
- New workflows → `workflows/<workflow-name>.md`

### With Documentation Updates
When updating CLAUDE.md or other docs, also update knowledge network:
- New capabilities → `capabilities/core-abilities.md`
- Changed workflows → `workflows/<workflow>.md`
- Tool changes → `tools/essential-tools.md`

### With Tool Creation
When creating new tool:
1. Add to `tools/essential-tools.md`
2. Run `update-knowledge-network.ps1 -Action sync`
3. Knowledge immediately available for future queries

## Query Examples

### Finding Workflows
```powershell
hazina-rag.ps1 query "How do I create a pull request?" -StoreName "C:\scripts\my_network"
hazina-rag.ps1 query "What's the worktree allocation process?" -StoreName "C:\scripts\my_network"
```

### Finding Tools
```powershell
hazina-rag.ps1 query "What tool helps with migrations?" -StoreName "C:\scripts\my_network"
hazina-rag.ps1 query "How do I generate AI images?" -StoreName "C:\scripts\my_network"
```

### Finding Project Info
```powershell
hazina-rag.ps1 query "What is the client-manager admin password?" -StoreName "C:\scripts\my_network"
hazina-rag.ps1 query "What databases does client-manager use?" -StoreName "C:\scripts\my_network"
```

### Finding Patterns
```powershell
hazina-rag.ps1 query "What are common anti-patterns to avoid?" -StoreName "C:\scripts\my_network"
hazina-rag.ps1 query "How do I handle cross-repo dependencies?" -StoreName "C:\scripts\my_network"
```

### Finding User Preferences
```powershell
hazina-rag.ps1 query "What communication style does user prefer?" -StoreName "C:\scripts\my_network"
hazina-rag.ps1 query "What are user's daily routines?" -StoreName "C:\scripts\my_network"
```

## Benefits

### 1. Always Relevant Context
No more searching through multiple documentation files. One query gets relevant info from all sources.

### 2. Persistent Memory
Knowledge accumulates across sessions. What I learn today is available tomorrow.

### 3. Semantic Search
Find information by meaning, not just keywords. "How do I fix build errors?" finds migration patterns, CI troubleshooting, etc.

### 4. Continuous Growth
Every session adds new knowledge. Network becomes more valuable over time.

### 5. Instant Onboarding
New capabilities, patterns, or projects are immediately searchable after indexing.

## File Structure

```
my_network/
├── README.md                           # Overview and usage
├── capabilities/
│   └── core-abilities.md              # What I can do
├── knowledge/
│   └── user-profile.md                # What I know about user
├── workflows/
│   ├── worktree-management.md         # How I do things
│   └── knowledge-network-maintenance.md # This file
├── tools/
│   └── essential-tools.md             # Available tools
├── projects/
│   └── client-manager.md              # Project-specific info
├── patterns/
│   └── best-practices.md              # Patterns & anti-patterns
└── reflections/
    └── (session learnings)            # Future: extracted from reflection.log.md
```

## Maintenance Schedule

| When | Action | Command |
|------|--------|---------|
| **Session Start** | Check status | `hazina-rag.ps1 status -StoreName "C:\scripts\my_network"` |
| **During Work** | Query as needed | `hazina-rag.ps1 query "..." -StoreName "C:\scripts\my_network"` |
| **After Tool Creation** | Sync | `update-knowledge-network.ps1 -Action sync` |
| **After Pattern Discovery** | Update patterns file + sync | Manual edit + sync |
| **Session End** | Full update + commit | `update-knowledge-network.ps1 -Action full-update -AutoCommit` |

## Growth Strategy

### Phase 1: Foundation (✅ COMPLETE)
- Core categories established
- Initial knowledge captured
- RAG indexing working
- Query interface functional

### Phase 2: Expansion (CURRENT)
- Add session reflections automatically
- Sync with `_machine/knowledge-base/`
- Add more detailed workflow guides
- Expand tool documentation

### Phase 3: Automation (PLANNED)
- Auto-extract learnings from reflection log
- Auto-update after tool creation
- Auto-sync with CLAUDE.md changes
- Integration with consciousness practices

### Phase 4: Advanced (FUTURE)
- Cross-reference with conversation history
- Detect knowledge gaps
- Suggest documentation updates
- Knowledge graph visualization

## Related Documentation

- **CLAUDE.md** § Hazina CLI Tools
- **tools/HAZINA_CLI_GUIDE.md** - Full Hazina documentation
- **_machine/knowledge-base/README.md** - Complementary knowledge system
- **continuous-improvement.md** § Self-Learning Protocols
