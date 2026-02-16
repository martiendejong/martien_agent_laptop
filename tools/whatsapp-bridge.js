/**
 * WhatsApp Bridge - Autonomous WhatsApp messaging via WhatsApp Web
 *
 * Usage:
 *   node whatsapp-bridge.js init              # Display QR code for linking
 *   node whatsapp-bridge.js send <number> <message>
 *   node whatsapp-bridge.js status            # Check connection status
 *
 * Dependencies: whatsapp-web.js, qrcode-terminal
 * Install: npm install whatsapp-web.js qrcode-terminal
 */

const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const fs = require('fs');
const path = require('path');

const SESSION_PATH = 'C:\\scripts\\_machine\\whatsapp-session';
const LOG_FILE = 'C:\\scripts\\_machine\\whatsapp.log';

// Ensure session directory exists
if (!fs.existsSync(SESSION_PATH)) {
    fs.mkdirSync(SESSION_PATH, { recursive: true });
}

// Create WhatsApp client with persistent session
const client = new Client({
    authStrategy: new LocalAuth({
        dataPath: SESSION_PATH
    }),
    puppeteer: {
        headless: true,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-accelerated-2d-canvas',
            '--no-first-run',
            '--no-zygote',
            '--disable-gpu'
        ]
    }
});

function log(message) {
    const timestamp = new Date().toISOString();
    const logLine = `${timestamp} - ${message}\n`;
    console.log(logLine.trim());
    fs.appendFileSync(LOG_FILE, logLine);
}

// QR Code event - display for user to scan
client.on('qr', (qr) => {
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
});

// Ready event - client authenticated and ready
client.on('ready', () => {
    console.log('✓ WhatsApp client is ready!');
    log('WhatsApp client authenticated and ready');
});

// Authenticated event
client.on('authenticated', () => {
    console.log('✓ WhatsApp authenticated');
    log('WhatsApp authenticated successfully');
});

// Disconnected event
client.on('disconnected', (reason) => {
    console.log('✗ WhatsApp disconnected:', reason);
    log(`WhatsApp disconnected: ${reason}`);
});

// Message received event (for monitoring)
client.on('message', async (message) => {
    log(`Message from ${message.from}: ${message.body.substring(0, 50)}...`);
});

// Parse command line arguments
const args = process.argv.slice(2);
const command = args[0];

async function sendMessage(phoneNumber, message) {
    try {
        // Format phone number (remove spaces, dashes, etc.)
        let formatted = phoneNumber.replace(/\D/g, '');

        // Add country code if missing (default to Netherlands +31)
        if (!formatted.startsWith('31') && !formatted.startsWith('254')) {
            // Kenya = 254, Netherlands = 31
            // Detect based on length (Kenya mobile = 10 digits without country code)
            if (formatted.length === 10 && formatted.startsWith('0')) {
                formatted = '254' + formatted.substring(1); // Kenya
            } else if (formatted.length === 9) {
                formatted = '31' + formatted; // Netherlands
            }
        }

        const chatId = formatted + '@c.us';

        log(`Attempting to send message to ${chatId}`);
        console.log(`Sending to: ${chatId}`);

        await client.sendMessage(chatId, message);

        console.log('✓ Message sent successfully');
        log(`Message sent successfully to ${chatId}`);

        process.exit(0);
    } catch (error) {
        console.error('✗ Error sending message:', error.message);
        log(`Error sending message: ${error.message}`);
        process.exit(1);
    }
}

async function checkStatus() {
    try {
        const state = await client.getState();
        console.log('WhatsApp Status:', state);
        log(`Status check: ${state}`);

        if (state === 'CONNECTED') {
            const info = client.info;
            console.log('Connected as:', info.pushname);
            console.log('Phone:', info.wid.user);
        }

        process.exit(0);
    } catch (error) {
        console.error('Error checking status:', error.message);
        process.exit(1);
    }
}

// Main execution
(async () => {
    if (!command) {
        console.log('WhatsApp Bridge Usage:');
        console.log('  node whatsapp-bridge.js init                  # Show QR code for linking');
        console.log('  node whatsapp-bridge.js send <number> <msg>   # Send message');
        console.log('  node whatsapp-bridge.js status                # Check status');
        console.log('');
        console.log('Examples:');
        console.log('  node whatsapp-bridge.js init');
        console.log('  node whatsapp-bridge.js send 254712345678 "Hello from Jengo"');
        console.log('  node whatsapp-bridge.js send +31612345678 "Test message"');
        process.exit(0);
    }

    // Initialize client
    await client.initialize();

    // Wait for ready state
    await new Promise((resolve) => {
        client.on('ready', resolve);

        // Timeout after 2 minutes
        setTimeout(() => {
            console.error('✗ Timeout waiting for WhatsApp connection');
            process.exit(1);
        }, 120000);
    });

    // Execute command
    if (command === 'init') {
        console.log('WhatsApp initialized. Press Ctrl+C to exit.');
        console.log('Session will be saved for future use.');
        // Keep running to maintain connection

    } else if (command === 'send') {
        const phoneNumber = args[1];
        const message = args.slice(2).join(' ');

        if (!phoneNumber || !message) {
            console.error('Usage: node whatsapp-bridge.js send <number> <message>');
            process.exit(1);
        }

        await sendMessage(phoneNumber, message);

    } else if (command === 'status') {
        await checkStatus();

    } else {
        console.error('Unknown command:', command);
        console.error('Use: init, send, or status');
        process.exit(1);
    }
})();
