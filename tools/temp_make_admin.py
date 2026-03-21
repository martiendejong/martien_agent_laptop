"""Make info@prospergenics.com admin in Brand2Boost"""
import paramiko

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

script_content = r"""
import sqlite3
db = r'C:\stores\brand2boost\identity.db'
conn = sqlite3.connect(db)
c = conn.cursor()

# Get user
c.execute("SELECT Id, UserName FROM AspNetUsers WHERE Email = 'info@prospergenics.com'")
user = c.fetchone()
print(f"User: {user}")

# List roles
c.execute("SELECT Id, Name FROM AspNetRoles")
roles = c.fetchall()
print(f"Available roles: {roles}")

# Current roles
c.execute("SELECT r.Name FROM AspNetUserRoles ur JOIN AspNetRoles r ON ur.RoleId = r.Id WHERE ur.UserId = ?", (user[0],))
print(f"Current roles: {c.fetchall()}")

# Find ADMIN role
c.execute("SELECT Id FROM AspNetRoles WHERE Name = 'ADMIN'")
admin_role = c.fetchone()

if admin_role:
    c.execute("SELECT 1 FROM AspNetUserRoles WHERE UserId = ? AND RoleId = ?", (user[0], admin_role[0]))
    if c.fetchone():
        print("Already admin!")
    else:
        c.execute("INSERT INTO AspNetUserRoles (UserId, RoleId) VALUES (?, ?)", (user[0], admin_role[0]))
        conn.commit()
        print(f"ADMIN role added!")

    # Verify
    c.execute("SELECT r.Name FROM AspNetUserRoles ur JOIN AspNetRoles r ON ur.RoleId = r.Id WHERE ur.UserId = ?", (user[0],))
    print(f"Roles after: {c.fetchall()}")
else:
    print("ADMIN role not found!")

conn.close()
print("DONE")
"""

sftp = ssh.open_sftp()
with sftp.open('C:/temp_admin.py', 'w') as f:
    f.write(script_content)
sftp.close()

stdin, stdout, stderr = ssh.exec_command('python C:\\temp_admin.py')
print(stdout.read().decode())
err = stderr.read().decode()
if err:
    print(f"Error: {err}")

ssh.exec_command('del C:\\temp_admin.py')
ssh.close()
print("Done")
