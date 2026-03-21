"""Update connection string with Mode=ReadWriteCreate"""
import paramiko
import json
import time

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Updating Connection String with Mode Parameter')
print('='*60)

sftp = c.open_sftp()

# Read current config
print('\n1. Reading current configuration...')
with sftp.open('C:/inetpub/vault.prospergenics.com/appsettings.Production.json', 'r') as f:
    config = json.load(f)

print(f'   Current: {config["ConnectionStrings"]["DefaultConnection"]}')

# Update with Mode parameter
print('\n2. Adding Mode=ReadWriteCreate...')
config["ConnectionStrings"]["DefaultConnection"] = "Data Source=C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db;Mode=ReadWriteCreate"

# Write back
with sftp.open('C:/inetpub/vault.prospergenics.com/appsettings.Production.json', 'w') as f:
    json.dump(config, f, indent=2)

print(f'   Updated: {config["ConnectionStrings"]["DefaultConnection"]}')

sftp.close()

# Restart app pool
print('\n3. Restarting application pool...')
c.exec_command('powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com')
time.sleep(5)
print('   Restarted')

print('\n' + '='*60)
print('Connection string updated with explicit Mode parameter')
print('This tells SQLite to create the database if needed and open in ReadWrite mode')
print('\nTest now!')

c.close()
