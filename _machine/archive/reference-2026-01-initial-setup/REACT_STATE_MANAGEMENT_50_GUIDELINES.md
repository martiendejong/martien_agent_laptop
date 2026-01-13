# React State Management - 50 Expert Guidelines ⚛️

**Generated:** 2026-01-08
**Purpose:** Make Brand2Boost React app stateful, scalable, and maintainable
**Method:** 50 world-class React experts each provide 1 guideline

---

## 50 React Experts Panel

### State Management Experts (10)
1. **Kent C. Dodds** - Testing Library, Epic React
2. **Mark Erikson** - Redux Maintainer
3. **Daishi Kato** - Zustand & Jotai Creator
4. **Tanner Linsley** - TanStack Query Creator
5. **Michel Weststrate** - MobX Creator
6. **Sophie Alpert** - Former React Core Team
7. **Dan Abramov** - React Core Team, Redux Co-creator
8. **Cassidy Williams** - React Educator
9. **Ryan Florence** - React Router, Remix
10. **Tejas Kumar** - React Performance Expert

### Architecture & Patterns (10)
11. **Adam Wathan** - Tailwind CSS Creator
12. **Guillermo Rauch** - Next.js Creator (Vercel)
13. **Evan You** - Vue Creator (patterns apply to React)
14. **Rich Harris** - Svelte Creator (modern patterns)
15. **Sebastian Markbåge** - React Core Team
16. **Lee Robinson** - Next.js DX Lead
17. **Theo Browne** - T3 Stack Creator
18. **Addy Osmani** - Google Chrome, Performance
19. **Jason Miller** - Preact Creator
20. **Jared Palmer** - Formik Creator

### Performance Experts (10)
21. **Alex Russell** - Chrome Performance Team
22. **Maxime Heckel** - React Performance Blog
23. **Josh W. Comeau** - CSS/React Performance
24. **Sam Selikoff** - EmberConf, React Performance
25. **Lydia Hallie** - JavaScript Visualized
26. **Steve Kinney** - Frontend Masters
27. **Ben Ilegbodu** - React Performance Advocate
28. **Harry Roberts** - Performance Consultant
29. **Anna Migas** - Web Performance
30. **Katie Hempenius** - Chrome Performance

### Testing & Quality (10)
31. **Gleb Bahmutov** - Cypress Ambassador
32. **Debbie O'Brien** - Playwright Advocate
33. **Kent Dodds** - Testing Best Practices
34. **Justin Searls** - Test Double
35. **Angie Jones** - Test Automation University
36. **Erin Doyle** - Accessibility Testing
37. **Marcy Sutton** - Accessibility Expert
38. **Sid Sijbrandij** - CI/CD Best Practices
39. **Tomek Sułkowski** - Storybook Maintainer
40. **Michael Shilman** - Storybook Team

### TypeScript & Type Safety (10)
41. **Matt Pocock** - Total TypeScript
42. **Marius Schulz** - TypeScript Deep Dive
43. **Basarat Ali Syed** - TypeScript Guru
44. **Stefan Baumgartner** - TypeScript Expert
45. **Josh Goldberg** - Learning TypeScript
46. **Orta Therox** - TypeScript/React Types
47. **Anders Hejlsberg** - TypeScript Creator (patterns)
48. **Gabriel Vergnaud** - TS-Pattern Creator
49. **Andarist** - Emotion/TS Maintainer
50. **Artem Zakharchenko** - MSW Creator

---

## 50 Guidelines for React State Management

### Category 1: State Architecture (Guidelines 1-10)

#### 1. Kent C. Dodds - Colocate State
**Guideline:** Keep state as close as possible to where it's used.

```tsx
// ❌ BAD: Global state for local concern
const globalStore = create((set) => ({
  modalOpen: false,
  setModalOpen: (open) => set({ modalOpen: open }),
}));

function MyComponent() {
  const { modalOpen, setModalOpen } = globalStore();
  // ...
}

// ✅ GOOD: Local state
function MyComponent() {
  const [modalOpen, setModalOpen] = useState(false);
  // Only lift state up when multiple components need it
}
```

**Why:** Reduces complexity, improves performance, easier to understand.

---

#### 2. Mark Erikson - Normalize State Shape
**Guideline:** Store data in normalized form (like a database).

```tsx
// ❌ BAD: Nested, denormalized
const state = {
  brands: [
    {
      id: '1',
      name: 'Coffee Co',
      products: [
        { id: 'p1', name: 'Espresso', brandId: '1' },
        { id: 'p2', name: 'Latte', brandId: '1' },
      ],
    },
  ],
};

// ✅ GOOD: Normalized (flat)
const state = {
  brands: {
    byId: {
      '1': { id: '1', name: 'Coffee Co', productIds: ['p1', 'p2'] },
    },
    allIds: ['1'],
  },
  products: {
    byId: {
      'p1': { id: 'p1', name: 'Espresso', brandId: '1' },
      'p2': { id: 'p2', name: 'Latte', brandId: '1' },
    },
    allIds: ['p1', 'p2'],
  },
};
```

**Why:** Easier updates, no duplication, better performance.

---

#### 3. Daishi Kato - Use Atomic State Updates
**Guideline:** Update state atomically to avoid partial updates.

```tsx
// ❌ BAD: Multiple setState calls (race conditions)
const updateUser = (userId: string, data: Partial<User>) => {
  setUsers((prev) => prev.map((u) => (u.id === userId ? { ...u, ...data } : u)));
  setLastUpdated(Date.now());
  setIsDirty(true);
};

// ✅ GOOD: Single atomic update
const usersStore = create<State>((set) => ({
  users: [],
  lastUpdated: null,
  isDirty: false,
  updateUser: (userId, data) =>
    set((state) => ({
      users: state.users.map((u) => (u.id === userId ? { ...u, ...data } : u)),
      lastUpdated: Date.now(),
      isDirty: true,
    })),
}));
```

**Why:** Consistency, predictability, fewer bugs.

---

#### 4. Tanner Linsley - Separate Server State from Client State
**Guideline:** Use React Query for server state, Zustand/Context for client state.

```tsx
// ❌ BAD: Mixing server and client state in one store
const useStore = create((set) => ({
  brands: [],  // Server state
  selectedBrandId: null,  // Client state (UI)
  isLoading: false,  // Server state status
  // ...
}));

// ✅ GOOD: Separate concerns
// Server state (React Query)
const { data: brands, isLoading } = useQuery({
  queryKey: ['brands'],
  queryFn: fetchBrands,
});

// Client state (Zustand)
const useUIStore = create((set) => ({
  selectedBrandId: null,
  setSelectedBrand: (id) => set({ selectedBrandId: id }),
}));
```

**Why:** Clear responsibilities, automatic caching/refetching, less boilerplate.

---

#### 5. Michel Weststrate - Make State Observable, Not Writable
**Guideline:** Expose read-only state, provide actions for updates.

```tsx
// ❌ BAD: Direct state mutation allowed
const useStore = create((set) => ({
  count: 0,
  // No encapsulation
}));

function Component() {
  const store = useStore();
  store.count++; // Mutation! Bad!
}

// ✅ GOOD: Encapsulated with actions
const useStore = create<State>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
}));

function Component() {
  const count = useStore((state) => state.count);
  const increment = useStore((state) => state.increment);
  // Can't mutate directly!
}
```

**Why:** Predictable updates, easier debugging, immutability enforced.

---

#### 6. Sophie Alpert - Derive State Instead of Storing It
**Guideline:** Calculate derived values instead of storing them.

```tsx
// ❌ BAD: Storing derived state
const [products, setProducts] = useState([]);
const [total, setTotal] = useState(0);

useEffect(() => {
  setTotal(products.reduce((sum, p) => sum + p.price, 0));
}, [products]);

// ✅ GOOD: Derive on the fly
const [products, setProducts] = useState([]);
const total = products.reduce((sum, p) => sum + p.price, 0);

// Or use useMemo for expensive calculations
const total = useMemo(
  () => products.reduce((sum, p) => sum + p.price, 0),
  [products]
);
```

**Why:** Single source of truth, no sync issues, less state.

---

#### 7. Dan Abramov - Use Reducers for Complex State Logic
**Guideline:** useReducer for state with multiple related values.

```tsx
// ❌ BAD: Multiple useState for related state
const [loading, setLoading] = useState(false);
const [error, setError] = useState(null);
const [data, setData] = useState(null);

const fetchData = async () => {
  setLoading(true);
  setError(null);
  try {
    const result = await api.fetch();
    setData(result);
  } catch (err) {
    setError(err);
  } finally {
    setLoading(false);
  }
};

// ✅ GOOD: useReducer for complex state
type State =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: Data }
  | { status: 'error'; error: Error };

const [state, dispatch] = useReducer(fetchReducer, { status: 'idle' });

const fetchData = async () => {
  dispatch({ type: 'FETCH_START' });
  try {
    const data = await api.fetch();
    dispatch({ type: 'FETCH_SUCCESS', data });
  } catch (error) {
    dispatch({ type: 'FETCH_ERROR', error });
  }
};
```

**Why:** Clearer state transitions, easier to test, type-safe.

---

#### 8. Cassidy Williams - Use Enums for State Machines
**Guideline:** Model state as finite state machine.

```tsx
// ❌ BAD: Boolean soup
const [isLoading, setIsLoading] = useState(false);
const [hasError, setHasError] = useState(false);
const [isSuccess, setIsSuccess] = useState(false);
// Impossible states: loading + success? error + loading?

// ✅ GOOD: Enum/union type
type Status = 'idle' | 'loading' | 'success' | 'error';
const [status, setStatus] = useState<Status>('idle');

// Even better: XState for complex state machines
import { createMachine } from 'xstate';

const fetchMachine = createMachine({
  initial: 'idle',
  states: {
    idle: { on: { FETCH: 'loading' } },
    loading: {
      on: {
        SUCCESS: 'success',
        ERROR: 'error',
      },
    },
    success: { on: { REFETCH: 'loading' } },
    error: { on: { RETRY: 'loading' } },
  },
});
```

**Why:** No impossible states, clear transitions, easier debugging.

---

#### 9. Ryan Florence - Sync State with URL
**Guideline:** Store UI state in URL when it affects sharing/bookmarking.

```tsx
// ❌ BAD: Client-only state (can't share, refresh loses state)
const [selectedTab, setSelectedTab] = useState('profile');
const [searchQuery, setSearchQuery] = useState('');

// ✅ GOOD: URL-synced state
import { useSearchParams } from 'react-router-dom';

function Dashboard() {
  const [searchParams, setSearchParams] = useSearchParams();

  const selectedTab = searchParams.get('tab') ?? 'profile';
  const searchQuery = searchParams.get('q') ?? '';

  const setSelectedTab = (tab: string) => {
    setSearchParams((prev) => {
      prev.set('tab', tab);
      return prev;
    });
  };

  // URL: /dashboard?tab=settings&q=search
  // Shareable, bookmarkable, refresh-safe!
}
```

**Why:** Shareable URLs, better UX, deep linking.

---

#### 10. Tejas Kumar - Separate Domain Logic from UI State
**Guideline:** Business logic should be independent of UI framework.

```tsx
// ❌ BAD: Business logic mixed with UI
function ProductList() {
  const [products, setProducts] = useState([]);

  const applyDiscount = (productId: string, percent: number) => {
    setProducts((prev) =>
      prev.map((p) =>
        p.id === productId
          ? { ...p, price: p.price * (1 - percent / 100) }
          : p
      )
    );
  };

  // Discount logic tied to React!
}

// ✅ GOOD: Extract to domain model
// domain/Product.ts
class Product {
  constructor(public id: string, public price: number) {}

  applyDiscount(percent: number): Product {
    return new Product(this.id, this.price * (1 - percent / 100));
  }
}

// Component just orchestrates
function ProductList() {
  const [products, setProducts] = useState<Product[]>([]);

  const applyDiscount = (productId: string, percent: number) => {
    setProducts((prev) =>
      prev.map((p) => (p.id === productId ? p.applyDiscount(percent) : p))
    );
  };

  // Business logic testable without React!
}
```

**Why:** Testability, reusability, separation of concerns.

---

### Category 2: Performance Optimization (Guidelines 11-20)

#### 11. Adam Wathan - Memoize Expensive Calculations
**Guideline:** Use `useMemo` for expensive derived values.

```tsx
// ❌ BAD: Recalculates on every render
function ProductList({ products }: { products: Product[] }) {
  const total = products.reduce((sum, p) => sum + p.price, 0);
  const average = total / products.length;

  return <div>Total: {total}, Avg: {average}</div>;
}

// ✅ GOOD: Memoize expensive calculation
function ProductList({ products }: { products: Product[] }) {
  const stats = useMemo(() => {
    const total = products.reduce((sum, p) => sum + p.price, 0);
    return {
      total,
      average: total / products.length,
    };
  }, [products]);

  return <div>Total: {stats.total}, Avg: {stats.average}</div>;
}
```

**When to use:** Calculation takes >5ms, or runs on every render.

---

#### 12. Guillermo Rauch - Code-Split by Route
**Guideline:** Lazy-load routes to reduce initial bundle size.

```tsx
// ❌ BAD: All routes loaded upfront
import Dashboard from './Dashboard';
import Settings from './Settings';
import Profile from './Profile';

const routes = [
  { path: '/dashboard', element: <Dashboard /> },
  { path: '/settings', element: <Settings /> },
  { path: '/profile', element: <Profile /> },
];

// ✅ GOOD: Lazy-loaded routes
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./Dashboard'));
const Settings = lazy(() => import('./Settings'));
const Profile = lazy(() => import('./Profile'));

const routes = [
  {
    path: '/dashboard',
    element: (
      <Suspense fallback={<Loading />}>
        <Dashboard />
      </Suspense>
    ),
  },
  // ...
];
```

**Impact:** 50-70% smaller initial bundle.

---

#### 13. Evan You - Use Keys Correctly in Lists
**Guideline:** Stable, unique keys for list items (not index).

```tsx
// ❌ BAD: Index as key (breaks on reorder/filter)
{items.map((item, index) => (
  <Item key={index} data={item} />
))}

// ✅ GOOD: Unique ID as key
{items.map((item) => (
  <Item key={item.id} data={item} />
))}

// ✅ BETTER: Composite key if no unique ID
{items.map((item) => (
  <Item key={`${item.name}-${item.createdAt}`} data={item} />
))}
```

**Why:** Correct reconciliation, preserves component state, better performance.

---

#### 14. Rich Harris - Minimize Re-renders with Selectors
**Guideline:** Select only the data you need from store.

```tsx
// ❌ BAD: Subscribes to entire store (re-renders on any change)
function UserName() {
  const store = useStore();  // Entire store!
  return <div>{store.user.name}</div>;
}

// ✅ GOOD: Select specific field
function UserName() {
  const userName = useStore((state) => state.user.name);
  // Only re-renders when user.name changes
  return <div>{userName}</div>;
}

// ✅ BEST: Shallow equality with multiple fields
import { shallow } from 'zustand/shallow';

function UserProfile() {
  const { name, email } = useStore(
    (state) => ({ name: state.user.name, email: state.user.email }),
    shallow
  );
  // Only re-renders when name OR email changes
}
```

**Impact:** 80-90% fewer re-renders.

---

#### 15. Sebastian Markbåge - Use `React.memo` Wisely
**Guideline:** Wrap components only when props are expensive to compare.

```tsx
// ❌ BAD: Memoizing everything (overhead)
const Button = React.memo(({ onClick }) => <button onClick={onClick}>Click</button>);

// ✅ GOOD: Memo for expensive components
const ExpensiveChart = React.memo(
  ({ data }: { data: ChartData }) => {
    // Expensive rendering logic
    return <canvas>...</canvas>;
  },
  (prevProps, nextProps) => {
    // Custom comparison
    return prevProps.data.id === nextProps.data.id;
  }
);
```

**Rule of thumb:** Memo if component renders >10ms or receives large props.

---

#### 16. Lee Robinson - Prefetch Data on Hover
**Guideline:** Start fetching data before user clicks.

```tsx
// ✅ Prefetch on hover
function ProductCard({ productId }: { productId: string }) {
  const queryClient = useQueryClient();

  const prefetchProduct = () => {
    queryClient.prefetchQuery({
      queryKey: ['product', productId],
      queryFn: () => fetchProduct(productId),
    });
  };

  return (
    <Link
      to={`/product/${productId}`}
      onMouseEnter={prefetchProduct}  // Prefetch on hover!
      onFocus={prefetchProduct}       // Also on keyboard focus
    >
      View Product
    </Link>
  );
}
```

**Impact:** Instant navigation feel (data already loaded).

---

#### 17. Theo Browne - Use Suspense for Data Fetching
**Guideline:** Coordinate loading states with Suspense boundaries.

```tsx
// ❌ BAD: Manual loading states everywhere
function ProductList() {
  const { data, isLoading } = useQuery(['products'], fetchProducts);

  if (isLoading) return <Spinner />;

  return <div>{data.map(...)}</div>;
}

// ✅ GOOD: Suspense boundary
import { Suspense } from 'react';

function ProductList() {
  const products = useSuspenseQuery(['products'], fetchProducts);
  // No manual loading check!
  return <div>{products.map(...)}</div>;
}

// Wrap in Suspense
<Suspense fallback={<Spinner />}>
  <ProductList />
</Suspense>
```

**Why:** Declarative loading, easier error boundaries, better UX.

---

#### 18. Addy Osmani - Virtualize Long Lists
**Guideline:** Render only visible items in long lists.

```tsx
// ❌ BAD: Render 10,000 items (slow!)
function ProductList({ products }: { products: Product[] }) {
  return (
    <div>
      {products.map((p) => (
        <ProductCard key={p.id} product={p} />
      ))}
    </div>
  );
}

// ✅ GOOD: Virtualized list
import { useVirtualizer } from '@tanstack/react-virtual';

function ProductList({ products }: { products: Product[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: products.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 80,  // Estimate row height
  });

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map((virtualRow) => (
          <div
            key={virtualRow.key}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              transform: `translateY(${virtualRow.start}px)`,
            }}
          >
            <ProductCard product={products[virtualRow.index]} />
          </div>
        ))}
      </div>
    </div>
  );
}
```

**Impact:** 100x performance improvement for 10K+ items.

---

#### 19. Jason Miller - Debounce Expensive Updates
**Guideline:** Delay expensive operations until user stops typing.

```tsx
// ❌ BAD: API call on every keystroke
function SearchInput() {
  const [query, setQuery] = useState('');

  useEffect(() => {
    searchAPI(query);  // Called 100x while typing!
  }, [query]);

  return <input value={query} onChange={(e) => setQuery(e.target.value)} />;
}

// ✅ GOOD: Debounced search
import { useDebouncedValue } from '@mantine/hooks';

function SearchInput() {
  const [query, setQuery] = useState('');
  const [debouncedQuery] = useDebouncedValue(query, 500);  // 500ms delay

  useEffect(() => {
    if (debouncedQuery) {
      searchAPI(debouncedQuery);  // Only called when user stops typing
    }
  }, [debouncedQuery]);

  return <input value={query} onChange={(e) => setQuery(e.target.value)} />;
}
```

**Impact:** 90% fewer API calls.

---

#### 20. Jared Palmer - Optimistic Updates for Better UX
**Guideline:** Update UI immediately, rollback on error.

```tsx
// ❌ BAD: Wait for server response
const likeBrand = async (brandId: string) => {
  setLoading(true);
  await api.likeBrand(brandId);
  await refetch();  // User waits...
  setLoading(false);
};

// ✅ GOOD: Optimistic update
const likeBrand = useMutation({
  mutationFn: api.likeBrand,
  onMutate: async (brandId) => {
    // Cancel outgoing refetches
    await queryClient.cancelQueries(['brands']);

    // Snapshot previous value
    const previous = queryClient.getQueryData(['brands']);

    // Optimistically update
    queryClient.setQueryData(['brands'], (old: Brand[]) =>
      old.map((b) => (b.id === brandId ? { ...b, liked: true } : b))
    );

    return { previous };
  },
  onError: (err, variables, context) => {
    // Rollback on error
    queryClient.setQueryData(['brands'], context.previous);
  },
});
```

**Impact:** Instant feedback, better perceived performance.

---

### Category 3: Type Safety & Developer Experience (Guidelines 21-30)

#### 21. Matt Pocock - Use Discriminated Unions for State
**Guideline:** Model mutually exclusive states with TypeScript unions.

```tsx
// ❌ BAD: Nullable fields (impossible states possible)
type State = {
  data: Data | null;
  error: Error | null;
  loading: boolean;
};
// Can be: loading=true, data=set, error=set (impossible!)

// ✅ GOOD: Discriminated union
type State =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: Data }
  | { status: 'error'; error: Error };

// TypeScript ensures only valid states!
function Component({ state }: { state: State }) {
  if (state.status === 'success') {
    return <div>{state.data.name}</div>;  // data is guaranteed to exist!
  }
}
```

**Why:** Type safety, impossible states eliminated, better autocomplete.

---

#### 22. Marius Schulz - Type Your Zustand Store
**Guideline:** Fully type store state and actions.

```tsx
// ❌ BAD: Untyped store
const useStore = create((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// ✅ GOOD: Fully typed
interface CounterState {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

const useStore = create<CounterState>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));

// Full autocomplete and type checking!
```

---

#### 23. Basarat Ali Syed - Use `as const` for Action Types
**Guideline:** Const assertions for action type safety.

```tsx
// ❌ BAD: String literals (typos not caught)
dispatch({ type: 'INCREMENT' });
dispatch({ type: 'INCREMNT' });  // Typo! No error!

// ✅ GOOD: Const object with as const
const ActionTypes = {
  INCREMENT: 'INCREMENT',
  DECREMENT: 'DECREMENT',
} as const;

type Action =
  | { type: typeof ActionTypes.INCREMENT }
  | { type: typeof ActionTypes.DECREMENT };

// Typos caught at compile time!
dispatch({ type: ActionTypes.INCREMENT });
dispatch({ type: ActionTypes.INCREMNT });  // Error!
```

---

#### 24. Stefan Baumgartner - Extract Props to Types
**Guideline:** Define prop types separately for reusability.

```tsx
// ❌ BAD: Inline props
function Button({ variant, size, children }: {
  variant: 'primary' | 'secondary';
  size: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
}) {
  // ...
}

// ✅ GOOD: Extract to type
type ButtonProps = {
  variant: 'primary' | 'secondary';
  size: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
};

function Button({ variant, size, children }: ButtonProps) {
  // ...
}

// Reusable in stories, tests, etc.
const mockProps: ButtonProps = { ... };
```

---

#### 25. Josh Goldberg - Use Generics for Reusable Hooks
**Guideline:** Generic hooks for type-safe reusability.

```tsx
// ❌ BAD: Hook tied to specific type
function useLocalStorage(key: string) {
  const [value, setValue] = useState<string | null>(
    localStorage.getItem(key)
  );
  // Only works with strings!
}

// ✅ GOOD: Generic hook
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const item = localStorage.getItem(key);
    return item ? JSON.parse(item) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}

// Type-safe usage
const [user, setUser] = useLocalStorage<User>('user', null);
const [settings, setSettings] = useLocalStorage<Settings>('settings', {});
```

---

#### 26. Orta Therox - Use React.FC Sparingly
**Guideline:** Prefer explicit prop types over React.FC.

```tsx
// ❌ AVOID: React.FC (implicit children, less control)
const Button: React.FC<{ variant: string }> = ({ variant, children }) => {
  // children is implicitly typed
};

// ✅ GOOD: Explicit props
type ButtonProps = {
  variant: string;
  children: React.ReactNode;  // Explicit!
};

const Button = ({ variant, children }: ButtonProps) => {
  // ...
};
```

**Why:** More control, explicit children, better with generics.

---

#### 27. Anders Hejlsberg - Use Template Literal Types
**Guideline:** Type-safe string patterns with template literals.

```tsx
// ❌ BAD: Any string accepted
type Color = string;
const color: Color = 'primary-500';  // Could be anything!

// ✅ GOOD: Template literal type
type ColorScale = 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900;
type ColorName = 'primary' | 'secondary' | 'neutral';
type Color = `${ColorName}-${ColorScale}`;

const color: Color = 'primary-500';  // ✅
const invalid: Color = 'primary-999';  // ❌ Error!
const invalid2: Color = 'purple-500';  // ❌ Error!
```

---

#### 28. Gabriel Vergnaud - Pattern Match on State
**Guideline:** Use pattern matching for cleaner state handling.

```tsx
// ❌ BAD: Nested if-else
if (state.status === 'loading') {
  return <Spinner />;
} else if (state.status === 'error') {
  return <Error error={state.error} />;
} else if (state.status === 'success') {
  return <Data data={state.data} />;
}

// ✅ GOOD: Pattern matching with ts-pattern
import { match } from 'ts-pattern';

return match(state)
  .with({ status: 'loading' }, () => <Spinner />)
  .with({ status: 'error' }, ({ error }) => <Error error={error} />)
  .with({ status: 'success' }, ({ data }) => <Data data={data} />)
  .with({ status: 'idle' }, () => <Idle />)
  .exhaustive();  // TypeScript ensures all cases handled!
```

---

#### 29. Andarist - Type Event Handlers Correctly
**Guideline:** Use proper event types for handlers.

```tsx
// ❌ BAD: any event
const handleClick = (event: any) => {
  event.preventDefault();
};

// ✅ GOOD: Specific event type
const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
  event.preventDefault();
  // Full autocomplete for mouse events on button!
};

const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
  console.log(event.target.value);  // Type-safe!
};
```

---

#### 30. Artem Zakharchenko - Mock with MSW for Type Safety
**Guideline:** Use MSW for type-safe API mocking.

```tsx
// ✅ Type-safe API mocking
import { rest } from 'msw';
import { setupServer } from 'msw/node';

type Brand = { id: string; name: string };

const handlers = [
  rest.get<never, never, Brand[]>('/api/brands', (req, res, ctx) => {
    return res(
      ctx.json([
        { id: '1', name: 'Coffee Co' },
        { id: '2', name: 'Tea Time' },
      ])
    );
  }),
];

const server = setupServer(...handlers);

// Type-safe mocks in tests!
```

---

### Category 4: Testing & Quality (Guidelines 31-40)

#### 31. Gleb Bahmutov - Test User Behavior, Not Implementation
**Guideline:** Test what the user sees and does.

```tsx
// ❌ BAD: Testing implementation details
test('increments counter', () => {
  const { result } = renderHook(() => useCounter());
  act(() => result.current.increment());
  expect(result.current.count).toBe(1);  // Testing internal state!
});

// ✅ GOOD: Testing user behavior
test('increments counter when button clicked', () => {
  render(<Counter />);

  expect(screen.getByText('Count: 0')).toBeInTheDocument();

  fireEvent.click(screen.getByRole('button', { name: 'Increment' }));

  expect(screen.getByText('Count: 1')).toBeInTheDocument();
  // Tests what user sees!
});
```

---

#### 32. Debbie O'Brien - Use Playwright for E2E
**Guideline:** E2E tests with real browser interactions.

```tsx
// Playwright test
import { test, expect } from '@playwright/test';

test('user can create brand', async ({ page }) => {
  await page.goto('/brands');
  await page.click('text=New Brand');

  await page.fill('[name="name"]', 'My Brand');
  await page.selectOption('[name="industry"]', 'Technology');
  await page.click('button[type="submit"]');

  await expect(page.locator('text=Brand created')).toBeVisible();
});
```

---

#### 33. Kent Dodds - Write Fewer, Longer Tests
**Guideline:** Test complete user flows, not isolated units.

```tsx
// ❌ BAD: Many small tests
test('renders login form', () => { ... });
test('validates email', () => { ... });
test('validates password', () => { ... });
test('shows error on invalid login', () => { ... });
test('redirects on success', () => { ... });

// ✅ GOOD: One comprehensive test
test('login flow', async () => {
  render(<Login />);

  // Renders form
  expect(screen.getByLabelText('Email')).toBeInTheDocument();

  // Validates inputs
  await userEvent.click(screen.getByRole('button', { name: 'Sign in' }));
  expect(screen.getByText('Email is required')).toBeInTheDocument();

  // Shows error on invalid login
  await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');
  await userEvent.type(screen.getByLabelText('Password'), 'wrong');
  await userEvent.click(screen.getByRole('button', { name: 'Sign in' }));
  await waitFor(() => expect(screen.getByText('Invalid credentials')).toBeInTheDocument());

  // Success redirects
  // ...
});
```

---

#### 34. Justin Searls - Use Test Data Builders
**Guideline:** Reusable test data factories.

```tsx
// ❌ BAD: Hardcoded test data everywhere
test('displays brand', () => {
  const brand = {
    id: '1',
    name: 'Coffee Co',
    industry: 'Food',
    // ... 20 more fields
  };
  render(<BrandCard brand={brand} />);
});

// ✅ GOOD: Test data builder
class BrandBuilder {
  private brand: Brand = {
    id: '1',
    name: 'Test Brand',
    industry: 'Technology',
    // ... defaults
  };

  withName(name: string) {
    this.brand.name = name;
    return this;
  }

  withIndustry(industry: string) {
    this.brand.industry = industry;
    return this;
  }

  build() {
    return this.brand;
  }
}

// Usage
test('displays brand name', () => {
  const brand = new BrandBuilder()
    .withName('Coffee Co')
    .build();

  render(<BrandCard brand={brand} />);
  expect(screen.getByText('Coffee Co')).toBeInTheDocument();
});
```

---

#### 35. Angie Jones - Test Accessibility
**Guideline:** Automated accessibility tests.

```tsx
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('has no accessibility violations', async () => {
  const { container } = render(<LoginForm />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

---

#### 36. Erin Doyle - Test Keyboard Navigation
**Guideline:** Ensure all interactions work with keyboard.

```tsx
test('can navigate form with keyboard', async () => {
  render(<ContactForm />);

  // Tab to first input
  await userEvent.tab();
  expect(screen.getByLabelText('Name')).toHaveFocus();

  // Type and tab to next
  await userEvent.keyboard('John Doe');
  await userEvent.tab();
  expect(screen.getByLabelText('Email')).toHaveFocus();

  // Submit with Enter
  await userEvent.keyboard('{Enter}');
  // ...
});
```

---

#### 37. Marcy Sutton - Test Screen Reader Announcements
**Guideline:** Verify ARIA announcements.

```tsx
test('announces loading state', () => {
  const { rerender } = render(<DataTable loading={true} />);

  expect(screen.getByRole('status')).toHaveTextContent('Loading data...');

  rerender(<DataTable loading={false} data={mockData} />);

  expect(screen.getByRole('status')).toHaveTextContent('Data loaded. 10 items.');
});
```

---

#### 38. Sid Sijbrandij - Run Tests in Parallel
**Guideline:** Speed up test suite with parallelization.

```json
// jest.config.js
module.exports = {
  maxWorkers: '50%',  // Use 50% of CPU cores
  testPathIgnorePatterns: ['/node_modules/', '/dist/'],
};

// playwright.config.ts
export default {
  workers: process.env.CI ? 2 : undefined,  // Parallel workers
  fullyParallel: true,
};
```

---

#### 39. Tomek Sułkowski - Use Storybook for Component Development
**Guideline:** Develop and test components in isolation.

```tsx
// Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'Components/Button',
  component: Button,
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'outline'],
    },
  },
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: {
    variant: 'primary',
    children: 'Click me',
  },
};

export const Loading: Story = {
  args: {
    loading: true,
    children: 'Loading...',
  },
};
```

---

#### 40. Michael Shilman - Use Interaction Tests in Storybook
**Guideline:** Test user interactions in Storybook.

```tsx
import { within, userEvent } from '@storybook/testing-library';
import { expect } from '@storybook/jest';

export const FilledForm: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);

    await userEvent.type(canvas.getByLabelText('Email'), 'test@example.com');
    await userEvent.type(canvas.getByLabelText('Password'), 'password123');
    await userEvent.click(canvas.getByRole('button', { name: 'Sign in' }));

    await expect(canvas.getByText('Welcome back!')).toBeInTheDocument();
  },
};
```

---

### Category 5: Architecture & Best Practices (Guidelines 41-50)

#### 41. Alex Russell - Measure Performance Metrics
**Guideline:** Track Web Vitals (LCP, FID, CLS).

```tsx
import { getCLS, getFID, getLCP } from 'web-vitals';

getCLS(console.log);  // Cumulative Layout Shift
getFID(console.log);  // First Input Delay
getLCP(console.log);  // Largest Contentful Paint

// Send to analytics
function sendToAnalytics(metric) {
  const body = JSON.stringify(metric);
  navigator.sendBeacon('/analytics', body);
}

getCLS(sendToAnalytics);
getFID(sendToAnalytics);
getLCP(sendToAnalytics);
```

---

#### 42. Maxime Heckel - Profile with React DevTools
**Guideline:** Use Profiler to find performance bottlenecks.

```tsx
// Wrap components to profile
import { Profiler } from 'react';

function App() {
  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <Dashboard />
    </Profiler>
  );
}

function onRenderCallback(
  id,
  phase,
  actualDuration,
  baseDuration,
  startTime,
  commitTime
) {
  console.log(`${id} took ${actualDuration}ms to render`);
}
```

---

#### 43. Josh W. Comeau - Use CSS Modules or CSS-in-JS
**Guideline:** Scope styles to avoid conflicts.

```tsx
// ❌ BAD: Global CSS (conflicts)
import './Button.css';  // .button class is global!

// ✅ GOOD: CSS Modules
import styles from './Button.module.css';

function Button() {
  return <button className={styles.button}>Click</button>;
}

// ✅ ALSO GOOD: CSS-in-JS
import { css } from '@emotion/react';

const buttonStyles = css`
  background: blue;
  padding: 1rem;
`;

function Button() {
  return <button css={buttonStyles}>Click</button>;
}
```

---

#### 44. Sam Selikoff - Use Container/Presentational Pattern
**Guideline:** Separate data fetching from presentation.

```tsx
// ❌ BAD: Mixed concerns
function BrandList() {
  const { data, isLoading } = useQuery(['brands'], fetchBrands);

  if (isLoading) return <Spinner />;

  return (
    <div className="grid grid-cols-3 gap-4">
      {data.map((brand) => (
        <div key={brand.id} className="p-4 border rounded">
          <h2>{brand.name}</h2>
          <p>{brand.industry}</p>
        </div>
      ))}
    </div>
  );
}

// ✅ GOOD: Separated
// Container (data)
function BrandListContainer() {
  const { data, isLoading } = useQuery(['brands'], fetchBrands);

  if (isLoading) return <Spinner />;

  return <BrandListView brands={data} />;
}

// Presentational (UI)
function BrandListView({ brands }: { brands: Brand[] }) {
  return (
    <div className="grid grid-cols-3 gap-4">
      {brands.map((brand) => (
        <BrandCard key={brand.id} brand={brand} />
      ))}
    </div>
  );
}
```

**Why:** Easier testing, reusability, separation of concerns.

---

#### 45. Lydia Hallie - Use Error Boundaries
**Guideline:** Catch rendering errors gracefully.

```tsx
import { Component, ReactNode } from 'react';

class ErrorBoundary extends Component<
  { children: ReactNode },
  { hasError: boolean; error: Error | null }
> {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Send to error tracking service
  }

  render() {
    if (this.state.hasError) {
      return (
        <div>
          <h1>Something went wrong</h1>
          <details>
            <summary>Error details</summary>
            <pre>{this.state.error?.message}</pre>
          </details>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
<ErrorBoundary>
  <Dashboard />
</ErrorBoundary>
```

---

#### 46. Steve Kinney - Use Custom Hooks for Logic Reuse
**Guideline:** Extract reusable logic into custom hooks.

```tsx
// ❌ BAD: Duplicated logic
function ComponentA() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    fetchData().then(setData).finally(() => setLoading(false));
  }, []);

  // ...
}

function ComponentB() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    fetchData().then(setData).finally(() => setLoading(false));
  }, []);

  // ...
}

// ✅ GOOD: Custom hook
function useFetchData<T>(fetcher: () => Promise<T>) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    setLoading(true);
    fetcher()
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [fetcher]);

  return { data, loading, error };
}

// Reuse!
function ComponentA() {
  const { data, loading } = useFetchData(fetchUsers);
}

function ComponentB() {
  const { data, loading } = useFetchData(fetchBrands);
}
```

---

#### 47. Ben Ilegbodu - Use Proper Folder Structure
**Guideline:** Organize by feature, not by type.

```
// ❌ BAD: Organized by type
src/
├── components/
│   ├── BrandCard.tsx
│   ├── BrandList.tsx
│   ├── UserProfile.tsx
│   └── UserSettings.tsx
├── hooks/
│   ├── useBrands.ts
│   └── useUser.ts
└── services/
    ├── brandService.ts
    └── userService.ts

// ✅ GOOD: Organized by feature
src/
├── features/
│   ├── brands/
│   │   ├── components/
│   │   │   ├── BrandCard.tsx
│   │   │   └── BrandList.tsx
│   │   ├── hooks/
│   │   │   └── useBrands.ts
│   │   ├── services/
│   │   │   └── brandService.ts
│   │   └── types.ts
│   └── user/
│       ├── components/
│       │   ├── UserProfile.tsx
│       │   └── UserSettings.tsx
│       ├── hooks/
│       │   └── useUser.ts
│       └── services/
│           └── userService.ts
└── shared/
    ├── components/
    ├── hooks/
    └── utils/
```

**Why:** Easier to find files, better encapsulation, scalable.

---

#### 48. Harry Roberts - Lazy Load Images
**Guideline:** Native lazy loading for images.

```tsx
// ❌ BAD: All images loaded immediately
<img src="/large-image.jpg" alt="Product" />

// ✅ GOOD: Lazy load
<img src="/large-image.jpg" alt="Product" loading="lazy" />

// ✅ BETTER: With placeholder
function LazyImage({ src, alt }: { src: string; alt: string }) {
  const [loaded, setLoaded] = useState(false);

  return (
    <div className="relative">
      {!loaded && (
        <div className="absolute inset-0 bg-gray-200 animate-pulse" />
      )}
      <img
        src={src}
        alt={alt}
        loading="lazy"
        onLoad={() => setLoaded(true)}
        className={loaded ? 'opacity-100' : 'opacity-0'}
      />
    </div>
  );
}
```

---

#### 49. Anna Migas - Use Prefetch for Links
**Guideline:** Prefetch next page when link is hovered.

```tsx
// React Router v6
import { Link } from 'react-router-dom';

<Link
  to="/dashboard"
  prefetch="intent"  // Prefetch on hover
>
  Go to Dashboard
</Link>

// Or manually with React Query
function PrefetchLink({ to, children }) {
  const queryClient = useQueryClient();

  const prefetch = () => {
    queryClient.prefetchQuery(['dashboard-data'], fetchDashboard);
  };

  return (
    <Link to={to} onMouseEnter={prefetch}>
      {children}
    </Link>
  );
}
```

---

#### 50. Katie Hempenius - Minimize Bundle Size
**Guideline:** Analyze and reduce bundle size.

```bash
# Analyze bundle
npm run build
npx vite-bundle-visualizer

# Look for:
# - Large dependencies (can they be replaced?)
# - Duplicate code (dedupe)
# - Unused code (tree-shaking)

# Optimize imports
// ❌ BAD: Import entire library
import _ from 'lodash';

// ✅ GOOD: Import only what you need
import debounce from 'lodash/debounce';

// ✅ BEST: Use tree-shakeable alternative
import { debounce } from 'lodash-es';
```

**Target:** <200KB gzipped for initial bundle.

---

## Summary: Priority Implementation Checklist

**Immediate (Do First):**
- [ ] #4 - Separate server state (React Query) from client state (Zustand)
- [ ] #6 - Derive state instead of storing it
- [ ] #14 - Use selectors to minimize re-renders
- [ ] #21 - Use discriminated unions for type safety
- [ ] #45 - Add error boundaries
- [ ] #47 - Organize code by feature, not type

**High Priority (Do This Week):**
- [ ] #1 - Colocate state close to usage
- [ ] #7 - Use reducers for complex state logic
- [ ] #12 - Code-split by route
- [ ] #18 - Virtualize long lists
- [ ] #33 - Write comprehensive E2E tests

**Medium Priority (Do This Month):**
- [ ] #2 - Normalize state shape
- [ ] #9 - Sync important state with URL
- [ ] #11 - Memoize expensive calculations
- [ ] #19 - Debounce expensive updates
- [ ] #20 - Implement optimistic updates

**Nice to Have (Future):**
- [ ] #8 - Model state as state machines (XState)
- [ ] #16 - Prefetch data on hover
- [ ] #17 - Use Suspense for data fetching
- [ ] #28 - Pattern matching with ts-pattern
- [ ] #50 - Optimize bundle size

---

## Related Documentation

- [DESIGN_TOKENS.md](./DESIGN_TOKENS.md) - Consistent UI theming
- [TEST_STRATEGY.md](./TEST_STRATEGY.md) - Testing best practices
- [ACCESSIBILITY_TESTING.md](./ACCESSIBILITY_TESTING.md) - a11y guidelines
- [ADR-010: Zustand State Management](./ADR/010-zustand-state-management.md)

---

**Last Updated:** 2026-01-08
**Expert Panel:** 50 world-class React developers
**Guidelines:** 50 actionable best practices
**Target:** Production-ready, scalable React application
**Maintained by:** Frontend Team
