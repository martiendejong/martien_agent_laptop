"""Deploy frontend to vault.prospergenics.com"""
import paramiko
import os

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Deploying Frontend to vault.prospergenics.com')
print('='*60)

# Create wwwroot directory
print('\n1. Creating wwwroot directory...')
c.exec_command('powershell New-Item -ItemType Directory -Force -Path C:\\inetpub\\vault.prospergenics.com\\wwwroot')
print('   OK Created')

# Upload frontend files via SFTP
print('\n2. Uploading frontend files...')
sftp = c.open_sftp()

local_dist = 'E:/projects/passwordmanager/frontend/dist'
remote_wwwroot = 'C:/inetpub/vault.prospergenics.com/wwwroot'

# Get all files from dist
import glob
files_to_upload = []

# Walk through dist directory
for root, dirs, files in os.walk(local_dist):
    for file in files:
        local_path = os.path.join(root, file)
        # Calculate relative path
        rel_path = os.path.relpath(local_path, local_dist)
        remote_path = os.path.join(remote_wwwroot, rel_path).replace('\\', '/')
        files_to_upload.append((local_path, remote_path, rel_path))

print(f'   Found {len(files_to_upload)} files to upload')

# Create directories and upload files
uploaded = 0
for local_path, remote_path, rel_path in files_to_upload:
    try:
        # Create remote directory if needed
        remote_dir = os.path.dirname(remote_path).replace('\\', '/')
        try:
            sftp.stat(remote_dir)
        except:
            # Directory doesn't exist, create it
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

        # Upload file
        sftp.put(local_path, remote_path)
        uploaded += 1
        if uploaded % 5 == 0 or uploaded == len(files_to_upload):
            print(f'   Uploaded {uploaded}/{len(files_to_upload)} files...')
    except Exception as e:
        print(f'   Error uploading {rel_path}: {e}')

sftp.close()
print(f'   OK Uploaded {uploaded} files')

# Update web.config to serve static files and route /api to ASP.NET Core
print('\n3. Updating web.config for frontend + API...')

webconfig = """<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <!-- Serve static files for frontend -->
        <add name="StaticFile" path="*" verb="*" modules="StaticFileModule,DefaultDocumentModule,DirectoryListingModule" resourceType="Either" requireAccess="Read" />
        <!-- Route /api to ASP.NET Core -->
        <add name="aspNetCore" path="api/*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="dotnet" arguments=".\\PasswordManager.API.dll" stdoutLogEnabled="true" stdoutLogFile=".\\logs\\stdout" hostingModel="inprocess">
        <environmentVariables>
          <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Production" />
        </environmentVariables>
      </aspNetCore>
      <rewrite>
        <rules>
          <!-- Serve index.html for SPA routes -->
          <rule name="React Routes" stopProcessing="true">
            <match url=".*" />
            <conditions logicalGrouping="MatchAll">
              <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
              <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
              <add input="{REQUEST_URI}" pattern="^/api" negate="true" />
            </conditions>
            <action type="Rewrite" url="/wwwroot/index.html" />
          </rule>
        </rules>
      </rewrite>
      <staticContent>
        <mimeMap fileExtension=".js" mimeType="application/javascript" />
        <mimeMap fileExtension=".css" mimeType="text/css" />
        <mimeMap fileExtension=".svg" mimeType="image/svg+xml" />
      </staticContent>
      <defaultDocument>
        <files>
          <add value="index.html" />
        </files>
      </defaultDocument>
    </system.webServer>
  </location>
</configuration>"""

os.makedirs('C:/temp', exist_ok=True)
with open('C:/temp/web.config.frontend', 'w', encoding='utf-8') as f:
    f.write(webconfig)

sftp = c.open_sftp()
sftp.put('C:/temp/web.config.frontend', 'C:/inetpub/vault.prospergenics.com/web.config')
sftp.close()
print('   OK Updated')

# Restart app pool
print('\n4. Restarting application pool...')
c.exec_command('powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com')
import time
time.sleep(3)
print('   OK Restarted')

print('\n' + '='*60)
print('  FRONTEND DEPLOYED')
print('='*60)
print('\nTest now: https://vault.prospergenics.com')
print('You should see the Password Manager login page!')

c.close()
