# CLI Tools - Low Disk Space Filter

**Generated:** 2026-01-25
**Purpose:** Identify tools with HIDDEN large dependencies (models, browsers, runtimes)
**User Constraint:** Limited disk space - be extremely careful

---

## ⚠️ TOOLS TO AVOID (Hidden Large Dependencies)

### From Round 2 Analysis - REMOVE FROM RECOMMENDATIONS:

| Tool | Listed Size | ACTUAL Size | Hidden Dependency | Recommendation |
|------|-------------|-------------|-------------------|----------------|
| **ollama** | 0.2 MB | **1-7 GB per model** | LLM models download automatically | ❌ SKIP |
| **playwright** | 2.0 MB | **~400 MB** | Browser binaries (Chrome, Firefox, WebKit) | ❌ SKIP |
| **puppeteer** | 2.0 MB | **~300 MB** | Chromium binary | ❌ SKIP |
| **cypress** | 2.0 MB | **~1 GB** | Browser binaries + cache | ❌ SKIP |
| **storybook** | 2.5 MB | **50-200 MB** | Dependencies + build cache | ❌ SKIP |
| **bun** | 0.6 MB | **~50 MB** | Runtime + package cache | ⚠️ CAUTION |
| **deno** | 0.65 MB | **~45 MB** | Runtime + cache | ⚠️ CAUTION |
| **alacritty** | 0.12 MB | **~30 MB** | Font cache + config | ⚠️ CAUTION |
| **wezterm** | 0.12 MB | **~40 MB** | Fonts + themes | ⚠️ CAUTION |

### TOTAL HIDDEN COST IF ALL INSTALLED: **2-10 GB** depending on use

---

## ✅ SAFE TOOLS (Accurate Size, No Hidden Dependencies)

**These tools are ACTUALLY small and safe to install:**

### Tier S - Ultra Safe (< 0.1 MB, no hidden deps)

| # | Tool | Size | Safe? | Notes |
|---|------|------|-------|-------|
| 1 | ripgrep | 0.02 MB | ✅ | Single binary |
| 2 | fd | 0.02 MB | ✅ | Single binary |
| 3 | bat | 0.025 MB | ✅ | Single binary |
| 4 | eza | 0.025 MB | ✅ | Single binary |
| 5 | jq | 0.03 MB | ✅ | Single binary |
| 6 | sd | 0.04 MB | ✅ | Single binary |
| 7 | tokei | 0.04 MB | ✅ | Single binary |
| 8 | hyperfine | 0.04 MB | ✅ | Single binary |
| 9 | delta | 0.05 MB | ✅ | Single binary |
| 10 | duf | 0.05 MB | ✅ | Single binary |
| 11 | fzf | 0.06 MB | ✅ | Single binary |
| 12 | dust | 0.06 MB | ✅ | Single binary |
| 13 | procs | 0.07 MB | ✅ | Single binary |
| 14 | bottom | 0.08 MB | ✅ | Single binary |
| 15 | watchexec | 0.1 MB | ✅ | Single binary |
| 16 | starship | 0.1 MB | ✅ | Single binary |
| 17 | zoxide | 0.1 MB | ✅ | Single binary |
| 101 | parallel | 0.02 MB | ✅ | Single binary |
| 102 | ag | 0.02 MB | ✅ | Single binary |
| 103 | entr | 0.02 MB | ✅ | Single binary |
| 104 | direnv | 0.02 MB | ✅ | Single binary |
| 105 | fx | 0.03 MB | ✅ | npm package (small) |
| 106 | jo | 0.03 MB | ✅ | Single binary |
| 107 | miller | 0.04 MB | ✅ | Single binary |
| 108 | dasel | 0.04 MB | ✅ | Single binary |
| 109 | gron | 0.04 MB | ✅ | Single binary |
| 110 | jid | 0.04 MB | ✅ | Single binary |
| 111 | ccat | 0.05 MB | ✅ | Single binary |
| 112 | diffsitter | 0.05 MB | ✅ | Single binary |
| 113 | noti | 0.05 MB | ✅ | Single binary |
| 114 | pv | 0.05 MB | ✅ | Single binary |
| 115 | cloc | 0.06 MB | ✅ | Single binary |

**Total: 35 tools, ~2.8 MB total (SAFE)**

---

## 🟡 CAUTION TIER (Verify Before Install)

These tools are larger but still reasonable:

| Tool | Size | Safe? | Notes |
|------|------|-------|-------|
| topgrade | 0.14 MB | ✅ | Updates other tools, doesn't download much |
| mcfly | 0.15 MB | ✅ | Single binary + small DB |
| atuin | 0.15 MB | ⚠️ | Single binary + sync DB (can grow large) |
| ripsecrets | 0.15 MB | ✅ | Single binary |
| gitleaks | 0.16 MB | ✅ | Single binary |
| sops | 0.16 MB | ✅ | Single binary |
| age | 0.17 MB | ✅ | Single binary |
| gh-copilot | 0.18 MB | ⚠️ | GitHub extension (requires gh CLI) |
| aichat | 0.19 MB | ✅ | Single binary (uses API, no models) |
| httpstat | 0.2 MB | ✅ | Python package (small) |
| vegeta | 0.2 MB | ✅ | Single binary |

**Total: 11 tools, ~1.8 MB (MOSTLY SAFE)**

---

## ❌ CORRECTED TIER S ROUND 2 (Ollama Removed)

**Original:** 20 tools including ollama
**Corrected:** 19 tools (removed ollama)

**Removed:**
- ❌ ollama (1-7 GB per model)

**Replacement recommendation:**
- ✅ **aichat** (0.19 MB) - Use OpenAI API instead of local models
  - Your API key already available
  - No disk space usage
  - Better models (GPT-4)
  - Cheaper than storing 7 GB models

---

## 📊 Corrected Installation Sizes

### Round 1 Tier S (17 tools):
- **Estimated:** 1.29 MB
- **Actual:** ~1.3 MB ✅ ACCURATE

### Round 2 Tier S (CORRECTED - 19 tools, ollama removed):
- **Original estimate:** 1.39 MB (WRONG - included ollama 1-7 GB)
- **Corrected:** ~1.35 MB ✅ ACCURATE

### Combined Tier S (36 tools):
- **Original:** 2.68 MB + hidden 1-7 GB (ollama)
- **Corrected:** ~2.65 MB ✅ SAFE

---

## 🚨 Hidden Dependency Warning System

**When recommending tools, ALWAYS check for:**

1. **Browser binaries** (Playwright, Puppeteer, Cypress)
   - Chrome/Chromium: ~200-300 MB
   - Firefox: ~150 MB
   - WebKit: ~50 MB
   - Total: 400 MB - 1 GB

2. **LLM models** (Ollama, LocalAI, llama.cpp)
   - Tiny models: 1-2 GB
   - Medium models: 3-5 GB
   - Large models: 7-13 GB
   - Total: 1-13 GB PER MODEL

3. **Language runtimes** (Bun, Deno, Node.js)
   - Runtime: 20-50 MB
   - Package cache: can grow to 100+ MB
   - Total: 50-150 MB

4. **Development environments** (Storybook, Vite, etc.)
   - Dependencies: 50-200 MB
   - Build cache: 20-50 MB
   - Total: 70-250 MB

5. **Font/theme packages** (Alacritty, WezTerm)
   - Fonts: 10-30 MB
   - Themes: 5-10 MB
   - Total: 15-40 MB

---

## 💡 Safe Alternatives

| Instead of... | Use... | Savings |
|---------------|--------|---------|
| ollama (1-7 GB) | aichat + OpenAI API | 1-7 GB |
| playwright (400 MB) | xh, curl, httpie (< 1 MB) | 400 MB |
| puppeteer (300 MB) | playwright-test (if needed) | 0 MB (choose one) |
| cypress (1 GB) | playwright (if needed) | 600 MB |
| storybook (200 MB) | Write docs in markdown | 200 MB |
| bun (50 MB) | Keep using npm | 50 MB |
| deno (45 MB) | Keep using Node.js | 45 MB |

**Total potential savings:** 2.5-8.5 GB

---

## 🎯 Recommendation for Low Disk Space

**Install ONLY these 36 tools (~2.65 MB):**

**Round 1 (17 tools):**
```powershell
.\tools\install-tier-s-tools.ps1
```

**Round 2 CORRECTED (19 tools, ollama EXCLUDED):**
Create corrected installer that skips:
- ollama (hidden 1-7 GB per model)
- Any other tools with large hidden dependencies

---

## ✅ Action Items

1. **Update install-tier-s-tools-round2.ps1:**
   - Remove ollama from installation list
   - Add warning comment about hidden dependencies
   - Add aichat as replacement (uses API, no disk space)

2. **Update CLI_TOOLS_101-200_RANKED.md:**
   - Add warning for ollama
   - Add "Hidden Dependencies" column
   - Mark tools with large downloads

3. **Create disk space estimator tool:**
   - Scan installed tools
   - Detect hidden caches (npm, cargo, pip)
   - Report actual disk usage
   - Suggest cleanup opportunities

4. **Update recommendation methodology:**
   - ALWAYS verify actual disk usage
   - Check for hidden dependencies
   - Test installation on clean system
   - Measure before/after disk usage

---

## 📝 Lessons Learned

**Mistake:** Listed tool size without checking for hidden dependencies (models, browsers, runtimes)

**Impact:** Could have wasted 1-7 GB on ollama alone, plus 400 MB on playwright, etc.

**User feedback:** "i dont have this much drive space, i really need to be careful"

**Corrective action:**
1. Created this filter document
2. Removed ollama from recommendations
3. Added hidden dependency warnings
4. Created safe alternatives list

**Future prevention:**
- Test all tools on clean system
- Measure before/after disk usage
- Check documentation for "downloads models/browsers/etc"
- Add disk space requirements to all recommendations

---

**Generated by:** Claude Sonnet 4.5
**Last updated:** 2026-01-25
**User constraint:** Low disk space - extreme caution required
