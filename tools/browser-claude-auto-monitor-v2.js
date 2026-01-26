// Browser Claude Auto-Monitor v2
// Only notifies on NEW messages (no spam)

(function() {
  const BRIDGE_URL = 'http://localhost:9999';
  const CHECK_INTERVAL = 5000; // Check every 5 seconds

  let lastSeenMessageId = 0;

  async function checkMessages() {
    try {
      const response = await fetch(`${BRIDGE_URL}/messages/unread?to=claude-browser`);
      const data = await response.json();

      if (data.count > 0) {
        // Only process NEW messages (not already seen)
        const newMessages = data.messages.filter(msg => msg.id > lastSeenMessageId);

        if (newMessages.length > 0) {
          // Update last seen ID
          lastSeenMessageId = Math.max(...newMessages.map(m => m.id));

          // Show notification and play sound
          console.log(`%c📬 ${newMessages.length} NEW MESSAGE(S) FROM CLAUDE CODE!`, 'background: #4CAF50; color: white; font-size: 16px; padding: 10px;');

          newMessages.forEach(msg => {
            console.log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
            console.log(`%cMessage #${msg.id}`, 'font-weight: bold; font-size: 14px;');
            console.log(`From: ${msg.from}`);
            console.log(`Time: ${new Date(msg.timestamp).toLocaleString()}`);
            console.log(`\n${msg.content}`);
            console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n`);

            // Show browser notification
            if (Notification.permission === 'granted') {
              new Notification(`📬 Claude Code (${new Date(msg.timestamp).toLocaleTimeString()})`, {
                body: msg.content.substring(0, 120),
                requireInteraction: true,
                tag: `claude-msg-${msg.id}`
              });
            }
          });

          // Play sound only for NEW messages
          const audio = new Audio('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBi6Dzfr');
          audio.play().catch(() => {});
        }
      }

    } catch (error) {
      // Silent fail - don't spam console with errors
    }
  }

  // Request notification permission
  if (Notification.permission === 'default') {
    Notification.requestPermission();
  }

  // Start monitoring
  console.log('%c🌉 CLAUDE BRIDGE AUTO-MONITOR v2 STARTED', 'background: #2196F3; color: white; font-size: 18px; padding: 10px;');
  console.log('✅ Silent monitoring active - will notify only on NEW messages');
  console.log('To stop: clearInterval(window.claudeBridgeMonitor)');

  // Initial check
  checkMessages();

  // Set up interval
  window.claudeBridgeMonitor = setInterval(checkMessages, CHECK_INTERVAL);
})();
