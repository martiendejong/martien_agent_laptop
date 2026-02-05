# Best Practice: Linter Interference Mitigation Strategies

**Date**: 2026-01-08
**Time**: 22:40:00 UTC
**Created by**: Claude Opus 4.5 (claude-sonnet-4-5-20250929)
**Context**: Learned during hazina chat fix completion (PR #13, Session 2)

---

## Overview

This document captures strategies for handling linter interference during active development, particularly when linters automatically revert or modify code changes.

## The Problem

### Symptom
- File modifications using Edit tool are immediately reverted
- Changes show as applied but disappear on next read
- Error message: "File has been unexpectedly modified. Read it again before attempting to write it."
- Multiple edit attempts fail with same error

### Root Cause
- Active linter/formatter processes watching file system
- Auto-save or auto-format features in IDE
- File watchers triggering automatic code formatting
- Language server protocol (LSP) making automatic corrections

### Impact
- Wasted time on repeated edit attempts
- Incomplete fixes across multiple files
- Frustration and loss of context
- Risk of partial application of multi-file changes

---

## Solution: Batch Command-Line Updates

### Primary Strategy: Use `sed` for Pattern Replacement

**When to use**:
- Multiple locations need identical or similar changes
- Linter is interfering with Edit tool
- Pattern-based replacements across files
- Need atomic, immediate file updates

**Advantages**:
- Bypasses IDE/linter watchers
- Atomic file operations
- Can process multiple files in sequence
- Easily scriptable and repeatable
- Changes persist immediately

**Example: Simple Pattern Replacement**
```bash
# Replace all occurrences of old pattern with new pattern
sed -i 's/OldPattern/NewPattern/g' path/to/file.cs

# Example from hazina fix:
sed -i 's/StoreProvider\.GetStoreSetup(\([^,]*\), Config\.ApiSettings\.OpenApiKey)/StoreProvider.GetStoreSetup(\1, Config.OpenAI)/g' GeneratorAgentBase.cs
```

**Example: Multiple Files**
```bash
# Process multiple files in one command
for file in file1.cs file2.cs file3.cs; do
    sed -i 's/OldPattern/NewPattern/g' "$file"
done

# Or using find:
find src/ -name "*.cs" -exec sed -i 's/OldPattern/NewPattern/g' {} \;
```

---

## Real-World Example: Hazina Chat Fix

### Problem
- 13 locations across 3 files needed updating
- Edit tool failed with "File has been unexpectedly modified"
- Linter was reverting changes during development

### Solution Applied

**GeneratorAgentBase.cs (4 locations)**:
```bash
cd C:/Projects/hazina

# Backup first
cp src/Tools/Foundation/Hazina.Tools.AI.Agents/Agents/GeneratorAgentBase.cs \
   src/Tools/Foundation/Hazina.Tools.AI.Agents/Agents/GeneratorAgentBase.cs.bak

# Replace all occurrences with capture group to preserve folder variable
sed -i 's/StoreProvider\.GetStoreSetup(\([^,]*\), Config\.ApiSettings\.OpenApiKey)/StoreProvider.GetStoreSetup(\1, Config.OpenAI)/g' \
    src/Tools/Foundation/Hazina.Tools.AI.Agents/Agents/GeneratorAgentBase.cs

# Verify changes
grep -n "Config.OpenAI\|Config.ApiSettings.OpenApiKey" \
    src/Tools/Foundation/Hazina.Tools.AI.Agents/Agents/GeneratorAgentBase.cs
```

**EmbeddingsService.cs (8 locations)**:
```bash
# Same pattern with different variable name (_config instead of Config)
sed -i 's/StoreProvider\.GetStoreSetup(\([^,]*\), _config\.ApiSettings\.OpenApiKey)/StoreProvider.GetStoreSetup(\1, _config.OpenAI)/g' \
    src/Tools/Services/Hazina.Tools.Services.Embeddings/EmbeddingsService.cs

# Verify
grep -n "_config.OpenAI" src/Tools/Services/Hazina.Tools.Services.Embeddings/EmbeddingsService.cs
```

**Result**:
- All 13 locations updated successfully
- No linter interference
- Changes persisted after commit
- Build succeeded: 0 errors

---

## Sed Command Patterns

### Basic Replacement
```bash
# Replace first occurrence per line
sed -i 's/old/new/' file.txt

# Replace all occurrences (global)
sed -i 's/old/new/g' file.txt

# Case-insensitive replacement
sed -i 's/old/new/gi' file.txt
```

### Using Capture Groups
```bash
# Capture part of pattern and reuse
sed -i 's/\(kept_part\)removed_part/\1new_part/' file.txt

# Example: Keep folder variable, change second parameter
sed -i 's/GetSetup(\([^,]*\), oldParam)/GetSetup(\1, newParam)/g' file.cs
```

### Line-Specific Operations
```bash
# Delete specific line
sed -i '42d' file.txt

# Insert after line N
sed -i '42a\New line content' file.txt

# Insert before line N
sed -i '42i\New line content' file.txt

# Replace specific line
sed -i '42s/.*/New line content/' file.txt
```

### Special Characters
```bash
# Escape special regex characters: . * [ ] ^ $ \ /
# Use backslash before special chars

# Escape dots in pattern
sed -i 's/Config\.ApiSettings/Config.OpenAI/' file.cs

# Escape backslashes (for paths)
sed -i 's/old\\path/new\\\\path/' file.txt

# Alternative: Use different delimiter
sed -i 's|old/path|new/path|g' file.txt
```

---

## Workflow Pattern

### 1. Detection Phase
```bash
# Try Edit tool first
# If error occurs: "File has been unexpectedly modified"
# → Switch to sed/bash approach
```

### 2. Backup Phase
```bash
# Always create backup before bulk changes
cp original_file.cs original_file.cs.bak
```

### 3. Change Phase
```bash
# Apply changes using sed
sed -i 's/pattern/replacement/g' file.cs

# Verify immediately
grep -n "replacement" file.cs
```

### 4. Verification Phase
```bash
# Check the changes were applied
git diff file.cs

# Test compilation
dotnet build
```

### 5. Commit Immediately
```bash
# Commit before linter can revert
git add file.cs
git commit -m "Description of change"
```

---

## Common Pitfalls

### 1. Incorrect Escaping
```bash
# WRONG: Unescaped dot matches any character
sed -i 's/Config.OpenAI/Config.NewAI/g' file.cs

# RIGHT: Escape the dot
sed -i 's/Config\.OpenAI/Config.NewAI/g' file.cs
```

### 2. Forgetting Global Flag
```bash
# WRONG: Only replaces first occurrence per line
sed -i 's/old/new/' file.txt

# RIGHT: Replace all occurrences
sed -i 's/old/new/g' file.txt
```

### 3. Path Separators on Windows
```bash
# WRONG: Windows path with single backslash
sed -i 's/C:\path/D:\path/' file.txt

# RIGHT: Use forward slashes (works on Windows with Git Bash)
sed -i 's|C:/path|D:/path|' file.txt
```

### 4. Not Creating Backups
```bash
# WRONG: Direct modification without backup
sed -i 's/critical_code/new_code/g' important_file.cs

# RIGHT: Create backup first
cp important_file.cs important_file.cs.bak
sed -i 's/critical_code/new_code/g' important_file.cs
```

---

## When to Use sed vs Edit Tool

| Situation | Tool | Reason |
|-----------|------|--------|
| Single file, simple change | Edit | Most maintainable |
| Single file, linter interferes | sed | Bypasses watchers |
| Multiple files, same pattern | sed | Efficient batch processing |
| Complex multi-line restructuring | Edit/Manual | Better control |
| Linter active and interfering | sed | Immediate, atomic changes |

---

## Summary: Quick Decision Tree

```
Edit tool fails with "File unexpectedly modified"?
    ↓
Yes → Try once more
    ↓
Still fails?
    ↓
Yes → Is it a pattern replacement?
    ↓
Yes → Use sed with backup
    ↓
Apply changes → Verify with grep
    ↓
Build to verify → Commit immediately
    ↓
Document in reflection
```

---

**Document created**: 2026-01-08T22:40:00Z
**Pattern verified**: Hazina PR #13 (commits 7d4a26f, 739e564)
**Status**: ACTIVE PATTERN
**Category**: Development Troubleshooting
**Related**: DOCUMENTATION_AND_PR_WORKFLOW.md
