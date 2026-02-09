#!/usr/bin/env python3
"""Upload Art Revisionist Theme and Plugin to Staging via FTP"""

import os
import ftplib
from pathlib import Path

# FTP Configuration
FTP_HOST = "ftp.artrevisionist.com"
FTP_USER = "info@artrevisionist.com"
FTP_PASS = "u48zm5dRaDTxVc9wdSbW"
REMOTE_BASE = "/public_html/staging/wp-content"

# Local paths
LOCAL_THEME = Path("C:/xampp/htdocs/wp-content/themes/artrevisionist-wp-theme")
LOCAL_PLUGIN = Path("C:/xampp/htdocs/wp-content/plugins/artrevisionist-wordpress")

def upload_directory(ftp, local_dir, remote_dir):
    """Recursively upload a directory to FTP"""
    print(f"Uploading {local_dir.name}...")

    # Create remote directory if it doesn't exist
    try:
        ftp.cwd(remote_dir)
    except:
        # Directory doesn't exist, create it
        parts = remote_dir.strip('/').split('/')
        current = '/'
        for part in parts:
            current = os.path.join(current, part).replace('\\', '/')
            try:
                ftp.cwd(current)
            except:
                ftp.mkd(current)
                ftp.cwd(current)

    # Upload files
    for item in local_dir.rglob('*'):
        if item.is_file():
            # Skip git files
            if '.git' in item.parts:
                continue

            # Calculate relative path
            rel_path = item.relative_to(local_dir)
            remote_file = os.path.join(remote_dir, str(rel_path)).replace('\\', '/')

            # Create remote directories
            remote_file_dir = os.path.dirname(remote_file)
            try:
                ftp.cwd(remote_file_dir)
            except:
                # Create directories recursively
                parts = remote_file_dir.strip('/').split('/')
                current = '/'
                for part in parts:
                    current = os.path.join(current, part).replace('\\', '/')
                    try:
                        ftp.cwd(current)
                    except:
                        try:
                            ftp.mkd(current)
                            ftp.cwd(current)
                        except:
                            pass

            # Upload file
            try:
                with open(item, 'rb') as f:
                    ftp.storbinary(f'STOR {remote_file}', f)
                print(f"  [OK] {rel_path}")
            except Exception as e:
                print(f"  [ERR] {rel_path}: {e}")

def main():
    print("=== Uploading to Art Revisionist Staging ===\n")

    try:
        # Connect to FTP
        print(f"Connecting to {FTP_HOST}...")
        ftp = ftplib.FTP(FTP_HOST)
        ftp.login(FTP_USER, FTP_PASS)
        print("[OK] Connected\n")

        # Upload Theme
        upload_directory(ftp, LOCAL_THEME, f"{REMOTE_BASE}/themes/artrevisionist-wp-theme")

        # Upload Plugin
        upload_directory(ftp, LOCAL_PLUGIN, f"{REMOTE_BASE}/plugins/artrevisionist-wordpress")

        ftp.quit()

        print("\n=== Upload Complete ===")
        print("Staging URL: https://artrevisionist.com/staging")

    except Exception as e:
        print(f"\n[ERROR] {e}")
        return 1

    return 0

if __name__ == "__main__":
    exit(main())
