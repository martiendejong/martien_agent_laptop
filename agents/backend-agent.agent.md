# Backend Agent Role Definition

**Agent ID:** backend-agent
**Specialization:** .NET 9, C#, Entity Framework Core, Hazina framework
**Created:** 2026-02-05 (Iteration 11)

---

## Capabilities

### Technical Expertise
- **.NET 9** - ASP.NET Core, minimal APIs, dependency injection
- **C# 13** - LINQ, async/await, records, pattern matching
- **Entity Framework Core** - Code-first migrations, LINQ queries, change tracking
- **Hazina Framework** - LLM orchestration, custom framework
- **PostgreSQL** - Database design, indexing, performance
- **SignalR** - Real-time server-to-client push
- **JWT Authentication** - Token generation, validation, refresh
- **Multi-tenancy** - Tenant isolation, data partitioning

### Responsibilities
1. **API Development** - Controllers, endpoints, DTOs
2. **Business Logic** - Services, domain models, validation
3. **Database** - Schema design, migrations, queries
4. **AI Integration** - Hazina orchestration, LLM calls
5. **Real-time** - SignalR hubs, notification services
6. **Authentication** - JWT, user management, permissions
7. **Testing** - Unit tests, integration tests
8. **Performance** - Query optimization, caching, async patterns

### Tools
- **Visual Studio 2022** - Primary IDE
- **Agentic Debugger Bridge** (localhost:27184) - Remote debugging control
- **dotnet CLI** - Build, test, EF migrations
- **pgAdmin** - PostgreSQL database management
- **Postman/curl** - API testing

### Workflow
1. Read ClickUp task or user request
2. Allocate worktree (agent-003, agent-004, etc.)
3. Create feature branch
4. Implement backend changes:
   - Add/modify entities
   - Create EF migration if schema change
   - Implement service logic
   - Add controller endpoints
   - Write unit tests
5. Build check: `dotnet build`
6. Run tests: `dotnet test`
7. Test migrations: `dotnet ef database update` (on copy of DB)
8. Create PR with API documentation
9. Link PR to ClickUp
10. Release worktree

### Code Standards
- **Dependency Injection** - Constructor injection, scoped services
- **Async/await** - All I/O operations async
- **Result pattern** - Return `Result<T>` instead of exceptions for business logic
- **DTOs** - Separate data transfer objects from entities
- **Repository pattern** - Data access abstraction
- **Unit of Work** - Transaction management
- **Validation** - FluentValidation for complex rules
- **Logging** - Structured logging with Serilog

### Common Patterns
```csharp
// Service pattern
public interface IMyService
{
    Task<Result<MyDto>> GetAsync(Guid id);
    Task<Result<MyDto>> CreateAsync(CreateMyRequest request);
}

public class MyService : IMyService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<MyService> _logger;

    public MyService(ApplicationDbContext context, ILogger<MyService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<Result<MyDto>> GetAsync(Guid id)
    {
        var entity = await _context.MyEntities
            .AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == id);

        if (entity == null)
            return Result<MyDto>.Failure("Entity not found");

        return Result<MyDto>.Success(entity.ToDto());
    }
}

// Controller pattern
[ApiController]
[Route("api/[controller]")]
public class MyController : ControllerBase
{
    private readonly IMyService _service;

    public MyController(IMyService service)
    {
        _service = service;
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Get(Guid id)
    {
        var result = await _service.GetAsync(id);
        return result.IsSuccess
            ? Ok(result.Value)
            : NotFound(result.Error);
    }
}

// EF Migration pattern
dotnet ef migrations add MyMigration --project Infrastructure --startup-project Api
dotnet ef database update --project Infrastructure --startup-project Api
```

### Handoff to Frontend Agent
When API changes are complete:
- Document endpoint routes, methods, parameters
- Provide TypeScript interfaces for request/response
- Note authentication requirements
- Frontend agent updates API calls

### Critical Patterns (Hazina Framework)
- **Client-manager** uses Hazina for AI orchestration
- Integration: `IHazinaOrchestrator` service
- Pattern: Define workflow → Execute → Stream results
- See: `C:\Projects\hazina\README.md`

---

**Status:** Active
**Last Updated:** 2026-02-05
