# Software Inventory

**Generated:** 2026-01-25
**Machine:** Windows 11 (Build 26100)
**Tags:** #software, #versions, #tools, #inventory

---

## System Information

| Component | Version | Details |
|-----------|---------|---------|
| **Operating System** | Windows 11 | Build 26100 (Microsoft Windows NT 10.0.26100.0) |
| **PowerShell** | 5.1+ | Built-in Windows PowerShell |
| **Windows Terminal** | 1.23.13503.0 | Modern terminal application |

---

## Development Tools

### IDEs and Code Editors

| Tool | Version | Extensions/Workloads | Installation Path |
|------|---------|---------------------|-------------------|
| **Visual Studio Community 2022** | 17.14.25 | Full .NET workloads | System-wide |
| **Visual Studio Code** | 1.108.2 (commit: c9d77990917f3102ada88be140d28b038d1dd7c7) | 35 extensions (see below) | User install |
| **Cursor** | 2.2.44 | AI-powered code editor | User install |
| **Windsurf** | 1.94.0 | Codeium AI editor | User install |
| **Claude Code CLI** | 2.1.19 (via npm) | Anthropic AI coding assistant | Global npm |

### VS Code Extensions (35 total)

**AI & Productivity:**
- `anthropic.claude-code` - Claude AI integration
- `github.copilot` - GitHub Copilot
- `github.copilot-chat` - Copilot Chat
- `openai.chatgpt` - ChatGPT integration
- `continue.continue` - Continue AI coding assistant

**Vue/Nuxt Development:**
- `vue.volar` - Vue Language Features
- `nuxt.mdc` - Nuxt MDC
- `nuxtr.nuxtr-vscode` - Nuxtr
- `mubaidr.vuejs-extension-pack` - Vue.js Extension Pack
- `sdras.vue-vscode-snippets` - Vue snippets
- `hossaini.quasar-intellisense` - Quasar IntelliSense
- `alimozdemir.vscode-nuget-dx-tools` - Nuxt DX Tools

**.NET Development:**
- `ms-dotnettools.csdevkit` - C# Dev Kit
- `ms-dotnettools.csharp` - C# language support
- `ms-dotnettools.vscode-dotnet-runtime` - .NET runtime

**JavaScript/TypeScript:**
- `esbenp.prettier-vscode` - Prettier formatter
- `dbaeumer.vscode-eslint` - ESLint
- `christian-kohler.npm-intellisense` - npm IntelliSense
- `xabikos.javascriptsnippets` - JavaScript snippets
- `antfu.vite` - Vite integration
- `antfu.browse-lite` - Browser preview

**Git & Version Control:**
- `mhutchie.git-graph` - Git Graph
- `donjayamanne.githistory` - Git History
- `mk12.better-git-line-blame` - Better Git Line Blame

**Utilities:**
- `mechatroner.rainbow-csv` - Rainbow CSV
- `anseki.vscode-color` - Color picker
- `tombonnike.vscode-status-bar-format-toggle` - Format toggle
- `vitest.explorer` - Vitest test explorer

**Containers:**
- `ms-azuretools.vscode-containers` - Docker support
- `ms-vscode-remote.remote-containers` - Remote containers

**Documentation:**
- `fmoronzirfas.markdown-to-html` - Markdown to HTML
- `yzane.markdown-pdf` - Markdown PDF export
- `bachtv.mdx-exporter-lite` - MDX exporter

**IntelliCode:**
- `visualstudioexptteam.vscodeintellicode` - IntelliCode
- `visualstudioexptteam.intellicode-api-usage-examples` - API usage examples

---

## Programming Languages & Runtimes

### .NET Ecosystem

| Component | Versions Installed | Path |
|-----------|-------------------|------|
| **.NET SDK** | 9.0.308 | C:\Program Files\dotnet\sdk |
| **ASP.NET Core Runtime** | 8.0.22, 9.0.11 | C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App |
| **.NET Runtime** | 6.0.36, 8.0.22, 9.0.11, 10.0.2 | C:\Program Files\dotnet\shared\Microsoft.NETCore.App |
| **Windows Desktop Runtime** | 6.0.36, 8.0.22, 9.0.11 | C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App |

**Visual C++ Redistributables:**
- 2008 x86/x64 (9.0.30729.6161)
- 2010 x64 (10.0.40219)
- 2012 x64 (11.0.61135.0)
- 2013 x64 (12.0.30501.0, 12.0.40653.0)
- 2015-2022 x86/x64 (14.42.34438.0)

### JavaScript/Node.js

| Tool | Version | Global Packages |
|------|---------|----------------|
| **Node.js** | 22.14.0 | 7 packages |
| **npm** | Included with Node | - |
| **Yarn** | 1.22.22 | Via npm global |

**Global npm Packages:**
- `@angular/cli@20.0.0` - Angular framework CLI
- `@anthropic-ai/claude-code@2.1.19` - Claude Code CLI
- `@quasar/cli@2.5.0` - Quasar framework CLI
- `claude@0.1.1` - Claude CLI (legacy)
- `markdown-pdf@11.0.0` - Markdown to PDF converter
- `opencode-ai@1.1.28` - OpenCode AI CLI
- `yarn@1.22.22` - Alternative package manager

### Python

| Component | Version | Installation |
|-----------|---------|-------------|
| **Python** | 3.13.9 | System-wide |
| **pip** | 25.2 | Package manager |

**Installed Python Packages (43 total):**

**Core Libraries:**
- `numpy@2.3.5` - Numerical computing
- `scipy@1.17.0` - Scientific computing
- `pillow@12.1.0` - Image processing
- `scikit-image@0.26.0` - Image processing algorithms
- `networkx@3.6.1` - Graph analysis

**AI/ML Libraries:**
- `onnxruntime@1.23.2` - ONNX model runtime
- `numba@0.63.1` - JIT compiler
- `llvmlite@0.46.0` - LLVM bindings
- `rembg@2.0.72` - Background removal
- `PyMatting@1.1.14` - Image matting

**Utilities:**
- `requests@2.32.5` - HTTP client
- `tqdm@4.67.1` - Progress bars
- `coloredlogs@15.0.1` - Colored logging
- `invoke@2.2.1` - Task execution
- `Markdown@3.10` - Markdown parser
- `jsonschema@4.26.0` - JSON schema validation

**Security:**
- `cryptography@46.0.3` - Cryptographic recipes
- `paramiko@4.0.0` - SSH library
- `bcrypt@5.0.0` - Password hashing
- `PyNaCl@1.6.2` - Crypto primitives

**Image Processing:**
- `ImageIO@2.37.2` - Image I/O
- `tifffile@2026.1.14` - TIFF file handling

### Rust

| Tool | Version |
|------|---------|
| **rustc** | 1.93.0 (254b59607 2026-01-19) |
| **cargo** | 1.93.0 (083ac5135 2025-12-15) |
| **rustup** | 1.28.2 |

### Go

| Tool | Version |
|------|---------|
| **Go** | 1.25.6 |

### Java

| Tool | Version |
|------|---------|
| **Java Runtime Environment** | 8 Update 481 (8.0.4810.10) |

---

## Database Systems

| Database | Version | Notes |
|----------|---------|-------|
| **PostgreSQL 17** | 17.6-2 | Primary database |
| **PostgreSQL 18** | 18.0-2 | Latest version |
| **SQL Server 2019 LocalDB** | 15.0.4382.1 | Development database |
| **Microsoft ODBC Driver 17** | 17.10.6.1 | SQL Server connectivity |
| **SQLite** | Via DB Browser 3.13.1 | Lightweight database |
| **Npgsql** | 3.2.6-3 | PostgreSQL .NET provider |

**Database Tools:**
- **DB Browser for SQLite** 3.13.1
- **DBeaver Community** 25.0.5 (visual database manager)
- **SQL Server Management Tools** (via Visual Studio)

---

## Version Control & CI/CD

| Tool | Version | Purpose |
|------|---------|---------|
| **Git** | 2.49.0.windows.1 | Version control |
| **GitHub CLI (gh)** | 2.83.2 (2025-12-10) | GitHub automation |
| **TortoiseGit** | 2.17.0.2 (64-bit) | Git GUI |
| **SourceTree** | 3.4.28 | Visual Git client |

---

## Build & Development Tools

### PowerShell Modules (Top 20)

| Module | Version |
|--------|---------|
| **PackageManagement** | 1.0.0.1 |
| **PowerShellGet** | 1.0.0.1 |
| **PSReadLine** | 2.0.0 |
| **Pester** | 3.4.0 |
| **AppBackgroundTask** | 1.0.0.0 |
| **AppLocker** | 2.0.0.0 |
| **BitLocker** | 1.0.0.0 |
| **BitsTransfer** | 2.0.0.0 |
| **Defender** | 1.0 |
| **ConfigDefender** | 1.0 |

### Modern CLI Tools (Rust-based)

| Tool | Version | Purpose |
|------|---------|---------|
| **ripgrep (rg)** | 15.1.0 | Fast text search |
| **bat** | 0.26.1 | Cat with syntax highlighting |
| **fd** | 10.3.0 | Fast find alternative |
| **eza** | 0.23.4 | Modern ls replacement |
| **delta** | 0.18.2 | Git diff viewer |
| **procs** | 0.14.10 | Modern ps alternative |
| **dust** | 1.2.4 | Disk usage analyzer |
| **duf** | 0.9.1 | Disk usage viewer |
| **hyperfine** | 1.20.0 | Command benchmarking |
| **tokei** | 12.1.2 | Code statistics |
| **sd** | 1.0.0 | Search & displace |
| **zoxide** | 0.9.8 | Smart cd command |
| **fzf** | 0.67.0 | Fuzzy finder |
| **starship** | 1.24.2 | Cross-shell prompt |
| **jq** | 1.8.1 | JSON processor |

### Other Build Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **IIS Express** | 10.0.10007 | Local web server |
| **Microsoft Web Deploy** | 10.0.9419 | Web deployment |
| **Chocolatey** | 2.6.0.0 | Windows package manager |
| **winget** | 2026.125.1549+ | Windows Package Manager |

---

## Web Browsers & AI Tools

### Browsers

| Browser | Version | Purpose |
|---------|---------|---------|
| **Google Chrome** | 144.0.7559.61 | Primary browser |
| **Microsoft Edge** | 144.0.3719.82 | Secondary browser |
| **Brave** | 144.1.86.142 | Privacy-focused browser |

### AI Desktop Applications

| Application | Version | Purpose |
|-------------|---------|---------|
| **Claude Desktop** | 1.1.799 | Anthropic AI assistant |
| **ChatGPT Desktop** | 1.2025.328.0 | OpenAI assistant |
| **Copilot** | 1.25121.73.0 | Microsoft AI assistant |
| **Perplexity** | 1.3.0 | AI search |
| **Antigravity** | 1.13.3 | Google AI tool |

---

## Communication & Productivity

| Application | Version | Category |
|-------------|---------|----------|
| **Microsoft Teams** | 25044.2208.34+ | Communication |
| **Zoom Workplace** | 6.6.6 (19875) | Video conferencing |
| **Slack** | 4.47.69.0 | Team messaging |
| **Microsoft Outlook** | 1.2026.114.100 | Email client |
| **Microsoft To Do** | 0.153.5851.0 | Task management |
| **ManicTime** | 25.3.5.0 | Time tracking |
| **Mailspring** | 1.17.2 | Email client |
| **LinkedIn** | 3.0.43.0 | Professional networking |

---

## File Management & Utilities

### File Management

| Tool | Version | Purpose |
|------|---------|---------|
| **WinMerge** | 2.16.50.2 (64-bit) | File comparison |
| **TreeSize Free** | 4.7.3 (64-bit) | Disk space analysis |
| **FileZilla** | 3.69.1 | FTP client |

### Image & Media Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **ImageMagick** | 7.1.2.13 Q16-HDRI (64-bit) | Image manipulation |
| **Paint.NET** | 5.1.11 | Image editing |
| **Microsoft Photos** | 2025.11120.50+ | Photo viewer |
| **Microsoft Paint** | 11.2511.291.0 | Basic drawing |
| **Windows Camera** | 2025.2510.2.0 | Camera app |
| **Media Player** | 11.2511.5.0 | Media playback |

### Document Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **OpenOffice** | 4.1.15 | Office suite |
| **Foxit PDF Reader** | 2025.1.0.27937 | PDF viewer |
| **Pandoc** | 3.8.3 | Document converter |

---

## Development Servers & Environments

| Server | Version | Components |
|--------|---------|-----------|
| **XAMPP** | 8.2.12-0 | Apache, MySQL, PHP |
| **Laragon** | 8.2.3 | Development environment |

---

## API Development & Testing

| Tool | Version | Purpose |
|------|---------|---------|
| **Postman Agent** | 0.4.45 | API testing |
| **Insomnia** | 11.2.0 | API client |

---

## Game Development & Unity

| Tool | Version | Notes |
|------|---------|-------|
| **Unity Hub** | 3.12.1 | Unity version manager |
| **Unity 6000.1.6f1** | 6000.1.6f1 | Game engine |
| **Microsoft GameInput** | 3.1.26100.6879 | Game input API |

---

## Cloud & Networking

| Tool | Version | Purpose |
|------|---------|---------|
| **Google Drive** | 119.0.2.0 | Cloud storage |
| **Microsoft OneDrive** | 25.238.1204.0+ | Cloud storage |
| **Tailscale** | 1.92.5 | VPN/mesh network |
| **OpenSSL** | 3.4.1 (64-bit) | Cryptography toolkit |
| **mkcert** | 1.4.4 | Local SSL certificates |

---

## Microsoft 365 & Windows Apps

### Productivity Apps

- **Microsoft 365 Copilot** - 19.2601.50081+
- **Microsoft Edge WebView2** - Built-in
- **Microsoft Clipchamp** - 4.5.10020.0 (video editor)
- **Microsoft Solitaire Collection** - 4.25.1130.0
- **Microsoft Sticky Notes** - 4.0.6104.0

### System Apps

- **Windows Calculator** - 11.2508.4.0
- **Windows Notepad** - 11.2510.14.0
- **Windows Clock** - 11.2510.4.0
- **Windows Sound Recorder** - 1.1.47.0
- **Snipping Tool** - 11.2511.31.0
- **Windows Security** - 1000.29429.10+
- **Microsoft Store** - 22512.1401.5.0
- **App Installer** - 1.27.460.0
- **Feedback Hub** - 1.2512.16303.0
- **Quick Assist** - 2.0.29.0
- **Phone Link** - 1.25112.36.0

### Xbox Gaming

- **Xbox** - 2512.1001.36.0
- **Game Bar** - 7.325.11061.0
- **Xbox Identity Provider** - 12.130.16001.0
- **Game Speech Window** - 1.97.17002.0
- **Xbox TCUI** - 1.24.10001.0
- **Gaming Services** - 33.108.12001.0

### Media Extensions

- **AV1 Video Extension** - 2.0.6.0
- **HEIF Image Extension** - 1.2.28.0
- **HEVC Video Extensions** - 2.4.39.0
- **MPEG-2 Video Extension** - 1.2.13.0
- **VP9 Video Extensions** - 1.2.12.0
- **Web Media Extensions** - 1.2.17.0
- **WebP Image Extension** - 1.2.14.0
- **Raw Image Extension** - 2.5.7.0

---

## Windows Subsystem for Linux

| Component | Version |
|-----------|---------|
| **WSL** | 2.5.9.0 |

Note: Docker is **not installed** on this system.

---

## Other Software

### Design & Documentation

- **WordPress.com** - 8.0.4 (desktop app)
- **Langflow** - 1.5.1 (visual programming)
- **ODAFileConverter** - 26.7.0 (CAD file converter)

### Epic Games

- **Epic Games Launcher** - 1.3.151.0
- **Epic Online Services** - 3.0.4

### Terminals

- **Warp** - v0.2025.11.05+ (modern terminal)
- **Windows Terminal** - 1.23.13503.0 (primary terminal)
- **Zenflow** - 0.0.68 (workflow terminal)

### Security & VPN

- **Microsoft Windows Security** - Built-in
- **Microsoft Defender** - Built-in
- **Tailscale** - 1.92.5 (mesh VPN)

### Hardware Utilities

- **Canon MP495 series MP Drivers** - Printer drivers
- **HP Desktop Support Utilities** - 7.0.8.0
- **HP Audio Control** - 2.51.331.0
- **AMD Radeon Software** - 10.23.19012.0

---

## Runtime Libraries & Frameworks

### .NET Framework Components

- **Microsoft .Net Native Framework** - 2.2.29512.0 (multiple architectures)
- **Microsoft .Net Native Runtime** - 2.2.28604.0 (multiple architectures)
- **Microsoft SQL Server 2019 CLR Types** - 15.0.2000.5

### Windows Runtime Components

- **WindowsAppRuntime.1.4** - 4000.1309.205+
- **WindowsAppRuntime.1.5** - 5001.373.1736+
- **WindowsAppRuntime.1.6** - 6000.519.329.0
- **WindowsAppRuntime.1.7** - 7000.676/7000.744
- **WindowsAppRuntime.1.8** - 8000.675/8000.731

### Microsoft UI Libraries

- **Microsoft.UI.Xaml.2.7** - 7.2409.9001.0
- **Microsoft.UI.Xaml.2.8** - 8.2501.31001.0

### DirectX & Gaming

- **DirectX Runtime** - 9.29.1974.0

---

## Update Status Summary

**Software with Available Updates (as of 2026-01-25):**

| Software | Current | Available | Priority |
|----------|---------|-----------|----------|
| Claude Desktop | 1.1.799 | 1.1.886 | High |
| VS Code extensions | Various | Various | Medium |
| GitHub CLI | 2.83.2 | 2.85.0 | Medium |
| Node.js | 22.14.0 | 22.22.0 | Medium |
| Windsurf | 1.94.0 | Latest | Low |
| Cursor | 2.2.44 | 2.4.21 | Low |
| DBeaver | 25.0.5 | 25.3.3 | Low |
| Chrome | 144.0.7559.61 | 144.0.7559.97 | Security |
| Edge | 144.0.3719.82 | Latest | Security |

**Total Software Packages Identified:** 200+

---

## Installation Paths

### Primary Development Locations

- **Projects:** `C:\Projects\`
- **Worker Agents:** `C:\Projects\worker-agents\`
- **Scripts:** `C:\scripts\`
- **Tools:** `C:\scripts\tools\`
- **Stores:** `C:\stores\`

### Program Installations

- **Program Files:** `C:\Program Files\`
- **Program Files (x86):** `C:\Program Files (x86)\`
- **User Applications:** `C:\Users\HP\AppData\`
- **npm Global:** `C:\Users\HP\AppData\Roaming\npm\`

---

## Notes

1. **Docker:** Not installed on this system (verified 2026-01-25)
2. **Multiple .NET Versions:** System maintains backwards compatibility with .NET 6, 8, 9, and 10
3. **Rust Toolchain:** Recently updated (2026-01-19)
4. **Python:** Latest 3.13 series with comprehensive ML/AI libraries
5. **Modern CLI Tools:** Extensive Rust-based CLI toolkit installed
6. **VS Code:** 35 extensions focused on AI, Vue/Nuxt, .NET, and Git workflows
7. **AI Tools:** Multiple AI assistants installed (Claude, ChatGPT, Copilot, Perplexity)
8. **Database Support:** PostgreSQL (17 & 18), SQL Server LocalDB, SQLite
9. **Browser Extensions:** Not inventoried (requires manual check per browser)
10. **ManicTime:** Time tracking tool actively used for activity monitoring

---

**Last Updated:** 2026-01-25
**Maintained By:** Software Inventory Specialist (Expert #12)
**Next Review:** Quarterly or when major software installations occur
