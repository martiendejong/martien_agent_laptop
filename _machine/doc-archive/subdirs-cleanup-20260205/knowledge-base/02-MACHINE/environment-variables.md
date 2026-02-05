# Environment Variables & System Configuration

**Tags:** `#environment` `#configuration` `#system` `#path` `#development-tools`

**Last Updated:** 2026-01-25
**Expert:** Environment Variables Expert (#13)

---

## Table of Contents

1. [System Environment Variables](#system-environment-variables)
2. [PATH Configuration](#path-configuration)
3. [Development Tools in PATH](#development-tools-in-path)
4. [PowerShell Configuration](#powershell-configuration)
5. [Node.js / npm Configuration](#nodejs--npm-configuration)
6. [.NET Configuration](#net-configuration)
7. [Git Configuration](#git-configuration)
8. [IDE Configuration](#ide-configuration)
9. [Configuration Files](#configuration-files)
10. [Custom Environment Variables](#custom-environment-variables)

---

## System Environment Variables

### Core System Variables

| Variable | Value | Type | Description |
|----------|-------|------|-------------|
| `COMPUTERNAME` | `DESKTOP-ECBAUNU` | System | Machine name |
| `USERNAME` | `HP` | User | Current user |
| `USERDOMAIN` | `DESKTOP-ECBAUNU` | System | Domain name |
| `USERPROFILE` | `C:\Users\HP` | User | User profile directory |
| `HOMEDRIVE` | `C:` | System | System drive |
| `HOMEPATH` | `\Users\HP` | User | User home path |
| `HOME` | `C:\Users\HP` | User | Unix-style home directory |
| `APPDATA` | `C:\Users\HP\AppData\Roaming` | User | Roaming app data |
| `LOCALAPPDATA` | `C:\Users\HP\AppData\Local` | User | Local app data |
| `TEMP` | `C:\Users\HP\AppData\Local\Temp` | User | Temporary files |
| `TMP` | `C:\Users\HP\AppData\Local\Temp` | User | Temporary files (alternate) |

### Windows System Paths

| Variable | Value | Type |
|----------|-------|------|
| `SYSTEMROOT` | `C:\WINDOWS` | System |
| `WINDIR` | `C:\WINDOWS` | System |
| `SYSTEMDRIVE` | `C:` | System |
| `COMSPEC` | `C:\WINDOWS\system32\cmd.exe` | System |
| `PROGRAMFILES` | `C:\Program Files` | System |
| `ProgramFiles(x86)` | `C:\Program Files (x86)` | System |
| `ProgramW6432` | `C:\Program Files` | System |
| `COMMONPROGRAMFILES` | `C:\Program Files\Common Files` | System |
| `CommonProgramFiles(x86)` | `C:\Program Files (x86)\Common Files` | System |
| `ALLUSERSPROFILE` | `C:\ProgramData` | System |
| `PUBLIC` | `C:\Users\Public` | System |

### Hardware Information

| Variable | Value | Description |
|----------|-------|-------------|
| `PROCESSOR_ARCHITECTURE` | `AMD64` | CPU architecture |
| `PROCESSOR_IDENTIFIER` | `AMD64 Family 23 Model 96 Stepping 1, AuthenticAMD` | CPU details |
| `PROCESSOR_LEVEL` | `23` | Processor family |
| `PROCESSOR_REVISION` | `6001` | Processor stepping |
| `NUMBER_OF_PROCESSORS` | `16` | CPU core count |

---

## PATH Configuration

### System-Level PATH (Machine)

**Source:** `[System.Environment]::GetEnvironmentVariable('PATH', 'Machine')`

```
C:\Program Files\ImageMagick-7.1.2-Q16-HDRI
C:\Program Files (x86)\Common Files\Oracle\Java\java8path
C:\Program Files (x86)\Common Files\Oracle\Java\javapath
C:\WINDOWS\system32
C:\WINDOWS
C:\WINDOWS\System32\Wbem
C:\WINDOWS\System32\WindowsPowerShell\v1.0\
C:\WINDOWS\System32\OpenSSH\
C:\Program Files\Git\cmd
C:\Program Files\Microsoft SQL Server\150\Tools\Binn\
C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\
C:\Program Files\dotnet\
C:\Program Files\nodejs\
C:\Program Files\TortoiseGit\bin
C:\Programs\jdk-21.0.6+7\bin
C:\wp-cli
c:\scripts
C:\Program Files\GitHub CLI\
C:\Program Files\Tailscale\
C:\Program Files\Go\bin
```

### User-Level PATH

**Source:** `[System.Environment]::GetEnvironmentVariable('PATH', 'User')`

```
C:\Users\HP\.cargo\bin
C:\Users\HP\AppData\Local\com.Langflow\uv
C:\Users\HP\AppData\Local\Microsoft\WindowsApps
C:\Users\HP\AppData\Local\Programs\Microsoft VS Code\bin
C:\Users\HP\.dotnet\tools
C:\Users\HP\AppData\Roaming\npm
C:\Users\HP\AppData\Local\Programs\Windsurf\bin
C:\Programs\jdk-21.0.6+7\bin
C:\Users\HP\AppData\Local\Programs\Warp
C:\Users\HP\AppData\Local\Programs\cursor\resources\app\bin
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\FiloSottile.mkcert_Microsoft.Winget.Source_8wekyb3d8bbwe
C:\Users\HP\AppData\Local\Programs\Antigravity\bin
C:\Users\HP\.dotnet\tools
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\JohnMacFarlane.Pandoc_Microsoft.Winget.Source_8wekyb3d8bbwe\pandoc-3.8.3
C:\Users\HP\AppData\Local\Programs\Ollama
C:\xampp\php
```

### WinGet-Installed CLI Tools (in User PATH)

```
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe\ripgrep-15.1.0-x86_64-pc-windows-msvc
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_8wekyb3d8bbwe\fd-v10.3.0-x86_64-pc-windows-msvc
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\sharkdp.bat_Microsoft.Winget.Source_8wekyb3d8bbwe\bat-v0.26.1-x86_64-pc-windows-msvc
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\eza-community.eza_Microsoft.Winget.Source_8wekyb3d8bbwe
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\jqlang.jq_Microsoft.Winget.Source_8wekyb3d8bbwe
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\chmln.sd_Microsoft.Winget.Source_8wekyb3d8bbwe\sd-v1.0.0-x86_64-pc-windows-msvc
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\XAMPPRocky.Tokei_Microsoft.Winget.Source_8wekyb3d8bbwe
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\sharkdp.hyperfine_Microsoft.Winget.Source_8wekyb3d8bbwe\hyperfine-v1.20.0-x86_64-pc-windows-msvc
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\dandavison.delta_Microsoft.Winget.Source_8wekyb3d8bbwe\delta-0.18.2-x86_64-pc-windows-msvc
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\muesli.duf_Microsoft.Winget.Source_8wekyb3d8bbwe
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\junegunn.fzf_Microsoft.Winget.Source_8wekyb3d8bbwe
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\bootandy.dust_Microsoft.Winget.Source_8wekyb3d8bbwe\dust-v1.2.4-x86_64-pc-windows-gnu
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\dalance.procs_Microsoft.Winget.Source_8wekyb3d8bbwe
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\Starship.Starship_Microsoft.Winget.Source_8wekyb3d8bbwe
C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\ajeetdsouza.zoxide_Microsoft.Winget.Source_8wekyb3d8bbwe
```

### Git Bash Variables (MINGW64)

| Variable | Value | Description |
|----------|-------|-------------|
| `MSYSTEM` | `MINGW64` | MSYS2 environment |
| `MINGW_PREFIX` | `C:/Program Files/Git/mingw64` | MinGW prefix |
| `MINGW_CHOST` | `x86_64-w64-mingw32` | Target architecture |
| `MINGW_PACKAGE_PREFIX` | `mingw-w64-x86_64` | Package prefix |
| `EXEPATH` | `C:\Program Files\Git\bin` | Git executable path |

---

## Development Tools in PATH

### Version Control

| Tool | Version | Location | Command |
|------|---------|----------|---------|
| Git | Latest | `C:\Program Files\Git\cmd` | `git` |
| GitHub CLI | 2.83.2 | `C:\Program Files\GitHub CLI` | `gh` |
| TortoiseGit | Latest | `C:\Program Files\TortoiseGit\bin` | GUI only |

### Programming Languages

| Tool | Version | Location | Command |
|------|---------|----------|---------|
| Node.js | 22.14.0 | `C:\Program Files\nodejs` | `node` |
| npm | 10.9.2 | `C:\Program Files\nodejs` | `npm` |
| .NET SDK | 9.0.308 | `C:\Program Files\dotnet` | `dotnet` |
| Python | 3.13.9 | System PATH | `python` |
| Java JDK | 21.0.6+7 | `C:\Programs\jdk-21.0.6+7\bin` | `java` |
| Go | Latest | `C:\Program Files\Go\bin` | `go` |
| PHP | Latest | `C:\xampp\php` | `php` |
| Rust | Latest | `C:\Users\HP\.cargo\bin` | `cargo`, `rustc` |

### IDEs & Editors

| Tool | Location | Command |
|------|----------|---------|
| VS Code | `C:\Users\HP\AppData\Local\Programs\Microsoft VS Code\bin` | `code` |
| Cursor | `C:\Users\HP\AppData\Local\Programs\cursor\resources\app\bin` | `cursor` |
| Windsurf | `C:\Users\HP\AppData\Local\Programs\Windsurf\bin` | `windsurf` |
| Warp | `C:\Users\HP\AppData\Local\Programs\Warp` | `warp` |

### AI & ML Tools

| Tool | Location | Command |
|------|----------|---------|
| Claude Code CLI | `C:\Users\HP\AppData\Roaming\npm` | `claude` |
| Ollama | `C:\Users\HP\AppData\Local\Programs\Ollama` | `ollama` |
| Antigravity | `C:\Users\HP\AppData\Local\Programs\Antigravity\bin` | `antigravity` |

### Modern CLI Tools (Rust-based)

| Tool | Purpose | Location |
|------|---------|----------|
| `ripgrep` (rg) | Fast search | WinGet packages |
| `fd` | Fast find | WinGet packages |
| `bat` | Better cat | WinGet packages |
| `eza` | Better ls | WinGet packages |
| `delta` | Better diff | WinGet packages |
| `dust` | Better du | WinGet packages |
| `duf` | Better df | WinGet packages |
| `procs` | Better ps | WinGet packages |
| `zoxide` | Better cd | WinGet packages |
| `fzf` | Fuzzy finder | WinGet packages |
| `starship` | Shell prompt | WinGet packages |
| `jq` | JSON processor | WinGet packages |
| `sd` | Better sed | WinGet packages |
| `tokei` | Code counter | WinGet packages |
| `hyperfine` | Benchmarking | WinGet packages |

### Database & Servers

| Tool | Location | Command |
|------|----------|---------|
| SQL Server Tools | `C:\Program Files\Microsoft SQL Server\150\Tools\Binn` | `sqlcmd` |
| SQL Server ODBC | `C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn` | Various |

### Utilities

| Tool | Location | Command |
|------|----------|---------|
| ImageMagick | `C:\Program Files\ImageMagick-7.1.2-Q16-HDRI` | `magick` |
| mkcert | WinGet packages | `mkcert` |
| Pandoc | WinGet packages | `pandoc` |
| WP-CLI | `C:\wp-cli` | `wp` |
| Scripts | `c:\scripts` | Custom scripts |

---

## PowerShell Configuration

### Profile Location

**Path:** `C:\Users\HP\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

**Status:** File does not exist (no custom PowerShell profile configured)

### Module Paths

```
C:\Users\HP\Documents\WindowsPowerShell\Modules
C:\Program Files\WindowsPowerShell\Modules
C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
```

### PowerShell Variables

| Variable | Value |
|----------|-------|
| `$PROFILE` | `C:\Users\HP\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` |
| `$PSModulePath` | See Module Paths above |

---

## Node.js / npm Configuration

### Versions

- **Node.js:** 22.14.0
- **npm:** 10.9.2
- **Corepack:** Auto-pin disabled

### npm Configuration

```bash
prefix = "C:\Users\HP\AppData\Roaming\npm"
cwd = C:\scripts
HOME = C:\Users\HP
```

### Global npm Packages

| Package | Version | Purpose |
|---------|---------|---------|
| `@anthropic-ai/claude-code` | 2.1.19 | Claude Code CLI |
| `@angular/cli` | 20.0.0 | Angular framework |
| `@quasar/cli` | 2.5.0 | Quasar framework |
| `claude` | 0.1.1 | Claude CLI (legacy) |
| `markdown-pdf` | 11.0.0 | Markdown to PDF converter |
| `opencode-ai` | 1.1.28 | OpenCode AI tools |
| `yarn` | 1.22.22 | Package manager |

### npm Global Prefix

**Location:** `C:\Users\HP\AppData\Roaming\npm`

This is where global npm packages are installed and should be in PATH.

---

## .NET Configuration

### SDK Information

**Version:** 9.0.308
**Commit:** 46e170c517
**MSBuild:** 17.14.28+09c1be848
**Base Path:** `C:\Program Files\dotnet\sdk\9.0.308\`

### Installed SDKs

- 9.0.308 (latest)

### Installed Runtimes

| Runtime | Versions | Location |
|---------|----------|----------|
| Microsoft.AspNetCore.App | 8.0.22, 9.0.11 | `C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App` |
| Microsoft.NETCore.App | 6.0.36, 8.0.22, 9.0.11, 10.0.2 | `C:\Program Files\dotnet\shared\Microsoft.NETCore.App` |
| Microsoft.WindowsDesktop.App | 6.0.36, 8.0.22, 9.0.11 | `C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App` |

### Global .NET Tools

| Tool | Version | Command |
|------|---------|---------|
| `dotnet-ef` | 9.0.7 | Entity Framework Core CLI |
| `gitversion.tool` | 6.1.0 | Git versioning tool |

**Installation Location:** `C:\Users\HP\.dotnet\tools`

### NuGet Package Sources

| Source | Status | URL |
|--------|--------|-----|
| nuget.org | Enabled | https://api.nuget.org/v3/index.json |
| Local Packages | Enabled | `C:\Projects\devgpt\local_packages` |
| Microsoft Visual Studio Offline Packages | Enabled | `C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\` |

---

## Git Configuration

### Global Settings

```ini
user.name=martiendejong
user.email=martiendejong2008@gmail.com

core.whitespace=cr-at-eol
core.autocrlf=true

diff.tool=vsdiffmerge
diff.wserrorhighlight=none
difftool.prompt=true
difftool.vsdiffmerge.cmd="C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\vsdiffmerge.exe" "$LOCAL" "$REMOTE" //t
difftool.vsdiffmerge.keepbackup=false

merge.tool=vsdiffmerge
mergetool.prompt=true
mergetool.vsdiffmerge.cmd="C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\vsdiffmerge.exe" "$REMOTE" "$LOCAL" "$BASE" "$MERGED" //m
mergetool.vsdiffmerge.keepbackup=false
mergetool.vsdiffmerge.trustexitcode=true

difftool.bc.cmd="C:/Program Files/Beyond Compare 5/BCompare.exe" "$LOCAL" "$REMOTE"
mergetool.bc.cmd="C:/Program Files/Beyond Compare 5/BCompare.exe" "$LOCAL" "$REMOTE" "$BASE" "$MERGED"

difftool.sourcetree.cmd=''
mergetool.sourcetree.cmd=''
mergetool.sourcetree.trustexitcode=false
mergetool.sourcetree.keepbackup=false
```

### Key Configuration Notes

1. **User Identity:**
   - Name: martiendejong
   - Email: martiendejong2008@gmail.com

2. **Line Endings:**
   - `core.autocrlf=true` - Convert LF to CRLF on checkout, CRLF to LF on commit
   - `core.whitespace=cr-at-eol` - Allow CR at end of line

3. **Diff/Merge Tools:**
   - Primary: Visual Studio Diff/Merge
   - Secondary: Beyond Compare 5
   - Legacy: SourceTree (disabled)

---

## IDE Configuration

### VS Code

**Executable:** `C:\Users\HP\AppData\Local\Programs\Microsoft VS Code\bin\code`
**Settings Location:** `C:\Users\HP\AppData\Roaming\Code\User\settings.json`
**Extensions:** `C:\Users\HP\.vscode\extensions`

### Cursor

**Executable:** `C:\Users\HP\AppData\Local\Programs\cursor\resources\app\bin\cursor`
**Settings Location:** `C:\Users\HP\AppData\Roaming\Cursor\User\settings.json`
**Extensions:** `C:\Users\HP\.cursor\extensions`

### Visual Studio 2022 Community

**Diff/Merge Tool:** `C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\vsdiffmerge.exe`

---

## Configuration Files

### appsettings.json Locations

**Project:** client-manager

```
C:\Projects\client-manager\ClientManager.Tests\bin\Debug\net8.0-windows\appsettings.json
C:\Projects\client-manager\ClientManager.Tests\bin\Debug\net8.0-windows\appsettings.example.json
C:\Projects\client-manager\ClientManager.Tests\bin\Debug\net8.0-windows\appsettings.Hangfire.json
C:\Projects\client-manager\ClientManager.Tests\bin\Debug\net8.0-windows\appsettings.Secrets.json
C:\Projects\client-manager\ClientManager.Tests\bin\Debug\net8.0-windows\appsettings.Secrets.example.json
```

**Note:** Actual source files are in project root, these are build outputs.

### .env Files

**Project:** client-manager

```
C:\Projects\client-manager\.env.example
C:\Projects\client-manager\ClientManagerFrontend\.env.development
C:\Projects\client-manager\ClientManagerFrontend\.env.production
```

### Configuration Precedence

**.NET (appsettings.json):**
1. `appsettings.json` (base)
2. `appsettings.{Environment}.json` (environment-specific)
3. `appsettings.Secrets.json` (secrets, not in source control)
4. Environment variables
5. Command-line arguments

**React (.env):**
1. `.env` (base)
2. `.env.local` (local overrides)
3. `.env.{mode}` (development/production)
4. `.env.{mode}.local` (local environment overrides)

---

## Custom Environment Variables

### Claude-Specific

| Variable | Value | Purpose |
|----------|-------|---------|
| `CLAUDE_CODE_ENTRYPOINT` | `cli` | Claude Code CLI entry point |
| `CLAUDECODE` | `1` | Indicates running in Claude Code context |

### Package Managers

| Variable | Value | Purpose |
|----------|-------|---------|
| `ChocolateyInstall` | `C:\ProgramData\chocolatey` | Chocolatey package manager |
| `COREPACK_ENABLE_AUTO_PIN` | `0` | Node.js Corepack auto-pinning disabled |

### Development

| Variable | Value | Purpose |
|----------|-------|---------|
| `GOPATH` | `C:\Users\HP\go` | Go workspace |
| `NUGET_API_KEY` | `oy2h2iiqtmgfli33ft7a6okd7f3ijk3u3gvcumbnorwmvi` | NuGet API key |

### Internationalization

| Variable | Value | Purpose |
|----------|-------|---------|
| `LANG` | `nl_NL.UTF-8` | System locale (Dutch) |
| `TERM` | `xterm-256color` | Terminal type |

### Shell Behavior

| Variable | Value | Purpose |
|----------|-------|---------|
| `GIT_EDITOR` | `true` | Disable interactive git editor |
| `SHELL` | `C:\Program Files\Git\usr\bin\bash.exe` | Default shell |
| `SHELLOPTS` | `braceexpand:hashall:igncr:interactive-comments` | Shell options |

---

## Environment Variable Categories

### PATH Components Breakdown

**Total PATH entries:** 67

**By category:**
- System tools: 7 (Windows, PowerShell, OpenSSH)
- Development languages: 8 (Node.js, .NET, Python, Java, Go, PHP, Rust)
- Version control: 3 (Git, GitHub CLI, TortoiseGit)
- IDEs/Editors: 4 (VS Code, Cursor, Windsurf, Warp)
- Modern CLI tools: 15 (ripgrep, fd, bat, eza, etc.)
- Database tools: 2 (SQL Server)
- AI tools: 3 (Claude, Ollama, Antigravity)
- Utilities: 6 (ImageMagick, mkcert, Pandoc, etc.)
- Custom: 1 (`c:\scripts`)
- Package managers: 2 (.dotnet\tools, npm global)
- WinGet packages: 16

---

## Security & Secrets

### API Keys in Environment

**WARNING:** `NUGET_API_KEY` is stored in environment variables. This is a security risk.

**Recommendation:** Store API keys in:
- `.env` files (not in source control)
- `appsettings.Secrets.json` (not in source control)
- Windows Credential Manager
- Azure Key Vault or similar secrets management

### Secrets Storage Locations

**DO NOT commit:**
- `appsettings.Secrets.json`
- `.env.local`
- `.env.*.local`
- Any file containing API keys, passwords, or connection strings

**Safe to commit:**
- `appsettings.example.json`
- `appsettings.Secrets.example.json`
- `.env.example`

---

## Verification Commands

### Check Environment

```powershell
# All environment variables
Get-ChildItem Env: | Sort-Object Name

# PATH components
$env:PATH -split ';' | Sort-Object

# System PATH only
[System.Environment]::GetEnvironmentVariable('PATH', 'Machine') -split ';'

# User PATH only
[System.Environment]::GetEnvironmentVariable('PATH', 'User') -split ';'
```

### Check Tool Versions

```bash
# Node.js / npm
node --version
npm --version

# .NET
dotnet --info
dotnet tool list -g

# Git
git --version
git config --list --global

# GitHub CLI
gh --version

# Python
python --version

# Other tools
claude --version
java --version
go version
php --version
```

### Check Locations

```bash
# Find executables
where node
where dotnet
where python
where git
where gh
where code
where cursor
where claude
```

---

## Notes & Observations

### Duplicates in PATH

Some paths appear multiple times:
- `C:\Users\HP\.dotnet\tools` (appears twice in user PATH)
- `C:\Programs\jdk-21.0.6+7\bin` (appears in both system and user PATH)
- Git binaries appear in multiple locations (MinGW paths)

**Impact:** Low - PATH searches left-to-right, first match is used.

### Modern CLI Tools Strategy

User has adopted a comprehensive set of modern Rust-based CLI tools installed via WinGet:
- All tools installed in `C:\Users\HP\AppData\Local\Microsoft\WinGet\Packages\`
- Tools are automatically updated via WinGet
- No manual PATH management needed

### Language Versions

- **Node.js:** v22 (latest LTS)
- **.NET:** v9 (latest)
- **Python:** v3.13 (latest)
- **Java:** JDK 21 (LTS)
- **Go:** Latest stable

All languages are on current/recent major versions.

### Missing PowerShell Profile

No custom PowerShell profile is configured. User may benefit from creating one to:
- Set custom aliases
- Import frequently-used modules
- Configure prompt (e.g., Starship)
- Set custom environment variables

---

## Related Documentation

- [Tools & Productivity](./tools-documentation.md) - Tool usage and workflows
- [Development Environment](./development-environment.md) - IDE setup and configuration
- [File System Structure](./file-system-structure.md) - Directory organization
- [Security & Secrets](./security-practices.md) - Secrets management

---

**Document Status:** ✅ Complete
**Coverage:** Comprehensive environment variable and system configuration documentation
**Next Expert:** #14 - PowerShell Profile & Customizations Expert
