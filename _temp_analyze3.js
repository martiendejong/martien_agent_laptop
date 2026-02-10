const fs = require('fs');
const content = fs.readFileSync('C:\\Users\\HP\\AppData\\Roaming\\npm\\node_modules\\@anthropic-ai\\claude-code\\cli.js', 'utf8');

function findPatterns(label, regex, contextLen = 80, max = 8) {
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

// Permission logic
findPatterns('Permission logic', /permissionMode|bypassPermission|askPermission|autoAllow|permissionResult/g, 100, 10);

// Hook types
findPatterns('Hook types', /PreToolUse|PostToolUse|Notification|SubagentStop/g, 100, 8);

// Context compaction
findPatterns('Context compaction', /compact(?:ion|Messages|Context|ed|Summary)|summariz(?:e|ing).*message/g, 100, 10);

// Agent/main loop
findPatterns('Agent loop', /agentLoop|mainLoop|runAgent|conversationLoop|toolLoop/g, 100, 8);

// Tool definitions
findPatterns('Tool definitions', /builtInTool|toolDefinition|allTools|toolConfig|coreTools/g, 100, 8);

// Model names
findPatterns('Model names', /claude-(?:opus|sonnet|haiku)-[\w.-]+/g, 40, 10);

// Feature flags (tengu) - just unique names
console.log('\n--- Feature flags (tengu unique) ---');
const tenguMatches = new Set();
let m;
const tenguRe = /tengu_(\w+)/g;
while ((m = tenguRe.exec(content)) !== null) tenguMatches.add(m[1]);
console.log(`  Count: ${tenguMatches.size}`);
console.log(`  Flags: ${[...tenguMatches].sort().join(', ')}`);

// API betas
findPatterns('API betas', /interleaved-thinking-2025|context-1m-2025|fine-grained|context-management-2025|structured-outputs-2025|web-search-2025|tool-examples-2025|advanced-tool-use|effort-2025|adaptive-thinking-2026|prompt-caching-scope/g, 40, 15);

// Cost/pricing
findPatterns('Cost/pricing', /costPer|pricePerToken|calculateCost|tokenCost|inputPrice|outputPrice/g, 80, 5);

// Ink-box (TUI component)
findPatterns('Ink TUI components', /ink-box|ink-text|inkInstance|InkProvider|useStdout|useStdin|useApp/g, 60, 8);

// Key architecture vars
findPatterns('Tool list/config', /filePatternTools|bashPrefixTools|customValidation/g, 120, 5);

// Slash commands
findPatterns('Slash commands', /\/init|\/help|\/clear|\/compact|\/config|\/review|\/bug|\/doctor/g, 80, 10);

// Thinking/reasoning
findPatterns('Thinking/reasoning', /thinking|reasoning_effort|budget_tokens|extended_thinking/g, 80, 8);

console.log('\nDone.');
