const { chromium } = require('playwright');

(async () => {
  console.log('🚀 Testing Work Tracking Dashboard...\n');

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    // Navigate to dashboard
    console.log('📊 Opening dashboard at http://localhost:4242/work-dashboard.html');
    await page.goto('http://localhost:4242/work-dashboard.html', { waitUntil: 'networkidle' });

    // Wait for initial load
    await page.waitForTimeout(2000);

    // Check for errors
    const errorContainer = await page.$('#error-container');
    const errorText = await errorContainer?.textContent();

    if (errorText && errorText.trim()) {
      console.error('❌ ERROR DETECTED:', errorText);
    } else {
      console.log('✅ No errors in error container');
    }

    // Check if content loaded
    const contentVisible = await page.isVisible('#content');
    console.log(`📄 Content visible: ${contentVisible ? '✅ YES' : '❌ NO'}`);

    // Check stats
    const activeAgents = await page.textContent('#stat-active-agents');
    const totalTasks = await page.textContent('#stat-total-tasks');
    const prsCreated = await page.textContent('#stat-prs-created');

    console.log('\n📊 Stats:');
    console.log(`  Active Agents: ${activeAgents}`);
    console.log(`  Total Tasks: ${totalTasks}`);
    console.log(`  PRs Created: ${prsCreated}`);

    // Check search box
    const searchBox = await page.$('#search-box');
    console.log(`\n🔍 Search box present: ${searchBox ? '✅ YES' : '❌ NO'}`);

    // Check tables
    const activeWorkRows = await page.$$('#active-work tr');
    const completedWorkRows = await page.$$('#completed-work tr');

    console.log(`\n📋 Tables:`);
    console.log(`  Active work rows: ${activeWorkRows.length}`);
    console.log(`  Completed work rows: ${completedWorkRows.length}`);

    // Take screenshot
    await page.screenshot({ path: 'C:/scripts/_machine/dashboard-test.png', fullPage: true });
    console.log('\n📸 Screenshot saved to C:/scripts/_machine/dashboard-test.png');

    // Check console errors
    page.on('console', msg => {
      if (msg.type() === 'error') {
        console.error('🔴 Browser console error:', msg.text());
      }
    });

    // Wait a bit to see auto-refresh
    console.log('\n⏳ Waiting 5 seconds to observe auto-refresh...');
    await page.waitForTimeout(5000);

    const lastUpdated = await page.textContent('#last-updated');
    console.log(`⏰ Last updated: ${lastUpdated}`);

    console.log('\n✅ Test complete!');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await browser.close();
  }
})();
