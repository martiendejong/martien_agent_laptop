#!/usr/bin/env python3
"""
Universal Google Drive tool with OAuth, upload, download, search, list
"""

import os
import sys
import json
import time
import argparse
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs, urlencode
import requests

CREDENTIALS_PATH = r"C:\scripts\_machine\gdrive-full-credentials.json"
CLIENT_SECRET_PATH = r"C:\Users\HP\Downloads\client_secret_856798693858-fh1s1fu0uj58vpluo6j13c4ioprptfgl.apps.googleusercontent.com.json"

class OAuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        query = urlparse(self.path).query
        params = parse_qs(query)

        if 'code' in params:
            self.server.auth_code = params['code'][0]

            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'<html><body><h1>Authorization successful!</h1><p>You can close this window.</p></body></html>')
        else:
            self.send_response(400)
            self.end_headers()

    def log_message(self, format, *args):
        pass  # Suppress logs

def load_client_config():
    with open(CLIENT_SECRET_PATH, 'r') as f:
        config = json.load(f)
    return config['web']

def get_access_token():
    if not os.path.exists(CREDENTIALS_PATH):
        print("No credentials found. Run: python gdrive.py auth")
        sys.exit(1)

    with open(CREDENTIALS_PATH, 'r') as f:
        creds = json.load(f)

    # Check if expired
    now = int(time.time() * 1000)
    if creds['expiry_date'] < now:
        print("Token expired, refreshing...")
        client_config = load_client_config()

        response = requests.post('https://oauth2.googleapis.com/token', data={
            'client_id': client_config['client_id'],
            'client_secret': client_config['client_secret'],
            'refresh_token': creds['refresh_token'],
            'grant_type': 'refresh_token'
        })

        token_data = response.json()
        creds['access_token'] = token_data['access_token']
        creds['expiry_date'] = now + (token_data['expires_in'] * 1000)

        with open(CREDENTIALS_PATH, 'w') as f:
            json.dump(creds, f)

        print("Token refreshed")

    return creds['access_token']

def do_auth():
    client_config = load_client_config()

    redirect_uri = 'http://localhost:8080'
    scope = 'https://www.googleapis.com/auth/drive'

    auth_url = f"https://accounts.google.com/o/oauth2/auth?{urlencode({
        'client_id': client_config['client_id'],
        'redirect_uri': redirect_uri,
        'scope': scope,
        'response_type': 'code',
        'access_type': 'offline',
        'prompt': 'consent'
    })}"

    print("Opening browser for authorization...")
    print(f"If browser doesn't open, go to: {auth_url}")
    webbrowser.open(auth_url)

    # Start local server
    server = HTTPServer(('localhost', 8080), OAuthHandler)
    server.auth_code = None

    print("Waiting for authorization...")
    while server.auth_code is None:
        server.handle_request()

    code = server.auth_code

    # Exchange code for tokens
    print("Exchanging code for tokens...")
    response = requests.post('https://oauth2.googleapis.com/token', data={
        'code': code,
        'client_id': client_config['client_id'],
        'client_secret': client_config['client_secret'],
        'redirect_uri': redirect_uri,
        'grant_type': 'authorization_code'
    })

    token_data = response.json()

    # Save credentials
    now = int(time.time() * 1000)
    credentials = {
        'access_token': token_data['access_token'],
        'refresh_token': token_data['refresh_token'],
        'scope': token_data['scope'],
        'token_type': token_data['token_type'],
        'expiry_date': now + (token_data['expires_in'] * 1000)
    }

    with open(CREDENTIALS_PATH, 'w') as f:
        json.dump(credentials, f)

    print("Authentication successful! Credentials saved.")

def find_folder(name):
    token = get_access_token()
    headers = {'Authorization': f'Bearer {token}'}

    params = {
        'q': f"name='{name}' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        'fields': 'files(id,name,parents)'
    }

    response = requests.get('https://www.googleapis.com/drive/v3/files', headers=headers, params=params)
    data = response.json()

    if data.get('files'):
        return data['files'][0]
    return None

def list_files(folder_id=None):
    token = get_access_token()
    headers = {'Authorization': f'Bearer {token}'}

    query = f"'{folder_id}' in parents and trashed=false" if folder_id else "trashed=false"

    params = {
        'q': query,
        'fields': 'files(id,name,mimeType,size,modifiedTime)',
        'pageSize': 100
    }

    response = requests.get('https://www.googleapis.com/drive/v3/files', headers=headers, params=params)
    return response.json().get('files', [])

def upload_file(local_path, folder_id=None):
    if not os.path.exists(local_path):
        print(f"File not found: {local_path}")
        sys.exit(1)

    token = get_access_token()
    headers = {'Authorization': f'Bearer {token}'}

    file_name = os.path.basename(local_path)

    # Metadata
    metadata = {'name': file_name}
    if folder_id:
        metadata['parents'] = [folder_id]

    # Upload using multipart
    files = {
        'data': ('metadata', json.dumps(metadata), 'application/json; charset=UTF-8'),
        'file': (file_name, open(local_path, 'rb'))
    }

    response = requests.post(
        'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
        headers=headers,
        files=files
    )

    return response.json()

def search_files(query):
    token = get_access_token()
    headers = {'Authorization': f'Bearer {token}'}

    params = {
        'q': f"fullText contains '{query}' and trashed=false",
        'fields': 'files(id,name,mimeType,parents,webViewLink)',
        'pageSize': 100
    }

    response = requests.get('https://www.googleapis.com/drive/v3/files', headers=headers, params=params)
    return response.json().get('files', [])

def main():
    parser = argparse.ArgumentParser(description='Google Drive CLI tool')
    parser.add_argument('action', choices=['auth', 'upload', 'list', 'search', 'find-folder'])
    parser.add_argument('--file', help='Local file path')
    parser.add_argument('--folder', help='Google Drive folder name')
    parser.add_argument('--query', help='Search query')

    args = parser.parse_args()

    if args.action == 'auth':
        do_auth()

    elif args.action == 'find-folder':
        folder = find_folder(args.folder)
        if folder:
            print(f"Folder found: {folder['name']}")
            print(f"ID: {folder['id']}")
        else:
            print(f"Folder not found: {args.folder}")

    elif args.action == 'upload':
        if not args.file:
            print("--file required")
            sys.exit(1)

        folder_id = None
        if args.folder:
            print(f"Finding folder: {args.folder}")
            folder = find_folder(args.folder)
            if not folder:
                print(f"Folder not found: {args.folder}")
                sys.exit(1)
            folder_id = folder['id']
            print(f"Folder found: {folder['name']}")

        print(f"Uploading: {os.path.basename(args.file)}")
        result = upload_file(args.file, folder_id)
        print("Upload successful!")
        print(f"File ID: {result['id']}")
        print(f"Link: https://drive.google.com/file/d/{result['id']}/view")

    elif args.action == 'list':
        folder_id = None
        if args.folder:
            folder = find_folder(args.folder)
            if not folder:
                print(f"Folder not found: {args.folder}")
                sys.exit(1)
            folder_id = folder['id']
            print(f"Listing files in: {folder['name']}")
        else:
            print("Listing all files")

        files = list_files(folder_id)

        if not files:
            print("No files found")
        else:
            print(f"\n{len(files)} files found:")
            for f in files:
                size_kb = int(f.get('size', 0)) / 1024 if f.get('size') else 0
                print(f"  {f['name']} ({size_kb:.2f} KB)")

    elif args.action == 'search':
        if not args.query:
            print("--query required")
            sys.exit(1)

        print(f"Searching for: {args.query}")
        files = search_files(args.query)

        if not files:
            print("No files found")
        else:
            print(f"\n{len(files)} files found:")
            for f in files:
                print(f"\n  {f['name']}")
                print(f"  Link: {f.get('webViewLink', 'N/A')}")
                print(f"  ID: {f['id']}")

if __name__ == '__main__':
    main()
