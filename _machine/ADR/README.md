# Architectural Decision Records (ADRs)

**What are ADRs?** Documentation of significant architectural decisions made during development.

**Why?** Future developers understand the "why" behind decisions, not just the "what" or "how".

---

## ADR Format

Each ADR follows this structure:

```markdown
# ADR-XXX: Title

**Status:** Accepted | Deprecated | Superseded by ADR-YYY
**Date:** YYYY-MM-DD
**Decision Makers:** [Names/Roles]

## Context

What is the issue we're trying to solve? What constraints exist?

## Decision

What did we decide to do?

## Consequences

### Positive
- Benefits of this decision

### Negative
- Tradeoffs and downsides

### Neutral
- Other impacts

## Alternatives Considered

What other options did we evaluate?
1. **Option A:** Why rejected
2. **Option B:** Why rejected

## References
- Links to relevant documentation, discussions, RFCs
```

---

## ADR Index

### Infrastructure & Deployment
- [ADR-001: Why Hazina Framework Over LangChain](./001-why-hazina-over-langchain.md)
- [ADR-002: SQLite for Development, PostgreSQL for Production](./002-sqlite-dev-postgres-prod.md)
- [ADR-003: Git Worktree Pattern for Parallel AI Agents](./003-worktree-pattern-agents.md)
- [ADR-004: Multi-Tenant SaaS Architecture](./004-multi-tenant-architecture.md)

### Backend Architecture
- ADR-005: ASP.NET Core Web API Framework _(planned)_
- ADR-006: Entity Framework Core as ORM _(planned)_
- [ADR-007: SignalR for Real-Time Communication](./007-signalr-real-time.md)
- [ADR-008: JWT Authentication Strategy](./008-jwt-authentication.md)

### Frontend Architecture
- ADR-009: React 18 + TypeScript Stack _(planned)_
- [ADR-010: Zustand for State Management](./010-zustand-state-management.md)
- ADR-011: TailwindCSS + Radix UI Design System _(planned)_
- ADR-012: Vite as Build Tool _(planned)_

### AI & LLM Integration
- ADR-013: Multi-Provider LLM Strategy _(planned)_
- [ADR-014: Token-Based Pricing Model](./014-token-based-pricing.md)
- ADR-015: RAG Architecture with pgvector _(planned)_

### Development Workflow
- ADR-016: Main/Develop Branching Strategy _(planned)_
- ADR-017: Agent-Driven Development Model _(planned)_

---

## How to Create a New ADR

### 1. Determine if an ADR is Needed

**Create ADR when:**
- Making significant architectural decisions
- Choosing between multiple viable options
- Decision will impact multiple components
- Decision is hard to reverse

**Skip ADR for:**
- Minor implementation details
- Obvious technical choices
- Temporary workarounds

### 2. Create New ADR File

```bash
# Get next number
cd C:\scripts\_machine\ADR
ls *.md | wc -l  # Current count

# Create file
touch XXX-decision-title.md
```

### 3. Fill in Template

Copy the format from above and document:
- **Context:** Why is this decision needed?
- **Decision:** What are we doing?
- **Consequences:** What are the impacts?
- **Alternatives:** What else did we consider?

### 4. Get Review

- Share with team
- Discuss tradeoffs
- Update based on feedback
- Mark as "Accepted" when finalized

### 5. Update Index

Add link to this README.md

---

## ADR Lifecycle

### Status Definitions

**Proposed**
- ADR is drafted but not yet approved
- Open for discussion and changes

**Accepted**
- Team has agreed to this decision
- Implementation can proceed

**Deprecated**
- Decision is no longer recommended
- But code using it still exists

**Superseded by ADR-XXX**
- Replaced by a newer decision
- Provides link to replacement ADR

---

## Best Practices

### DO:
✅ Write ADRs at decision time (not retroactively)
✅ Keep ADRs concise (1-2 pages max)
✅ Focus on "why" not "how"
✅ Document alternatives considered
✅ Update status when decisions change
✅ Link to related ADRs

### DON'T:
❌ Write implementation details (that goes in code docs)
❌ Change ADRs after acceptance (create new ADR instead)
❌ Delete old ADRs (mark as deprecated)
❌ Write ADRs for reversible decisions
❌ Make ADRs too long and detailed

---

## Template

Use this template for new ADRs:

```markdown
# ADR-XXX: [Decision Title]

**Status:** Proposed
**Date:** [YYYY-MM-DD]
**Decision Makers:** [Names]

## Context

[What problem are we solving? What constraints exist?]

## Decision

[What did we decide to do?]

## Consequences

### Positive
- [Benefit 1]
- [Benefit 2]

### Negative
- [Tradeoff 1]
- [Tradeoff 2]

### Neutral
- [Impact 1]

## Alternatives Considered

### Option A: [Name]
- **Pros:** [...]
- **Cons:** [...]
- **Why rejected:** [...]

### Option B: [Name]
- **Pros:** [...]
- **Cons:** [...]
- **Why rejected:** [...]

## References
- [Link to discussion]
- [Link to documentation]
```

---

## Examples from Other Projects

**Useful ADR repositories:**
- [GitHub ADR Organization](https://adr.github.io/)
- [Microsoft Architecture Decisions](https://docs.microsoft.com/en-us/azure/architecture/guide/design-principles/)
- [ThoughtWorks Tech Radar](https://www.thoughtworks.com/radar)

---

**Created:** 2026-01-08
**Maintained by:** Development Team & AI Agents
**Questions?** Add to team discussion or update this README
