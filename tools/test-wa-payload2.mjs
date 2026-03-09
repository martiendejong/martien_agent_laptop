import { proto } from '@whiskeysockets/baileys/WAProto/index.js';
import { generateRegistrationNode } from '@whiskeysockets/baileys/lib/Utils/validate-connection.js';
import { Curve, signedKeyPair } from '@whiskeysockets/baileys/lib/Utils/crypto.js';
import { randomBytes } from 'crypto';

const signedIdentityKey = Curve.generateKeyPair();
const spk = signedKeyPair(signedIdentityKey, 1);

console.log('signature full len:', spk.signature.length);
console.log('signature hex:', Buffer.from(spk.signature).toString('hex'));

// Also check libsignal sign directly
import * as curve from 'libsignal/src/curve.js';
const pub33 = Buffer.concat([Buffer.from([5]), Buffer.from(spk.keyPair.public)]);
const sig = curve.calculateSignature(Buffer.from(signedIdentityKey.private), pub33);
console.log('raw calculateSignature len:', sig.length);
