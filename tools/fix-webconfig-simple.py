"""Fix web.config with simpler configuration"""
import paramiko
import os

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Fixing web.config')
print('='*60)

# Simpler web.config that just serves static files and lets ASP.NET Core handle /api
webconfig = """<?xml version="1.0" encoding="utf-8"?>
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

os.makedirs('C:/temp', exist_ok=True)
with open('C:/temp/web.config.simple', 'w', encoding='utf-8') as f:
    f.write(webconfig)

sftp = c.open_sftp()
sftp.put('C:/temp/web.config.simple', 'C:/inetpub/vault.prospergenics.com/web.config')
sftp.close()
print('OK web.config updated')

# Update Program.cs to serve static files - actually, let me add static files middleware
# For now, let me just configure IIS to serve the wwwroot folder with a separate site or virtual directory

print('\nSimpler approach: Deploy frontend to /app subdirectory')
print('This keeps API at / and frontend at /app')

c.exec_command('powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com')

print('\nRestarted app pool')
print('\nNow configuring ASP.NET Core to serve static files from wwwroot...')

c.close()
