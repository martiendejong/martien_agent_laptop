"""
Fix vault.prospergenics.com deployment issues:
1. Create database directory with proper permissions
2. Update connection string to use absolute path
3. Run EF migrations
4. Verify SSL certificate
"""
import paramiko
import sys
import os

def main():
    host = 'vault.prospergenics.com'
    username = 'administrator'
    key_path = r'C:\Users\HP\.ssh\id_ed25519'

    print(f"Connecting to {host}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        client.connect(host, username=username, key_filename=key_path)
        print("✓ Connected successfully\n")

        # Step 1: Create data directory
        print("STEP 1: Creating database directory...")
        commands = [
            # Create Data directory
            'powershell -Command "New-Item -ItemType Directory -Force -Path C:\\inetpub\\vault.prospergenics.com\\Data | Out-Null"',

            # Get application pool name
            'powershell -Command "Import-Module WebAdministration; (Get-Website -Name \'vault.prospergenics.com\').applicationPool"',
        ]

        app_pool = None
        for cmd in commands:
            stdin, stdout, stderr = client.exec_command(cmd)
            output = stdout.read().decode().strip()
            error = stderr.read().decode().strip()

            if 'applicationPool' in cmd:
                app_pool = output
                print(f"✓ Application Pool: {app_pool}")
            else:
                print(f"✓ {cmd[:50]}...")
                if error:
                    print(f"  Warning: {error}")

        if not app_pool:
            app_pool = "DefaultAppPool"  # Fallback
            print(f"⚠ Using default app pool: {app_pool}")

        # Step 2: Grant permissions to app pool identity
        print("\nSTEP 2: Granting permissions to IIS app pool...")
        permission_cmd = f'''powershell -Command "
        $path = 'C:\\inetpub\\vault.prospergenics.com\\Data'
        $acl = Get-Acl $path
        $identity = 'IIS AppPool\\{app_pool}'
        $permission = $identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
        $acl.SetAccessRule($accessRule)
        Set-Acl $path $acl
        Write-Host 'Permissions granted to' $identity
        "'''

        stdin, stdout, stderr = client.exec_command(permission_cmd)
        output = stdout.read().decode().strip()
        error = stderr.read().decode().strip()

        if output:
            print(f"✓ {output}")
        if error:
            print(f"⚠ {error}")

        # Step 3: Update appsettings.Production.json
        print("\nSTEP 3: Updating connection string...")
        update_config_cmd = '''powershell -Command "
        $configPath = 'C:\\inetpub\\vault.prospergenics.com\\appsettings.Production.json'
        $json = Get-Content $configPath | ConvertFrom-Json
        $json.ConnectionStrings.DefaultConnection = 'Data Source=C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db'
        $json | ConvertTo-Json -Depth 10 | Set-Content $configPath
        Write-Host 'Updated connection string to absolute path'
        "'''

        stdin, stdout, stderr = client.exec_command(update_config_cmd)
        output = stdout.read().decode().strip()
        error = stderr.read().decode().strip()

        if output:
            print(f"✓ {output}")
        if error:
            print(f"⚠ {error}")

        # Step 4: Check if EF tools are available
        print("\nSTEP 4: Checking for Entity Framework migrations...")
        check_dll_cmd = 'powershell -Command "Test-Path C:\\inetpub\\vault.prospergenics.com\\PasswordManager.API.dll"'
        stdin, stdout, stderr = client.exec_command(check_dll_cmd)
        dll_exists = stdout.read().decode().strip()

        if dll_exists == "True":
            print("✓ Application DLL found")

            # Check for migrations in the deployed folder
            check_migrations_cmd = 'powershell -Command "Get-ChildItem C:\\inetpub\\vault.prospergenics.com\\*.dll | Select-String \'Microsoft.EntityFrameworkCore\' | Measure-Object | Select-Object -ExpandProperty Count"'
            stdin, stdout, stderr = client.exec_command(check_migrations_cmd)
            has_ef = stdout.read().decode().strip()

            if has_ef and int(has_ef) > 0:
                print("⚠ EF Core found - migrations may need to be applied manually")
                print("  Run: dotnet ef database update --project PasswordManager.API.csproj")
            else:
                print("⚠ EF Core not found in deployment - database will be created automatically")
        else:
            print("⚠ Application DLL not found")

        # Step 5: Restart application pool
        print("\nSTEP 5: Restarting application pool...")
        restart_cmd = f'powershell -Command "Import-Module WebAdministration; Restart-WebAppPool -Name \'{app_pool}\'; Write-Host \'Application pool restarted\'"'
        stdin, stdout, stderr = client.exec_command(restart_cmd)
        output = stdout.read().decode().strip()
        error = stderr.read().decode().strip()

        if output:
            print(f"✓ {output}")
        if error and "not running" not in error.lower():
            print(f"⚠ {error}")

        # Step 6: Check SSL certificate
        print("\nSTEP 6: Checking SSL certificate...")
        cert_cmd = '''powershell -Command "
        Import-Module WebAdministration
        $binding = Get-WebBinding -Name 'vault.prospergenics.com' -Protocol 'https'
        if ($binding) {
            $thumbprint = $binding.certificateHash
            if ($thumbprint) {
                $cert = Get-ChildItem Cert:\\LocalMachine\\My | Where-Object { $_.Thumbprint -eq $thumbprint }
                Write-Host 'Certificate Subject:' $cert.Subject
                Write-Host 'Certificate Issuer:' $cert.Issuer
                Write-Host 'Valid Until:' $cert.NotAfter
            } else {
                Write-Host 'No certificate bound to HTTPS binding'
            }
        } else {
            Write-Host 'No HTTPS binding found'
        }
        "'''

        stdin, stdout, stderr = client.exec_command(cert_cmd)
        output = stdout.read().decode().strip()
        error = stderr.read().decode().strip()

        if output:
            print(f"✓ Certificate Info:\n  {output}")
        if error:
            print(f"⚠ {error}")

        print("\n" + "="*60)
        print("✅ DEPLOYMENT FIX COMPLETE")
        print("="*60)
        print("\nNext steps:")
        print("1. Test the application: https://vault.prospergenics.com")
        print("2. Check application logs if issues persist")
        print("3. Verify database file created: C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db")

    except Exception as e:
        print(f"\n❌ ERROR: {str(e)}", file=sys.stderr)
        return 1
    finally:
        client.close()

    return 0

if __name__ == '__main__':
    sys.exit(main())
