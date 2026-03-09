import { proto } from '@whiskeysockets/baileys/WAProto/index.js';
import { generateRegistrationNode } from '@whiskeysockets/baileys/lib/Utils/validate-connection.js';
import { Curve, signedKeyPair } from '@whiskeysockets/baileys/lib/Utils/crypto.js';
import { randomBytes } from 'crypto';

const noiseKey = Curve.generateKeyPair();
const signedIdentityKey = Curve.generateKeyPair();
const registrationId = 12345;
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

console.log('Total bytes:', bytes.length);
console.log('Hex:', Buffer.from(bytes).toString('hex'));

const dp = node.devicePairingData;
if (dp) {
    console.log('\neRegid len:', dp.eRegid?.length, '=', Buffer.from(dp.eRegid).toString('hex'));
    console.log('eKeytype:', Buffer.from(dp.eKeytype).toString('hex'));
    console.log('eIdent len:', dp.eIdent?.length);
    console.log('eSkeyId:', Buffer.from(dp.eSkeyId).toString('hex'));
    console.log('eSkeyVal len:', dp.eSkeyVal?.length);
    console.log('eSkeySig len:', dp.eSkeySig?.length);
    console.log('buildHash:', Buffer.from(dp.buildHash).toString('hex'));
    console.log('deviceProps len:', dp.deviceProps?.length);
}

// UserAgent
const ua = node.userAgent;
console.log('\nUserAgent platform:', ua.platform);
console.log('UserAgent appVersion:', ua.appVersion.primary + '.' + ua.appVersion.secondary + '.' + ua.appVersion.tertiary);
console.log('connectType:', node.connectType);
console.log('connectReason:', node.connectReason);
console.log('passive:', node.passive);
console.log('pull:', node.pull);
