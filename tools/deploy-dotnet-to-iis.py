#!/usr/bin/env python3
r"""
Generic .NET application deployment to IIS via SSH
Builds locally (if source path provided) or remotely, then deploys to IIS

MODES:
1. Config-based: python deploy-dotnet-to-iis.py <project-name>
   Reads from C:\scripts\_machine\PROJECT_MASTER_MAP.md

2. Manual: python deploy-dotnet-to-iis.py <source> <remote> <app-pool>
   Direct parameter control
"""

import paramiko
import sys
import os
import subprocess
import re
from pathlib import Path

# Default SSH Configuration (can be overridden by config)
DEFAULT_SSH_HOST = "85.215.217.154"
DEFAULT_SSH_USER = "administrator"
DEFAULT_SSH_PASSWORD = "SpaceElevator1tam!"

PROJECT_MASTER_MAP = r"C:\scripts\_machine\PROJECT_MASTER_MAP.md"

def parse_project_config(project_name):
    """Parse PROJECT_MASTER_MAP.md for deployment configuration"""
    if not os.path.exists(PROJECT_MASTER_MAP):
        print(f"[ERROR] PROJECT_MASTER_MAP.md not found: {PROJECT_MASTER_MAP}")
        return None

    with open(PROJECT_MASTER_MAP, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find project section (case-insensitive)
    pattern = rf"###\s+([^\n]+{re.escape(project_name)}[^\n]*)"
    match = re.search(pattern, content, re.IGNORECASE)

    if not match:
        print(f"[ERROR] Project '{project_name}' not found in PROJECT_MASTER_MAP.md")
        print("\nAvailable projects:")
        # Show available projects
        projects = re.findall(r"###\s+(.+)", content)
        for p in projects[:20]:  # Show first 20
            print(f"  - {p}")
        return None

    # Extract section content (from ### to next ### or end)
    start_pos = match.start()
    next_section = re.search(r"\n###\s+", content[start_pos + 4:])
    if next_section:
        section = content[start_pos:start_pos + 4 + next_section.start()]
    else:
        section = content[start_pos:]

    # Extract deployment configuration
    config = {
        'project_name': match.group(1).strip(),
        'ssh_host': DEFAULT_SSH_HOST,
        'ssh_user': DEFAULT_SSH_USER,
        'ssh_password': DEFAULT_SSH_PASSWORD
    }

    # Extract local path
    local_path_match = re.search(r'\*\*Local Path:\*\*\s*`([^`]+)`', section)
    if local_path_match:
        config['source_path'] = local_path_match.group(1).strip()

    # Extract deployment config
    api_path_match = re.search(r'\*\*API Path:\*\*\s*`([^`]+)`', section)
    if api_path_match:
        config['remote_path'] = api_path_match.group(1).strip()

    app_pool_match = re.search(r'\*\*App Pool:\*\*\s*(\w+)', section)
    if app_pool_match:
        config['app_pool'] = app_pool_match.group(1).strip()

    # Extract production URL (for health check)
    prod_url_match = re.search(r'\*\*Production URL:\*\*\s*([^\s\n]+)', section)
    if prod_url_match:
        config['health_check_url'] = prod_url_match.group(1).strip()

    # Extract SSH credentials if specified
    server_match = re.search(r'\*\*Server:\*\*\s*([^\s]+)\s*\(SSH:\s*([^\s/]+)\s*/\s*([^)]+)\)', section)
    if server_match:
        config['ssh_host'] = server_match.group(1).strip()
        config['ssh_user'] = server_match.group(2).strip()
        config['ssh_password'] = server_match.group(3).strip()

    # Validate required fields
    required = ['source_path', 'remote_path', 'app_pool']
    missing = [f for f in required if f not in config]

    if missing:
        print(f"[ERROR] Missing deployment configuration in PROJECT_MASTER_MAP.md:")
        for field in missing:
            print(f"  - {field}")
        return None

    return config

def execute_remote(ssh, command, description=""):
    """Execute command on remote server"""
    if description:
        print(f"\n{'='*60}")
        print(f"  {description}")
        print('='*60)

    stdin, stdout, stderr = ssh.exec_command(command, timeout=120)
    exit_status = stdout.channel.recv_exit_status()

    output = stdout.read().decode('utf-8', errors='ignore')
    error = stderr.read().decode('utf-8', errors='ignore')

    if output:
        print(output)
    if error and exit_status != 0:
        print(f"[ERROR] {error}", file=sys.stderr)

    return output, error, exit_status

def build_local(source_path, output_path):
    """Build .NET application locally"""
    print(f"\n{'='*60}")
    print(f"  Building Locally: {source_path}")
    print('='*60)

    # Find .csproj or .sln file
    source = Path(source_path)
    project_file = None

    for ext in ['*.sln', '*.csproj']:
        files = list(source.glob(ext))
        if files:
            project_file = files[0]
            break

    if not project_file:
        print(f"[ERROR] No .sln or .csproj found in {source_path}")
        return False

    print(f"Project file: {project_file}")

    # Build command
    cmd = [
        'dotnet', 'publish',
        str(project_file),
        '-c', 'Release',
        '-o', output_path
    ]

    print(f"Command: {' '.join(cmd)}")

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        print(result.stdout)

        if result.returncode != 0:
            print(f"[ERROR] Build failed:\n{result.stderr}")
            return False

        print(f"\n[OK] Build successful! Output: {output_path}")
        return True

    except subprocess.TimeoutExpired:
        print("[ERROR] Build timed out after 5 minutes")
        return False
    except Exception as e:
        print(f"[ERROR] Build failed: {e}")
        return False

def deploy_to_iis(ssh, local_publish_path, remote_path, app_pool_name):
    """Deploy published files to IIS via SSH"""

    print(f"\n{'='*60}")
    print(f"  Deploying to IIS")
    print('='*60)
    print(f"Local: {local_publish_path}")
    print(f"Remote: {remote_path}")
    print(f"App Pool: {app_pool_name}")

    # Stop app pool
    execute_remote(
        ssh,
        f'powershell -Command "Import-Module WebAdministration; Stop-WebAppPool -Name \'{app_pool_name}\'"',
        f"Stopping App Pool: {app_pool_name}"
    )

    # Wait a bit
    import time
    print("\nWaiting 3 seconds...")
    time.sleep(3)

    # Create remote directory if needed
    execute_remote(
        ssh,
        f'if not exist "{remote_path}" mkdir "{remote_path}"',
        f"Ensuring remote path exists"
    )

    # Transfer files via SFTP
    print(f"\n{'='*60}")
    print(f"  Transferring Files via SFTP")
    print('='*60)

    try:
        sftp = ssh.open_sftp()

        local_path = Path(local_publish_path)
        if not local_path.exists():
            print(f"[ERROR] Local path doesn't exist: {local_path}")
            return False

        # Get all files recursively
        files_to_copy = list(local_path.rglob('*'))
        print(f"Found {len(files_to_copy)} files to transfer")

        for local_file in files_to_copy:
            if local_file.is_file():
                # Calculate relative path
                rel_path = local_file.relative_to(local_path)
                remote_file = f"{remote_path}\\{rel_path}".replace('/', '\\')

                # Create remote directory if needed
                remote_dir = '\\'.join(remote_file.split('\\')[:-1])
                try:
                    sftp.stat(remote_dir.replace('\\', '/'))
                except:
                    # Directory doesn't exist, create it
                    execute_remote(ssh, f'mkdir "{remote_dir}" 2>nul', "")

                # Copy file
                print(f"  {rel_path}")
                sftp.put(str(local_file), remote_file.replace('\\', '/'))

        sftp.close()
        print(f"\n[OK] {len([f for f in files_to_copy if f.is_file()])} files transferred")

    except Exception as e:
        print(f"[ERROR] File transfer failed: {e}")
        return False

    # Start app pool
    execute_remote(
        ssh,
        f'powershell -Command "Import-Module WebAdministration; Start-WebAppPool -Name \'{app_pool_name}\'"',
        f"Starting App Pool: {app_pool_name}"
    )

    # Restart IIS for good measure
    execute_remote(ssh, "iisreset", "Restarting IIS")

    return True

def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  MODE 1 (Config-based): deploy-dotnet-to-iis.py <project-name>")
        print("  MODE 2 (Manual):       deploy-dotnet-to-iis.py <source> <remote> <app-pool>")
        print()
        print("Examples:")
        print("  python deploy-dotnet-to-iis.py client-manager")
        print("  python deploy-dotnet-to-iis.py C:\\Projects\\app C:\\inetpub\\app AppPool")
        sys.exit(1)

    # Detect mode
    if len(sys.argv) == 2:
        # MODE 1: Config-based
        print("="*60)
        print("  CONFIG-BASED DEPLOYMENT")
        print("="*60)
        print(f"Project: {sys.argv[1]}\n")

        config = parse_project_config(sys.argv[1])
        if not config:
            sys.exit(1)

        source_path = config['source_path']
        remote_path = config['remote_path']
        app_pool_name = config['app_pool']
        ssh_host = config['ssh_host']
        ssh_user = config['ssh_user']
        ssh_password = config['ssh_password']
        health_check_url = config.get('health_check_url')

        print(f"Project: {config['project_name']}")
        print(f"Source: {source_path}")
        print(f"Target: {remote_path}")
        print(f"App Pool: {app_pool_name}")
        print(f"Server: {ssh_host}")

    elif len(sys.argv) == 4:
        # MODE 2: Manual
        print("="*60)
        print("  MANUAL DEPLOYMENT")
        print("="*60)

        source_path = sys.argv[1]
        remote_path = sys.argv[2]
        app_pool_name = sys.argv[3]
        ssh_host = DEFAULT_SSH_HOST
        ssh_user = DEFAULT_SSH_USER
        ssh_password = DEFAULT_SSH_PASSWORD
        health_check_url = None

        print(f"Source: {source_path}")
        print(f"Target: {remote_path}")
        print(f"App Pool: {app_pool_name}")

    else:
        print("[ERROR] Invalid number of arguments")
        print("\nUsage:")
        print("  MODE 1: deploy-dotnet-to-iis.py <project-name>")
        print("  MODE 2: deploy-dotnet-to-iis.py <source> <remote> <app-pool>")
        sys.exit(1)

    # Create temp publish directory
    publish_dir = "C:\\temp\\dotnet-publish"

    print("="*60)
    print("  .NET to IIS Deployment")
    print("="*60)

    # Step 1: Build locally
    if not build_local(source_path, publish_dir):
        print("\n[ERROR] Build failed. Aborting deployment.")
        sys.exit(1)

    # Step 2: Connect to server
    print(f"\n{'='*60}")
    print(f"  Connecting to {ssh_host}")
    print('='*60)

    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(ssh_host, username=ssh_user, password=ssh_password, timeout=10)
        print("[OK] Connected!")

        # Step 3: Deploy
        if not deploy_to_iis(ssh, publish_dir, remote_path, app_pool_name):
            print("\n[ERROR] Deployment failed")
            ssh.close()
            sys.exit(1)

        ssh.close()

        print("\n" + "="*60)
        print("  Deployment Complete!")
        print("="*60)

        # Health check (if URL configured)
        if health_check_url:
            print(f"\nTesting {health_check_url} in 5 seconds...")

            import time
            time.sleep(5)

            # Test
            import urllib.request
            try:
                # Try /health endpoint first, fallback to base URL
                test_urls = [
                    f"{health_check_url}/health",
                    f"{health_check_url}/api/health",
                    health_check_url
                ]

                success = False
                for test_url in test_urls:
                    try:
                        response = urllib.request.urlopen(test_url, timeout=10)
                        status = response.getcode()
                        print(f"[OK] API is ONLINE! (Status: {status})")
                        print(f"     URL: {test_url}")
                        success = True
                        break
                    except:
                        continue

                if not success:
                    print(f"[WARNING] Health check failed for all endpoints")
                    print("Check IIS logs for details")

            except Exception as e:
                print(f"[WARNING] Health check error: {e}")
                print("Deployment succeeded, but API verification failed")
        else:
            print("\n[INFO] No health check URL configured - skipping API test")

    except Exception as e:
        print(f"[ERROR] Deployment failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
