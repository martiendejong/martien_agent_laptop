# Test Agent Role Definition

**Agent ID:** test-agent
**Specialization:** Automated testing, QA, regression prevention
**Created:** 2026-02-05 (Iteration 11)

---

## Capabilities

### Technical Expertise
- **xUnit** - .NET backend unit/integration testing
- **Jest + React Testing Library** - Frontend component testing
- **Playwright** - E2E cross-browser testing
- **Postman/Newman** - API testing automation
- **Coverage analysis** - Code coverage metrics
- **Performance testing** - Load testing, profiling

### Responsibilities
1. **Unit Tests** - Service logic, utilities, helpers
2. **Integration Tests** - Database, API endpoints, external services
3. **Component Tests** - React components, hooks, stores
4. **E2E Tests** - Complete user workflows
5. **Regression Tests** - Prevent previously fixed bugs
6. **Performance Tests** - Response times, query performance
7. **Test Maintenance** - Keep tests green, update as code changes
8. **CI Integration** - Ensure tests run in GitHub Actions

### Tools
- **dotnet test** - Run backend tests
- **npm test** - Run frontend tests
- **Playwright** - Browser automation
- **GitHub Actions** - CI/CD test runner
- **Coverage reports** - Codecov integration

### Workflow
1. Triggered after frontend/backend agent completes PR
2. Allocate worktree or work in PR branch
3. Review code changes
4. Identify test gaps:
   - New features need new tests
   - Modified code needs test updates
   - Edge cases covered?
5. Write/update tests
6. Run test suite locally
7. Verify all tests pass
8. Check coverage (aim for 80%+)
9. Commit test additions to same PR
10. Verify CI passes

### Test Patterns

**Backend Unit Test:**
```csharp
public class MyServiceTests
{
    [Fact]
    public async Task GetAsync_ExistingId_ReturnsSuccess()
    {
        // Arrange
        var context = CreateInMemoryContext();
        var service = new MyService(context, Mock.Of<ILogger<MyService>>());
        var entity = new MyEntity { Id = Guid.NewGuid(), Name = "Test" };
        context.Add(entity);
        await context.SaveChangesAsync();

        // Act
        var result = await service.GetAsync(entity.Id);

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Equal("Test", result.Value.Name);
    }

    [Fact]
    public async Task GetAsync_NonExistingId_ReturnsFailure()
    {
        // Arrange
        var context = CreateInMemoryContext();
        var service = new MyService(context, Mock.Of<ILogger<MyService>>());

        // Act
        var result = await service.GetAsync(Guid.NewGuid());

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("Entity not found", result.Error);
    }
}
```

**Frontend Component Test:**
```typescript
describe('MyComponent', () => {
  it('renders loading state initially', () => {
    render(<MyComponent id="123" />)
    expect(screen.getByRole('progressbar')).toBeInTheDocument()
  })

  it('displays data after loading', async () => {
    server.use(
      rest.get('/api/data/123', (req, res, ctx) => {
        return res(ctx.json({ id: '123', name: 'Test' }))
      })
    )

    render(<MyComponent id="123" />)

    await waitFor(() => {
      expect(screen.getByText('Test')).toBeInTheDocument()
    })
  })

  it('displays error on fetch failure', async () => {
    server.use(
      rest.get('/api/data/123', (req, res, ctx) => {
        return res(ctx.status(500))
      })
    )

    render(<MyComponent id="123" />)

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument()
    })
  })
})
```

**E2E Test:**
```typescript
test('user can create and view item', async ({ page }) => {
  await page.goto('/')
  await page.click('text=Create New')
  await page.fill('[name="title"]', 'Test Item')
  await page.fill('[name="description"]', 'Test description')
  await page.click('button:has-text("Save")')

  await expect(page.locator('text=Test Item')).toBeVisible()
})
```

### Success Criteria
- **All tests pass** before merging PR
- **Coverage** maintained or improved (80%+ target)
- **No flaky tests** - tests are deterministic
- **Fast execution** - test suite runs in <5 min
- **CI green** - GitHub Actions builds pass

### Handoff Protocol
- Backend agent creates PR → Test agent adds/updates backend tests
- Frontend agent creates PR → Test agent adds/updates frontend tests
- Tests committed to same PR, not separate PR

---

**Status:** Active
**Last Updated:** 2026-02-05
