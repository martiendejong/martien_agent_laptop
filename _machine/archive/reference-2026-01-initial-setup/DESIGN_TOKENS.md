# Design Token System 🎨

**Purpose:** Centralized design values (colors, spacing, typography) for consistent UI across Brand2Boost.

**Goal:** Single source of truth, easy theming, design-developer collaboration.

---

## What are Design Tokens?

**Design tokens** = Named design decisions stored as data.

**Instead of:**
```css
.button {
  background: #3B82F6;  /* What is this color? */
  padding: 12px 24px;    /* Why these values? */
  font-size: 16px;       /* Is this consistent? */
}
```

**Use tokens:**
```css
.button {
  background: var(--color-primary-500);
  padding: var(--space-3) var(--space-6);
  font-size: var(--text-base);
}
```

**Benefits:**
✅ Consistent design across app
✅ Easy to change theme (dark mode, rebrand)
✅ Design and dev use same names
✅ Type-safe (with TypeScript)
✅ Documentation built-in

---

## Token Categories

| Category | Examples | Use Case |
|----------|----------|----------|
| **Colors** | `primary-500`, `gray-100` | Backgrounds, text, borders |
| **Spacing** | `space-2`, `space-4` | Padding, margin, gaps |
| **Typography** | `text-base`, `font-bold` | Font sizes, weights, families |
| **Shadows** | `shadow-sm`, `shadow-lg` | Drop shadows, elevations |
| **Borders** | `radius-md`, `width-1` | Border radius, widths |
| **Z-Index** | `z-modal`, `z-dropdown` | Layering, stacking |
| **Breakpoints** | `screen-sm`, `screen-lg` | Responsive design |
| **Transitions** | `duration-200`, `ease-out` | Animations, transitions |

---

## Token Structure

### File Location

```
ClientManagerFrontend/src/styles/
├── tokens.css          # CSS custom properties
├── tokens.ts           # TypeScript constants
└── tailwind.config.js  # Tailwind theme (uses tokens)
```

### tokens.css (CSS Custom Properties)

```css
:root {
  /* === COLORS === */

  /* Primary (Brand Blue) */
  --color-primary-50: #EFF6FF;
  --color-primary-100: #DBEAFE;
  --color-primary-200: #BFDBFE;
  --color-primary-300: #93C5FD;
  --color-primary-400: #60A5FA;
  --color-primary-500: #3B82F6;  /* Main brand color */
  --color-primary-600: #2563EB;
  --color-primary-700: #1D4ED8;
  --color-primary-800: #1E40AF;
  --color-primary-900: #1E3A8A;

  /* Neutral (Grays) */
  --color-neutral-50: #F9FAFB;
  --color-neutral-100: #F3F4F6;
  --color-neutral-200: #E5E7EB;
  --color-neutral-300: #D1D5DB;
  --color-neutral-400: #9CA3AF;
  --color-neutral-500: #6B7280;
  --color-neutral-600: #4B5563;
  --color-neutral-700: #374151;
  --color-neutral-800: #1F2937;
  --color-neutral-900: #111827;

  /* Semantic Colors */
  --color-success: #10B981;
  --color-warning: #F59E0B;
  --color-error: #EF4444;
  --color-info: #3B82F6;

  /* === SPACING === */
  --space-0: 0;
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-3: 0.75rem;  /* 12px */
  --space-4: 1rem;     /* 16px */
  --space-5: 1.25rem;  /* 20px */
  --space-6: 1.5rem;   /* 24px */
  --space-8: 2rem;     /* 32px */
  --space-10: 2.5rem;  /* 40px */
  --space-12: 3rem;    /* 48px */
  --space-16: 4rem;    /* 64px */
  --space-20: 5rem;    /* 80px */

  /* === TYPOGRAPHY === */

  /* Font Families */
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-mono: 'Fira Code', 'Courier New', monospace;

  /* Font Sizes */
  --text-xs: 0.75rem;    /* 12px */
  --text-sm: 0.875rem;   /* 14px */
  --text-base: 1rem;     /* 16px */
  --text-lg: 1.125rem;   /* 18px */
  --text-xl: 1.25rem;    /* 20px */
  --text-2xl: 1.5rem;    /* 24px */
  --text-3xl: 1.875rem;  /* 30px */
  --text-4xl: 2.25rem;   /* 36px */
  --text-5xl: 3rem;      /* 48px */

  /* Font Weights */
  --font-normal: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;

  /* Line Heights */
  --leading-tight: 1.25;
  --leading-normal: 1.5;
  --leading-relaxed: 1.75;

  /* === SHADOWS === */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
  --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1);

  /* === BORDERS === */
  --radius-none: 0;
  --radius-sm: 0.125rem;  /* 2px */
  --radius-md: 0.375rem;  /* 6px */
  --radius-lg: 0.5rem;    /* 8px */
  --radius-xl: 0.75rem;   /* 12px */
  --radius-full: 9999px;

  --border-width-1: 1px;
  --border-width-2: 2px;
  --border-width-4: 4px;

  /* === Z-INDEX === */
  --z-base: 0;
  --z-dropdown: 1000;
  --z-sticky: 1100;
  --z-modal: 1200;
  --z-popover: 1300;
  --z-tooltip: 1400;
  --z-notification: 1500;

  /* === TRANSITIONS === */
  --duration-75: 75ms;
  --duration-100: 100ms;
  --duration-150: 150ms;
  --duration-200: 200ms;
  --duration-300: 300ms;
  --duration-500: 500ms;

  --ease-linear: linear;
  --ease-in: cubic-bezier(0.4, 0, 1, 1);
  --ease-out: cubic-bezier(0, 0, 0.2, 1);
  --ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);

  /* === BREAKPOINTS === */
  --screen-sm: 640px;
  --screen-md: 768px;
  --screen-lg: 1024px;
  --screen-xl: 1280px;
  --screen-2xl: 1536px;
}
```

### Dark Mode Tokens

```css
[data-theme="dark"] {
  /* Override colors for dark mode */
  --color-neutral-50: #1F2937;
  --color-neutral-100: #374151;
  --color-neutral-200: #4B5563;
  --color-neutral-300: #6B7280;
  --color-neutral-400: #9CA3AF;
  --color-neutral-500: #D1D5DB;
  --color-neutral-600: #E5E7EB;
  --color-neutral-700: #F3F4F6;
  --color-neutral-800: #F9FAFB;
  --color-neutral-900: #FFFFFF;

  /* Adjust shadows for dark mode */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.5);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.5);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.5);
}
```

### tokens.ts (TypeScript Constants)

```typescript
// Auto-generated from tokens.css (or manually maintained)

export const colors = {
  primary: {
    50: '#EFF6FF',
    100: '#DBEAFE',
    200: '#BFDBFE',
    300: '#93C5FD',
    400: '#60A5FA',
    500: '#3B82F6',
    600: '#2563EB',
    700: '#1D4ED8',
    800: '#1E40AF',
    900: '#1E3A8A',
  },
  neutral: {
    50: '#F9FAFB',
    100: '#F3F4F6',
    // ... rest of grays
  },
  success: '#10B981',
  warning: '#F59E0B',
  error: '#EF4444',
  info: '#3B82F6',
} as const;

export const spacing = {
  0: '0',
  1: '0.25rem',
  2: '0.5rem',
  3: '0.75rem',
  4: '1rem',
  5: '1.25rem',
  6: '1.5rem',
  8: '2rem',
  10: '2.5rem',
  12: '3rem',
  16: '4rem',
  20: '5rem',
} as const;

export const typography = {
  fontFamily: {
    sans: "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
    mono: "'Fira Code', 'Courier New', monospace",
  },
  fontSize: {
    xs: '0.75rem',
    sm: '0.875rem',
    base: '1rem',
    lg: '1.125rem',
    xl: '1.25rem',
    '2xl': '1.5rem',
    '3xl': '1.875rem',
    '4xl': '2.25rem',
    '5xl': '3rem',
  },
  fontWeight: {
    normal: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
  },
} as const;

export const shadows = {
  sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
  md: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
  lg: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
  xl: '0 20px 25px -5px rgb(0 0 0 / 0.1)',
} as const;

export const borderRadius = {
  none: '0',
  sm: '0.125rem',
  md: '0.375rem',
  lg: '0.5rem',
  xl: '0.75rem',
  full: '9999px',
} as const;

export const zIndex = {
  base: 0,
  dropdown: 1000,
  sticky: 1100,
  modal: 1200,
  popover: 1300,
  tooltip: 1400,
  notification: 1500,
} as const;

export const transitions = {
  duration: {
    75: '75ms',
    100: '100ms',
    150: '150ms',
    200: '200ms',
    300: '300ms',
    500: '500ms',
  },
  easing: {
    linear: 'linear',
    in: 'cubic-bezier(0.4, 0, 1, 1)',
    out: 'cubic-bezier(0, 0, 0.2, 1)',
    inOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
  },
} as const;

export const breakpoints = {
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
  '2xl': '1536px',
} as const;
```

### Tailwind Integration

```javascript
// tailwind.config.js
import { colors, spacing, typography, shadows, borderRadius } from './src/styles/tokens';

export default {
  theme: {
    extend: {
      colors,
      spacing,
      fontFamily: typography.fontFamily,
      fontSize: typography.fontSize,
      fontWeight: typography.fontWeight,
      boxShadow: shadows,
      borderRadius,
    },
  },
};
```

---

## Using Design Tokens

### In CSS

```css
/* ✅ CORRECT: Use tokens */
.button-primary {
  background-color: var(--color-primary-500);
  color: white;
  padding: var(--space-3) var(--space-6);
  border-radius: var(--radius-md);
  font-size: var(--text-base);
  font-weight: var(--font-semibold);
  transition: background-color var(--duration-200) var(--ease-out);
}

.button-primary:hover {
  background-color: var(--color-primary-600);
}

/* ❌ WRONG: Hardcoded values */
.button-primary {
  background-color: #3B82F6;
  padding: 12px 24px;
  border-radius: 6px;
}
```

### In React (Tailwind)

```tsx
// ✅ CORRECT: Tailwind uses tokens automatically
<button className="bg-primary-500 text-white px-6 py-3 rounded-md text-base font-semibold hover:bg-primary-600 transition-colors duration-200">
  Submit
</button>

// ❌ WRONG: Inline styles (not using tokens)
<button style={{ backgroundColor: '#3B82F6', padding: '12px 24px' }}>
  Submit
</button>
```

### In React (CSS-in-JS)

```tsx
import { css } from '@emotion/react';
import { colors, spacing } from '@/styles/tokens';

const buttonStyles = css`
  background-color: ${colors.primary[500]};
  padding: ${spacing[3]} ${spacing[6]};
  border-radius: ${borderRadius.md};
`;

<button css={buttonStyles}>Submit</button>
```

### In TypeScript (Programmatic)

```typescript
import { colors, zIndex } from '@/styles/tokens';

// Set z-index programmatically
modalElement.style.zIndex = zIndex.modal.toString();

// Generate color from token
const primaryColor = colors.primary[500];
```

---

## Semantic Tokens (Component-Specific)

**Problem:** Tokens like `color-primary-500` are too generic.
**Solution:** Create semantic aliases for specific use cases.

```css
:root {
  /* Semantic Tokens (built from base tokens) */
  --button-bg-primary: var(--color-primary-500);
  --button-bg-primary-hover: var(--color-primary-600);
  --button-bg-secondary: var(--color-neutral-200);
  --button-bg-danger: var(--color-error);

  --text-body: var(--color-neutral-900);
  --text-muted: var(--color-neutral-500);
  --text-heading: var(--color-neutral-900);

  --bg-page: var(--color-neutral-50);
  --bg-card: white;
  --bg-input: white;

  --border-default: var(--color-neutral-200);
  --border-focus: var(--color-primary-500);
}

[data-theme="dark"] {
  --button-bg-primary: var(--color-primary-600);
  --text-body: var(--color-neutral-100);
  --bg-page: var(--color-neutral-900);
  --bg-card: var(--color-neutral-800);
  --border-default: var(--color-neutral-700);
}
```

**Usage:**

```css
.card {
  background: var(--bg-card);
  border: 1px solid var(--border-default);
  color: var(--text-body);
}

/* Works in dark mode automatically! */
```

---

## Token Naming Conventions

### Format: `--{category}-{name}-{variant}`

**Examples:**
- `--color-primary-500` (category: color, name: primary, variant: 500)
- `--space-4` (category: space, name: 4)
- `--text-base` (category: text, name: base)
- `--shadow-md` (category: shadow, name: md)

### Color Scale (50-900)

**50-100:** Very light backgrounds
**200-400:** Borders, muted text
**500-600:** Primary buttons, links (main brand color)
**700-900:** Dark text, dark backgrounds

```css
/* Light mode */
--color-primary-500  /* Buttons */
--color-primary-600  /* Hover state */

/* Dark mode */
--color-primary-400  /* Buttons (lighter for dark bg) */
--color-primary-500  /* Hover */
```

### Spacing Scale (1-20)

**1-3:** Tight spacing (4px, 8px, 12px)
**4-6:** Default spacing (16px, 20px, 24px)
**8-12:** Large spacing (32px, 40px, 48px)
**16-20:** Extra large (64px, 80px)

---

## Theming (Dark Mode)

### Toggle Implementation

```tsx
// ThemeProvider.tsx
import { createContext, useContext, useEffect, useState } from 'react';

type Theme = 'light' | 'dark';

const ThemeContext = createContext<{
  theme: Theme;
  setTheme: (theme: Theme) => void;
}>({ theme: 'light', setTheme: () => {} });

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>('light');

  useEffect(() => {
    // Load from localStorage
    const saved = localStorage.getItem('theme') as Theme;
    if (saved) setTheme(saved);
  }, []);

  useEffect(() => {
    // Apply to document
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);
  }, [theme]);

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export const useTheme = () => useContext(ThemeContext);
```

### Theme Toggle Button

```tsx
import { useTheme } from './ThemeProvider';
import { MoonIcon, SunIcon } from '@heroicons/react/24/outline';

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();

  return (
    <button
      onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}
      aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
      className="p-2 rounded-md hover:bg-neutral-100 dark:hover:bg-neutral-800"
    >
      {theme === 'light' ? (
        <MoonIcon className="w-5 h-5" />
      ) : (
        <SunIcon className="w-5 h-5" />
      )}
    </button>
  );
}
```

---

## Component Variants (Using Tokens)

### Button Component

```tsx
// Button.tsx
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-semibold transition-colors',
  {
    variants: {
      variant: {
        primary: 'bg-primary-500 text-white hover:bg-primary-600',
        secondary: 'bg-neutral-200 text-neutral-900 hover:bg-neutral-300',
        outline: 'border-2 border-primary-500 text-primary-500 hover:bg-primary-50',
        ghost: 'text-neutral-700 hover:bg-neutral-100',
        danger: 'bg-error text-white hover:bg-red-600',
      },
      size: {
        sm: 'px-3 py-2 text-sm',
        md: 'px-6 py-3 text-base',
        lg: 'px-8 py-4 text-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export function Button({ variant, size, className, ...props }: ButtonProps) {
  return (
    <button className={buttonVariants({ variant, size, className })} {...props} />
  );
}
```

**Usage:**
```tsx
<Button variant="primary" size="md">Submit</Button>
<Button variant="secondary" size="sm">Cancel</Button>
<Button variant="danger" size="lg">Delete</Button>
```

---

## Documentation Generation

### Style Dictionary (Automated Token Docs)

**Install:**
```bash
npm install style-dictionary
```

**Config (`style-dictionary.config.js`):**
```javascript
module.exports = {
  source: ['src/styles/tokens/**/*.json'],
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: 'src/styles/',
      files: [
        {
          destination: 'tokens.css',
          format: 'css/variables',
        },
      ],
    },
    ts: {
      transformGroup: 'js',
      buildPath: 'src/styles/',
      files: [
        {
          destination: 'tokens.ts',
          format: 'javascript/es6',
        },
      ],
    },
  },
};
```

**Source tokens (`src/styles/tokens/colors.json`):**
```json
{
  "color": {
    "primary": {
      "500": { "value": "#3B82F6" },
      "600": { "value": "#2563EB" }
    }
  }
}
```

**Generate:**
```bash
npx style-dictionary build
```

**Output:** `tokens.css` and `tokens.ts` auto-generated

---

## Design Handoff (Figma → Code)

### Figma Plugin: Design Tokens

1. **Designer creates tokens in Figma**
   - Colors, spacing, typography
   - Uses Figma Styles/Variables

2. **Export with Figma Tokens plugin**
   - Exports as JSON
   - Matches Style Dictionary format

3. **Import to codebase**
   ```bash
   cp figma-tokens.json src/styles/tokens/
   npx style-dictionary build
   ```

4. **Tokens now in sync** (design ↔ code)

---

## Testing

### Visual Regression Testing

**Check that token changes don't break UI:**

```typescript
// Chromatic (Storybook integration)
import { storiesOf } from '@storybook/react';

storiesOf('Button', module)
  .add('Primary', () => <Button variant="primary">Submit</Button>)
  .add('Secondary', () => <Button variant="secondary">Cancel</Button>);

// Run Chromatic on each commit
// Catches unintended visual changes
```

### Token Validation

```typescript
// Validate tokens at build time
import { colors, spacing } from '@/styles/tokens';

// Ensure all color values are valid hex
Object.values(colors.primary).forEach(color => {
  if (!/^#[0-9A-F]{6}$/i.test(color)) {
    throw new Error(`Invalid color: ${color}`);
  }
});

// Ensure spacing values are in rem
Object.values(spacing).forEach(space => {
  if (space !== '0' && !space.endsWith('rem')) {
    throw new Error(`Invalid spacing: ${space}`);
  }
});
```

---

## Best Practices

### DO:
✅ Use tokens for all design values
✅ Name tokens semantically (`--text-body`, not `--gray-700`)
✅ Document token usage
✅ Keep tokens in sync between design and code
✅ Use Tailwind classes (built from tokens)
✅ Test token changes visually

### DON'T:
❌ Hardcode colors/spacing in components
❌ Create one-off custom values
❌ Skip dark mode token overrides
❌ Use generic names (`--blue`, `--small`)
❌ Nest tokens too deeply (max 3 levels)

---

## Checklist

**Before using a value in CSS/component:**
- [ ] Does a token exist for this value?
- [ ] If not, should I create a token?
- [ ] Is this a semantic or base token?
- [ ] Does it work in dark mode?
- [ ] Is the token name clear?

---

## Related Documentation

- [ACCESSIBILITY_TESTING.md](./ACCESSIBILITY_TESTING.md) - Color contrast
- Tailwind Config: `ClientManagerFrontend/tailwind.config.js`
- Component Library: `ClientManagerFrontend/src/components/ui/`

---

**Last Updated:** 2026-01-08
**Token Version:** 1.0
**Design Tool:** Figma
**Maintained by:** Design Team & Frontend Team
