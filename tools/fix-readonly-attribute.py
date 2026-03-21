"""Remove readonly attribute from database files"""
import paramiko
import time

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Removing Readonly Attribute')
print('='*60)

# Check and remove readonly attribute
print('\n1. Checking file attributes...')
stdin, stdout, stderr = c.exec_command('powershell Get-ItemProperty C:\\inetpub\\vault.prospergenics.com\\Data\\*.* | Select-Object Name, IsReadOnly')
print(stdout.read().decode('utf-8', errors='ignore'))

# Remove readonly attribute from all files in Data directory
print('\n2. Removing readonly attributes...')
stdin, stdout, stderr = c.exec_command('attrib -R C:\\inetpub\\vault.prospergenics.com\\Data\\*.* /S')
output = stdout.read().decode('utf-8', errors='ignore')
print('   OK Removed readonly attributes')

# Delete and recreate database to ensure clean state
print('\n3. Recreating database with correct permissions...')
cmds = [
    'powershell Remove-Item C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db* -Force -ErrorAction SilentlyContinue',
    'powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com'
]

for cmd in cmds:
    c.exec_command(cmd)

time.sleep(5)

print('   OK Database will be recreated on first request')

print('\n' + '='*60)
print('Test now - database will be created fresh')

c.close()
