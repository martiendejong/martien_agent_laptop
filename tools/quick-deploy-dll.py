"""Quick deploy just the DLL with CORS fix"""
import paramiko
import time

print('Quick CORS Fix Deployment')
print('='*60)

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
print('Connecting...')
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')
print('Connected')

# Stop app pool
print('\nStopping app pool...')
stdin, stdout, stderr = c.exec_command('powershell Stop-WebAppPool vault.prospergenics.com')
stdout.read()  # Wait for command
time.sleep(2)
print('Stopped')

# Upload DLL
print('\nUploading DLL...')
sftp = c.open_sftp()
sftp.put('E:/projects/passwordmanager/backend/PasswordManager.API/publish/PasswordManager.API.dll',
         'C:/inetpub/vault.prospergenics.com/PasswordManager.API.dll')
print('Uploaded')
sftp.close()

# Start app pool
print('\nStarting app pool...')
stdin, stdout, stderr = c.exec_command('powershell Start-WebAppPool vault.prospergenics.com')
stdout.read()  # Wait for command
time.sleep(3)
print('Started')

c.close()

print('\n' + '='*60)
print('CORS fix deployed!')
print('Test the extension now')
