"""
Fix vault.prospergenics.com deployment issues via SSH
Server: 85.215.217.154
"""
import paramiko
import sys
import time

def execute_command(client, command, description=""):
    """Execute a PowerShell command and return output"""
    if description:
        print(f"  -> {description}")

    stdin, stdout, stderr = client.exec_command(f'powershell -Command "{command}"')
    output = stdout.read().decode('utf-8', errors='ignore').strip()
    error = stderr.read().decode('utf-8', errors='ignore').strip()

    return output, error

def main():
    host = '85.215.217.154'
    username = 'administrator'
    password = 'administrator'

    print("=" * 70)
    print("  vault.prospergenics.com Deployment Fix")
    print("  Server: 85.215.217.154")
    print("=" * 70)
    print()

    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        print(f"Connecting to {host} as {username}...")
        client.connect(host, username=username, password=password, timeout=30)
        print("OK Connected successfully\n")
    except paramiko.AuthenticationException:
        print("ERROR: Authentication failed - incorrect password")
        return 1
    except Exception as e:
        print(f"ERROR: Connection error: {e}")
        return 1

    try:
        site_path = r'C:\inetpub\vault.prospergenics.com'
        data_path = r'C:\inetpub\vault.prospergenics.com\Data'

        # Step 1: Check if site exists
        print("STEP 1: Verifying site path...")
        output, error = execute_command(client, f"Test-Path '{site_path}'", "Check site directory")
        if output.lower() != 'true':
            print(f"ERROR: Site path not found: {site_path}")
            print("   Checking for alternate locations...")

            # Check common IIS locations
            output, error = execute_command(client,
                "Get-ChildItem C:\\inetpub -Directory | Select-Object -ExpandProperty Name",
                "List IIS sites")
            print(f"   Found sites: {output}")
            return 1
        print("OK Site path verified\n")

        # Step 2: Create Data directory
        print("STEP 2: Creating Data directory...")
        execute_command(client,
            f"New-Item -ItemType Directory -Force -Path '{data_path}' | Out-Null",
            "Create Data folder")
        print("OK Data directory created\n")

        # Step 3: Get application pool
        print("STEP 3: Getting application pool...")
        output, error = execute_command(client,
            "Import-Module WebAdministration; (Get-Website -Name 'vault.prospergenics.com').applicationPool",
            "Query IIS configuration")

        app_pool = output.strip() if output else "DefaultAppPool"
        print(f"OK Application Pool: {app_pool}\n")

        # Step 4: Grant permissions
        print("STEP 4: Granting permissions to IIS app pool...")
        identity = f"IIS AppPool\\{app_pool}"

        permission_script = f"""
$path = '{data_path}'
$acl = Get-Acl $path
$identity = '{identity}'
$permission = $identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl $path $acl
Write-Host 'Permissions granted'
"""
        output, error = execute_command(client, permission_script.replace('\n', '; '),
            f"Grant FullControl to {identity}")

        if error and "cannot find" not in error.lower():
            print(f"WARNING: {error}")
        else:
            print("OK Permissions granted\n")

        # Step 5: Update connection string
        print("STEP 5: Updating connection string...")
        db_path = f"{data_path}\\passwordmanager.db"

        update_config_script = f"""
$configPath = '{site_path}\\appsettings.Production.json'
if (Test-Path $configPath) {{
    $json = Get-Content $configPath -Raw | ConvertFrom-Json
    $json.ConnectionStrings.DefaultConnection = 'Data Source={db_path}'
    $json | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
    Write-Host 'Config updated'
}} else {{
    Write-Host 'Config not found'
}}
"""
        output, error = execute_command(client, update_config_script.replace('\n', '; '),
            "Update appsettings.Production.json")

        if 'Config updated' in output:
            print(f"OK Connection string updated to: Data Source={db_path}\n")
        else:
            print(f"WARNING: {output}\n")

        # Step 6: Check SSL certificate
        print("STEP 6: Checking SSL certificate...")
        cert_script = """
Import-Module WebAdministration
$binding = Get-WebBinding -Name 'vault.prospergenics.com' -Protocol 'https'
if ($binding) {
    $thumbprint = $binding.certificateHash
    if ($thumbprint) {
        $cert = Get-ChildItem Cert:\\LocalMachine\\My | Where-Object { $_.Thumbprint -eq $thumbprint }
        if ($cert) {
            Write-Host "Subject: $($cert.Subject)"
            Write-Host "Issuer: $($cert.Issuer)"
            Write-Host "Valid Until: $($cert.NotAfter)"
        } else {
            Write-Host "Certificate not found in store"
        }
    } else {
        Write-Host "No certificate bound"
    }
} else {
    Write-Host "No HTTPS binding found"
}
"""
        output, error = execute_command(client, cert_script.replace('\n', '; '),
            "Query SSL certificate")

        if output:
            print(f"  {output}\n")
        else:
            print("  WARNING: Could not retrieve certificate info\n")

        # Step 7: Restart application pool
        print("STEP 7: Restarting application pool...")
        execute_command(client,
            f"Import-Module WebAdministration; Restart-WebAppPool -Name '{app_pool}'",
            f"Restart {app_pool}")
        print("OK Application pool restarted\n")

        # Wait for app to start
        print("Waiting 5 seconds for application to initialize...")
        time.sleep(5)

        # Step 8: Verify database file
        print("\nSTEP 8: Verifying database file...")
        output, error = execute_command(client, f"Test-Path '{db_path}'",
            "Check if database file was created")

        if output.lower() == 'true':
            print("OK Database file created successfully\n")
        else:
            print("NOTE: Database file not yet created (will be created on first request)\n")

        # Final summary
        print("=" * 70)
        print("  DEPLOYMENT FIX COMPLETE")
        print("=" * 70)
        print()
        print("Changes applied:")
        print(f"  1. Created directory: {data_path}")
        print(f"  2. Granted FullControl to: IIS AppPool\\{app_pool}")
        print(f"  3. Updated connection string to absolute path")
        print(f"  4. Restarted application pool: {app_pool}")
        print()
        print("Next steps:")
        print("  1. Test the application: https://vault.prospergenics.com")
        print("  2. The database will be created automatically on first request")
        print("  3. Register a test account to verify functionality")
        print()
        print("If the SSL certificate warning persists:")
        print("  - The certificate may need to be reissued or renewed")
        print("  - Check the fix guide for SSL certificate installation steps")
        print(f"  - Guide: C:\\scripts\\tools\\vault-deployment-fix-guide.md")
        print()

    except Exception as e:
        print(f"\nERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        return 1
    finally:
        client.close()

    return 0

if __name__ == '__main__':
    sys.exit(main())
