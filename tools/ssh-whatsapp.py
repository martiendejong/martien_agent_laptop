#!/usr/bin/env python3
"""SSH utility for WhatsApp Bridge server"""

import paramiko
import sys

# SSH Configuration
SSH_HOST = "85.215.217.154"
SSH_USER = "administrator"
SSH_PASSWORD = "SpaceElevator1tam!"

def execute_ssh_command(command):
    """Execute a command via SSH and return the output"""
    try:
        # Create SSH client
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        # Connect using password
        ssh.connect(SSH_HOST, username=SSH_USER, password=SSH_PASSWORD, timeout=10)

        # Execute command
        stdin, stdout, stderr = ssh.exec_command(command, timeout=15)

        # Get output
        output = stdout.read().decode('utf-8', errors='replace')
        error = stderr.read().decode('utf-8', errors='replace')

        # Close connection
        ssh.close()

        return output, error
    except Exception as e:
        return None, str(e)

def main():
    if len(sys.argv) < 2:
        print("Usage: ssh-whatsapp.py 'command'")
        sys.exit(1)

    command = sys.argv[1]
    output, error = execute_ssh_command(command)

    if output:
        print(output, end='')
    if error:
        print(f"{error}", file=sys.stderr, end='')

    return 0 if not error else 1

if __name__ == "__main__":
    sys.exit(main())
