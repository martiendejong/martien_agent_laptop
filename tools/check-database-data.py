"""Check if database has any projects and credentials"""
import paramiko
import sqlite3
import io

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

print('Checking Database Content')
print('='*60)

sftp = c.open_sftp()

# Download database file
print('\n1. Downloading database...')
with sftp.open('C:/inetpub/vault.prospergenics.com/Data/passwordmanager.db', 'rb') as remote_file:
    db_data = remote_file.read()

# Connect to database
print('\n2. Analyzing database...')
conn = sqlite3.connect(':memory:')
conn.execute('PRAGMA journal_mode=DELETE')  # For in-memory compatibility
with open('temp_db.db', 'wb') as f:
    f.write(db_data)

conn = sqlite3.connect('temp_db.db')
cursor = conn.cursor()

# Check users
cursor.execute("SELECT COUNT(*) FROM AspNetUsers")
user_count = cursor.fetchone()[0]
print(f'   Users: {user_count}')

if user_count > 0:
    cursor.execute("SELECT Email FROM AspNetUsers")
    users = cursor.fetchall()
    for user in users:
        print(f'     - {user[0]}')

# Check projects
cursor.execute("SELECT COUNT(*) FROM Projects")
project_count = cursor.fetchone()[0]
print(f'\n   Projects: {project_count}')

if project_count > 0:
    cursor.execute("SELECT Id, Name, Description FROM Projects")
    projects = cursor.fetchall()
    for proj in projects:
        print(f'     - [{proj[0]}] {proj[1]}: {proj[2] or "No description"}')

# Check credentials
cursor.execute("SELECT COUNT(*) FROM Credentials")
cred_count = cursor.fetchone()[0]
print(f'\n   Credentials: {cred_count}')

if cred_count > 0:
    cursor.execute("SELECT Id, Name, Username, Url, ProjectId FROM Credentials LIMIT 5")
    creds = cursor.fetchall()
    for cred in creds:
        print(f'     - [{cred[0]}] {cred[1]} ({cred[2]}) for project {cred[4]}')

conn.close()

sftp.close()
c.close()

import os
os.remove('temp_db.db')

print('\n' + '='*60)
if user_count == 0:
    print('⚠️  NO USERS - Register a user first!')
elif project_count == 0:
    print('⚠️  NO PROJECTS - Create a project first!')
elif cred_count == 0:
    print('⚠️  NO CREDENTIALS - Add credentials to a project!')
else:
    print('✓ Database has data')
    print('✓ Extension should show this data now (after CORS fix)')
