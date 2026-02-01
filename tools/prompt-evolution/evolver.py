#!/usr/bin/env python3
"""
Hybrid Prompt Evolution Engine

Uses genetic algorithms to evolve optimal prompts:
- Phase 1: Component-based evolution (fast, cheap)
- Phase 2: LLM-assisted refinement (powerful)
- Phase 3: Final validation
"""

import json
import random
import asyncio
import subprocess
from typing import List, Dict, Tuple
from dataclasses import dataclass
from pathlib import Path

@dataclass
class TestCase:
    """A test case for evaluating prompt quality"""
    input: str
    expected_output: str
    weight: float = 1.0

@dataclass
class PromptGenome:
    """Represents a prompt as a genome of component indices"""
    instruction_idx: int
    style_idx: int
    focus_idx: int
    format_idx: int

    def to_dict(self):
        return {
            'instruction': self.instruction_idx,
            'style': self.style_idx,
            'focus': self.focus_idx,
            'format': self.format_idx
        }

# Component pools for building prompts
INSTRUCTION_POOL = [
    "Summarize",
    "Extract key points from",
    "Provide an overview of",
    "Analyze",
    "Review",
    "Condense",
]

STYLE_POOL = [
    "concisely",
    "in detail",
    "briefly",
    "comprehensively",
    "clearly",
]

FOCUS_POOL = [
    "focusing on main ideas",
    "highlighting key decisions",
    "emphasizing action items",
    "prioritizing important details",
    "noting critical information",
]

FORMAT_POOL = [
    "using bullet points",
    "in paragraph form",
    "as a numbered list",
    "in a structured format",
    "using clear sections",
]

class PromptEvolver:
    """Hybrid genetic algorithm for prompt evolution"""

    def __init__(self, test_cases: List[TestCase], hazina_path: str = None):
        self.test_cases = test_cases
        self.hazina_path = hazina_path or self._find_hazina()
        self.generation_history = []

    def _find_hazina(self) -> str:
        """Find hazina CLI executable"""
        paths = [
            "C:\\scripts\\bin\\hazina.exe",
            "C:\\Projects\\worker-agents\\agent-002\\hazina\\apps\\CLI\\Hazina.CLI\\bin\\Release\\net9.0\\hazina.exe",
        ]
        for path in paths:
            if Path(path).exists():
                return path
        raise FileNotFoundError("Hazina CLI not found")

    def decode_genome(self, genome: PromptGenome) -> str:
        """Convert genome to actual prompt text"""
        instruction = INSTRUCTION_POOL[genome.instruction_idx]
        style = STYLE_POOL[genome.style_idx]
        focus = FOCUS_POOL[genome.focus_idx]
        format_spec = FORMAT_POOL[genome.format_idx]

        return f"{instruction} the following {style}, {focus}, {format_spec}:\n\n{{input}}"

    def random_genome(self) -> PromptGenome:
        """Create random genome"""
        return PromptGenome(
            instruction_idx=random.randint(0, len(INSTRUCTION_POOL) - 1),
            style_idx=random.randint(0, len(STYLE_POOL) - 1),
            focus_idx=random.randint(0, len(FOCUS_POOL) - 1),
            format_idx=random.randint(0, len(FORMAT_POOL) - 1),
        )

    async def evaluate_prompt(self, prompt: str) -> float:
        """Evaluate prompt fitness using test cases"""
        scores = []

        for test in self.test_cases:
            # Format prompt with test input
            formatted_prompt = prompt.format(input=test.input)

            # Call LLM via Hazina
            result = await self._call_hazina(formatted_prompt)

            # Simple similarity scoring (you'd want better metrics in production)
            score = self._similarity(result, test.expected_output)
            scores.append(score * test.weight)

        return sum(scores) / len(scores)

    async def _call_hazina(self, prompt: str) -> str:
        """Call Hazina CLI for LLM response"""
        proc = await asyncio.create_subprocess_exec(
            self.hazina_path, "ask", prompt, "--stream", "false",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await proc.communicate()

        if proc.returncode != 0:
            raise RuntimeError(f"Hazina error: {stderr.decode()}")

        return stdout.decode().strip()

    def _similarity(self, text1: str, text2: str) -> float:
        """Simple similarity metric (could use embeddings for better results)"""
        # Normalize
        t1 = set(text1.lower().split())
        t2 = set(text2.lower().split())

        # Jaccard similarity
        if not t1 or not t2:
            return 0.0

        intersection = len(t1 & t2)
        union = len(t1 | t2)

        return intersection / union if union > 0 else 0.0

    def crossover(self, parent1: PromptGenome, parent2: PromptGenome) -> Tuple[PromptGenome, PromptGenome]:
        """Single-point crossover"""
        # Randomly choose crossover point
        point = random.randint(1, 3)

        p1_genes = [parent1.instruction_idx, parent1.style_idx, parent1.focus_idx, parent1.format_idx]
        p2_genes = [parent2.instruction_idx, parent2.style_idx, parent2.focus_idx, parent2.format_idx]

        child1_genes = p1_genes[:point] + p2_genes[point:]
        child2_genes = p2_genes[:point] + p1_genes[point:]

        child1 = PromptGenome(*child1_genes)
        child2 = PromptGenome(*child2_genes)

        return child1, child2

    def mutate(self, genome: PromptGenome, mutation_rate: float = 0.2) -> PromptGenome:
        """Random mutation"""
        genes = [genome.instruction_idx, genome.style_idx, genome.focus_idx, genome.format_idx]
        pool_sizes = [len(INSTRUCTION_POOL), len(STYLE_POOL), len(FOCUS_POOL), len(FORMAT_POOL)]

        for i in range(len(genes)):
            if random.random() < mutation_rate:
                genes[i] = random.randint(0, pool_sizes[i] - 1)

        return PromptGenome(*genes)

    async def phase1_component_evolution(self, population_size: int = 20, generations: int = 20) -> List[Tuple[PromptGenome, float]]:
        """Phase 1: Fast component-based evolution"""
        print(f"\n🧬 Phase 1: Component-based evolution ({generations} generations)")

        # Initialize population
        population = [self.random_genome() for _ in range(population_size)]

        for gen in range(generations):
            # Evaluate fitness
            print(f"  Generation {gen + 1}/{generations}...", end=" ", flush=True)

            fitness_tasks = [self.evaluate_prompt(self.decode_genome(g)) for g in population]
            fitness_scores = await asyncio.gather(*fitness_tasks)

            # Sort by fitness
            pop_with_scores = list(zip(population, fitness_scores))
            pop_with_scores.sort(key=lambda x: x[1], reverse=True)

            best_score = pop_with_scores[0][1]
            print(f"Best: {best_score:.3f}")

            # Store generation stats
            self.generation_history.append({
                'generation': gen + 1,
                'phase': 1,
                'best_score': best_score,
                'avg_score': sum(fitness_scores) / len(fitness_scores),
                'best_prompt': self.decode_genome(pop_with_scores[0][0])
            })

            # Selection: Keep top 50%
            survivors = [g for g, f in pop_with_scores[:population_size // 2]]

            # Crossover to create offspring
            offspring = []
            for i in range(0, len(survivors), 2):
                if i + 1 < len(survivors):
                    child1, child2 = self.crossover(survivors[i], survivors[i + 1])
                    offspring.extend([child1, child2])

            # Mutation
            offspring = [self.mutate(g) for g in offspring]

            # New population
            population = survivors + offspring

        # Final evaluation
        fitness_tasks = [self.evaluate_prompt(self.decode_genome(g)) for g in population]
        fitness_scores = await asyncio.gather(*fitness_tasks)

        return sorted(zip(population, fitness_scores), key=lambda x: x[1], reverse=True)

    async def phase2_llm_refinement(self, candidates: List[Tuple[PromptGenome, float]], top_k: int = 5) -> List[Tuple[str, float]]:
        """Phase 2: LLM-assisted refinement of top candidates"""
        print(f"\n🤖 Phase 2: LLM-assisted refinement (top {top_k})")

        top_candidates = candidates[:top_k]
        refined_prompts = []

        for i, (genome, score) in enumerate(top_candidates):
            print(f"  Refining candidate {i + 1}/{top_k}...", end=" ", flush=True)

            original_prompt = self.decode_genome(genome)

            # Use LLM to refine
            refinement_request = f"""Improve this prompt template for better clarity and effectiveness:

{original_prompt}

Return ONLY the improved prompt template (keep {{input}} placeholder). Make it more specific and effective."""

            refined = await self._call_hazina(refinement_request)

            # Evaluate refined version
            refined_score = await self.evaluate_prompt(refined)

            print(f"Score: {score:.3f} → {refined_score:.3f}")

            # Keep whichever is better
            if refined_score > score:
                refined_prompts.append((refined, refined_score))
            else:
                refined_prompts.append((original_prompt, score))

        return sorted(refined_prompts, key=lambda x: x[1], reverse=True)

    async def evolve(self, population_size: int = 20, phase1_generations: int = 20, top_k: int = 5) -> Dict:
        """Run complete hybrid evolution"""
        print("🚀 Starting Hybrid Prompt Evolution")
        print(f"   Population: {population_size}")
        print(f"   Phase 1 Generations: {phase1_generations}")
        print(f"   Phase 2 Top-K: {top_k}")

        # Phase 1: Component evolution
        phase1_results = await self.phase1_component_evolution(population_size, phase1_generations)

        # Phase 2: LLM refinement
        phase2_results = await self.phase2_llm_refinement(phase1_results, top_k)

        # Return best result
        best_prompt, best_score = phase2_results[0]

        print(f"\n✅ Evolution Complete!")
        print(f"   Best Score: {best_score:.3f}")
        print(f"\n📝 Best Prompt:")
        print(f"   {best_prompt}")

        return {
            'best_prompt': best_prompt,
            'best_score': best_score,
            'all_candidates': [
                {'prompt': p, 'score': s}
                for p, s in phase2_results
            ],
            'generation_history': self.generation_history
        }


async def main():
    """Example usage"""
    # Example test cases
    test_cases = [
        TestCase(
            input="The project deadline is next Friday. We need to complete the API integration and testing by Wednesday.",
            expected_output="Deadline: Next Friday. Complete API integration and testing by Wednesday.",
            weight=1.0
        ),
        TestCase(
            input="Our website has been experiencing slow load times. The database queries are taking 3-5 seconds on average.",
            expected_output="Issue: Slow website load times. Cause: Database queries taking 3-5 seconds.",
            weight=1.0
        ),
        TestCase(
            input="Customer feedback has been positive overall. Main request is for a mobile app version.",
            expected_output="Feedback: Positive. Request: Mobile app version.",
            weight=1.0
        ),
    ]

    evolver = PromptEvolver(test_cases)
    result = await evolver.evolve(
        population_size=10,
        phase1_generations=10,
        top_k=3
    )

    # Save results
    output_path = Path("prompt_evolution_result.json")
    with open(output_path, 'w') as f:
        json.dump(result, f, indent=2)

    print(f"\n💾 Results saved to: {output_path}")


if __name__ == "__main__":
    asyncio.run(main())
