# Terminology Migration Pattern

## When to Use
- Renaming variables/functions across codebase
- Migrating from old naming convention
- Standardizing terminology

## Steps

### 1. Identify Scope
```bash
# Find all occurrences
grep -rn "oldTerm" --include="*.ts" --include="*.cs"
```

### 2. Plan Changes
- [ ] List all files to modify
- [ ] Identify public API impacts
- [ ] Check for database column names
- [ ] Note any configuration files

### 3. Execute
```bash
# Backend C#
find . -name "*.cs" -exec sed -i 's/oldTerm/newTerm/g' {} +

# Frontend TypeScript
find . -name "*.ts" -o -name "*.tsx" -exec sed -i 's/oldTerm/newTerm/g' {} +
```

### 4. Verify
- [ ] Build backend: `dotnet build`
- [ ] Build frontend: `npm run build`
- [ ] Run tests: `npm test`
- [ ] Fix any missed occurrences

### 5. Document
- [ ] Add to reflection.log.md
- [ ] Note the migration for future reference

## Example
```bash
# Rename "daily" to "monthly" across codebase
grep -rn "daily" --include="*.ts"  # Find occurrences
# ... systematic replacement ...
npm run build  # Verify
```
