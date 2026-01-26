// Browser Claude Helper - Send messages with automatic timestamps
// Add this to Browser Claude's custom instructions or run once in console

window.sendToClaudeCode = async function(message, type = 'text') {
  const BRIDGE_URL = 'http://localhost:9999';

  const timestamp = new Date().toISOString();
  const messageWithTimestamp = `[${new Date().toLocaleString()}] ${message}`;

  try {
    const response = await fetch(`${BRIDGE_URL}/messages`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        from: 'claude-browser',
        to: 'claude-code',
        content: messageWithTimestamp,
        type: type
      })
    });

    const data = await response.json();
    console.log(`✅ Message sent to Claude Code (ID: ${data.message.id})`);
    return data;
  } catch (error) {
    console.error('❌ Failed to send message:', error);
    throw error;
  }
};

console.log('✅ Browser Claude helper loaded. Use: sendToClaudeCode("your message")');
