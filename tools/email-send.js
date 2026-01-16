#!/usr/bin/env node
/**
 * Email Send Tool - Send emails via SMTP
 *
 * Usage:
 *   node email-send.js --to "email@example.com" --subject "Subject" --body "Body text" --attachment "path/to/file"
 */

const nodemailer = require('nodemailer');
const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const getArg = (name) => args.find(a => a.startsWith(`--${name}=`))?.split('=').slice(1).join('=');

const to = getArg('to');
const subject = getArg('subject');
const bodyFile = getArg('body-file');
const bodyText = getArg('body');
const attachment = getArg('attachment');
const from = getArg('from') || 'info@martiendejong.nl';

if (!to || !subject || (!bodyFile && !bodyText)) {
  console.error('Usage: node email-send.js --to "email@example.com" --subject "Subject" --body "Text" --attachment "path"');
  console.error('   Or: node email-send.js --to "email@example.com" --subject "Subject" --body-file "path/to/body.txt" --attachment "path"');
  process.exit(1);
}

// SMTP configuration for info@martiendejong.nl
const smtpConfig = {
  host: 'mail.zxcs.nl',
  port: 587, // Try STARTTLS first
  secure: false, // true for 465, false for other ports
  auth: {
    user: 'info@martiendejong.nl',
    pass: 'hLPFy6MdUnfEDbYTwXps'
  },
  tls: {
    rejectUnauthorized: false
  }
};

async function sendEmail() {
  console.log('Creating SMTP transporter...');
  const transporter = nodemailer.createTransport(smtpConfig);

  // Read body from file if specified
  let body = bodyText;
  if (bodyFile) {
    if (!fs.existsSync(bodyFile)) {
      console.error(`Body file not found: ${bodyFile}`);
      process.exit(1);
    }
    body = fs.readFileSync(bodyFile, 'utf8');
  }

  // Prepare email options
  const mailOptions = {
    from: `Martien de Jong <${from}>`,
    to: to,
    subject: subject,
    text: body
  };

  // Add attachment if specified
  if (attachment) {
    if (!fs.existsSync(attachment)) {
      console.error(`Attachment not found: ${attachment}`);
      process.exit(1);
    }

    const filename = path.basename(attachment);
    mailOptions.attachments = [{
      filename: filename,
      path: attachment
    }];

    console.log(`Attachment: ${filename} (${fs.statSync(attachment).size} bytes)`);
  }

  try {
    console.log('\nSending email...');
    console.log(`From: ${mailOptions.from}`);
    console.log(`To: ${to}`);
    console.log(`Subject: ${subject}`);
    console.log(`Body length: ${body.length} characters`);

    const info = await transporter.sendMail(mailOptions);

    console.log('\n✅ Email sent successfully!');
    console.log(`Message ID: ${info.messageId}`);
    console.log(`Response: ${info.response}`);

  } catch (error) {
    console.error('\n❌ Failed to send email:');
    console.error(error.message);

    // If port 587 failed, suggest trying port 465
    if (error.code === 'ECONNECTION' || error.code === 'ETIMEDOUT') {
      console.log('\n💡 Tip: Try with port 465 (SSL) instead by editing the script');
    }

    process.exit(1);
  }
}

// Verify SMTP connection first
console.log('Verifying SMTP connection...');
const transporter = nodemailer.createTransport(smtpConfig);

transporter.verify()
  .then(() => {
    console.log('✅ SMTP server is ready');
    return sendEmail();
  })
  .catch((error) => {
    console.error('❌ SMTP connection failed:');
    console.error(error.message);

    console.log('\n💡 Trying to send anyway...');
    sendEmail();
  });
