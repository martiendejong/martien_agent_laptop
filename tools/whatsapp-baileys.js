/**
 * WhatsApp Bridge using Baileys
 * Better compatibility than whatsapp-web.js
 */

const { default: makeWASocket, DisconnectReason, useMultiFileAuthState } = require('@whiskeysockets/baileys');
const qrcode = require('qrcode-terminal');
const fs = require('fs');
const { Boom } = require('@hapi/boom');

const AUTH_DIR = 'C:\\scripts\\_machine\\baileys-session';
const LOG_FILE = 'C:\\scripts\\_machine\\whatsapp-baileys.log';

function log(message) {
    const timestamp = new Date().toISOString();
    const logLine = `${timestamp} - ${message}\n`;
    console.log(logLine.trim());
    fs.appendFileSync(LOG_FILE, logLine);
}

async function connectToWhatsApp(onReady) {
    // Ensure auth directory exists
    if (!fs.existsSync(AUTH_DIR)) {
        fs.mkdirSync(AUTH_DIR, { recursive: true });
    }

    const { state, saveCreds } = await useMultiFileAuthState(AUTH_DIR);

    const sock = makeWASocket({
        auth: state,
        printQRInTerminal: false,  // We'll handle QR display ourselves
    });

    sock.ev.on('creds.update', saveCreds);

    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update;

        // Display QR code
        if (qr) {
            console.log('\n==================================================');
            console.log('WhatsApp QR Code - Scan with your phone');
            console.log('==================================================\n');
            qrcode.generate(qr, { small: true });
            console.log('\n==================================================');
            console.log('Instructions:');
            console.log('1. Open WhatsApp on your phone');
            console.log('2. Tap Menu > Linked Devices');
            console.log('3. Tap "Link a Device"');
            console.log('4. Scan the QR code above');
            console.log('==================================================\n');
            log('QR code generated, waiting for scan...');
        }

        if (connection === 'close') {
            const shouldReconnect = (lastDisconnect?.error instanceof Boom)
                ? lastDisconnect.error.output.statusCode !== DisconnectReason.loggedOut
                : true;

            log(`Connection closed. Reconnect: ${shouldReconnect}`);

            if (shouldReconnect) {
                log('Reconnecting...');
                connectToWhatsApp(onReady);
            }
        } else if (connection === 'open') {
            log('WhatsApp connected successfully!');
            console.log('\n✓ WhatsApp connected successfully!\n');
            if (onReady) onReady(sock);
        }
    });

    // Log incoming messages
    sock.ev.on('messages.upsert', async ({ messages }) => {
        for (const msg of messages) {
            if (!msg.key.fromMe && msg.message) {
                const from = msg.key.remoteJid;
                const text = msg.message.conversation || msg.message.extendedTextMessage?.text || '';
                log(`Message from ${from}: ${text.substring(0, 50)}`);
            }
        }
    });

    return sock;
}

async function sendMessage(sock, phoneNumber, message) {
    try {
        // Format phone number - Baileys format: country code + number + @s.whatsapp.net
        let formatted = phoneNumber.replace(/\D/g, ''); // Remove non-digits

        // Remove leading + if present
        if (phoneNumber.startsWith('+')) {
            formatted = phoneNumber.substring(1).replace(/\D/g, '');
        }

        // For Netherlands numbers starting with 0, add country code
        if (formatted.startsWith('0') && formatted.length === 10) {
            formatted = '31' + formatted.substring(1);
        }

        const jid = formatted + '@s.whatsapp.net';

        log(`Sending message to ${jid}`);
        console.log(`Sending to: ${jid}`);

        await sock.sendMessage(jid, { text: message });

        log(`Message sent successfully to ${jid}`);
        console.log('✓ Message sent successfully!');

        return true;
    } catch (error) {
        log(`Error sending message: ${error.message}`);
        console.error('✗ Error sending message:', error.message);
        return false;
    }
}

// Command line interface
const args = process.argv.slice(2);
const command = args[0];

(async () => {
    if (!command) {
        console.log('WhatsApp Baileys Bridge Usage:');
        console.log('  node whatsapp-baileys.js init');
        console.log('  node whatsapp-baileys.js send <number> <message>');
        console.log('');
        console.log('Examples:');
        console.log('  node whatsapp-baileys.js init');
        console.log('  node whatsapp-baileys.js send +31633984381 "Hello!"');
        console.log('  node whatsapp-baileys.js send 0633984381 "Test message"');
        process.exit(0);
    }

    if (command === 'init') {
        console.log('Initializing WhatsApp...');
        await connectToWhatsApp(() => {
            console.log('WhatsApp is ready! Press Ctrl+C to exit.');
        });

        // Keep running
        await new Promise(() => {});

    } else if (command === 'send') {
        const phoneNumber = args[1];
        const message = args.slice(2).join(' ');

        if (!phoneNumber || !message) {
            console.error('Usage: node whatsapp-baileys.js send <number> <message>');
            process.exit(1);
        }

        console.log('Connecting to WhatsApp...');

        const sock = await connectToWhatsApp(async (socket) => {
            await sendMessage(socket, phoneNumber, message);
            process.exit(0);
        });

        // Timeout after 2 minutes
        setTimeout(() => {
            console.error('Timeout waiting for WhatsApp connection');
            process.exit(1);
        }, 120000);
    }
})();
