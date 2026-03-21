"""Fix Brand2Boost frontend config.js on server - deploy production config"""
import paramiko

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('85.215.217.154', username='administrator', password='SpaceElevator1tam!')

# Upload production config.js via SFTP
prod_config = r'''window.__CONFIG__ = {
  API_URL: "https://api.brand2boost.com/api/",
  env: "production",
  LINKEDIN_CLIENT_ID: "770k2mszhs3pl9",
  FACEBOOK_CLIENT_ID: "764190923379550",
  GOOGLE_CLIENT_ID: "522975587259-ntjj390t0iu7n5hmdm05gk8gdrada8b9.apps.googleusercontent.com",
  TWITTER_CLIENT_ID: "NUo0djNUZnBxcU1ZeUlCemJVZkY6MTpjaQ",
  PINTEREST_CLIENT_ID: "1542684",
  SNAPCHAT_CLIENT_ID: "1128f41a-7228-432b-9757-9290fe405ddc",
  TUMBLR_CLIENT_ID: "IrwA5Ljh7gVtNt0fkOc3RujLSYgQZmP0n5UK3IlO7Bwvcv6H0p",
  TIKTOK_CLIENT_ID: "awpnhsgwz9eaxnbm",
  INSTAGRAM_CLIENT_ID: "926262283417229",
};
'''

sftp = ssh.open_sftp()
with sftp.open('C:/stores/brand2boost/www/config.js', 'w') as f:
    f.write(prod_config)
sftp.close()
print("Production config.js uploaded!")

# Verify
stdin, stdout, stderr = ssh.exec_command('type "C:\\stores\\brand2boost\\www\\config.js"')
content = stdout.read().decode()
print(f"\n=== Verified config.js ===\n{content}")

ssh.close()
print("Done")
