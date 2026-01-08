# ADR-014: Token-Based Pricing Model

**Status:** Accepted
**Date:** 2024-08-01
**Decision Makers:** Product Team, Business Lead

## Context

We needed a pricing model for Brand2Boost that:
- Aligns with actual LLM costs (OpenAI charges per token)
- Flexible for different user needs
- Simple to understand
- Prevents abuse
- Scales with usage
- Predictable revenue

**LLM Cost Reality:**
- OpenAI GPT-4: $30 per 1M input tokens, $60 per 1M output tokens
- Anthropic Claude: $15 per 1M input tokens, $75 per 1M output tokens
- Image generation (DALL-E 3): $0.04-0.08 per image

**User Needs:**
- Hobbyists: Try the product (low usage)
- Professionals: Regular usage (medium volume)
- Agencies: High volume, predictable costs

## Decision

**Three-tier token-based subscription model:**

### Free Tier
- **Cost:** $0/month
- **Tokens:** 100,000 tokens/month
- **Limits:**
  - GPT-3.5 only (no GPT-4)
  - 5 images per month
  - No priority support
- **Goal:** Trial, hobbyists, low usage

### Pro Tier
- **Cost:** $29/month
- **Tokens:** 1,000,000 tokens/month
- **Features:**
  - GPT-4 access
  - 50 images per month
  - Priority support
  - Advanced features
- **Goal:** Professionals, regular users

### Enterprise Tier
- **Cost:** Custom pricing
- **Tokens:** Custom allocation
- **Features:**
  - Dedicated support
  - SLA guarantees
  - Custom integrations
  - Bulk discounts
- **Goal:** Agencies, high-volume users

**Token Economy:**
- 1 token ≈ 0.75 words (OpenAI standard)
- ~750 words per 1,000 tokens
- Pro tier = 750,000 words/month = ~15 long-form articles

## Consequences

### Positive
✅ **Cost Alignment**
- Our costs scale with customer usage
- Pass-through pricing (we pay OpenAI per token)
- Predictable margins

✅ **Flexible Usage**
- Users can use tokens however they want
- Chat-heavy vs generation-heavy usage both work
- No artificial limits ("10 articles/month")

✅ **Fair Pricing**
- Heavy users pay more
- Light users pay less
- No subsidizing power users

✅ **Upsell Path**
- Free → Pro is easy upgrade ($29/month)
- Pro → Enterprise for high volume
- Clear value proposition

✅ **Prevents Abuse**
- Token limits prevent runaway costs
- Rate limiting per tier
- Hard caps protect infrastructure

### Negative
❌ **User Confusion**
- "What is a token?" (education needed)
- Hard to estimate usage upfront
- Requires token calculator on pricing page

❌ **Cost Unpredictability for Users**
- Users might run out mid-month
- Unexpected overages (if we allow)
- Need clear notifications

❌ **Pricing Complexity**
- More complex than "10 articles/month"
- Competitive products may seem simpler
- Requires explanation

### Neutral
⚪ **Competitive Positioning**
- Jasper: $49/month for "unlimited" (but quality limits)
- Copy.ai: $36/month for 100 runs
- Writesonic: $19/month for 100,000 words
- We're in the middle (fair pricing)

## Alternatives Considered

### Option A: Flat Unlimited Pricing
**How it works:** $49/month, unlimited usage

**Pros:**
- Simple to understand
- No user confusion
- Easy to sell

**Cons:**
- **Abuse risk:** Power users cost us a fortune
- Can't scale (costs explode)
- Margins are unpredictable
- Must throttle quality or speed (bad UX)

**Why rejected:** Financially unsustainable. Can't compete with OpenAI's scale.

### Option B: Per-Article Pricing
**How it works:** $29/month for 50 articles

**Pros:**
- Easy to understand ("50 articles")
- Predictable for users
- Common model (Jasper uses this)

**Cons:**
- What is "an article"? (100 words? 1,000?)
- Doesn't fit chat use case
- Artificial limitation
- Doesn't reflect real costs

**Why rejected:** Too rigid. Doesn't match LLM cost structure.

### Option C: Pay-As-You-Go (No Subscription)
**How it works:** Buy tokens a la carte

**Pros:**
- Ultimate flexibility
- No commitment
- Users only pay for what they use

**Cons:**
- No predictable revenue (MRR)
- Users might balk at micro-transactions
- Harder to build habits
- Checkout friction

**Why rejected:** SaaS needs recurring revenue. Subscriptions are better.

### Option D: Freemium Forever (Free + Pro)
**How it works:** No limits on free tier, but reduced quality

**Pros:**
- Largest user base
- Viral growth potential

**Cons:**
- **Free users cost money** (LLM costs)
- Hard to monetize
- Need huge scale to work
- We're not venture-funded

**Why rejected:** Can't afford to subsidize free users at scale.

### Option E: API-Style Pricing (Like OpenAI)
**How it works:** $0.01 per 1,000 tokens (exact pass-through)

**Pros:**
- Exact cost recovery
- No guessing
- Transparent

**Cons:**
- Users expect SaaS pricing, not API pricing
- Competes directly with OpenAI (why use us?)
- No margin for our features/UX

**Why rejected:** We add value beyond raw LLM access. Need margin.

## Implementation Details

### Database Schema

```sql
-- Subscription tiers
CREATE TABLE Subscriptions (
    Id UUID PRIMARY KEY,
    UserId UUID REFERENCES Users(Id),
    Tier VARCHAR(20), -- 'Free', 'Pro', 'Enterprise'
    TokensPerMonth INT,
    StartDate TIMESTAMP,
    RenewDate TIMESTAMP,
    Status VARCHAR(20) -- 'Active', 'Cancelled', 'Expired'
);

-- Token balances (updated in real-time)
CREATE TABLE TokenBalances (
    Id UUID PRIMARY KEY,
    UserId UUID REFERENCES Users(Id),
    AvailableTokens INT,
    UsedTokens INT,
    LastResetDate TIMESTAMP
);

-- Token usage log (for analytics)
CREATE TABLE TokenUsage (
    Id UUID PRIMARY KEY,
    UserId UUID,
    Operation VARCHAR(50), -- 'ChatCompletion', 'ImageGeneration'
    TokensUsed INT,
    Model VARCHAR(50), -- 'gpt-4', 'gpt-3.5-turbo'
    Timestamp TIMESTAMP
);
```

### Token Tracking (TokenService.cs)

```csharp
public async Task<bool> HasEnoughTokens(string userId, int required)
{
    var balance = await _db.TokenBalances
        .FirstOrDefaultAsync(b => b.UserId == userId);

    return balance.AvailableTokens >= required;
}

public async Task DeductTokens(string userId, int used, string operation)
{
    var balance = await _db.TokenBalances.FindAsync(userId);
    balance.AvailableTokens -= used;
    balance.UsedTokens += used;

    // Log usage
    _db.TokenUsage.Add(new TokenUsage
    {
        UserId = userId,
        Operation = operation,
        TokensUsed = used,
        Model = "gpt-4",
        Timestamp = DateTime.UtcNow
    });

    await _db.SaveChangesAsync();
}
```

### Monthly Reset (Hangfire Background Job)

```csharp
[RecurringJob("0 0 1 * *")] // 1st of every month
public async Task ResetMonthlyTokens()
{
    var subscriptions = await _db.Subscriptions
        .Where(s => s.Status == "Active")
        .ToListAsync();

    foreach (var sub in subscriptions)
    {
        var balance = await _db.TokenBalances
            .FirstOrDefaultAsync(b => b.UserId == sub.UserId);

        balance.AvailableTokens = sub.TokensPerMonth;
        balance.UsedTokens = 0;
        balance.LastResetDate = DateTime.UtcNow;
    }

    await _db.SaveChangesAsync();
}
```

## Pricing Justification

### Cost Breakdown (Pro Tier Example)

**Revenue:**
- Pro tier: $29/month

**Costs:**
- LLM tokens: 1M tokens ≈ $5-10 (depends on GPT-4 vs 3.5 usage)
- Images: 50 images ≈ $2-4
- Infrastructure: $2/user (database, hosting)
- Support: $1/user (amortized)
- **Total cost:** ~$10-17/user

**Margin:** $12-19/user (40-65% margin)

**Assumptions:**
- Users don't use all tokens (typical usage: 60%)
- Mix of GPT-3.5 (cheap) and GPT-4 (expensive)

### Free Tier Economics

**Cost per free user:** ~$1-2/month (100K tokens)
**Goal:** Convert 5% to paid ($29/month)
**Break-even:** 20 free users per 1 paid user

**Strategy:**
- Limit free tier to prevent abuse
- Nudge upgrades with "Unlock GPT-4" prompts
- Email campaigns for inactive users

## User Education

**Landing page:**
- "What is a token?" explainer
- Visual token calculator
- "~750 words per 1,000 tokens"
- Example: "Write a 1,000-word blog post = ~1,300 tokens"

**In-app:**
- Token balance visible in navbar
- Notifications at 80%, 100% usage
- Suggest upgrade when low on tokens

## Future Enhancements

### Add-On Packs (Planned)
- "Need more tokens?" → Buy 500K tokens for $10
- One-time purchase, no subscription change
- Expires at end of month

### Rollover (Considered)
- Unused tokens roll over to next month (max 2x monthly allotment)
- Prevents "use it or lose it" anxiety
- But: Complicates accounting

### Team Plans (Planned)
- Shared token pool for teams
- $99/month for 5 users, 5M tokens
- Centralized billing

## Monitoring & Analytics

**Track:**
- Average tokens used per user per tier
- Distribution of GPT-3.5 vs GPT-4 usage
- Image generation frequency
- Upgrade rate (Free → Pro)
- Churn rate by tier

**Optimize:**
- Adjust tier limits based on actual usage
- Identify power users (upsell to Enterprise)
- Find underused features (educate or remove)

## References

- OpenAI Pricing: https://openai.com/pricing
- Anthropic Pricing: https://www.anthropic.com/pricing
- Competitor Analysis: Internal doc
- Token Economics: `TokenService.cs`

---

**Review Date:** Every quarter (pricing is fluid)
**Related ADRs:**
- ADR-013: Multi-Provider LLM Strategy
- ADR-004: Multi-Tenant SaaS Architecture
