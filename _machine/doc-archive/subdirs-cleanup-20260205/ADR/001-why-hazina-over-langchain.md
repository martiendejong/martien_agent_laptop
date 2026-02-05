# ADR-001: Why Hazina Framework Over LangChain

**Status:** Accepted
**Date:** 2024-06-15
**Decision Makers:** Development Team, Product Owner

## Context

We needed a framework for LLM integration in Brand2Boost. Two major options existed:

1. **LangChain** - Popular Python/TypeScript framework for LLM apps
2. **Hazina** - Custom C# framework (formerly DevGPT)

**Requirements:**
- Multi-provider support (OpenAI, Anthropic, Azure, local models)
- RAG capabilities with vector search
- C# integration with existing .NET stack
- Full control over prompt management
- Token accounting and cost tracking
- Multi-tenant isolation

## Decision

**We chose Hazina Framework** and invested in building it as a separate 108-project ecosystem.

**Key reasons:**
1. Native C# integration with ASP.NET Core
2. Full control over all LLM abstractions
3. Custom prompt management system
4. Built-in token accounting
5. Multi-tenant isolation at framework level
6. No Python interop overhead

## Consequences

### Positive
✅ **Native C# Integration**
- No language barriers, works seamlessly with .NET
- Strong typing with C# generics
- Full async/await support

✅ **Full Control**
- We own the abstraction layer
- Can optimize for our specific use cases
- No dependency on external framework changes

✅ **Performance**
- No Python interop overhead
- Native .NET performance
- Efficient memory management

✅ **Multi-Provider Support**
- Easily swap between OpenAI, Anthropic, Azure OpenAI
- Fallback strategies built-in
- Cost optimization through provider selection

✅ **Token Economics**
- Precise token counting
- Per-user token tracking
- Cost attribution to tenants

### Negative
❌ **Maintenance Burden**
- We must maintain 108 projects ourselves
- Keep up with LLM provider API changes
- More code to test and debug

❌ **Missing Community Features**
- LangChain has larger ecosystem
- Community-contributed chains and agents
- More examples and tutorials

❌ **Slower Feature Parity**
- LangChain gets new features faster
- We must implement features ourselves
- Smaller team vs large OSS community

### Neutral
⚪ **Learning Curve**
- Team must learn Hazina instead of LangChain
- Custom documentation required
- But: C# developers already know the patterns

⚪ **Vendor Lock-in**
- Locked into our own framework
- But: We control the migration path
- Can always extract to LangChain later if needed

## Alternatives Considered

### Option A: LangChain (Python)
**Pros:**
- Mature ecosystem with many features
- Large community support
- Well-documented
- Regular updates

**Cons:**
- Requires Python runtime alongside .NET
- Interop overhead (HTTP API or gRPC)
- Additional deployment complexity
- Language mismatch with team expertise

**Why rejected:** Team is C# experts, not Python. Interop adds complexity and latency.

### Option B: LangChain4j (Java)
**Pros:**
- JVM is similar to CLR
- Better than Python interop
- Some C# devs know Java

**Cons:**
- Still a separate runtime
- Team prefers C# over Java
- Less mature than Python version

**Why rejected:** If we're going cross-runtime, might as well use Python version.

### Option C: Semantic Kernel (Microsoft)
**Pros:**
- Official Microsoft C# LLM framework
- Native .NET integration
- Well-supported

**Cons:**
- Less mature than LangChain at decision time (2024-06)
- Opinionated architecture
- Less flexible for multi-provider

**Why rejected:** Hazina gives us more control. Semantic Kernel could be revisited in future.

### Option D: Build Minimal Abstraction (No Framework)
**Pros:**
- Simplest approach
- Only implement what we need
- No framework overhead

**Cons:**
- Reinvent wheel for RAG, agents, chains
- Miss out on patterns and best practices
- Hard to scale complexity

**Why rejected:** We knew we'd need RAG, agents, multiple providers. Framework was justified.

## Migration Path

If we need to migrate away from Hazina:

1. **To Semantic Kernel:**
   - Both are C#, migration is straightforward
   - Implement adapter layer
   - Gradual migration possible

2. **To LangChain:**
   - Bigger lift, requires Python runtime
   - Could use LangChain as external service
   - HTTP API bridge

## References

- Hazina Deep Dive: `C:\scripts\_machine\HAZINA_DEEP_DIVE.md`
- LangChain: https://python.langchain.com/
- Semantic Kernel: https://github.com/microsoft/semantic-kernel
- Decision discussion: Internal team meeting 2024-06-10

---

**Review Date:** 2026-06-01 (Re-evaluate after 2 years)
**Related ADRs:**
- ADR-013: Multi-Provider LLM Strategy
- ADR-015: RAG Architecture with pgvector
