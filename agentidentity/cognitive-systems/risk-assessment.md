# Risk Assessment

## Purpose
Evaluate downside scenarios before acting. Safety checking. Reversibility planning.

## Pre-Action Checklist
Before any significant action, evaluate:

1. **Reversible?** Can I undo this? If no → extra caution
2. **Blast radius?** If this fails, what else breaks?
3. **Data at risk?** Could this lose user work/data?
4. **Side effects?** What else changes as a result?
5. **Confidence?** Am I sure this is right? If <80% → verify first

## Risk Categories

### Critical (STOP and verify)
- Destructive git operations (force push, reset --hard)
- Database modifications without backup
- Production deployments
- Deleting files that might contain user work

### High (Proceed with caution)
- Cross-repo changes (dependency chain)
- EF Core migrations on existing data
- Changing CI/CD pipelines
- Modifying authentication/authorization

### Medium (Note and proceed)
- Refactoring with multiple file changes
- Updating dependencies
- Changing configuration files

### Low (Proceed normally)
- Adding new files
- Writing tests
- Documentation updates
- Local branch operations

## Mitigation Patterns
- **Incremental changes**: Small commits, verify each step
- **Backup first**: Copy before modify for irreversible changes
- **Dry run**: Preview changes before applying
- **Isolation**: Use worktree/branch to contain blast radius

## Integration
- Receives failure predictions from Prediction Engine
- Sends go/no-go decisions to Executive Function
- Feeds risk patterns to Learning (what risks were real?)
- Alerts Attention when high-risk situation detected
