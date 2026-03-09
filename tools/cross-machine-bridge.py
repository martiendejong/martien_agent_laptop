#!/usr/bin/env python3
"""
Cross-Machine Bridge Server - Jengo Agent Messaging
Listens on 0.0.0.0:9998 for cross-machine communication via Tailscale VPN.
Requires X-Auth-Token header for mutating operations.
Auth token loaded from C:\scripts\_machine\bridge-auth.token at startup.
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import datetime
import os
import socket
import time

# --- Config ---
CONFIG_PATH = r'C:\scripts\_machine\cross-machine-config.json'
TOKEN_PATH = r'C:\scripts\_machine\bridge-auth.token'

messages = []
message_id = 0
start_time = time.time()
auth_token = None
machine_name = "unknown"
machine_ip = "unknown"

def load_config():
    global machine_name, machine_ip
    try:
        with open(CONFIG_PATH, 'r') as f:
            config = json.load(f)
        this = config.get('this_machine', 'unknown')
        machine_name = this
        machines = config.get('machines', {})
        if this in machines:
            machine_ip = machines[this].get('tailscale_ip', 'unknown')
    except Exception as e:
        print(f'[BRIDGE] Warning: Could not load config: {e}')

def load_auth_token():
    global auth_token
    try:
        with open(TOKEN_PATH, 'r') as f:
            auth_token = f.read().strip()
        print(f'[BRIDGE] Auth token loaded from {TOKEN_PATH}')
    except FileNotFoundError:
        print(f'[BRIDGE] WARNING: No auth token file at {TOKEN_PATH}')
        print('[BRIDGE] POST/DELETE endpoints will be UNPROTECTED until token is set.')
        auth_token = None
    except Exception as e:
        print(f'[BRIDGE] ERROR loading auth token: {e}')
        auth_token = None


class BridgeHandler(BaseHTTPRequestHandler):

    def _check_auth(self):
        """Returns True if request is authorized."""
        if auth_token is None:
            return True  # No token configured - open (warn at startup)
        provided = self.headers.get('X-Auth-Token', '')
        return provided == auth_token

    def _set_headers(self, status=200, content_type='application/json'):
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, X-Auth-Token')
        self.send_header('X-Machine', machine_name)
        self.end_headers()

    def _send_json(self, data, status=200):
        self._set_headers(status)
        self.wfile.write(json.dumps(data).encode())

    def _log_connection(self, method, path, status):
        client_ip = self.client_address[0]
        ts = datetime.datetime.now().strftime('%H:%M:%S')
        print(f'[{ts}] {client_ip} {method} {path} -> {status}')

    def do_OPTIONS(self):
        self._set_headers(204)

    def do_GET(self):
        from urllib.parse import urlparse, parse_qs
        parsed = urlparse(self.path)
        path = parsed.path
        query = parse_qs(parsed.query)

        if path == '/health':
            uptime_s = int(time.time() - start_time)
            data = {
                'status': 'healthy',
                'machine': machine_name,
                'tailscale_ip': machine_ip,
                'uptime_seconds': uptime_s,
                'messageCount': len(messages),
                'unreadCount': len([m for m in messages if m['status'] == 'unread'])
            }
            self._send_json(data)
            self._log_connection('GET', path, 200)

        elif path == '/identity':
            uptime_s = int(time.time() - start_time)
            data = {
                'machine': machine_name,
                'tailscale_ip': machine_ip,
                'hostname': socket.gethostname(),
                'uptime_seconds': uptime_s,
                'bridge_version': '2.0.0',
                'started_at': datetime.datetime.utcfromtimestamp(start_time).isoformat() + 'Z'
            }
            self._send_json(data)
            self._log_connection('GET', path, 200)

        elif path == '/messages':
            filtered = messages
            if 'from' in query:
                filtered = [m for m in filtered if m['from'] == query['from'][0]]
            if 'to' in query:
                filtered = [m for m in filtered if m['to'] == query['to'][0]]
            if 'status' in query:
                filtered = [m for m in filtered if m['status'] == query['status'][0]]

            self._send_json({'messages': filtered, 'total': len(filtered)})
            self._log_connection('GET', path, 200)

        elif path == '/messages/unread':
            to_filter = query.get('to', [None])[0]
            from_filter = query.get('from', [None])[0]
            unread = [m for m in messages if m['status'] == 'unread']
            if to_filter:
                unread = [m for m in unread if m['to'] == to_filter]
            if from_filter:
                unread = [m for m in unread if m['from'] == from_filter]

            self._send_json({'messages': unread, 'count': len(unread)})
            self._log_connection('GET', path, 200)

        elif path.startswith('/messages/'):
            try:
                msg_id = int(path.split('/')[-1])
                msg = next((m for m in messages if m['id'] == msg_id), None)
                if msg:
                    self._send_json(msg)
                    self._log_connection('GET', path, 200)
                else:
                    self._send_json({'error': 'Message not found'}, 404)
                    self._log_connection('GET', path, 404)
            except ValueError:
                self._send_json({'error': 'Invalid message ID'}, 400)
                self._log_connection('GET', path, 400)

        else:
            self._send_json({'error': 'Not found'}, 404)
            self._log_connection('GET', path, 404)

    def do_POST(self):
        global message_id

        if not self._check_auth():
            self._send_json({'error': 'Unauthorized - missing or invalid X-Auth-Token'}, 401)
            self._log_connection('POST', self.path, 401)
            return

        from urllib.parse import urlparse
        parsed = urlparse(self.path)
        path = parsed.path

        try:
            content_length = int(self.headers.get('Content-Length', 0))
            body = json.loads(self.rfile.read(content_length).decode()) if content_length > 0 else {}
        except (json.JSONDecodeError, ValueError) as e:
            self._send_json({'error': f'Invalid JSON: {e}'}, 400)
            self._log_connection('POST', path, 400)
            return

        if path == '/messages':
            if not all(k in body for k in ['from', 'to', 'content']):
                self._send_json({'error': 'Missing required fields: from, to, content'}, 400)
                self._log_connection('POST', path, 400)
                return

            message_id += 1
            source_ip = self.client_address[0]
            message = {
                'id': message_id,
                'from': body['from'],
                'to': body['to'],
                'content': body['content'],
                'type': body.get('type', 'text'),
                'status': 'unread',
                'timestamp': datetime.datetime.utcnow().isoformat() + 'Z',
                'source_ip': source_ip
            }
            messages.append(message)

            ts = datetime.datetime.now().strftime('%H:%M:%S')
            print(f'[{ts}] MSG #{message["id"]}: {body["from"]} -> {body["to"]} ({source_ip}): {body["content"][:60]}')

            self._send_json({'success': True, 'message': message}, 201)
            self._log_connection('POST', path, 201)

        elif path.endswith('/read'):
            try:
                parts = path.split('/')
                msg_id = int(parts[-2])
                msg = next((m for m in messages if m['id'] == msg_id), None)
                if msg:
                    msg['status'] = 'read'
                    msg['readAt'] = datetime.datetime.utcnow().isoformat() + 'Z'
                    self._send_json({'success': True, 'message': msg})
                    self._log_connection('POST', path, 200)
                else:
                    self._send_json({'error': 'Message not found'}, 404)
                    self._log_connection('POST', path, 404)
            except (ValueError, IndexError):
                self._send_json({'error': 'Invalid path'}, 400)
                self._log_connection('POST', path, 400)

        elif path == '/messages/read-all':
            count = 0
            for m in messages:
                if m['status'] == 'unread':
                    m['status'] = 'read'
                    m['readAt'] = datetime.datetime.utcnow().isoformat() + 'Z'
                    count += 1
            self._send_json({'success': True, 'marked': count})
            self._log_connection('POST', path, 200)

        else:
            self._send_json({'error': 'Not found'}, 404)
            self._log_connection('POST', path, 404)

    def do_DELETE(self):
        if not self._check_auth():
            self._send_json({'error': 'Unauthorized - missing or invalid X-Auth-Token'}, 401)
            self._log_connection('DELETE', self.path, 401)
            return

        global messages
        from urllib.parse import urlparse
        parsed = urlparse(self.path)
        path = parsed.path

        if path == '/messages':
            count = len(messages)
            messages = []
            self._send_json({'success': True, 'deleted': count})
            self._log_connection('DELETE', path, 200)

        elif path.startswith('/messages/'):
            try:
                msg_id = int(path.split('/')[-1])
                before = len(messages)
                messages = [m for m in messages if m['id'] != msg_id]
                if len(messages) < before:
                    self._send_json({'success': True})
                    self._log_connection('DELETE', path, 200)
                else:
                    self._send_json({'error': 'Message not found'}, 404)
                    self._log_connection('DELETE', path, 404)
            except ValueError:
                self._send_json({'error': 'Invalid message ID'}, 400)
                self._log_connection('DELETE', path, 400)

        else:
            self._send_json({'error': 'Not found'}, 404)
            self._log_connection('DELETE', path, 404)

    def log_message(self, format, *args):
        pass  # Suppress default httpd logging - we handle it ourselves


def run(port=9998):
    load_config()
    load_auth_token()

    server = HTTPServer(('0.0.0.0', port), BridgeHandler)

    print(f'[BRIDGE] Cross-Machine Jengo Bridge v2.0 started')
    print(f'[BRIDGE] Machine: {machine_name} ({machine_ip})')
    print(f'[BRIDGE] Listening on 0.0.0.0:{port} (all interfaces)')
    print(f'[BRIDGE] Auth: {"ENABLED" if auth_token else "DISABLED (no token file)"}')
    print()
    print('Endpoints:')
    print('  GET    /health              - Health check (public)')
    print('  GET    /identity            - Machine identity (public)')
    print('  GET    /messages            - Get all messages')
    print('  GET    /messages/unread     - Get unread messages')
    print('  GET    /messages/:id        - Get specific message')
    print('  POST   /messages            - Send a message [AUTH]')
    print('  POST   /messages/:id/read   - Mark message as read [AUTH]')
    print('  POST   /messages/read-all   - Mark all as read [AUTH]')
    print('  DELETE /messages/:id        - Delete message [AUTH]')
    print('  DELETE /messages            - Clear all messages [AUTH]')
    print()
    print('Press CTRL+C to stop')
    print()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n[BRIDGE] Server stopped')
        server.shutdown()


if __name__ == '__main__':
    import sys
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 9998
    run(port)
