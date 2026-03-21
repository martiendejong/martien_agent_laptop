"""Deploy complete Password Manager (backend + frontend)"""
import paramiko
import os
import glob

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Deploying Complete Password Manager')
print('='*60)

sftp = c.open_sftp()

# Step 1: Stop app pool
print('\n1. Stopping application pool...')
c.exec_command('powershell Import-Module WebAdministration; Stop-WebAppPool vault.prospergenics.com')
import time
time.sleep(3)
print('   OK Stopped')

# Step 2: Deploy backend
print('\n2. Deploying backend...')
local_backend = 'E:/projects/passwordmanager/backend/PasswordManager.API/publish'
remote_site = 'C:/inetpub/vault.prospergenics.com'

backend_files = []
for root, dirs, files in os.walk(local_backend):
    for file in files:
        local_path = os.path.join(root, file)
        rel_path = os.path.relpath(local_path, local_backend)
        remote_path = os.path.join(remote_site, rel_path).replace('\\', '/')
        backend_files.append((local_path, remote_path, rel_path))

print(f'   Uploading {len(backend_files)} backend files...')
uploaded = 0
for local_path, remote_path, rel_path in backend_files:
    try:
        # Create directory if needed
        remote_dir = os.path.dirname(remote_path).replace('\\', '/')
        try:
            sftp.stat(remote_dir)
        except:
            parts = remote_dir.split('/')
            current = ''
            for part in parts:
                if not part:
                    continue
                current = current + '/' + part if current else part
                try:
                    sftp.stat(current)
                except:
                    sftp.mkdir(current)

        sftp.put(local_path, remote_path)
        uploaded += 1
        if uploaded % 50 == 0:
            print(f'   {uploaded}/{len(backend_files)}...')
    except Exception as e:
        if 'appsettings.Production.json' not in rel_path:  # Don't overwrite production config
            print(f'   Error: {rel_path}: {e}')

print(f'   OK Uploaded {uploaded} files')

# Step 3: Deploy frontend to wwwroot
print('\n3. Deploying frontend to wwwroot...')

# Create wwwroot
try:
    sftp.stat(f'{remote_site}/wwwroot')
except:
    sftp.mkdir(f'{remote_site}/wwwroot')

local_frontend = 'E:/projects/passwordmanager/frontend/dist'
remote_wwwroot = f'{remote_site}/wwwroot'

frontend_files = []
for root, dirs, files in os.walk(local_frontend):
    for file in files:
        local_path = os.path.join(root, file)
        rel_path = os.path.relpath(local_path, local_frontend)
        remote_path = os.path.join(remote_wwwroot, rel_path).replace('\\', '/')
        frontend_files.append((local_path, remote_path, rel_path))

print(f'   Uploading {len(frontend_files)} frontend files...')
uploaded = 0
for local_path, remote_path, rel_path in frontend_files:
    try:
        remote_dir = os.path.dirname(remote_path).replace('\\', '/')
        try:
            sftp.stat(remote_dir)
        except:
            parts = remote_dir.split('/')
            current = ''
            for part in parts:
                if not part:
                    continue
                current = current + '/' + part if current else part
                try:
                    sftp.stat(current)
                except:
                    sftp.mkdir(current)

        sftp.put(local_path, remote_path)
        uploaded += 1
    except Exception as e:
        print(f'   Error: {rel_path}: {e}')

print(f'   OK Uploaded {uploaded} files')

sftp.close()

# Step 4: Start app pool
print('\n4. Starting application pool...')
c.exec_command('powershell Import-Module WebAdministration; Start-WebAppPool vault.prospergenics.com')
time.sleep(5)
print('   OK Started')

print('\n' + '='*60)
print('  DEPLOYMENT COMPLETE')
print('='*60)
print('\n✅ Backend API: https://vault.prospergenics.com/api')
print('✅ Frontend Web App: https://vault.prospergenics.com')
print('\nTest it now!')

c.close()
