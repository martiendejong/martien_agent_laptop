"""Try to run the app manually to see errors"""
import paramiko
import time
import threading

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Attempting to run application manually...')
print('='*60)

# Run the app and capture output
cmd = 'cd C:\\inetpub\\vault.prospergenics.com && set ASPNETCORE_ENVIRONMENT=Production && dotnet PasswordManager.API.dll --urls http://localhost:5999'

print(f'\nRunning command: {cmd}')
print('\nOutput (will run for 10 seconds):\n')

stdin, stdout, stderr = client.exec_command(cmd, get_pty=True)

# Read output for 10 seconds
def read_output(stream, name):
    try:
        for line in iter(stream.readline, ''):
            if line:
                print(f'{name}: {line.strip()}')
    except:
        pass

# Start reading in background
import threading
t1 = threading.Thread(target=read_output, args=(stdout, 'STDOUT'))
t2 = threading.Thread(target=read_output, args=(stderr, 'STDERR'))
t1.daemon = True
t2.daemon = True
t1.start()
t2.start()

# Wait
time.sleep(10)

# Try to access it
print('\n\nTrying to access http://localhost:5999...')
client2 = paramiko.SSHClient()
client2.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client2.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

stdin2, stdout2, stderr2 = client2.exec_command('powershell Invoke-WebRequest -Uri http://localhost:5999 -UseBasicParsing')
response = stdout2.read().decode('utf-8', errors='ignore')
print(response if response else 'No response')

error = stderr2.read().decode('utf-8', errors='ignore')
if error:
    print(f'Error: {error}')

client2.close()
client.close()
