# Quick Start: Migrate CDP to Puppeteer (3-Day Plan)

**Goal:** Replace raw CDP implementation with production-grade Puppeteer automation

---

## Day 1: Setup & Proof of Concept (2 hours)

### 1. Install Puppeteer
```powershell
# Create Node.js project
cd C:\scripts\tools
New-Item -ItemType Directory -Path browser-scripts -Force
cd browser-scripts

# Initialize Node project
npm init -y

# Install dependencies
npm install puppeteer yargs
```

### 2. Create First Puppeteer Script

**C:\scripts\tools\browser-scripts\screenshot.js:**
```javascript
#!/usr/bin/env node
const puppeteer = require('puppeteer');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

const argv = yargs(hideBin(process.argv))
    .option('url', { type: 'string', demandOption: true })
    .option('output', { type: 'string', default: 'screenshot.png' })
    .option('fullpage', { type: 'boolean', default: false })
    .argv;

(async () => {
    let browser;
    try {
        browser = await puppeteer.launch({
            executablePath: 'C:\\Program Files\\BraveSoftware\\Brave-Browser\\Application\\brave.exe',
            headless: true,
            args: ['--no-sandbox']
        });

        const page = await browser.newPage();

        // Navigate with auto-wait
        await page.goto(argv.url, {
            waitUntil: 'networkidle2',
            timeout: 30000
        });

        // Take screenshot
        await page.screenshot({
            path: argv.output,
            fullPage: argv.fullpage
        });

        console.log(JSON.stringify({
            success: true,
            path: argv.output
        }));

    } catch (error) {
        console.error(JSON.stringify({
            success: false,
            error: error.message
        }));
        process.exit(1);
    } finally {
        if (browser) await browser.close();
    }
})();
```

### 3. Create PowerShell Wrapper

**C:\scripts\tools\browser-screenshot.ps1:**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$Url,

    [string]$OutputPath = "screenshot.png",

    [switch]$FullPage
)

$scriptPath = Join-Path $PSScriptRoot "browser-scripts\screenshot.js"

$args = @(
    $scriptPath,
    "--url", $Url,
    "--output", $OutputPath
)

if ($FullPage) {
    $args += "--fullpage"
}

try {
    $output = node @args 2>&1 | Out-String
    $result = $output | ConvertFrom-Json

    if ($result.success) {
        Write-Host "✅ Screenshot saved: $($result.path)" -ForegroundColor Green
        return $result
    } else {
        Write-Error "❌ Screenshot failed: $($result.error)"
        return $null
    }

} catch {
    Write-Error "❌ Execution error: $_"
    return $null
}
```

### 4. Test It
```powershell
# Take screenshot of webpage
.\browser-screenshot.ps1 -Url "https://example.com" -OutputPath "test.png"

# Full page screenshot
.\browser-screenshot.ps1 -Url "https://example.com" -OutputPath "test-full.png" -FullPage
```

---

## Day 2: Add Robustness (3 hours)

### 1. Add Retry Logic

**C:\scripts\tools\browser-scripts\lib\retry.js:**
```javascript
async function retryWithBackoff(fn, options = {}) {
    const maxRetries = options.retries || 3;
    const baseDelay = options.baseDelay || 1000;

    for (let i = 0; i < maxRetries; i++) {
        try {
            return await fn();
        } catch (error) {
            const isLastAttempt = i === maxRetries - 1;

            if (isLastAttempt) {
                throw error;
            }

            // Exponential backoff with jitter
            const delay = Math.pow(2, i) * baseDelay;
            const jitter = delay * 0.2 * (Math.random() - 0.5);
            const totalDelay = delay + jitter;

            console.error(`Retry ${i + 1}/${maxRetries} after ${Math.round(totalDelay)}ms...`);

            await new Promise(resolve => setTimeout(resolve, totalDelay));
        }
    }
}

module.exports = { retryWithBackoff };
```

### 2. Create Robust Navigation Script

**C:\scripts\tools\browser-scripts\navigate.js:**
```javascript
#!/usr/bin/env node
const puppeteer = require('puppeteer');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');
const { retryWithBackoff } = require('./lib/retry');

const argv = yargs(hideBin(process.argv))
    .option('url', { type: 'string', demandOption: true })
    .option('screenshot', { type: 'string' })
    .option('retries', { type: 'number', default: 3 })
    .argv;

(async () => {
    let browser;
    try {
        browser = await puppeteer.launch({
            executablePath: 'C:\\Program Files\\BraveSoftware\\Brave-Browser\\Application\\brave.exe',
            headless: true,
            args: ['--no-sandbox']
        });

        const page = await browser.newPage();

        // Navigate with retry
        await retryWithBackoff(async () => {
            await page.goto(argv.url, {
                waitUntil: 'networkidle2',
                timeout: 30000
            });
        }, { retries: argv.retries });

        // Get page info
        const title = await page.title();
        const url = page.url();

        // Optional screenshot
        let screenshot = null;
        if (argv.screenshot) {
            await page.screenshot({ path: argv.screenshot });
            screenshot = argv.screenshot;
        }

        console.log(JSON.stringify({
            success: true,
            title: title,
            url: url,
            screenshot: screenshot
        }));

    } catch (error) {
        console.error(JSON.stringify({
            success: false,
            error: error.message
        }));
        process.exit(1);
    } finally {
        if (browser) await browser.close();
    }
})();
```

### 3. Add Form Filling Capability

**C:\scripts\tools\browser-scripts\fill-form.js:**
```javascript
#!/usr/bin/env node
const puppeteer = require('puppeteer');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

const argv = yargs(hideBin(process.argv))
    .option('url', { type: 'string', demandOption: true })
    .option('fields', { type: 'string', demandOption: true }) // JSON object
    .option('submit', { type: 'string' }) // Submit button selector
    .argv;

(async () => {
    let browser;
    try {
        const fields = JSON.parse(argv.fields);

        browser = await puppeteer.launch({
            executablePath: 'C:\\Program Files\\BraveSoftware\\Brave-Browser\\Application\\brave.exe',
            headless: true
        });

        const page = await browser.newPage();
        await page.goto(argv.url, { waitUntil: 'networkidle2' });

        const results = {};

        // Fill each field
        for (const [fieldName, value] of Object.entries(fields)) {
            try {
                const selector = `[name="${fieldName}"]`;

                // Wait for field
                await page.waitForSelector(selector, {
                    visible: true,
                    timeout: 10000
                });

                // Clear and type
                await page.click(selector, { clickCount: 3 }); // Select all
                await page.type(selector, value, { delay: 50 });

                results[fieldName] = { success: true };

            } catch (error) {
                results[fieldName] = {
                    success: false,
                    error: error.message
                };
            }
        }

        // Optional submit
        if (argv.submit) {
            await page.click(argv.submit);
            await page.waitForNavigation({ waitUntil: 'networkidle2' });
        }

        console.log(JSON.stringify({
            success: true,
            fields: results,
            url: page.url()
        }));

    } catch (error) {
        console.error(JSON.stringify({
            success: false,
            error: error.message
        }));
        process.exit(1);
    } finally {
        if (browser) await browser.close();
    }
})();
```

### 4. Create Unified PowerShell Interface

**C:\scripts\tools\browser-automation.ps1:**
```powershell
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('screenshot', 'navigate', 'fill-form', 'click', 'scrape')]
    [string]$Action,

    [Parameter(Mandatory=$true)]
    [string]$Url,

    [hashtable]$Options = @{}
)

$scriptsPath = Join-Path $PSScriptRoot "browser-scripts"
$scriptFile = Join-Path $scriptsPath "$Action.js"

if (-not (Test-Path $scriptFile)) {
    throw "Script not found: $scriptFile"
}

# Build arguments
$args = @(
    $scriptFile,
    "--url", $Url
)

# Add options
foreach ($key in $Options.Keys) {
    $value = $Options[$key]

    if ($value -is [hashtable] -or $value -is [array]) {
        # JSON encode complex types
        $jsonValue = $value | ConvertTo-Json -Compress
        $args += "--$key", $jsonValue
    } elseif ($value -is [bool]) {
        if ($value) {
            $args += "--$key"
        }
    } else {
        $args += "--$key", $value
    }
}

# Execute
try {
    Write-Verbose "Executing: node $($args -join ' ')"

    $output = node @args 2>&1 | Out-String
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        Write-Error "Browser automation failed: $output"
        return $null
    }

    # Parse JSON output
    return $output | ConvertFrom-Json

} catch {
    Write-Error "Execution error: $_"
    return $null
}
```

---

## Day 3: Integration & Testing (2 hours)

### 1. Test All Capabilities

```powershell
# Screenshot
$result = .\browser-automation.ps1 -Action screenshot -Url "https://example.com" -Options @{
    output = "test.png"
    fullpage = $true
}

# Navigation with retry
$result = .\browser-automation.ps1 -Action navigate -Url "https://example.com" -Options @{
    retries = 5
    screenshot = "nav.png"
}

# Form filling
$result = .\browser-automation.ps1 -Action fill-form -Url "https://example.com/form" -Options @{
    fields = @{
        username = "user@example.com"
        password = "secure123"
    }
    submit = "#submit-button"
}

Write-Host "Success: $($result.success)"
```

### 2. Integrate with Claude Bridge

**Update C:\scripts\tools\claude-bridge-tasks.ps1:**
```powershell
# Add browser automation tasks

function Test-BrowserForm {
    param(
        [string]$Url,
        [hashtable]$FormData
    )

    Write-Host "🌐 Testing form at: $Url" -ForegroundColor Cyan

    $result = .\browser-automation.ps1 -Action fill-form -Url $Url -Options @{
        fields = $FormData
        screenshot = "form-test.png"
    }

    if ($result.success) {
        Write-Host "✅ Form test passed" -ForegroundColor Green
        return $result
    } else {
        Write-Host "❌ Form test failed: $($result.error)" -ForegroundColor Red
        return $null
    }
}

# Usage in bridge tasks
if ($task.action -eq "test-form") {
    $result = Test-BrowserForm -Url $task.url -FormData $task.fields
    # Send result back to Browser Claude
}
```

### 3. Document Patterns

**C:\scripts\_machine\best-practices\browser-automation-patterns.md:**
```markdown
# Browser Automation Patterns

## Pattern 1: Screenshot with Retry
```powershell
$result = .\browser-automation.ps1 -Action screenshot -Url $url -Options @{
    output = "screenshot.png"
    fullpage = $true
}
```

## Pattern 2: Form Filling
```powershell
$result = .\browser-automation.ps1 -Action fill-form -Url $url -Options @{
    fields = @{
        email = "user@example.com"
        message = "Hello world"
    }
    submit = "#send-button"
}
```

## Pattern 3: SPA Navigation
```powershell
$result = .\browser-automation.ps1 -Action navigate -Url $url -Options @{
    waitUntil = "networkidle2"
    retries = 5
}
```
```

---

## Verification Checklist

After Day 3, verify:

- [ ] ✅ Puppeteer installed and working
- [ ] ✅ Screenshot capability working (basic + full page)
- [ ] ✅ Navigation with retry logic working
- [ ] ✅ Form filling working
- [ ] ✅ Error handling returns structured JSON
- [ ] ✅ PowerShell wrapper provides clean interface
- [ ] ✅ Integration with existing tools (Claude Bridge)
- [ ] ✅ Documentation created

---

## Next Steps (Week 2+)

1. **Add Visual Regression Testing**
   - Install BackstopJS
   - Create baseline screenshots
   - Add to CI/CD pipeline

2. **Add Click & Scrape Actions**
   - `click.js` - Smart element clicking with wait
   - `scrape.js` - Extract data from pages

3. **Create Browser Pool**
   - Reuse browser instances for performance
   - Manage lifecycle (acquire/release)

4. **CI/CD Integration**
   - Docker container for headless browser
   - GitHub Actions workflow
   - Parallel test execution

---

## Common Issues & Solutions

### Issue: "Browser not found"
**Solution:** Update `executablePath` in scripts:
```javascript
executablePath: 'C:\\Program Files\\BraveSoftware\\Brave-Browser\\Application\\brave.exe'
```

### Issue: "Timeout waiting for selector"
**Solution:** Increase timeout or add retry:
```javascript
await page.waitForSelector(selector, {
    visible: true,
    timeout: 30000 // 30 seconds
});
```

### Issue: "Navigation timeout"
**Solution:** Use retry logic:
```javascript
await retryWithBackoff(async () => {
    await page.goto(url, { waitUntil: 'networkidle2' });
}, { retries: 5 });
```

### Issue: "Element not interactable"
**Solution:** Wait for element to be ready:
```javascript
await page.waitForSelector(selector, { state: 'visible' });
await page.waitForTimeout(500); // Wait for animations
await page.click(selector);
```

---

## Performance Benchmarks (Expected)

| Operation | Raw CDP | Puppeteer | Improvement |
|-----------|---------|-----------|-------------|
| **Reliability** | ~60% | ~95% | +35% |
| **Maintenance Time** | High | Low | -80% |
| **Error Recovery** | Manual | Automatic | +100% |
| **Speed** | Fast | Fast | Same |

---

**Migration Path:** 3 days to production-ready browser automation
**Effort:** ~7 hours total
**Impact:** 🚀 Transform brittle CDP into enterprise-grade automation
