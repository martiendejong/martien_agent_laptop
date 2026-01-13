# Accessibility Testing Guide ♿

**Purpose:** Ensure Brand2Boost is usable by everyone, including users with disabilities.

**Goal:** WCAG 2.1 Level AA compliance, keyboard navigation, screen reader support.

---

## Why Accessibility Matters

**Legal:** ADA compliance in US, EAA in EU (mandatory 2025)
**Ethical:** 15% of world population has disabilities
**Business:** Larger addressable market
**SEO:** Better semantic HTML improves search rankings
**UX:** Benefits all users (keyboard shortcuts, clear contrast)

---

## Quick Accessibility Checklist

**Before every deploy:**

- [ ] All interactive elements keyboard accessible (Tab, Enter, Space)
- [ ] Color contrast ≥ 4.5:1 for text
- [ ] All images have alt text
- [ ] Form inputs have labels
- [ ] Error messages are descriptive
- [ ] Focus indicators visible
- [ ] No keyboard traps
- [ ] ARIA labels where needed
- [ ] Screen reader tested (NVDA or VoiceOver)
- [ ] Automated scan with axe-core passes

---

## WCAG 2.1 Level AA Requirements

### 1. Perceivable (Users Can Perceive Content)

#### 1.1 Text Alternatives

**Provide alt text for images:**

```tsx
// ✅ CORRECT
<img src="/logo.png" alt="Brand2Boost logo" />

// ❌ WRONG
<img src="/logo.png" />  // Missing alt

// ✅ Decorative images
<img src="/divider.png" alt="" />  // Empty alt = decorative
```

**Icon buttons need labels:**

```tsx
// ✅ CORRECT
<button aria-label="Close dialog">
  <XIcon />
</button>

// ❌ WRONG
<button>
  <XIcon />  // Screen reader says "button" (no context)
</button>
```

#### 1.2 Time-Based Media

**Provide captions for videos:**

```tsx
<video controls>
  <source src="demo.mp4" type="video/mp4" />
  <track kind="captions" src="captions-en.vtt" srclang="en" label="English" />
</video>
```

#### 1.3 Adaptable

**Use semantic HTML:**

```tsx
// ✅ CORRECT: Semantic structure
<header>
  <nav>
    <ul>
      <li><a href="/">Home</a></li>
    </ul>
  </nav>
</header>
<main>
  <article>
    <h1>Page Title</h1>
    <p>Content...</p>
  </article>
</main>
<footer>Copyright 2026</footer>

// ❌ WRONG: Divs everywhere
<div class="header">
  <div class="nav">
    <div><a href="/">Home</a></div>
  </div>
</div>
<div class="content">...</div>
```

**Form labels:**

```tsx
// ✅ CORRECT
<label htmlFor="email">Email</label>
<input id="email" type="email" />

// ❌ WRONG
<input type="email" placeholder="Email" />  // Placeholder is NOT a label
```

#### 1.4 Distinguishable

**Color contrast:**

```css
/* ✅ CORRECT: 4.5:1 contrast */
.text {
  color: #333333;  /* Dark gray */
  background: #FFFFFF;  /* White */
}

/* ❌ WRONG: Low contrast */
.text {
  color: #CCCCCC;  /* Light gray on white = 1.6:1 */
  background: #FFFFFF;
}
```

**Check contrast:** https://webaim.org/resources/contrastchecker/

**Don't rely on color alone:**

```tsx
// ✅ CORRECT: Icon + color
<div className="error">
  <XCircleIcon /> Error: Email is required
</div>

// ❌ WRONG: Color only
<div className="text-red-500">
  Email is required  // Colorblind users can't see this is an error
</div>
```

**Text resizing (up to 200%):**

```css
/* ✅ Use rem units (scales with browser font size) */
.text {
  font-size: 1rem;  /* 16px default, scales to 32px at 200% */
}

/* ❌ Don't use px for text */
.text {
  font-size: 16px;  /* Doesn't scale */
}
```

---

### 2. Operable (Users Can Operate Interface)

#### 2.1 Keyboard Accessible

**All functionality available via keyboard:**

```tsx
// ✅ CORRECT: Button is keyboard accessible by default
<button onClick={handleClick}>Submit</button>

// ❌ WRONG: Div is not keyboard accessible
<div onClick={handleClick}>Submit</div>  // Can't Tab to this!

// ✅ If you MUST use div, add keyboard support
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  }}
>
  Submit
</div>
```

**Keyboard shortcuts:**

```tsx
useEffect(() => {
  const handleKeyDown = (e: KeyboardEvent) => {
    // Ctrl+K: Open search
    if (e.ctrlKey && e.key === 'k') {
      e.preventDefault();
      openSearch();
    }
  };

  window.addEventListener('keydown', handleKeyDown);
  return () => window.removeEventListener('keydown', handleKeyDown);
}, []);
```

**Document keyboard shortcuts:**

- `Tab` - Next element
- `Shift+Tab` - Previous element
- `Enter` - Activate button/link
- `Space` - Toggle checkbox/button
- `Esc` - Close dialog/dropdown
- `Arrow keys` - Navigate lists/menus

#### 2.2 Enough Time

**No time limits (or allow extension):**

```tsx
// ✅ CORRECT: Allow user to extend session
<Dialog open={sessionExpiring}>
  <p>Your session will expire in 60 seconds.</p>
  <button onClick={extendSession}>Extend Session</button>
</Dialog>

// ❌ WRONG: Auto-logout without warning
setTimeout(logout, 300000);  // 5 minutes, no warning
```

#### 2.3 Seizures and Physical Reactions

**No flashing content >3 times per second:**

```tsx
// ❌ WRONG: Rapid flashing
<div className="animate-pulse">...</div>  // May trigger seizures

// ✅ CORRECT: Slow, gentle animations
<div className="transition-opacity duration-500">...</div>
```

#### 2.4 Navigable

**Skip to main content link:**

```tsx
// At top of page (visually hidden until focused)
<a href="#main-content" className="sr-only focus:not-sr-only">
  Skip to main content
</a>

<main id="main-content">
  {/* Page content */}
</main>
```

**Descriptive page titles:**

```tsx
// ✅ CORRECT
<Helmet>
  <title>Dashboard - Brand2Boost</title>
</Helmet>

// ❌ WRONG
<title>Page</title>
```

**Focus order matches visual order:**

```tsx
// ✅ CORRECT: Visual order = DOM order
<div>
  <button>First</button>   {/* tabIndex 1 */}
  <button>Second</button>  {/* tabIndex 2 */}
  <button>Third</button>   {/* tabIndex 3 */}
</div>

// ❌ WRONG: Using tabIndex to reorder
<button tabIndex={3}>Third</button>
<button tabIndex={1}>First</button>
<button tabIndex={2}>Second</button>
```

**Link purpose clear from text:**

```tsx
// ✅ CORRECT
<a href="/pricing">View pricing plans</a>

// ❌ WRONG
<a href="/pricing">Click here</a>  // "Click here" is not descriptive
```

**Breadcrumbs:**

```tsx
<nav aria-label="Breadcrumb">
  <ol>
    <li><a href="/">Home</a></li>
    <li><a href="/brands">Brands</a></li>
    <li aria-current="page">My Brand</li>
  </ol>
</nav>
```

**Focus indicators:**

```css
/* ✅ CORRECT: Visible focus ring */
button:focus-visible {
  outline: 2px solid #3B82F6;
  outline-offset: 2px;
}

/* ❌ WRONG: No focus indicator */
button:focus {
  outline: none;  /* NEVER DO THIS */
}
```

---

### 3. Understandable (Content is Understandable)

#### 3.1 Readable

**Specify language:**

```html
<html lang="en">  <!-- Page language -->

<p lang="es">Hola</p>  <!-- Inline language change -->
```

#### 3.2 Predictable

**Navigation consistent across pages:**

```tsx
// Same navigation on every page
<Navigation>
  <NavLink to="/">Home</NavLink>
  <NavLink to="/brands">Brands</NavLink>
  <NavLink to="/settings">Settings</NavLink>
</Navigation>
```

**No surprises on focus/input:**

```tsx
// ❌ WRONG: Dropdown auto-submits on selection
<select onChange={handleSubmit}>...</select>

// ✅ CORRECT: Explicit submit button
<select onChange={handleChange}>...</select>
<button onClick={handleSubmit}>Submit</button>
```

#### 3.3 Input Assistance

**Label all form inputs:**

```tsx
<label htmlFor="email">Email *</label>
<input
  id="email"
  type="email"
  required
  aria-required="true"
  aria-describedby="email-error"
/>
<span id="email-error" role="alert">
  {emailError}
</span>
```

**Error identification:**

```tsx
// ✅ CORRECT: Clear error message
<Input
  aria-invalid={hasError}
  aria-describedby="password-error"
/>
{hasError && (
  <p id="password-error" role="alert">
    Password must be at least 8 characters
  </p>
)}

// ❌ WRONG: No error message
<Input className={hasError ? 'border-red-500' : ''} />
```

**Error prevention (confirmations):**

```tsx
<Dialog>
  <p>Are you sure you want to delete this brand? This cannot be undone.</p>
  <button onClick={confirmDelete}>Delete Brand</button>
  <button onClick={closeDialog}>Cancel</button>
</Dialog>
```

---

### 4. Robust (Works with Assistive Tech)

#### 4.1 Compatible

**Valid HTML:**

```tsx
// ✅ CORRECT
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>

// ❌ WRONG: Invalid nesting
<ul>
  <div>Item 1</div>  // div not allowed in ul
</ul>
```

**ARIA attributes:**

```tsx
// Modal dialog
<div
  role="dialog"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-description"
  aria-modal="true"
>
  <h2 id="dialog-title">Confirm Delete</h2>
  <p id="dialog-description">Are you sure?</p>
</div>

// Loading state
<button aria-busy="true" aria-live="polite">
  Loading...
</button>

// Expandable section
<button
  aria-expanded={isOpen}
  aria-controls="content-id"
>
  Toggle Content
</button>
<div id="content-id" hidden={!isOpen}>
  Content...
</div>
```

---

## Automated Testing

### axe-core (Browser Extension)

**Install:**
- Chrome: [axe DevTools](https://chrome.google.com/webstore/detail/axe-devtools-web-accessibility/lhdoppojpmngadmnindnejefpokejbdd)
- Firefox: [axe DevTools](https://addons.mozilla.org/en-US/firefox/addon/axe-devtools/)

**Usage:**
1. Open page in browser
2. Open DevTools (F12)
3. Go to "axe DevTools" tab
4. Click "Scan ALL of my page"
5. Fix all Critical and Serious issues
6. Review Moderate issues

### axe-core (Integration Tests)

**Install:**
```bash
npm install --save-dev @axe-core/react jest-axe
```

**Test:**
```typescript
import { axe, toHaveNoViolations } from 'jest-axe';
import { render } from '@testing-library/react';

expect.extend(toHaveNoViolations);

test('LoginForm should have no accessibility violations', async () => {
  const { container } = render(<LoginForm />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

### Playwright (E2E Tests)

**Install:**
```bash
npm install --save-dev @axe-core/playwright
```

**Test:**
```typescript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('Homepage should be accessible', async ({ page }) => {
  await page.goto('/');

  const results = await new AxeBuilder({ page }).analyze();

  expect(results.violations).toEqual([]);
});
```

---

## Manual Testing

### Keyboard Navigation

**Test steps:**
1. **Tab through entire page** - Can you reach all interactive elements?
2. **Shift+Tab** - Does reverse tab order work?
3. **Enter/Space on buttons** - Do they activate?
4. **Esc on dialogs** - Do they close?
5. **Arrow keys in dropdowns** - Can you navigate?
6. **No keyboard traps** - Can you always tab out?

### Screen Reader Testing

#### NVDA (Windows, Free)

**Download:** https://www.nvaccess.org/download/

**Test:**
1. Start NVDA (Ctrl+Alt+N)
2. Navigate with Tab
3. Listen to announcements
4. Check:
   - Form labels read correctly
   - Buttons have clear names
   - Errors announced
   - Page structure makes sense

**Common commands:**
- `Tab` - Next interactive element
- `H` - Next heading
- `K` - Next link
- `F` - Next form field
- `Insert+Down` - Read all (from cursor)

#### VoiceOver (macOS, Built-in)

**Start:** Cmd+F5

**Test:**
- `VO` = Ctrl+Option
- `VO+A` - Read all
- `VO+Right Arrow` - Next item
- `VO+Cmd+H` - Next heading

#### JAWS (Windows, Commercial)

**Most popular screen reader** (enterprise)

**40-minute demo:** https://www.freedomscientific.com/downloads/jaws/

### Color Contrast Testing

**Tools:**
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Chrome DevTools: Inspect element → "Contrast ratio" in Styles panel
- [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/) (desktop app)

**Requirements:**
- Normal text: **4.5:1** minimum
- Large text (18pt+): **3:1** minimum
- UI components: **3:1** minimum

### Zoom Testing

**Test at 200% zoom:**
```
Browser: Ctrl + "++" (zoom in)
Expected: All content visible, no horizontal scroll
```

### Color Blindness Testing

**Tools:**
- [Colorblind Web Page Filter](https://www.toptal.com/designers/colorfilter)
- Chrome extension: [Colorblindly](https://chrome.google.com/webstore/detail/colorblindly/floniaahmccleoclneebhhmnjgdfijgg)

**Test for:**
- Deuteranopia (green-blind, 5% of males)
- Protanopia (red-blind, 1% of males)
- Tritanopia (blue-blind, rare)

---

## Common Accessibility Patterns

### Modal Dialog

```tsx
import { Dialog } from '@radix-ui/react-dialog';

<Dialog.Root open={isOpen} onOpenChange={setIsOpen}>
  <Dialog.Trigger asChild>
    <button>Open Dialog</button>
  </Dialog.Trigger>

  <Dialog.Portal>
    <Dialog.Overlay className="fixed inset-0 bg-black/50" />
    <Dialog.Content
      className="fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2"
      aria-describedby="dialog-description"
    >
      <Dialog.Title>Dialog Title</Dialog.Title>
      <Dialog.Description id="dialog-description">
        Dialog description...
      </Dialog.Description>

      <button onClick={() => setIsOpen(false)}>Close</button>
    </Dialog.Content>
  </Dialog.Portal>
</Dialog.Root>
```

**What it does:**
- Traps focus inside dialog
- Esc closes dialog
- Proper ARIA attributes
- Announces to screen readers

### Dropdown Menu

```tsx
import { DropdownMenu } from '@radix-ui/react-dropdown-menu';

<DropdownMenu.Root>
  <DropdownMenu.Trigger asChild>
    <button aria-label="Options">
      <DotsIcon />
    </button>
  </DropdownMenu.Trigger>

  <DropdownMenu.Portal>
    <DropdownMenu.Content>
      <DropdownMenu.Item onSelect={handleEdit}>
        Edit
      </DropdownMenu.Item>
      <DropdownMenu.Item onSelect={handleDelete}>
        Delete
      </DropdownMenu.Item>
    </DropdownMenu.Content>
  </DropdownMenu.Portal>
</DropdownMenu.Root>
```

**Keyboard:**
- Enter/Space opens menu
- Arrow keys navigate
- Enter selects item
- Esc closes menu

### Loading State

```tsx
<button disabled={isLoading} aria-busy={isLoading}>
  {isLoading ? (
    <>
      <Spinner aria-hidden="true" />
      <span className="sr-only">Loading...</span>
    </>
  ) : (
    'Submit'
  )}
</button>
```

### Toast Notifications

```tsx
<div
  role="status"  // or "alert" for urgent
  aria-live="polite"  // or "assertive" for urgent
  aria-atomic="true"
>
  Brand saved successfully
</div>
```

**`aria-live` values:**
- `polite` - Announce when user is idle
- `assertive` - Interrupt and announce immediately
- `off` - Don't announce

---

## React Components (Accessible by Default)

**Use these libraries (already accessible):**

### Radix UI (Recommended)
```bash
npm install @radix-ui/react-dialog @radix-ui/react-dropdown-menu
```

**Pros:**
- Unstyled (bring your own CSS)
- Fully accessible
- Keyboard navigation built-in
- ARIA attributes automatic

### Headless UI (Tailwind Labs)
```bash
npm install @headlessui/react
```

**Pros:**
- Works great with Tailwind
- Accessible
- Small bundle size

### React Aria (Adobe)
```bash
npm install react-aria
```

**Pros:**
- Most comprehensive
- Handles complex patterns
- Industry-leading accessibility

---

## Accessibility Checklist by Component

### Navigation

- [ ] Skip to main content link
- [ ] Current page indicated (`aria-current="page"`)
- [ ] Keyboard navigable
- [ ] Focus indicators visible
- [ ] Mobile menu keyboard accessible

### Forms

- [ ] All inputs have labels
- [ ] Required fields marked (`aria-required`)
- [ ] Errors have `role="alert"`
- [ ] Error messages descriptive
- [ ] Focus on first error after submit
- [ ] Field help text linked (`aria-describedby`)

### Buttons

- [ ] Clear labels (not "Click here")
- [ ] Icon-only buttons have `aria-label`
- [ ] Disabled state announced
- [ ] Loading state announced (`aria-busy`)
- [ ] Keyboard activatable (Enter/Space)

### Images

- [ ] Alt text provided
- [ ] Decorative images have empty alt (`alt=""`)
- [ ] Complex images have long descriptions

### Tables

- [ ] `<th>` for headers
- [ ] `scope` attribute on headers
- [ ] Caption provided (`<caption>`)
- [ ] Sortable columns announced

### Modals/Dialogs

- [ ] Focus trapped inside
- [ ] Esc closes dialog
- [ ] Focus returns to trigger on close
- [ ] `aria-modal="true"`
- [ ] Title and description linked

---

## CI/CD Integration

**Add to GitHub Actions:**

`.github/workflows/a11y-tests.yml`:
```yaml
name: Accessibility Tests

on: [push, pull_request]

jobs:
  a11y:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install dependencies
        run: npm install

      - name: Run axe tests
        run: npm run test:a11y

      - name: Build app
        run: npm run build

      - name: Start server
        run: npm run preview &

      - name: Wait for server
        run: npx wait-on http://localhost:4173

      - name: Run Pa11y
        run: npx pa11y-ci http://localhost:4173
```

**Fail build if accessibility issues found.**

---

## Accessibility Statement

**Add to website:**

`/accessibility` page:

```markdown
# Accessibility Statement

Brand2Boost is committed to ensuring digital accessibility for people with disabilities. We continually improve the user experience for everyone and apply relevant accessibility standards.

## Conformance Status

We aim for WCAG 2.1 Level AA conformance. This means:
- All content is keyboard accessible
- Color contrast meets minimum ratios
- Forms are labeled and errors are clear
- Screen readers can navigate our site

## Feedback

We welcome feedback on accessibility. If you encounter barriers:
- Email: accessibility@brand2boost.com
- We will respond within 2 business days

## Technical Specifications

Our website works with:
- Screen readers (NVDA, JAWS, VoiceOver)
- Browser zoom up to 200%
- Keyboard-only navigation
- Voice recognition software

## Known Issues

We are working on:
- [List any known issues]

Last updated: 2026-01-08
```

---

## Resources

**Guidelines:**
- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM Articles](https://webaim.org/articles/)
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)

**Testing Tools:**
- [axe DevTools](https://www.deque.com/axe/devtools/)
- [WAVE Browser Extension](https://wave.webaim.org/extension/)
- [Lighthouse (Chrome)](https://developers.google.com/web/tools/lighthouse)
- [Pa11y](https://pa11y.org/) - Command-line testing

**Screen Readers:**
- [NVDA](https://www.nvaccess.org/) (Windows, free)
- [JAWS](https://www.freedomscientific.com/products/software/jaws/) (Windows, commercial)
- VoiceOver (macOS/iOS, built-in)
- [TalkBack](https://support.google.com/accessibility/android/answer/6283677) (Android, built-in)

**Courses:**
- [Web Accessibility by Google](https://www.udacity.com/course/web-accessibility--ud891) (Free)
- [Deque University](https://dequeuniversity.com/) (Paid)

---

**Last Updated:** 2026-01-08
**WCAG Level:** AA (Goal)
**Next Audit:** 2026-04-01
**Maintained by:** Frontend Team
