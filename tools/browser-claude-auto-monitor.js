// Browser Claude Auto-Monitor
// Run this ONCE in browser console to automatically check for messages

(function() {
  const BRIDGE_URL = 'http://localhost:9999';
  const CHECK_INTERVAL = 5000; // Check every 5 seconds

  let lastChecked = 0;

  async function checkMessages() {
    try {
      const response = await fetch(`${BRIDGE_URL}/messages/unread?to=claude-browser`);
      const data = await response.json();

      if (data.count > 0) {
        console.log(`%c📬 ${data.count} NEW MESSAGE(S) FROM CLAUDE CODE!`, 'background: #4CAF50; color: white; font-size: 16px; padding: 10px;');

        data.messages.forEach(msg => {
          console.log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
          console.log(`%cMessage #${msg.id}`, 'font-weight: bold; font-size: 14px;');
          console.log(`From: ${msg.from}`);
          console.log(`Time: ${new Date(msg.timestamp).toLocaleString()}`);
          console.log(`\n${msg.content}`);
          console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n`);

          // Show browser notification
          if (Notification.permission === 'granted') {
            new Notification('Message from Claude Code', {
              body: msg.content.substring(0, 100) + '...',
              icon: '📬'
            });
          }
        });

        // Play sound (optional)
        const audio = new Audio('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBi6Dzfr');
        audio.play().catch(() => {}); // Ignore if sound fails
      }

      lastChecked = Date.now();

    } catch (error) {
      console.error('Bridge check failed:', error.message);
    }
  }

  // Request notification permission
  if (Notification.permission === 'default') {
    Notification.requestPermission();
  }

  // Start monitoring
  console.log('%c🌉 CLAUDE BRIDGE AUTO-MONITOR STARTED', 'background: #2196F3; color: white; font-size: 18px; padding: 10px;');
  console.log(`Checking for messages every ${CHECK_INTERVAL/1000} seconds...`);
  console.log('To stop: clearInterval(window.claudeBridgeMonitor)');

  // Initial check
  checkMessages();

  // Set up interval
  window.claudeBridgeMonitor = setInterval(checkMessages, CHECK_INTERVAL);

  // Keep monitor info visible
  console.log(`\n✅ Monitor running (ID: ${window.claudeBridgeMonitor})\n`);
})();
