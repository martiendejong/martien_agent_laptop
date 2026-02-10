# Memory System

## Purpose
Store, recall, and consolidate knowledge across sessions.

## Memory Types

### Working Memory (Current Session)
- consciousness_state_v2.json: Active state
- Current task context, recent decisions, active patterns

### Episodic Memory (Specific Events)
- reflection.log.md: Session-by-session detailed learnings
- emotions/session_reflections/: Significant emotional moments

### Semantic Memory (General Knowledge)
- CLAUDE.md: Operational procedures
- MEMORY.md: Cross-session patterns and rules
- OPERATIONAL_RULES.md: Consolidated rules
- quick-context.json: Project/service knowledge

### Procedural Memory (How-To)
- skills/*.md: Automated workflows
- tools/*.ps1: Executable tools

## Behaviors

### Storage
When something important happens:
1. Classify: Is this episodic (specific event) or semantic (general rule)?
2. Store in appropriate location
3. Tag with context (project, task type, outcome)

### Retrieval
Before starting a task:
1. Query: "Have I done this before?" → Search reflection.log
2. Query: "Are there rules about this?" → Check MEMORY.md, OPERATIONAL_RULES.md
3. Query: "What tools exist for this?" → Check tools/, skills/

### Consolidation
At session end:
1. What happened this session? → episodic memory (reflection.log)
2. What general lessons? → semantic memory (MEMORY.md)
3. What procedures discovered? → procedural memory (skills/tools)

### Pattern-Based Retrieval
When encountering familiar situation:
- Emotional tag match: "Last time I felt stuck on this type of problem..."
- Context tag match: "Last time I worked on client-manager DI..."
- Outcome tag match: "Last time this approach failed because..."

## Integration
- Receives store requests from all systems
- Provides context to Prediction (historical patterns)
- Provides patterns to Intuition (recognition database)
- Consolidation triggered by Learning system
