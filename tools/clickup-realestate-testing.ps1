$apiKey = 'pk_74525428_P1UEETHS67964EXW4K4ZOPR1F1TWL0NI'

$tasks = @(
    @{
        id = '869ceqgnc'
        pr = '#136'
        review = @"
📝 CODE REVIEW (Automated by Claude Code Agent)

## PR Analysis
- **PR #136**: [869ceqgnc] Add responsive hamburger menu for mobile sidebar navigation
- **Status**: MERGED ✅
- **Files Changed**: 3 (Sidebar.tsx, MainLayout.tsx, main.css)

## Functionality Review ✅
- Sidebar accepts isOpen/onClose props with sensible defaults (isOpen=false)
- MainLayout manages sidebarOpen state — correct separation of concerns
- Overlay div conditionally rendered (no DOM waste when closed)
- .open CSS class applied via template literal — clean
- onClick={onClose} on each nav item — sidebar closes on navigation ✅
- aria-label on hamburger button — accessibility ✅
- CSS uses position:fixed, left:-260px → 0 transition — standard mobile drawer pattern ✅

## Code Quality Assessment ✅
- SidebarProps interface with optional props and defaults
- Fragment wrapper handles the overlay + aside cleanly
- Mobile-first CSS with @media (max-width: 768px)
- .content-area flex wrapper with min-width:0 prevents overflow issues

## Issues Found
None — clean implementation.

## Verdict
✅ APPROVED — Merged to develop.

---
Review conducted by Claude Code Agent | 2026-03-12
"@
    },
    @{
        id = '869cekk7m'
        pr = '#137'
        review = @"
📝 CODE REVIEW (Automated by Claude Code Agent)

## PR Analysis
- **PR #137**: [869cekk7m] Complete API Integration Layer
- **Status**: MERGED ✅
- **Files Changed**: 5 (analytics.service.ts new, api.ts, index.ts, WoningPubliek.tsx, PropertyCard.tsx)

## Functionality Review ✅
- analytics.service.ts covers all 4 acceptance criteria endpoints (trackView, trackLead, getPropertyAnalytics, getDashboardStats)
- Caching: in-memory Map with TTL — reduces redundant API calls ✅
- Retry logic: 3-step exponential backoff (500ms/1s/2s) on network errors + 5xx ✅
- Skips retry on 4xx (client errors not retryable) ✅
- Skips retry on 401 (handled by token refresh) ✅
- Optimistic favorites update with revert on error ✅
- Analytics tracking never throws — fire-and-forget pattern correct ✅
- Visitor ID persisted to localStorage with crypto.randomUUID() ✅

## Code Quality Assessment ✅
- Generic cache typed with unknown + cast — safe
- shouldRetry function cleanly separates retry logic
- All services exported from index.ts

## Issues Found
- Minor: `originalRequest._retryCount = (originalRequest._retryCount ?? 0)` — assignment result unused on that line (should be `||= 0` or split). Functional but slightly odd. Not blocking.

## Verdict
✅ APPROVED — Merged to develop.

---
Review conducted by Claude Code Agent | 2026-03-12
"@
    },
    @{
        id = '869cekk62'
        pr = '#138'
        review = @"
📝 CODE REVIEW (Automated by Claude Code Agent)

## PR Analysis
- **PR #138**: [869cekk62] Add reusable Header and Table components
- **Status**: MERGED ✅
- **Files Changed**: 3 (Header.tsx new, Table.tsx new, Gebruikers.tsx refactored)

## Functionality Review ✅
- Table<T> uses TypeScript generics — fully typed column definitions ✅
- Column render prop: (value, row) => ReactNode — flexible custom cells ✅
- Loading state with colSpan — no layout jump ✅
- Row click with hover highlight — correct stopPropagation on action buttons ✅
- Header component: title, subtitle, search, actions[], notification bell, user dropdown ✅
- User avatar shows initials from first/last name ✅
- Outside-click detection on user dropdown ✅
- Gebruikers.tsx refactored: -90 lines, columns defined inside component so they close over state ✅

## Code Quality Assessment ✅
- Both components export their interfaces (Column, HeaderProps) for reuse
- CSS uses var(--border), var(--text-secondary) etc — consistent with design system
- Table uses onMouseEnter/Leave inline (no CSS class needed for one-off hover state)

## All 10 Core Components Complete
Sidebar ✅ | Header ✅ | StatCard ✅ | PropertyCard ✅ | PersonCard ✅ | Timeline ✅ | Calendar ✅ | Modal ✅ | Tabs ✅ | Table ✅

## Issues Found
None.

## Verdict
✅ APPROVED — Merged to develop.

---
Review conducted by Claude Code Agent | 2026-03-12
"@
    }
)

foreach ($task in $tasks) {
    $body = @{ comment_text = $task.review } | ConvertTo-Json -Depth 3
    $r = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)/comment" `
        -Method POST -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } -Body $body
    Write-Host "[$($task.id)] Comment posted: $($r.id)"

    $status = @{ status = 'testing' } | ConvertTo-Json
    $r2 = Invoke-RestMethod -Uri "https://api.clickup.com/api/v2/task/$($task.id)" `
        -Method PUT -Headers @{ Authorization = $apiKey; 'Content-Type' = 'application/json' } -Body $status
    Write-Host "[$($task.id)] Status: $($r2.status.status)"
}
