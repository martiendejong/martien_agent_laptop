# ADR-008: JWT Authentication Strategy

**Status:** Accepted
**Date:** 2024-06-01
**Decision Makers:** Backend Team, Security Lead

## Context

We needed an authentication mechanism for Brand2Boost that:
- Works across API and frontend
- Supports both email/password and OAuth (Google)
- Scales for multi-tenant SaaS
- Stateless (no session server required)
- Secure and industry-standard

## Decision

**Use JWT (JSON Web Tokens)** with the following architecture:

**Flow:**
1. User logs in (email/password or Google OAuth)
2. API generates JWT containing user claims
3. Frontend stores JWT in localStorage
4. Frontend sends JWT in Authorization header for every API request
5. API validates JWT signature and extracts claims
6. No session storage required

**Token Structure:**
```json
{
  "sub": "user-id",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "Pro",
  "exp": 1704067200,
  "iat": 1704063600
}
```

**Signing:** HMAC-SHA256 with secret key from appsettings.Secrets.json

## Consequences

### Positive
✅ **Stateless**
- No session storage needed
- API can scale horizontally (no sticky sessions)
- Works across multiple API instances

✅ **Cross-Platform**
- Standard format (RFC 7519)
- Works in React, mobile apps, Postman
- Easy to integrate with third-party tools

✅ **Contains User Claims**
- Avoid database lookup on every request
- User ID, email, role embedded in token
- Fast authorization checks

✅ **OAuth Integration**
- Works seamlessly with Google OAuth
- External provider validates user, we issue JWT
- Consistent auth regardless of provider

✅ **Secure**
- Signed with secret key (HMAC) or private key (RS256)
- Tamper-proof
- Industry-standard security

### Negative
❌ **Token Revocation is Hard**
- Can't revoke a valid JWT before expiration
- If user logs out, token still valid until expiry
- Workaround: Short expiration (1 hour) + refresh tokens

❌ **Payload Size**
- JWT is larger than session ID (200-500 bytes vs 32 bytes)
- Sent with every request (bandwidth overhead)
- But: Acceptable for HTTP/2

❌ **Secrets Management**
- Must protect signing key carefully
- If key leaks, all JWTs can be forged
- Rotation is complex

### Neutral
⚪ **Expiration Management**
- Tokens expire (default: 1 hour)
- Need refresh token flow (future)
- Users might get logged out unexpectedly

⚪ **Storage Location**
- localStorage is common but has XSS risk
- Could use httpOnly cookies (more secure)
- Current choice: localStorage for simplicity

## Alternatives Considered

### Option A: Session-Based Authentication
**How it works:**
- Server creates session on login
- Session ID stored in cookie
- Server looks up session in Redis/database

**Pros:**
- Easy to revoke (just delete session)
- Smaller cookie (32-byte session ID)
- More control over sessions

**Cons:**
- Requires session storage (Redis or DB)
- Sticky sessions or shared session store
- Doesn't scale as easily
- More complex infrastructure

**Why rejected:** Statelessness is more important for horizontal scaling.

### Option B: OAuth Only (No Backend JWT)
**How it works:**
- Use Google OAuth tokens directly
- No custom JWTs

**Pros:**
- Simpler (one less token type)
- Google handles security

**Cons:**
- Tied to Google (what about email/password users?)
- Google tokens are large
- Can't customize claims
- Requires Google API call to validate

**Why rejected:** Need to support email/password too. Want control over claims.

### Option C: API Keys
**How it works:**
- Generate API key on login
- Send API key with every request

**Pros:**
- Very simple
- Easy to revoke
- Long-lived

**Cons:**
- No expiration (security risk)
- Can't embed user claims
- Less secure than JWTs

**Why rejected:** API keys are for machine-to-machine, not user authentication.

### Option D: Opaque Tokens
**How it works:**
- Generate random token on login
- Store token → user mapping in database
- Look up user on every request

**Pros:**
- Easy to revoke
- Smaller tokens

**Cons:**
- Database lookup on every request (slow)
- Not stateless
- Doesn't scale well

**Why rejected:** Performance and scalability concerns.

## Implementation Details

### Token Generation (TokenService.cs)

```csharp
public string GenerateJwtToken(ApplicationUser user)
{
    var claims = new List<Claim>
    {
        new Claim(JwtRegisteredClaimNames.Sub, user.Id),
        new Claim(JwtRegisteredClaimNames.Email, user.Email),
        new Claim(JwtRegisteredClaimNames.Name, user.FullName),
        new Claim("role", user.Subscription?.Tier ?? "Free")
    };

    var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSecret));
    var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

    var token = new JwtSecurityToken(
        issuer: "Brand2Boost",
        audience: "Brand2Boost-Frontend",
        claims: claims,
        expires: DateTime.UtcNow.AddHours(1),
        signingCredentials: creds
    );

    return new JwtSecurityTokenHandler().WriteToken(token);
}
```

### Token Validation (Program.cs)

```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = "Brand2Boost",
            ValidAudience = "Brand2Boost-Frontend",
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtSecret))
        };
    });
```

### Frontend Usage (React)

```typescript
// Store token after login
localStorage.setItem('jwt', response.token);

// Send with every request
const api = axios.create({
  headers: {
    Authorization: `Bearer ${localStorage.getItem('jwt')}`
  }
});
```

## Security Considerations

**Secret Key Management:**
- Stored in `appsettings.Secrets.json` (local dev)
- Stored in Azure Key Vault (production)
- Never committed to Git
- Rotated every 6 months

**Token Expiration:**
- Access token: 1 hour
- Refresh token: 7 days (future)
- Force re-login after 7 days for security

**HTTPS Only:**
- Tokens only sent over HTTPS
- Prevent token interception

**XSS Protection:**
- Sanitize all user input
- Content Security Policy headers
- Consider httpOnly cookies in future

## Future Enhancements

### Refresh Tokens (Planned)
- Add refresh token alongside access token
- Access token: 1 hour expiration
- Refresh token: 7 days, stored in httpOnly cookie
- Endpoint: `POST /api/auth/refresh`

### Token Revocation (Planned)
- Maintain revocation list in Redis
- Check on every request if token is revoked
- TTL = token expiration time

### RS256 Signing (Considered)
- Use asymmetric keys (public/private)
- More secure than HMAC
- Allows public key distribution
- But: More complex key management

## References

- JWT RFC 7519: https://tools.ietf.org/html/rfc7519
- ASP.NET Core Authentication: https://docs.microsoft.com/en-us/aspnet/core/security/authentication/
- OWASP JWT Cheatsheet: https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html

---

**Review Date:** 2026-06-01
**Related ADRs:**
- ADR-011: Security Checklist
- ADR-015: Secrets Management
