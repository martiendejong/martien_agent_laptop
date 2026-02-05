# ADR-010: Zustand for State Management

**Status:** Accepted
**Date:** 2024-07-10
**Decision Makers:** Frontend Team

## Context

React components need to share state (user auth, chat messages, UI preferences). We evaluated several state management solutions:

**Requirements:**
- Lightweight (small bundle size)
- TypeScript support
- Easy to learn
- No boilerplate
- Works with React 18
- Support for async actions
- DevTools for debugging

## Decision

**Use Zustand** as primary state management library.

**Architecture:**
- **authStore** - User authentication, token, profile
- **chatStore** - Chat messages, active conversation
- **uiStore** - Theme, sidebar state, modals
- **React Query** - Server state (API data, caching)

**Pattern:**
```typescript
// Define store
const useAuthStore = create<AuthState>((set) => ({
  user: null,
  token: null,
  login: (token, user) => set({ token, user }),
  logout: () => set({ token: null, user: null })
}));

// Use in component
function Profile() {
  const user = useAuthStore(state => state.user);
  return <div>{user?.name}</div>;
}
```

## Consequences

### Positive
✅ **Minimal Boilerplate**
- No reducers, actions, or dispatch
- Direct state updates via `set()`
- Easy to understand

✅ **Small Bundle Size**
- Only 1.2 KB (gzipped)
- vs Redux (10 KB), MobX (16 KB)
- Faster page loads

✅ **TypeScript First**
- Excellent TypeScript support
- Type inference works perfectly
- No manual type definitions needed

✅ **No Context Providers**
- No wrapping app in providers
- Works outside React (vanilla JS)
- Simpler component tree

✅ **Fast Performance**
- Only re-renders components that use changed state
- Selector-based subscriptions
- No unnecessary renders

✅ **DevTools Support**
- Redux DevTools integration
- Time-travel debugging
- State inspection

✅ **Easy to Test**
- Stores are just functions
- No complex setup
- Can test outside React

### Negative
❌ **Less Ecosystem**
- Smaller community than Redux
- Fewer middleware options
- Less Stack Overflow answers

❌ **No Official Patterns**
- Less opinionated than Redux
- Team must decide on patterns
- Can lead to inconsistency

### Neutral
⚪ **Learning Curve**
- Different from Redux/Context
- But: Simpler, so faster to learn
- Most devs pick it up in 1 day

## Alternatives Considered

### Option A: Redux + Redux Toolkit
**Pros:**
- Most popular (large ecosystem)
- Well-documented
- Mature and battle-tested
- Great DevTools
- Time-travel debugging

**Cons:**
- **Too much boilerplate** (actions, reducers, dispatch)
- Larger bundle size (10 KB)
- Steeper learning curve
- Overkill for our app size

**Why rejected:** Boilerplate overhead not justified for medium-sized app.

### Option B: React Context + useReducer
**Pros:**
- Built into React (no dependency)
- Standard React approach
- Everyone knows it

**Cons:**
- **Performance issues** with large state trees
- Re-renders entire context on any change
- Verbose (need provider wrappers)
- Hard to organize multiple contexts

**Why rejected:** Performance and developer experience issues.

### Option C: MobX
**Pros:**
- Very easy to use (reactive)
- Minimal boilerplate
- Good TypeScript support

**Cons:**
- Larger bundle size (16 KB)
- Less popular than Redux
- Decorator syntax can be confusing
- "Magic" reactivity can hide bugs

**Why rejected:** Larger size, less predictable than Zustand.

### Option D: Jotai / Recoil (Atomic State)
**Pros:**
- Atomic state management (granular)
- Great performance
- Modern approach

**Cons:**
- Less mature
- Smaller ecosystem
- Different mental model (atoms)
- Team unfamiliar with pattern

**Why rejected:** Team prefers familiar store pattern. Zustand is simpler.

### Option E: Valtio (Proxy-Based)
**Pros:**
- Very simple (mutate state directly)
- Small bundle size
- Made by same author as Zustand

**Cons:**
- Newer, less proven
- Proxy-based approach has gotchas
- Immutability is clearer

**Why rejected:** Zustand is more mature, clearer immutability.

## Implementation Details

### Store Structure

**authStore.ts** - Authentication state
```typescript
interface AuthState {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  login: (token: string, user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  token: localStorage.getItem('jwt'),
  isLoading: false,
  login: (token, user) => {
    localStorage.setItem('jwt', token);
    set({ token, user });
  },
  logout: () => {
    localStorage.removeItem('jwt');
    set({ token: null, user: null });
  }
}));
```

**chatStore.ts** - Chat state
```typescript
interface ChatState {
  messages: Message[];
  activeConversation: string | null;
  addMessage: (message: Message) => void;
  clearMessages: () => void;
}

export const useChatStore = create<ChatState>((set) => ({
  messages: [],
  activeConversation: null,
  addMessage: (message) => set((state) => ({
    messages: [...state.messages, message]
  })),
  clearMessages: () => set({ messages: [] })
}));
```

### Usage Patterns

**1. Select specific fields (avoid re-renders)**
```typescript
// ✅ Good: Only re-renders when user.name changes
const userName = useAuthStore(state => state.user?.name);

// ❌ Bad: Re-renders on any auth state change
const { user } = useAuthStore();
```

**2. Use shallow equality for objects**
```typescript
import { shallow } from 'zustand/shallow';

const { user, token } = useAuthStore(
  state => ({ user: state.user, token: state.token }),
  shallow
);
```

**3. Async actions**
```typescript
const useAuthStore = create<AuthState>((set) => ({
  login: async (email, password) => {
    set({ isLoading: true });
    try {
      const response = await api.post('/auth/login', { email, password });
      set({ token: response.token, user: response.user, isLoading: false });
    } catch (error) {
      set({ isLoading: false });
      throw error;
    }
  }
}));
```

### DevTools Integration

```typescript
import { devtools } from 'zustand/middleware';

export const useAuthStore = create<AuthState>()(
  devtools(
    (set) => ({
      // ... state
    }),
    { name: 'AuthStore' }
  )
);
```

## Division of Responsibilities

**Zustand:** Client-side UI state
- Authentication (user, token)
- UI preferences (theme, sidebar)
- Temporary state (modals, forms)

**React Query (TanStack Query):** Server state
- API data fetching
- Caching
- Background refetching
- Optimistic updates

**Why both?**
- Zustand: Great for simple client state
- React Query: Great for server state with caching
- Together: Best of both worlds

## Testing Strategy

```typescript
// Reset store between tests
beforeEach(() => {
  useAuthStore.setState({ user: null, token: null });
});

// Test store actions
it('should login user', () => {
  const { result } = renderHook(() => useAuthStore());

  act(() => {
    result.current.login('token123', mockUser);
  });

  expect(result.current.user).toEqual(mockUser);
  expect(result.current.token).toBe('token123');
});
```

## Migration Path

If Zustand no longer fits:

**To Redux:**
- Similar enough that migration is straightforward
- Zustand stores map to Redux slices
- Can migrate one store at a time

**To React Query Only:**
- If most state becomes server state
- Remove Zustand stores
- Use React Query for everything

## References

- Zustand: https://github.com/pmndrs/zustand
- React Query: https://tanstack.com/query/latest
- State Management Comparison: https://www.npmtrends.com/zustand-vs-redux-vs-mobx

---

**Review Date:** 2026-07-01
**Related ADRs:**
- ADR-009: React 18 + TypeScript Stack
- ADR-012: Vite as Build Tool
