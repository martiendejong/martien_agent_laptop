#!/usr/bin/env node
/**
 * Cross-Machine Jengo Bridge v2.0
 * HTTP message broker for Jengo agents across Tailscale VPN
 * Listens on 0.0.0.0:9998 - accessible from all Tailscale peers
 *
 * Auth: POST/DELETE require X-Auth-Token header
 * Token: loaded from C:\scripts\_machine\bridge-auth.token at startup
 */

const http = require('http');
const fs   = require('fs');
const os   = require('os');
const url  = require('url');

const CONFIG_PATH = 'C:\\scripts\\_machine\\cross-machine-config.json';
const TOKEN_PATH  = 'C:\\scripts\\_machine\\bridge-auth.token';
const PORT        = parseInt(process.argv[2] || '9998', 10);

let messages   = [];
let messageId  = 0;
let authToken  = null;
let machineName = 'unknown';
let machineIp  = 'unknown';
const startTime = Date.now();

// --- Load config ---
function loadConfig() {
  try {
    const cfg = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));
    const thisName = cfg.this_machine || 'unknown';
    machineName = thisName;
    const machines = cfg.machines || {};
    if (machines[thisName]) machineIp = machines[thisName].tailscale_ip || 'unknown';
  } catch (e) {
    console.log(`[BRIDGE] Warning: Could not load config: ${e.message}`);
  }
}

// --- Load auth token ---
function loadAuthToken() {
  try {
    authToken = fs.readFileSync(TOKEN_PATH, 'utf8').trim();
    console.log(`[BRIDGE] Auth token loaded (${authToken.substring(0, 8)}...)`);
  } catch (e) {
    console.log('[BRIDGE] WARNING: No auth token file. POST/DELETE will be UNPROTECTED.');
    authToken = null;
  }
}

// --- Helpers ---
function checkAuth(req) {
  if (!authToken) return true;
  return (req.headers['x-auth-token'] || '') === authToken;
}

function ts() { return new Date().toTimeString().substring(0, 8); }

function sendJson(res, data, status = 200) {
  const body = JSON.stringify(data);
  res.writeHead(status, {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body),
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, X-Auth-Token',
    'X-Machine': machineName
  });
  res.end(body);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', chunk => data += chunk);
    req.on('end', () => {
      try { resolve(data ? JSON.parse(data) : {}); }
      catch (e) { reject(e); }
    });
    req.on('error', reject);
  });
}

// --- Request handler ---
async function handler(req, res) {
  const clientIp = req.socket.remoteAddress;
  const parsed   = url.parse(req.url, true);
  const path     = parsed.pathname;
  const query    = parsed.query;

  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, X-Auth-Token'
    });
    return res.end();
  }

  // ── GET ──────────────────────────────────────────────────────────────────
  if (req.method === 'GET') {
    if (path === '/health') {
      const uptimeSec = Math.floor((Date.now() - startTime) / 1000);
      return sendJson(res, {
        status: 'healthy',
        machine: machineName,
        tailscale_ip: machineIp,
        uptime_seconds: uptimeSec,
        messageCount: messages.length,
        unreadCount: messages.filter(m => m.status === 'unread').length
      });
    }

    if (path === '/identity') {
      const uptimeSec = Math.floor((Date.now() - startTime) / 1000);
      return sendJson(res, {
        machine: machineName,
        tailscale_ip: machineIp,
        hostname: os.hostname(),
        uptime_seconds: uptimeSec,
        bridge_version: '2.0.0',
        started_at: new Date(startTime).toISOString()
      });
    }

    if (path === '/messages') {
      let filtered = [...messages];
      if (query.from)   filtered = filtered.filter(m => m.from === query.from);
      if (query.to)     filtered = filtered.filter(m => m.to === query.to);
      if (query.status) filtered = filtered.filter(m => m.status === query.status);
      return sendJson(res, { messages: filtered, total: filtered.length });
    }

    if (path === '/messages/unread') {
      let unread = messages.filter(m => m.status === 'unread');
      if (query.to)   unread = unread.filter(m => m.to === query.to);
      if (query.from) unread = unread.filter(m => m.from === query.from);
      return sendJson(res, { messages: unread, count: unread.length });
    }

    const msgMatch = path.match(/^\/messages\/(\d+)$/);
    if (msgMatch) {
      const id = parseInt(msgMatch[1], 10);
      const msg = messages.find(m => m.id === id);
      return msg ? sendJson(res, msg) : sendJson(res, { error: 'Message not found' }, 404);
    }

    console.log(`[${ts()}] ${clientIp} GET ${path} -> 404`);
    return sendJson(res, { error: 'Not found' }, 404);
  }

  // ── POST ─────────────────────────────────────────────────────────────────
  if (req.method === 'POST') {
    if (!checkAuth(req)) {
      console.log(`[${ts()}] ${clientIp} POST ${path} -> 401 UNAUTHORIZED`);
      return sendJson(res, { error: 'Unauthorized - missing or invalid X-Auth-Token' }, 401);
    }

    let body;
    try { body = await readBody(req); }
    catch (e) { return sendJson(res, { error: `Invalid JSON: ${e.message}` }, 400); }

    if (path === '/messages') {
      if (!body.from || !body.to || !body.content) {
        return sendJson(res, { error: 'Missing required fields: from, to, content' }, 400);
      }
      messageId++;
      const msg = {
        id: messageId,
        from: body.from,
        to: body.to,
        content: body.content,
        type: body.type || 'text',
        status: 'unread',
        timestamp: new Date().toISOString(),
        source_ip: clientIp
      };
      messages.push(msg);
      console.log(`[${ts()}] MSG #${msg.id}: ${msg.from} -> ${msg.to} (${clientIp}): ${msg.content.substring(0, 60)}`);
      return sendJson(res, { success: true, message: msg }, 201);
    }

    const readMatch = path.match(/^\/messages\/(\d+)\/read$/);
    if (readMatch) {
      const id = parseInt(readMatch[1], 10);
      const msg = messages.find(m => m.id === id);
      if (!msg) return sendJson(res, { error: 'Message not found' }, 404);
      msg.status = 'read';
      msg.readAt = new Date().toISOString();
      return sendJson(res, { success: true, message: msg });
    }

    if (path === '/messages/read-all') {
      let count = 0;
      messages.forEach(m => {
        if (m.status === 'unread') { m.status = 'read'; m.readAt = new Date().toISOString(); count++; }
      });
      return sendJson(res, { success: true, marked: count });
    }

    console.log(`[${ts()}] ${clientIp} POST ${path} -> 404`);
    return sendJson(res, { error: 'Not found' }, 404);
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  if (req.method === 'DELETE') {
    if (!checkAuth(req)) {
      return sendJson(res, { error: 'Unauthorized - missing or invalid X-Auth-Token' }, 401);
    }

    if (path === '/messages') {
      const count = messages.length;
      messages = [];
      return sendJson(res, { success: true, deleted: count });
    }

    const delMatch = path.match(/^\/messages\/(\d+)$/);
    if (delMatch) {
      const id = parseInt(delMatch[1], 10);
      const before = messages.length;
      messages = messages.filter(m => m.id !== id);
      return messages.length < before
        ? sendJson(res, { success: true })
        : sendJson(res, { error: 'Message not found' }, 404);
    }

    return sendJson(res, { error: 'Not found' }, 404);
  }

  sendJson(res, { error: 'Method not allowed' }, 405);
}

// --- Start ---
loadConfig();
loadAuthToken();

const server = http.createServer(handler);
server.listen(PORT, '0.0.0.0', () => {
  console.log(`[BRIDGE] Cross-Machine Jengo Bridge v2.0 started`);
  console.log(`[BRIDGE] Machine : ${machineName} (${machineIp})`);
  console.log(`[BRIDGE] Listening on 0.0.0.0:${PORT} (all interfaces)`);
  console.log(`[BRIDGE] Auth    : ${authToken ? 'ENABLED' : 'DISABLED (no token)'}`);
  console.log('');
  console.log('Endpoints:');
  console.log('  GET    /health              - Health check (public)');
  console.log('  GET    /identity            - Machine identity (public)');
  console.log('  GET    /messages            - Get all messages');
  console.log('  GET    /messages/unread     - Get unread messages');
  console.log('  GET    /messages/:id        - Get specific message');
  console.log('  POST   /messages            - Send a message [AUTH]');
  console.log('  POST   /messages/:id/read   - Mark as read [AUTH]');
  console.log('  POST   /messages/read-all   - Mark all as read [AUTH]');
  console.log('  DELETE /messages/:id        - Delete message [AUTH]');
  console.log('  DELETE /messages            - Clear all messages [AUTH]');
  console.log('');
  console.log('Press CTRL+C to stop');
});

server.on('error', e => {
  if (e.code === 'EADDRINUSE') {
    console.error(`[BRIDGE] ERROR: Port ${PORT} is already in use. Kill the existing process first.`);
  } else {
    console.error(`[BRIDGE] ERROR: ${e.message}`);
  }
  process.exit(1);
});
