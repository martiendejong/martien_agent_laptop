// Temporary analysis script for cli.js architecture
const fs = require('fs');
const content = fs.readFileSync('C:\\Users\\HP\\AppData\\Roaming\\npm\\node_modules\\@anthropic-ai\\claude-code\\cli.js', 'utf8');

function findPatterns(label, regex, contextLen = 60) {
  console.log(`\n${'='.repeat(80)}`);
  console.log(`SEARCH: ${label}`);
  console.log('='.repeat(80));
  const matches = [];
  let match;
  let count = 0;
  while ((match = regex.exec(content)) !== null && count < 25) {
    const start = Math.max(0, match.index - contextLen);
    const end = Math.min(content.length, match.index + match[0].length + contextLen);
    const before = content.substring(start, match.index).replace(/\n/g, '\\n');
    const after = content.substring(match.index + match[0].length, end).replace(/\n/g, '\\n');
    console.log(`  [${count+1}] ...${before}<<<${match[0]}>>>${after}...`);
    count++;
  }
  if (count === 0) console.log('  (no matches)');
  console.log(`  Total matches: ${count}${count >= 25 ? '+' : ''}`);
}

// 1. Tool names - look for tool registration patterns
findPatterns('Tool name strings (quoted)', /"(Bash|Read|Write|Edit|Grep|Glob|WebFetch|WebSearch|NotebookEdit|TodoRead|TodoWrite|Task|Skill|Agent)"/g, 80);

// 2. System prompt patterns
findPatterns('System prompt', /system.?[Pp]rompt|systemPrompt|system_prompt/g, 80);

// 3. API endpoints
findPatterns('API endpoints', /api\.anthropic\.com|\/v1\/messages|\/v1\/complete/g, 80);

// 4. Permission system
findPatterns('Permission patterns', /[Pp]ermission(?:s|Mode|Result|Request|Check|Grant|Deny|Allow)/g, 80);

// 5. Hook system
findPatterns('Hook system', /(?:pre|post)(?:Tool|Message)|hookResult|registeredHook|HookEvent|runHook/g, 80);

// 6. MCP patterns
findPatterns('MCP patterns', /McpServer|McpClient|mcp_server|mcpServer|MCP_SERVER|MCPConnection/g, 80);

// 7. Compress/truncate for context window
findPatterns('Compress/truncate', /compress(?:ion|Messages|Context|ed)|truncat(?:e|ed|ion|ing)|summariz(?:e|ing)/g, 80);

// 8. Sandbox/seatbelt
findPatterns('Sandbox/seatbelt', /sandbox|seatbelt|[Ss]andbox(?:Mode|ed|ing)|linux_sandbox|macos_sandbox/g, 80);

// 9. CLAUDE.md
findPatterns('CLAUDE.md patterns', /CLAUDE\.md|claude\.md|claudeMd|CLAUDE_MD/g, 80);

// 10. Tree-sitter
findPatterns('Tree-sitter', /tree.sitter|treeSitter|tree_sitter|TreeSitter/g, 80);

// 11. Subagent/spawn
findPatterns('Subagent/spawn', /subagent|sub_agent|TaskAgent|spawnAgent|agentTask|[Aa]gent(?:Loop|Thread|Spawn)/g, 80);

// 12. Ink/React TUI
findPatterns('Ink/React TUI', /(?:from|require)\s*\(?["']ink["']\)?|useInk|InkProvider|inkInstance/g, 40);

// 13. Messages API call
findPatterns('Messages API', /messages\.create|client\.messages|\.stream\(|apiCall|makeRequest/g, 80);

// 14. Conversation/context management
findPatterns('Context management', /contextWindow|contextManag|conversationHistory|messageHistory|contextLimit/g, 80);

// 15. Key class/function patterns
findPatterns('Architecture patterns', /class\s+\w*(?:Agent|Tool|Session|Conversation|Message|Provider)\b/g, 80);

console.log('\n\nDone.');
