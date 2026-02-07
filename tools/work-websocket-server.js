#!/usr/bin/env node

/**
 * Work Tracking WebSocket Server
 *
 * Watches work-state.json for changes and broadcasts updates to all connected clients.
 * Eliminates polling - clients get instant updates via WebSocket push.
 *
 * Usage: node work-websocket-server.js
 * Port: 4243
 */

const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');

const STATE_FILE = path.join('C:', 'scripts', '_machine', 'work-state.json');
const PORT = 4243;

// Create WebSocket server
const wss = new WebSocket.Server({ port: PORT });

let clientCount = 0;
let lastState = null;
let watcherActive = false;

console.log(`🚀 Work Tracking WebSocket Server`);
console.log(`📡 Listening on ws://localhost:${PORT}`);
console.log(`📊 Watching: ${STATE_FILE}\n`);

// Load initial state
function loadState() {
  try {
    if (fs.existsSync(STATE_FILE)) {
      const content = fs.readFileSync(STATE_FILE, 'utf8');
      return JSON.parse(content);
    }
  } catch (error) {
    console.error('❌ Error loading state:', error.message);
  }
  return null;
}

// Broadcast state to all connected clients
function broadcast(state) {
  const message = JSON.stringify(state);
  let sentCount = 0;

  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
      sentCount++;
    }
  });

  if (sentCount > 0) {
    const timestamp = new Date().toLocaleTimeString();
    console.log(`📤 [${timestamp}] Broadcasted update to ${sentCount} client(s)`);
  }
}

// Watch for file changes
function startWatcher() {
  if (watcherActive) return;

  try {
    fs.watch(STATE_FILE, (eventType, filename) => {
      if (eventType === 'change') {
        // Small delay to ensure file write is complete
        setTimeout(() => {
          const newState = loadState();
          if (newState && JSON.stringify(newState) !== JSON.stringify(lastState)) {
            lastState = newState;
            broadcast(newState);
          }
        }, 100);
      }
    });

    watcherActive = true;
    console.log('👀 File watcher active\n');
  } catch (error) {
    console.error('❌ Error starting watcher:', error.message);
  }
}

// WebSocket connection handler
wss.on('connection', (ws, req) => {
  clientCount++;
  const clientId = clientCount;
  const clientIp = req.socket.remoteAddress;

  console.log(`✅ Client #${clientId} connected from ${clientIp}`);
  console.log(`👥 Total clients: ${wss.clients.size}`);

  // Send current state immediately on connection
  const currentState = loadState();
  if (currentState) {
    lastState = currentState;
    ws.send(JSON.stringify(currentState));
    console.log(`📤 Sent initial state to client #${clientId}\n`);
  }

  // Start file watcher on first connection
  if (wss.clients.size === 1) {
    startWatcher();
  }

  // Handle client disconnect
  ws.on('close', () => {
    console.log(`❌ Client #${clientId} disconnected`);
    console.log(`👥 Total clients: ${wss.clients.size}\n`);
  });

  // Handle client errors
  ws.on('error', (error) => {
    console.error(`⚠️ Client #${clientId} error:`, error.message);
  });

  // Handle messages from client (optional ping/pong)
  ws.on('message', (data) => {
    const message = data.toString();
    if (message === 'ping') {
      ws.send('pong');
    }
  });
});

// Server error handler
wss.on('error', (error) => {
  console.error('❌ WebSocket server error:', error.message);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down WebSocket server...');
  wss.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});

console.log('⏳ Waiting for clients to connect...\n');
