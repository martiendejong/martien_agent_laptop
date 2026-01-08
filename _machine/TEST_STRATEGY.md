# Test Strategy 🧪

**Purpose:** Ensure Brand2Boost quality through comprehensive, automated testing.

**Goal:** 80%+ code coverage, catch bugs before production, fast feedback loop.

---

## Testing Pyramid

```
        /\
       /  \  E2E Tests (5%)
      /----\
     /      \  Integration Tests (20%)
    /--------\
   /          \  Unit Tests (75%)
  /--------------\
```

**Distribution:**
- **75% Unit Tests** - Fast, isolated, many
- **20% Integration Tests** - API endpoints, database
- **5% E2E Tests** - Full user flows, critical paths

---

## Test Types

### 1. Unit Tests (75%)

**What:** Test individual functions/classes in isolation.

**Backend (C# xUnit):**

```csharp
// Test/Services/TokenServiceTests.cs
public class TokenServiceTests
{
    private readonly Mock<AppDbContext> _dbMock;
    private readonly TokenService _service;

    public TokenServiceTests()
    {
        _dbMock = new Mock<AppDbContext>();
        _service = new TokenService(_dbMock.Object);
    }

    [Fact]
    public async Task DeductTokens_SufficientBalance_Success()
    {
        // Arrange
        var userId = "user-123";
        var balance = new TokenBalance { UserId = userId, AvailableTokens = 1000 };
        _dbMock.Setup(db => db.TokenBalances.FindAsync(userId)).ReturnsAsync(balance);

        // Act
        var result = await _service.DeductTokens(userId, 100);

        // Assert
        Assert.True(result);
        Assert.Equal(900, balance.AvailableTokens);
    }

    [Fact]
    public async Task DeductTokens_InsufficientBalance_Fails()
    {
        // Arrange
        var balance = new TokenBalance { AvailableTokens = 50 };
        _dbMock.Setup(db => db.TokenBalances.FindAsync(It.IsAny<string>())).ReturnsAsync(balance);

        // Act
        var result = await _service.DeductTokens("user-123", 100);

        // Assert
        Assert.False(result);
        Assert.Equal(50, balance.AvailableTokens);  // Unchanged
    }
}
```

**Frontend (Jest + React Testing Library):**

```typescript
// src/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click</Button>);

    fireEvent.click(screen.getByText('Click'));

    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('is disabled when loading', () => {
    render(<Button loading>Submit</Button>);

    const button = screen.getByRole('button');
    expect(button).toBeDisabled();
  });
});
```

**When to write:**
- Every service method
- Every utility function
- Every React component
- Every business logic function

**Target coverage:** 80%+

---

### 2. Integration Tests (20%)

**What:** Test multiple components working together (API + database, service + repository).

**Backend (API Tests):**

```csharp
// Test/Integration/AuthControllerTests.cs
public class AuthControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public AuthControllerTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Login_ValidCredentials_ReturnsToken()
    {
        // Arrange
        var request = new
        {
            email = "test@example.com",
            password = "Test123!"
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/auth/login", request);

        // Assert
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<LoginResponse>();
        Assert.NotNull(result.Token);
        Assert.NotNull(result.User);
    }

    [Fact]
    public async Task Login_InvalidPassword_Returns401()
    {
        // Arrange
        var request = new
        {
            email = "test@example.com",
            password = "WrongPassword"
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/auth/login", request);

        // Assert
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task GetBrands_WithoutAuth_Returns401()
    {
        // Act
        var response = await _client.GetAsync("/api/brands");

        // Assert
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task GetBrands_WithAuth_ReturnsUserBrands()
    {
        // Arrange
        var token = await GetAuthToken();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        // Act
        var response = await _client.GetAsync("/api/brands");

        // Assert
        response.EnsureSuccessStatusCode();
        var brands = await response.Content.ReadFromJsonAsync<List<Brand>>();
        Assert.NotEmpty(brands);
    }
}
```

**Frontend (Integration Tests):**

```typescript
// src/features/auth/Login.integration.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { Login } from './Login';

const server = setupServer(
  rest.post('/api/auth/login', (req, res, ctx) => {
    const { email, password } = req.body as any;

    if (email === 'test@example.com' && password === 'Test123!') {
      return res(
        ctx.json({
          token: 'fake-jwt-token',
          user: { id: '123', email: 'test@example.com' },
        })
      );
    }

    return res(ctx.status(401));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('login flow - success', async () => {
  render(<Login />);

  await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');
  await userEvent.type(screen.getByLabelText('Password'), 'Test123!');
  await userEvent.click(screen.getByRole('button', { name: 'Sign in' }));

  await waitFor(() => {
    expect(localStorage.getItem('jwt')).toBe('fake-jwt-token');
    expect(window.location.pathname).toBe('/dashboard');
  });
});

test('login flow - invalid credentials', async () => {
  render(<Login />);

  await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');
  await userEvent.type(screen.getByLabelText('Password'), 'wrong');
  await userEvent.click(screen.getByRole('button', { name: 'Sign in' }));

  await waitFor(() => {
    expect(screen.getByText('Invalid credentials')).toBeInTheDocument();
  });
});
```

**When to write:**
- Every API endpoint
- User flows involving multiple components
- Database operations
- External API integrations (mocked)

**Target coverage:** All critical paths

---

### 3. E2E Tests (5%)

**What:** Test complete user journeys in real browser.

**Playwright:**

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication Flow', () => {
  test('user can sign up, login, and access dashboard', async ({ page }) => {
    // Sign up
    await page.goto('/signup');
    await page.fill('[name="email"]', 'newuser@example.com');
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.fill('[name="confirmPassword"]', 'SecurePass123!');
    await page.click('button[type="submit"]');

    // Should redirect to dashboard
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('h1')).toContainText('Welcome');

    // Logout
    await page.click('button:has-text("Logout")');
    await expect(page).toHaveURL('/login');

    // Login again
    await page.fill('[name="email"]', 'newuser@example.com');
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL('/dashboard');
  });

  test('invalid login shows error', async ({ page }) => {
    await page.goto('/login');
    await page.fill('[name="email"]', 'wrong@example.com');
    await page.fill('[name="password"]', 'wrong');
    await page.click('button[type="submit"]');

    await expect(page.locator('.error-message')).toContainText('Invalid credentials');
  });
});

test.describe('Brand Creation Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/login');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'Test123!');
    await page.click('button[type="submit"]');
    await page.waitForURL('/dashboard');
  });

  test('create new brand', async ({ page }) => {
    await page.click('button:has-text("New Brand")');

    await page.fill('[name="name"]', 'My Coffee Brand');
    await page.selectOption('[name="industry"]', 'Food & Beverage');
    await page.fill('[name="description"]', 'Artisan coffee roaster');
    await page.click('button[type="submit"]');

    await expect(page.locator('.success-message')).toContainText('Brand created');
    await expect(page.locator('h2')).toContainText('My Coffee Brand');
  });
});
```

**When to write:**
- Critical user flows (signup, checkout, key features)
- Cross-browser compatibility checks
- Mobile responsiveness

**Target coverage:** Top 5 user journeys

---

## Test Organization

### Backend Structure

```
ClientManager.Tests/
├── Unit/
│   ├── Services/
│   │   ├── TokenServiceTests.cs
│   │   ├── BrandServiceTests.cs
│   │   └── ChatServiceTests.cs
│   ├── Utilities/
│   │   └── StringHelpersTests.cs
│   └── Validators/
│       └── RegisterRequestValidatorTests.cs
├── Integration/
│   ├── Controllers/
│   │   ├── AuthControllerTests.cs
│   │   ├── BrandControllerTests.cs
│   │   └── ChatControllerTests.cs
│   └── Database/
│       └── MigrationTests.cs
└── TestUtilities/
    ├── TestData.cs
    ├── MockFactory.cs
    └── TestServer.cs
```

### Frontend Structure

```
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   └── Button.test.tsx
│   └── Input/
│       ├── Input.tsx
│       └── Input.test.tsx
├── features/
│   ├── auth/
│   │   ├── Login.tsx
│   │   ├── Login.test.tsx
│   │   └── Login.integration.test.tsx
│   └── brands/
│       ├── BrandList.tsx
│       └── BrandList.test.tsx
└── utils/
    ├── validation.ts
    └── validation.test.ts
```

---

## Running Tests

### Backend (CLI)

```bash
# Run all tests
dotnet test

# Run specific test file
dotnet test --filter "FullyQualifiedName~TokenServiceTests"

# Run with coverage
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover

# Watch mode (re-run on file change)
dotnet watch test
```

### Frontend (CLI)

```bash
# Run all tests
npm test

# Run specific test file
npm test -- Button.test.tsx

# Run with coverage
npm test -- --coverage

# Watch mode
npm test -- --watch

# Update snapshots
npm test -- -u
```

### E2E (Playwright)

```bash
# Run all E2E tests
npx playwright test

# Run specific test
npx playwright test auth.spec.ts

# Run in headed mode (see browser)
npx playwright test --headed

# Debug mode
npx playwright test --debug

# Generate test report
npx playwright show-report
```

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '9.0.x'

      - name: Restore dependencies
        run: dotnet restore

      - name: Build
        run: dotnet build --no-restore

      - name: Run tests
        run: dotnet test --no-build --verbosity normal /p:CollectCoverage=true

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage.opencover.xml

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/coverage-final.json

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npx playwright test

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

---

## Test Coverage Goals

| Component | Target Coverage | Current |
|-----------|----------------|---------|
| **Backend Services** | 90% | - |
| **Backend Controllers** | 80% | - |
| **Frontend Components** | 85% | - |
| **Frontend Utils** | 95% | - |
| **E2E Critical Paths** | 100% | - |

**View coverage reports:**
```bash
# Backend
dotnet test /p:CollectCoverage=true
open coverage/index.html

# Frontend
npm test -- --coverage
open coverage/lcov-report/index.html
```

---

## Testing Best Practices

### DO:
✅ Test behavior, not implementation
✅ Write tests before fixing bugs (TDD)
✅ Keep tests fast (< 100ms for unit tests)
✅ Use descriptive test names
✅ Follow AAA pattern (Arrange, Act, Assert)
✅ Mock external dependencies
✅ Test edge cases and error paths
✅ Keep tests independent

### DON'T:
❌ Test private methods directly
❌ Have tests depend on each other
❌ Use random data (use deterministic fixtures)
❌ Sleep/wait for arbitrary durations
❌ Hit real external APIs
❌ Commit failing tests
❌ Skip writing tests for "simple" code

---

## Test Data Management

### Fixtures (Reusable Test Data)

```csharp
// TestData.cs
public static class TestData
{
    public static User CreateTestUser(string email = "test@example.com")
    {
        return new User
        {
            Id = Guid.NewGuid().ToString(),
            Email = email,
            FullName = "Test User",
            CreatedAt = DateTime.UtcNow
        };
    }

    public static Brand CreateTestBrand(string userId)
    {
        return new Brand
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Name = "Test Brand",
            Industry = "Technology",
            CreatedAt = DateTime.UtcNow
        };
    }
}
```

### Database Seeding (Integration Tests)

```csharp
public class TestDbContext : AppDbContext
{
    public TestDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public static async Task<TestDbContext> CreateInMemory()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        var context = new TestDbContext(options);
        await context.Database.EnsureCreatedAsync();

        // Seed test data
        context.Users.Add(TestData.CreateTestUser());
        await context.SaveChangesAsync();

        return context;
    }
}
```

---

## Snapshot Testing (UI Components)

**When UI changes are expected, update snapshots:**

```typescript
import { render } from '@testing-library/react';
import { Button } from './Button';

test('Button renders correctly', () => {
  const { container } = render(<Button variant="primary">Click me</Button>);
  expect(container.firstChild).toMatchSnapshot();
});

// To update snapshots:
// npm test -- -u
```

---

## Performance Testing

### Load Testing (k6)

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },  // Ramp up to 100 users
    { duration: '5m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests < 500ms
  },
};

export default function () {
  const res = http.get('https://staging.brand2boost.com/api/brands');

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
```

**Run:**
```bash
k6 run load-test.js
```

---

## Mutation Testing (Advanced)

**Test the tests:**

```bash
# Install Stryker (mutation testing)
npm install --save-dev @stryker-mutator/core

# Run mutation tests
npx stryker run

# Result: "80% of mutants killed" = tests caught 80% of introduced bugs
```

---

## Test Checklist (Before PR)

**Before creating pull request:**
- [ ] All tests pass locally
- [ ] New code has tests (80%+ coverage)
- [ ] No test warnings
- [ ] Tests run in < 5 minutes (total)
- [ ] E2E tests pass (if UI changed)
- [ ] Coverage report reviewed
- [ ] No flaky tests (intermittent failures)

---

## Related Documentation

- [ACCESSIBILITY_TESTING.md](./ACCESSIBILITY_TESTING.md) - a11y testing
- [SECURITY_CHECKLIST.md](./SECURITY_CHECKLIST.md) - Security testing
- [CI/CD Workflows](./.github/workflows/) - Automated testing pipeline

---

**Last Updated:** 2026-01-08
**Test Framework:** xUnit (backend), Jest (frontend), Playwright (E2E)
**Coverage Goal:** 80%+
**Maintained by:** Engineering Team
