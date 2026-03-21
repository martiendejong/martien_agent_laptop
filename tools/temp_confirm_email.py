"""Confirm email for Brand2Boost user via SSH"""
import paramiko

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

# Check if Python is available on server
stdin, stdout, stderr = ssh.exec_command('python --version')
py_ver = stdout.read().decode().strip()
py_err = stderr.read().decode().strip()
print(f"Python version: {py_ver or py_err}")

# Write a Python script to the server
script_content = """
import sqlite3
db_path = r'C:\\stores\\brand2boost\\identity.db'
conn = sqlite3.connect(db_path)
c = conn.cursor()

# Check current state
c.execute("SELECT Id, UserName, Email, EmailConfirmed FROM AspNetUsers WHERE Email = 'info@prospergenics.com'")
rows = c.fetchall()
for r in rows:
    print(f"Before: Id={r[0]}, User={r[1]}, Email={r[2]}, Confirmed={r[3]}")

if not rows:
    print("User not found!")
else:
    # Update EmailConfirmed
    c.execute("UPDATE AspNetUsers SET EmailConfirmed = 1 WHERE Email = 'info@prospergenics.com'")
    conn.commit()
    print(f"Rows updated: {c.rowcount}")

    # Verify
    c.execute("SELECT Id, UserName, Email, EmailConfirmed FROM AspNetUsers WHERE Email = 'info@prospergenics.com'")
    rows = c.fetchall()
    for r in rows:
        print(f"After: Id={r[0]}, User={r[1]}, Email={r[2]}, Confirmed={r[3]}")

conn.close()
print("DONE")
"""

# Upload script via SFTP
sftp = ssh.open_sftp()
with sftp.open('C:/temp_confirm_email.py', 'w') as f:
    f.write(script_content)
sftp.close()
print("Script uploaded")

# Execute it
stdin, stdout, stderr = ssh.exec_command('python C:\\temp_confirm_email.py')
out = stdout.read().decode()
err = stderr.read().decode()
print(f"Output:\n{out}")
if err:
    print(f"Errors:\n{err}")

# Cleanup
ssh.exec_command('del C:\\temp_confirm_email.py')

ssh.close()
print("Connection closed")
