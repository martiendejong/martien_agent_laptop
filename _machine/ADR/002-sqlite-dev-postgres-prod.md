# ADR-002: SQLite for Development, PostgreSQL for Production

**Status:** Accepted
**Date:** 2024-05-20
**Decision Makers:** Backend Team, DevOps

## Context

We needed to choose a database strategy that balances:
- **Development velocity** - Fast local setup, no Docker required
- **Production scalability** - Handle thousands of users
- **Vector search** - Support for RAG with embeddings
- **Cost efficiency** - Minimize infrastructure costs

## Decision

**Two-database strategy:**
- **SQLite** - Local development only
- **PostgreSQL + pgvector** - Staging and production

**Entity Framework Core** handles both through provider abstraction.

## Consequences

### Positive
✅ **Fast Local Development**
- Zero setup time (SQLite is file-based)
- No Docker/PostgreSQL installation needed
- Instant migrations
- Easy to reset database (delete file)

✅ **Production Scalability**
- PostgreSQL handles concurrent users
- ACID compliance with high throughput
- Connection pooling
- Advanced indexing (B-tree, GIN, HNSW)

✅ **Vector Search with pgvector**
- Native vector operations in PostgreSQL
- HNSW and IVFFlat indexes
- Cosine similarity, L2 distance
- No separate vector database needed

✅ **Single Codebase**
- Entity Framework abstracts database differences
- Same migrations work on both (mostly)
- Same LINQ queries
- Minimal conditional code

✅ **Cost Efficiency**
- Free SQLite for dev
- PostgreSQL only in cloud (paid)
- No local infrastructure costs

### Negative
❌ **Database Drift Risk**
- SQLite and PostgreSQL have subtle differences
- Some SQL features differ (JSON, full-text search)
- Must test on PostgreSQL before deploying

❌ **Migration Complexity**
- Some migrations PostgreSQL-specific (pgvector)
- Must conditionally apply migrations
- Can't test production migrations locally

❌ **Limited Local Testing**
- Can't test PostgreSQL-specific features locally
- Vector search works differently (SQLite has no native vectors)
- Requires staging environment for full testing

### Neutral
⚪ **Development Workflow**
- Devs must remember they're on SQLite
- Integration tests should use PostgreSQL (Docker)
- Staging is mandatory before production

## Alternatives Considered

### Option A: PostgreSQL Everywhere (Docker for Local)
**Pros:**
- Identical dev/prod environments
- No database drift
- Test all features locally

**Cons:**
- Requires Docker Desktop on every dev machine
- Slower setup (pull image, start container)
- More resource usage (RAM, CPU)
- Harder for non-Docker users

**Why rejected:** Developer friction. Not everyone wants Docker running 24/7.

### Option B: SQLite Everywhere (Even Production)
**Pros:**
- Simplest setup
- Single database system
- No drift possible

**Cons:**
- SQLite doesn't scale for multi-user SaaS
- No pgvector support (RAG needs vectors)
- Limited concurrency (write lock)
- Not suitable for production

**Why rejected:** Can't handle production load or vector search.

### Option C: MySQL/MariaDB
**Pros:**
- Popular, well-known
- Good performance

**Cons:**
- No native vector support (would need separate Pinecone/Weaviate)
- Team prefers PostgreSQL
- Less advanced features than PostgreSQL

**Why rejected:** PostgreSQL + pgvector is better for RAG.

### Option D: MongoDB (NoSQL)
**Pros:**
- Flexible schema
- Built-in vector search (Atlas Vector Search)
- Horizontal scaling

**Cons:**
- Team is SQL experts, not NoSQL
- No ACID transactions (in older versions)
- EF Core support is limited
- Licensing concerns

**Why rejected:** Team expertise is SQL. Relational model fits our domain.

## Implementation Details

### Database Configuration (Program.cs)

```csharp
if (builder.Environment.IsDevelopment())
{
    // SQLite for local development
    builder.Services.AddDbContext<AppDbContext>(options =>
        options.UseSqlite($"Data Source={sqliteDbPath}"));
}
else
{
    // PostgreSQL for staging/production
    builder.Services.AddDbContext<AppDbContext>(options =>
        options.UseNpgsql(connectionString, o => o.UseVector()));
}
```

### Migration Conditional Logic

```csharp
// In EF migration:
if (migrationBuilder.ActiveProvider == "Microsoft.EntityFrameworkCore.Sqlite")
{
    // Skip pgvector extensions
}
else
{
    migrationBuilder.AlterDatabase()
        .Annotation("Npgsql:PostgresExtension:vector", ",,");
}
```

### Testing Strategy

**Unit Tests:** Use SQLite (fast, in-memory)
**Integration Tests:** Use PostgreSQL (Docker Testcontainers)
**Staging:** Always use PostgreSQL
**Production:** PostgreSQL with backups

## Vector Search Strategy

**Development (SQLite):**
- Store vectors as TEXT (JSON)
- Similarity search in-memory (slower, limited)
- Good enough for basic testing

**Production (PostgreSQL + pgvector):**
- Store vectors as `VECTOR(1536)` for OpenAI embeddings
- HNSW index for fast similarity search
- Handles millions of vectors efficiently

## Database Locations

**SQLite (Dev):**
```
C:\stores\brand2boost\identity.db
```

**PostgreSQL (Prod):**
```
Azure Database for PostgreSQL
Connection string in Key Vault
```

## Migration

If we ever need to unify on one database:

**Option 1: PostgreSQL Everywhere**
- Add Docker Compose for local PostgreSQL
- Update DEVELOPER_ONBOARDING.md
- Worth it when team grows beyond 5 devs

**Option 2: Ditch SQLite, Use PostgreSQL Cloud Free Tier**
- Use Neon.tech or Supabase free tier for dev
- Everyone gets their own cloud database
- More realistic testing

## References

- Entity Framework Core: https://docs.microsoft.com/en-us/ef/core/
- pgvector: https://github.com/pgvector/pgvector
- Database schema: `C:\scripts\_machine\DATABASE_SCHEMA.md`

---

**Review Date:** 2026-01-01 (Re-evaluate yearly)
**Related ADRs:**
- ADR-015: RAG Architecture with pgvector
- ADR-006: Entity Framework Core as ORM
