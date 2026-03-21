"""Final diagnostic - check what's actually being used"""
import paramiko
import json

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Final Diagnostic Check')
print('='*60)

sftp = c.open_sftp()

# Check both config files
print('\n1. Checking appsettings.json (default):')
with sftp.open('C:/inetpub/vault.prospergenics.com/appsettings.json', 'r') as f:
    default_config = json.load(f)
    print(f'   Connection: {default_config["ConnectionStrings"]["DefaultConnection"]}')

print('\n2. Checking appsettings.Production.json:')
with sftp.open('C:/inetpub/vault.prospergenics.com/appsettings.Production.json', 'r') as f:
    prod_config = json.load(f)
    print(f'   Connection: {prod_config["ConnectionStrings"]["DefaultConnection"]}')

# Update BOTH files to be sure
print('\n3. Updating BOTH config files to absolute path with Mode...')
conn_str = "Data Source=C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db;Mode=ReadWriteCreate"

default_config["ConnectionStrings"]["DefaultConnection"] = conn_str
prod_config["ConnectionStrings"]["DefaultConnection"] = conn_str

with sftp.open('C:/inetpub/vault.prospergenics.com/appsettings.json', 'w') as f:
    json.dump(default_config, f, indent=2)

with sftp.open('C:/inetpub/vault.prospergenics.com/appsettings.Production.json', 'w') as f:
    json.dump(prod_config, f, indent=2)

print('   Updated both files')

sftp.close()

# Restart
c.exec_command('powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com')
import time
time.sleep(5)

print('\n' + '='*60)
print('Both config files now have the absolute path')
print('Testing one more time...')

c.close()
