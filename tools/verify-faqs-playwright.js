/**
 * Verify FAQs are visible on WordPress pages with Playwright
 */

const { chromium } = require('playwright');

async function verifyFaqs() {
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext();
    const page = await context.newPage();

    try {
        console.log('=== FAQ Verification with Playwright ===\n');

        // Test pages to verify
        const testPages = [
            { id: 32152, title: 'Who Founded the Valsuani Foundry?' },
            { id: 32214, title: 'Senufo Hornbill' }
        ];

        for (const testPage of testPages) {
            console.log(`\n[Verifying] ${testPage.title} (ID: ${testPage.id})`);
            const url = `http://localhost/?page_id=${testPage.id}`;

            await page.goto(url, { waitUntil: 'networkidle' });

            // Check for FAQ section in various possible locations
            const faqSelectors = [
                '.b2bk-qa',
                '.faq-section',
                '[data-qa-items]',
                '.qa-items',
                '[class*="qa"]',
                'article' // fallback to check entire article
            ];

            let foundFaqs = false;
            let faqCount = 0;

            for (const selector of faqSelectors) {
                const elements = await page.locator(selector).count();
                if (elements > 0) {
                    console.log(`  ✓ Found FAQ container: ${selector}`);

                    // Try to count individual Q&A items
                    const qaItems = await page.locator(`${selector} .qa-item, ${selector} .b2bk-qa-item`).count();
                    if (qaItems > 0) {
                        faqCount = qaItems;
                        foundFaqs = true;
                        break;
                    }

                    // Check page source for qa_items
                    const pageContent = await page.content();
                    if (pageContent.includes('b2bk_qa_items') || pageContent.includes('qa-item')) {
                        foundFaqs = true;
                        console.log(`  ✓ FAQ data found in page source`);
                        break;
                    }
                }
            }

            if (foundFaqs && faqCount > 0) {
                console.log(`  ✓ ${faqCount} FAQ items visible on page`);
            } else if (foundFaqs) {
                console.log(`  ⚠ FAQ data exists but rendering may not be complete`);
            } else {
                console.log(`  ⚠ No FAQ section found - theme may need updates for rendering`);
            }

            // Take screenshot
            const screenshotPath = `C:\\scripts\\logs\\faq-verify-${testPage.id}.png`;
            await page.screenshot({ path: screenshotPath, fullPage: true });
            console.log(`  ✓ Screenshot: faq-verify-${testPage.id}.png`);
        }

        console.log('\n=== Verification Summary ===');
        console.log('✓ All test pages accessed');
        console.log('✓ Screenshots captured');
        console.log('⚠ Note: FAQs are stored in WordPress database but theme rendering may need implementation');

    } catch (error) {
        console.error('\n❌ Verification failed:', error.message);
    } finally {
        await browser.close();
    }
}

verifyFaqs().catch(console.error);
