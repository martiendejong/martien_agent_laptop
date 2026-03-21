"""Test SQLite write directly"""
import paramiko
import time

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Testing SQLite Write Capabilities')
print('='*60)

# Check if SQLite3.exe is available or use PowerShell with System.Data.SQLite
print('\n1. Creating test database with PowerShell...')

test_script = '''
$dbPath = "C:\\inetpub\\vault.prospergenics.com\\Data\\test-write.db"

# Try to create and write to a SQLite database
try {
    Add-Type -AssemblyName System.Data
    $connectionString = "Data Source=$dbPath;Version=3;"

    # Load SQLite if available
    if (Test-Path "C:\\inetpub\\vault.prospergenics.com\\Microsoft.Data.Sqlite.dll") {
        Add-Type -Path "C:\\inetpub\\vault.prospergenics.com\\Microsoft.Data.Sqlite.dll"
        $conn = New-Object Microsoft.Data.Sqlite.SqliteConnection($connectionString)
        $conn.Open()

        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT); INSERT INTO test (name) VALUES ('test');"
        $cmd.ExecuteNonQuery() | Out-Null

        $conn.Close()
        Write-Host "SUCCESS: SQLite write test passed"

        # Check what files were created
        Get-ChildItem "C:\\inetpub\\vault.prospergenics.com\\Data\\test-write.*" | ForEach-Object { Write-Host "Created: $($_.Name)" }

        # Clean up
        Remove-Item "C:\\inetpub\\vault.prospergenics.com\\Data\\test-write.*" -Force
    } else {
        Write-Host "DLL not found, using dotnet command"
        # Alternative: use the deployed app's DLL
        cd C:\\inetpub\\vault.prospergenics.com
        $env:ASPNETCORE_ENVIRONMENT="Production"

        # Just check file creation
        "test" | Out-File "C:\\inetpub\\vault.prospergenics.com\\Data\\write-test.txt"
        if (Test-Path "C:\\inetpub\\vault.prospergenics.com\\Data\\write-test.txt") {
            Write-Host "File write: OK"
            Remove-Item "C:\\inetpub\\vault.prospergenics.com\\Data\\write-test.txt"
        } else {
            Write-Host "File write: FAILED"
        }
    }
} catch {
    Write-Host "ERROR: $_"
}
'''

stdin, stdout, stderr = c.exec_command(f'powershell {test_script}')
output = stdout.read().decode('utf-8', errors='ignore')
error = stderr.read().decode('utf-8', errors='ignore')

print(output)
if error:
    print(f'Errors: {error}')

# Check connection string being used
print('\n2. Checking actual connection string in use...')
stdin, stdout, stderr = c.exec_command('powershell Get-Content C:\\inetpub\\vault.prospergenics.com\\appsettings.Production.json | Select-String -Pattern "ConnectionString" -Context 0,2')
connstr = stdout.read().decode('utf-8', errors='ignore')
print(connstr)

# Check if there might be multiple database files
print('\n3. Checking for all database-related files...')
stdin, stdout, stderr = c.exec_command('powershell Get-ChildItem C:\\inetpub\\vault.prospergenics.com -Recurse -Include *.db,*.sqlite,*.db3 -ErrorAction SilentlyContinue | Select-Object FullName, Length, IsReadOnly')
files = stdout.read().decode('utf-8', errors='ignore')
print(files if files else '   No database files found')

# Try using the connection string mode parameter
print('\n4. Suggestion: Add Mode=ReadWrite to connection string...')
print('   Current: Data Source=C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db')
print('   Try: Data Source=C:\\inetpub\\vault.prospergenics.com\\Data\\passwordmanager.db;Mode=ReadWriteCreate')

c.close()
