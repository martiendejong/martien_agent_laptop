# Browser Testing with Puppeteer

**Created:** 2026-01-14
**Context:** Automated testing of Brand2Boost frontend

## Setup

### Starting Browser with Remote Debugging
```powershell
# Brave browser
& "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" --remote-debugging-port=9222

# Chrome
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

### Connecting with Puppeteer
```javascript
const puppeteer = require('puppeteer-core');

const browser = await puppeteer.connect({
  browserURL: 'http://localhost:9222',
  defaultViewport: null
});

const pages = await browser.pages();
const page = pages.find(p => p.url().includes('localhost:5173'));
```

## React Form Handling

### The Problem
Setting `input.value` directly doesn't trigger React state updates because React uses synthetic events and tracks values internally.

### Solution: Native Value Setter with _valueTracker Hack
```javascript
function setNativeValue(element, value) {
  const lastValue = element.value;
  element.value = value;
  const event = new Event('input', { bubbles: true });

  // React 15/16+ hack - reset the internal tracker
  const tracker = element._valueTracker;
  if (tracker) {
    tracker.setValue(lastValue);
  }
  element.dispatchEvent(event);
}

// Usage in page.evaluate()
await page.evaluate((email, password) => {
  const inputs = document.querySelectorAll('input');
  const emailInput = Array.from(inputs).find(i => i.type === 'email');
  setNativeValue(emailInput, email);
}, testEmail, testPassword);
```

### Alternative: Use Puppeteer's type() method
```javascript
const input = await page.$('input[type="email"]');
await input.click({ clickCount: 3 }); // Select all
await input.type('test@example.com');
```
**Note:** This can be slow and sometimes hangs on React apps.

## API Monitoring

### Capture Network Requests
```javascript
page.on('request', req => {
  if (req.url().includes('/api/')) {
    console.log(`>> ${req.method()} ${req.url()}`);
    if (req.postData()) console.log(`   Body: ${req.postData()}`);
  }
});

page.on('response', async res => {
  if (res.url().includes('/api/')) {
    const body = await res.text().catch(() => '');
    console.log(`<< [${res.status()}] ${res.url()}`);
  }
});
```

## Clicking Elements

### By Coordinates (most reliable for overlays/modals)
```javascript
await page.mouse.click(340, 25);
```

### By Selector in page.evaluate()
```javascript
await page.evaluate(() => {
  const btns = Array.from(document.querySelectorAll('button'));
  const target = btns.find(b => b.textContent.includes('Submit'));
  if (target) target.click();
});
```

## Screenshots

### Save to structured folder
```javascript
const testFolder = 'C:/testresults/brand2boost/test-name-2026-01-14';
await page.screenshot({
  path: `${testFolder}/screenshot-step1.png`,
  fullPage: true  // Optional: capture entire scrollable area
});
```

## Test Results Organization

All test artifacts go to:
```
C:\testresults\
├── <application>\
│   └── <test-name-YYYY-MM-DD>\
│       ├── TEST_SUMMARY.md
│       ├── screenshot-*.png
│       └── logs/
```

## Common Issues

| Issue | Solution |
|-------|----------|
| `page.waitForTimeout is not a function` | Use `await new Promise(r => setTimeout(r, 1000))` |
| `page.$x is not a function` | Use `page.evaluate()` with DOM queries |
| React inputs not updating | Use `_valueTracker` hack (see above) |
| Sidebar blocking clicks | Click by coordinates or close overlay first |
| Script hangs on `input.type()` | Use `page.keyboard.type()` after clicking |

## Example: Complete Registration Test

```javascript
const puppeteer = require('puppeteer-core');

async function testRegistration() {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9222',
    defaultViewport: null
  });

  const pages = await browser.pages();
  const page = pages.find(p => p.url().includes('localhost:5173'));

  // Fill form with React-compatible method
  await page.evaluate((name, email, password) => {
    function setNativeValue(el, val) {
      const last = el.value;
      el.value = val;
      const tracker = el._valueTracker;
      if (tracker) tracker.setValue(last);
      el.dispatchEvent(new Event('input', { bubbles: true }));
    }

    const inputs = document.querySelectorAll('input');
    const nameInput = Array.from(inputs).find(i => i.type === 'text');
    const emailInput = Array.from(inputs).find(i => i.type === 'email');
    const pwInputs = Array.from(inputs).filter(i => i.type === 'password');

    if (nameInput) setNativeValue(nameInput, name);
    if (emailInput) setNativeValue(emailInput, email);
    if (pwInputs[0]) setNativeValue(pwInputs[0], password);
    if (pwInputs[1]) setNativeValue(pwInputs[1], password);
  }, 'Test User', 'test@example.com', 'Password123!');

  await page.screenshot({ path: 'C:/testresults/app/test/filled.png' });

  // Submit
  await page.evaluate(() => {
    const btn = Array.from(document.querySelectorAll('button'))
      .find(b => b.textContent.toLowerCase().includes('create account'));
    if (btn) btn.click();
  });

  await new Promise(r => setTimeout(r, 3000));
  await page.screenshot({ path: 'C:/testresults/app/test/result.png' });
}
```
