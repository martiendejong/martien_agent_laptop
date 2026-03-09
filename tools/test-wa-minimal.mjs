// Simulate MINIMAL ClientPayload without devicePairingData
import { proto } from '@whiskeysockets/baileys/WAProto/index.js';

// Minimal payload - no device pairing data at all
const minimal = {
  connectType: 1,   // WIFI_UNKNOWN
  connectReason: 1, // USER_ACTIVATED
  userAgent: {
    platform: 14,  // WEB
    appVersion: { primary: 2, secondary: 3000, tertiary: 1027934701 },
    mcc: '000', mnc: '000', osVersion: '0.1',
    device: 'Desktop', osBuildNumber: '0.1',
    releaseChannel: 0,  // RELEASE
    localeLanguageIso6391: 'en',
    localeCountryIso31661Alpha2: 'US',
  },
  webInfo: { webSubPlatform: 0 },  // WEB_BROWSER
  passive: false,
  pull: false,
};

const bytes = proto.ClientPayload.encode(minimal).finish();
console.log('Minimal payload bytes:', bytes.length);
console.log('Hex:', Buffer.from(bytes).toString('hex'));

// Full registration payload
import { generateRegistrationNode } from '@whiskeysockets/baileys/lib/Utils/validate-connection.js';
import { Curve, signedKeyPair } from '@whiskeysockets/baileys/lib/Utils/crypto.js';
import { randomBytes } from 'crypto';

const signedIdentityKey = Curve.generateKeyPair();
const spk = signedKeyPair(signedIdentityKey, 1);
const creds = { noiseKey: Curve.generateKeyPair(), signedIdentityKey, registrationId: 12345, advSecretKey: randomBytes(32).toString('base64'), signedPreKey: spk };
const config = { version: [2, 3000, 1027934701], browser: ['Windows', 'Desktop', '10.0'], countryCode: 'US', syncFullHistory: false };
const full = generateRegistrationNode(creds, config);
const fullBytes = proto.ClientPayload.encode(full).finish();
console.log('\nFull payload bytes:', fullBytes.length);
