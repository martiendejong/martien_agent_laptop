"""Add a landing page to the root URL"""
import paramiko

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Adding landing page to vault.prospergenics.com')
print('='*60)

# Create a simple index.html
landing_page = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prospergenics Vault API</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            padding: 40px;
            backdrop-filter: blur(10px);
        }
        h1 {
            margin: 0 0 10px 0;
            font-size: 2.5em;
        }
        .status {
            background: #10b981;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            display: inline-block;
            margin: 20px 0;
            font-weight: bold;
        }
        .endpoint {
            background: rgba(255,255,255,0.15);
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
            border-left: 4px solid #10b981;
        }
        .method {
            background: #3b82f6;
            color: white;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.8em;
            font-weight: bold;
        }
        a {
            color: #60efff;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Prospergenics Vault</h1>
        <p>Password Manager API</p>

        <div class="status">✓ API is Running</div>

        <h2>Available Endpoints</h2>

        <div class="endpoint">
            <span class="method">POST</span>
            <strong>/api/auth/register</strong><br>
            Register a new user account
        </div>

        <div class="endpoint">
            <span class="method">POST</span>
            <strong>/api/auth/login</strong><br>
            Login to your account
        </div>

        <div class="endpoint">
            <span class="method">GET</span>
            <strong>/api/projects</strong><br>
            List your projects (requires authentication)
        </div>

        <div class="endpoint">
            <span class="method">GET</span>
            <strong>/api/projects/{id}/credentials</strong><br>
            Get project credentials (requires authentication)
        </div>

        <h2>Browser Extension</h2>
        <p>Download the browser extension to manage your passwords:</p>
        <p><a href="/extension/" target="_blank">Download Extension →</a></p>

        <hr style="border: 1px solid rgba(255,255,255,0.2); margin: 30px 0;">

        <p style="font-size: 0.9em; opacity: 0.8;">
            Base URL: <code>https://vault.prospergenics.com</code><br>
            Status: Operational
        </p>
    </div>
</body>
</html>"""

# Upload via SFTP
print('\n1. Creating landing page...')
sftp = c.open_sftp()

import os
os.makedirs('C:/temp', exist_ok=True)
with open('C:/temp/index.html', 'w', encoding='utf-8') as f:
    f.write(landing_page)

sftp.put('C:/temp/index.html', 'C:/inetpub/vault.prospergenics.com/wwwroot/index.html')
sftp.close()
print('   OK Uploaded')

# Enable static files in Program.cs by modifying web.config
print('\n2. Configuring IIS for static files...')

# Update web.config to serve static files
webconfig_with_static = """<?xml version="1.0" encoding="utf-8"?>
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
      <staticContent>
        <mimeMap fileExtension=".html" mimeType="text/html" />
      </staticContent>
      <defaultDocument>
        <files>
          <add value="index.html" />
        </files>
      </defaultDocument>
    </system.webServer>
  </location>
</configuration>"""

with open('C:/temp/web.config.static', 'w', encoding='utf-8') as f:
    f.write(webconfig_with_static)

sftp = c.open_sftp()
sftp.put('C:/temp/web.config.static', 'C:/inetpub/vault.prospergenics.com/web.config')
sftp.close()
print('   OK Updated web.config')

# Restart app pool
print('\n3. Restarting application...')
c.exec_command('powershell Import-Module WebAdministration; Restart-WebAppPool vault.prospergenics.com')
import time
time.sleep(3)
print('   OK Restarted')

print('\n' + '='*60)
print('  LANDING PAGE CREATED')
print('='*60)
print('\nNow test: https://vault.prospergenics.com')
print('You should see a nice landing page instead of 404!')

c.close()
