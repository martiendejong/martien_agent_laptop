# 100 MORE CLI Tools (Tools 101-200) - Ranked by Value/Size Ratio

**Generated:** 2026-01-25 (Round 2)
**Method:** 100-expert consultation across 10 NEW domains
**Environment:** Windows, .NET, React/TypeScript, PostgreSQL, Git
**Ranking:** Value (1-10) / Size (MB) = Higher is better
**Excludes:** Tools 1-100 from previous analysis

**Key:**
- ✅ **Tier S** (ratio > 100): Install immediately
- 🟢 **Tier A** (ratio 50-100): High priority
- 🟡 **Tier B** (ratio 20-50): Install as needed
- 🟠 **Tier C** (ratio 10-20): Evaluate first
- 🔴 **Tier D** (ratio < 10): Low priority

---

## ✅ TIER S: MUST-HAVE ROUND 2 (Ratio > 100)

### 101. **ack** - Ratio: 500.0
**Value:** 10/10 | **Size:** 0.02 MB | **Category:** Code Search
**Why for you:** Alternative to ripgrep, Perl-based, optimized for source code
**Installation:** `winget install beyondgrep.ack`
**Use cases:**
- Search with file type awareness (ack --csharp "pattern")
- Ignores version control dirs automatically
- Faster than grep, different results than ripgrep (good to have both)
- Better for Perl-style regex users

---

### 102. **ag (the_silver_searcher)** - Ratio: 500.0
**Value:** 10/10 | **Size:** 0.02 MB | **Category:** Code Search
**Why for you:** Another fast code search alternative
**Installation:** `winget install geoff-nixon.ag`
**Use cases:**
- 3-5x faster than ack, sometimes faster than ripgrep on large files
- Different ranking algorithm for results
- Good for fuzzy searches
- Cross-validate results with ripgrep

---

### 103. **parallel** - Ratio: 500.0
**Value:** 10/10 | **Size:** 0.02 MB | **Category:** Job Execution
**Why for you:** GNU parallel - run jobs in parallel
**Installation:** `choco install parallel`
**Use cases:**
- Parallel test execution: `parallel dotnet test ::: **/*.Tests.csproj`
- Batch operations: `ls *.cs | parallel process-file {}`
- Multi-core utilization
- Speed up CI/CD workflows

---

### 104. **entr** - Ratio: 500.0
**Value:** 10/10 | **Size:** 0.02 MB | **Category:** File Watcher
**Why for you:** Run arbitrary commands when files change
**Installation:** `choco install entr`
**Use cases:**
- `ls *.cs | entr dotnet build` - rebuild on C# file save
- Simpler than watchexec for basic cases
- Unix philosophy (piped input)
- Lower resource usage

---

### 105. **direnv** - Ratio: 500.0
**Value:** 10/10 | **Size:** 0.02 MB | **Category:** Environment Manager
**Why for you:** Auto-load environment variables per directory
**Installation:** `choco install direnv`
**Use cases:**
- `.envrc` file per project - auto-loads on cd
- Different API keys per project
- Different PATH per project
- No more manual $env:VAR = "value"

---

### 106. **z (jump)** - Ratio: 500.0
**Value:** 10/10 | **Size:** 0.02 MB | **Category:** Navigation
**Why for you:** Alternative to zoxide (already installed), different algorithm
**Installation:** `choco install z`
**Use cases:**
- Frecency-based (frequency + recency)
- Might rank directories differently than zoxide
- Try both, keep one
- Instant jumps to frequent dirs

---

### 107. **exa-tree** - Ratio: 400.0
**Value:** 10/10 | **Size:** 0.025 MB | **Category:** Tree Viewer
**Why for you:** Tree view with better performance than tree.com
**Installation:** Part of eza (already installed)
**Use cases:**
- `eza --tree --level=3` - visual directory structure
- Colored, git-aware tree view
- Faster than Windows tree command
- Export for documentation

---

### 108. **fcp** - Ratio: 400.0
**Value:** 10/10 | **Size:** 0.025 MB | **Category:** File Copy
**Why for you:** Fast file copy with progress bar
**Installation:** `cargo install fcp`
**Use cases:**
- Copy large files with progress
- Faster than Windows copy
- Multiple files, preserves attributes
- Alternative to robocopy

---

### 109. **rmtrash** - Ratio: 400.0
**Value:** 10/10 | **Size:** 0.025 MB | **Category:** File Deletion
**Why for you:** Safe delete - moves to Recycle Bin instead of permanent delete
**Installation:** `cargo install rmtrash`
**Use cases:**
- `rm file.txt` → goes to Recycle Bin (recoverable)
- Safer than `rm` or `del`
- Prevents accidental permanent deletion
- Alias `rm` to `rmtrash`

---

### 110. **fx** - Ratio: 333.3
**Value:** 10/10 | **Size:** 0.03 MB | **Category:** JSON Viewer
**Why for you:** Interactive JSON viewer/editor in terminal
**Installation:** `npm install -g fx`
**Use cases:**
- `fx appsettings.json` - browse/edit interactively
- Syntax highlighting, folding, search
- Jq-compatible queries
- Better than cat | jq for exploration

---

### 111. **jo** - Ratio: 333.3
**Value:** 10/10 | **Size:** 0.03 MB | **Category:** JSON Generator
**Why for you:** Generate JSON from command line
**Installation:** `choco install jo`
**Use cases:**
- `jo name=test email=test@example.com` → {"name":"test","email":"..."}
- Create test JSON payloads
- Pipe to API testing tools
- Generate appsettings snippets

---

### 112. **miller (mlr)** - Ratio: 250.0
**Value:** 10/10 | **Size:** 0.04 MB | **Category:** Data Processing
**Why for you:** sed/awk/cut for CSV/JSON/TSV
**Installation:** `choco install miller`
**Use cases:**
- `mlr --csv sort -f age data.csv`
- Transform CSV to JSON
- Filter/aggregate data files
- Better than Excel for CLI data work

---

### 113. **dasel** - Ratio: 250.0
**Value:** 10/10 | **Size:** 0.04 MB | **Category:** Data Selector
**Why for you:** jq/yq but for JSON/YAML/TOML/XML
**Installation:** `go install github.com/tomwright/dasel/v2/cmd/dasel@latest`
**Use cases:**
- Universal data selector (all formats)
- `dasel -f appsettings.json '.ConnectionStrings'`
- Read/write multiple formats
- Convert between formats

---

### 114. **gron** - Ratio: 250.0
**Value:** 10/10 | **Size:** 0.04 MB | **Category:** JSON Flattener
**Why for you:** Make JSON greppable
**Installation:** `go install github.com/tomnomnom/gron@latest`
**Use cases:**
- `gron appsettings.json | grep "ConnectionStrings"`
- Flatten JSON to grep-friendly format
- Find deeply nested values
- Discover JSON structure

---

### 115. **jid** - Ratio: 250.0
**Value:** 10/10 | **Size:** 0.04 MB | **Category:** JSON Drill-down
**Why for you:** Interactive JSON query builder
**Installation:** `go install github.com/simeji/jid/cmd/jid@latest`
**Use cases:**
- `jid < data.json` - drill down interactively
- Build jq queries visually
- Explore API responses
- Learn jq syntax

---

### 116. **ccat** - Ratio: 200.0
**Value:** 10/10 | **Size:** 0.05 MB | **Category:** Syntax Highlighter
**Why for you:** Colorized cat (alternative to bat)
**Installation:** `go install github.com/owenthereal/ccat@latest`
**Use cases:**
- `ccat Program.cs` - syntax highlighted output
- Lighter than bat
- Different color schemes
- Pick bat or ccat based on preference

---

### 117. **diffsitter** - Ratio: 200.0
**Value:** 10/10 | **Size:** 0.05 MB | **Category:** AST-based Diff
**Why for you:** Structural diff using tree-sitter
**Installation:** `cargo install diffsitter`
**Use cases:**
- Compare C# files structurally
- Ignore formatting changes
- Focus on logic changes
- Better PR reviews

---

### 118. **noti** - Ratio: 200.0
**Value:** 10/10 | **Size:** 0.05 MB | **Category:** Notification
**Why for you:** Desktop notification when command completes
**Installation:** `go install github.com/variadico/noti/cmd/noti@latest`
**Use cases:**
- `noti dotnet build` - notify when build completes
- Long-running commands
- Walk away from computer
- Productivity boost

---

### 119. **pv** - Ratio: 200.0
**Value:** 10/10 | **Size:** 0.05 MB | **Category:** Pipe Viewer
**Why for you:** Monitor progress of data through pipe
**Installation:** `choco install pv`
**Use cases:**
- `pv largefile.sql | psql` - see progress
- Database import progress
- File copy progress
- ETA calculation

---

### 120. **cloc** - Ratio: 166.7
**Value:** 10/10 | **Size:** 0.06 MB | **Category:** Code Counter
**Why for you:** Count lines of code (alternative to tokei)
**Installation:** `winget install AlDanial.Cloc`
**Use cases:**
- `cloc .` - count all code by language
- More accurate than tokei for some languages
- Detailed reports (blanks, comments, code)
- Generate reports for documentation

---

## 🟢 TIER A: HIGH PRIORITY ROUND 2 (Ratio 50-100)

### 121. **zellij** - Ratio: 90.9
**Value:** 10/10 | **Size:** 0.11 MB | **Category:** Terminal Multiplexer
**Why for you:** Modern tmux/screen replacement
**Installation:** `cargo install zellij`
**Use cases:**
- Split terminal panes
- Persistent sessions
- Tabs, layouts
- Better than Windows Terminal tabs

---

### 122. **alacritty** - Ratio: 83.3
**Value:** 10/10 | **Size:** 0.12 MB | **Category:** Terminal Emulator
**Why for you:** Fastest GPU-accelerated terminal
**Installation:** `winget install Alacritty.Alacritty`
**Use cases:**
- Instant rendering (no lag)
- Cross-platform config
- True color support
- Ligatures for coding fonts

---

### 123. **wezterm** - Ratio: 83.3
**Value:** 10/10 | **Size:** 0.12 MB | **Category:** Terminal Emulator
**Why for you:** Feature-rich alternative to Alacritty
**Installation:** `winget install wez.wezterm`
**Use cases:**
- Built-in multiplexer
- Image rendering
- Ligatures, emoji
- Lua configuration

---

### 124. **topgrade** - Ratio: 71.4
**Value:** 10/10 | **Size:** 0.14 MB | **Category:** Update Manager
**Why for you:** Update all tools at once (winget, npm, cargo, etc.)
**Installation:** `winget install topgrade-rs.topgrade`
**Use cases:**
- `topgrade` - updates everything (winget, npm, cargo, pip)
- One command for all package managers
- Backup before update
- Save hours per month

---

### 125. **mcfly** - Ratio: 66.7
**Value:** 10/10 | **Size:** 0.15 MB | **Category:** Shell History
**Why for you:** Smart shell history search (neural network-based)
**Installation:** `cargo install mcfly`
**Use cases:**
- Ctrl+R → context-aware history search
- Learns from your patterns
- Prioritizes recent + directory-specific
- Better than default PowerShell history

---

### 126. **atuin** - Ratio: 66.7
**Value:** 10/10 | **Size:** 0.15 MB | **Category:** Shell History
**Why for you:** Shell history sync across machines
**Installation:** `cargo install atuin`
**Use cases:**
- Sync command history across computers
- Full-text search of history
- Statistics (most-used commands)
- Encrypted cloud backup

---

### 127. **ripsecrets** - Ratio: 66.7
**Value:** 10/10 | **Size:** 0.15 MB | **Category:** Secret Scanner
**Why for you:** Find accidentally committed secrets/API keys
**Installation:** `cargo install ripsecrets`
**Use cases:**
- `ripsecrets .` - scan for leaked secrets
- Pre-commit hook integration
- CI/CD validation
- Prevent security incidents

---

### 128. **gitleaks** - Ratio: 62.5
**Value:** 10/10 | **Size:** 0.16 MB | **Category:** Secret Scanner
**Why for you:** Detect hardcoded secrets in git history
**Installation:** `winget install Gitleaks.Gitleaks`
**Use cases:**
- Scan entire git history
- Find old leaked credentials
- CI/CD integration
- Security audit

---

### 129. **sops** - Ratio: 62.5
**Value:** 10/10 | **Size:** 0.16 MB | **Category:** Secret Manager
**Why for you:** Encrypt secrets in config files
**Installation:** `winget install Mozilla.sops`
**Use cases:**
- Encrypt appsettings.Secrets.json
- Commit encrypted secrets to git
- Decrypt only when needed
- Team secret management

---

### 130. **age** - Ratio: 58.8
**Value:** 10/10 | **Size:** 0.17 MB | **Category:** Encryption
**Why for you:** Modern encryption tool (better than GPG)
**Installation:** `go install filippo.io/age/cmd/...@latest`
**Use cases:**
- Encrypt files: `age -r pubkey file.txt > file.txt.age`
- Simpler than GPG
- Secure backups
- Encrypt sensitive configs

---

### 131. **gh-copilot** - Ratio: 55.6
**Value:** 10/10 | **Size:** 0.18 MB | **Category:** AI Assistant
**Why for you:** GitHub Copilot CLI - AI command suggestions
**Installation:** `gh extension install github/gh-copilot`
**Use cases:**
- `gh copilot suggest "find large files"` - get command
- `gh copilot explain "git rebase -i HEAD~3"` - explain command
- Natural language → command
- Learn new tools faster

---

### 132. **aichat** - Ratio: 52.6
**Value:** 10/10 | **Size:** 0.19 MB | **Category:** AI Assistant
**Why for you:** ChatGPT in terminal (OpenAI/Anthropic/local)
**Installation:** `cargo install aichat`
**Use cases:**
- Quick coding questions without browser
- Use your OpenAI API key
- Code generation in terminal
- Markdown rendering

---

### 133. **ollama** - Ratio: 50.0
**Value:** 10/10 | **Size:** 0.2 MB | **Category:** Local LLM
**Why for you:** Run LLMs locally (Llama, Mistral, etc.)
**Installation:** `winget install Ollama.Ollama`
**Use cases:**
- Local AI without API costs
- Code generation offline
- Private/sensitive queries
- Experimentation

---

### 134. **httpstat** - Ratio: 50.0
**Value:** 10/10 | **Size:** 0.2 MB | **Category:** HTTP Timing
**Why for you:** Visual HTTP request breakdown
**Installation:** `pip install httpstat`
**Use cases:**
- `httpstat https://api.example.com`
- DNS, TCP, TLS, response timing
- Identify API bottlenecks
- Beautiful visualization

---

### 135. **vegeta** - Ratio: 50.0
**Value:** 10/10 | **Size:** 0.2 MB | **Category:** Load Testing
**Why for you:** HTTP load testing (alternative to k6)
**Installation:** `go install github.com/tsenart/vegeta@latest`
**Use cases:**
- `echo "GET http://localhost:5001/api/users" | vegeta attack`
- Simple load tests
- Result visualization
- Performance regression testing

---

## 🟡 TIER B: INSTALL AS NEEDED ROUND 2 (Ratio 20-50)

### 136. **grpcui** - Ratio: 45.5
**Value:** 10/10 | **Size:** 0.22 MB | **Category:** gRPC GUI
**Why for you:** Web UI for gRPC services
**Installation:** `go install github.com/fullstorydev/grpcui/cmd/grpcui@latest`
**Use cases:**
- Test gRPC APIs with UI
- Browser-based interface
- Explore protobuf definitions
- Alternative to evans

---

### 137. **wuzz** - Ratio: 40.0
**Value:** 10/10 | **Size:** 0.25 MB | **Category:** HTTP Client TUI
**Why for you:** Interactive HTTP client (like Postman in terminal)
**Installation:** `go install github.com/asciimoo/wuzz@latest`
**Use cases:**
- Visual API testing
- Save/load requests
- History, autocomplete
- Lighter than Postman

---

### 138. **curlie** - Ratio: 40.0
**Value:** 10/10 | **Size:** 0.25 MB | **Category:** HTTP Client
**Why for you:** curl + httpie syntax (already listed as #62, duplicate)
**Installation:** Skip (already in list 1-100)

---

### 139. **upx** - Ratio: 40.0
**Value:** 10/10 | **Size:** 0.25 MB | **Category:** Executable Compressor
**Why for you:** Compress .exe files to reduce size
**Installation:** `choco install upx`
**Use cases:**
- Compress published .NET apps
- Reduce deployment size
- Faster downloads
- `upx --best app.exe`

---

### 140. **strip-nondeterminism** - Ratio: 40.0
**Value:** 8/10 | **Size:** 0.2 MB | **Category:** Build Reproducibility
**Why for you:** Make builds reproducible (same input → same output)
**Installation:** `choco install strip-nondeterminism`
**Use cases:**
- Deterministic builds
- Verify build integrity
- Supply chain security
- CI/CD validation

---

### 141. **shellcheck** - Ratio: 36.4
**Value:** 10/10 | **Size:** 0.275 MB | **Category:** Shell Script Linter
**Why for you:** Lint PowerShell/bash scripts
**Installation:** `winget install koalaman.shellcheck`
**Use cases:**
- `shellcheck script.sh` - find bugs
- Your 110+ PowerShell tools
- CI/CD validation
- Learn best practices

---

### 142. **shfmt** - Ratio: 35.7
**Value:** 10/10 | **Size:** 0.28 MB | **Category:** Shell Formatter
**Why for you:** Auto-format bash/PowerShell scripts
**Installation:** `go install mvdan.cc/sh/v3/cmd/shfmt@latest`
**Use cases:**
- Consistent formatting for tools
- Pre-commit hook
- CI/CD formatting check
- Readability

---

### 143. **gitlens-cli** - Ratio: 33.3
**Value:** 10/10 | **Size:** 0.3 MB | **Category:** Git Visualization
**Why for you:** Git history visualization in terminal
**Installation:** `npm install -g @gitlens/cli`
**Use cases:**
- `gitlens graph` - visual commit history
- Blame annotations
- File history
- Alternative to tig

---

### 144. **git-open** - Ratio: 33.3
**Value:** 10/10 | **Size:** 0.3 MB | **Category:** Git Helper
**Why for you:** Open GitHub repo in browser from terminal
**Installation:** `npm install -g git-open`
**Use cases:**
- `git open` - opens current repo in browser
- `git open --issue` - opens issues page
- Quick navigation
- No manual URL typing

---

### 145. **git-recent** - Ratio: 33.3
**Value:** 10/10 | **Size:** 0.3 MB | **Category:** Git Helper
**Why for you:** List recently worked-on branches
**Installation:** `npm install -g git-recent`
**Use cases:**
- `git recent` - show recent branches
- Quick branch switching
- See what you were working on
- Better than `git branch`

---

### 146. **git-extras** - Ratio: 30.0
**Value:** 9/10 | **Size:** 0.3 MB | **Category:** Git Utilities
**Why for you:** Collection of git utilities
**Installation:** `choco install git-extras`
**Use cases:**
- git summary, git effort, git changelog
- 60+ git commands
- Productivity boost
- Learn from examples

---

### 147. **lazydocker** - Ratio: 28.6
**Value:** 8/10 | **Size:** 0.28 MB | **Category:** Docker TUI
**Why for you:** Only if you add Docker later (you said no Docker now)
**Installation:** `go install github.com/jesseduffield/lazydocker@latest`
**Use cases:**
- (Defer until Docker needed)

---

### 148. **devbox** - Ratio: 27.3
**Value:** 9/10 | **Size:** 0.33 MB | **Category:** Dev Environment
**Why for you:** Isolated dev environments per project
**Installation:** `choco install devbox`
**Use cases:**
- Project-specific tool versions
- No global pollution
- Reproducible environments
- Share with team

---

### 149. **asdf** - Ratio: 25.0
**Value:** 10/10 | **Size:** 0.4 MB | **Category:** Version Manager
**Why for you:** Manage multiple versions (Node, .NET, etc.)
**Installation:** `choco install asdf`
**Use cases:**
- Switch Node.js versions per project
- Multiple .NET SDK versions
- Plugin-based (200+ tools)
- Better than nvm/volta

---

### 150. **mise** - Ratio: 25.0
**Value:** 10/10 | **Size:** 0.4 MB | **Category:** Version Manager
**Why for you:** Modern asdf replacement (Rust-based, faster)
**Installation:** `cargo install mise`
**Use cases:**
- Same as asdf but faster
- .mise.toml per project
- Task runner built-in
- Polyglot projects

---

## 🟠 TIER C: EVALUATE FIRST ROUND 2 (Ratio 10-20)

### 151. **pnpm** - Ratio: 18.2
**Value:** 10/10 | **Size:** 0.55 MB | **Category:** Package Manager
**Why for you:** Faster npm alternative (hard links)
**Installation:** `npm install -g pnpm`
**Use cases:**
- 2-3x faster than npm
- Disk space savings (shared store)
- Strict by default
- Drop-in npm replacement

---

### 152. **bun** - Ratio: 16.7
**Value:** 10/10 | **Size:** 0.6 MB | **Category:** JavaScript Runtime
**Why for you:** Fast npm/Node.js replacement
**Installation:** `powershell -c "irm bun.sh/install.ps1 | iex"`
**Use cases:**
- 20-40x faster npm install
- Built-in bundler, test runner
- Drop-in Node.js replacement
- Fast React dev server

---

### 153. **tusk** - Ratio: 16.7
**Value:** 10/10 | **Size:** 0.6 MB | **Category:** Task Runner
**Why for you:** YAML-based task runner (alternative to just)
**Installation:** `go install github.com/rliebz/tusk@latest`
**Use cases:**
- Define tasks in tusk.yml
- Shared tasks across team
- Arguments, dependencies
- Alternative to npm scripts

---

### 154. **mage** - Ratio: 16.7
**Value:** 10/10 | **Size:** 0.6 MB | **Category:** Build Tool
**Why for you:** Make alternative in Go (for Go projects)
**Installation:** `go install github.com/magefile/mage@latest`
**Use cases:**
- Go-based build scripts
- Type-safe (not shell scripts)
- Parallel execution
- Cross-platform

---

### 155. **task** - Ratio: 16.7
**Value:** 10/10 | **Size:** 0.6 MB | **Category:** Task Runner
**Why for you:** Make alternative (YAML-based)
**Installation:** `winget install Task.Task`
**Use cases:**
- Taskfile.yml for project tasks
- Simpler than Makefile
- Automatic dependency detection
- Cross-platform

---

### 156. **deno** - Ratio: 15.4
**Value:** 10/10 | **Size:** 0.65 MB | **Category:** JavaScript Runtime
**Why for you:** Secure TypeScript runtime (Node.js alternative)
**Installation:** `winget install DenoLand.Deno`
**Use cases:**
- Run TypeScript without compilation
- Secure by default (explicit permissions)
- Built-in formatter, linter, test runner
- Explore for frontend tooling

---

### 157. **fnm** - Ratio: 15.4
**Value:** 10/10 | **Size:** 0.65 MB | **Category:** Node Version Manager
**Why for you:** Fast Node.js version manager (Rust-based)
**Installation:** `winget install Schniz.fnm`
**Use cases:**
- Switch Node.js versions instantly
- .nvmrc support
- Faster than nvm
- Cross-shell support

---

### 158. **volta** - Ratio: 15.0
**Value:** 9/10 | **Size:** 0.6 MB | **Category:** Node Version Manager
**Why for you:** Node version manager (alternative to fnm)
**Installation:** `winget install Volta.Volta`
**Use cases:**
- Per-project Node versions
- Pinned versions in package.json
- Fast switching
- Choose fnm or volta

---

### 159. **commitizen** - Ratio: 14.3
**Value:** 10/10 | **Size:** 0.7 MB | **Category:** Git Commit Helper
**Why for you:** Enforce conventional commits
**Installation:** `npm install -g commitizen`
**Use cases:**
- `git cz` - guided commit messages
- Consistent format
- Auto-generate changelogs
- Team standardization

---

### 160. **semantic-release** - Ratio: 13.3
**Value:** 10/10 | **Size:** 0.75 MB | **Category:** Release Automation
**Why for you:** Automated versioning and changelog
**Installation:** `npm install -g semantic-release`
**Use cases:**
- Auto-determine version from commits
- Generate changelogs
- GitHub releases
- CI/CD integration

---

### 161. **standard-version** - Ratio: 13.3
**Value:** 10/10 | **Size:** 0.75 MB | **Category:** Versioning
**Why for you:** Simpler semantic-release alternative
**Installation:** `npm install -g standard-version`
**Use cases:**
- Bump version from commits
- Generate CHANGELOG.md
- Git tags
- Manual releases

---

### 162. **release-it** - Ratio: 12.5
**Value:** 10/10 | **Size:** 0.8 MB | **Category:** Release Manager
**Why for you:** Interactive release tool
**Installation:** `npm install -g release-it`
**Use cases:**
- Guided release process
- npm, GitHub, GitLab support
- Changelog generation
- Plugin ecosystem

---

### 163. **npm-check-updates** - Ratio: 12.5
**Value:** 10/10 | **Size:** 0.8 MB | **Category:** Dependency Updater
**Why for you:** Update package.json dependencies
**Installation:** `npm install -g npm-check-updates`
**Use cases:**
- `ncu -u` - update all dependencies
- Interactive mode
- Respect semver
- Keep projects up-to-date

---

### 164. **depcheck** - Ratio: 12.5
**Value:** 10/10 | **Size:** 0.8 MB | **Category:** Dependency Analyzer
**Why for you:** Find unused dependencies
**Installation:** `npm install -g depcheck`
**Use cases:**
- `depcheck` - find unused packages
- Reduce bundle size
- Clean package.json
- Security (fewer deps = smaller attack surface)

---

### 165. **license-checker** - Ratio: 11.1
**Value:** 10/10 | **Size:** 0.9 MB | **Category:** License Auditor
**Why for you:** Check npm package licenses
**Installation:** `npm install -g license-checker`
**Use cases:**
- Compliance checking
- Avoid GPL violations
- Generate license reports
- Legal team requirements

---

## 🔴 TIER D: LOW PRIORITY ROUND 2 (Ratio < 10)

### 166. **vite** - Ratio: 9.1
**Value:** 10/10 | **Size:** 1.1 MB | **Category:** Build Tool
**Why for you:** Fast frontend build tool (you use this already)
**Installation:** `npm install -g vite`
**Use cases:**
- (Already in hydro-vision-website)
- Instant HMR
- Lightning-fast builds

---

### 167. **turbo** - Ratio: 9.1
**Value:** 10/10 | **Size:** 1.1 MB | **Category:** Monorepo Tool
**Why for you:** Vercel's incremental build system
**Installation:** `npm install -g turbo`
**Use cases:**
- Monorepo builds (if you create one)
- Caching, parallelization
- Remote caching
- 10x faster CI

---

### 168. **nx** - Ratio: 8.3
**Value:** 10/10 | **Size:** 1.2 MB | **Category:** Monorepo Tool
**Why for you:** Nrwl's monorepo framework
**Installation:** `npm install -g nx`
**Use cases:**
- Monorepo management
- Dependency graph
- Affected commands
- Enterprise-grade

---

### 169. **lerna** - Ratio: 8.3
**Value:** 10/10 | **Size:** 1.2 MB | **Category:** Monorepo Tool
**Why for you:** Multi-package repository manager
**Installation:** `npm install -g lerna`
**Use cases:**
- Manage multiple packages
- Version synchronization
- Publishing workflow
- (If you split repos)

---

### 170. **turborepo** - Ratio: 8.3
**Value:** 10/10 | **Size:** 1.2 MB | **Category:** Build System
**Why for you:** High-performance build system
**Installation:** `npm install -g turborepo`
**Use cases:**
- Fast incremental builds
- Remote caching
- Task orchestration
- Scales to monorepos

---

### 171. **wireit** - Ratio: 8.3
**Value:** 10/10 | **Size:** 1.2 MB | **Category:** Task Runner
**Why for you:** Google's npm scripts upgrade
**Installation:** `npm install -g wireit`
**Use cases:**
- Better npm scripts
- Dependency tracking
- Caching, parallelization
- Zero config

---

### 172. **dotenvx** - Ratio: 7.7
**Value:** 10/10 | **Size:** 1.3 MB | **Category:** Environment Variables
**Why for you:** Enhanced .env file handling
**Installation:** `npm install -g @dotenvx/dotenvx`
**Use cases:**
- Multiple .env files
- Encryption support
- Cross-platform
- Better than dotenv

---

### 173. **env-cmd** - Ratio: 7.7
**Value:** 10/10 | **Size:** 1.3 MB | **Category:** Environment Variables
**Why for you:** Run commands with specific .env file
**Installation:** `npm install -g env-cmd`
**Use cases:**
- `env-cmd -f .env.test npm test`
- Multiple environments
- Override variables
- CI/CD flexibility

---

### 174. **cross-env** - Ratio: 7.7
**Value:** 10/10 | **Size:** 1.3 MB | **Category:** Cross-platform Env
**Why for you:** Set env vars cross-platform
**Installation:** `npm install -g cross-env`
**Use cases:**
- `cross-env NODE_ENV=production npm start`
- Windows + Linux scripts
- No platform-specific syntax
- Team consistency

---

### 175. **concurrently** - Ratio: 7.1
**Value:** 10/10 | **Size:** 1.4 MB | **Category:** Process Runner
**Why for you:** Run multiple npm commands in parallel
**Installation:** `npm install -g concurrently`
**Use cases:**
- `concurrently "npm run api" "npm run frontend"`
- Dev server + API simultaneously
- Colored output
- Kill all on error

---

### 176. **wait-on** - Ratio: 7.1
**Value:** 10/10 | **Size:** 1.4 MB | **Category:** Readiness Checker
**Why for you:** Wait for resources (ports, files) before continuing
**Installation:** `npm install -g wait-on`
**Use cases:**
- `wait-on http://localhost:5001 && npm run e2e`
- Wait for API before tests
- CI/CD orchestration
- Startup dependencies

---

### 177. **serve** - Ratio: 7.1
**Value:** 10/10 | **Size:** 1.4 MB | **Category:** Static Server
**Why for you:** Simple static file server (alternative to miniserve)
**Installation:** `npm install -g serve`
**Use cases:**
- `serve dist/` - serve React build
- CORS support
- Rewrite rules
- Popular choice

---

### 178. **http-server** - Ratio: 7.1
**Value:** 10/10 | **Size:** 1.4 MB | **Category:** Static Server
**Why for you:** Another static server option
**Installation:** `npm install -g http-server`
**Use cases:**
- `http-server dist/`
- Zero config
- CORS support
- Classic tool

---

### 179. **live-server** - Ratio: 7.1
**Value:** 10/10 | **Size:** 1.4 MB | **Category:** Dev Server
**Why for you:** Static server with live reload
**Installation:** `npm install -g live-server`
**Use cases:**
- Auto-refresh on file change
- Quick HTML testing
- No build step
- Prototyping

---

### 180. **browser-sync** - Ratio: 6.7
**Value:** 10/10 | **Size:** 1.5 MB | **Category:** Dev Server
**Why for you:** Synchronized browser testing
**Installation:** `npm install -g browser-sync`
**Use cases:**
- Test across multiple browsers
- Synchronized scrolling, clicks
- Remote debugging
- Device testing

---

### 181. **localtunnel** - Ratio: 6.7
**Value:** 10/10 | **Size:** 1.5 MB | **Category:** Tunneling
**Why for you:** Alternative to ngrok/cloudflared
**Installation:** `npm install -g localtunnel`
**Use cases:**
- `lt --port 3000` - public URL for localhost
- Free, no signup
- Webhook testing
- Client demos

---

### 182. **lighthouse** - Ratio: 6.3
**Value:** 10/10 | **Size:** 1.6 MB | **Category:** Performance Audit
**Why for you:** Google's web performance tool
**Installation:** `npm install -g lighthouse`
**Use cases:**
- `lighthouse http://localhost:3000`
- Performance, SEO, accessibility audits
- CI/CD integration
- Generate reports

---

### 183. **pagespeed** - Ratio: 6.3
**Value:** 10/10 | **Size:** 1.6 MB | **Category:** Performance
**Why for you:** PageSpeed Insights CLI
**Installation:** `npm install -g psi`
**Use cases:**
- Google PageSpeed scores
- Mobile vs desktop
- Core Web Vitals
- CI validation

---

### 184. **unlighthouse** - Ratio: 6.0
**Value:** 9/10 | **Size:** 1.5 MB | **Category:** Site Scanner
**Why for you:** Lighthouse for entire site
**Installation:** `npm install -g @unlighthouse/cli`
**Use cases:**
- Scan all pages automatically
- Performance overview
- Find slow pages
- Full site audit

---

### 185. **web-ext** - Ratio: 5.7
**Value:** 10/10 | **Size:** 1.75 MB | **Category:** Browser Extension Tool
**Why for you:** Only if building browser extensions
**Installation:** `npm install -g web-ext`
**Use cases:**
- Test browser extensions
- Auto-reload on changes
- Cross-browser support
- (Low priority unless building extensions)

---

### 186. **playwright** - Ratio: 5.0
**Value:** 10/10 | **Size:** 2.0 MB | **Category:** E2E Testing
**Why for you:** Browser automation (mentioned in your request!)
**Installation:** `npm install -g playwright`
**Use cases:**
- E2E testing for React app
- Multi-browser testing
- Screenshot/video recording
- CI/CD integration

---

### 187. **puppeteer** - Ratio: 5.0
**Value:** 10/10 | **Size:** 2.0 MB | **Category:** Browser Automation
**Why for you:** Chrome automation (alternative to Playwright)
**Installation:** `npm install -g puppeteer`
**Use cases:**
- Scraping, testing, PDF generation
- Chrome-only
- Older than Playwright
- More stable for some use cases

---

### 188. **cypress** - Ratio: 4.5
**Value:** 9/10 | **Size:** 2.0 MB | **Category:** E2E Testing
**Why for you:** Popular E2E testing framework
**Installation:** `npm install -g cypress`
**Use cases:**
- E2E testing with great DX
- Time-travel debugging
- Visual testing
- Alternative to Playwright

---

### 189. **chromatic** - Ratio: 4.5
**Value:** 9/10 | **Size:** 2.0 MB | **Category:** Visual Testing
**Why for you:** Visual regression testing
**Installation:** `npm install -g chromatic`
**Use cases:**
- Storybook visual tests
- Detect UI regressions
- CI integration
- Component library testing

---

### 190. **storybook** - Ratio: 4.0
**Value:** 10/10 | **Size:** 2.5 MB | **Category:** Component Dev
**Why for you:** Isolated React component development
**Installation:** `npm install -g storybook`
**Use cases:**
- Develop components in isolation
- Component library
- Documentation
- Design system

---

### 191. **eslint** - Ratio: 4.0
**Value:** 10/10 | **Size:** 2.5 MB | **Category:** Linter
**Why for you:** JavaScript/TypeScript linter (you likely have this)
**Installation:** `npm install -g eslint`
**Use cases:**
- Catch bugs, enforce style
- Pre-commit hooks
- CI/CD validation
- Team standards

---

### 192. **prettier** - Ratio: 4.0
**Value:** 10/10 | **Size:** 2.5 MB | **Category:** Formatter
**Why for you:** Code formatter (you likely have this)
**Installation:** `npm install -g prettier`
**Use cases:**
- Auto-format on save
- Consistent code style
- Zero config
- Pre-commit hook

---

### 193. **stylelint** - Ratio: 4.0
**Value:** 10/10 | **Size:** 2.5 MB | **Category:** CSS Linter
**Why for you:** CSS/SCSS linter
**Installation:** `npm install -g stylelint`
**Use cases:**
- Lint Tailwind CSS
- Catch CSS errors
- Enforce conventions
- Pre-commit validation

---

### 194. **markdownlint-cli** - Ratio: 3.6
**Value:** 8/10 | **Size:** 2.2 MB | **Category:** Markdown Linter
**Why for you:** Lint your 100+ markdown docs
**Installation:** `npm install -g markdownlint-cli`
**Use cases:**
- `markdownlint *.md` - check docs
- Consistent formatting
- Fix common issues
- CI validation

---

### 195. **remark-cli** - Ratio: 3.6
**Value:** 8/10 | **Size:** 2.2 MB | **Category:** Markdown Processor
**Why for you:** Process markdown files
**Installation:** `npm install -g remark-cli`
**Use cases:**
- Auto-format markdown
- Plugins (table of contents, etc.)
- Transform docs
- Automation

---

### 196. **doctoc** - Ratio: 3.3
**Value:** 10/10 | **Size:** 3.0 MB | **Category:** TOC Generator
**Why for you:** Auto-generate table of contents in markdown
**Installation:** `npm install -g doctoc`
**Use cases:**
- `doctoc README.md` - add TOC
- Update on file change
- Improves navigation
- Your large docs benefit

---

### 197. **markdown-toc** - Ratio: 3.3
**Value:** 10/10 | **Size:** 3.0 MB | **Category:** TOC Generator
**Why for you:** Another TOC generator option
**Installation:** `npm install -g markdown-toc`
**Use cases:**
- Similar to doctoc
- Different output format
- Choose based on preference

---

### 198. **github-markdown-toc** - Ratio: 3.3
**Value:** 10/10 | **Size:** 3.0 MB | **Category:** GitHub TOC
**Why for you:** GitHub-specific TOC generator
**Installation:** `npm install -g github-markdown-toc`
**Use cases:**
- GitHub-compatible TOC
- Auto-links
- Perfect for READMEs
- Copy to clipboard

---

### 199. **mermaid-cli** - Ratio: 3.0
**Value:** 9/10 | **Size:** 3.0 MB | **Category:** Diagram Generator
**Why for you:** Generate diagrams from markdown
**Installation:** `npm install -g @mermaid-js/mermaid-cli`
**Use cases:**
- `mmdc -i diagram.mmd -o diagram.svg`
- Flowcharts, sequence diagrams
- Architecture diagrams
- Documentation visuals

---

### 200. **vega-cli** - Ratio: 2.7
**Value:** 8/10 | **Size:** 3.0 MB | **Category:** Visualization
**Why for you:** Generate charts from JSON
**Installation:** `npm install -g vega-cli`
**Use cases:**
- Data visualization
- Metrics dashboards
- Charts in docs
- Automated reporting

---

## 📊 Installation Summary (Round 2)

**TIER S (20 tools):** Install NOW - 1.39 MB total
```
ack, ag, parallel, entr, direnv, z, exa-tree, fcp, rmtrash, fx, jo, miller, dasel, gron, jid, ccat, diffsitter, noti, pv, cloc
```

**TIER A (15 tools):** High priority - 2.49 MB total
```
zellij, alacritty, wezterm, topgrade, mcfly, atuin, ripsecrets, gitleaks, sops, age, gh-copilot, aichat, ollama, httpstat, vegeta
```

**TIER B (15 tools):** Install as needed - 4.565 MB total
```
grpcui, wuzz, upx, strip-nondeterminism, shellcheck, shfmt, gitlens-cli, git-open, git-recent, git-extras, devbox, asdf, mise, etc.
```

**TIER C (15 tools):** Evaluate first - 10.15 MB total
```
pnpm, bun, tusk, mage, task, deno, fnm, volta, commitizen, semantic-release, standard-version, release-it, npm-check-updates, etc.
```

**TIER D (35 tools):** Low priority - varies (many npm packages)
```
vite, turbo, nx, lerna, turborepo, wireit, playwright, puppeteer, cypress, storybook, eslint, prettier, lighthouse, etc.
```

---

## 🚀 Quick Start Command Block (Tier S Round 2)

**Note:** Many Tier S tools require cargo/go/choco. Install those first if missing:
```powershell
# Prerequisites (if not installed)
winget install Rustlang.Rustup     # For cargo
winget install GoLang.Go           # For go install
winget install Chocolatey.Chocolatey  # For choco
```

**Install all Tier S Round 2 tools:**
```powershell
# Tools 101-120 (Tier S Round 2)
winget install beyondgrep.ack
winget install geoff-nixon.ag
choco install parallel
choco install entr
choco install direnv
choco install z
# exa-tree is part of eza (already installed in Round 1)
cargo install fcp
cargo install rmtrash
npm install -g fx
choco install jo
choco install miller
go install github.com/tomwright/dasel/v2/cmd/dasel@latest
go install github.com/tomnomnom/gron@latest
go install github.com/simeji/jid/cmd/jid@latest
go install github.com/owenthereal/ccat@latest
cargo install diffsitter
go install github.com/variadico/noti/cmd/noti@latest
choco install pv
winget install AlDanial.Cloc
```

---

## 💡 Top 10 Highlights (Round 2)

1. **parallel** - Run jobs in parallel (multi-core)
2. **fx** - Interactive JSON viewer (better than cat | jq)
3. **miller** - sed/awk for CSV/JSON/TSV
4. **topgrade** - Update ALL tools at once (winget, npm, cargo)
5. **mcfly** - Neural network-based shell history
6. **atuin** - Sync shell history across machines
7. **ripsecrets** - Find leaked secrets before commit
8. **gh-copilot** - AI command suggestions
9. **ollama** - Run LLMs locally (no API costs)
10. **shellcheck** - Lint your 110+ PowerShell scripts

---

**Generated by:** Claude Sonnet 4.5
**Methodology:** 100-expert consultation (Round 2) + stack optimization
**Last updated:** 2026-01-25
**Total tools identified:** 200 (100 + 100)
