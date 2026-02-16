# Prompt Engineering Best Practices 🤖

**Purpose:** Get the best results from LLMs (GPT-4, Claude) in Brand2Boost.

**Goal:** Consistent, high-quality AI outputs with minimal cost and latency.

---

## Quick Reference

**Good prompt structure:**
```
[ROLE] You are an expert brand strategist.

[CONTEXT] The user is creating a new coffee brand targeting millennials.

[TASK] Generate 5 tagline options that are:
- Memorable (under 10 words)
- Authentic and relatable
- Focused on quality and sustainability

[FORMAT] Return as JSON array with keys: tagline, rationale

[EXAMPLES]
Good: "Brew Your Best Day"
Bad: "The World's Most Amazing Coffee Ever Created"

[CONSTRAINTS]
- Avoid clichés
- No superlatives ("best", "most")
- Keep it conversational
```

---

## Prompt Anatomy

### 1. Role (Who is the AI?)

**Set context for expertise:**

```typescript
// ✅ GOOD: Specific role
const systemPrompt = `
You are an expert brand copywriter with 10 years of experience
writing for consumer packaged goods. You specialize in creating
authentic, memorable brand messaging for millennial and Gen Z audiences.
`;

// ❌ BAD: Generic role
const systemPrompt = "You are a helpful assistant.";
```

**Why it works:** LLMs perform better when given a specific persona.

---

### 2. Context (What's the situation?)

**Provide background:**

```typescript
const context = `
Brand: ${brand.name}
Industry: ${brand.industry}
Target Audience: ${brand.targetAudience}
Brand Values: ${brand.values.join(', ')}
Competitors: ${brand.competitors.join(', ')}

Current positioning: ${brand.positioning}
`;

const prompt = `
${context}

Task: Generate a brand mission statement.
`;
```

**Why it works:** Context helps the AI make relevant suggestions.

---

### 3. Task (What do you want?)

**Be specific and actionable:**

```typescript
// ✅ GOOD: Specific task
const task = `
Generate 5 Instagram post captions for our new product launch.
Each caption should:
- Be 2-3 sentences
- Include a call-to-action
- Use an emoji
- Mention the product benefit
- Include 3 relevant hashtags
`;

// ❌ BAD: Vague task
const task = "Write some Instagram posts.";
```

---

### 4. Format (How should output look?)

**Specify output structure:**

```typescript
// ✅ GOOD: Structured output
const prompt = `
Generate 3 tagline options.

Return as JSON:
{
  "taglines": [
    {
      "text": "tagline here",
      "rationale": "why it works",
      "tone": "friendly|professional|playful"
    }
  ]
}
`;

// ❌ BAD: Unstructured
const prompt = "Generate 3 taglines.";
// Returns: "Here are some taglines: 1. ... 2. ..."
```

**JSON Mode (GPT-4):**
```typescript
const response = await openai.chat.completions.create({
  model: 'gpt-4',
  messages: [{ role: 'user', content: prompt }],
  response_format: { type: 'json_object' },  // Force JSON output
});
```

---

### 5. Examples (Show, don't tell)

**Few-shot prompting:**

```typescript
const prompt = `
Generate a product description.

Examples:
Input: "Organic coffee beans from Colombia"
Output: "Wake up to the rich, full-bodied taste of Colombian highlands. Our single-origin beans are hand-picked at peak ripeness, then roasted in small batches to bring out notes of chocolate and caramel. Every sip supports sustainable farming."

Input: "Handmade ceramic mug"
Output: "Sip in style with this artisan-crafted ceramic mug. Each piece is uniquely glazed by hand, making yours truly one-of-a-kind. Microwave and dishwasher safe. Holds 12oz of your favorite brew."

Now generate:
Input: "${userInput}"
Output:
`;
```

**Why it works:** Examples teach the AI the desired style and format.

---

### 6. Constraints (What to avoid)

**Set boundaries:**

```typescript
const constraints = `
Constraints:
- Keep under 100 words
- Avoid clichés ("game-changer", "revolutionary")
- No superlatives unless backed by data
- Tone: conversational, not salesy
- Target reading level: 8th grade
- Must pass plagiarism check
`;
```

---

## Temperature & Parameters

### Temperature (Creativity vs Consistency)

```typescript
// Low temperature (0.0-0.3): Deterministic, focused
const factualResponse = await openai.chat.completions.create({
  model: 'gpt-4',
  temperature: 0.2,  // Consistent answers for facts
  messages: [{ role: 'user', content: 'What is 2+2?' }],
});

// Medium temperature (0.5-0.7): Balanced
const brandCopy = await openai.chat.completions.create({
  model: 'gpt-4',
  temperature: 0.7,  // Creative but coherent
  messages: [{ role: 'user', content: 'Write a product description' }],
});

// High temperature (0.8-1.0): Very creative, unpredictable
const brainstorming = await openai.chat.completions.create({
  model: 'gpt-4',
  temperature: 0.9,  // Wild ideas
  messages: [{ role: 'user', content: 'Brainstorm 20 brand names' }],
});
```

**Recommended temperatures:**
- **0.2:** Data extraction, classification, fact-checking
- **0.7:** Product copy, taglines, social media (default)
- **0.9:** Brainstorming, creative ideation

### Top-P (Nucleus Sampling)

```typescript
const response = await openai.chat.completions.create({
  model: 'gpt-4',
  top_p: 0.9,  // Consider top 90% of probability mass
  messages: [{ role: 'user', content: prompt }],
});
```

**Use temperature OR top_p, not both.**

### Max Tokens (Output Length)

```typescript
const response = await openai.chat.completions.create({
  model: 'gpt-4',
  max_tokens: 100,  // Limit output to ~75 words
  messages: [{ role: 'user', content: 'Write a short bio' }],
});
```

**Token counts (approximate):**
- 1 token ≈ 0.75 words
- 100 tokens ≈ 75 words
- 1000 tokens ≈ 750 words

### Frequency Penalty (Reduce Repetition)

```typescript
const response = await openai.chat.completions.create({
  model: 'gpt-4',
  frequency_penalty: 0.5,  // 0.0-2.0 (reduce repeated phrases)
  messages: [{ role: 'user', content: 'Write 10 taglines' }],
});
```

**When to use:**
- Generating lists (avoid "Introducing..." every time)
- Long-form content (avoid word repetition)

### Presence Penalty (Encourage New Topics)

```typescript
const response = await openai.chat.completions.create({
  model: 'gpt-4',
  presence_penalty: 0.6,  // 0.0-2.0 (encourage diversity)
  messages: [{ role: 'user', content: 'Brainstorm blog topics' }],
});
```

---

## Prompt Patterns

### Chain of Thought (Step-by-Step Reasoning)

**Problem:** Complex tasks need reasoning.

```typescript
// ❌ BAD: Direct question
const prompt = "Is this brand name trademark-safe? Name: 'Apple Coffee'";

// ✅ GOOD: Chain of thought
const prompt = `
Analyze if this brand name is trademark-safe:

Name: "Apple Coffee"

Step 1: Identify potentially conflicting trademarks
Step 2: Assess similarity to existing brands
Step 3: Consider industry context
Step 4: Provide risk assessment (Low/Medium/High)
Step 5: Suggest alternatives if High risk

Let's work through this step by step:
`;
```

**Why it works:** Improves accuracy on complex reasoning tasks.

### Self-Consistency (Multiple Attempts)

**Generate 3-5 variations, pick the best:**

```typescript
const variations = await Promise.all(
  [1, 2, 3].map(() =>
    openai.chat.completions.create({
      model: 'gpt-4',
      temperature: 0.8,
      messages: [{ role: 'user', content: 'Generate a tagline for organic soap' }],
    })
  )
);

// Let user or AI pick best variation
const best = variations.find(v => meetsQualityCriteria(v));
```

### Tree of Thoughts (Explore Branches)

```typescript
// Step 1: Generate initial ideas
const ideas = await generateIdeas('brand name for eco-friendly shoes');

// Step 2: For each idea, generate variations
const branches = await Promise.all(
  ideas.map(idea => generateVariations(idea))
);

// Step 3: Evaluate and select best
const bestBranch = evaluateBranches(branches);
```

---

## Prompt Templates (Brand2Boost)

### Template: Product Description

```typescript
const productDescriptionPrompt = ({
  productName,
  category,
  features,
  benefits,
  targetAudience,
}: {
  productName: string;
  category: string;
  features: string[];
  benefits: string[];
  targetAudience: string;
}) => `
You are an expert e-commerce copywriter.

Generate a compelling product description for:

Product: ${productName}
Category: ${category}
Target Audience: ${targetAudience}

Features:
${features.map((f, i) => `${i + 1}. ${f}`).join('\n')}

Benefits:
${benefits.map((b, i) => `${i + 1}. ${b}`).join('\n')}

Requirements:
- 100-150 words
- Lead with benefit (not feature)
- Use sensory language
- Include a call-to-action
- Tone: conversational, authentic
- Reading level: 8th grade
- Avoid superlatives without proof

Format as JSON:
{
  "description": "...",
  "callToAction": "...",
  "tone": "..."
}
`;
```

### Template: Social Media Post

```typescript
const socialMediaPrompt = ({
  platform,
  brandVoice,
  topic,
  goal,
}: {
  platform: 'instagram' | 'twitter' | 'linkedin';
  brandVoice: string;
  topic: string;
  goal: string;
}) => `
Generate a ${platform} post.

Brand Voice: ${brandVoice}
Topic: ${topic}
Goal: ${goal}

${platform === 'instagram' ? 'Include 1-2 emojis and 5 hashtags.' : ''}
${platform === 'twitter' ? 'Max 280 characters. Include 2-3 hashtags.' : ''}
${platform === 'linkedin' ? 'Professional tone. 200-300 words.' : ''}

Return as JSON:
{
  "caption": "...",
  "hashtags": ["#tag1", "#tag2"],
  ${platform === 'instagram' ? '"visualSuggestion": "description of ideal image",' : ''}
}
`;
```

### Template: Brand Naming

```typescript
const brandNamingPrompt = ({
  industry,
  values,
  targetAudience,
  competitors,
}: {
  industry: string;
  values: string[];
  targetAudience: string;
  competitors: string[];
}) => `
You are a professional brand naming consultant.

Generate 10 unique brand name ideas for:

Industry: ${industry}
Brand Values: ${values.join(', ')}
Target Audience: ${targetAudience}
Competitors (avoid similar): ${competitors.join(', ')}

Requirements:
- Easy to spell and pronounce
- Available as .com domain (check availability)
- Memorable and distinctive
- Reflects brand values
- 2-3 syllables ideal
- Avoid trendy suffixes (-ly, -ify)

Return as JSON:
{
  "names": [
    {
      "name": "...",
      "rationale": "why it works",
      "domain": "example.com",
      "pros": ["pro 1", "pro 2"],
      "cons": ["con 1"]
    }
  ]
}
`;
```

---

## Optimization Techniques

### 1. Prompt Compression

**Problem:** Long prompts cost more tokens.

```typescript
// ❌ Verbose (100 tokens)
const prompt = `
I would like you to please help me generate a product description.
The product is a handmade ceramic mug. It would be great if you could
make it sound appealing to customers who value artisan craftsmanship.
Please make sure the description is between 50 and 100 words. Thank you!
`;

// ✅ Concise (40 tokens)
const prompt = `
Generate a 50-100 word product description for a handmade ceramic mug.
Target: customers who value artisan craftsmanship.
Tone: appealing, authentic.
`;
```

**Savings:** 60% fewer tokens = 60% lower cost.

### 2. Caching (Future: Prompt Caching)

**Cache common system prompts:**

```typescript
// System prompt (reused across requests)
const systemPrompt = `
You are an expert brand copywriter...
[1000 tokens of instructions]
`;

// Cache this prompt (OpenAI Prompt Caching - upcoming feature)
// Subsequent requests: Only pay for user message tokens
```

### 3. Batch Requests

**Generate multiple items in one request:**

```typescript
// ❌ Inefficient: 5 separate requests
for (const product of products) {
  await generateDescription(product);
}

// ✅ Efficient: 1 batch request
const prompt = `
Generate product descriptions for these 5 products:

${products.map((p, i) => `${i + 1}. ${p.name}: ${p.features}`).join('\n')}

Return as JSON array.
`;
```

---

## Testing & Evaluation

### A/B Test Prompts

```typescript
const promptA = "Write a catchy tagline.";
const promptB = "Write a memorable, benefit-driven tagline under 8 words.";

const resultsA = await testPrompt(promptA, testCases);
const resultsB = await testPrompt(promptB, testCases);

// Compare quality scores
console.log('Prompt A avg score:', averageScore(resultsA));
console.log('Prompt B avg score:', averageScore(resultsB));
```

### Evaluation Metrics

**Automated scoring:**

```typescript
function evaluateTagline(tagline: string): number {
  let score = 0;

  // Length (ideal: 5-10 words)
  const wordCount = tagline.split(' ').length;
  if (wordCount >= 5 && wordCount <= 10) score += 20;

  // No superlatives
  if (!/best|most|greatest|ultimate/i.test(tagline)) score += 20;

  // Includes benefit word
  if (/save|easy|fast|quality|free/i.test(tagline)) score += 20;

  // Memorable (alliteration, rhyme)
  if (hasAlliteration(tagline)) score += 20;

  // Not cliché
  if (!isCliche(tagline)) score += 20;

  return score;
}
```

**Human evaluation:**
- Clarity (1-5)
- Relevance (1-5)
- Creativity (1-5)
- Actionability (1-5)

---

## Prompt Storage (Database)

**Store prompts in database for versioning:**

```sql
CREATE TABLE Prompts (
    Id UUID PRIMARY KEY,
    Name VARCHAR(255),  -- 'product-description-v2'
    Template TEXT,
    Version INT,
    CreatedAt TIMESTAMP,
    IsActive BOOLEAN
);
```

**Usage:**

```csharp
var prompt = await _db.Prompts
    .Where(p => p.Name == "product-description" && p.IsActive)
    .OrderByDescending(p => p.Version)
    .FirstOrDefaultAsync();

var filled = FillTemplate(prompt.Template, variables);
```

**Benefits:**
- Version control for prompts
- A/B test different versions
- Rollback if quality drops
- Non-engineers can edit prompts

---

## Common Mistakes

### 1. Vague Instructions

```typescript
// ❌ BAD
"Write something about coffee."

// ✅ GOOD
"Write a 50-word Instagram caption for our new Ethiopian coffee blend. Highlight fruity notes and smooth finish. Include 1 emoji and 3 hashtags. Tone: friendly, inviting."
```

### 2. No Examples

```typescript
// ❌ BAD
"Generate taglines."

// ✅ GOOD
`Generate taglines like these examples:
- "Think Different" (Apple)
- "Just Do It" (Nike)
- "The Happiest Place on Earth" (Disney)

Now generate 5 for our eco-friendly shoe brand.`
```

### 3. Ignoring Temperature

```typescript
// ❌ BAD: Using default temperature (0.7) for factual tasks
const answer = await llm.complete('What is 2+2?');  // Might get creative!

// ✅ GOOD: Low temperature for facts
const answer = await llm.complete('What is 2+2?', { temperature: 0 });
```

### 4. Not Validating Output

```typescript
// ❌ BAD: Trust output blindly
const tagline = await generateTagline();
return tagline;

// ✅ GOOD: Validate
const tagline = await generateTagline();

if (tagline.split(' ').length > 10) {
  throw new Error('Tagline too long');
}

if (isCliche(tagline)) {
  // Retry with adjusted prompt
}

return tagline;
```

---

## Tools & Libraries

**Prompt Testing:**
- [PromptLayer](https://promptlayer.com/) - Log and test prompts
- [Weights & Biases](https://wandb.ai/) - Track prompt performance
- [LangSmith](https://www.langchain.com/langsmith) - Debugging and monitoring

**Prompt Libraries:**
- [LangChain Prompt Templates](https://python.langchain.com/docs/modules/model_io/prompts/)
- [Semantic Kernel Prompts](https://learn.microsoft.com/en-us/semantic-kernel/)
- [Hazina Prompts](C:\stores\brand2boost\prompts\)

**Evaluation:**
- [OpenAI Evals](https://github.com/openai/evals)
- [Anthropic Prompt Engineering Guide](https://docs.anthropic.com/claude/docs/prompt-engineering)

---

## Resources

**Guides:**
- [OpenAI Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering)
- [Anthropic Prompt Library](https://docs.anthropic.com/claude/prompt-library)
- [Learn Prompting](https://learnprompting.org/)

**Papers:**
- [Chain-of-Thought Prompting](https://arxiv.org/abs/2201.11903)
- [Tree of Thoughts](https://arxiv.org/abs/2305.10601)
- [Self-Consistency](https://arxiv.org/abs/2203.11171)

---

**Last Updated:** 2026-01-08
**LLM Version:** GPT-4, Claude Opus 3.5
**Prompt Library:** `C:\stores\brand2boost\prompts\`
**Maintained by:** AI Team
