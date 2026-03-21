"""Complete database permissions fix"""
import paramiko
import time

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Fixing Database Permissions Completely')
print('='*60)

# Check if Data directory and database exist
print('\n1. Checking files...')
stdin, stdout, stderr = c.exec_command('powershell Test-Path C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db')
db_exists = stdout.read().decode().strip()
print(f'   Database exists: {db_exists}')

# Grant full permissions using icacls (more reliable than PowerShell ACL)
print('\n2. Granting permissions with icacls...')

cmds = [
    'icacls C:\\inetpub\\vault.prospergenics.com\\Data /grant "IIS AppPool\\vault.prospergenics.com:(OI)(CI)F" /T',
]

if db_exists.lower() == 'true':
    cmds.append('icacls C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db /grant "IIS AppPool\\vault.prospergenics.com:F"')

for cmd in cmds:
    print(f'   Running: {cmd[:80]}...')
    stdin, stdout, stderr = c.exec_command(cmd)
    output = stdout.read().decode('utf-8', errors='ignore')
    if 'Successfully processed' in output:
        print('   OK')
    else:
        print(f'   Output: {output[:200]}')

# Verify permissions
print('\n3. Verifying permissions...')
stdin, stdout, stderr = c.exec_command('icacls C:\\inetpub\\vault.prospergenics.com\\Data')
perms = stdout.read().decode('utf-8', errors='ignore')
if 'vault.prospergenics.com' in perms and '(F)' in perms:
    print('   OK Full Control granted')
else:
    print(f'   Permissions: {perms[:300]}')

# Restart app pool
print('\n4. Restarting application...')
c.exec_command('powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com')
time.sleep(5)
print('   OK Restarted')

print('\n' + '='*60)
print('Done - Test now: https://vault.prospergenics.com')

c.close()
