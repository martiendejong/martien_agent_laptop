const fs = require('fs');
const content = fs.readFileSync('C:\\Users\\HP\\AppData\\Roaming\\npm\\node_modules\\@anthropic-ai\\claude-code\\cli.js', 'utf8');

function findPatterns(label, regex, contextLen = 80) {
  console.log(`\n${'='.repeat(80)}`);
  console.log(`SEARCH: ${label}`);
  console.log('='.repeat(80));
  let match;
  let count = 0;
  while ((match = regex.exec(content)) !== null && count < 20) {
    const start = Math.max(0, match.index - contextLen);
    const end = Math.min(content.length, match.index + match[0].length + contextLen);
    const before = content.substring(start, match.index).replace(/\n/g, '\\n');
    const after = content.substring(match.index + match[0].length, end).replace(/\n/g, '\\n');
    console.log(`  [${count+1}] ...${before}<<<${match[0]}>>>${after}...`);
    count++;
  }
  if (count === 0) console.log('  (no matches)');
  console.log(`  Total: ${count}${count >= 20 ? '+' : ''}`);
}

// Ink/React - broader search
findPatterns('Import ink', /["']ink["']|["']ink\//g, 60);

// React patterns for TUI
findPatterns('React createElement/render', /createElement|React\.createElement|\.render\(/g, 60);

// Permission check/grant/deny logic
findPatterns('Permission logic keywords', /permissionMode|bypassPermission|askPermission|grantPermission|denyPermission|autoAllow/g, 100);

// Hook event types
findPatterns('Hook event types', /PreToolUse|PostToolUse|Notification|SubagentStop|hookEvent/g, 100);

// Compact/summarize context
findPatterns('Context compaction', /compact|compaction|summarize.*message|summary.*message|contextManag/g, 80);

// Agent loop / main loop
findPatterns('Agent/main loop', /agentLoop|mainLoop|conversationLoop|toolLoop|runLoop/g, 100);

// Tool registration / tool schema
findPatterns('Tool schema/registration', /toolSchema|registerTool|builtInTool|toolDefinition|allTools/g, 100);

// Version string
findPatterns('Version', /Version:\s*[\d.]+/g, 40);

// Model names/IDs
findPatterns('Model names', /claude-(?:opus|sonnet|haiku)-[\d-]+|claude-\d-\d+-(?:opus|sonnet|haiku)/g, 60);

// Feature flags / tengu
findPatterns('Feature flags (tengu)', /tengu_\w+/g, 60);

// Betas / API features
findPatterns('API betas', /interleaved-thinking|context-1m|fine-grained|context-management|structured-outputs|web-search|tool-examples|advanced-tool-use|effort-|adaptive-thinking|prompt-caching-scope/g, 40);

// Cost calculation
findPatterns('Cost calculation', /costPer|pricePerToken|calculateCost|tokenCost|inputCost|outputCost/g, 80);

console.log('\n\nDone.');
