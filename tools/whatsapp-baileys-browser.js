/**
 * WhatsApp Baileys - Browser QR Display
 */

const { default: makeWASocket, DisconnectReason, useMultiFileAuthState } = require('@whiskeysockets/baileys');
const qrcode = require('qrcode');
const fs = require('fs');
const { exec } = require('child_process');
const { Boom } = require('@hapi/boom');

const AUTH_DIR = 'C:\\scripts\\_machine\\baileys-session';
const QR_HTML_PATH = 'C:\\jengo\\documents\\temp\\baileys-qr.html';
const QR_IMAGE_PATH = 'C:\\jengo\\documents\\temp\\baileys-qr.png';
const LOG_FILE = 'C:\\scripts\\_machine\\whatsapp-baileys.log';

function log(message) {
    const timestamp = new Date().toISOString();
    const logLine = `${timestamp} - ${message}\n`;
    console.log(logLine.trim());
    fs.appendFileSync(LOG_FILE, logLine);
}

let browserOpened = false;

async function openQRInBrowser(qrData) {
    try {
        // Generate QR code as PNG
        await qrcode.toFile(QR_IMAGE_PATH, qrData, {
            width: 400,
            margin: 2,
            color: { dark: '#000000', light: '#FFFFFF' }
        });

        console.log('QR code image saved:', QR_IMAGE_PATH);

        // Create HTML page
        const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WhatsApp Baileys QR Code</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #25D366 0%, #128C7E 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
            text-align: center;
            max-width: 500px;
            animation: slideIn 0.5s ease-out;
        }
        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        h1 {
            color: #25D366;
            font-size: 2em;
            margin-bottom: 10px;
        }
        .badge {
            display: inline-block;
            background: #128C7E;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.8em;
            margin-bottom: 20px;
        }
        .subtitle {
            color: #666;
            font-size: 1.1em;
            margin-bottom: 30px;
        }
        .qr-container {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 30px;
            margin: 20px 0;
            display: inline-block;
        }
        .qr-code {
            width: 400px;
            height: 400px;
            border: 3px solid #25D366;
            border-radius: 10px;
            animation: pulse 2s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { box-shadow: 0 0 0 0 rgba(37, 211, 102, 0.7); }
            50% { box-shadow: 0 0 20px 10px rgba(37, 211, 102, 0); }
        }
        .instructions {
            text-align: left;
            margin-top: 30px;
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #25D366;
        }
        .instructions h3 {
            color: #333;
            margin-bottom: 15px;
        }
        .instructions ol {
            padding-left: 20px;
            color: #555;
            line-height: 1.8;
        }
        .instructions li {
            margin: 10px 0;
        }
        .status {
            margin-top: 20px;
            padding: 15px;
            background: #e3f2fd;
            border-radius: 8px;
            color: #1565c0;
            font-weight: 500;
        }
        .loader {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #25D366;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            animation: spin 1s linear infinite;
            display: inline-block;
            margin-right: 10px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .footer {
            margin-top: 30px;
            color: #999;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 WhatsApp Baileys</h1>
        <div class="badge">Using Baileys Library (like ClawBot)</div>
        <div class="subtitle">Scan to connect</div>

        <div class="qr-container">
            <img src="baileys-qr.png?t=${Date.now()}" alt="QR Code" class="qr-code" />
        </div>

        <div class="instructions">
            <h3>How to scan:</h3>
            <ol>
                <li>Open <strong>WhatsApp</strong> on your phone</li>
                <li>Tap <strong>Menu</strong> (⋮) or <strong>Settings</strong></li>
                <li>Tap <strong>Linked Devices</strong></li>
                <li>Tap <strong>"Link a Device"</strong></li>
                <li>Point your camera at this QR code</li>
            </ol>
        </div>

        <div class="status">
            <div class="loader"></div>
            Waiting for scan...
        </div>

        <div class="footer">
            Generated: ${new Date().toLocaleString()}<br>
            Jengo - WhatsApp Baileys Bridge
        </div>
    </div>
</body>
</html>
        `.trim();

        fs.writeFileSync(QR_HTML_PATH, html);
        console.log('HTML page created:', QR_HTML_PATH);

        if (!browserOpened) {
            const openCommand = `start "" "${QR_HTML_PATH}"`;
            exec(openCommand, (error) => {
                if (error) {
                    console.error('Error opening browser:', error);
                } else {
                    console.log('Browser opened successfully!');
                }
            });
            browserOpened = true;
        }

    } catch (error) {
        console.error('Error creating QR display:', error);
    }
}

async function connectToWhatsApp() {
    if (!fs.existsSync(AUTH_DIR)) {
        fs.mkdirSync(AUTH_DIR, { recursive: true });
    }

    const { state, saveCreds } = await useMultiFileAuthState(AUTH_DIR);

    const sock = makeWASocket({
        auth: state,
        printQRInTerminal: false,
    });

    sock.ev.on('creds.update', saveCreds);

    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update;

        if (qr) {
            log('QR code generated, opening in browser...');
            console.log('QR code received, opening browser...');
            await openQRInBrowser(qr);
        }

        if (connection === 'close') {
            const shouldReconnect = (lastDisconnect?.error instanceof Boom)
                ? lastDisconnect.error.output.statusCode !== DisconnectReason.loggedOut
                : true;

            if (shouldReconnect) {
                log('Reconnecting...');
                connectToWhatsApp();
            }
        } else if (connection === 'open') {
            log('WhatsApp connected successfully!');
            console.log('\n✓ WhatsApp connected! You can close the browser.\n');

            // Send test message
            const testNumber = '31633984381';
            const testJid = testNumber + '@s.whatsapp.net';

            try {
                await sock.sendMessage(testJid, { text: 'Baileys connected! Testing message delivery...' });
                log('Test message sent to ' + testNumber);
                console.log('✓ Test message sent to your number!');
            } catch (err) {
                log('Test message failed: ' + err.message);
                console.log('✗ Test message failed:', err.message);
            }

            console.log('\nKeeping connection alive. Press Ctrl+C to exit.');
        }
    });

    return sock;
}

console.log('Initializing WhatsApp Baileys...');
connectToWhatsApp().catch(err => {
    console.error('Error:', err);
    process.exit(1);
});
