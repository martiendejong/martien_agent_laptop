# Prompt Evolution via Genetic Algorithms

**Status:** Built and ready (2026-02-01)
**Cost:** ~$0.21-$2.10 per evolution run
**Use When:** Production optimization needed, manual prompts plateau

---

## Overview

Hybrid genetic algorithm system that evolves optimal prompts through:
1. **Phase 1:** Component-based genetic evolution (fast, cheap)
2. **Phase 2:** LLM-assisted refinement (powerful, expensive)

## When to Use

### ✅ Good Use Cases
- **RAG query optimization** - Find best prompts for specific knowledge bases
- **Email/content summarization** - Consistent, high-quality summaries
- **Code review automation** - Standardized feedback patterns
- **Production systems** - One-time cost, reuse forever
- **Quality plateau** - Manual prompts not improving anymore

### ❌ Don't Use When
- **Cost-sensitive** - ~2000 LLM calls per run
- **Quick prototyping** - Manual iteration faster for initial exploration
- **Unclear requirements** - Need clear test cases first
- **Single-use prompts** - Not worth optimization cost

## How It Works

### Component-Based Evolution (Phase 1)
```
Prompt = [Instruction] + [Style] + [Focus] + [Format]

Example pools:
- Instructions: ["Summarize", "Extract", "Analyze"]
- Styles: ["concisely", "in detail", "briefly"]
- Focus: ["key decisions", "action items", "main ideas"]
- Formats: ["bullet points", "paragraphs", "numbered list"]

Genome: [2, 0, 1, 0] → "Analyze concisely highlighting key decisions using bullet points"
```

**Genetic Operations:**
- **Selection:** Keep top 50% by fitness
- **Crossover:** Combine parent genomes at random point
- **Mutation:** Randomly change components (20% rate)
- **Fitness:** Similarity to expected outputs on test cases

### LLM-Assisted Refinement (Phase 2)
```
Top 5 component-based prompts
    ↓
LLM refines each for clarity/effectiveness
    ↓
Compare refined vs original scores
    ↓
Keep whichever is better
```

## Usage

### 1. Create Test Cases
```json
[
  {
    "input": "Example text to process",
    "expected_output": "What you want the LLM to produce",
    "weight": 1.0
  }
]
```

**Tips:**
- 10+ test cases (more is better)
- Diverse examples
- Clear expected outputs
- Use weight=2.0 for critical cases

### 2. Run Evolution
```powershell
prompt-evolver.ps1 -TestCasesPath "test_cases.json"
```

**Options:**
- `-PopulationSize 20` - Prompts per generation (default: 20)
- `-Generations 20` - Phase 1 iterations (default: 20)
- `-TopK 5` - How many to refine in Phase 2 (default: 5)
- `-OutputPath "results.json"` - Where to save results

### 3. Use Results
```powershell
$result = Get-Content "prompt_evolution_result.json" | ConvertFrom-Json
$bestPrompt = $result.best_prompt
$bestScore = $result.best_score
```

## Cost Analysis

**Phase 1:** 20 generations × 20 population = 400 evaluations
**Test cases:** 5 per prompt
**Total Phase 1:** 400 × 5 = 2000 LLM calls

**Phase 2:** 5 candidates × (1 refinement + 5 evaluations) = 30 LLM calls

**Grand Total:** ~2030 LLM calls = $0.21 - $2.10 (Haiku to Sonnet)

**ROI:** One-time cost, reuse optimal prompt forever

## Performance

- **Fast test:** 10 pop × 10 gen × 3 top = ~500 calls = 1 min = $0.05
- **Standard:** 20 pop × 20 gen × 5 top = ~2000 calls = 3 min = $0.21
- **Thorough:** 50 pop × 100 gen × 20 top = ~25k calls = 30 min = $2.50

## Real-World Use Cases

### Client-Manager: Email Summarization
**Problem:** Need consistent, high-quality email summaries for inbox
**Solution:** Evolve prompt with 20+ example emails
**Result:** Discover optimal format, tone, detail level automatically

### Hazina: RAG Query Optimization
**Problem:** Different knowledge bases need different retrieval prompts
**Solution:** Evolve per-knowledge-base prompts
**Result:** Better relevance, reduced hallucination

### Code Review Automation
**Problem:** Inconsistent review feedback quality
**Solution:** Evolve prompts with example code + desired feedback
**Result:** Standardized, helpful reviews

## Files & Documentation

- **Tool:** `C:\scripts\tools\prompt-evolver.ps1`
- **Engine:** `C:\scripts\tools\prompt-evolution\evolver.py`
- **Examples:** `C:\scripts\tools\prompt-evolution\example_test_cases.json`
- **Quick Start:** `C:\scripts\tools\prompt-evolution\QUICKSTART.md`
- **Full Docs:** `C:\scripts\tools\prompt-evolution\README.md`

## Future Enhancements

**When cost becomes less of a concern:**
- Embedding-based similarity (better than word overlap)
- Multi-objective optimization (accuracy + brevity + clarity)
- Adaptive mutation rates
- Prompt caching for duplicates
- Integration with Hazina stores
- Visualization of evolution progress

## Status: Ready But Expensive

**Decision:** Tool is built, tested, and ready to use
**Constraint:** ~$2 per run makes it expensive for experimentation
**Use when:** Production optimization needed, ROI is clear
**Wait for:** Cost reduction, critical need, or budget allocation

---

**Created:** 2026-02-01
**User feedback:** "for now just leave it, its too expensive but update your systems and when the time comes we can use it"
**Next steps:** Monitor for use cases where $2 optimization is worth it (production systems, high-value automations)
