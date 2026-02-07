#!/usr/bin/env node

/**
 * Morning Email Briefing - Gmail Fetcher
 * Fetches unread emails and generates natural language summary
 */

import { google } from 'googleapis';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config({ path: path.join(__dirname, '.env') });

// Configuration
const SCOPES = ['https://www.googleapis.com/auth/gmail.readonly'];
const TOKEN_PATH = process.env.GMAIL_TOKEN_PATH || path.join(__dirname, 'token.json');
const CREDENTIALS_PATH = process.env.GMAIL_CREDENTIALS_PATH || path.join(__dirname, 'credentials.json');

// Noise filters
const NOISE_FILTERS = {
  clickUpSelf: (email) => {
    // Filter ClickUp notifications triggered by myself
    return email.from?.includes('notifications@clickup.com') &&
           (email.snippet?.includes('You ') || email.snippet?.includes('you '));
  },
  automatedReviews: (email) => {
    // Filter automated code review comments
    const autoReviewKeywords = [
      'codecov',
      'dependabot',
      'github-actions',
      'automated review',
      'CI/CD',
      'build succeeded',
      'build failed'
    ];
    return autoReviewKeywords.some(keyword =>
      email.from?.toLowerCase().includes(keyword) ||
      email.subject?.toLowerCase().includes(keyword)
    );
  },
  autoMigrations: (email) => {
    // Filter auto-migration notices
    const migrationKeywords = [
      'auto-migration',
      'database migration',
      'schema update',
      'migration completed'
    ];
    return migrationKeywords.some(keyword =>
      email.subject?.toLowerCase().includes(keyword) ||
      email.snippet?.toLowerCase().includes(keyword)
    );
  }
};

/**
 * Load OAuth2 credentials
 */
async function loadCredentials() {
  try {
    const content = fs.readFileSync(CREDENTIALS_PATH, 'utf8');
    const credentials = JSON.parse(content);

    const { client_secret, client_id, redirect_uris } = credentials.installed || credentials.web;
    const oAuth2Client = new google.auth.OAuth2(client_id, client_secret, redirect_uris[0]);

    // Load token
    if (fs.existsSync(TOKEN_PATH)) {
      const token = JSON.parse(fs.readFileSync(TOKEN_PATH, 'utf8'));
      oAuth2Client.setCredentials(token);
    } else {
      throw new Error(`Token file not found at ${TOKEN_PATH}. Please run authentication first.`);
    }

    return oAuth2Client;
  } catch (error) {
    console.error('Error loading credentials:', error.message);
    process.exit(1);
  }
}

/**
 * Fetch unread emails
 */
async function fetchUnreadEmails(auth) {
  const gmail = google.gmail({ version: 'v1', auth });

  try {
    // Get list of unread messages
    const res = await gmail.users.messages.list({
      userId: 'me',
      q: 'is:unread',
      maxResults: 50
    });

    const messages = res.data.messages || [];

    if (messages.length === 0) {
      return [];
    }

    // Fetch full message details
    const emails = await Promise.all(
      messages.map(async (message) => {
        const msg = await gmail.users.messages.get({
          userId: 'me',
          id: message.id,
          format: 'metadata',
          metadataHeaders: ['From', 'Subject', 'Date']
        });

        const headers = msg.data.payload.headers;
        const from = headers.find(h => h.name === 'From')?.value || '';
        const subject = headers.find(h => h.name === 'Subject')?.value || '';
        const date = headers.find(h => h.name === 'Date')?.value || '';

        return {
          id: message.id,
          from,
          subject,
          date,
          snippet: msg.data.snippet || ''
        };
      })
    );

    return emails;
  } catch (error) {
    console.error('Error fetching emails:', error.message);
    return [];
  }
}

/**
 * Filter out automated noise
 */
function filterNoise(emails) {
  return emails.filter(email => {
    // Apply all noise filters
    return !Object.values(NOISE_FILTERS).some(filter => filter(email));
  });
}

/**
 * Generate natural language summary
 */
function generateSummary(emails) {
  if (emails.length === 0) {
    return "Good morning! You have no important unread emails. You're all caught up!";
  }

  let summary = `Good morning! You have ${emails.length} important unread email${emails.length > 1 ? 's' : ''}.\n\n`;

  // Group by sender
  const bySender = emails.reduce((acc, email) => {
    const sender = email.from.replace(/<.*>/, '').trim();
    if (!acc[sender]) acc[sender] = [];
    acc[sender].push(email);
    return acc;
  }, {});

  // Generate friendly summaries
  Object.entries(bySender).forEach(([sender, senderEmails], index) => {
    if (senderEmails.length === 1) {
      summary += `${index + 1}. ${sender} sent you: "${senderEmails[0].subject}"\n`;
    } else {
      summary += `${index + 1}. ${sender} sent you ${senderEmails.length} emails:\n`;
      senderEmails.forEach(email => {
        summary += `   - "${email.subject}"\n`;
      });
    }
  });

  summary += `\nThat's all for now. Have a productive day!`;

  return summary;
}

/**
 * Main execution
 */
async function main() {
  const testMode = process.argv.includes('--test');

  if (testMode) {
    console.log('Running in test mode...');
    const testEmails = [
      { from: 'John Doe <john@example.com>', subject: 'Project Update', snippet: 'Here is the latest...' },
      { from: 'notifications@clickup.com', subject: 'Task Updated', snippet: 'You updated task...' },
      { from: 'Jane Smith <jane@example.com>', subject: 'Meeting Tomorrow', snippet: 'Reminder about our meeting...' }
    ];

    const filtered = filterNoise(testEmails);
    const summary = generateSummary(filtered);
    console.log('\nFiltered emails:', filtered.length);
    console.log('\nSummary:\n', summary);

    // Write to file for TTS
    fs.writeFileSync(path.join(__dirname, 'summary.txt'), summary);
    console.log('\nSummary written to summary.txt');
    return;
  }

  try {
    console.log('Fetching unread emails...');
    const auth = await loadCredentials();
    const emails = await fetchUnreadEmails(auth);

    console.log(`Found ${emails.length} unread emails`);

    const filtered = filterNoise(emails);
    console.log(`${filtered.length} important emails after filtering`);

    const summary = generateSummary(filtered);

    // Write summary to file
    const summaryPath = path.join(__dirname, 'summary.txt');
    fs.writeFileSync(summaryPath, summary);

    console.log(`Summary written to ${summaryPath}`);
    console.log('\n' + summary);

  } catch (error) {
    console.error('Fatal error:', error.message);
    process.exit(1);
  }
}

main();
