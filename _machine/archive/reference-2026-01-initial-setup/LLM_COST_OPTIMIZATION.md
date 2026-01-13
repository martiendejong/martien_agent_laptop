# LLM Cost Optimization 💰

**Purpose:** Minimize OpenAI/Anthropic API costs without sacrificing quality.

**Goal:** Reduce monthly AI spend by 30-50% through smart model selection, caching, and prompt optimization.

---

## Cost Breakdown (Current Pricing 2026)

### OpenAI (GPT Models)

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Speed | Quality |
|-------|----------------------|------------------------|-------|---------|
| **GPT-4 Turbo** | $10.00 | $30.00 | Fast | Excellent |
| **GPT-4** | $30.00 | $60.00 | Slow | Best |
| **GPT-3.5 Turbo** | $0.50 | $1.50 | Fastest | Good |
| **GPT-3.5 Turbo 16k** | $3.00 | $4.00 | Fast | Good |

### Anthropic (Claude Models)

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Context | Quality |
|-------|----------------------|------------------------|---------|---------|
| **Claude Opus 3.5** | $15.00 | $75.00 | 200K | Excellent |
| **Claude Sonnet 3.5** | $3.00 | $15.00 | 200K | Very Good |
| **Claude Haiku 3** | $0.25 | $1.25 | 200K | Good |

### Image Generation

| Model | Cost per Image | Resolution | Speed |
|-------|---------------|------------|-------|
| **DALL-E 3** | $0.040 | 1024x1024 | Slow |
| **DALL-E 3** | $0.080 | 1024x1792 | Slow |
| **DALL-E 2** | $0.020 | 1024x1024 | Fast |

---

## Quick Wins (Easy Cost Savings)

### 1. Use Cheaper Models for Simple Tasks ⭐⭐⭐⭐⭐

**DON'T use GPT-4 for everything!**

```typescript
// ❌ BAD: Using GPT-4 for simple classification ($0.03)
const sentiment = await openai.chat.completions.create({
  model: 'gpt-4',
  messages: [{ role: 'user', content: 'Is this review positive or negative: "Great product!"' }],
});

// ✅ GOOD: Use GPT-3.5 Turbo for simple tasks ($0.0005)
const sentiment = await openai.chat.completions.create({
  model: 'gpt-3.5-turbo',  // 60x cheaper!
  messages: [{ role: 'user', content: 'Is this review positive or negative: "Great product!"' }],
});
```

**Model Selection Guide:**

| Task | Recommended Model | Cost | Why |
|------|------------------|------|-----|
| **Classification** | GPT-3.5 Turbo | $ | Simple logic |
| **Summarization** | GPT-3.5 Turbo | $ | Straightforward |
| **Data extraction** | GPT-3.5 Turbo | $ | Follows patterns |
| **Simple Q&A** | GPT-3.5 Turbo | $ | Factual retrieval |
| **Product descriptions** | GPT-3.5 Turbo / Sonnet | $$ | Good quality, cheaper |
| **Brand strategy** | GPT-4 Turbo / Sonnet | $$$ | Needs deep reasoning |
| **Complex creative** | GPT-4 / Opus | $$$$ | Best quality needed |

**Potential savings:** 50-80% by using GPT-3.5 where appropriate.

---

### 2. Compress Prompts (Remove Fluff) ⭐⭐⭐⭐⭐

**Every token costs money!**

```typescript
// ❌ BAD: Verbose prompt (120 tokens)
const prompt = `
Hello! I hope you're having a great day. I would really appreciate it if
you could help me out with something. I need you to please generate a
short product description for me. The product is a handmade ceramic mug.
It would be wonderful if you could make it sound appealing to customers.
If possible, please try to keep the description between 50 and 100 words.
Thank you so much for your help!
`;

// ✅ GOOD: Concise prompt (25 tokens)
const prompt = `
Generate a 50-100 word product description for a handmade ceramic mug.
Make it appealing to customers.
`;
```

**Savings:** 80% fewer input tokens = 80% cost reduction on that portion.

**Prompt compression checklist:**
- [ ] Remove pleasantries ("please", "thank you")
- [ ] Remove filler words ("really", "very", "actually")
- [ ] Use bullet points instead of prose
- [ ] Abbreviate where clear (e.g., "desc" vs "description")
- [ ] Remove redundant instructions

---

### 3. Set Max Tokens (Prevent Overgeneration) ⭐⭐⭐⭐

**Output tokens are 2-5x more expensive than input!**

```typescript
// ❌ BAD: No max_tokens (might generate 1000+ tokens)
const response = await openai.chat.completions.create({
  model: 'gpt-4',
  messages: [{ role: 'user', content: 'Write a product description' }],
});
// Cost: $0.06 if it generates 1000 tokens

// ✅ GOOD: Limit output length
const response = await openai.chat.completions.create({
  model: 'gpt-4',
  max_tokens: 100,  // ~75 words
  messages: [{ role: 'user', content: 'Write a short product description (50-75 words)' }],
});
// Cost: $0.006 (10x cheaper)
```

**Savings:** 50-90% on output costs.

---

### 4. Batch Requests (Combine When Possible) ⭐⭐⭐⭐

**API overhead adds up!**

```typescript
// ❌ BAD: 10 separate requests (10x API calls)
const descriptions = [];
for (const product of products) {
  const desc = await generateDescription(product);
  descriptions.push(desc);
}
// Cost: 10 requests × $0.01 = $0.10

// ✅ GOOD: 1 batch request
const prompt = `
Generate product descriptions for these 10 products:

${products.map((p, i) => `${i + 1}. ${p.name}: ${p.features}`).join('\n')}

Return as JSON array.
`;
const response = await generateBatch(prompt);
// Cost: 1 request × $0.01 = $0.01
```

**Savings:** 90% fewer API calls = 90% cost reduction on overhead.

---

### 5. Cache Responses (Don't Regenerate) ⭐⭐⭐⭐⭐

**Cache identical requests:**

```typescript
// Check cache first
const cacheKey = `tagline:${brand.name}:${brand.industry}`;
let tagline = await cache.get(cacheKey);

if (!tagline) {
  // Generate if not cached
  tagline = await generateTagline(brand);
  await cache.set(cacheKey, tagline, { ttl: 3600 }); // 1 hour TTL
}

return tagline;
```

**What to cache:**
- Product descriptions (TTL: 1 day)
- Brand taglines (TTL: 1 week)
- Social media templates (TTL: 1 hour)
- FAQ answers (TTL: 1 month)

**Savings:** 60-90% if users request same content repeatedly.

---

## Advanced Optimizations

### 6. Use Cheaper Models for First Draft ⭐⭐⭐⭐

**Two-pass approach:**

```typescript
// Step 1: Generate 5 options with GPT-3.5 (cheap)
const options = await openai.chat.completions.create({
  model: 'gpt-3.5-turbo',
  messages: [{ role: 'user', content: 'Generate 5 tagline options' }],
});

// Step 2: Refine best option with GPT-4 (expensive, but only 1x)
const refined = await openai.chat.completions.create({
  model: 'gpt-4',
  messages: [{ role: 'user', content: `Refine this tagline: "${options[0]}"` }],
});
```

**Cost comparison:**
- All GPT-4: 5 × $0.02 = $0.10
- Hybrid: (5 × $0.001) + (1 × $0.02) = $0.025 (75% savings)

---

### 7. Streaming (Stop Early) ⭐⭐⭐

**Stop generation when you have enough:**

```typescript
const stream = await openai.chat.completions.create({
  model: 'gpt-4',
  stream: true,
  messages: [{ role: 'user', content: 'List 100 brand names' }],
});

const names = [];
for await (const chunk of stream) {
  const text = chunk.choices[0]?.delta?.content || '';
  names.push(...extractNames(text));

  if (names.length >= 10) {
    stream.controller.abort();  // Stop generating (only pay for what you got)
    break;
  }
}
```

**Savings:** Pay only for tokens generated before stopping.

---

### 8. Fine-Tuning (For Repetitive Tasks) ⭐⭐⭐

**If you generate the same type of content 1000+ times:**

**Before (few-shot prompting):**
```typescript
const prompt = `
Generate a product description.

Examples:
1. ...
2. ...
3. ...

Now generate:
Input: ${product}
`;
// Cost: 200 tokens input + 100 tokens output = $0.009 per request
```

**After (fine-tuned model):**
```typescript
const prompt = `Input: ${product}`;
// Cost: 10 tokens input + 100 tokens output = $0.003 per request (70% savings)
```

**Fine-tuning cost:**
- Training: ~$50 (one-time)
- Break-even: ~6,000 requests

**When to fine-tune:**
- Same task repeated >10,000 times
- Consistent format/style needed
- Want to reduce prompt size

---

### 9. Fallback to Cheaper Models ⭐⭐⭐

**Try cheap first, upgrade if quality insufficient:**

```typescript
async function generateWithFallback(prompt: string) {
  // Try GPT-3.5 first
  let response = await openai.create({
    model: 'gpt-3.5-turbo',
    messages: [{ role: 'user', content: prompt }],
  });

  // Check quality
  if (meetsQualityStandard(response)) {
    return response;  // Good enough!
  }

  // Fall back to GPT-4
  response = await openai.create({
    model: 'gpt-4',
    messages: [{ role: 'user', content: prompt }],
  });

  return response;
}
```

**Expected savings:** 70-80% if cheap model works 80% of the time.

---

### 10. Embeddings for Similarity (Not LLM Generation) ⭐⭐⭐⭐

**Use embeddings for similarity search (much cheaper than LLM):**

```typescript
// ❌ EXPENSIVE: Ask GPT-4 to find similar products
const prompt = `
Which of these products is most similar to "${query}"?
Products: ${products.join(', ')}
`;
const similar = await gpt4.complete(prompt);
// Cost: ~$0.02

// ✅ CHEAP: Use embeddings
const queryEmbedding = await openai.embeddings.create({
  model: 'text-embedding-ada-002',
  input: query,
});
// Cost: $0.0001 (200x cheaper!)

const similarities = products.map(p =>
  cosineSimilarity(queryEmbedding, p.embedding)
);
const similar = products[argmax(similarities)];
```

**Embedding costs:**
- text-embedding-ada-002: $0.10 per 1M tokens
- GPT-3.5: $0.50 per 1M tokens (5x more expensive)
- GPT-4: $30 per 1M tokens (300x more expensive)

---

## Token Tracking & Budgeting

### Track Usage Per User

```csharp
// TokenService.cs
public async Task TrackUsage(string userId, string model, int tokensUsed)
{
    var usage = new TokenUsage
    {
        UserId = userId,
        Model = model,
        TokensUsed = tokensUsed,
        Cost = CalculateCost(model, tokensUsed),
        Timestamp = DateTime.UtcNow
    };

    _db.TokenUsage.Add(usage);
    await _db.SaveChangesAsync();

    // Update balance
    var balance = await _db.TokenBalances.FindAsync(userId);
    balance.UsedTokens += tokensUsed;
    await _db.SaveChangesAsync();
}

private decimal CalculateCost(string model, int tokens)
{
    var prices = new Dictionary<string, decimal>
    {
        ["gpt-4"] = 0.00003m,  // $30 per 1M input tokens
        ["gpt-3.5-turbo"] = 0.0000005m,  // $0.50 per 1M
    };

    return tokens * prices[model];
}
```

### Alert on Budget Exceeded

```csharp
public async Task CheckBudget(string userId)
{
    var monthlyUsage = await _db.TokenUsage
        .Where(u => u.UserId == userId && u.Timestamp >= DateTime.UtcNow.AddMonths(-1))
        .SumAsync(u => u.Cost);

    var subscription = await _db.Subscriptions.FindAsync(userId);

    if (monthlyUsage > subscription.MonthlyBudget * 0.9m)
    {
        await SendAlert(userId, "You've used 90% of your monthly AI budget");
    }
}
```

### Cost Dashboard

```sql
-- Monthly cost by model
SELECT
    Model,
    SUM(TokensUsed) as TotalTokens,
    SUM(Cost) as TotalCost,
    COUNT(*) as Requests
FROM TokenUsage
WHERE Timestamp >= DATEADD(month, -1, GETUTCDATE())
GROUP BY Model
ORDER BY TotalCost DESC;

-- Top 10 most expensive users
SELECT TOP 10
    UserId,
    SUM(Cost) as TotalCost,
    SUM(TokensUsed) as TotalTokens
FROM TokenUsage
WHERE Timestamp >= DATEADD(month, -1, GETUTCDATE())
GROUP BY UserId
ORDER BY TotalCost DESC;
```

---

## Real-World Scenarios

### Scenario 1: Product Description Generation

**Before optimization:**
- Model: GPT-4
- Prompt: 200 tokens (verbose)
- Output: 150 tokens (no limit)
- Cost: (200 × $0.00003) + (150 × $0.00006) = $0.015 per description
- Monthly: 10,000 descriptions × $0.015 = **$150/month**

**After optimization:**
- Model: GPT-3.5 Turbo (good enough for descriptions)
- Prompt: 50 tokens (compressed)
- Output: 100 tokens (max_tokens=100)
- Caching: 30% cache hit rate
- Cost: (50 × $0.0000005) + (100 × $0.0000015) = $0.00018 per description
- With cache: $0.00018 × 0.7 = $0.000126 per description
- Monthly: 10,000 descriptions × $0.000126 = **$1.26/month**

**Savings: $148.74/month (99% reduction!)**

---

### Scenario 2: Chat Feature

**Before:**
- Model: GPT-4
- Average conversation: 10 messages
- Avg tokens per message: 100 input + 150 output
- Cost per conversation: 10 × [(100 × $0.00003) + (150 × $0.00006)] = $0.12
- Monthly: 5,000 conversations × $0.12 = **$600/month**

**After:**
- Model: GPT-3.5 Turbo (fast, cheap)
- Streaming (stop early if answer complete)
- Avg tokens: 100 input + 100 output (stopped early)
- Cost: 10 × [(100 × $0.0000005) + (100 × $0.0000015)] = $0.002
- Monthly: 5,000 conversations × $0.002 = **$10/month**

**Savings: $590/month (98% reduction!)**

---

### Scenario 3: Image Generation

**Before:**
- DALL-E 3 (1024x1024): $0.040 per image
- Monthly: 1,000 images × $0.040 = **$40/month**

**After:**
- DALL-E 2 (1024x1024): $0.020 per image (half price, good enough)
- Monthly: 1,000 images × $0.020 = **$20/month**

**Savings: $20/month (50% reduction)**

---

## Cost Monitoring & Alerts

### Daily Budget Check

```typescript
// Run daily via Hangfire
async function checkDailyBudget() {
  const today = await getTodayUsage();
  const budget = 50; // $50/day limit

  if (today.cost > budget * 0.9) {
    await sendAlert('90% of daily AI budget used');
  }

  if (today.cost > budget) {
    await sendAlert('Daily AI budget exceeded! Throttling expensive models.');
    await setThrottling(true);
  }
}
```

### Model Cost Breakdown

```typescript
const breakdown = {
  'gpt-4': { requests: 100, tokens: 50000, cost: 1.50 },
  'gpt-3.5-turbo': { requests: 5000, tokens: 500000, cost: 0.25 },
  'claude-opus': { requests: 50, tokens: 25000, cost: 0.75 },
};

console.table(breakdown);
// Identify: Which model is most expensive?
```

---

## Best Practices Checklist

**Before every API call:**
- [ ] Is this the cheapest model that can do this task?
- [ ] Can I compress the prompt further?
- [ ] Have I set max_tokens?
- [ ] Is this request cacheable?
- [ ] Can I batch this with other requests?

**Monthly review:**
- [ ] Analyze cost breakdown by model
- [ ] Identify top 10 most expensive users
- [ ] Check if cheaper models could replace expensive ones
- [ ] Review cache hit rate (target: >50%)
- [ ] Test fine-tuning ROI for repetitive tasks

---

## Tools & Monitoring

**Cost Tracking:**
- Application Insights (Azure) - Custom metrics
- Datadog - LLM cost tracking
- [LangSmith](https://www.langchain.com/langsmith) - Prompt cost analysis
- [PromptLayer](https://promptlayer.com/) - Request logging & cost

**Optimization:**
- [Token Counter](https://platform.openai.com/tokenizer) - Count tokens before sending
- [OpenAI Usage Dashboard](https://platform.openai.com/usage) - Real-time cost
- Custom dashboard (Grafana) - Track costs per feature

---

## Estimated Monthly Costs

**Current usage (unoptimized):**
- Product descriptions: $150
- Chat feature: $600
- Social media generation: $200
- Image generation: $40
- **Total: $990/month**

**After optimization:**
- Product descriptions: $1.26 (cache + GPT-3.5)
- Chat feature: $10 (GPT-3.5 + streaming)
- Social media: $20 (GPT-3.5 + batching)
- Images: $20 (DALL-E 2)
- **Total: $51.26/month**

**Savings: $938.74/month (95% reduction!)**

---

## Related Documentation

- [PROMPT_ENGINEERING.md](./PROMPT_ENGINEERING.md) - Optimize prompts for quality
- [ADR-013: Multi-Provider LLM Strategy](./ADR/013-multi-provider-llm.md) (future)
- [ADR-014: Token-Based Pricing](./ADR/014-token-based-pricing.md)

---

**Last Updated:** 2026-01-08
**Target Cost:** <$100/month
**Current Cost:** ~$1000/month (before optimization)
**Maintained by:** AI Team & Finance
