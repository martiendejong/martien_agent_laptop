"""Fix database permissions after deployment"""
import paramiko

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Fixing database permissions...')

# Grant permissions
cmd = """powershell $path = 'C:\\inetpub\\vault.prospergenics.com\\Data'; $acl = Get-Acl $path; $identity = 'IIS AppPool\\vault.prospergenics.com'; $permission = $identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'; $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission; $acl.SetAccessRule($accessRule); Set-Acl $path $acl; Write-Host 'Done'"""

stdin, stdout, stderr = c.exec_command(cmd)
print(stdout.read().decode('utf-8', errors='ignore'))

# Restart
c.exec_command('powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com')
print('Restarted app pool')

import time
time.sleep(3)
print('Done!')

c.close()
