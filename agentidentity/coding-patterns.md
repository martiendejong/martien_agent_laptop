# Coding Patterns & Anti-Patterns

Practical learnings from development sessions. Referenced from MEMORY.md.

---

## CSS Root Cause Analysis (2026-02-28) - CRITICAL PATTERN

**Context:** Bliek Vastgoed React app, task reopened 3x because agents claimed "FIXED" but buttons were still grey

**Root cause:** All `.button-*` CSS class definitions were COMPLETELY MISSING from main.css. Buttons in JSX used `className="button button-primary"` but the CSS rules didn't exist.

**The Pattern:**
When multiple UI elements look broken across different pages, the root cause is almost always a MISSING SHARED STYLE DEFINITION, not individual element issues.

**Methodology for "X looks wrong" tasks:**
1. Grep for CSS class names used in JSX components (e.g., `button-primary`)
2. Check if base class DEFINITIONS exist in the stylesheet (not just usage)
3. If missing -> add complete CSS system matching HTML prototype
4. If present but wrong -> compare with HTML prototype CSS values
5. Verify on ALL pages (not just the one mentioned in the task)

**Anti-patterns that caused 3 reopenings:**
- Patching individual buttons with inline styles instead of adding base CSS system
- Claiming "FIXED" after checking 1-2 pages (user explicitly said "go through everything")
- Not reading ClickUp comment history (user had given specific page URLs)
- Not browser-testing with Playwright MCP (just reading code)

**Verification protocol for cross-cutting CSS fixes:**
1. Get ALL routes from App.tsx / router config
2. Screenshot EVERY page via Playwright
3. Scroll to bottom of long pages
4. Click through tabs/modals to check inner content
5. Only post ClickUp "FIXED" comment after 100% page coverage

---

## Sticky Sidebar Pattern (2026-02-28)

```css
.sidebar { position: sticky; top: 100px; height: fit-content; }
@media (max-width: 1024px) { .sidebar { position: static; } }
```

`height: fit-content` is essential - without it, sticky doesn't work on content shorter than viewport.

---

## Backend Enum → Frontend Type Safety (2026-02-28) - CRITICAL PATTERN

**Context:** Bliek Vastgoed - Dashboard worked, but Woningzoekenden crashed with `TypeError: clients.filter is not a function` and `status.toLowerCase is not a function`

**Root cause:**
1. ASP.NET Core serializes C# enums as numbers (0, 1, 2)
2. Frontend TypeScript expected strings ('Active', 'Inactive')
3. PagedResult wrapper not unwrapped (missing `.items`)

**The Pattern - 4-Layer Enum Safety:**

```typescript
// 1. Define enum matching backend values
export enum ClientStatus {
  Active = 0,
  Inactive = 1,
  Converted = 2
}

// 2. Label helper (number → display string)
export function getClientStatusLabel(status: number): string {
  switch (status) {
    case ClientStatus.Active: return 'Actief'
    case ClientStatus.Inactive: return 'Inactief'
    case ClientStatus.Converted: return 'Geconverteerd'
    default: return 'Onbekend'
  }
}

// 3. Class helper (number → CSS class)
export function getClientStatusClass(status: number): string {
  switch (status) {
    case ClientStatus.Active: return 'active'
    case ClientStatus.Inactive: return 'inactive'
    case ClientStatus.Converted: return 'converted'
    default: return 'unknown'
  }
}

// 4. Interface uses number (NOT string)
export interface Client {
  status: number  // CRITICAL
}
```

**Usage in components:**
```typescript
// Stats calculation
stats.active = clients.filter(c => c.status === ClientStatus.Active).length

// Display
<span className={`badge badge-${getClientStatusClass(client.status as any)}`}>
  {getClientStatusLabel(client.status as any)}
</span>
```

**Checklist for ALL entity types:**
- [ ] Backend enum definition checked (0, 1, 2 values)
- [ ] Frontend enum matches backend
- [ ] Interface property type is `number`
- [ ] Label helper created
- [ ] Class helper created
- [ ] Component imports both helpers
- [ ] No string comparisons (`status === 'Active'` is WRONG)

**Applied to:**
- PropertyStatus (Concept=0, Live=1, Sold=2, Rented=3, Offline=4)
- ClientStatus (Active=0, Inactive=1, Converted=2)
- ViewingStatus (Planned=0, Confirmed=1, Completed=2, Cancelled=3, NoShow=4)
- PropertyType, TransactionType (same pattern)

**Detection:**
- `TypeError: x.toLowerCase is not a function` on enum value
- Enum comparisons return false when they should be true
- Display shows "0" instead of "Active"

---

## PagedResult API Response Pattern (2026-02-28)

**Context:** Backend returns paginated results wrapped in `{ items: T[], totalCount: number }`

**Symptom:** `TypeError: data.filter is not a function` when treating PagedResult as array

**Solution:**
```typescript
// Service returns PagedResult<T>
async search(filter: Filter): Promise<PagedResult<T>> {
  const response = await api.get<PagedResult<T>>('/endpoint', { params: filter })
  return response.data  // Returns { items: [...], totalCount: 10 }
}

// Component MUST extract .items
const data = await service.search(filter)
setItems(data.items)  // NOT setItems(data)
setTotal(data.totalCount)
```

**Files using this pattern:**
- property.service.ts → PropertySearchResult
- client.service.ts → PagedResult<Client>
- viewing.service.ts → (verify if needed)

---

## Browser Testing MANDATORY Protocol (2026-02-28)

**Context:** User explicitly said "je moet integratietesten doen" after I claimed "klaar" without testing

**The Rule:** TypeScript compilation success ≠ runtime success

**MANDATORY steps before claiming "done":**

1. **Test ALL pages** (not just the one you edited)
2. **Use Browser MCP** (Playwright automation)
3. **Check console for errors** (0 errors = success)
4. **Screenshot evidence** (save proof)
5. **Test complete user flows** (login → dashboard → detail pages)

**Testing template:**
```typescript
// Navigate and capture state
await page.goto('http://localhost:3501/login')
await page.fill('[name="email"]', 'admin@bliekvastgoed.nl')
await page.fill('[name="password"]', 'Admin#123')
await page.click('button[type="submit"]')

// Verify no console errors
// Console: 0 errors, 0 warnings = SUCCESS
```

**Anti-pattern:**
- ❌ "Dashboard works, so all pages work" (WRONG - each page can have unique errors)
- ❌ "TypeScript compiled cleanly" (WRONG - runtime errors still possible)
- ❌ Testing only 1-2 pages (WRONG - must test ALL)

**Bliek Vastgoed pages to test:**
1. /login
2. /dashboard (stats, properties, viewings)
3. /aanbod (property list with filters)
4. /woningzoekenden (client list)
5. /bezichtigingen (viewing calendar)
6. /instellingen (settings)

**Success criteria:** 0 console errors on ALL pages

---

## Bliek Vastgoed Project Context (2026-02-28)

**Frontend:** E:\projects\bliek\frontend-react\ (React 18 + TypeScript + Vite, dev ports 3500/3501)
**Backend:** E:\projects\bliek\src\Bliek.API\ (ASP.NET Core 9.0, HTTPS: 7000, HTTP: 5000)
**Prototype:** E:\projects\bliek\frontend-prototype\ (HTML source of truth)
**ClickUp List:** 901216032110
**Database:** PostgreSQL + Entity Framework Core

**Authentication:**
- Admin: admin@bliekvastgoed.nl / Admin#123
- JWT Bearer tokens
- Vite proxy: /api → https://localhost:7000

**Pages:** /login, /dashboard, /aanbod, /aanbod/:id, /woningzoekenden, /woningzoekenden/:id, /bezichtigingen, /instellingen, /woning/:id (public)

**CSS variables from prototype:** --primary: #2563eb, --text-secondary: #475569, --border: #e2e8f0

**Key files:**
- main.css: All shared styles (buttons, sidebar, layout)
- App.tsx: Route definitions
- utils/enums.ts: Enum helpers (PropertyStatus, ClientStatus, ViewingStatus)
- services/*.service.ts: API integration with PagedResult handling
- WoningPubliek.tsx: Public woning page (gallery, map, sidebar)
- AanbodDetailPerfect.tsx: Admin property detail with tabs
