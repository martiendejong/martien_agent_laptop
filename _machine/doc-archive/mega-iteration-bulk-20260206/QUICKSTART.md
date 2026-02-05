# 🚀 Prompt Evolution - Quick Start

Get started in 60 seconds.

## 1. Try the Example

```powershell
cd C:\scripts\tools

# Run evolution with example test cases
.\prompt-evolver.ps1 -TestCasesPath "prompt-evolution\example_test_cases.json"
```

**What happens:**
1. ✅ Phase 1 evolves 20 generations (20 population)
2. ✅ Phase 2 refines top 5 candidates using LLM
3. ✅ Results saved to `prompt_evolution_result.json`
4. ✅ Best prompt displayed in console

**Expected output:**
```
🚀 Starting Hybrid Prompt Evolution
   Population: 20
   Phase 1 Generations: 20
   Phase 2 Top-K: 5

🧬 Phase 1: Component-based evolution (20 generations)
  Generation 1/20... Best: 0.523
  Generation 2/20... Best: 0.587
  ...
  Generation 20/20... Best: 0.734

🤖 Phase 2: LLM-assisted refinement (top 5)
  Refining candidate 1/5... Score: 0.734 → 0.847
  Refining candidate 2/5... Score: 0.721 → 0.809
  ...

✅ Evolution Complete!
   Best Score: 0.847

📝 Best Prompt:
   Extract key points from the following concisely, focusing on main ideas, using bullet points:

{input}
```

## 2. Create Your Own Test Cases

```powershell
# Create test cases for your specific use case
$testCases = @(
    @{
        input = "Your example input text here"
        expected_output = "What you want the LLM to produce"
        weight = 1.0
    },
    @{
        input = "Another example"
        expected_output = "Expected output"
        weight = 1.0
    }
)

$testCases | ConvertTo-Json | Out-File "my_test_cases.json"

# Run evolution
.\prompt-evolver.ps1 -TestCasesPath "my_test_cases.json"
```

## 3. Use the Evolved Prompt

```powershell
# Load results
$result = Get-Content "prompt_evolution_result.json" | ConvertFrom-Json

# Use best prompt
$bestPrompt = $result.best_prompt

# Try it with Hazina
hazina-ask.ps1 ($bestPrompt -replace '\{input\}', 'Your actual text here')
```

## Common Use Cases

### Email Summarization
```json
[
  {
    "input": "Hi team, I wanted to follow up on the meeting...",
    "expected_output": "Follow-up on meeting...",
    "weight": 1.0
  }
]
```

### Code Review
```json
[
  {
    "input": "function calculateTotal(items) { var sum = 0; for(var i=0; i<items.length; i++) sum += items[i]; return sum }",
    "expected_output": "Use const/let instead of var. Consider Array.reduce() for cleaner code.",
    "weight": 1.0
  }
]
```

### Document Extraction
```json
[
  {
    "input": "Contract dated 2024-01-15. Parties: Company A and Company B. Term: 12 months...",
    "expected_output": "Date: 2024-01-15. Parties: Company A, Company B. Duration: 12 months.",
    "weight": 1.0
  }
]
```

## Tips for Best Results

### 1. Quality Test Cases
- **At least 5-10 test cases** (more is better)
- **Diverse examples** covering different scenarios
- **Clear expected outputs** (be specific)
- **Use weights** (2.0 for critical cases, 1.0 for normal)

### 2. Iteration
- Start with 10 generations, see results
- If promising, increase to 30-50 generations
- Try different population sizes (10, 20, 30)

### 3. Evaluation
- **Test evolved prompt** on new examples (not in test set)
- **Compare to your manual prompt** (is it actually better?)
- **A/B test in production** if possible

## Performance Tuning

### Fast Test (2 minutes)
```powershell
prompt-evolver.ps1 -TestCasesPath "test_cases.json" -PopulationSize 10 -Generations 10 -TopK 3
```

### Thorough Search (5 minutes)
```powershell
prompt-evolver.ps1 -TestCasesPath "test_cases.json" -PopulationSize 30 -Generations 50 -TopK 10
```

### Production Quality (10 minutes)
```powershell
# Run multiple times, compare results
prompt-evolver.ps1 -TestCasesPath "test_cases.json" -PopulationSize 50 -Generations 100 -TopK 20 -OutputPath "run1.json"
prompt-evolver.ps1 -TestCasesPath "test_cases.json" -PopulationSize 50 -Generations 100 -TopK 20 -OutputPath "run2.json"
```

## Next Steps

1. ✅ **Run example** → See it work
2. ✅ **Create your test cases** → Your specific problem
3. ✅ **Evolve prompt** → Get optimized version
4. ✅ **Test in production** → Validate improvement
5. ✅ **Iterate** → Refine test cases, re-evolve

## Troubleshooting

**"Hazina CLI not found"**
```powershell
cd C:\Projects\hazina\apps\CLI\Hazina.CLI
dotnet build -c Release
Copy-Item "bin\Release\net9.0\*" "C:\scripts\bin\" -Recurse
```

**Low scores (<0.5)**
- Add more diverse test cases
- Improve expected output clarity
- Try custom similarity function

**Taking too long**
- Reduce population size
- Reduce generations
- Reduce TopK

**Want better results**
- Increase test cases (20+)
- Increase generations (50+)
- Use embedding-based scoring (future)

## Ready?

```powershell
.\prompt-evolver.ps1 -TestCasesPath "prompt-evolution\example_test_cases.json"
```

Let the evolution begin! 🧬
