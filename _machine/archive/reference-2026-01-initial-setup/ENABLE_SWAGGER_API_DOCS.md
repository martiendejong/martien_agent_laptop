# Enable Swagger/OpenAPI Documentation 📖

**Goal:** Enable auto-generated interactive API documentation at `/swagger` endpoint

**Effort:** 1 hour (if not already enabled)
**Impact:** High (API discoverability, easier integration, developer experience)

---

## Quick Check: Is Swagger Already Enabled?

**Test:**
1. Run the API: `dotnet run` (in ClientManagerAPI folder)
2. Visit: https://localhost:54501/swagger
3. **If you see Swagger UI** → Already done! ✅
4. **If you see 404** → Follow steps below

---

## Step 1: Install Swashbuckle (if not installed)

**Check if already installed:**
```bash
cd ClientManagerAPI
dotnet list package | findstr Swashbuckle
```

**If not found, install:**
```bash
dotnet add package Swashbuckle.AspNetCore
```

---

## Step 2: Enable Swagger in Program.cs

**File:** `ClientManagerAPI/Program.cs`

**Find the service registration section and add:**
```csharp
// Add services to the container
builder.Services.AddControllers();

// Add Swagger/OpenAPI support
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Brand2Boost API",
        Version = "v1",
        Description = "AI-Powered Brand Development & Promotion Platform API",
        Contact = new OpenApiContact
        {
            Name = "Brand2Boost Team",
            Email = "support@brand2boost.com",
            Url = new Uri("https://brand2boost.com")
        },
        License = new OpenApiLicense
        {
            Name = "Proprietary",
            Url = new Uri("https://brand2boost.com/license")
        }
    });

    // Include XML comments for better documentation
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        options.IncludeXmlComments(xmlPath);
    }

    // Add JWT authentication to Swagger
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token.",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});
```

**Find the middleware pipeline section and add:**
```csharp
var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment() || app.Environment.IsStaging())
{
    // Enable Swagger in dev and staging only
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Brand2Boost API v1");
        options.RoutePrefix = "swagger"; // Access at /swagger
        options.DocumentTitle = "Brand2Boost API Documentation";

        // Optional: Dark theme
        options.DefaultModelsExpandDepth(-1); // Hide models by default
        options.DocExpansion(DocExpansion.None); // Collapse all endpoints
        options.EnableDeepLinking();
        options.DisplayRequestDuration();
    });
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
```

---

## Step 3: Enable XML Documentation

**File:** `ClientManagerAPI/ClientManagerAPI.csproj` (or `ClientManagerAPI.local.csproj`)

**Add to `<PropertyGroup>`:**
```xml
<PropertyGroup>
  <TargetFramework>net9.0</TargetFramework>
  <Nullable>enable</Nullable>
  <ImplicitUsings>enable</ImplicitUsings>

  <!-- Generate XML documentation -->
  <GenerateDocumentationFile>true</GenerateDocumentationFile>
  <NoWarn>$(NoWarn);1591</NoWarn> <!-- Suppress missing XML comment warnings -->
</PropertyGroup>
```

---

## Step 4: Add XML Comments to Controllers

**Example:** `Controllers/AuthController.cs`

**Before:**
```csharp
[HttpPost("login")]
public async Task<IActionResult> Login([FromBody] LoginRequest request)
{
    // ...
}
```

**After:**
```csharp
/// <summary>
/// Authenticates a user and returns a JWT token
/// </summary>
/// <param name="request">Login credentials (email and password)</param>
/// <returns>JWT token and user information</returns>
/// <response code="200">Login successful, returns JWT token</response>
/// <response code="401">Invalid credentials</response>
[HttpPost("login")]
[ProducesResponseType(typeof(LoginResponse), StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status401Unauthorized)]
public async Task<IActionResult> Login([FromBody] LoginRequest request)
{
    // ...
}
```

**More examples:**
```csharp
/// <summary>
/// Registers a new user account
/// </summary>
/// <param name="request">Registration data (email, password, name)</param>
/// <returns>Created user and JWT token</returns>
/// <response code="201">User created successfully</response>
/// <response code="400">Validation error (email taken, weak password, etc.)</response>
[HttpPost("register")]
[ProducesResponseType(typeof(RegisterResponse), StatusCodes.Status201Created)]
[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
public async Task<IActionResult> Register([FromBody] RegisterRequest request)
{
    // ...
}

/// <summary>
/// Gets the current user's profile
/// </summary>
/// <returns>User profile information</returns>
/// <response code="200">Profile retrieved successfully</response>
/// <response code="401">Not authenticated</response>
[HttpGet("profile")]
[Authorize]
[ProducesResponseType(typeof(UserProfile), StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status401Unauthorized)]
public async Task<IActionResult> GetProfile()
{
    // ...
}
```

---

## Step 5: Add XML Comments to DTOs

**Example:** `Models/LoginRequest.cs`

```csharp
/// <summary>
/// Login request model
/// </summary>
public class LoginRequest
{
    /// <summary>
    /// User's email address
    /// </summary>
    /// <example>user@example.com</example>
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// User's password
    /// </summary>
    /// <example>P@ssw0rd123</example>
    [Required]
    [MinLength(8)]
    public string Password { get; set; } = string.Empty;
}

/// <summary>
/// Login response model
/// </summary>
public class LoginResponse
{
    /// <summary>
    /// JWT access token
    /// </summary>
    public string Token { get; set; } = string.Empty;

    /// <summary>
    /// Token expiration time (Unix timestamp)
    /// </summary>
    public long ExpiresAt { get; set; }

    /// <summary>
    /// User information
    /// </summary>
    public UserDto User { get; set; } = null!;
}
```

---

## Step 6: Test Swagger

**Run the API:**
```bash
cd ClientManagerAPI
dotnet run
```

**Open in browser:**
- **Swagger UI:** https://localhost:54501/swagger
- **OpenAPI JSON:** https://localhost:54501/swagger/v1/swagger.json

**You should see:**
- List of all API endpoints grouped by controller
- Request/response schemas
- Try it out functionality
- Authentication support (Authorize button)

---

## Step 7: Test Authentication in Swagger

**Steps:**
1. Click "Authorize" button (top right)
2. Get a JWT token:
   - Expand `POST /api/auth/login`
   - Click "Try it out"
   - Enter test credentials:
     ```json
     {
       "email": "test@example.com",
       "password": "Test123!"
     }
     ```
   - Click "Execute"
   - Copy the `token` from response

3. Paste token in Authorization dialog:
   ```
   Bearer <your-token-here>
   ```

4. Click "Authorize"
5. Now you can test authenticated endpoints!

---

## Step 8: Group Endpoints by Tags

**Add tags to controllers:**

```csharp
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
[Tags("Authentication")] // This groups endpoints in Swagger
public class AuthController : ControllerBase
{
    // ...
}

[ApiController]
[Route("api/[controller]")]
[Tags("Chat")] // Group chat endpoints
public class ChatController : ControllerBase
{
    // ...
}

[ApiController]
[Route("api/[controller]")]
[Tags("Content Management")] // Group content endpoints
public class ContentController : ControllerBase
{
    // ...
}
```

**Result:** Endpoints grouped logically in Swagger UI

---

## Step 9: Add Example Responses

**Method 1: Using attributes**
```csharp
/// <summary>
/// Creates a new brand
/// </summary>
[HttpPost]
[ProducesResponseType(typeof(Brand), StatusCodes.Status201Created)]
[ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
public async Task<IActionResult> CreateBrand([FromBody] CreateBrandRequest request)
{
    // ...
}
```

**Method 2: Using Swashbuckle filters**
```csharp
// In Program.cs, inside AddSwaggerGen():
options.EnableAnnotations(); // Enable Swagger annotations

// Then in controllers:
[HttpPost]
[SwaggerOperation(Summary = "Create brand", Description = "Creates a new brand for the authenticated user")]
[SwaggerResponse(201, "Brand created successfully", typeof(Brand))]
[SwaggerResponse(400, "Validation error", typeof(ValidationProblemDetails))]
public async Task<IActionResult> CreateBrand([FromBody] CreateBrandRequest request)
{
    // ...
}
```

---

## Step 10: Customize Swagger UI

**Advanced customization in Program.cs:**

```csharp
app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "Brand2Boost API v1");
    options.RoutePrefix = "swagger";

    // Appearance
    options.DocumentTitle = "Brand2Boost API - Interactive Documentation";
    options.DefaultModelsExpandDepth(-1); // Hide schemas section
    options.DocExpansion(DocExpansion.List); // Expand tags, collapse operations
    options.EnableDeepLinking(); // Enable deep linking
    options.DisplayRequestDuration(); // Show request duration
    options.EnableFilter(); // Enable search/filter
    options.ShowExtensions(); // Show vendor extensions
    options.EnableValidator(); // Validate requests

    // Custom CSS (optional)
    options.InjectStylesheet("/swagger-ui/custom.css");

    // OAuth configuration (if using OAuth)
    // options.OAuthClientId("brand2boost-swagger");
    // options.OAuthAppName("Brand2Boost API");
});
```

---

## Step 11: Version Your API

**Multiple API versions:**

**Install package:**
```bash
dotnet add package Microsoft.AspNetCore.Mvc.Versioning
dotnet add package Microsoft.AspNetCore.Mvc.Versioning.ApiExplorer
```

**Configure in Program.cs:**
```csharp
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
});

builder.Services.AddVersionedApiExplorer(options =>
{
    options.GroupNameFormat = "'v'VVV";
    options.SubstituteApiVersionInUrl = true;
});

builder.Services.AddSwaggerGen(options =>
{
    // Multiple Swagger docs for each version
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "Brand2Boost API", Version = "v1" });
    options.SwaggerDoc("v2", new OpenApiInfo { Title = "Brand2Boost API", Version = "v2" });
});

app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "Brand2Boost API v1");
    options.SwaggerEndpoint("/swagger/v2/swagger.json", "Brand2Boost API v2");
});
```

**Use in controllers:**
```csharp
[ApiController]
[Route("api/v{version:apiVersion}/[controller]")]
[ApiVersion("1.0")]
public class AuthController : ControllerBase
{
    // v1 endpoints
}

[ApiController]
[Route("api/v{version:apiVersion}/[controller]")]
[ApiVersion("2.0")]
public class AuthV2Controller : ControllerBase
{
    // v2 endpoints
}
```

---

## Step 12: Export OpenAPI Spec

**Generate OpenAPI JSON file:**

**Method 1: Manual (while app running)**
1. Run API
2. Visit https://localhost:54501/swagger/v1/swagger.json
3. Save JSON to file

**Method 2: CLI tool**
```bash
dotnet tool install -g Swashbuckle.AspNetCore.Cli
dotnet swagger tofile --output swagger.json bin/Debug/net9.0/ClientManagerAPI.dll v1
```

**Use cases:**
- Import into Postman/Insomnia
- Generate client SDKs (using openapi-generator)
- Share with frontend team
- API contract testing

---

## Best Practices

**DO:**
- ✅ Document all public endpoints
- ✅ Use XML comments for descriptions
- ✅ Include example values
- ✅ Document error responses
- ✅ Group endpoints with tags
- ✅ Enable authentication in Swagger UI
- ✅ Only expose in dev/staging (not production)

**DON'T:**
- ❌ Expose internal/admin endpoints publicly
- ❌ Include sensitive data in examples
- ❌ Forget to update docs when API changes
- ❌ Enable Swagger in production (security risk)

---

## Troubleshooting

**Problem: Swagger UI not showing**
```bash
# Check if package installed
dotnet list package | findstr Swashbuckle

# Check Program.cs has UseSwagger() and UseSwaggerUI()
# Make sure you're in Development environment
```

**Problem: XML comments not showing**
```bash
# Check .csproj has <GenerateDocumentationFile>true</GenerateDocumentationFile>
# Rebuild project
dotnet build
```

**Problem: Authentication not working in Swagger**
```bash
# Make sure JWT is configured correctly in Program.cs
# Check AddSecurityDefinition and AddSecurityRequirement
# Test token in Postman first
```

**Problem: 404 at /swagger**
```bash
# Check RoutePrefix in UseSwaggerUI
# Try /swagger/index.html instead
# Check app.Environment.IsDevelopment() condition
```

---

## Alternative: NSwag (Instead of Swashbuckle)

**NSwag advantages:**
- Client code generation
- TypeScript/C# client generation
- More features

**Install:**
```bash
dotnet add package NSwag.AspNetCore
```

**Configure:**
```csharp
builder.Services.AddOpenApiDocument(config =>
{
    config.DocumentName = "v1";
    config.Title = "Brand2Boost API";
    config.Version = "v1";
});

app.UseOpenApi();
app.UseSwaggerUi(); // NSwag's Swagger UI
```

---

## Next Steps

**After enabling Swagger:**
1. ✅ Document all controllers with XML comments
2. ✅ Add example requests/responses
3. ✅ Test all endpoints in Swagger UI
4. ✅ Export OpenAPI spec
5. ✅ Share with frontend team
6. ✅ Generate client SDKs (optional)
7. ✅ Set up API contract tests (optional)

---

## Related Documentation

- [CLIENT_MANAGER_DEEP_DIVE.md](./CLIENT_MANAGER_DEEP_DIVE.md) - API architecture
- [GETTING_STARTED.md](./GETTING_STARTED.md) - Setup guide
- [Official Swashbuckle docs](https://github.com/domaindrivendev/Swashbuckle.AspNetCore)

---

**Status:** ✅ Enabled
**URL:** https://localhost:54501/swagger
**Effort:** 1 hour
**Impact:** Massive (better API discoverability)

**Questions?** Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
