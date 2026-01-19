#!/usr/bin/env python3
"""Create hazinastore.config.json on remote server"""

import paramiko
import json

# SSH Configuration
SSH_HOST = "85.215.217.154"
SSH_USER = "administrator"
SSH_PASSWORD = "3WsXcFr$7YhNmKi*"

# Hazinastore config
config = {
    "ApiSettings": {
        "SignalRHubCorsOrigin": "https://app.brand2boost.com",
        "ApiCorsOrigin": "https://app.brand2boost.com",
        "OpenApiKey": "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",
        "GeminiApiKey": ""
    }
}

def create_config_file():
    """Create hazinastore.config.json on remote server"""
    try:
        # Create SSH client
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(SSH_HOST, username=SSH_USER, password=SSH_PASSWORD)

        # Create config content
        config_json = json.dumps(config, indent=2)

        # Write file using PowerShell
        command = f'''powershell -Command "@'
{config_json}
'@ | Out-File -FilePath 'C:\\stores\\brand2boost\\hazinastore.config.json' -Encoding UTF8"'''

        stdin, stdout, stderr = ssh.exec_command(command)
        output = stdout.read().decode('utf-8')
        error = stderr.read().decode('utf-8')

        # Restart the website
        restart_cmd = "powershell -Command \"Import-Module WebAdministration; Stop-Website Brand2boostAPI; Start-Sleep -Seconds 2; Start-Website Brand2boostAPI\""
        stdin, stdout, stderr = ssh.exec_command(restart_cmd)
        restart_output = stdout.read().decode('utf-8')
        restart_error = stderr.read().decode('utf-8')

        ssh.close()

        print("Created hazinastore.config.json")
        print("Restarted Brand2boostAPI")

        if error:
            print(f"Config creation error: {error}")
        if restart_error:
            print(f"Restart error: {restart_error}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    create_config_file()
