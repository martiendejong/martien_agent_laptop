# 🧬 Prompt Evolution - Hybrid Genetic Algorithm

Automatically evolve optimal prompts using a two-phase hybrid approach.

## How It Works

### Phase 1: Component-Based Evolution (Fast & Cheap)
- Breaks prompts into **reusable components** (instruction, style, focus, format)
- Uses **genetic algorithms** to evolve combinations
- Fast iterations (no LLM calls for crossover/mutation)
- Example components:
  - Instructions: "Summarize", "Extract key points", "Analyze"
  - Styles: "concisely", "in detail", "briefly"
  - Focus: "highlighting key decisions", "emphasizing action items"
  - Formats: "using bullet points", "in paragraph form"

### Phase 2: LLM-Assisted Refinement (Powerful)
- Takes **top candidates** from Phase 1
- Uses **LLM to refine** each prompt for better clarity and effectiveness
- Compares refined vs original, keeps whichever scores higher
- More creative improvements than component-based alone

## Usage

### 1. Create Test Cases

```json
[
  {
    "input": "The project deadline is next Friday. We need to complete the API integration and testing by Wednesday.",
    "expected_output": "Deadline: Next Friday. Complete API integration and testing by Wednesday.",
    "weight": 1.0
  },
  {
    "input": "Our website has been experiencing slow load times. The database queries are taking 3-5 seconds.",
    "expected_output": "Issue: Slow website load times. Cause: Database queries taking 3-5 seconds.",
    "weight": 1.0
  }
]
```

Save as `test_cases.json`

### 2. Run Evolution

```powershell
prompt-evolver.ps1 -TestCasesPath "test_cases.json"
```

### 3. Results

The tool will:
1. Run Phase 1 evolution (20 generations by default)
2. Refine top 5 candidates using LLM
3. Save results to `prompt_evolution_result.json`
4. Display best prompt and score

## Advanced Usage

```powershell
# Larger population, more generations
prompt-evolver.ps1 -TestCasesPath "test_cases.json" -PopulationSize 30 -Generations 50

# Refine top 10 instead of top 5
prompt-evolver.ps1 -TestCasesPath "test_cases.json" -TopK 10

# Custom output path
prompt-evolver.ps1 -TestCasesPath "test_cases.json" -OutputPath "my_results.json"
```

## Output Format

```json
{
  "best_prompt": "Extract key points from the following concisely, focusing on main ideas, using bullet points:\n\n{input}",
  "best_score": 0.847,
  "all_candidates": [
    {
      "prompt": "...",
      "score": 0.847
    },
    {
      "prompt": "...",
      "score": 0.823
    }
  ],
  "generation_history": [
    {
      "generation": 1,
      "phase": 1,
      "best_score": 0.523,
      "avg_score": 0.412
    }
  ]
}
```

## Evaluation Metrics

Current implementation uses **Jaccard similarity** (word overlap) between LLM output and expected output.

### Improving Evaluation

For production use, consider:
- **Embedding-based similarity** (cosine similarity of embeddings)
- **Custom scoring functions** (check for specific requirements)
- **Human evaluation** (for final validation)
- **Multiple metrics** (accuracy + brevity + clarity)

## Use Cases

### 1. RAG Query Optimization
Evolve prompts for retrieving and summarizing documents:
```json
{
  "input": "User manual for Product X, page 42...",
  "expected_output": "Product X requires annual maintenance...",
  "weight": 1.0
}
```

### 2. Email Summarization
Find optimal prompt for client email summaries:
```json
{
  "input": "Hi, our website is down. Please fix ASAP...",
  "expected_output": "URGENT: Website outage, immediate action required",
  "weight": 2.0
}
```

### 3. Code Review
Evolve prompts for consistent code review feedback:
```json
{
  "input": "function foo() { var x = 1; return x }",
  "expected_output": "Use const instead of var. Consider descriptive naming.",
  "weight": 1.0
}
```

## Cost Considerations

### Phase 1 (Component-Based)
- **20 generations × 20 population = 400 evaluations**
- Each evaluation = 1 LLM call per test case
- With 5 test cases: **2000 LLM calls**
- Cost: ~$0.20 - $2.00 depending on model

### Phase 2 (LLM-Assisted)
- **Top 5 candidates × (1 refinement + 1 evaluation)**
- With 5 test cases: **50 LLM calls**
- Cost: ~$0.01 - $0.10

### Total
- **~2050 LLM calls** per evolution run
- Cost: **$0.21 - $2.10** (using Haiku/Sonnet)
- **One-time cost, reuse prompt forever**

### Optimizations
- Start with smaller population (10) and fewer generations (10)
- Use cached results for identical inputs
- Use faster/cheaper models for Phase 1
- Use better models only for Phase 2

## Extending the System

### Add New Component Pools

Edit `evolver.py`:
```python
INSTRUCTION_POOL = [
    "Summarize",
    "Extract key points from",
    # Add your custom instructions
    "Translate",
    "Rewrite",
]
```

### Custom Fitness Functions

Replace `_similarity()` with your own:
```python
def _similarity(self, text1: str, text2: str) -> float:
    # Your custom scoring logic
    # Could use embeddings, regex matching, etc.
    pass
```

### Multi-Objective Optimization

Evolve for multiple goals:
```python
async def evaluate_prompt(self, prompt: str) -> Dict[str, float]:
    return {
        'accuracy': accuracy_score,
        'brevity': brevity_score,
        'clarity': clarity_score
    }
```

## Troubleshooting

### "Hazina CLI not found"
```powershell
# Build Hazina CLI
cd C:\Projects\hazina\apps\CLI\Hazina.CLI
dotnet build -c Release

# Copy to bin
Copy-Item "bin\Release\net9.0\*" "C:\scripts\bin\" -Recurse
```

### "Python not found"
```powershell
# Install Python 3.8+
winget install Python.Python.3.12
```

### Low Scores
- **Add more test cases** (10+ recommended)
- **Improve expected outputs** (be specific)
- **Try custom fitness function** (Jaccard similarity is simple)
- **Increase generations** (30-50 for complex tasks)

## Performance

- **Phase 1:** ~1-2 minutes (20 generations, population 20)
- **Phase 2:** ~30-60 seconds (refine top 5)
- **Total:** ~2-3 minutes per evolution run

Parallelization opportunity: Multiple test cases evaluated concurrently.

## Future Enhancements

- [ ] Embedding-based similarity scoring
- [ ] Multi-objective fitness (Pareto optimization)
- [ ] Adaptive mutation rates
- [ ] Prompt caching for duplicate evaluations
- [ ] Visualization of evolution progress
- [ ] Support for custom component pools via config
- [ ] Interactive mode (approve/reject candidates)
- [ ] Integration with Hazina RAG stores

## References

- Genetic Algorithms: [Wikipedia](https://en.wikipedia.org/wiki/Genetic_algorithm)
- Prompt Engineering: [OpenAI Guide](https://platform.openai.com/docs/guides/prompt-engineering)
- LLM Evaluation: [Anthropic Guide](https://docs.anthropic.com/claude/docs/guide-to-anthropics-prompt-engineering-resources)
