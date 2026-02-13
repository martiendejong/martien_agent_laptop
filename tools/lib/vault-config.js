/**
 * Vault Config - Reads credentials from DPAPI vault
 *
 * Usage:
 *   const { getSmtpConfig, getImapConfig, getCredential } = require('./lib/vault-config');
 *   const smtp = getSmtpConfig();
 *   const imap = getImapConfig();
 */

const { execSync } = require('child_process');
const path = require('path');

const VAULT_SCRIPT = path.join(__dirname, '..', 'vault.ps1');

// Cache to avoid repeated vault calls in same process
const _cache = {};

function vaultGet(service, field) {
  const cacheKey = `${service}:${field}`;
  if (_cache[cacheKey]) return _cache[cacheKey];

  try {
    const cmd = `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${VAULT_SCRIPT}" -Action get -Service "${service}" -Field "${field}" -Silent`;
    const result = execSync(cmd, { encoding: 'utf8', timeout: 10000 }).trim();
    if (!result || result === '[DECRYPTION FAILED]') {
      throw new Error(`Vault returned empty or failed for ${service}:${field}`);
    }
    _cache[cacheKey] = result;
    return result;
  } catch (err) {
    console.error(`[vault-config] Failed to get ${service}:${field} - ${err.message}`);
    process.exit(1);
  }
}

function getSmtpConfig() {
  return {
    host: 'mail.zxcs.nl',
    port: 465,
    secure: true,
    auth: {
      user: vaultGet('smtp', 'username'),
      pass: vaultGet('smtp', 'password')
    },
    tls: { rejectUnauthorized: false },
    connectionTimeout: 10000,
    greetingTimeout: 10000
  };
}

function getImapConfig() {
  return {
    user: vaultGet('imap', 'username'),
    password: vaultGet('imap', 'password'),
    host: 'mail.zxcs.nl',
    port: 993,
    tls: true,
    tlsOptions: { rejectUnauthorized: false },
    authTimeout: 30000,
    connTimeout: 30000
  };
}

function getCredential(service, field) {
  return vaultGet(service, field);
}

module.exports = { getSmtpConfig, getImapConfig, getCredential, vaultGet };
