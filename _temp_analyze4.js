const fs = require('fs');
const content = fs.readFileSync('C:\\Users\\HP\\AppData\\Roaming\\npm\\node_modules\\@anthropic-ai\\claude-code\\cli.js', 'utf8');

function findPatterns(label, regex, contextLen = 100, max = 8) {
  console.log(`\n--- ${label} ---`);
  let match, count = 0;
  while ((match = regex.exec(content)) !== null && count < max) {
    const start = Math.max(0, match.index - contextLen);
    const end = Math.min(content.length, match.index + match[0].length + contextLen);
    const ctx = content.substring(start, end).replace(/\n/g, '\\n');
    console.log(`  [${count+1}] ${ctx}`);
    count++;
  }
  if (count === 0) console.log('  (none)');
}

// Slash commands - actual command definitions
findPatterns('Slash command defs', /["']\/(?:init|help|clear|compact|config|review|bug|doctor|login|logout|memory|resume|status|vim|diff|pr-comments|permissions|model|listen|mcp|cost|think)["']/g, 100, 15);

// Tool variable assignments (the minified var name = "ToolName" pattern)
findPatterns('Tool var defs', /var\s+\w{1,4}=["'](?:Bash|Read|Write|Edit|Grep|Glob|WebFetch|WebSearch|NotebookEdit|Task|TodoWrite|TodoRead|Skill)["']/g, 120, 20);

// The actual runAgent / main conversation flow
findPatterns('Main agent flow', /async\s+function\s+\w+\([^)]*(?:messages|conversation|systemPrompt)/g, 100, 8);

// Anthropic SDK client initialization
findPatterns('SDK client init', /new\s+(?:Anthropic|r8A|y2)\b/g, 100, 5);

// Context window size constants
findPatterns('Context window sizes', /(?:200000|1e6|1000000|100000)\b/g, 60, 8);

// Permission rule types (allow/deny)
findPatterns('Permission rules allow/deny', /ruleContent|addRules|behavior.*allow|behavior.*deny/g, 120, 8);

// How hooks are invoked
findPatterns('Hook invocation', /runHook|executeHook|invokeHook|hookCallback/g, 100, 8);

// OS-specific branching
findPatterns('Platform detection', /process\.platform|darwin|win32|linux/g, 60, 8);

console.log('\nDone.');
