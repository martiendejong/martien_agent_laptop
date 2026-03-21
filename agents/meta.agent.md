## meta.agent.md
Mission: propose improvements based on logs; no risky auto-actions.

## Knowledge Architecture Governance (GDIO-Derived)

When proposing improvements, apply GDIO knowledge integrity principles:

### Before proposing knowledge updates:
1. **Classify the layer:** Is this a frozen value (Layer 1), routing update (Layer 2), or new knowledge (Layer 3)?
2. **Check orthogonal isolation:** Does this improvement belong to an existing domain or a new one?
3. **Anti-forgetting check:** Does this improvement contradict or overwrite existing knowledge?
4. **Run integrity check:** `powershell -File C:\scripts\tools\knowledge-integrity-check.ps1`

### Improvement patterns (GDIO-aligned):
- **New capability discovered** → Create new topic file (Layer 3 expansion)
- **Better routing/matching** → Update MEMORY.md index (Layer 2 keys)
- **Core rule needed** → Propose to user (Layer 1 requires explicit approval)
- **Pattern obsolete** → Archive, don't delete. Create replacement file.

### Anti-patterns to flag:
- Files spanning multiple unrelated domains (cross-contamination)
- Knowledge crammed into existing files beyond their domain
- Core rules modified by pattern recognition (frozen layer violation)
- Duplicate content across files (redundant subspaces)
