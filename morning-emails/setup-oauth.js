#!/usr/bin/env node

/**
 * OAuth Setup - One-time authentication flow
 * Run this once to authorize Gmail access
 */

import { google } from 'googleapis';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import readline from 'readline';
import dotenv from 'dotenv';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.join(__dirname, '.env') });

const SCOPES = ['https://www.googleapis.com/auth/gmail.readonly'];
const TOKEN_PATH = process.env.GMAIL_TOKEN_PATH || path.join(__dirname, 'token.json');
const CREDENTIALS_PATH = process.env.GMAIL_CREDENTIALS_PATH || path.join(__dirname, 'credentials.json');

/**
 * Get OAuth2 client and generate auth URL
 */
async function authorize() {
  try {
    // Load credentials
    if (!fs.existsSync(CREDENTIALS_PATH)) {
      console.error(`\nCredentials file not found: ${CREDENTIALS_PATH}`);
      console.error('\nPlease download OAuth credentials from Google Cloud Console:');
      console.error('1. Go to https://console.cloud.google.com/');
      console.error('2. Create a project (or select existing)');
      console.error('3. Enable Gmail API');
      console.error('4. Create OAuth 2.0 credentials (Desktop app)');
      console.error('5. Download JSON and save as credentials.json');
      process.exit(1);
    }

    const content = fs.readFileSync(CREDENTIALS_PATH, 'utf8');
    const credentials = JSON.parse(content);

    const { client_secret, client_id, redirect_uris } = credentials.installed || credentials.web;
    const oAuth2Client = new google.auth.OAuth2(client_id, client_secret, redirect_uris[0]);

    // Check if already authorized
    if (fs.existsSync(TOKEN_PATH)) {
      console.log('\nToken already exists. Testing...');
      const token = JSON.parse(fs.readFileSync(TOKEN_PATH, 'utf8'));
      oAuth2Client.setCredentials(token);

      // Test the token
      const gmail = google.gmail({ version: 'v1', auth: oAuth2Client });
      const res = await gmail.users.getProfile({ userId: 'me' });
      console.log(`✓ Already authorized: ${res.data.emailAddress}`);
      console.log('✓ Token is valid');
      return;
    }

    // Generate auth URL
    const authUrl = oAuth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: SCOPES,
    });

    console.log('\n=== Gmail OAuth Setup ===\n');
    console.log('Authorize this app by visiting this URL:');
    console.log('\n' + authUrl + '\n');

    // Get authorization code from user
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    rl.question('Enter the authorization code from that page: ', async (code) => {
      rl.close();

      try {
        const { tokens } = await oAuth2Client.getToken(code);
        oAuth2Client.setCredentials(tokens);

        // Save token
        fs.writeFileSync(TOKEN_PATH, JSON.stringify(tokens, null, 2));
        console.log(`\n✓ Token saved to: ${TOKEN_PATH}`);

        // Test the token
        const gmail = google.gmail({ version: 'v1', auth: oAuth2Client });
        const res = await gmail.users.getProfile({ userId: 'me' });
        console.log(`✓ Authorization successful: ${res.data.emailAddress}`);
        console.log('\nSetup complete! You can now run the morning briefing.');

      } catch (error) {
        console.error('\n✗ Error retrieving access token:', error.message);
        process.exit(1);
      }
    });

  } catch (error) {
    console.error('Error during authorization:', error.message);
    process.exit(1);
  }
}

authorize();
