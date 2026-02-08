/**
 * Verify FAQs are now rendering on all page types
 */

const { chromium } = require('playwright');

async function verifyRendering() {
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext();
    const page = await context.newPage();

    try {
        console.log('=== Verifying FAQ Rendering Across Page Types ===\n');

        const testPages = [
            { url: 'http://localhost/', name: 'Homepage', id: null },
            { url: 'http://localhost/contact-us/', name: 'Contact', id: 291 },
            { url: 'http://localhost/ai-research/', name: 'AI Research', id: 32287 },
            { url: 'http://localhost/senufo-hornbill/', name: 'Senufo Hornbill (Topic)', id: 32262 }
        ];

        for (const testPage of testPages) {
            console.log(`\n[Testing] ${testPage.name}`);
            console.log(`URL: ${testPage.url}`);

            await page.goto(testPage.url, { waitUntil: 'networkidle' });

            // Check if FAQ section exists
            const faqSection = await page.locator('.ar-qa-section').count();
            const faqTitle = await page.locator('.ar-qa-title').count();
            const faqItems = await page.locator('.ar-qa-item').count();
            const editButton = await page.locator('.b2bk-qa-edit-btn').count();

            if (faqSection > 0) {
                console.log(`  ✓ FAQ section found`);
                if (faqTitle > 0) {
                    console.log(`  ✓ FAQ title present`);
                }
                if (faqItems > 0) {
                    console.log(`  ✓ ${faqItems} FAQ items rendered`);

                    // Get first question as sample
                    const firstQuestion = await page.locator('.ar-qa-question').first().textContent();
                    console.log(`  ✓ Sample Q: ${firstQuestion.substring(0, 60)}...`);
                } else {
                    console.log(`  ⚠️  FAQ section exists but no items rendered (FAQs may be empty)`);
                }
                if (editButton > 0) {
                    console.log(`  ✓ Edit button visible (logged in)`);
                }
            } else {
                console.log(`  ⚠️  FAQ section not found`);
            }

            // Take screenshot
            const screenshotName = testPage.name.toLowerCase().replace(/\s+/g, '-').replace(/[()]/g, '');
            await page.screenshot({
                path: `C:\\scripts\\logs\\faq-render-${screenshotName}.png`,
                fullPage: true
            });
            console.log(`  ✓ Screenshot: faq-render-${screenshotName}.png`);
        }

        console.log('\n=== Summary ===');
        console.log('✓ All test pages checked');
        console.log('✓ Screenshots captured');
        console.log('✓ FAQ sections should now be visible on all pages');

    } catch (error) {
        console.error('\n❌ Verification failed:', error.message);
    } finally {
        await browser.close();
    }
}

verifyRendering().catch(console.error);
