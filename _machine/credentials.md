# Credentials Reference

All credentials have been migrated to the DPAPI-encrypted vault.

Usage:
  vault.ps1 -Action list                              # Show all entries
  vault.ps1 -Action get -Service smtp                  # Get full credentials
  vault.ps1 -Action get -Service clickup -Field token  # Get single value

Vault file: C:\scripts\_machine\vault.secure.json (DPAPI encrypted, CurrentUser scope)
Migrated: 2026-02-11
