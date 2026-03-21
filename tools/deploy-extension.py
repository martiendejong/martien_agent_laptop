"""Deploy browser extension to vault.prospergenics.com"""
import paramiko
import os

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Deploying Browser Extension')
print('='*60)

sftp = c.open_sftp()

# Create extension directory
print('\n1. Creating extension directory...')
try:
    sftp.mkdir('C:/inetpub/vault.prospergenics.com/wwwroot/extension')
except:
    pass  # Directory might already exist
print('   OK')

# Upload extension zip
print('\n2. Uploading extension zip file...')
local_zip = 'E:/projects/passwordmanager/password-manager-extension.zip'
remote_zip = 'C:/inetpub/vault.prospergenics.com/wwwroot/extension/password-manager.zip'

sftp.put(local_zip, remote_zip)
print('   OK Uploaded (64 KB)')

# Create download page
print('\n3. Creating download page...')
download_page = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Download Password Manager Extension</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
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
        h1 { margin: 0 0 10px 0; }
        .download-btn {
            display: inline-block;
            background: #10b981;
            color: white;
            padding: 15px 30px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: bold;
            font-size: 1.1em;
            margin: 20px 0;
            transition: background 0.3s;
        }
        .download-btn:hover {
            background: #059669;
        }
        .steps {
            background: rgba(255,255,255,0.05);
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .step {
            margin: 10px 0;
            padding-left: 30px;
            position: relative;
        }
        .step:before {
            content: "→";
            position: absolute;
            left: 0;
            color: #10b981;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Password Manager Browser Extension</h1>
        <p>Download de browser extensie om je wachtwoorden te beheren</p>

        <a href="/extension/password-manager.zip" class="download-btn" download>
            ⬇️ Download Extension
        </a>

        <div class="steps">
            <h2>Installatie instructies:</h2>

            <h3>Chrome / Edge:</h3>
            <div class="step">Download de zip file</div>
            <div class="step">Pak de zip uit naar een map</div>
            <div class="step">Ga naar chrome://extensions/ (of edge://extensions/)</div>
            <div class="step">Schakel "Developer mode" in (rechts boven)</div>
            <div class="step">Klik op "Load unpacked"</div>
            <div class="step">Selecteer de uitgepakte 'dist' folder</div>

            <h3>Firefox:</h3>
            <div class="step">Download de zip file</div>
            <div class="step">Ga naar about:debugging#/runtime/this-firefox</div>
            <div class="step">Klik "Load Temporary Add-on"</div>
            <div class="step">Selecteer het manifest.json bestand uit de uitgepakte folder</div>
        </div>

        <hr style="border: 1px solid rgba(255,255,255,0.2); margin: 30px 0;">

        <p>
            <strong>API Endpoint:</strong> https://vault.prospergenics.com/api<br>
            <strong>Web Interface:</strong> <a href="/" style="color: #60efff;">vault.prospergenics.com</a>
        </p>
    </div>
</body>
</html>"""

os.makedirs('C:/temp', exist_ok=True)
with open('C:/temp/extension-download.html', 'w', encoding='utf-8') as f:
    f.write(download_page)

sftp.put('C:/temp/extension-download.html', 'C:/inetpub/vault.prospergenics.com/wwwroot/extension/index.html')
print('   OK Created download page')

sftp.close()

print('\n' + '='*60)
print('  EXTENSION DEPLOYED')
print('='*60)
print('\nDownload URL: https://vault.prospergenics.com/extension/')
print('\nDe extensie kan nu gedownload worden!')

c.close()
