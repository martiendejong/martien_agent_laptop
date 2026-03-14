// Verify Dawa's Signal crypto values against Node.js reference implementation
// Uses the exact same intermediate values from Dawa's debug log

const crypto = require('crypto');

// HKDF-SHA256 implementation (matches Signal/Baileys)
function hkdf(ikm, salt, info, length) {
    // Extract
    const prk = crypto.createHmac('sha256', salt).update(ikm).digest();
    // Expand
    const infoBuffer = Buffer.from(info);
    let t = Buffer.alloc(0);
    const output = Buffer.alloc(length);
    let written = 0;
    let counter = 1;
    while (written < length) {
        const block = Buffer.concat([t, infoBuffer, Buffer.from([counter++])]);
        t = crypto.createHmac('sha256', prk).update(block).digest();
        const take = Math.min(t.length, length - written);
        t.copy(output, written, 0, take);
        written += take;
    }
    return output;
}

// Values from Dawa debug log
const dh1 = Buffer.from('3B394D953ED8AE4CD4EDBAD5247E6D0691E6AEF9B5DF7D3B0874915759381400', 'hex');
const dh2 = Buffer.from('34424C0A23CBFDA4D6CE17695FBD5624F122EC32A2EC096BDEF943CDC1A1FC3E', 'hex');
const dh3 = Buffer.from('E8CD04DD8D7EE7F108C7988F49DB40D76F938DD2A4F8BB8E5ADDF753E24B9306', 'hex');
const dh4 = Buffer.from('C798B135C23AB2A8AABD73BED7D2A9B8BF3721424D3C840CA74061C55C6A2A60', 'hex');

const ratchetDH = Buffer.from('5A31D6EC446E65D30636F2571B4C31B1BCF3BAB86DE089123398185182913F64', 'hex');

// 1. Compute master secret
const f = Buffer.alloc(32, 0xFF);
const masterSecret = Buffer.concat([f, dh1, dh2, dh3, dh4]);
console.log(`masterSecret len=${masterSecret.length} first8=${masterSecret.slice(0, 8).toString('hex').toUpperCase()}`);

// 2. HKDF to get rootKey0
const zeroSalt = Buffer.alloc(32, 0);
const derived = hkdf(masterSecret, zeroSalt, 'WhisperText', 64);
const rootKey0 = derived.slice(0, 32);
const chainKey0 = derived.slice(32, 64);
console.log(`rootKey0=${rootKey0.toString('hex').toUpperCase()}`);
console.log(`chainKey0=${chainKey0.toString('hex').toUpperCase()} (unused for initiator)`);

// Dawa's rootKey0
console.log(`Dawa rootKey0=05C121D93F1703A5C6E2B89EE1760A09A9FD5ABC5779A6A05622D1F13434DFF2`);
console.log(`MATCH rootKey0: ${rootKey0.toString('hex').toUpperCase() === '05C121D93F1703A5C6E2B89EE1760A09A9FD5ABC5779A6A05622D1F13434DFF2'}`);

// 3. Ratchet step: HKDF(salt=rootKey0, ikm=ratchetDH, info="WhisperRatchet", 64)
const ratchetDerived = hkdf(ratchetDH, rootKey0, 'WhisperRatchet', 64);
const rootKey2 = ratchetDerived.slice(0, 32);
const sendChainKey = ratchetDerived.slice(32, 64);
console.log(`\nrootKey2=${rootKey2.toString('hex').toUpperCase()}`);
console.log(`Dawa rootKey2=4FE6260BF68DF9E7D30A77A85F522DEDE1784CD6001B4D3375DF4FBC1AAE4288`);
console.log(`MATCH rootKey2: ${rootKey2.toString('hex').toUpperCase() === '4FE6260BF68DF9E7D30A77A85F522DEDE1784CD6001B4D3375DF4FBC1AAE4288'}`);

console.log(`\nsendChainKey=${sendChainKey.toString('hex').toUpperCase()}`);
console.log(`Dawa sendChainKey=E0FA25E8D3D53FB87F6F578CE106505CE8E9C8937BF1BA6FAA2CD2322CDDF7AF`);
console.log(`MATCH sendChainKey: ${sendChainKey.toString('hex').toUpperCase() === 'E0FA25E8D3D53FB87F6F578CE106505CE8E9C8937BF1BA6FAA2CD2322CDDF7AF'}`);

// 4. Message key derivation
const messageKey = crypto.createHmac('sha256', sendChainKey).update(Buffer.from([0x01])).digest();
const nextChainKey = crypto.createHmac('sha256', sendChainKey).update(Buffer.from([0x02])).digest();
console.log(`\nmessageKey=${messageKey.toString('hex').toUpperCase()}`);
console.log(`Dawa messageKey=DA0804594345C5B6B438082FD659307F10549DCAC705D520B5D215053AD9147A`);
console.log(`MATCH messageKey: ${messageKey.toString('hex').toUpperCase() === 'DA0804594345C5B6B438082FD659307F10549DCAC705D520B5D215053AD9147A'}`);

console.log(`\nnextChainKey=${nextChainKey.toString('hex').toUpperCase()}`);
console.log(`Dawa nextChainKey=5D97F574874F1BA841AF8EA6B8501A7312C328D62A51E80D896EE5ABB83B0B61`);
console.log(`MATCH nextChainKey: ${nextChainKey.toString('hex').toUpperCase() === '5D97F574874F1BA841AF8EA6B8501A7312C328D62A51E80D896EE5ABB83B0B61'}`);

// 5. Expand message key to get encKey, macKey, iv
const keyMaterial = hkdf(messageKey, Buffer.alloc(32, 0), 'WhisperMessageKeys', 80);
const encKey = keyMaterial.slice(0, 32);
const macKey = keyMaterial.slice(32, 64);
const iv = keyMaterial.slice(64, 80);
console.log(`\nencKey=${encKey.toString('hex').toUpperCase()}`);
console.log(`Dawa encKey=1794CBAA97B9D8097477376CE0C95554BE2CECE15B1E7EB6527C51CB2C855FB8`);
console.log(`MATCH encKey: ${encKey.toString('hex').toUpperCase() === '1794CBAA97B9D8097477376CE0C95554BE2CECE15B1E7EB6527C51CB2C855FB8'}`);

console.log(`\nmacKey=${macKey.toString('hex').toUpperCase()}`);
console.log(`Dawa macKey=2FE6C6A024E2A6C0B9267FE2DE2D4463ACBF863940257F1309C04D45F962AEB4`);
console.log(`MATCH macKey: ${macKey.toString('hex').toUpperCase() === '2FE6C6A024E2A6C0B9267FE2DE2D4463ACBF863940257F1309C04D45F962AEB4'}`);

console.log(`\niv=${iv.toString('hex').toUpperCase()}`);
console.log(`Dawa iv=938A23C5949D17862B531B35BCF55A56`);
console.log(`MATCH iv: ${iv.toString('hex').toUpperCase() === '938A23C5949D17862B531B35BCF55A56'}`);

// 6. Verify AES-CBC encryption
const plaintext = Buffer.from('0A1D54657374206D6573736167652066726F6D20446177612062726964676506060606060606', 'hex');
// Wait, the debug log says plaintext len=45 first16=0A1D54657374206D6573736167652066
// 45 bytes = 31 bytes proto + 14 bytes random padding? No...
// "Test message from Dawa bridge" = 30 chars
// Proto: 0A (tag1,wire2) + 1D (29 length) + "Test message from Dawa bridge" (29 bytes) = 31 bytes
// Padding: 45 - 31 = 14 bytes of value 14 (0x0E)
// AES-CBC on 45 bytes = 45 + (16-45%16) = 45 + 3 = 48 bytes (PKCS7 adds 3 bytes of 0x03)

console.log(`\nPlaintext len=45 (proto 31 + pad 14)`);
// We can't fully verify the AES because the random padding is... random. But we can check the structure.

// 7. Verify MAC
const protoBytes = Buffer.from('0A21059002473F077728A680B95164EAF4191756E3A23C1450902E556A0D431EC511161000180022305BF8556F9FCC6892DF441D890CA06975B1B292CC3271CEFAA5145A968148864A374456A5C391DA01864F6FCC750A8F26', 'hex');
const ourIdentity33 = Buffer.from('0516E7538C79E50AAC4B3818C84DBC1F928D6118B1A43953016685A9658537DA19', 'hex');
const theirIdentity33 = Buffer.from('05E9B26CFC3AAEC3FFC7D3BCE4F1592BE556B482877EA89194FB0E26617C0EEB7C', 'hex');

const macInput = Buffer.concat([ourIdentity33, theirIdentity33, Buffer.from([0x33]), protoBytes]);
const fullMac = crypto.createHmac('sha256', macKey).update(macInput).digest();
const mac = fullMac.slice(0, 8);
console.log(`\nmac=${mac.toString('hex').toUpperCase()}`);
console.log(`Dawa mac=E8F5302C70E49389`);
console.log(`MATCH mac: ${mac.toString('hex').toUpperCase() === 'E8F5302C70E49389'}`);

console.log('\n=== SUMMARY ===');
console.log('If all MATCH=true, the crypto is identical to Baileys.');
console.log('If any MATCH=false, that step is where the divergence happens.');
