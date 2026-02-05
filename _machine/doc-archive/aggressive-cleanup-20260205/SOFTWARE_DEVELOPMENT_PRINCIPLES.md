# Software Development Principles - Universal Rules

**Last Updated:** 2026-01-17
**Status:** MANDATORY for all code changes
**Scope:** All projects (mastermindgroupAI, client-manager, hazina, etc.)

---

## 🎯 Core Philosophy

**Guiding Principle:** Code is read 10x more than it's written. Optimize for clarity, not cleverness.

**Primary Objective:** Create architecturally pure systems that are easy to understand, maintain, and extend.

---

## 📋 The Boy Scout Rule (MANDATORY)

### Definition
**"Always leave the code better than you found it."**

### Implementation Protocol

**BEFORE making your primary change:**
1. Read the entire file you're about to modify
2. Identify small improvements (max 5 minutes each):
   - Remove unused imports/variables
   - Fix inconsistent naming
   - Add missing XML documentation
   - Extract magic numbers to named constants
   - Simplify complex conditionals
   - Remove commented-out code
   - Fix formatting inconsistencies

**DURING your primary change:**
3. Apply improvements as you go
4. Keep cleanup commits separate from feature commits (optional but preferred)

**AFTER your primary change:**
5. Review the file one more time
6. Ask: "Is this file better than when I started?"

### Examples

#### ❌ BAD - Changed only what was needed
```csharp
// Added new method but left existing mess
public class UserService
{
    private readonly IUserRepository _repo; // Good
    private ILogger logger; // Inconsistent naming - should fix

    // TODO: Remove this old method - should remove
    // public void OldMethod() { }

    public async Task<User> GetUserAsync(int id) // Your new method
    {
        return await _repo.GetByIdAsync(id);
    }

    public void UpdateUser(User u) // Missing XML doc, poor param name
    {
        logger.LogInformation("Updating user " + u.Id); // String concat instead of interpolation
    }
}
```

#### ✅ GOOD - Boy Scout Rule applied
```csharp
/// <summary>
/// Manages user-related business logic and data access.
/// </summary>
public class UserService
{
    private readonly IUserRepository _repository;
    private readonly ILogger<UserService> _logger; // Fixed naming consistency

    public UserService(IUserRepository repository, ILogger<UserService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    /// <summary>
    /// Retrieves a user by their unique identifier.
    /// </summary>
    public async Task<User> GetUserAsync(int id)
    {
        return await _repository.GetByIdAsync(id);
    }

    /// <summary>
    /// Updates an existing user's information.
    /// </summary>
    public void UpdateUser(User user) // Fixed param name
    {
        _logger.LogInformation("Updating user {UserId}", user.Id); // Fixed string interpolation
    }
}
```

### Boy Scout Checklist

Every file edit must check:
- ☐ Unused imports removed
- ☐ Consistent naming (fields, parameters, variables)
- ☐ XML documentation added for public members
- ☐ Magic numbers extracted to constants
- ☐ Commented-out code removed
- ☐ TODOs addressed or converted to GitHub issues
- ☐ String concatenation → interpolation
- ☐ Inconsistent formatting fixed
- ☐ Complex conditions simplified
- ☐ Duplicated code extracted to methods

---

## 🏛️ Architectural Purity Principles

### Principle 1: Clarity Over Cleverness

**Rule:** If a solution requires explanation, it's not clear enough.

**Application:**
- Prefer explicit over implicit
- Prefer verbose over terse if it improves understanding
- Prefer simple patterns over advanced techniques
- Write code for junior developers to understand

#### ❌ BAD - Clever but obscure
```csharp
// WTF does this do?
var results = users.Where(u => u.Age > 18)
                  .SelectMany(u => u.Orders)
                  .GroupBy(o => o.Category)
                  .ToDictionary(g => g.Key, g => g.Sum(o => o.Total));
```

#### ✅ GOOD - Clear and understandable
```csharp
// Get total sales by category for adult users
var adultUsers = users.Where(user => user.Age > 18);
var allOrders = adultUsers.SelectMany(user => user.Orders);
var ordersByCategory = allOrders.GroupBy(order => order.Category);
var totalSalesByCategory = ordersByCategory.ToDictionary(
    categoryGroup => categoryGroup.Key,
    categoryGroup => categoryGroup.Sum(order => order.Total)
);
```

### Principle 2: Single Responsibility Principle (SRP)

**Rule:** Each class/method should have ONE reason to change.

**Application:**
- Classes should do ONE thing well
- Methods should have ONE clear purpose
- Split responsibilities when you see "and" in descriptions

#### ❌ BAD - Multiple responsibilities
```csharp
public class OrderService
{
    public void ProcessOrder(Order order)
    {
        // Validates order
        if (order.Items.Count == 0) throw new Exception("Empty order");

        // Calculates total
        var total = order.Items.Sum(i => i.Price * i.Quantity);

        // Sends email
        var smtp = new SmtpClient();
        smtp.Send("Order confirmed", order.UserId);

        // Updates database
        _db.Orders.Add(order);
        _db.SaveChanges();

        // Logs to file
        File.AppendAllText("orders.log", $"Order {order.Id} processed");
    }
}
```

#### ✅ GOOD - Single responsibilities
```csharp
public class OrderService
{
    private readonly IOrderValidator _validator;
    private readonly IOrderRepository _repository;
    private readonly IEmailService _emailService;
    private readonly ILogger<OrderService> _logger;

    public async Task ProcessOrderAsync(Order order)
    {
        _validator.Validate(order); // Validation responsibility
        var total = CalculateTotal(order); // Calculation responsibility

        await _repository.SaveOrderAsync(order); // Persistence responsibility
        await _emailService.SendOrderConfirmationAsync(order); // Notification responsibility

        _logger.LogInformation("Processed order {OrderId}", order.Id); // Logging responsibility
    }

    private decimal CalculateTotal(Order order)
    {
        return order.Items.Sum(item => item.Price * item.Quantity);
    }
}
```

### Principle 3: Dependency Inversion Principle (DIP)

**Rule:** Depend on abstractions, not concretions.

**Application:**
- Inject dependencies via constructor
- Use interfaces for external dependencies
- Never use `new` for dependencies (use DI container)

#### ❌ BAD - Tight coupling
```csharp
public class UserService
{
    public void RegisterUser(User user)
    {
        var db = new SqlServerDatabase(); // Tight coupling to SQL Server
        var hasher = new BCryptHasher(); // Tight coupling to BCrypt
        var emailer = new SmtpEmailService(); // Tight coupling to SMTP

        user.PasswordHash = hasher.Hash(user.Password);
        db.SaveUser(user);
        emailer.SendWelcomeEmail(user.Email);
    }
}
```

#### ✅ GOOD - Loose coupling via DI
```csharp
public class UserService
{
    private readonly IUserRepository _repository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IEmailService _emailService;

    public UserService(
        IUserRepository repository,
        IPasswordHasher passwordHasher,
        IEmailService emailService)
    {
        _repository = repository;
        _passwordHasher = passwordHasher;
        _emailService = emailService;
    }

    public async Task RegisterUserAsync(User user)
    {
        user.PasswordHash = _passwordHasher.Hash(user.Password);
        await _repository.SaveAsync(user);
        await _emailService.SendWelcomeEmailAsync(user.Email);
    }
}
```

### Principle 4: Separation of Concerns (SoC)

**Rule:** Different concerns belong in different layers.

**Layer Responsibilities:**
- **Controllers/API**: HTTP concerns, routing, model binding
- **Services**: Business logic, orchestration
- **Repositories**: Data access, queries
- **Domain/Core**: Business rules, entities, interfaces

#### ❌ BAD - Mixed concerns
```csharp
[ApiController]
public class UsersController : ControllerBase
{
    [HttpPost]
    public IActionResult CreateUser([FromBody] CreateUserRequest request)
    {
        // Validation in controller - should be in service
        if (string.IsNullOrEmpty(request.Email)) return BadRequest();

        // Business logic in controller - should be in service
        var user = new User
        {
            Email = request.Email,
            PasswordHash = BCrypt.HashPassword(request.Password)
        };

        // Data access in controller - should be in repository
        using var db = new AppDbContext();
        db.Users.Add(user);
        db.SaveChanges();

        return Ok(user);
    }
}
```

#### ✅ GOOD - Clear separation
```csharp
// Controller - HTTP concerns only
[ApiController]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    [HttpPost]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request)
    {
        var user = await _userService.RegisterUserAsync(request);
        return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
    }
}

// Service - Business logic
public class UserService : IUserService
{
    private readonly IUserRepository _repository;
    private readonly IPasswordHasher _passwordHasher;

    public async Task<User> RegisterUserAsync(CreateUserRequest request)
    {
        var user = new User
        {
            Email = request.Email,
            PasswordHash = _passwordHasher.Hash(request.Password)
        };

        return await _repository.CreateAsync(user);
    }
}

// Repository - Data access
public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;

    public async Task<User> CreateAsync(User user)
    {
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }
}
```

### Principle 5: Open/Closed Principle (OCP)

**Rule:** Open for extension, closed for modification.

**Application:**
- Use interfaces for extension points
- Use abstract classes for shared behavior
- Avoid modifying existing code - extend it instead

#### ❌ BAD - Requires modification to extend
```csharp
public class ReportGenerator
{
    public string Generate(string type, List<Order> orders)
    {
        if (type == "PDF")
        {
            // PDF generation logic
            return GeneratePdf(orders);
        }
        else if (type == "Excel")
        {
            // Excel generation logic
            return GenerateExcel(orders);
        }
        // Adding CSV requires modifying this method!
        else
        {
            throw new NotSupportedException();
        }
    }
}
```

#### ✅ GOOD - Open for extension
```csharp
public interface IReportGenerator
{
    string Generate(List<Order> orders);
}

public class PdfReportGenerator : IReportGenerator
{
    public string Generate(List<Order> orders)
    {
        // PDF-specific logic
    }
}

public class ExcelReportGenerator : IReportGenerator
{
    public string Generate(List<Order> orders)
    {
        // Excel-specific logic
    }
}

// Adding CSV requires NO modification - just a new class
public class CsvReportGenerator : IReportGenerator
{
    public string Generate(List<Order> orders)
    {
        // CSV-specific logic
    }
}

public class ReportService
{
    private readonly Dictionary<string, IReportGenerator> _generators;

    public ReportService(IEnumerable<IReportGenerator> generators)
    {
        // DI container injects all implementations automatically
        _generators = generators.ToDictionary(g => g.GetType().Name);
    }
}
```

---

## 🎨 Code Quality Standards

### Naming Conventions

**Classes:** PascalCase, noun or noun phrase
```csharp
public class UserService { }
public class OrderRepository { }
public class PaymentProcessor { }
```

**Methods:** PascalCase, verb or verb phrase
```csharp
public User GetUser(int id) { }
public async Task<bool> ValidateOrderAsync(Order order) { }
public void ProcessPayment(Payment payment) { }
```

**Private fields:** _camelCase with underscore prefix
```csharp
private readonly IUserRepository _userRepository;
private readonly ILogger<UserService> _logger;
private string _cachedToken;
```

**Parameters/Local variables:** camelCase
```csharp
public void UpdateUser(int userId, string emailAddress)
{
    var existingUser = _repository.GetById(userId);
    var isValid = ValidateEmail(emailAddress);
}
```

**Constants:** PascalCase or UPPER_SNAKE_CASE for magic values
```csharp
private const int MaxRetryAttempts = 3;
private const string DEFAULT_CULTURE = "en-US";
```

**Interfaces:** PascalCase with "I" prefix
```csharp
public interface IUserService { }
public interface IPaymentGateway { }
```

### Method Size Guidelines

**Maximum:** 20 lines of code (excluding braces, comments)
**Ideal:** 5-10 lines of code
**Rationale:** If a method is longer, it's doing too much

#### ❌ BAD - Method too long
```csharp
public async Task<Order> ProcessOrderAsync(CreateOrderRequest request)
{
    // Validation (lines 1-5)
    if (request == null) throw new ArgumentNullException();
    if (request.Items.Count == 0) throw new InvalidOperationException();
    // ... more validation

    // Calculation (lines 6-12)
    var subtotal = 0m;
    foreach (var item in request.Items)
    {
        var price = _productService.GetPrice(item.ProductId);
        subtotal += price * item.Quantity;
    }
    var tax = subtotal * 0.21m;
    var total = subtotal + tax;

    // Discount logic (lines 13-20)
    if (request.CouponCode != null)
    {
        var discount = _couponService.GetDiscount(request.CouponCode);
        if (discount.IsValid)
        {
            total -= discount.Amount;
        }
    }

    // Payment processing (lines 21-28)
    var payment = new Payment { Amount = total, Method = request.PaymentMethod };
    var paymentResult = await _paymentGateway.ProcessAsync(payment);
    if (!paymentResult.Success)
    {
        throw new PaymentFailedException();
    }

    // Email notification (lines 29-32)
    var email = new OrderConfirmationEmail { To = request.Email, OrderId = order.Id };
    await _emailService.SendAsync(email);

    // Save to database (lines 33-35)
    var order = new Order { /* mapping logic */ };
    await _repository.SaveAsync(order);
    return order;
}
```

#### ✅ GOOD - Extracted to focused methods
```csharp
public async Task<Order> ProcessOrderAsync(CreateOrderRequest request)
{
    ValidateRequest(request);

    var pricing = CalculatePricing(request);
    await ProcessPaymentAsync(pricing.Total, request.PaymentMethod);

    var order = await CreateOrderAsync(request, pricing);
    await SendOrderConfirmationAsync(order, request.Email);

    return order;
}

private void ValidateRequest(CreateOrderRequest request)
{
    if (request == null) throw new ArgumentNullException(nameof(request));
    if (request.Items.Count == 0) throw new InvalidOperationException("Order must contain items");
}

private OrderPricing CalculatePricing(CreateOrderRequest request)
{
    var subtotal = CalculateSubtotal(request.Items);
    var discount = ApplyDiscount(subtotal, request.CouponCode);
    var tax = CalculateTax(subtotal - discount);

    return new OrderPricing(subtotal, discount, tax);
}

private async Task ProcessPaymentAsync(decimal amount, string paymentMethod)
{
    var payment = new Payment { Amount = amount, Method = paymentMethod };
    var result = await _paymentGateway.ProcessAsync(payment);

    if (!result.Success)
        throw new PaymentFailedException(result.ErrorMessage);
}

private async Task<Order> CreateOrderAsync(CreateOrderRequest request, OrderPricing pricing)
{
    var order = _mapper.Map<Order>(request);
    order.Total = pricing.Total;

    return await _repository.SaveAsync(order);
}

private async Task SendOrderConfirmationAsync(Order order, string email)
{
    var confirmation = new OrderConfirmationEmail { To = email, OrderId = order.Id };
    await _emailService.SendAsync(confirmation);
}
```

### Class Size Guidelines

**Maximum:** 300 lines
**Ideal:** 100-200 lines
**Action:** If a class exceeds 300 lines, split into multiple classes

### Cyclomatic Complexity

**Maximum:** 10 per method
**Ideal:** 1-4 per method
**Measurement:** Count decision points (if, while, for, case, &&, ||, ?)

---

## 🧹 Cleanup Cycle (Mandatory)

Every code change must include a cleanup cycle:

### 1. Pre-Change Scan (1-2 minutes)
- Read the entire file
- Identify obvious issues
- Plan small improvements

### 2. During Change (continuous)
- Fix issues as you encounter them
- Maintain consistency with existing patterns
- Extract duplicated code

### 3. Post-Change Review (2-3 minutes)
- Review the entire modified file
- Check Boy Scout checklist
- Verify architectural alignment
- Ensure all cleanup is complete

### 4. Commit Strategy
**Option A - Single commit:**
```
feat: Add user authentication endpoint

- Implement JWT token generation
- Add login/logout controllers
- Cleanup: Remove unused imports, fix naming consistency, add XML docs
```

**Option B - Separate commits (preferred for large cleanups):**
```
Commit 1: refactor: Cleanup UserService before adding authentication
Commit 2: feat: Add user authentication endpoint
```

---

## 📐 Architectural Decision Rules

When faced with multiple valid approaches, choose based on this priority:

### Priority 1: Understandability
**Question:** "Will a junior developer understand this in 6 months?"
- If NO → Choose simpler approach
- If YES → Proceed to Priority 2

### Priority 2: Maintainability
**Question:** "How easy is it to modify this when requirements change?"
- If HARD → Reconsider design
- If EASY → Proceed to Priority 3

### Priority 3: Testability
**Question:** "Can I unit test this without mocking half the framework?"
- If NO → Refactor for testability
- If YES → Proceed to Priority 4

### Priority 4: Performance
**Question:** "Is this a performance bottleneck?"
- If NO → Choose readable approach
- If YES → Optimize with comments explaining why

### Example Decision Tree

**Scenario:** Should I use LINQ `.Where().Select()` or a `foreach` loop?

**Priority 1 - Understandability:**
- LINQ: High readability for developers familiar with functional programming
- foreach: High readability for all developers
- **Winner:** Depends on team experience, default to LINQ for simple cases

**Priority 2 - Maintainability:**
- LINQ: Easier to modify query logic
- foreach: Easier to add complex logic inside loop
- **Winner:** LINQ for data transformations, foreach for complex operations

**Priority 3 - Testability:**
- LINQ: Easier to extract to separate method
- foreach: Requires more setup
- **Winner:** LINQ

**Priority 4 - Performance:**
- LINQ: Slight overhead, lazy evaluation
- foreach: Direct iteration, no overhead
- **Winner:** foreach if processing millions of items, otherwise LINQ

**Final Decision:** Use LINQ for readability unless:
- Complex logic inside loop (use foreach)
- Performance-critical code (use foreach with profiler evidence)
- Team unfamiliar with LINQ (use foreach)

---

## 🚫 Anti-Patterns to Avoid

### 1. God Objects
**Problem:** Classes that do everything
**Fix:** Split into focused classes following SRP

### 2. Magic Numbers
**Problem:** Unexplained constants scattered in code
**Fix:** Extract to named constants

#### ❌ BAD
```csharp
if (user.Age < 18) { /* ... */ }
var timeout = 30000; // What unit? Why 30000?
```

#### ✅ GOOD
```csharp
private const int MinimumAge = 18;
private const int HttpTimeoutMilliseconds = 30000; // 30 seconds for API calls

if (user.Age < MinimumAge) { /* ... */ }
var timeout = HttpTimeoutMilliseconds;
```

### 3. Shotgun Surgery
**Problem:** Single change requires modifying many files
**Fix:** Improve cohesion, reduce coupling

### 4. Copy-Paste Programming
**Problem:** Duplicated code everywhere
**Fix:** Extract to shared methods/classes

### 5. Leaky Abstractions
**Problem:** Implementation details bleeding through interfaces
**Fix:** Design proper abstractions

#### ❌ BAD - SqlException leaks from repository
```csharp
public interface IUserRepository
{
    User GetUser(int id); // Throws SqlException - leaky!
}
```

#### ✅ GOOD - Domain exception
```csharp
public interface IUserRepository
{
    User GetUser(int id); // Throws UserNotFoundException - domain exception
}

public class UserRepository : IUserRepository
{
    public User GetUser(int id)
    {
        try
        {
            return _context.Users.Find(id);
        }
        catch (SqlException ex)
        {
            throw new RepositoryException("Failed to retrieve user", ex);
        }
    }
}
```

---

## 📊 Metrics and Enforcement

### Code Review Checklist
Every PR must verify:
- ☐ Boy Scout Rule applied (file is better than before)
- ☐ Methods under 20 lines
- ☐ Classes under 300 lines
- ☐ Single Responsibility Principle followed
- ☐ Dependencies injected, not newed up
- ☐ Separation of Concerns maintained
- ☐ XML documentation for public members
- ☐ Consistent naming conventions
- ☐ No magic numbers
- ☐ No commented-out code
- ☐ No TODO comments (convert to issues)

### Automated Checks
Use these tools:
- **Roslyn Analyzers** - Enforce C# best practices
- **SonarQube** - Code quality and security
- **StyleCop** - Consistent formatting
- **Code Metrics** - Cyclomatic complexity, maintainability index

---

## 🎓 Learning Resources

### Books
- *Clean Code* by Robert C. Martin
- *The Pragmatic Programmer* by Hunt & Thomas
- *Domain-Driven Design* by Eric Evans
- *Refactoring* by Martin Fowler

### Principles
- SOLID (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion)
- DRY (Don't Repeat Yourself)
- KISS (Keep It Simple, Stupid)
- YAGNI (You Aren't Gonna Need It)

---

## ✅ Success Criteria

**You are following these principles correctly when:**

1. ✅ Every file you touch is cleaner than when you started
2. ✅ A new developer can understand your code without explanation
3. ✅ Changes are localized to single classes/methods
4. ✅ Unit tests are easy to write
5. ✅ Code reviews have minimal feedback on structure
6. ✅ Bug fixes don't introduce new bugs
7. ✅ Adding features doesn't require rewriting existing code

**You are NOT following these principles when:**

1. ❌ You're explaining complex code in code reviews
2. ❌ You're copying and pasting code
3. ❌ You're saying "I'll clean this up later"
4. ❌ You're writing methods over 20 lines
5. ❌ You're using `new` for dependencies
6. ❌ You're mixing business logic with data access
7. ❌ You're leaving TODOs and commented code

---

## 🔄 Continuous Improvement

**This document is living documentation.**

- Update when discovering new patterns
- Add examples from actual code reviews
- Refine based on team feedback
- Review quarterly for relevance

**Last Review:** 2026-01-17
**Next Review:** 2026-04-17

---

**Remember:** The goal is not perfection. The goal is continuous improvement.

**Apply the Boy Scout Rule:** Leave every file better than you found it.

---

## 📚 See Also

**Related development guidelines:**
- **Definition of Done:** `C:\scripts\_machine\DEFINITION_OF_DONE.md` - Complete task completion checklist
- **Continuous Improvement:** `C:\scripts\continuous-improvement.md` - Self-learning protocols
- **Best Practices Library:** `C:\scripts\_machine\best-practices\` - Pattern library

**Project-specific architecture:**
- **client-manager Architecture:** `C:\scripts\_machine\knowledge-base\05-PROJECTS\client-manager\architecture.md`
- **Hazina Framework Patterns:** `C:\scripts\_machine\knowledge-base\05-PROJECTS\hazina\framework-patterns.md`

**Code quality tools:**
- **C# Auto-fix:** `C:\scripts\tools\cs-format.ps1`, `cs-autofix\`
- **Code Analysis:** `C:\scripts\tools\auto-code-review.ps1`
- **Code Metrics:** `C:\scripts\tools\generate-code-metrics.ps1`
