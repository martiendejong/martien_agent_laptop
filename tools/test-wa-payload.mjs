// Test script to show what Baileys generates for ClientPayload registration
import { proto } from '@whiskeysockets/baileys/WAProto/index.js';
import { generateRegistrationNode } from '@whiskeysockets/baileys/lib/Utils/validate-connection.js';
import { Curve } from '@whiskeysockets/baileys/lib/Utils/crypto.js';
import { KEY_BUNDLE_TYPE, DEFAULT_BROWSER } from '@whiskeysockets/baileys/lib/Defaults/index.js';
import { createHash, randomBytes } from 'crypto';
import { signedKeyPair } from '@whiskeysockets/baileys/lib/Utils/crypto.js';

// Generate a fake auth state like Baileys would
const noiseKey = Curve.generateKeyPair();
const signedIdentityKey = Curve.generateKeyPair();
const registrationId = 12345;

// Create signed pre-key (keyId=1)
const spk = signedKeyPair(signedIdentityKey, 1);

const creds = {
    noiseKey,
    signedIdentityKey,
    registrationId,
    advSecretKey: randomBytes(32).toString('base64'),
    signedPreKey: spk,
};

const config = {
    version: [2, 3000, 1027934701],
    browser: ['Windows', 'Desktop', '10.0'],
    countryCode: 'US',
    syncFullHistory: false,
};

const node = generateRegistrationNode(creds, config);
const bytes = proto.ClientPayload.encode(node).finish();

console.log('ClientPayload bytes (hex):');
console.log(Buffer.from(bytes).toString('hex'));
console.log('\nClientPayload JSON:');
console.log(JSON.stringify(node, (key, val) => {
    if (val && val.type === 'Buffer') return Buffer.from(val.data).toString('hex');
    if (val instanceof Uint8Array) return Buffer.from(val).toString('hex');
    return val;
}, 2));

console.log('\ndevicePairingData:');
const dp = node.devicePairingData;
if (dp) {
    console.log('  eRegid:', Buffer.from(dp.eRegid).toString('hex'));
    console.log('  eKeytype:', Buffer.from(dp.eKeytype).toString('hex'));
    console.log('  eIdent (len):', dp.eIdent?.length, Buffer.from(dp.eIdent).toString('hex'));
    console.log('  eSkeyId:', Buffer.from(dp.eSkeyId).toString('hex'));
    console.log('  eSkeyVal (len):', dp.eSkeyVal?.length, Buffer.from(dp.eSkeyVal).toString('hex'));
    console.log('  eSkeySig (len):', dp.eSkeySig?.length);
    console.log('  buildHash:', Buffer.from(dp.buildHash).toString('hex'));
}
