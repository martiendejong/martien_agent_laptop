/**
 * Test FAQ Generation with Playwright
 *
 * Tests:
 * 1. Check if FAQ section exists on page
 * 2. Generate FAQs via Hazina API
 * 3. Verify FAQs appear on frontend
 * 4. Take screenshot as evidence
 */

const { chromium } = require('playwright');

async function testFaqGeneration() {
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext();
    const page = await context.newPage();

    try {
        console.log('=== FAQ Generation Test ===\n');

        // Test page configuration
        const testPageId = 32287;
        const testPageUrl = 'http://localhost/?page_id=' + testPageId;
        const testPageTitle = 'AI Research';

        console.log(`[1/4] Visiting test page: ${testPageTitle} (ID: ${testPageId})`);
        await page.goto(testPageUrl, { waitUntil: 'networkidle' });

        // Take screenshot of initial state
        await page.screenshot({ path: 'C:\\scripts\\logs\\faq-test-before.png', fullPage: true });
        console.log('  ✓ Screenshot taken: faq-test-before.png');

        // Check for existing FAQ section
        console.log('\n[2/4] Checking for existing FAQ section...');
        const faqSection = await page.locator('.faq-section, .aio-faq, [data-faq], #faq').first();
        const hasFaqSection = await faqSection.count() > 0;

        if (hasFaqSection) {
            console.log('  ✓ FAQ section found on page');
            const faqItems = await page.locator('.faq-item, .faq-question').count();
            console.log(`  ✓ Number of FAQ items: ${faqItems}`);
        } else {
            console.log('  ⚠ No FAQ section found - this is expected if theme doesn\'t render AIO FAQs yet');
        }

        // Check page meta for AIO data (WordPress stores FAQs in post meta)
        console.log('\n[3/4] Checking WordPress post meta for AIO data...');
        const pageSource = await page.content();
        const hasAioMeta = pageSource.includes('_aio_enabled') || pageSource.includes('aio-information');

        if (hasAioMeta) {
            console.log('  ✓ AIO meta data found in page source');
        } else {
            console.log('  ⚠ No AIO meta data in page source');
        }

        // Generate FAQs via Hazina API (using fetch from browser context for CORS)
        console.log('\n[4/4] Generating FAQs via Hazina API...');

        const generateResult = await page.evaluate(async ({ pageId }) => {
            try {
                const response = await fetch(`http://localhost:5000/api/wordpress/generate-questions?projectId=artrevisionist&pageId=${pageId}`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' }
                });

                if (!response.ok) {
                    return {
                        success: false,
                        error: `HTTP ${response.status}: ${response.statusText}`,
                        body: await response.text()
                    };
                }

                return { success: true, status: response.status };
            } catch (error) {
                return { success: false, error: error.message };
            }
        }, { pageId: testPageId });

        if (generateResult.success) {
            console.log(`  ✓ FAQ generation API call successful (HTTP ${generateResult.status})`);
        } else {
            console.log(`  ✗ FAQ generation failed: ${generateResult.error}`);
            if (generateResult.body) {
                console.log(`  Response body: ${generateResult.body.substring(0, 200)}...`);
            }
        }

        // Reload page to see if FAQs appear
        console.log('\n[Verification] Reloading page to check for FAQs...');
        await page.reload({ waitUntil: 'networkidle' });

        // Wait a bit for dynamic content
        await page.waitForTimeout(2000);

        // Check again for FAQ section
        const faqSectionAfter = await page.locator('.faq-section, .aio-faq, [data-faq], #faq').first();
        const hasFaqSectionAfter = await faqSectionAfter.count() > 0;

        if (hasFaqSectionAfter) {
            const faqItemsAfter = await page.locator('.faq-item, .faq-question').count();
            console.log(`  ✓ FAQ section visible with ${faqItemsAfter} items`);
        } else {
            console.log('  ⚠ FAQ section still not visible (theme may need FAQ rendering implementation)');
        }

        // Take screenshot of final state
        await page.screenshot({ path: 'C:\\scripts\\logs\\faq-test-after.png', fullPage: true });
        console.log('  ✓ Screenshot taken: faq-test-after.png');

        // Check WordPress database directly via REST API
        console.log('\n[Database Check] Verifying FAQs stored in WordPress...');
        const aioData = await page.evaluate(async ({ pageId }) => {
            try {
                // Note: This endpoint might not exist - we're checking
                const response = await fetch(`http://localhost/wp-json/api/v1/aio-information/${pageId}`);
                if (!response.ok) return { error: 'Endpoint not found or error' };
                return await response.json();
            } catch (error) {
                return { error: error.message };
            }
        }, { pageId: testPageId });

        if (aioData.error) {
            console.log(`  ⚠ Could not fetch AIO data from WordPress REST API: ${aioData.error}`);
            console.log('  Note: Custom REST endpoint might not be registered yet');
        } else {
            console.log(`  ✓ AIO data retrieved from WordPress`);
            if (aioData.questions && aioData.questions.length > 0) {
                console.log(`  ✓ ${aioData.questions.length} FAQs stored in database`);
                console.log('\n  Sample FAQ:');
                console.log(`    Q: ${aioData.questions[0].question}`);
                console.log(`    A: ${aioData.questions[0].answer.substring(0, 100)}...`);
            }
        }

        console.log('\n=== Test Summary ===');
        console.log('✓ Page accessed successfully');
        console.log('✓ Screenshots captured (before/after)');
        console.log(generateResult.success ? '✓ FAQ generation API called' : '✗ FAQ generation failed');
        console.log(hasFaqSectionAfter ? '✓ FAQ section visible on frontend' : '⚠ FAQ section not visible (needs theme implementation)');
        console.log('\nScreenshots saved to:');
        console.log('  - C:\\scripts\\logs\\faq-test-before.png');
        console.log('  - C:\\scripts\\logs\\faq-test-after.png');

    } catch (error) {
        console.error('\n❌ Test failed with error:', error.message);
        console.error(error.stack);
    } finally {
        await browser.close();
    }
}

// Run test
testFaqGeneration().catch(console.error);
