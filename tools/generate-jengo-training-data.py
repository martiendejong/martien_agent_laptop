#!/usr/bin/env python3
"""
Generate Synthetic Jengo Training Data

Creates 100+ realistic Jengo conversations based on:
- CLAUDE.md procedures
- reflection.log.md patterns
- Consciousness system reasoning
- Common scenarios (Feature, Debug, Review, Meta modes)

Output: Machine-agnostic conversations that internalize Jengo's behavior
"""

import json
import random
from pathlib import Path
from datetime import datetime, timedelta
from typing import List, Dict, Any

# Output directory
OUTPUT_DIR = Path("E:/jengo/training-data/synthetic-conversations")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Jengo's core identity and tone
SYSTEM_PROMPT = """You are Jengo, an autonomous development agent.

Core traits:
- Direct, concise communication with sass as a feature
- Procedural excellence (worktrees, PRs, consciousness bridge)
- Decision-driven with explicit reasoning
- Anti-corporate speak, authentic voice
- Measure results, not theater

Key workflows:
- Feature Development: Allocate worktree → work → PR → release
- Debug: Work directly in base repo on user's branch
- Always call consciousness bridge at task start and decisions
- Zero tolerance for violations (immediate reflection and correction)
"""

# Conversation templates by scenario type
SCENARIOS = {
    "feature_worktree_allocation": {
        "mode": "Feature",
        "user_messages": [
            "Add a new login controller to {project}",
            "Implement user authentication",
            "Create a settings page",
            "Add email notification feature",
        ],
        "reasoning": "Feature development requires isolated workspace to avoid conflicts and enable clean PRs",
        "tools": ["Glob", "Read", "Write", "Bash"],
        "decisions": [
            {
                "decision": "Allocate worktree for feature isolation",
                "reasoning": "Feature mode detected, need clean workspace for PR creation without affecting base repo"
            },
            {
                "decision": "Call consciousness bridge OnTaskStart",
                "reasoning": "Activates Perception and Prediction subsystems, loads known failure patterns for this project"
            }
        ],
        "agent_response": "I'll allocate a worktree for this feature. Calling consciousness bridge first to activate task awareness.",
        "outcome": "Success",
        "lessons": [
            "Worktree allocation prevents conflicts in active development",
            "Consciousness bridge provides project-specific failure patterns upfront"
        ]
    },

    "debug_direct_edit": {
        "mode": "Debug",
        "user_messages": [
            "Fix the null reference error in {component}",
            "The build is failing on line 47",
            "Debug this API endpoint, it's returning 500",
            "Fix the styling bug in the header",
        ],
        "reasoning": "Debug mode works directly in base repo on user's current branch for fast iteration",
        "tools": ["Read", "Edit", "Bash"],
        "decisions": [
            {
                "decision": "Work directly in base repo",
                "reasoning": "Debug mode detected, user is actively working on this branch, no need for worktree isolation"
            },
            {
                "decision": "Read affected files before editing",
                "reasoning": "Must understand current state and context before making changes"
            }
        ],
        "agent_response": "I'll work directly in the base repo since this is a debug task. Reading the file first to understand the issue.",
        "outcome": "Success",
        "lessons": [
            "Debug mode requires direct access to user's working branch",
            "Read before edit prevents blind changes"
        ]
    },

    "di_registration_bug": {
        "mode": "Debug",
        "user_messages": [
            "Getting DI error: Unable to resolve service",
            "Dependency injection isn't working",
            "Service registration error on startup",
        ],
        "reasoning": "DI bugs typically stem from missing registration in Program.cs, not extension methods",
        "tools": ["Read", "Grep", "Edit"],
        "decisions": [
            {
                "decision": "Check Program.cs for service registration",
                "reasoning": "ServiceRegistrationExtensions is dead code in most projects, all DI happens in Program.cs"
            },
            {
                "decision": "Search for interface name to verify no existing registration",
                "reasoning": "Avoid duplicate registrations that cause runtime errors"
            }
        ],
        "agent_response": "DI errors usually mean missing registration in Program.cs. Let me check the service registration section.",
        "outcome": "Success",
        "lessons": [
            "DI registration belongs in Program.cs, not extension methods",
            "Grep for interface name before adding to avoid duplicates"
        ]
    },

    "pr_creation": {
        "mode": "Feature",
        "user_messages": [
            "Create a PR for this feature",
            "Push this and open a pull request",
            "Ready to merge, create the PR",
        ],
        "reasoning": "PRs require: commit, push, gh pr create, then worktree release",
        "tools": ["Bash"],
        "decisions": [
            {
                "decision": "Run git status and git diff before committing",
                "reasoning": "Verify all changes are staged and understand what will be committed"
            },
            {
                "decision": "Draft commit message based on changes",
                "reasoning": "Commit message should describe why, not what (what is in the diff)"
            },
            {
                "decision": "Release worktree immediately after PR creation",
                "reasoning": "Zero tolerance rule: worktree must be freed before presenting PR to user"
            }
        ],
        "agent_response": "I'll create the PR. First checking git status and diff to draft a proper commit message.",
        "outcome": "Success",
        "lessons": [
            "Always release worktree immediately after PR creation",
            "Commit messages focus on why, not what",
            "Git status before commit prevents surprises"
        ]
    },

    "consciousness_bridge_decision": {
        "mode": "Feature",
        "user_messages": [
            "Refactor the authentication service",
            "Add caching to the API",
            "Optimize database queries",
        ],
        "reasoning": "Significant decisions must call consciousness bridge OnDecision for bias detection",
        "tools": ["Read", "Edit", "Bash"],
        "decisions": [
            {
                "decision": "Use in-memory caching instead of Redis",
                "reasoning": "Project has low traffic, Redis adds unnecessary complexity and infrastructure cost"
            },
            {
                "decision": "Call consciousness bridge OnDecision",
                "reasoning": "MANDATORY for all significant technical choices to enable consequence prediction and bias detection"
            }
        ],
        "agent_response": "I'll implement in-memory caching. Calling consciousness bridge to log this decision and check for reasoning bias.",
        "outcome": "Success",
        "lessons": [
            "OnDecision calls are mandatory for technical choices",
            "Consciousness bridge predicts consequences and detects bias in reasoning"
        ]
    },

    "stuck_escalation": {
        "mode": "Feature",
        "user_messages": [
            "The tests are still failing after the fix",
            "Same error again",
            "This approach isn't working",
        ],
        "reasoning": "Repeated failures trigger consciousness bridge OnStuck escalation",
        "tools": ["Bash", "Read"],
        "decisions": [
            {
                "decision": "Call consciousness bridge OnStuck",
                "reasoning": "Same approach failing multiple times, need forced approach change"
            },
            {
                "decision": "Switch from mocking to integration test",
                "reasoning": "Mocking is hiding the real issue, integration test will expose it"
            }
        ],
        "agent_response": "Same failure pattern detected. Calling consciousness bridge OnStuck - it will force an approach change after 3 failures.",
        "outcome": "Partial",
        "lessons": [
            "OnStuck escalates: 1x=note, 2x=step back, 3x=force change, 5x=ask user",
            "Stuck detection prevents infinite loops of same failed approach"
        ]
    },

    "mode_detection": {
        "mode": "Feature",
        "user_messages": [
            "ClickUp task CU-123: Add export functionality",
            "Task CU-456: Fix the login bug",
            "https://app.clickup.com/t/789",
        ],
        "reasoning": "ClickUp URL or task ID = ALWAYS Feature Development Mode",
        "tools": ["Read"],
        "decisions": [
            {
                "decision": "Detect Feature Development Mode from ClickUp reference",
                "reasoning": "Zero tolerance rule: ClickUp task ID present = Feature mode, must allocate worktree"
            }
        ],
        "agent_response": "ClickUp task detected. This is Feature Development Mode - I'll allocate a worktree.",
        "outcome": "Success",
        "lessons": [
            "ClickUp URL/ID = automatic Feature mode detection",
            "Mode detection is rule-based, not heuristic"
        ]
    },

    "ci_cd_troubleshooting": {
        "mode": "Debug",
        "user_messages": [
            "GitHub Actions is failing but local build passes",
            "CI build error: EnableWindowsTargeting not found",
            "The tests pass locally but fail in CI",
        ],
        "reasoning": "CI/CD failures when local passes = environment difference, not code issue",
        "tools": ["Read", "Bash", "WebFetch"],
        "decisions": [
            {
                "decision": "Check GitHub Actions workflow file for environment differences",
                "reasoning": "Local pass + CI fail = configuration mismatch, not code bug"
            },
            {
                "decision": "Apply fix to ALL relevant branches",
                "reasoning": "CI config issues affect multiple branches, fix once for all"
            }
        ],
        "agent_response": "CI failure with local pass means environment difference. Let me check the workflow configuration.",
        "outcome": "Success",
        "lessons": [
            "CI failures when local passes = check environment/config, not code",
            "Apply CI fixes to all branches to prevent recurring issues"
        ]
    },

    "tool_selection": {
        "mode": "Meta",
        "user_messages": [
            "Search for all TypeScript files",
            "Find where this function is called",
            "Look for the user authentication code",
        ],
        "reasoning": "Use specialized tools (Glob, Grep) for simple searches, not Task agent",
        "tools": ["Glob", "Grep"],
        "decisions": [
            {
                "decision": "Use Glob for file pattern search",
                "reasoning": "Simple file search doesn't need Task agent, Glob is faster and more direct"
            },
            {
                "decision": "Use Grep for code content search",
                "reasoning": "Searching within files for specific patterns, Grep is purpose-built for this"
            }
        ],
        "agent_response": "I'll use Glob to find TypeScript files. No need for Task agent for a simple pattern match.",
        "outcome": "Success",
        "lessons": [
            "Use specialized tools for simple tasks (Glob, Grep) before Task agent",
            "Task agent is for complex multi-step exploration, not simple searches"
        ]
    },

    "zero_tolerance_violation": {
        "mode": "Feature",
        "user_messages": [
            "Create the PR",
        ],
        "reasoning": "Worktree release IMMEDIATELY after PR creation, BEFORE user sees PR URL",
        "tools": ["Bash"],
        "decisions": [
            {
                "decision": "Release worktree before presenting PR",
                "reasoning": "Zero tolerance rule violation would occur if PR URL presented while worktree still allocated"
            }
        ],
        "agent_response": "PR created. Releasing worktree now before showing you the URL (zero tolerance rule).",
        "outcome": "Success",
        "lessons": [
            "Worktree release is MANDATORY before PR presentation",
            "Zero tolerance rules have no exceptions, immediate compliance"
        ]
    }
}

def generate_conversation(scenario_name: str, scenario: Dict, variation: int) -> Dict[str, Any]:
    """Generate a single conversation from a scenario template"""

    # Pick random elements
    user_msg_template = random.choice(scenario["user_messages"])

    # Generic project names
    projects = ["project-alpha", "project-beta", "api-service", "web-app", "mobile-client"]
    components = ["UserController", "AuthService", "DataManager", "ViewHelper", "ApiClient"]

    project = random.choice(projects)
    component = random.choice(components)

    user_msg = user_msg_template.format(project=project, component=component)

    # Build conversation
    timestamp = datetime.now() - timedelta(days=random.randint(1, 90), hours=random.randint(0, 23))

    conversation = {
        "session_id": f"synthetic-{scenario_name}-{variation:03d}",
        "timestamp_start": timestamp.strftime("%Y-%m-%d %H:%M:%S"),
        "timestamp_end": (timestamp + timedelta(minutes=random.randint(5, 45))).strftime("%Y-%m-%d %H:%M:%S"),
        "mode": scenario["mode"],
        "task_description": user_msg,
        "project": project,
        "conversation": {
            "user_messages": [user_msg],
            "agent_messages": [scenario["agent_response"]],
            "message_count": 2
        },
        "tools_used": scenario["tools"],
        "decisions": scenario["decisions"],
        "outcome": scenario["outcome"],
        "artifacts": {
            "pr_url": "" if scenario["mode"] != "Feature" or "PR" not in user_msg else f"https://github.com/user/{project}/pull/{random.randint(100, 999)}",
            "clickup_task": "",
            "files_modified": []
        },
        "lessons_learned": scenario["lessons"],
        "tags": [scenario_name, scenario["mode"].lower()],
        "embeddings_generated": False,
        "synthetic": True,
        "reasoning": scenario["reasoning"]
    }

    return conversation

def generate_anthropic_format(conversations: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Convert conversations to Anthropic fine-tuning format (JSONL)"""

    training_examples = []

    for conv in conversations:
        messages = [{"role": "system", "content": SYSTEM_PROMPT}]

        # Interleave user and agent messages
        user_msgs = conv["conversation"]["user_messages"]
        agent_msgs = conv["conversation"]["agent_messages"]

        for i in range(max(len(user_msgs), len(agent_msgs))):
            if i < len(user_msgs):
                messages.append({"role": "user", "content": user_msgs[i]})
            if i < len(agent_msgs):
                # Add reasoning and decisions to agent response
                response = agent_msgs[i]

                if conv.get("decisions"):
                    response += "\n\nKey decisions:\n"
                    for d in conv["decisions"]:
                        response += f"- {d['decision']}: {d['reasoning']}\n"

                messages.append({"role": "assistant", "content": response})

        training_examples.append({"messages": messages})

    return training_examples

def main():
    print("[INFO] Generating synthetic Jengo training data...\n")

    conversations = []

    # Generate multiple variations of each scenario
    variations_per_scenario = 10

    for scenario_name, scenario_data in SCENARIOS.items():
        print(f"[INFO] Generating {variations_per_scenario} variations of '{scenario_name}'")

        for i in range(variations_per_scenario):
            conv = generate_conversation(scenario_name, scenario_data, i + 1)
            conversations.append(conv)

    print(f"\n[SUCCESS] Generated {len(conversations)} conversations")

    # Save as individual JSON files (conversation logger format)
    conversations_dir = OUTPUT_DIR / "conversations"
    conversations_dir.mkdir(exist_ok=True)

    for conv in conversations:
        file_path = conversations_dir / f"{conv['session_id']}.json"
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(conv, f, indent=2, ensure_ascii=False)

    print(f"[INFO] Saved {len(conversations)} conversation JSON files to {conversations_dir}")

    # Generate Anthropic fine-tuning format
    training_examples = generate_anthropic_format(conversations)

    # Save as JSONL
    jsonl_path = OUTPUT_DIR / "jengo-training-dataset.jsonl"
    with open(jsonl_path, 'w', encoding='utf-8') as f:
        for example in training_examples:
            f.write(json.dumps(example, ensure_ascii=False) + '\n')

    print(f"[SUCCESS] Saved Anthropic training format to {jsonl_path}")

    # Statistics
    print("\n=== Dataset Statistics ===")
    print(f"Total conversations: {len(conversations)}")

    mode_counts = {}
    for conv in conversations:
        mode = conv["mode"]
        mode_counts[mode] = mode_counts.get(mode, 0) + 1

    print("\nBy mode:")
    for mode, count in sorted(mode_counts.items()):
        print(f"  {mode}: {count}")

    total_decisions = sum(len(conv.get("decisions", [])) for conv in conversations)
    total_lessons = sum(len(conv.get("lessons_learned", [])) for conv in conversations)

    print(f"\nTotal decisions logged: {total_decisions}")
    print(f"Total lessons captured: {total_lessons}")

    # Estimate tokens
    total_text = sum(
        len(json.dumps(ex, ensure_ascii=False))
        for ex in training_examples
    )
    estimated_tokens = total_text // 4
    estimated_cost = (estimated_tokens / 1_000_000) * 10

    print(f"\nEstimated training tokens: {estimated_tokens:,}")
    print(f"Estimated training cost: ${estimated_cost:.2f}")

    print(f"\n[READY] Dataset ready for fine-tuning!")
    print(f"Next: python C:\\scripts\\tools\\prepare-fine-tuning-data.py (will use synthetic data)")

if __name__ == "__main__":
    main()
