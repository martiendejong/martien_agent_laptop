"""Enable stdout logging and check errors"""
import paramiko
import time

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Enabling stdout logging...')
print('='*60)

# Create logs directory
print('\n1. Creating logs directory:')
stdin, stdout, stderr = client.exec_command('powershell New-Item -ItemType Directory -Force -Path C:\\inetpub\\vault.prospergenics.com\\logs')
print('   OK Created')

# Update web.config to enable logging
webconfig_with_logging = """<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="dotnet" arguments=".\\PasswordManager.API.dll" stdoutLogEnabled="true" stdoutLogFile=".\\logs\\stdout" hostingModel="inprocess">
        <environmentVariables>
          <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Production" />
        </environmentVariables>
      </aspNetCore>
    </system.webServer>
  </location>
</configuration>"""

print('\n2. Updating web.config to enable logging:')
# Use SFTP
sftp = client.open_sftp()

import os
os.makedirs('C:/temp', exist_ok=True)
with open('C:/temp/web.config.logging', 'w', encoding='utf-8') as f:
    f.write(webconfig_with_logging)

sftp.put('C:/temp/web.config.logging', 'C:/inetpub/vault.prospergenics.com/web.config')
sftp.close()
print('   OK Updated')

# Restart app pool
print('\n3. Restarting application pool:')
stdin, stdout, stderr = client.exec_command('powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com')
print('   OK Restarted')

print('\n4. Waiting 3 seconds for app to start...')
time.sleep(3)

# Try to access the site to generate logs
print('\n5. Triggering site access to generate logs:')
stdin, stdout, stderr = client.exec_command('powershell try { Invoke-WebRequest -Uri http://localhost -UseBasicParsing | Out-Null } catch { }')
time.sleep(2)

# Check logs
print('\n6. Checking stdout logs:')
stdin, stdout, stderr = client.exec_command('powershell Get-ChildItem C:\\inetpub\\vault.prospergenics.com\\logs -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content')
logs = stdout.read().decode('utf-8', errors='ignore')

if logs:
    print('='*60)
    print('LOG CONTENT:')
    print('='*60)
    print(logs)
    print('='*60)
else:
    print('   No logs found yet')

# Check Windows Event Log for ASP.NET Core errors
print('\n7. Checking Windows Event Log for ASP.NET Core errors:')
stdin, stdout, stderr = client.exec_command('powershell Get-EventLog -LogName Application -Source "IIS AspNetCore Module*" -Newest 5 -ErrorAction SilentlyContinue | Select-Object TimeGenerated, Message | Format-List')
event_logs = stdout.read().decode('utf-8', errors='ignore')

if event_logs:
    print(event_logs)
else:
    print('   No recent ASP.NET Core errors in Event Log')

client.close()
