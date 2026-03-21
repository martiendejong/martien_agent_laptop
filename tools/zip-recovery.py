#!/usr/bin/env python3
"""
ZIP Recovery Tool
Attempts to recover files from corrupted ZIP archives
"""

import zipfile
import sys
import os
from pathlib import Path

def recover_zip(zip_path, output_dir):
    """Attempt to recover files from corrupted ZIP"""
    zip_path = Path(zip_path)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"[*] Analyzing: {zip_path}")
    print(f"[*] Size: {zip_path.stat().st_size:,} bytes ({zip_path.stat().st_size / (1024**3):.2f} GB)")
    print(f"[*] Output: {output_dir}\n")

    recovered = []
    failed = []

    try:
        # Try to open ZIP with lenient error handling
        with zipfile.ZipFile(zip_path, 'r', allowZip64=True) as zf:
            print(f"[+] ZIP header is readable")
            file_list = zf.namelist()
            print(f"[*] Found {len(file_list)} files in archive\n")

            # Try to extract each file individually
            for i, filename in enumerate(file_list, 1):
                try:
                    info = zf.getinfo(filename)
                    print(f"[{i}/{len(file_list)}] Extracting: {filename[:60]}...")

                    # Extract to output directory
                    zf.extract(filename, output_dir)
                    recovered.append(filename)
                    print(f"    [+] Success ({info.file_size:,} bytes)")

                except Exception as e:
                    failed.append((filename, str(e)))
                    print(f"    [-] Failed: {str(e)[:60]}")

    except zipfile.BadZipFile as e:
        print(f"[-] ZIP header is corrupted: {e}")
        print("\n[*] Attempting byte-level recovery...")

        # Try to find and extract individual file headers
        try:
            with open(zip_path, 'rb') as f:
                data = f.read()

            # Look for local file header signature (0x04034b50)
            signature = b'PK\x03\x04'
            positions = []
            pos = 0
            while True:
                pos = data.find(signature, pos)
                if pos == -1:
                    break
                positions.append(pos)
                pos += 1

            print(f"[*] Found {len(positions)} potential file headers")

            if len(positions) > 0:
                print("[!] Partial recovery might be possible with advanced tools")
                print("    Recommended: 7-Zip (7z x -tzip file.zip) or WinRAR")

        except Exception as e2:
            print(f"[-] Byte-level analysis failed: {e2}")

    except Exception as e:
        print(f"[-] Unexpected error: {e}")
        return False

    # Summary
    print("\n" + "="*70)
    print("RECOVERY SUMMARY")
    print("="*70)
    print(f"[+] Recovered: {len(recovered)} files")
    print(f"[-] Failed: {len(failed)} files")

    if recovered:
        print(f"\n[*] Recovered files saved to: {output_dir}")
        total_size = sum((output_dir / f).stat().st_size for f in recovered if (output_dir / f).exists())
        print(f"[*] Total recovered: {total_size:,} bytes ({total_size / (1024**2):.2f} MB)")

    if failed:
        print(f"\n[-] Failed files:")
        for filename, error in failed[:10]:  # Show first 10
            print(f"   - {filename}: {error[:60]}")
        if len(failed) > 10:
            print(f"   ... and {len(failed) - 10} more")

    return len(recovered) > 0

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python zip-recovery.py <zip_file> <output_dir>")
        sys.exit(1)

    zip_file = sys.argv[1]
    output_dir = sys.argv[2]

    if not os.path.exists(zip_file):
        print(f"[-] File not found: {zip_file}")
        sys.exit(1)

    success = recover_zip(zip_file, output_dir)
    sys.exit(0 if success else 1)
