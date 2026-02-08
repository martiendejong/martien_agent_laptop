/**
 * Verify FAQ edit button appears when logged in
 */

const { chromium } = require('playwright');

async function verifyEditButton() {
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext();
    const page = await context.newPage();

    try {
        console.log('=== Verifying Edit Button When Logged In ===\n');

        // Login to WordPress
        console.log('[1] Navigating to WordPress login...');
        await page.goto('http://localhost/wp-login.php');

        // Check if already logged in (redirects)
        if (page.url().includes('wp-admin')) {
            console.log('  ✓ Already logged in');
        } else {
            console.log('  ℹ️  Login form requires manual authentication');
            console.log('  ℹ️  Please login manually in the browser window...\n');

            // Wait for user to login manually (check for wp-admin URL)
            await page.waitForFunction(
                () => window.location.href.includes('wp-admin'),
                { timeout: 60000 }
            );
            console.log('  ✓ Login successful\n');
        }

        // Navigate to a test page
        console.log('[2] Navigating to Contact page...');
        await page.goto('http://localhost/contact-us/');
        await page.waitForLoadState('networkidle');

        // Check for edit button
        console.log('[3] Checking for edit button...');
        const editButton = await page.locator('.b2bk-qa-edit-btn').count();
        const editButtonVisible = await page.locator('.b2bk-qa-edit-btn').isVisible().catch(() => false);

        if (editButton > 0 && editButtonVisible) {
            console.log('  ✓ Edit button found and visible');

            // Get button text
            const buttonText = await page.locator('.b2bk-qa-edit-btn').textContent();
            console.log(`  ✓ Button text: "${buttonText.trim()}"`);

            // Take screenshot
            await page.screenshot({
                path: 'C:\\scripts\\logs\\faq-edit-button-visible.png',
                fullPage: true
            });
            console.log('  ✓ Screenshot saved: faq-edit-button-visible.png');

            // Test clicking the button
            console.log('[4] Testing edit button click...');
            await page.locator('.b2bk-qa-edit-btn').click();
            await page.waitForTimeout(1000);

            // Check if modal/dialog opened
            const modal = await page.locator('.b2bk-qa-modal, [role="dialog"], .modal').count();
            if (modal > 0) {
                console.log('  ✓ Edit modal opened');
            } else {
                console.log('  ℹ️  No modal detected (check for other edit UI)');
            }

            // Take screenshot with modal
            await page.screenshot({
                path: 'C:\\scripts\\logs\\faq-edit-modal.png',
                fullPage: true
            });
            console.log('  ✓ Screenshot with edit UI saved');

        } else {
            console.log('  ⚠️  Edit button not found or not visible');
            console.log('  ℹ️  This could mean:');
            console.log('     - User is not logged in with correct permissions');
            console.log('     - Edit button CSS class needs verification');
        }

        console.log('\n=== Verification Complete ===');

    } catch (error) {
        console.error('\n❌ Error:', error.message);
    } finally {
        // Don't close browser immediately so user can inspect
        console.log('\nBrowser will stay open for inspection. Close manually when done.');
        // await browser.close();
    }
}

verifyEditButton().catch(console.error);
