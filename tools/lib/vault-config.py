"""
Vault Config - Reads credentials from DPAPI vault for Python scripts.

Usage:
    from lib.vault_config import get_imap_credentials, get_credential
    user, password = get_imap_credentials()
"""

import subprocess
import os

VAULT_SCRIPT = os.path.join(os.path.dirname(__file__), '..', 'vault.ps1')

_cache = {}

def vault_get(service, field):
    cache_key = f"{service}:{field}"
    if cache_key in _cache:
        return _cache[cache_key]

    cmd = [
        'powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass',
        '-File', VAULT_SCRIPT,
        '-Action', 'get', '-Service', service, '-Field', field, '-Silent'
    ]
    result = subprocess.run(cmd, capture_output=True, timeout=10)
    value = result.stdout.decode('utf-8').strip()

    if not value or value == '[DECRYPTION FAILED]':
        raise RuntimeError(f"Vault returned empty or failed for {service}:{field}")

    _cache[cache_key] = value
    return value


def get_imap_credentials():
    """Returns (username, password) for IMAP."""
    return vault_get('imap', 'username'), vault_get('imap', 'password')


def get_smtp_credentials():
    """Returns (username, password) for SMTP."""
    return vault_get('smtp', 'username'), vault_get('smtp', 'password')


def get_credential(service, field):
    """Generic credential retrieval."""
    return vault_get(service, field)
