/**
 * WhatsApp QR Code - Browser Display
 * Generates QR code and displays it in a web browser
 */

const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const SESSION_PATH = 'C:\\scripts\\_machine\\whatsapp-session';
const QR_HTML_PATH = 'C:\\jengo\\documents\\temp\\whatsapp-qr.html';
const QR_IMAGE_PATH = 'C:\\jengo\\documents\\temp\\whatsapp-qr.png';

// Ensure directories exist
if (!fs.existsSync(SESSION_PATH)) {
    fs.mkdirSync(SESSION_PATH, { recursive: true });
}

const tempDir = path.dirname(QR_HTML_PATH);
if (!fs.existsSync(tempDir)) {
    fs.mkdirSync(tempDir, { recursive: true });
}

console.log('Initializing WhatsApp Web client...');

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

let qrDisplayed = false;

// QR Code event - save to file and display in browser
client.on('qr', async (qr) => {
    console.log('QR Code received, generating image and HTML...');

    try {
        // Generate QR code as PNG image
        await qrcode.toFile(QR_IMAGE_PATH, qr, {
            width: 400,
            margin: 2,
            color: {
                dark: '#000000',
                light: '#FFFFFF'
            }
        });

        console.log('QR code image saved:', QR_IMAGE_PATH);

        // Create HTML page with QR code
        const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WhatsApp QR Code - Scan to Link</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        h1 {
            color: #25D366;
            font-size: 2em;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .whatsapp-icon {
            width: 50px;
            height: 50px;
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
            display: block;
            border: 3px solid #25D366;
            border-radius: 10px;
            animation: pulse 2s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% {
                box-shadow: 0 0 0 0 rgba(37, 211, 102, 0.7);
            }
            50% {
                box-shadow: 0 0 20px 10px rgba(37, 211, 102, 0);
            }
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
            font-size: 1.2em;
        }

        .instructions ol {
            padding-left: 20px;
            color: #555;
            line-height: 1.8;
        }

        .instructions li {
            margin: 10px 0;
            font-size: 1.05em;
        }

        .status {
            margin-top: 20px;
            padding: 15px;
            background: #e3f2fd;
            border-radius: 8px;
            color: #1565c0;
            font-weight: 500;
        }

        .status.success {
            background: #e8f5e9;
            color: #2e7d32;
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

        .auto-refresh {
            margin-top: 15px;
            font-size: 0.9em;
            color: #666;
        }
    </style>
    <script>
        // Auto-refresh every 60 seconds to get new QR code
        let countdown = 60;
        let countdownInterval;

        function startCountdown() {
            const countdownEl = document.getElementById('countdown');
            countdownInterval = setInterval(() => {
                countdown--;
                if (countdownEl) {
                    countdownEl.textContent = countdown;
                }
                if (countdown <= 0) {
                    location.reload();
                }
            }, 1000);
        }

        window.addEventListener('load', () => {
            startCountdown();
            // Add cache buster to image URL to ensure fresh QR code
            const qrImg = document.querySelector('.qr-code');
            if (qrImg) {
                const cacheBuster = '?t=' + new Date().getTime();
                qrImg.src = qrImg.src + cacheBuster;
            }
        });

        // Check if we're authenticated
        setInterval(() => {
            // This is a simple check - in production you'd check actual status
            console.log('Checking WhatsApp status...');
        }, 5000);
    </script>
</head>
<body>
    <div class="container">
        <h1>
            <svg class="whatsapp-icon" viewBox="0 0 24 24" fill="#25D366">
                <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
            </svg>
            WhatsApp QR Code
        </h1>
        <div class="subtitle">Scan to link your phone to Jengo</div>

        <div class="qr-container">
            <img src="whatsapp-qr.png" alt="WhatsApp QR Code" class="qr-code" />
        </div>

        <div class="instructions">
            <h3>How to scan:</h3>
            <ol>
                <li>Open <strong>WhatsApp</strong> on your phone</li>
                <li>Tap <strong>Menu</strong> (⋮) or <strong>Settings</strong></li>
                <li>Tap <strong>Linked Devices</strong></li>
                <li>Tap <strong>"Link a Device"</strong></li>
                <li>Point your phone at this QR code</li>
            </ol>
        </div>

        <div class="status">
            <div class="loader"></div>
            Waiting for scan...
        </div>

        <div class="auto-refresh">
            QR code refreshes in <span id="countdown">60</span> seconds
        </div>

        <div class="footer">
            Generated: ${new Date().toLocaleString()}<br>
            Jengo - Autonomous WhatsApp Bridge
        </div>
    </div>
</body>
</html>
        `.trim();

        fs.writeFileSync(QR_HTML_PATH, html);
        console.log('HTML page created:', QR_HTML_PATH);

        if (!qrDisplayed) {
            // Open in default browser
            console.log('Opening QR code in browser...');
            const openCommand = process.platform === 'win32'
                ? `start "" "${QR_HTML_PATH}"`
                : process.platform === 'darwin'
                ? `open "${QR_HTML_PATH}"`
                : `xdg-open "${QR_HTML_PATH}"`;

            exec(openCommand, (error) => {
                if (error) {
                    console.error('Error opening browser:', error);
                    console.log('Please manually open:', QR_HTML_PATH);
                } else {
                    console.log('Browser opened successfully!');
                }
            });

            qrDisplayed = true;
        }
    } catch (error) {
        console.error('Error generating QR code:', error);
    }
});

// Ready event
client.on('ready', () => {
    console.log('');
    console.log('✓ WhatsApp connected successfully!');
    console.log('✓ You can close the browser window now.');
    console.log('');
    process.exit(0);
});

// Authenticated event
client.on('authenticated', () => {
    console.log('✓ WhatsApp authenticated');
});

// Disconnected event
client.on('disconnected', (reason) => {
    console.log('✗ WhatsApp disconnected:', reason);
    process.exit(1);
});

// Initialize client
console.log('Starting WhatsApp Web...');
client.initialize().catch(err => {
    console.error('Initialization error:', err);
    process.exit(1);
});

// Keep alive for 5 minutes, then exit
setTimeout(() => {
    console.log('Timeout: No scan received within 5 minutes');
    process.exit(1);
}, 300000);
